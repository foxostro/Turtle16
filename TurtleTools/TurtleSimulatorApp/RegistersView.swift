//
//  RegistersView.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/5/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import Combine
import SwiftUI

struct RegistersView: View {
    @StateObject var viewModel: ViewModel
    
    struct RegisterValueView: View {
        enum DisplayValueAs: CaseIterable, Identifiable {
            case hex, binary, unsignedDecimal, signedDecimal
            
            var id: Self { self }
            
            var description: String {
                switch self {
                case .hex: "Hexadecimal"
                case .binary: "Binary"
                case .unsignedDecimal: "Unsigned Decimal"
                case .signedDecimal: "Signed Decimal"
                }
            }
        }
        
        @State var displayValueAs: DisplayValueAs = .hex
        @State var value: UInt16
        
        var body: some View {
            Text(formattedValue)
                .contextMenu {
                    Picker("Display Value As", selection: $displayValueAs) {
                        ForEach(DisplayValueAs.allCases) { mode in
                            Text(mode.description)
                        }
                    }
                }
        }
        
        var formattedValue: String {
            switch displayValueAs {
            case .hex:
                value.hexadecimalString
                
            case .binary:
                value.binaryString
                
            case .unsignedDecimal:
                "\(value)"
                
            case .signedDecimal:
                value.signedDecimalString
            }
        }
    }
    
    var body: some View {
        Table($viewModel.registers) {
            TableColumn("Register") { register in
                HStack {
                    Spacer()
                    Text(register.wrappedValue.name)
                }
            }
            .width(Constant.registerColumnWidth)
            
            TableColumn("Value") { register in
                RegisterValueView(value: register.wrappedValue.value)
            }
            .width(min: Constant.valueColumnMinWidth)
        }
    }
    
    enum Constant {
        static let registerColumnWidth = 50.0
        static let valueColumnMinWidth = 50.0
    }
}

extension RegistersView {
    @MainActor class ViewModel: ObservableObject {
        private var subscriptions = Set<AnyCancellable>()
        
        struct Register: Identifiable {
            let id = UUID()
            let name: String
            let value: UInt16
        }
        
        @Published var document: TurtleSimulatorDocument
        @Published var registers: [Register] = []
        
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
            let gpr = (0..<document.debugger.computer.numberOfRegisters).map { i in
                Register(name: "r\(i)", value: document.debugger.computer.getRegister(i))
            }
            let pc = Register(name: "pc", value: document.debugger.computer.pc)
            registers = gpr + [pc]
        }
    }
}

extension UInt16 {
    var hexadecimalString: String {
        String(format: "$%04x", self)
    }
    
    var binaryString: String {
        var result = String(self, radix: 2)
        if result.count < 16 {
            result = String(repeatElement("0", count: 16 - result.count)) + result
        }
        return "0b" + result
    }
    
    var signedDecimalValue: Int {
        if self & 0x8000 == 0 {
            Int(self)
        }
        else {
            Int(self) - Int(Self.max) - 1
        }
    }
    
    var signedDecimalString: String {
        "\(signedDecimalValue)"
    }
}

#Preview {
    RegistersView(viewModel: RegistersView.ViewModel(document: TurtleSimulatorDocument()))
}
