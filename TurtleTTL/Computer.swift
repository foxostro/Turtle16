//
//  Computer.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Computer: NSObject {
    public let registerA = Register()
    public let registerB = Register()
    public let registerC = Register()
    public let registerD = Register()
    public let registerX = Register()
    public let registerY = Register()
    public let flags = Flags()
    public let dataRAM = RAM()
    public let programCounter = ProgramCounter()
    public let alu = ALU()
    public let instructionROM = InstructionROM()
    public let instructionDecoder = InstructionDecoder()
    public let controlWordRegister = ControlWord()
    public let pipelineStageFetch:PipelineStageFetch
    public let pipelineStageDecode:PipelineStageDecode
    public let pipelineStageExecute:PipelineStageExecute
    public var logger:Logger? {
        didSet {
            pipelineStageFetch.logger = logger
            pipelineStageDecode.logger = logger
            pipelineStageExecute.logger = logger
        }
    }
    let lowerDecoderRomFilename = "Lower Decoder ROM.bin"
    let upperDecoderRomFilename = "Upper Decoder ROM.bin"
    let lowerInstructionROMFilename = "Lower Instruction ROM.bin"
    let upperInstructionROMFilename = "Upper Instruction ROM.bin"
    
    public override init() {
        pipelineStageFetch = PipelineStageFetch(withProgramCounter: programCounter,
                                                withInstructionROM: instructionROM)
        pipelineStageDecode = PipelineStageDecode(withDecoder: instructionDecoder,
                                                  flags: flags)
        pipelineStageExecute = PipelineStageExecute(controlWordRegister: controlWordRegister,
                                                    registerA: registerA,
                                                    registerB: registerB,
                                                    registerC: registerC,
                                                    registerD: registerD,
                                                    registerX: registerX,
                                                    registerY: registerY,
                                                    flags: flags,
                                                    dataRAM: dataRAM,
                                                    programCounter: programCounter,
                                                    alu: alu)
    }
    
    public func reset() {
        pipelineStageFetch.isResetting = true
        pipelineStageDecode.isResetting = true
        pipelineStageExecute.isResetting = true
        for _ in 1...3 {
            programCounter.contents = 0
            haltlessStep()
        }
        programCounter.contents = 0
        pipelineStageFetch.isResetting = false
        pipelineStageDecode.isResetting = false
        pipelineStageExecute.isResetting = false
    }
    
    public func step() {
        if (true == controlWordRegister.HLT) {
            haltlessStep()
        }
    }
    
    func haltlessStep() {
        let instruction = pipelineStageFetch.fetch()
        let controlTuple = pipelineStageDecode.decode(withInstruction: instruction)
        pipelineStageExecute.execute(withControlTuple: controlTuple)
    }
    
    public func execute() {
        reset()
        while (true == controlWordRegister.HLT) {
            haltlessStep()
        }
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        instructionROM.store(instructions)
    }
    
    public var busStringValue:String {
        return String(pipelineStageExecute.bus, radix: 16)
    }
    
    public func saveMicrocode(to: URL) throws {
        // Use minipro on the command-line to flash the binary file to EEPROM:
        //   % minipro -p SST29EE010 -y -w ./file.bin
        let lowerDecoderROM = instructionDecoder.lowerROM.data
        let upperDecoderROM = instructionDecoder.upperROM.data
        
        try FileManager.default.createDirectory(at: to,
                                                withIntermediateDirectories: false,
                                                attributes: [:])
        try lowerDecoderROM.write(to: to.appendingPathComponent(lowerDecoderRomFilename))
        try upperDecoderROM.write(to: to.appendingPathComponent(upperDecoderRomFilename))
    }
    
    public func loadMicrocode(from: URL) throws {
        try instructionDecoder.lowerROM.data = Data(contentsOf: from.appendingPathComponent(lowerDecoderRomFilename) as URL)
        try instructionDecoder.upperROM.data = Data(contentsOf: from.appendingPathComponent(upperDecoderRomFilename) as URL)
    }
    
    public func saveProgram(to: URL) throws {
        // Use minipro on the command-line to flash the binary file to EEPROM:
        //   % minipro -p SST29EE010 -y -w ./file.bin
        let lowerInstructionROM = instructionROM.lowerROM.data
        let upperInstructionROM = instructionROM.upperROM.data
        
        try FileManager.default.createDirectory(at: to,
                                                withIntermediateDirectories: false,
                                                attributes: [:])
        try lowerInstructionROM.write(to: to.appendingPathComponent(lowerInstructionROMFilename))
        try upperInstructionROM.write(to: to.appendingPathComponent(upperInstructionROMFilename))
    }
    
    public func loadProgram(from: URL) throws {
        try instructionROM.lowerROM.data = Data(contentsOf: from.appendingPathComponent(lowerInstructionROMFilename) as URL)
        try instructionROM.upperROM.data = Data(contentsOf: from.appendingPathComponent(upperInstructionROMFilename) as URL)
    }
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        instructionDecoder.lowerROM.data = microcode.lowerROM.data
        instructionDecoder.upperROM.data = microcode.upperROM.data
    }
}
