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
                    
                case "c", "continue":
                    acceptContinue(node)
                
                case "s", "step":
                    acceptStep(node)
                    
                case "r", "reg", "regs", "registers":
                    acceptReg(node)
                    
                case "info":
                    acceptInfo(node)
                    
                case "x":
                    acceptReadMemory(node)
                    
                case "writemem":
                    acceptWriteMemory(node)
                    
                case "xi":
                    acceptReadInstructions(node)
                    
                case "writememi":
                    acceptWriteInstructions(node)
                    
                case "load":
                    acceptLoad(node)
                    
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
            instructions.append(.help(nil))
            return
        }
        
        guard let topic = node.parameters.elements[0] as? ParameterIdentifier else {
            instructions.append(.help(nil))
            return
        }
        
        switch topic.value {
        case "h", "help":
            instructions.append(.help(.help))
        
        case "q", "quit":
            instructions.append(.help(.quit))
            
        case "reset":
            instructions.append(.help(.reset))
        
        case "s", "step":
            instructions.append(.help(.step))
            
        case "r", "reg", "regs", "registers":
            instructions.append(.help(.reg))
        
        case "info":
            instructions.append(.help(.info))
            
        case "x":
            instructions.append(.help(.readMemory))
            
        case "writemem":
            instructions.append(.help(.writeMemory))
            
        case "xi":
            instructions.append(.help(.readInstructions))
            
        case "writememi":
            instructions.append(.help(.writeInstructions))
            
        default:
            instructions.append(.help(nil))
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
    
    fileprivate func acceptContinue(_ node: InstructionNode) {
        if node.parameters.elements.count != 0 {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "instruction takes no parameters: `\(node.instruction)'"))
        } else {
            instructions.append(.run)
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
    
    fileprivate func acceptInfo(_ node: InstructionNode) {
        if node.parameters.elements.count < 2 {
            let device = node.parameters.elements.first as? ParameterIdentifier
            instructions.append(.info(device?.value))
        } else {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements[1].sourceAnchor, message: "instruction takes zero or one parameters: `\(node.instruction)'"))
        }
    }
    
    fileprivate func acceptReadMemory(_ node: InstructionNode) {
        if let parameters = acceptReadMemoryParameters(node) {
            instructions.append(.readMemory(base: parameters.0, count: parameters.1))
        }
    }
    
    fileprivate func acceptWriteMemory(_ node: InstructionNode) {
        if let parameters = acceptWriteMemoryParameters(node) {
            instructions.append(.writeMemory(base: parameters.0, words: parameters.1))
        }
    }
    
    fileprivate func acceptReadInstructions(_ node: InstructionNode) {
        if let parameters = acceptReadMemoryParameters(node) {
            instructions.append(.readInstructions(base: parameters.0, count: parameters.1))
        }
    }
    
    fileprivate func acceptReadMemoryParameters(_ node: InstructionNode) -> (UInt16, UInt)? {
        if node.parameters.elements.count == 1 {
            if let base = node.parameters.elements.first as? ParameterNumber {
                return (UInt16(base.value), 1)
            } else {
                errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "expected a number for the memory address: `\(node.instruction)'"))
                return nil
            }
        } else if node.parameters.elements.count == 2 {
            guard let length = (node.parameters.elements[0] as? ParameterSlashed)?.child as? ParameterNumber else {
                errors.append(CompilerError(sourceAnchor: node.parameters.elements[0].sourceAnchor, message: "expected a number for the length: `\(node.instruction)'"))
                return nil
            }
            guard let base = node.parameters.elements[1] as? ParameterNumber else {
                errors.append(CompilerError(sourceAnchor: node.parameters.elements[1].sourceAnchor, message: "expected a number for the memory address: `\(node.instruction)'"))
                    return nil
            }
            
            guard let baseAddr = validateParameterUInt16(node, base) else {
                return nil
            }
            
            return (baseAddr, UInt(length.value))
        } else {
            errors.append(CompilerError(sourceAnchor: node.sourceAnchor, message: "expected at least one parameter for the memory address: `\(node.instruction)'"))
            return nil
        }
    }
    
    fileprivate func validateParameterUInt16(_ node: InstructionNode, _ param: ParameterNumber) -> UInt16? {
        guard param.value <= UInt16.max && param.value >= Int16.min else {
            errors.append(CompilerError(sourceAnchor: param.sourceAnchor, message: "not enough bits to represent the passed value: `\(node.instruction)'"))
                return nil
        }
        let baseAddr: UInt16
        if param.value < 0 {
            baseAddr = UInt16(bitPattern: Int16(param.value))
        } else {
            baseAddr = UInt16(param.value)
        }
        return baseAddr
    }
    
    fileprivate func acceptWriteInstructions(_ node: InstructionNode) {
        if let parameters = acceptWriteMemoryParameters(node) {
            instructions.append(.writeInstructions(base: parameters.0, words: parameters.1))
        }
    }
    
    fileprivate func acceptWriteMemoryParameters(_ node: InstructionNode) -> (UInt16, [UInt16])? {
        guard node.parameters.elements.count >= 2 else {
            let sourceAnchor = (node.parameters.elements.first?.sourceAnchor) ?? node.sourceAnchor
            errors.append(CompilerError(sourceAnchor: sourceAnchor, message: "expected a memory address and data words: `\(node.instruction)'"))
            return nil
        }
        guard let base = node.parameters.elements[0] as? ParameterNumber else {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements[0].sourceAnchor, message: "expected a number for the memory address: `\(node.instruction)'"))
                return nil
        }
        var words: [UInt16] = []
        for el in node.parameters.elements[1...] {
            guard let word = el as? ParameterNumber else {
                errors.append(CompilerError(sourceAnchor: el.sourceAnchor, message: "expected a number for the data word: `\(node.instruction)'"))
                    return nil
            }
            guard let value = validateParameterUInt16(node, word) else {
                return nil
            }
            words.append(value)
        }
        
        guard let baseAddr = validateParameterUInt16(node, base) else {
            return nil
        }
        
        return (baseAddr, words)
    }
    
    fileprivate func acceptLoad(_ node: InstructionNode) {
        guard node.parameters.elements.count != 0 else {
            errors.append(CompilerError(sourceAnchor: node.sourceAnchor, message: "expected one parameter for the file path: `\(node.instruction)'"))
            return
        }
        guard node.parameters.elements.count == 1 else {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements[1].sourceAnchor, message: "expected one parameter for the file path: `\(node.instruction)'"))
            return
        }
        guard let parameter = node.parameters.elements.first as? ParameterString else {
            errors.append(CompilerError(sourceAnchor: node.parameters.elements.first?.sourceAnchor, message: "expected a string for the file path: `\(node.instruction)'"))
            return
        }
        let url = URL(fileURLWithPath: parameter.value)
        instructions.append(.load(url))
    }
}
