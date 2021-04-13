//
//  DebugConsoleCommandLineCompiler.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public class DebugConsoleCommandLineCompiler: NSObject {
    public var syntaxTree: TopLevel! = nil
    public var instructions: [DebugConsoleInstruction] = []
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public func compile(_ text: String) {
        instructions = []
        errors = []
        
        // Lexer pass
        let lexer = DebugConsoleCommandLineLexer(text)
        lexer.scanTokens()
        if lexer.hasError {
            errors = lexer.errors
            return
        }
        
        // Compile to an abstract syntax tree
        let parser = DebugConsoleCommandLineParser(tokens: lexer.tokens, lineMapper: lexer.lineMapper)
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        syntaxTree = parser.syntaxTree
        
        // Walk the tree and generate commands for nodes.
        for child in syntaxTree.children {
            if let node = child as? InstructionNode {
                switch node.instruction {
                case "h", "help":
                    acceptHelp(node)
                    
                case "q", "quit":
                    acceptQuit(node)
                    
                case "reset":
                    acceptReset(node)
                
                case "s", "step":
                    acceptStep(node)
                    
                case "r", "reg", "regs", "registers":
                    acceptReg(node)
                    
                case "x":
                    acceptReadMemory(node)
                    
                case "writemem":
                    acceptWriteMemory(node)
                    
                default:
                    errors.append(CompilerError(sourceAnchor: child.sourceAnchor, message: "unrecognized instruction: `\(node.instruction)'"))
                }
            } else {
                errors.append(CompilerError(sourceAnchor: child.sourceAnchor, message: "expected instruction"))
            }
        }
    }
    
    fileprivate func acceptHelp(_ node: InstructionNode) {
        guard node.parameters.elements.count > 0 else {
            errors.append(CompilerError(sourceAnchor: node.parameters.sourceAnchor, message: "help expects a topic"))
            return
        }
        
        guard let topic = node.parameters.elements[0] as? ParameterIdentifier else {
            errors.append(CompilerError(sourceAnchor: node.parameters.sourceAnchor, message: "help expects a topic"))
            return
        }
        
        switch topic.value {
        case "h", "help":
            instructions.append(.help(.help))
        
        case "q", "quit":
            abort() // instructions.append(.help(.quit))
            
        case "reset":
            abort() // instructions.append(.help(.reset))
        
        case "s", "step":
            abort() // instructions.append(.help(.step))
            
        case "r", "reg", "regs", "registers":
            abort() // instructions.append(.help(.reg))
            
        case "x":
            abort() // instructions.append(.help(.readMemory))
            
        default:
            errors.append(CompilerError(sourceAnchor: topic.sourceAnchor, message: "unrecognized help topic: `\(topic.value)'"))
        }
    }
    
    fileprivate func acceptQuit(_ node: InstructionNode) {
        if node.parameters.elements.count != 0 {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "instruction takes no parameters: `\(node.instruction)'"))
        } else {
            instructions.append(.quit)
        }
    }
    
    fileprivate func acceptReset(_ node: InstructionNode) {
        if node.parameters.elements.count != 0 {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "instruction takes no parameters: `\(node.instruction)'"))
        } else {
            instructions.append(.reset)
        }
    }
    
    fileprivate func acceptStep(_ node: InstructionNode) {
        if node.parameters.elements.count == 0 {
            instructions.append(.step(count: 1))
        } else if node.parameters.elements.count == 1 {
            if let parameter = node.parameters.elements.first as? ParameterNumber {
                instructions.append(.step(count: parameter.value))
            } else {
                errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "expected a number for the step count: `\(node.instruction)'"))
            }
        } else {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements[2].sourceAnchor, message: "instruction takes one optional parameter for the step count: `\(node.instruction)'"))
        }
    }
    
    fileprivate func acceptReg(_ node: InstructionNode) {
        if node.parameters.elements.count != 0 {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "instruction takes no parameters: `\(node.instruction)'"))
        } else {
            instructions.append(.reg)
        }
    }
    
    fileprivate func acceptReadMemory(_ node: InstructionNode) {
        if node.parameters.elements.count == 1 {
            if let base = node.parameters.elements.first as? ParameterNumber {
                instructions.append(.readMemory(base: UInt16(base.value), count: 1))
            } else {
                errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "expected a number for the memory address: `\(node.instruction)'"))
            }
        } else if node.parameters.elements.count == 2 {
            guard let length = (node.parameters.elements[0] as? ParameterSlashed)?.child as? ParameterNumber else {
                errors.append(CompilerError(sourceAnchor: node.parameters.elements[0].sourceAnchor, message: "expected a number for the length: `\(node.instruction)'"))
                return
            }
            guard let base = node.parameters.elements[1] as? ParameterNumber else {
                errors.append(CompilerError(sourceAnchor: node.parameters.elements[1].sourceAnchor, message: "expected a number for the memory address: `\(node.instruction)'"))
                    return
            }
            instructions.append(.readMemory(base: UInt16(base.value), count: UInt(length.value)))
        } else {
            errors.append(CompilerError(sourceAnchor: node.sourceAnchor, message: "expected at least one parameter for the memory address: `\(node.instruction)'"))
        }
    }
    
    fileprivate func acceptWriteMemory(_ node: InstructionNode) {
        guard node.parameters.elements.count >= 2 else {
            let sourceAnchor = (node.parameters.elements.first?.sourceAnchor) ?? node.sourceAnchor
            errors.append(CompilerError(sourceAnchor: sourceAnchor, message: "expected a memory address and data words: `\(node.instruction)'"))
            return
        }
        guard let base = node.parameters.elements[0] as? ParameterNumber else {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements[1].sourceAnchor, message: "expected a number for the memory address: `\(node.instruction)'"))
                return
        }
        var words: [UInt16] = []
        for el in node.parameters.elements[1...] {
            guard let word = el as? ParameterNumber else {
                errors.append(CompilerError(sourceAnchor: el.sourceAnchor, message: "expected a number for the data word: `\(node.instruction)'"))
                    return
            }
            guard word.value <= UInt16.max && word.value >= Int16.min else {
                errors.append(CompilerError(sourceAnchor: word.sourceAnchor, message: "not enough bits to represent the passed value: `\(node.instruction)'"))
                    return
            }
            let value: UInt16
            if word.value < 0 {
                value = UInt16(bitPattern: Int16(word.value))
            } else {
                value = UInt16(word.value)
            }
            words.append(value)
        }
        
        guard base.value <= UInt16.max && base.value >= Int16.min else {
            errors.append(CompilerError(sourceAnchor: base.sourceAnchor, message: "not enough bits to represent the passed value: `\(node.instruction)'"))
                return
        }
        let baseAddr: UInt16
        if base.value < 0 {
            baseAddr = UInt16(bitPattern: Int16(base.value))
        } else {
            baseAddr = UInt16(base.value)
        }
        
        instructions.append(.writeMemory(base: baseAddr, words: words))
    }
}
