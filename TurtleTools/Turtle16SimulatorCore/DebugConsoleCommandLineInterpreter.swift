//
//  DebugConsoleCommandLineInterpreter.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public class DebugConsoleCommandLineInterpreter: NSObject {
    public let computer: Turtle16Computer
    public var shouldQuit = false
    public var stdout: TextOutputStream = String()
    
    public init(_ computer: Turtle16Computer) {
        self.computer = computer
    }
    
    public func run(instructions: [DebugConsoleInstruction]) {
        for ins in instructions {
            runOne(instruction: ins)
        }
    }
    
    public func runOne(instruction: DebugConsoleInstruction) {
        switch instruction {
        case .help(let topic):
            printHelp(topic)
            
        case .quit:
            shouldQuit = true
            
        case .reset:
            computer.reset()
            
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
            writeMemory(base: base, words: words)
            
        case .readInstructions(let base, let count):
            printInstructionMemoryContents(base: base, count: count)
            
        case .writeInstructions(let base, let words):
            writeInstructionMemory(base: base, words: words)
        }
    }
    
    fileprivate func printHelp(_ topic: DebugConsoleHelpTopic?) {
        if let topic = topic {
            stdout.write(topic.longHelp)
        } else {
            stdout.write("Debugger commands:\n")
            let topics = DebugConsoleHelpTopic.allCases
            let maxLength = topics.map({ $0.name.count }).reduce(0, { max($0, $1) })
            for topic in topics {
                let left = topic.name + String(repeating: " ", count: maxLength - topic.name.count)
                stdout.write("\t\(left) -- \(topic.shortHelp)\n")
            }
            stdout.write("\nFor more information on any command, type `help <command-name>'.\n")
        }
    }
    
    fileprivate func run() {
        computer.run()
        stdout.write("cpu is halted\n")
    }
    
    fileprivate func step(count: Int) {
        for _ in 0..<count {
            if computer.isHalted {
                stdout.write("cpu is halted\n")
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
        stdout.write("""
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
        stdout.write("""
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
        stdout.write("\(baseStr): \(hexDump)\n")
    }
    
    fileprivate func printMemoryContents(base: UInt16, count: UInt) {
        printMemoryContents(array: computer.ram, base: base, count: count)
    }
    
    fileprivate func printInstructionMemoryContents(base: UInt16, count: UInt) {
        printMemoryContents(array: computer.instructions, base: base, count: count)
    }
    
    fileprivate func writeMemory(array: inout [UInt16], base: UInt16, words: [UInt16]) {
        for idx in 0..<words.count {
            array[Int(base) + idx] = words[idx]
        }
    }
    
    fileprivate func writeMemory(base: UInt16, words: [UInt16]) {
        writeMemory(array: &computer.ram, base: base, words: words)
    }
    
    fileprivate func writeInstructionMemory(base: UInt16, words: [UInt16]) {
        writeMemory(array: &computer.instructions, base: base, words: words)
    }
}