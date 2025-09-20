//
//  ContentView.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/5/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var document: TurtleSimulatorDocument

    var body: some View {
        VSplitView {
            upperDeckView
            VStack {
                DebugConsoleView(viewModel: DebugConsoleView.ViewModel(document: document))
                DebugStatusBar(viewModel: DebugStatusBar.ViewModel(document: document))
            }
            .frame(minHeight: Constant.lowerDeckViewMinHeight)
        }
        .toolbar {
            ToolbarItem {
                if document.isFreeRunning {
                    Button {
                        document.pause()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                }
                else {
                    Button {
                        document.run()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }
        }
    }

    @ViewBuilder var upperDeckView: some View {
        if document.isShowingRegisters || document.isShowingPipeline
            || document.isShowingDisassembly || document.isShowingMemory {
            HSplitView {
                if document.isShowingRegisters {
                    RegistersView(viewModel: RegistersView.ViewModel(document: document))
                        .frame(minWidth: Constant.registersViewMinWidth)
                }
                if document.isShowingPipeline {
                    PipelineView(viewModel: PipelineView.ViewModel(document: document))
                        .frame(minWidth: Constant.pipelineViewMinWidth)
                }
                if document.isShowingDisassembly {
                    DisassemblyView(viewModel: DisassemblyView.ViewModel(document: document))
                        .frame(minWidth: Constant.disassemblyViewMinWidth)
                }
                if document.isShowingMemory {
                    MemoryView(viewModel: MemoryView.ViewModel(document: document))
                        .frame(minWidth: Constant.memoryViewMinWidth)
                }
            }
            .frame(minHeight: Constant.upperDeckViewMinHeight)
        }
    }

    enum Constant {
        static let lowerDeckViewMinHeight = 100.0
        static let upperDeckViewMinHeight = 260.0
        static let registersViewMinWidth = 145.0
        static let pipelineViewMinWidth = 350.0
        static let disassemblyViewMinWidth = 350.0
        static let memoryViewMinWidth = 350.0
    }
}

#Preview {
    ContentView(document: TurtleSimulatorDocument())
}
