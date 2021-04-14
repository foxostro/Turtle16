//
//  AssemblerCodeGenerator.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

// Takes an AST and performs a pass that does final code generation.
public class AssemblerCodeGenerator: NSObject {
    let assemblerBackEnd: AssemblerBackEnd
    public var symbols: [String:Int] = [:]
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
    
    public func compile(ast root: TopLevel, base: Int) {
        do {
            try tryCompile(ast: root, base: base)
        } catch let error as CompilerError {
            errors.append(error)
        } catch {
            // This catch block should be unreachable because patch()
            // only throws CompilerError. Regardless, we need it to satisfy
            // the compiler.
            errors.append(CompilerError(sourceAnchor: root.sourceAnchor, message: "unrecoverable error: \(error.localizedDescription)"))
        }
    }
    
    func tryCompile(ast root: TopLevel, base: Int) throws {
        instructions = []
        patcherActions = []
        assemblerBackEnd.begin()
        insertProgramPrologue()
        for child in root.children {
            do {
                try visit(genericNode: child)
            } catch let error as CompilerError {
                errors.append(error)
            }
        }
        assemblerBackEnd.end()
        let resolver = {[weak self] (sourceAnchor: SourceAnchor?, identifier: String) in
            return try self!.resolve(sourceAnchor: sourceAnchor, identifier: identifier)
        }
        let patcher = Patcher(inputInstructions: assemblerBackEnd.instructions,
                              resolver: resolver,
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
        if let node = genericNode as? TurtleTTLInstructionNode {
            try visit(node: node)
        }
        if let node = genericNode as? LabelDeclaration {
            try visit(node: node)
        }
        if let node = genericNode as? ConstantDeclaration {
            try visit(node: node)
        }
    }
    
    func visit(node: TurtleTTLInstructionNode) throws {
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
            "DCA"  : { try self.dca(node) },
            "AND"  : { try self.and(node) },
            "OR"   : { try self.or(node)  },
            "XOR"  : { try self.xor(node) },
            "LSL"  : { try self.lsl(node) },
            "NEG"  : { try self.neg(node) }
        ]
        if let closure = instructions[node.instruction] {
            try closure()
        } else {
            throw unrecognizedInstructionError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
    }
    
    func add(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.assemblerBackEnd.add(node.destination)
    }
    
    func sub(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.assemblerBackEnd.sub(node.destination)
    }
    
    func adc(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.assemblerBackEnd.adc(node.destination)
    }
    
    func sbc(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try self.assemblerBackEnd.sbc(node.destination)
    }
    
    func blt(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 2 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let destination = node.parameters.elements[0] as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        
        guard let source = node.parameters.elements[1] as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        try expectRegisterCanBeUsedAsSource(source)
        
        try self.assemblerBackEnd.blt(destination.value, source.value)
    }
    
    func cmp(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.cmp()
    }
    
    func hlt(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.hlt()
    }
    
    func inuv(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.inuv()
    }
    
    func inxy(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.inxy()
    }
    
    func link(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.link()
    }
    
    func jalr(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jalr()
    }
    
    func jc(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jc()
    }
    
    func jnc(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jnc()
    }
    
    func je(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.je()
    }
    
    func jne(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jne()
    }
    
    func jg(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jg()
    }
    
    func jle(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jle()
    }
    
    func jl(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jl()
    }
    
    func jge(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jge()
    }
    
    func jmp(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.jmp()
    }
    
    func li(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 2 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let destination = node.parameters.elements[0] as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        
        if let immediate = node.parameters.elements[1] as? ParameterNumber {
            try self.assemblerBackEnd.li(node.destination, immediate.value)
        } else if let identifier = node.parameters.elements[1] as? ParameterIdentifier {
            let value = try resolve(sourceAnchor: identifier.sourceAnchor, identifier: identifier.value)
            try self.assemblerBackEnd.li(node.destination, value)
        } else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
    }
    
    func resolve(sourceAnchor: SourceAnchor?, identifier: String) throws -> Int {
        guard let address = symbols[identifier] else {
            throw CompilerError(sourceAnchor: sourceAnchor, message: "use of unresolved identifier: `\(identifier)'")
        }
        return address
    }
    
    func lxy(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        let parameter = node.parameters.elements.first!
        
        if let identifier = parameter as? ParameterIdentifier {
            try self.setAddress(identifier: identifier)
        } else if let address = parameter as? ParameterNumber {
            try self.setAddress(number: address)
        } else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
    }
    
    func mov(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 2 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let destination = node.parameters.elements[0] as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        
        guard let source = node.parameters.elements[1] as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        try expectRegisterCanBeUsedAsSource(source)
        
        try self.assemblerBackEnd.mov(destination.value, source.value)
    }
    
    func nop(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 0 else {
            throw zeroOperandsExpectedError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        self.assemblerBackEnd.nop()
    }
    
    func expectRegisterCanBeUsedAsDestination(_ register: ParameterRegister) throws {
        if register.value == .E || register.value == .C {
            throw badDestinationError(register)
        }
    }
    
    func badDestinationError(_ register: ParameterRegister) -> Error {
        return CompilerError(sourceAnchor: register.sourceAnchor, message: "register cannot be used as a destination: `\(String(describing: register.value))'")
    }
    
    func expectRegisterCanBeUsedAsSource(_ register: ParameterRegister) throws {
        if register.value == .D {
            throw badSourceError(register)
        }
    }
    
    func badSourceError(_ register: ParameterRegister) -> Error {
        return CompilerError(sourceAnchor: register.sourceAnchor, message: "register cannot be used as a source: `\(String(describing: register.value))'")
    }
    
    func zeroOperandsExpectedError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "instruction takes no operands: `\(instruction)'")
    }
    
    func operandTypeMismatchError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "operand type mismatch: `\(instruction)'")
    }
    
    func unrecognizedInstructionError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "no such instruction: `\(instruction)'")
    }
    
    func visit(node: LabelDeclaration) throws {
        let name = node.identifier
        guard symbols[name] == nil else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "label redefines existing symbol: `\(name)'")
        }
        symbols[name] = assemblerBackEnd.programCounter
    }
    
    func visit(node: ConstantDeclaration) throws {
        let name = node.identifier
        guard symbols[name] == nil else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "constant redefines existing symbol: `\(name)'")
        }
        symbols[name] = node.value
    }
    
    func setAddress(number: ParameterNumber) throws {
        let address = number.value
        guard address >= 0 && address <= 0xffff else {
            throw CompilerError(sourceAnchor: number.sourceAnchor, format: "invalid address: 0x%x", address)
        }
        try self.assemblerBackEnd.li(.X, (address & 0xff00) >> 8)
        try self.assemblerBackEnd.li(.Y, (address & 0xff))
    }
    
    func setAddress(identifier: ParameterIdentifier) throws {
        patcherActions.append((index: assemblerBackEnd.programCounter,
                               sourceAnchor: identifier.sourceAnchor,
                               symbol: identifier.value,
                               shift: 8))
        try assemblerBackEnd.li(.X, 0xAB)
        
        patcherActions.append((index: assemblerBackEnd.programCounter,
                               sourceAnchor: identifier.sourceAnchor,
                               symbol: identifier.value,
                               shift: 0))
        try assemblerBackEnd.li(.Y, 0xCD)
    }
    
    public func dea(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.dea(node.destination)
    }
    
    public func dca(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.dca(node.destination)
    }
    
    public func and(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.and(node.destination)
    }
    
    public func or(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.or(node.destination)
    }
    
    public func xor(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.xor(node.destination)
    }
    
    public func lsl(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.lsl(node.destination)
    }
    
    public func neg(_ node: TurtleTTLInstructionNode) throws {
        guard node.parameters.elements.count == 1 else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        guard let register = node.parameters.elements.first as? ParameterRegister else {
            throw operandTypeMismatchError(sourceAnchor: node.sourceAnchor, instruction: node.instruction)
        }
        
        try expectRegisterCanBeUsedAsDestination(register)
        
        try assemblerBackEnd.neg(node.destination)
    }
}
