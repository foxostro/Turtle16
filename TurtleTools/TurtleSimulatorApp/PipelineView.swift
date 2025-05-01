//
//  PipelineView.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/5/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import Combine
import SwiftUI

struct PipelineView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        Table(viewModel.pipelineStages) {
            TableColumn("Stage", value: \.shortName)
                .width(Constant.stageColumnWidth)
            TableColumn("PC", value: \.programCounterString)
                .width(Constant.pcColumnWidth)
            TableColumn("Disassembly", value: \.disassembly)
                .width(Constant.disassemblyColumnWidth)
            TableColumn("Status", value: \.status)
                .width(min: Constant.statusColumnMinWidth)
        }
    }

    enum Constant {
        static let stageColumnWidth = 50.0
        static let pcColumnWidth = 50.0
        static let disassemblyColumnWidth = 75.0
        static let statusColumnMinWidth = 500.0
    }
}

extension PipelineView {
    @MainActor class ViewModel: ObservableObject {
        private var subscriptions = Set<AnyCancellable>()

        @Published var document: TurtleSimulatorDocument
        @Published var pipelineStages: [PipelineStage] = []

        struct PipelineStage: Identifiable {
            let id = UUID()
            let shortName: String
            let programCounter: UInt16?
            let disassembly: String
            let status: String

            var programCounterString: String {
                programCounter?.hexadecimalString ?? ""
            }
        }

        init(document: TurtleSimulatorDocument) {
            self.document = document
            self.document.objectWillChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.reloadData()
                }
                .store(in: &subscriptions)
            reloadData()
        }

        func reloadData() {
            guard let computer = document.debugger.latestSnapshot else { return }
            let cpu = computer.cpu
            pipelineStages = (0..<cpu.numberOfPipelineStages)
                .map {
                    cpu.getPipelineStageInfo($0)
                }
                .map { info in
                    let disassembledInstruction: String?
                    if let pc = info.pc {
                        let disassembly = computer.disassembly.entries
                        disassembledInstruction =
                            disassembly.first(where: { $0.address == pc })?.mnemonic
                    }
                    else {
                        disassembledInstruction = nil
                    }

                    return PipelineStage(
                        shortName: info.name,
                        programCounter: info.pc,
                        disassembly: disassembledInstruction ?? "",
                        status: info.status
                    )
                }
        }
    }
}

#Preview {
    PipelineView(viewModel: PipelineView.ViewModel(document: TurtleSimulatorDocument()))
}
