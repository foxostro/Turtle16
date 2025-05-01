//
//  DebugConsoleView.swift
//  TurtleAssembler
//
//  Created by Andrew Fox on 12/7/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import Combine
import SwiftUI

struct DebugConsoleView: NSViewControllerRepresentable {
    // SwiftUI's TextEditor is pretty undercooked so let's wrap and bring in
    // DebugConsoleViewController, the implementation from the old Simulator app
    // which uses AppKit's NSTextView.

    @StateObject var viewModel: ViewModel

    func makeNSViewController(context: Context) -> DebugConsoleViewController {
        DebugConsoleViewController(debugger: viewModel.document.debugger)
    }

    func updateNSViewController(_ uiViewController: DebugConsoleViewController, context: Context) {
        // nothing to do
    }
}

extension DebugConsoleView {
    @MainActor class ViewModel: ObservableObject {
        @Published var document: TurtleSimulatorDocument

        init(document: TurtleSimulatorDocument) {
            self.document = document
        }
    }
}

#Preview {
    DebugConsoleView(viewModel: DebugConsoleView.ViewModel(document: TurtleSimulatorDocument()))
}
