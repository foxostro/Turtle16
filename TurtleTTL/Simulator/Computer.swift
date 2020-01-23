//
//  Computer.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 1/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol Computer {
    var logger: Logger? { get set }
    var controlWord: ControlWord { get set }
    
    func step() -> Void
    func reset() -> Void
    
    func provideMicrocode(microcode: InstructionDecoder) -> Void
    func loadMicrocode(from: URL) throws
    func saveMicrocode(to: URL) throws
    
    func provideInstructions(_ instructions: [Instruction]) -> Void
    func loadProgram(from: URL) throws
    func saveProgram(to: URL) throws
    
    func provideSerialInput(bytes: [UInt8]) -> Void
    
    func modifyRegisterA(withString s: String) -> Void
    func modifyRegisterB(withString s: String) -> Void
    func modifyRegisterC(withString s: String) -> Void
    func modifyRegisterD(withString s: String) -> Void
    func modifyRegisterG(withString s: String) -> Void
    func modifyRegisterH(withString s: String) -> Void
    func modifyRegisterU(withString s: String) -> Void
    func modifyRegisterV(withString s: String) -> Void
    func modifyRegisterX(withString s: String) -> Void
    func modifyRegisterY(withString s: String) -> Void
    func modifyPC(withString s: String) -> Void
    func modifyPCIF(withString s: String) -> Void
    func modifyIFID(withString s: String) -> Void
    
    func describeRegisterA() -> String
    func describeRegisterB() -> String
    func describeRegisterC() -> String
    func describeRegisterD() -> String
    func describeRegisterG() -> String
    func describeRegisterH() -> String
    func describeRegisterU() -> String
    func describeRegisterV() -> String
    func describeRegisterX() -> String
    func describeRegisterY() -> String
    func describePC() -> String
    func describePCIF() -> String
    func describeIFID() -> String
    func describeBus() -> String
    func describeALUResult() -> String
    func describeControlWord() -> String
    func describeControlSignals() -> String
    func describeSerialOutput() -> String
}
