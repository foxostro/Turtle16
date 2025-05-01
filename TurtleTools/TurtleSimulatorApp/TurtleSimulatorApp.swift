//
//  TurtleSimulatorApp.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/5/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import SwiftUI

@main
struct TurtleSimulatorApp: App {
    @FocusedObject var document: TurtleSimulatorDocument?

    var body: some Scene {
        DocumentGroup(newDocument: {
            TurtleSimulatorDocument()
        }) { file in
            ContentView(document: file.document)
                .focusedSceneObject(file.document)
        }
        .commands {
            if document != nil {
                CommandGroup(after: .sidebar) {
                    Toggle(
                        isOn: $document!.isShowingRegisters,
                        label: { Text("Show Registers") }
                    )
                    .keyboardShortcut("1")
                    Toggle(
                        isOn: $document!.isShowingPipeline,
                        label: { Text("Show Pipeline") }
                    )
                    .keyboardShortcut("2")
                    Toggle(
                        isOn: $document!.isShowingDisassembly,
                        label: { Text("Show Disassembly") }
                    )
                    .keyboardShortcut("3")
                    Toggle(
                        isOn: $document!.isShowingMemory,
                        label: { Text("Show Memory") }
                    )
                    .keyboardShortcut("4")
                    Divider()
                }
            }
        }
    }
}
