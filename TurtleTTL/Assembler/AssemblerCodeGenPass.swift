//
//  AssemblerCodeGenPass.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Takes an AST and performs a pass that does final code generation.
public class AssemblerCodeGenPass: NSObject, AbstractSyntaxTreeNodeVisitor {
    let codeGenerator: CodeGenerator
    public var symbols: [String:Int] = [:]
    var patcherActions: [Patcher.Action] = []
    
    public var instructions: [Instruction] = []
    
    public private(set) var errors: [AssemblerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public required init(codeGenerator: CodeGenerator) {
        self.codeGenerator = codeGenerator
        super.init()
    }
    
    public func compile(_ root: AbstractSyntaxTreeNode) {
        do {
            try tryCompile(root)
        } catch let error as AssemblerError {
            errors.append(error)
        } catch {
            // This catch block should be unreachable because patch()
            // only throws AssemblerError. Regardless, we need it to satisfy
            // the compiler.
            errors.append(AssemblerError(format: "unrecoverable error: %@", error.localizedDescription))
        }
    }
    
    func tryCompile(_ root: AbstractSyntaxTreeNode) throws {
        instructions = []
        patcherActions = []
        codeGenerator.begin()
        try root.iterate {
            do {
                try $0.accept(visitor: self)
            } catch let error as AssemblerError {
                errors.append(error)
            }
        }
        codeGenerator.end()
        let patcher = Patcher(inputInstructions: codeGenerator.instructions,
                              symbols: symbols,
                              actions: patcherActions)
        instructions = try patcher.patch()
    }
    
    public func visit(node: InstructionNode) throws {
        let instructions = [
            "ADD"  : { try self.add(node) },
            "BLT"  : { try self.blt(node) },
            "CMP"  : { try self.cmp(node) },
            "HLT"  : { try self.hlt(node) },
            "INUV" : { try self.inuv(node) },
            "INXY" : { try self.inxy(node) },
            "JALR" : { try self.jalr(node) },
            "JC"   : { try self.jc(node) },
            "JMP"  : { try self.jmp(node) },
            "LI"   : { try self.li(node) },
            "LXY"  : { try self.lxy(node) },
            "MOV"  : { try self.mov(node) },
            "NOP"  : { try self.nop(node) }
        ]
        if let closure = instructions[node.instruction.lexeme] {
            try closure()
        } else {
            throw unrecognizedInstructionError(node.instruction)
        }
    }
    
    func add(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 1 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let register = node.parameters.parameters.first as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.codeGenerator.add(node.destination)
    }
    
    func blt(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 2 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let destination = node.parameters.parameters[0] as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        
        guard let source = node.parameters.parameters[1] as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        try expectRegisterCanBeUsedAsSource(source)
        
        try self.codeGenerator.blt(destination.literal, source.literal)
    }
    
    func cmp(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.cmp()
    }
    
    func hlt(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.hlt()
    }
    
    func inuv(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.inuv()
    }
    
    func inxy(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.inxy()
    }
    
    func jalr(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.jalr()
    }
    
    func jc(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.jc()
    }
    
    func jmp(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.jmp()
    }
    
    func li(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 2 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let destination = node.parameters.parameters[0] as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        
        guard let immediate = node.parameters.parameters[1] as? TokenNumber else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        try self.codeGenerator.li(node.destination, token: immediate)
    }
    
    func lxy(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 1 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        let parameter = node.parameters.parameters.first!
        
        if let identifier = parameter as? TokenIdentifier {
            try self.setAddress(token: identifier)
        } else if let address = parameter as? TokenNumber {
            try self.setAddress(address.literal)
        } else {
            throw operandTypeMismatchError(node.instruction)
        }
    }
    
    func mov(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 2 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let destination = node.parameters.parameters[0] as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        
        guard let source = node.parameters.parameters[1] as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        try expectRegisterCanBeUsedAsSource(source)
        
        try self.codeGenerator.mov(destination.literal, source.literal)
    }
    
    func nop(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.codeGenerator.nop()
    }
    
    func expectRegisterCanBeUsedAsDestination(_ register: TokenRegister) throws {
        if register.literal == .E || register.literal == .C {
            throw badDestinationError(register)
        }
    }
    
    func badDestinationError(_ register: TokenRegister) -> Error {
        return AssemblerError(line: register.lineNumber,
                              format: "register cannot be used as a destination: `%@'",
                              register.lexeme)
    }
    
    func expectRegisterCanBeUsedAsSource(_ register: TokenRegister) throws {
        if register.literal == .D {
            throw badSourceError(register)
        }
    }
    
    func badSourceError(_ register: TokenRegister) -> Error {
        return AssemblerError(line: register.lineNumber,
                              format: "register cannot be used as a source: `%@'",
                              register.lexeme)
    }
    
    func zeroOperandsExpectedError(_ instruction: Token) -> Error {
        return AssemblerError(line: instruction.lineNumber,
                              format: "instruction takes no operands: `%@'",
                              instruction.lexeme)
    }
    
    func operandTypeMismatchError(_ instruction: Token) -> Error {
        return AssemblerError(line: instruction.lineNumber,
                              format: "operand type mismatch: `%@'",
                              instruction.lexeme)
    }
    
    func unrecognizedInstructionError(_ instruction: Token) -> Error {
        return AssemblerError(line: instruction.lineNumber,
                              format: "no such instruction: `%@'",
                              instruction.lexeme)
    }
    
    public func visit(node: LabelDeclarationNode) throws {
        let name = node.identifier.lexeme
        if symbols[name] == nil {
            symbols[name] = codeGenerator.programCounter
        } else {
            throw AssemblerError(line: node.identifier.lineNumber, format: "duplicate label: `%@'", name)
        }
    }
    
    func setAddress(_ address: Int) throws {
        if(address < 0 || address > 0xffff) {
            throw AssemblerError(format: "invalid address: 0x%x", address)
        }
        try self.codeGenerator.li(.X, (address & 0xff00) >> 8)
        try self.codeGenerator.li(.Y, (address & 0xff))
    }
    
    func setAddress(token identifier: TokenIdentifier) throws {
        patcherActions.append((index: codeGenerator.programCounter,
                               symbol: identifier,
                               shift: 8))
        try codeGenerator.li(.X, 0xAB)
        
        patcherActions.append((index: codeGenerator.programCounter,
                               symbol: identifier,
                               shift: 0))
        try codeGenerator.li(.Y, 0xCD)
    }
}
