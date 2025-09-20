//
//  DisassemblyView.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/6/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import Combine
import SwiftUI
import TurtleSimulatorCore

struct DisassemblyView: NSViewRepresentable {
    // We need to use NSTableView for an acceptable table because SwiftUI's
    // TableView has very poor performance when using more than a trivial number
    // of rows.

    @StateObject var viewModel: ViewModel

    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        var viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        func numberOfRows(in _: NSTableView) -> Int {
            viewModel.numberOfRows
        }

        func tableView(
            _: NSTableView,
            objectValueFor tableColumn: NSTableColumn?,
            row: Int
        ) -> Any? {
            switch tableColumn?.identifier {
            case Constant.addressIdentifier:
                UInt16(row).hexadecimalString

            case Constant.wordIdentifier:
                viewModel.word(at: row)

            case Constant.labelIdentifier:
                viewModel.label(at: row)

            case Constant.mnemonicIdentifier:
                viewModel.mnemonic(at: row)

            default:
                nil
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let tableView = NSTableView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator

        let addressColumn = NSTableColumn(identifier: Constant.addressIdentifier)
        addressColumn.title = NSLocalizedString(
            "Address",
            comment: "Address of the disassembled instruction"
        )
        addressColumn.width = Constant.addressColumnWidth
        tableView.addTableColumn(addressColumn)

        let wordColumn = NSTableColumn(identifier: Constant.wordIdentifier)
        wordColumn.title = NSLocalizedString("Word", comment: "The instruction word")
        wordColumn.width = Constant.wordColumnWidth
        tableView.addTableColumn(wordColumn)

        let labelColumn = NSTableColumn(identifier: Constant.labelIdentifier)
        labelColumn.title = NSLocalizedString("Label", comment: "The associated label, if any")
        labelColumn.width = Constant.labelColumnWidth
        tableView.addTableColumn(labelColumn)

        let mnemonicColumn = NSTableColumn(identifier: Constant.mnemonicIdentifier)
        mnemonicColumn.title = NSLocalizedString(
            "Mnemonic",
            comment: "The mnemonic of the disassembled instruction"
        )
        tableView.addTableColumn(mnemonicColumn)

        tableView.headerView = NSTableHeaderView()
        tableView.usesAlternatingRowBackgroundColors = true

        let scrollView = NSScrollView()
        scrollView.documentView = tableView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context _: Context) {
        guard let tableView = scrollView.documentView as? NSTableView else { return }
        tableView.reloadData()
        tableView.selectRowIndexes(
            IndexSet(integer: Int(viewModel.pc)),
            byExtendingSelection: false
        )
    }

    enum Constant {
        static let addressIdentifier = NSUserInterfaceItemIdentifier("Address")
        static let wordIdentifier = NSUserInterfaceItemIdentifier("Word")
        static let labelIdentifier = NSUserInterfaceItemIdentifier("Label")
        static let mnemonicIdentifier = NSUserInterfaceItemIdentifier("Mnemonic")
        static let addressColumnWidth = 50.0
        static let wordColumnWidth = 50.0
        static let labelColumnWidth = 50.0
    }
}

extension DisassemblyView {
    @MainActor class ViewModel: ObservableObject {
        private var subscriptions = Set<AnyCancellable>()

        @Published var document: TurtleSimulatorDocument
        @Published var numberOfRows = Int(UInt16.max) + 1
        @Published var pc: UInt16 = 0

        init(document: TurtleSimulatorDocument) {
            self.document = document
            self.document
                .objectWillChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.reloadData()
                }
                .store(in: &subscriptions)
            reloadData()
        }

        private var latestSnapshot: TurtleComputer? {
            document.debugger.latestSnapshot
        }

        private func reloadData() {
            pc = latestSnapshot?.pc ?? 0
        }

        func word(at row: Int) -> String {
            latestSnapshot?.instructions[row].hexadecimalString ?? ""
        }

        func label(at row: Int) -> String {
            let entries = latestSnapshot?.disassembly.entries ?? []
            if row < entries.count, let label = entries[row].label {
                return label + ":"
            }
            return ""
        }

        func mnemonic(at row: Int) -> String {
            let entries = latestSnapshot?.disassembly.entries ?? []
            if row < entries.count, let mnemonic = entries[row].mnemonic {
                return mnemonic
            }
            return ""
        }
    }
}

#Preview {
    DisassemblyView(viewModel: DisassemblyView.ViewModel(document: TurtleSimulatorDocument()))
}
