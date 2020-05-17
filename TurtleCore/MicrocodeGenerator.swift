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
        case A, B, D, M, P, U, V, X, Y
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
                let mnemonic = String(format: "MOV %@, %@",
                                      String(describing: destination),
                                      String(describing: source))
                let opcode = getNextOpcode()
                record(mnemonic: mnemonic, opcode: opcode)
                microcode.store(opcode: opcode, controlWord: controlWord)
            }
        }
    }
    
    public func alu() {
        alu(base: "ALUC", withCarry: .active)
        alu(base: "ALU", withCarry: .inactive)
    }
    
    public func alu(base: String, withCarry carry: ControlSignal) {
        for destination in DestinationRegister.allCases {
            var controlWord = ControlWord()
            controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: .E)
            controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
            controlWord = controlWord.withFI(.active).withCarryIn(carry)
            let mnemonic = String(format: "%@ %@", base, String(describing: destination))
            let opcode = getNextOpcode()
            record(mnemonic: mnemonic, opcode: opcode)
            microcode.store(opcode: opcode, controlWord: controlWord)
        }
        
        aluNoDest(mnemonic: base, withCarry: carry)
    }
    
    // The case of an ALU operation with no destination register.
    // Only updates the flags.
    func aluNoDest(mnemonic: String, withCarry carry: ControlSignal) {
        let opcode = getNextOpcode()
        record(mnemonic: mnemonic, opcode: opcode)
        microcode.store(opcode: opcode, controlWord: ControlWord().withFI(.active).withCarryIn(carry))
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
        let opcode = getNextOpcode()
        record(mnemonic: mnemonic, opcode: opcode)
        let controlWord = ControlWord().withJ(.active)
        microcode.store(opcode: opcode,
                        carryFlag: 0, equalFlag: 0,
                        controlWord: (condition & 0b1000) != 0 ? controlWord : ControlWord())
        microcode.store(opcode: opcode,
                        carryFlag: 1, equalFlag: 0,
                        controlWord: (condition & 0b0100) != 0 ? controlWord : ControlWord())
        microcode.store(opcode: opcode,
                        carryFlag: 0, equalFlag: 1,
                        controlWord: (condition & 0b0010) != 0 ? controlWord : ControlWord())
        microcode.store(opcode: opcode,
                        carryFlag: 1, equalFlag: 1,
                        controlWord: (condition & 0b0001) != 0 ? controlWord : ControlWord())
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
        for source in SourceRegister.allCases {
            for destination in DestinationRegister.allCases {
                var controlWord = ControlWord().withUVInc(.active).withXYInc(.active)
                controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: source)
                controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
                let mnemonic = String(format: "BLT %@, %@",
                                      String(describing: destination),
                                      String(describing: source))
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
    
    public func getOpcode(withMnemonic mnemonic: String) -> Int? {
        return mapMnemonicToOpcode[mnemonic]
    }
    
    public func getMnemonic(withOpcode opcode: Int) -> String? {
        return mapOpcodeToMnemonic[opcode]
    }
    
    public func isUnconditionalJump(_ instruction: Instruction) -> Bool {
        let opcode = instruction.opcode
        return opcode == getOpcode(withMnemonic: "JMP")!
            || opcode == getOpcode(withMnemonic: "JALR")!
    }
    
    public func isConditionalJump(_ instruction: Instruction) -> Bool {
        let opcode = instruction.opcode
        return opcode == getOpcode(withMnemonic: "JC")!
            || opcode == getOpcode(withMnemonic: "JNC")!
            || opcode == getOpcode(withMnemonic: "JE")!
            || opcode == getOpcode(withMnemonic: "JNE")!
            || opcode == getOpcode(withMnemonic: "JG")!
            || opcode == getOpcode(withMnemonic: "JLE")!
            || opcode == getOpcode(withMnemonic: "JL")!
            || opcode == getOpcode(withMnemonic: "JGE")!
    }
}
