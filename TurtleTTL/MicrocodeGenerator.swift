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
    
    // Registers which can take in a value from the bus.
    public enum SourceRegister : CaseIterable {
        case A, B, C, X, Y, E, M
    }
    
    public func modifyControlWord(controlWord: ControlWord, toOutputToBus: SourceRegister) -> ControlWord {
        switch toOutputToBus {
        case .A:
            return controlWord.outputAToBus()
        case .B:
            return controlWord.outputBToBus()
        case .C:
            return controlWord.outputCToBus()
        case .X:
            return controlWord.outputXToBus()
        case .Y:
            return controlWord.outputYToBus()
        case .E:
            return controlWord.outputEToBus()
        case .M:
            return controlWord.outputMToBus()
        }
    }
    
    // Registers which can output a value to the bus.
    public enum DestinationRegister : CaseIterable {
        case A, B, D, X, Y, M
    }
    
    public func modifyControlWord(controlWord: ControlWord, toInputFromBus: DestinationRegister) -> ControlWord {
        switch toInputFromBus {
        case .A:
            return controlWord.inputAFromBus()
        case .B:
            return controlWord.inputBFromBus()
        case .D:
            return controlWord.inputDFromBus()
        case .X:
            return controlWord.inputXFromBus()
        case .Y:
            return controlWord.inputYFromBus()
        case .M:
            return controlWord.inputMFromBus()
        }
    }
    
    public func generate() {
        nop()
        hlt()
        mov()
        alu()
        jmp()
        jc()
    }
    
    public func nop() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["NOP"] = opcode
        microcode = microcode.withStore(opcode: opcode, controlWord: ControlWord())
    }
    
    public func hlt() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["HLT"] = opcode
        let controlWord = ControlWord().withHLT(false)
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
        for destination in DestinationRegister.allCases {
            var controlWord = ControlWord()
            controlWord = modifyControlWord(controlWord: controlWord, toOutputToBus: .E)
            controlWord = modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
            controlWord = controlWord.withFI(false)
            let mnemonic = String(format: "ALU %@", String(describing: destination))
            let opcode = getNextOpcode()
            mapMnemonicToOpcode[mnemonic] = opcode
            microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
        }
    }
    
    public func jmp() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["JMP"] = opcode
        let controlWord = ControlWord().withJ(false)
        microcode = microcode.withStore(opcode: opcode, controlWord: controlWord)
    }
    
    public func jc() {
        // JC performs a jump when the carry flag is set.
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["JC"] = opcode
        let controlWord = ControlWord().withJ(false)
        microcode = microcode.withStore(opcode: opcode, carryFlag: 0, equalFlag: 0, controlWord: controlWord)
        microcode = microcode.withStore(opcode: opcode, carryFlag: 1, equalFlag: 0, controlWord: ControlWord())
        microcode = microcode.withStore(opcode: opcode, carryFlag: 0, equalFlag: 1, controlWord: controlWord)
        microcode = microcode.withStore(opcode: opcode, carryFlag: 1, equalFlag: 1, controlWord: ControlWord())
    }
    
    func getNextOpcode() -> Int {
        let opcode = nextOpcode
        nextOpcode += 1
        return opcode
    }
    
    public func getOpcode(withMnemonic mnemonic: String) -> Int? {
        return mapMnemonicToOpcode[mnemonic]
    }
}
