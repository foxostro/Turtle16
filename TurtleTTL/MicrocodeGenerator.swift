//
//  MicrocodeGenerator.swift
//  Simulator
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Generates microcode for use in the ID stage of TurtleTTL hardware.
public class MicrocodeGenerator: NSObject {
    public var microcode = InstructionDecoder()
    var mapMnemonicToOpcode = [String:Int]()
    var nextOpcode = 0
    
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
        jc()
        jalr()
        inuv()
        inxy()
        blt()
    }
    
    public func nop() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["NOP"] = opcode
        microcode = microcode.withStore(opcode: opcode, controlWord: ControlWord())
    }
    
    public func hlt() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["HLT"] = opcode
        let controlWord = ControlWord().withHLT(.active)
        microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
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
                mapMnemonicToOpcode[mnemonic] = opcode
                microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
            }
        }
    }
    
    public func alu() {
        alu(base: "ALUC", withCarry: .active)
        alu(base: "ALU", withCarry: .inactive)
    }
    
    public func alu(base: String, withCarry carry: ControlWord.ControlSignal) {
        for destination in DestinationRegister.allCases {
            var controlWord = ControlWord()
            controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: .E)
            controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
            controlWord = controlWord.withFI(.active).withCarryIn(carry)
            let mnemonic = String(format: "%@ %@", base, String(describing: destination))
            let opcode = getNextOpcode()
            mapMnemonicToOpcode[mnemonic] = opcode
            microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
        }
        
        aluNoDest(mnemonic: base, withCarry: carry)
    }
    
    // The case of an ALU operation with no destination register.
    // Only updates the flags.
    func aluNoDest(mnemonic: String, withCarry carry: ControlWord.ControlSignal) {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode[mnemonic] = opcode
        microcode = microcode.withStore(opcode: opcode,
                                        controlWord: ControlWord()
                                            .withFI(.active)
                                            .withCarryIn(carry))
    }
    
    public func jalr() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["JALR"] = opcode
        let controlWord = ControlWord().withJ(.active).withLinkIn(.active)
        microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
    }
    
    public func jmp() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["JMP"] = opcode
        let controlWord = ControlWord().withJ(.active)
        microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
    }
    
    public func jc() {
        // JC performs a jump when the carry flag is set.
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["JC"] = opcode
        let controlWord = ControlWord().withJ(.active)
        microcode = microcode.withStore(opcode: opcode, carryFlag: 0, equalFlag: 0, controlWord: controlWord) // A Greater Than B
        microcode = microcode.withStore(opcode: opcode, carryFlag: 1, equalFlag: 0, controlWord: ControlWord()) // A Less Than B
        microcode = microcode.withStore(opcode: opcode, carryFlag: 0, equalFlag: 1, controlWord: controlWord) // ?
        microcode = microcode.withStore(opcode: opcode, carryFlag: 1, equalFlag: 1, controlWord: ControlWord()) // A Equal B
    }
    
    public func inuv() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["INUV"] = opcode
        let controlWord = ControlWord().withUVInc(.active)
        microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
    }
    
    public func inxy() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["INXY"] = opcode
        let controlWord = ControlWord().withXYInc(.active)
        microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
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
                mapMnemonicToOpcode[mnemonic] = opcode
                microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
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
}
