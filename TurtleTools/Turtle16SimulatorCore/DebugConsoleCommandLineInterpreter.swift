//
//  DebugConsoleCommandLineInterpreter.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class DebugConsoleCommandLineInterpreter: NSObject {
    public let computer: Turtle16Computer
    public var shouldQuit = false
    public var logger: Logger = StringLogger()
    public var sandboxAccessManager: SandboxAccessManager? = nil
    
    public init(_ computer: Turtle16Computer) {
        self.computer = computer
    }
    
    public func run(instructions: [DebugConsoleInstruction]) {
        for ins in instructions {
            internalRunOne(instruction: ins)
        }
        NotificationCenter.default.post(name: .virtualMachineStateDidChange, object: self.computer)
    }
    
    public func runOne(instruction: DebugConsoleInstruction) {
        internalRunOne(instruction: instruction)
        NotificationCenter.default.post(name: .virtualMachineStateDidChange, object: self.computer)
    }
    
    public func internalRunOne(instruction: DebugConsoleInstruction) {
        switch instruction {
        case .help(let topic):
            printHelp(topic)
            
        case .quit:
            shouldQuit = true
            
        case .reset(let type):
            computer.reset(type)
            
        case .run:
            computer.run()
            
        case .step(let count):
            step(count: count)
            
        case .reg:
            printRegisters()
            
        case .info(let device):
            printInfo(device: device)
            
        case .readMemory(let base, let count):
            printMemoryContents(base: base, count: count)
            
        case .writeMemory(let base, let words):
            writeDataMemory(base: base, words: words)
            
        case .readInstructions(let base, let count):
            printInstructionMemoryContents(base: base, count: count)
            
        case .writeInstructions(let base, let words):
            writeInstructionMemory(base: base, words: words)
            
        case .load(let what, let url):
            load(what, url)
            
        case .save(let what, let url):
            save(what, url)
        
        case .disassemble(let target):
            disassemble(target)
        }
    }
    
    fileprivate func printHelp(_ topic: DebugConsoleHelpTopic?) {
        if let topic = topic {
            logger.append(topic.longHelp)
        } else {
            logger.append("Debugger commands:\n")
            let topics = DebugConsoleHelpTopic.allCases
            let maxLength = topics.map({ $0.name.count }).reduce(0, { max($0, $1) })
            for topic in topics {
                let left = topic.name + String(repeating: " ", count: maxLength - topic.name.count)
                logger.append("\t\(left) -- \(topic.shortHelp)\n")
            }
            logger.append("\nFor more information on any command, type `help <command-name>'.\n")
        }
    }
    
    fileprivate func run() {
        computer.run()
        logger.append("cpu is halted\n")
    }
    
    fileprivate func step(count: Int) {
        for _ in 0..<count {
            if computer.isHalted {
                logger.append("cpu is halted\n")
                return
            } else {
                computer.step()
            }
        }
    }
    
    fileprivate func printRegisters() {
        let r0 = String(format: "0x%04x", computer.getRegister(0))
        let r1 = String(format: "0x%04x", computer.getRegister(1))
        let r2 = String(format: "0x%04x", computer.getRegister(2))
        let r3 = String(format: "0x%04x", computer.getRegister(3))
        let r4 = String(format: "0x%04x", computer.getRegister(4))
        let r5 = String(format: "0x%04x", computer.getRegister(5))
        let r6 = String(format: "0x%04x", computer.getRegister(6))
        let r7 = String(format: "0x%04x", computer.getRegister(7))
        let pc = String(format: "0x%04x", computer.pc)
        logger.append("""
r0: \(r0)\tr4: \(r4)
r1: \(r1)\tr5: \(r5)
r2: \(r2)\tr6: \(r6)
r3: \(r3)\tr7: \(r7)
pc: \(pc)

""")
    }
    
    fileprivate func printInfo(device: String?) {
        guard let device = device else {
            printHelp(.info)
            return
        }
        guard device == "cpu" else {
            printHelp(.info)
            return
        }
        logger.append("""
isStalling: \(computer.isStalling)
isHalted: \(computer.isHalted)
isResetting: \(computer.isResetting)


""")
        printRegisters()
    }
    
    fileprivate func printMemoryContents(array: [UInt16], base: UInt16, count: UInt) {
        let baseStr = String(format: "0x%04x", base)
        let hexDump = (0..<count).map({idx in
            String(format: "0x%04x", Int(array[Int(base) + Int(idx)]))
        }).joined(separator: " ")
        logger.append("\(baseStr): \(hexDump)\n")
    }
    
    fileprivate func printMemoryContents(base: UInt16, count: UInt) {
        printMemoryContents(array: computer.ram, base: base, count: count)
    }
    
    fileprivate func printInstructionMemoryContents(base: UInt16, count: UInt) {
        printMemoryContents(array: computer.instructions, base: base, count: count)
    }
    
    fileprivate func writeMemory(array: inout [UInt16], base: UInt16, words: [UInt16]) {
        for idx in 0..<min(words.count, Int(UInt16.max)+1) {
            array[Int(base) + idx] = words[idx]
        }
    }
    
    fileprivate func writeDataMemory(base: UInt16, words: [UInt16]) {
        writeMemory(array: &computer.ram, base: base, words: words)
    }
    
    fileprivate func writeInstructionMemory(base: UInt16, words: [UInt16]) {
        writeMemory(array: &computer.instructions, base: base, words: words)
    }
    
    fileprivate func loadDataFile(_ url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        }
        catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoPermissionError {
                sandboxAccessManager?.requestAccess(url: url)
                if let data: Data = try? Data(contentsOf: url) {
                    return data
                }
            } else {
                logger.append("failed to load file: `\(url.relativePath)'\n")
                logger.append((error.localizedFailureReason ?? "") + "\n")
            }
            
            return nil
        }
    }
    
    fileprivate func load(_ what: String, _ url: URL) {
        let validDestinations: Set<String> = ["program", "program_hi", "program_lo", "data", "OpcodeDecodeROM1", "OpcodeDecodeROM2", "OpcodeDecodeROM3"]
        guard validDestinations.contains(what) else {
            printHelp(.load)
            return
        }
        guard let data: Data = loadDataFile(url) else {
            return
        }
        switch what {
        case "program":
            let words = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [UInt16] in
                let buffer = pointer.bindMemory(to: UInt16.self)
                return buffer.map { UInt16(bigEndian: $0) }
            }
            computer.instructions = Array<UInt16>(repeating: 0, count: Int(UInt16.max)+1)
            writeInstructionMemory(base: 0, words: words)
            logger.append("Wrote \(words.count) words to instruction memory.\n")
            
        case "program_hi":
            let count = min(data.count, computer.instructions.count)
            for i in 0..<count {
                let hi = UInt16(data[i])
                computer.instructions[i] = (computer.instructions[i] & 0x00ff) | (hi << 8)
            }
            logger.append("Modified the high bytes of \(count) words of instruction memory.\n")
            
        case "program_lo":
            let count = min(data.count, computer.instructions.count)
            for i in 0..<count {
                let lo = UInt16(data[i])
                computer.instructions[i] = (computer.instructions[i] & 0xff00) | lo
            }
            logger.append("Modified the low bytes of \(count) words of instruction memory.\n")
            
        case "data":
            let words = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [UInt16] in
                let buffer = pointer.bindMemory(to: UInt16.self)
                return buffer.map { UInt16(bigEndian: $0) }
            }
            computer.ram = Array<UInt16>(repeating: 0, count: Int(UInt16.max)+1)
            writeDataMemory(base: 0, words: words)
            logger.append("Wrote \(words.count) words to data memory.\n")
            
        case "OpcodeDecodeROM1":
            let words = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [UInt8] in
                let buffer = pointer.bindMemory(to: UInt8.self)
                return buffer.map { UInt8(bigEndian: $0) }
            }
            for i in 0..<kDecoderTableSize {
                if i >= words.count {
                    computer.opcodeDecodeROM[i] = 0
                } else {
                    computer.opcodeDecodeROM[i] = (computer.opcodeDecodeROM[i] & ~0x0000ff) | UInt(words[i])
                }
            }
            logger.append("Wrote \(kDecoderTableSize) words to opcode decode ROM 1.\n")
            
        case "OpcodeDecodeROM2":
            let words = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [UInt8] in
                let buffer = pointer.bindMemory(to: UInt8.self)
                return buffer.map { UInt8(bigEndian: $0) }
            }
            for i in 0..<kDecoderTableSize {
                if i >= words.count {
                    computer.opcodeDecodeROM[i] = 0
                } else {
                    computer.opcodeDecodeROM[i] = (computer.opcodeDecodeROM[i] & ~0x00ff00) | (UInt(words[i])<<8)
                }
            }
            logger.append("Wrote \(kDecoderTableSize) words to opcode decode ROM 2.\n")
            
        case "OpcodeDecodeROM3":
            let words = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [UInt8] in
                let buffer = pointer.bindMemory(to: UInt8.self)
                return buffer.map { UInt8(bigEndian: $0) }
            }
            for i in 0..<kDecoderTableSize {
                if i >= words.count {
                    computer.opcodeDecodeROM[i] = 0
                } else {
                    computer.opcodeDecodeROM[i] = (computer.opcodeDecodeROM[i] & ~0xff0000) | (UInt(words[i])<<16)
                }
            }
            logger.append("Wrote \(kDecoderTableSize) words to opcode decode ROM 3.\n")
        
        default:
            abort()
        }
    }
    
    let kEEPROMSize = 1<<17
    let kDecoderTableSize = 512
    
    fileprivate func save(_ what: String, _ url: URL) {
        var data: Data
        switch what {
        case "program":
            data = Data(count: kEEPROMSize)
            for i in 0..<computer.instructions.count {
                let word = computer.instructions[i]
                data[i*2+0] = UInt8((word & 0xff00) >> 8)
                data[i*2+1] = UInt8( word & 0x00ff      )
            }
            logger.append("Wrote contents of instruction memory to file: \"\(url.path)\"\n")
            
        case "program_hi":
            data = Data(count: kEEPROMSize)
            for i in 0..<computer.instructions.count {
                let word = computer.instructions[i]
                data[i] = UInt8((word & 0xff00) >> 8)
            }
            logger.append("Wrote upper bytes of instruction memory to file: \"\(url.path)\"\n")
            
        case "program_lo":
            data = Data(count: kEEPROMSize)
            for i in 0..<computer.instructions.count {
                let word = computer.instructions[i]
                data[i] = UInt8(word & 0x00ff)
            }
            logger.append("Wrote lower bytes of instruction memory to file: \"\(url.path)\"\n")
            
        case "data":
            data = Data(capacity: computer.ram.count / MemoryLayout<UInt16>.size)
            for word in computer.ram {
                data.append(UInt8((word & 0xff00) >> 8))
                data.append(UInt8( word & 0x00ff      ))
            }
            logger.append("Wrote contents of data memory to file: \"\(url.path)\"\n")
            
        case "OpcodeDecodeROM1":
            data = Data(count: kEEPROMSize)
            for i in 0..<kDecoderTableSize {
                let word = computer.opcodeDecodeROM[i] & 0x0000ff
                data[i] = UInt8(word)
            }
            logger.append("Wrote contents of opcode decode ROM 1 to file: \"\(url.path)\"\n")
            
        case "OpcodeDecodeROM2":
            data = Data(count: kEEPROMSize)
            for i in 0..<kDecoderTableSize {
                let word = (computer.opcodeDecodeROM[i] & 0x00ff00) >> 8
                data[i] = UInt8(word)
            }
            logger.append("Wrote contents of opcode decode ROM 2 to file: \"\(url.path)\"\n")
            
        case "OpcodeDecodeROM3":
            data = Data(count: kEEPROMSize)
            for i in 0..<kDecoderTableSize {
                let word = (computer.opcodeDecodeROM[i] & 0xff0000) >> 16
                data[i] = UInt8(word)
            }
            logger.append("Wrote contents of opcode decode ROM 3 to file: \"\(url.path)\"\n")
        
        default:
            fatalError("unknown source `\(what)'")
        }
        try! data.write(to: url)
    }
    
    fileprivate func disassemble(_ target: DebugConsoleInstruction.DisassembleMode) {
        let kDefaultCount: UInt = 16
        switch target {
        case .unspecified:
            disassemble(base: computer.pc, count: kDefaultCount)
            break
            
        case .base(let base):
            disassemble(base: base, count: kDefaultCount)
            break
            
        case .baseCount(let base, let count):
            disassemble(base: base, count: count)
            break
            
        case .identifier(let identifier):
            disassemble(identifier: identifier, count: kDefaultCount)
            break
            
        case .identifierCount(let identifier, let count):
            disassemble(identifier: identifier, count: count)
            break
        }
    }
    
    fileprivate func disassemble(base: UInt16, count: UInt) {
        let disassembler = Disassembler()
        let disassembly = disassembler.disassemble(computer.instructions)
        var remaining = count
        for entry in disassembly {
            if entry.address >= base {
                let strAddress = String(format: "%04x", entry.address)
                let strWord = String(format: "%04x", entry.word)
                let strLabel: String
                if let label = entry.label {
                    strLabel = label + ": "
                } else {
                    strLabel = ""
                }
                let strMnemonic = entry.mnemonic ?? ""
                logger.append("\(strAddress)\t\(strWord)\t\(strLabel)\(strMnemonic)\n")
                remaining = remaining - 1
                if remaining == 0 {
                    break
                }
            }
        }
    }
    
    fileprivate func disassemble(identifier: String, count: UInt) {
        let disassembler = Disassembler()
        let _ = disassembler.disassemble(computer.instructions)
        if let base = disassembler.labels.first(where: { $1 == identifier })?.key {
            disassemble(base: UInt16(base), count: count)
        }
        else {
            logger.append("Use of unresolved identifier: `\(identifier)'\n")
        }
    }
}
