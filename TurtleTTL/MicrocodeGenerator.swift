//
//  MicrocodeGenerator.swift
//  Simulator
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class MicrocodeGenerator: NSObject {
    public let microcode = InstructionDecoder()
    var mapMnemonicToOpcode = [String:Int]()
    var nextOpcode = 0
    
    // Registers which can take in a value from the bus.
    public enum SourceRegister : CaseIterable {
        case A, B, C, X, Y, E, M
    }
    
    public func modifyControlWord(controlWord: ControlWord, toOutputToBus: SourceRegister) {
        switch toOutputToBus {
        case .A:
            controlWord.outputAToBus()
        case .B:
            controlWord.outputBToBus()
        case .C:
            controlWord.outputCToBus()
        case .X:
            controlWord.outputXToBus()
        case .Y:
            controlWord.outputYToBus()
        case .E:
            controlWord.outputEToBus()
        case .M:
            controlWord.outputMToBus()
        }
    }
    
    // Registers which can output a value to the bus.
    public enum DestinationRegister : CaseIterable {
        case A, B, D, X, Y, M
    }
    
    public func modifyControlWord(controlWord: ControlWord, toInputFromBus: DestinationRegister) {
        switch toInputFromBus {
        case .A:
            controlWord.inputAFromBus()
        case .B:
            controlWord.inputBFromBus()
        case .D:
            controlWord.inputDFromBus()
        case .X:
            controlWord.inputXFromBus()
        case .Y:
            controlWord.inputYFromBus()
        case .M:
            controlWord.inputMFromBus()
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
        microcode.store(opcode: opcode, controlWord: ControlWord())
    }
    
    public func hlt() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["HLT"] = opcode
        let controlWord = ControlWord()
        controlWord.HLT = false
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func mov() {
        for source in SourceRegister.allCases {
            for destination in DestinationRegister.allCases {
                let controlWord = ControlWord()
                modifyControlWord(controlWord: controlWord, toOutputToBus: source)
                modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
                let mnemonic = String(format: "MOV %@, %@",
                                      String(describing: destination),
                                      String(describing: source))
                let opcode = getNextOpcode()
                mapMnemonicToOpcode[mnemonic] = opcode
                microcode.store(opcode: opcode, controlWord: controlWord)
            }
        }
    }
    
    public func alu() {
        for destination in DestinationRegister.allCases {
            let controlWord = ControlWord()
            modifyControlWord(controlWord: controlWord, toOutputToBus: .E)
            modifyControlWord(controlWord: controlWord, toInputFromBus: destination)
            controlWord.FI = false
            let mnemonic = String(format: "ALU %@", String(describing: destination))
            let opcode = getNextOpcode()
            mapMnemonicToOpcode[mnemonic] = opcode
            microcode.store(opcode: opcode, controlWord: controlWord)
        }
    }
    
    public func jmp() {
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["JMP"] = opcode
        let controlWord = ControlWord()
        controlWord.J = false
        microcode.store(opcode: opcode, controlWord: controlWord)
    }
    
    public func jc() {
        // JC performs a jump when the carry flag is set.
        let opcode = getNextOpcode()
        mapMnemonicToOpcode["JC"] = opcode
        let controlWord = ControlWord()
        controlWord.J = false
        microcode.store(opcode: opcode, carryFlag: 0, equalFlag: 0, controlWord: controlWord)
        microcode.store(opcode: opcode, carryFlag: 1, equalFlag: 0, controlWord: ControlWord())
        microcode.store(opcode: opcode, carryFlag: 0, equalFlag: 1, controlWord: controlWord)
        microcode.store(opcode: opcode, carryFlag: 1, equalFlag: 1, controlWord: ControlWord())
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
