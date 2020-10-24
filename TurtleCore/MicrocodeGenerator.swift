//
//  MicrocodeGenerator.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

// Generates microcode for use in the ID stage of TurtleTTL hardware.
public class MicrocodeGenerator: NSObject {
    public var microcode = InstructionDecoder()
    var mapMnemonicToOpcode = [String:Int]()
    var mapOpcodeToMnemonic = [Int:String]()
    var nextOpcode = 0
    
    public static func makeMicrocodeGenerator() -> MicrocodeGenerator {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        return microcodeGenerator
    }
    
    // Registers which can output a value to the bus.
    // These can be the source for a MOV instruction.
    public enum SourceRegister : CaseIterable {
        case A, B, C, E, G, H, M, P, U, V, X, Y
    }
    
    public func modifyControlWord(controlWord: ControlWord, toOutputToBus: SourceRegister) -> ControlWord {
        switch toOutputToBus {
        case .A:
            return controlWord.outputAToBus()
        case .B:
            return controlWord.outputBToBus()
        case .C:
            return controlWord.outputCToBus()
        case .E:
            return controlWord.outputEToBus()
        case .G:
            return controlWord.outputLinkHiToBus()
        case .H:
            return controlWord.outputLinkLoToBus()
        case .M:
            return controlWord.outputMToBus()
        case .P:
            return controlWord.outputPToBus()
        case .U:
            return controlWord.outputUToBus()
        case .V:
            return controlWord.outputVToBus()
        case .X:
            return controlWord.outputXToBus()
        case .Y:
            return controlWord.outputYToBus()
        }
    }
    
    // Registers which can take in a value from the bus.
    // These can be the destination for a MOV instruction.
    public enum DestinationRegister : CaseIterable {
        case A, B, D, M, P, U, V, X, Y, UV
    }
    
    public func modifyControlWord(controlWord: ControlWord, toInputFromBus: DestinationRegister) -> ControlWord {
        switch toInputFromBus {
        case .A:
            return controlWord.inputAFromBus()
        case .B:
            return controlWord.inputBFromBus()
        case .D:
            return controlWord.inputDFromBus()
        case .M:
            return controlWord.inputMFromBus()
        case .P:
            return controlWord.inputPFromBus()
        case .U:
            return controlWord.inputUFromBus()
        case .V:
            return controlWord.inputVFromBus()
        case .X:
            return controlWord.inputXFromBus()
        case .Y:
            return controlWord.inputYFromBus()
        case .UV:
            return controlWord.inputUVFromBus()
        }
    }
    
    public func generate() {
        nop()
        hlt()
        mov()
        alu()
        jmp()
        conditionalJump(mnemonic:  "JC", condition: 0b1010)
        conditionalJump(mnemonic: "JNC", condition: 0b0101)
        conditionalJump(mnemonic:  "JE", condition: 0b0001)
        conditionalJump(mnemonic: "JNE", condition: 0b1110)
        conditionalJump(mnemonic:  "JG", condition: 0b1000)
        conditionalJump(mnemonic: "JLE", condition: 0b0111)
        conditionalJump(mnemonic:  "JL", condition: 0b0100)
        conditionalJump(mnemonic: "JGE", condition: 0b1011)
        link()
        jalr()
        inuv()
        inxy()
        blt()
    }
    
    func record(mnemonic: String, opcode: Int) {
        mapMnemonicToOpcode[mnemonic] = opcode
        mapOpcodeToMnemonic[opcode] = mnemonic
    }
    
    public func nop() {
        let opcode = getNextOpcode()
        record(mnemonic: "NOP", opcode: opcode)
        microcode.store(opcode: opcode, controlWord: ControlWord())
    }
    
    public func hlt() {
        let opcode = getNextOpcode()
        record(mnemonic: "HLT", opcode: opcode)
        let controlWord = ControlWord().withHLT(.active)
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func mov() {
        for source in SourceRegister.allCases {
            for destination in DestinationRegister.allCases {
                var controlWord = ControlWord()
                controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: source)
                controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
                let mnemonic = "MOV \(String(describing: destination)), \(String(describing: source))"
                let opcode = getNextOpcode()
                record(mnemonic: mnemonic, opcode: opcode)
                microcode.store(opcode: opcode, controlWord: controlWord)
            }
        }
    }
    
    public func alu() {
        // ALUwC -- ALU op with the 181's carry input set High.
        // ALUwoC -- ALU op with the 181's carry input set Low.
        // CALUwC -- When Carry Flag is Set: ALU op with the 181's carry input set High. Otherwise: NOP
        // CALUwoC -- When Carry Flag is Set: Conditional ALU op with the 181's carry input set Low. Otherwise: NOP
        // ALUxC -- ALU op with the 181's carry input set High when the CPU carry flag is High, and Low when the CPU carry flag is set Low as well.
        
        alu("ALUwC", carry: .active)
        alu("ALUwoC", carry: .inactive)
        
        // These conditional instructions will perform the computation when the
        // the Carry flag is set, regardless of the state of the A=B flag.
        // Otherwise, they will treated as a NOP.
        let carryFlagSet: UInt = 0b0101
        conditionalALU("CALUwC", condition: carryFlagSet, carry: .active)
        conditionalALU("CALUwoC", condition: carryFlagSet, carry: .inactive)
        
        carryPassThroughALU("ALUxC")
    }
    
    public func alu(_ base: String, carry: ControlSignal) {
        for destination in DestinationRegister.allCases {
            var controlWord = ControlWord()
            controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: .E)
            controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
            controlWord = controlWord.withFI(.active).withCarryIn(carry)
            let mnemonic = "\(base) \(String(describing: destination))"
            let opcode = getNextOpcode()
            record(mnemonic: mnemonic, opcode: opcode)
            microcode.store(opcode: opcode, controlWord: controlWord)
        }
        
        aluNoDest(base, carry)
    }
    
    // The case of an ALU operation with no destination register.
    // Only updates the flags.
    func aluNoDest(_ mnemonic: String, _ carry: ControlSignal) {
        let opcode = getNextOpcode()
        record(mnemonic: mnemonic, opcode: opcode)
        microcode.store(opcode: opcode, controlWord: ControlWord().withFI(.active).withCarryIn(carry))
    }
    
    func conditionalALU(_ base: String, condition: UInt, carry: ControlSignal) {
        for destination in DestinationRegister.allCases {
            conditionalALU(base, condition, destination, carry)
        }
        
        conditional(base, condition, ControlWord().withFI(.active).withCarryIn(carry))
    }
    
    func conditionalALU(_ base: String,
                        _ condition: UInt,
                        _ destination: MicrocodeGenerator.DestinationRegister,
                        _ carry: ControlSignal) {
        var controlWord = ControlWord()
        controlWord = controlWord.withFI(.active)
        controlWord = controlWord.withCarryIn(carry)
        controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: .E)
        controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
        let mnemonic = "\(base) \(String(describing: destination))"
        conditional(mnemonic, condition, controlWord)
    }
    
    func carryPassThroughALU(_ base: String) {
        let carryFlagSet: UInt = 0b0101
        for destination in DestinationRegister.allCases {
            carryPassThroughALU(base, carryFlagSet, destination)
        }
        carryPassThroughALU(base, carryFlagSet)
    }
    
    func carryPassThroughALU(_ base: String, _ condition: UInt, _ destination: MicrocodeGenerator.DestinationRegister) {
        var controlWord = ControlWord().withFI(.active).withCarryIn(.inactive)
        controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: .E)
        controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
        
        var controlWordElse = ControlWord().withFI(.active).withCarryIn(.active)
        controlWordElse = modifyControlWord(controlWord: controlWordElse, toOutputToBus: .E)
        controlWordElse = modifyControlWord(controlWord: controlWordElse, toInputFromBus: destination)
        
        conditional("\(base) \(String(describing: destination))",
                    condition, controlWord, controlWordElse)
    }
    
    func carryPassThroughALU(_ base: String, _ condition: UInt) {
        let controlWord = ControlWord().withFI(.active).withCarryIn(.inactive)
        let controlWordElse = ControlWord().withFI(.active).withCarryIn(.active)
        conditional(base, condition, controlWord, controlWordElse)
    }
    
    public func link() {
        let opcode = getNextOpcode()
        record(mnemonic: "LINK", opcode: opcode)
        let controlWord = ControlWord().withLinkIn(.active)
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func jalr() {
        let opcode = getNextOpcode()
        record(mnemonic: "JALR", opcode: opcode)
        let controlWord = ControlWord().withJ(.active).withLinkIn(.active)
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func jmp() {
        let opcode = getNextOpcode()
        record(mnemonic: "JMP", opcode: opcode)
        let controlWord = ControlWord().withJ(.active)
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func conditionalJump(mnemonic: String, condition: UInt) {
        let controlWord = ControlWord().withJ(.active)
        conditional(mnemonic, condition, controlWord)
    }
    
    func conditional(_ mnemonic: String,
                     _ condition: UInt,
                     _ controlWord: ControlWord,
                     _ controlWordElse: ControlWord = ControlWord()) {
        let opcode = getNextOpcode()
        record(mnemonic: mnemonic, opcode: opcode)
        microcode.store(opcode: opcode,
                        carryFlag: 0, equalFlag: 0,
                        controlWord: (condition & 0b1000) != 0 ? controlWord : controlWordElse)
        microcode.store(opcode: opcode,
                        carryFlag: 1, equalFlag: 0,
                        controlWord: (condition & 0b0100) != 0 ? controlWord : controlWordElse)
        microcode.store(opcode: opcode,
                        carryFlag: 0, equalFlag: 1,
                        controlWord: (condition & 0b0010) != 0 ? controlWord : controlWordElse)
        microcode.store(opcode: opcode,
                        carryFlag: 1, equalFlag: 1,
                        controlWord: (condition & 0b0001) != 0 ? controlWord : controlWordElse)
    }
    
    public func inuv() {
        let opcode = getNextOpcode()
        record(mnemonic: "INUV", opcode: opcode)
        let controlWord = ControlWord().withUVInc(.active)
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func inxy() {
        let opcode = getNextOpcode()
        record(mnemonic: "INXY", opcode: opcode)
        let controlWord = ControlWord().withXYInc(.active)
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func blt() {
        let sources = [SourceRegister.P, SourceRegister.M, SourceRegister.A]
        let destinations = [DestinationRegister.P, DestinationRegister.M]
        for source in sources {
            for destination in destinations {
                var controlWord = ControlWord().withUVInc(.active).withXYInc(.active)
                controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: source)
                controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
                let mnemonic = "BLT \(String(describing: destination)), \(String(describing: source))"
                let opcode = getNextOpcode()
                record(mnemonic: mnemonic, opcode: opcode)
                microcode.store(opcode: opcode, controlWord: controlWord)
            }
        }
    }
    
    func getNextOpcode() -> Int {
        assert(nextOpcode < 256)
        let opcode = nextOpcode
        nextOpcode += 1
        return opcode
    }
    
    public func getOpcode(mnemonic: String) -> Int? {
        return mapMnemonicToOpcode[mnemonic]
    }
    
    public func getMnemonic(opcode: Int) -> String? {
        return mapOpcodeToMnemonic[opcode]
    }
    
    public func isUnconditionalJump(_ instruction: Instruction) -> Bool {
        let opcode = instruction.opcode
        return opcode == getOpcode(mnemonic: "JMP")!
            || opcode == getOpcode(mnemonic: "JALR")!
    }
    
    public func isConditionalJump(_ instruction: Instruction) -> Bool {
        let opcode = instruction.opcode
        return opcode == getOpcode(mnemonic: "JC")!
            || opcode == getOpcode(mnemonic: "JNC")!
            || opcode == getOpcode(mnemonic: "JE")!
            || opcode == getOpcode(mnemonic: "JNE")!
            || opcode == getOpcode(mnemonic: "JG")!
            || opcode == getOpcode(mnemonic: "JLE")!
            || opcode == getOpcode(mnemonic: "JL")!
            || opcode == getOpcode(mnemonic: "JGE")!
    }
}
