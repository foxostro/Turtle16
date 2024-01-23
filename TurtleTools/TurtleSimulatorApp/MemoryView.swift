//
//  MemoryView.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/7/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import Combine
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var bin: UTType {
        UTType(mimeType: "application/octet-stream")!
    }
}

struct MemoryView: View {
    @StateObject var viewModel: ViewModel
    @State var isLoadPanelPresented = false
    
    struct HexDataView: NSViewRepresentable {
        // We need to use NSTableView for an acceptable table because SwiftUI's
        // TableView has very poor performance when using more than a trivial number
        // of rows.
        
        @ObservedObject var viewModel: ViewModel
        
        class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
            var viewModel: ViewModel
            
            init(viewModel: ViewModel) {
                self.viewModel = viewModel
            }
            
            func numberOfRows(in tableView: NSTableView) -> Int {
                viewModel.numberOfRows
            }
            
            func tableView(_ tableView: NSTableView,
                           objectValueFor tableColumn: NSTableColumn?,
                           row: Int) -> Any? {
                
                switch tableColumn?.identifier {
                case Constant.addressColumnIdentifier:
                    UInt16(row * 16).hexadecimalString
                    
                case Constant.wordColumnIdentifier[0]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+0))
                    
                case Constant.wordColumnIdentifier[1]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+1))
                    
                case Constant.wordColumnIdentifier[2]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+2))
                    
                case Constant.wordColumnIdentifier[3]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+3))
                    
                case Constant.wordColumnIdentifier[4]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+4))
                    
                case Constant.wordColumnIdentifier[5]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+5))
                    
                case Constant.wordColumnIdentifier[6]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+6))
                    
                case Constant.wordColumnIdentifier[7]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+7))
                    
                case Constant.wordColumnIdentifier[8]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+8))
                    
                case Constant.wordColumnIdentifier[9]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+9))
                    
                case Constant.wordColumnIdentifier[10]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+10))
                    
                case Constant.wordColumnIdentifier[11]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+11))
                    
                case Constant.wordColumnIdentifier[12]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+12))
                    
                case Constant.wordColumnIdentifier[13]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+13))
                    
                case Constant.wordColumnIdentifier[14]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+14))
                    
                case Constant.wordColumnIdentifier[15]:
                    String(format: Constant.wordFormat, viewModel.load(address: row*16+15))
                    
                case Constant.textColumnIdentifier:
                    viewModel.text(at: row)
                    
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
            
            let addressColumn = NSTableColumn(identifier: Constant.addressColumnIdentifier)
            addressColumn.title = NSLocalizedString("Address", comment: "Label for the Address column of the hex data table")
            addressColumn.width = Constant.addressColumnWidth
            tableView.addTableColumn(addressColumn)
            
            for i in 0..<16 {
                let column = NSTableColumn(identifier: Constant.wordColumnIdentifier[i])
                column.title = Constant.hexDigits[i]
                column.width = Constant.wordColumnWidth
                tableView.addTableColumn(column)
            }
            
            let textColumn = NSTableColumn(identifier: Constant.textColumnIdentifier)
            textColumn.title = NSLocalizedString("Text", comment: "Label for the Text column of the hex data table")
            textColumn.width = Constant.textColumnWidth
            tableView.addTableColumn(textColumn)
            
            tableView.headerView = NSTableHeaderView()
            tableView.usesAlternatingRowBackgroundColors = true
            
            let scrollView = NSScrollView()
            scrollView.documentView = tableView
            
            return scrollView
        }

        func updateNSView(_ scrollView: NSScrollView, context: Context) {
            guard let tableView = scrollView.documentView as? NSTableView else { return }
            tableView.reloadData()
        }
        
        enum Constant {
            static let addressColumnIdentifier = NSUserInterfaceItemIdentifier("Address")
            static let addressColumnWidth = 50.0
            
            static let hexDigits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
            static let wordColumnIdentifier = hexDigits.map { NSUserInterfaceItemIdentifier("Word \($0)")
            }
            static let wordColumnWidth = 40.0
            
            static let textColumnIdentifier = NSUserInterfaceItemIdentifier("Text")
            static let textColumnWidth = 265.0
            
            static let wordFormat = "%04x"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker(NSLocalizedString("Address Space:", comment: "Label for the address space picker"), selection: $viewModel.selectedAddressSpace) {
                    ForEach(viewModel.addressSpaces) {
                        Text("\($0.description)")
                    }
                }
                Spacer()
                Button(action: {
                    isLoadPanelPresented = true
                }, label: {
                    Text("Load")
                })
                Button(action: {
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [UTType.bin]
                    panel.allowsOtherFileTypes = true
                    panel.isExtensionHidden = false
                    panel.begin { (response: NSApplication.ModalResponse) in
                        guard response == NSApplication.ModalResponse.OK,
                              let url = panel.url else {
                            return
                        }
                        viewModel.saveMemory(url: url)
                    }
                }, label: {
                    Text("Save")
                })
            }
            .padding(Constant.topBarEdgeInsets)
            
            HexDataView(viewModel: viewModel)
        }
        .fileImporter(isPresented: $isLoadPanelPresented,
                      allowedContentTypes: [UTType.bin],
                      onCompletion: { result in
            
            switch result {
            case .success(let url):
                viewModel.loadMemory(url: url)
                
            case .failure:
                NSSound.beep()
            }
        })
    }
    
    enum Constant {
        static let topBarEdgeInsets = EdgeInsets(top: 6.0, leading: 6.0, bottom: 0.0, trailing: 6.0)
    }
}

extension MemoryView {
    @MainActor class ViewModel: ObservableObject {
        private var subscriptions = Set<AnyCancellable>()
        
        @Published var document: TurtleSimulatorDocument
        @Published var selectedAddressSpace: AddressSpace = .program
        @Published var numberOfRows: Int = (1<<16) / 0x10
        
        var addressSpaces: [AddressSpace] { AddressSpace.allCases }
        
        enum AddressSpace: Identifiable, CaseIterable {
            case program, data
            
            var id: Self { self }
            
            var description: String {
                switch self {
                case .program: "Program"
                case .data: "Data"
                }
            }
        }
        
        init(document: TurtleSimulatorDocument) {
            self.document = document
            self.document.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &subscriptions)
        }
        
        func load(address: Int) -> UInt16 {
            switch selectedAddressSpace {
            case .program:
                document.debugger.withLock { debugConsole in
                    debugConsole.computer.instructions[address]
                }
                
            case .data:
                document.debugger.withLock { debugConsole in
                    debugConsole.computer.ram[address]
                }
            }
        }
        
        func saveMemory(url: URL) {
            switch selectedAddressSpace {
            case .program:
                document.debugger.run(instruction: .save("program", url))
                
            case .data:
                document.debugger.run(instruction: .save("data", url))
            }
        }
        
        func loadMemory(url: URL) {
            switch selectedAddressSpace {
            case .program:
                document.debugger.run(instruction: .load("program", url))
                
            case .data:
                document.debugger.run(instruction: .load("data", url))
            }
        }
        
        func text(at row: Int) -> String {
            let words = ((row*16)..<(row*16+16)).map { load(address: $0) }
            var bytes: [UInt8] = []
            for word in words {
                bytes.append(UInt8(word >> 8) & 0xff)
                bytes.append(UInt8(word & 0xff))
            }
            let text = bytes.map { (byte: UInt8) -> String in
                (byte >= 32 && byte < 126) ? String(UnicodeScalar(byte)) : "."
            }.joined(separator: "")
            return text
        }
    }
}

#Preview {
    MemoryView(viewModel: MemoryView.ViewModel(document: TurtleSimulatorDocument()))
}
