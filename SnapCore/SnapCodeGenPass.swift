//
//  SnapCodeGenPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

public class SnapCodeGenPass: NSObject {
    // Programs written in Snap store the stack pointer in data RAM at
    // addresses 0x0000 and 0x0001. This is initialized on launch to 0x0000.
    let kStackPointerAddressHi: UInt16 = 0x0000
    let kStackPointerAddressLo: UInt16 = 0x0001
    let kStackPointerInitialValue = 0x0000
    
    let codeGenerator: CodeGenerator
    public var symbols: [String:Int] = [:]
    var patcherActions: [Patcher.Action] = []
    
    public var instructions: [Instruction] = []
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public required init(codeGenerator: CodeGenerator) {
        self.codeGenerator = codeGenerator
        super.init()
    }
    
    public func compile(ast root: AbstractSyntaxTreeNode, base: Int) {
        do {
            try tryCompile(ast: root, base: base)
        } catch let error as CompilerError {
            errors.append(error)
        } catch {
            // This catch block should be unreachable because patch()
            // only throws CompilerError. Regardless, we need it to satisfy
            // the compiler.
            errors.append(CompilerError(format: "unrecoverable error: %@", error.localizedDescription))
        }
    }
    
    func tryCompile(ast root: AbstractSyntaxTreeNode, base: Int) throws {
        instructions = []
        patcherActions = []
        codeGenerator.begin()
        try insertProgramPrologue()
        try root.iterate {
            do {
                try visit(genericNode: $0)
            } catch let error as CompilerError {
                errors.append(error)
            }
        }
        codeGenerator.end()
        let patcher = Patcher(inputInstructions: codeGenerator.instructions,
                              symbols: symbols,
                              actions: patcherActions,
                              base: base)
        instructions = try patcher.patch()
    }
    
    // Inserts prologue code into the program, presumably at the beginning.
    // Insert a NOP at the beginning of every program because correct operation
    // of the hardware reset cycle requires this.
    // Likewise, correct operation of a program written in Snap requires some
    // inititalization to be performed before anything else occurs.
    func insertProgramPrologue() throws {
        codeGenerator.nop()
        try codeGenerator.li(.X, Int((kStackPointerAddressHi & 0xff00) >> 8))
        try codeGenerator.li(.Y, Int((kStackPointerAddressHi & 0x00ff)))
        try codeGenerator.li(.M, Int((kStackPointerInitialValue & 0xff00) >> 8))
        try codeGenerator.li(.X, Int((kStackPointerAddressLo & 0xff00) >> 8))
        try codeGenerator.li(.Y, Int((kStackPointerAddressLo & 0x00ff)))
        try codeGenerator.li(.M, Int((kStackPointerInitialValue & 0x00ff)))
    }
    
    func visit(genericNode: AbstractSyntaxTreeNode) throws {
        // While could use the visitor pattern here, (and indeed used to)
        // this leads to problems. There's a lot of boilerplate code, for one.
        // The visitor class must know of all subclasses ahead of time. It's
        // not really possible to have more than one visitor for the whole
        // class hierarchy. These issues make it difficult to use the same set
        // of AST nodes for two, separate parsers.
        if let node = genericNode as? InstructionNode {
            try visit(node: node)
        }
        if let node = genericNode as? LabelDeclarationNode {
            try visit(node: node)
        }
        if let node = genericNode as? ConstantDeclarationNode {
            try visit(node: node)
        }
        if let node = genericNode as? Return {
            try visit(node: node)
        }
    }
    
    func visit(node: InstructionNode) throws {
        let instructions = [
            "ADD"  : { try self.add(node) },
            "BLT"  : { try self.blt(node) },
            "CMP"  : { try self.cmp(node) },
            "HLT"  : { try self.hlt(node) },
            "INUV" : { try self.inuv(node) },
            "INXY" : { try self.inxy(node) },
            "LINK" : { try self.link(node) },
            "JALR" : { try self.jalr(node) },
            "JC"   : { try self.jc(node) },
            "JNC"  : { try self.jnc(node) },
            "JE"   : { try self.je(node) },
            "JNE"  : { try self.jne(node) },
            "JG"   : { try self.jg(node) },
            "JLE"  : { try self.jle(node) },
            "JL"   : { try self.jl(node) },
            "JGE"  : { try self.jge(node) },
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
        
        try codeGenerator.add(node.destination)
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
        
        try codeGenerator.blt(destination.literal, source.literal)
    }
    
    func cmp(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.cmp()
    }
    
    func hlt(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.hlt()
    }
    
    func inuv(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.inuv()
    }
    
    func inxy(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.inxy()
    }
    
    func link(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.link()
    }
    
    func jalr(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jalr()
    }
    
    func jc(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jc()
    }
    
    func jnc(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jnc()
    }
    
    func je(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.je()
    }
    
    func jne(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jne()
    }
    
    func jg(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jg()
    }
    
    func jle(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jle()
    }
    
    func jl(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jl()
    }
    
    func jge(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jge()
    }
    
    func jmp(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.jmp()
    }
    
    func li(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 2 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let destination = node.parameters.parameters[0] as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        
        if let immediate = node.parameters.parameters[1] as? TokenNumber {
            try codeGenerator.li(node.destination, token: immediate)
        } else if let identifier = node.parameters.parameters[1] as? TokenIdentifier {
            guard let value = symbols[identifier.lexeme] else {
                throw CompilerError(line: identifier.lineNumber,
                                     format: "use of undeclared identifier: `%@'",
                                     identifier.lexeme)
            }
            try codeGenerator.li(node.destination,
                                      token: TokenNumber(lineNumber: identifier.lineNumber,
                                                         lexeme: identifier.lexeme,
                                                         literal: value))
        } else {
            throw operandTypeMismatchError(node.instruction)
        }
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
        
        try codeGenerator.mov(destination.literal, source.literal)
    }
    
    func nop(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        codeGenerator.nop()
    }
    
    func expectRegisterCanBeUsedAsDestination(_ register: TokenRegister) throws {
        if register.literal == .E || register.literal == .C {
            throw badDestinationError(register)
        }
    }
    
    func badDestinationError(_ register: TokenRegister) -> Error {
        return CompilerError(line: register.lineNumber,
                              format: "register cannot be used as a destination: `%@'",
                              register.lexeme)
    }
    
    func expectRegisterCanBeUsedAsSource(_ register: TokenRegister) throws {
        if register.literal == .D {
            throw badSourceError(register)
        }
    }
    
    func badSourceError(_ register: TokenRegister) -> Error {
        return CompilerError(line: register.lineNumber,
                              format: "register cannot be used as a source: `%@'",
                              register.lexeme)
    }
    
    func zeroOperandsExpectedError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "instruction takes no operands: `%@'",
                              instruction.lexeme)
    }
    
    func operandTypeMismatchError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "operand type mismatch: `%@'",
                              instruction.lexeme)
    }
    
    func unrecognizedInstructionError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "no such instruction: `%@'",
                              instruction.lexeme)
    }
    
    func visit(node: LabelDeclarationNode) throws {
        let name = node.identifier.lexeme
        if symbols[name] == nil {
            symbols[name] = codeGenerator.programCounter
        } else {
            throw CompilerError(line: node.identifier.lineNumber,
                                 format: "label redefines existing symbol: `%@'",
                                 node.identifier.lexeme)
        }
    }
    
    func visit(node: ConstantDeclarationNode) throws {
        let name = node.identifier.lexeme
        if symbols[name] == nil {
            symbols[name] = node.number.literal
        } else {
            throw CompilerError(line: node.identifier.lineNumber,
                                 format: "constant redefines existing symbol: `%@'",
                                 node.identifier.lexeme)
        }
    }
    
    func visit(node: Return) throws {
        if let expression = node.expression {
            try visit(node: expression)
        }
    }
    
    func visit(node: Expression) throws {
        if let expression = node as? Expression.Literal {
            try self.codeGenerator.li(.A, token: expression.number)
        } else {
            throw CompilerError(line: node.token.lineNumber, message: "compiler only supports returning a literal value for now")
        }
    }
    
    func setAddress(_ address: Int) throws {
        if(address < 0 || address > 0xffff) {
            throw CompilerError(format: "invalid address: 0x%x", address)
        }
        try codeGenerator.li(.X, (address & 0xff00) >> 8)
        try codeGenerator.li(.Y, (address & 0xff))
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
