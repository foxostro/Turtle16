//
//  InstructionRAMPeripheral.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 1/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class InstructionRAMPeripheral: ComputerPeripheral {
    public let store: (_ value: UInt8, _ address: Int) -> Void
    public let load: (_ address: Int) -> UInt8
    
    public init(name: String = "Instruction RAM Slice",
                store: @escaping (_ value: UInt8, _ address: Int) -> Void,
                load: @escaping (_ address: Int) -> UInt8) {
        self.store = store
        self.load = load
        super.init(name: name)
    }
    
    func reverseBits(_ value: UInt8) -> UInt8 {
        var n = value
        var result: UInt8 = 0
        while (n > 0) {
            result <<= 1
            if ((n & 1) == 1) {
                result ^= 1
            }
            n >>= 1
        }
        return result
    }
    
    public override func onControlClock() {
        if (PO == .active) {
            // There's a hardware bug in Rev 2 where the bits of the instruction
            // RAM port connected to the data bus are in reverse order.
            bus = Register(withValue: reverseBits(load(valueOfXYPair())))
        }
    }
    
    public override func onRegisterClock() {
        if (PI == .active) {
            // There's a hardware bug in Rev 2 where the bits of the instruction
            // RAM port connected to the data bus are in reverse order.
            store(reverseBits(bus.value), valueOfXYPair())
        }
    }
}
