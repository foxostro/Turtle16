//
//  DebugStatusBar.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/7/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import Combine
import SwiftUI

struct DebugStatusBar: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            HStack {
                Text("Halted")
                    .opacity(viewModel.isHalted ? 1.0 : Constant.disabledLabelOpacity)
                Text("Resetting")
                    .opacity(viewModel.isResetting ? 1.0 : Constant.disabledLabelOpacity)
                Text("Stall")
                    .opacity(viewModel.isStalling ? 1.0 : Constant.disabledLabelOpacity)
                Spacer()
                Text("C")
                    .opacity(viewModel.isCarryFlagSet ? 1.0 : Constant.disabledLabelOpacity)
                Text("Z")
                    .opacity(viewModel.isZeroFlagSet ? 1.0 : Constant.disabledLabelOpacity)
                Text("V")
                    .opacity(viewModel.isOverflowFlagSet ? 1.0 : Constant.disabledLabelOpacity)
                Text("N")
                    .opacity(viewModel.isNegativeFlagSet ? 1.0 : Constant.disabledLabelOpacity)
            }
            .padding([.leading, .trailing], Constant.statusBarPadding)
            HStack {
                Spacer()
                Text("t=\(viewModel.timeStamp)")
                Spacer()
            }
        }
        .font(.caption)
    }

    enum Constant {
        static let statusBarPadding = 12.0
        static let disabledLabelOpacity = 0.3
    }
}

extension DebugStatusBar {
    @MainActor class ViewModel: ObservableObject {
        private var subscriptions = Set<AnyCancellable>()

        @Published var document: TurtleSimulatorDocument
        @Published var isHalted = false
        @Published var isResetting = false
        @Published var isStalling = false
        @Published var isCarryFlagSet = false
        @Published var isZeroFlagSet = false
        @Published var isOverflowFlagSet = false
        @Published var isNegativeFlagSet = false
        @Published var timeStamp = ""

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

        private func reloadData() {
            guard let computer = document.debugger.latestSnapshot else { return }
            isHalted = computer.isHalted
            isResetting = computer.isResetting
            isStalling = computer.isStalling
            isCarryFlagSet = computer.c != 0
            isZeroFlagSet = computer.z != 0
            isOverflowFlagSet = computer.v != 0
            isNegativeFlagSet = computer.n != 0
            timeStamp = "\(computer.timeStamp)"
        }
    }
}

#Preview {
    DebugStatusBar(viewModel: DebugStatusBar.ViewModel(document: TurtleSimulatorDocument()))
}
