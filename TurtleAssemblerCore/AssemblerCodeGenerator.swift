//
//  AssemblerCodeGenerator.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

// Takes an AST and performs a pass that does final code generation.
public class AssemblerCodeGenerator: NSObject, CodeGenerator {
    let assemblerBackEnd: AssemblerBackEnd
    public var symbols = SymbolTable()
    var patcherActions: [Patcher.Action] = []
    
    public var instructions: [Instruction] = []
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public required init(assemblerBackEnd: AssemblerBackEnd) {
        self.assemblerBackEnd = assemblerBackEnd
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
        assemblerBackEnd.begin()
        insertProgramPrologue()
        try root.iterate {
            do {
                try visit(genericNode: $0)
            } catch let error as CompilerError {
                errors.append(error)
            }
        }
        assemblerBackEnd.end()
        let patcher = Patcher(inputInstructions: assemblerBackEnd.instructions,
                              symbols: symbols,
                              actions: patcherActions,
                              base: base)
        instructions = try patcher.patch()
    }
    
    // Inserts prologue code into the program, presumably at the beginning.
    // Insert a NOP at the beginning of every program because correct operation
    // of the hardware reset cycle requires this.
    func insertProgramPrologue() {
        assemblerBackEnd.nop()
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
    }
    
    func visit(node: InstructionNode) throws {
        let instructions = [
            "ADD"  : { try self.add(node) },
            "SUB"  : { try self.sub(node) },
            "ADC"  : { try self.adc(node) },
            "SBC"  : { try self.sbc(node) },
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
            "NOP"  : { try self.nop(node) },
            "DEA"  : { try self.dea(node) },
            "DCA"  : { try self.dca(node) }
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
        
        try self.assemblerBackEnd.add(node.destination)
    }
    
    func sub(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 1 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let register = node.parameters.parameters.first as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.assemblerBackEnd.sub(node.destination)
    }
    
    func adc(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 1 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let register = node.parameters.parameters.first as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.assemblerBackEnd.adc(node.destination)
    }
    
    func sbc(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 1 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let register = node.parameters.parameters.first as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.assemblerBackEnd.sbc(node.destination)
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
        
        try self.assemblerBackEnd.blt(destination.literal, source.literal)
    }
    
    func cmp(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.cmp()
    }
    
    func hlt(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.hlt()
    }
    
    func inuv(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.inuv()
    }
    
    func inxy(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.inxy()
    }
    
    func link(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.link()
    }
    
    func jalr(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jalr()
    }
    
    func jc(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jc()
    }
    
    func jnc(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jnc()
    }
    
    func je(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.je()
    }
    
    func jne(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jne()
    }
    
    func jg(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jg()
    }
    
    func jle(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jle()
    }
    
    func jl(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jl()
    }
    
    func jge(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jge()
    }
    
    func jmp(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.jmp()
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
            try self.assemblerBackEnd.li(node.destination, token: immediate)
        } else if let identifier = node.parameters.parameters[1] as? TokenIdentifier {
            let value = try resolve(identifier: identifier)
            try self.assemblerBackEnd.li(node.destination,
                                      token: TokenNumber(lineNumber: identifier.lineNumber,
                                                         lexeme: identifier.lexeme,
                                                         literal: value))
        } else {
            throw operandTypeMismatchError(node.instruction)
        }
    }
    
    func resolve(identifier: TokenIdentifier) throws -> Int {
        let symbol = try symbols.resolve(identifierToken: identifier)
        switch symbol {
        case .constantAddress(let address):
            return address.value
        case .constantWord(let word):
            return Int(word.value)
        case .staticWord(_):
            throw Expression.MustBeCompileTimeConstantError(line: identifier.lineNumber)
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
        
        try self.assemblerBackEnd.mov(destination.literal, source.literal)
    }
    
    func nop(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 0 else {
            throw zeroOperandsExpectedError(node.instruction)
        }
        self.assemblerBackEnd.nop()
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
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: node.identifier.lineNumber,
                                format: "label redefines existing symbol: `%@'",
                                name)
        }
        symbols.bindConstantAddress(identifier: name, value: assemblerBackEnd.programCounter)
    }
    
    func visit(node: ConstantDeclarationNode) throws {
        let name = node.identifier.lexeme
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: node.identifier.lineNumber,
                                format: "constant redefines existing symbol: `%@'",
                                name)
        }
        symbols.bindConstantWord(identifier: name, value: UInt8(node.number.literal))
    }
    
    func setAddress(_ address: Int) throws {
        if(address < 0 || address > 0xffff) {
            throw CompilerError(format: "invalid address: 0x%x", address)
        }
        try self.assemblerBackEnd.li(.X, (address & 0xff00) >> 8)
        try self.assemblerBackEnd.li(.Y, (address & 0xff))
    }
    
    func setAddress(token identifier: TokenIdentifier) throws {
        patcherActions.append((index: assemblerBackEnd.programCounter,
                               symbol: identifier,
                               shift: 8))
        try assemblerBackEnd.li(.X, 0xAB)
        
        patcherActions.append((index: assemblerBackEnd.programCounter,
                               symbol: identifier,
                               shift: 0))
        try assemblerBackEnd.li(.Y, 0xCD)
    }
    
    public func dea(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 1 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let register = node.parameters.parameters.first as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.dea(node.destination)
    }
    
    public func dca(_ node: InstructionNode) throws {
        guard node.parameters.parameters.count == 1 else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        guard let register = node.parameters.parameters.first as? TokenRegister else {
            throw operandTypeMismatchError(node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.dca(node.destination)
    }
}
