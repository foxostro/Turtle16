//
//  AssemblerCompiler.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 5/26/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Turtle16 assembly instruction opcodes
public let kNOP = "NOP"
public let kHLT = "HLT"
public let kLOAD = "LOAD"
public let kSTORE = "STORE"
public let kLA = "LA"
public let kLI = "LI"
public let kLIU = "LIU"
public let kLUI = "LUI"
public let kCMP = "CMP"
public let kADD = "ADD"
public let kSUB = "SUB"
public let kAND = "AND"
public let kOR = "OR"
public let kXOR = "XOR"
public let kNOT = "NOT"
public let kCMPI = "CMPI"
public let kADDI = "ADDI"
public let kSUBI = "SUBI"
public let kANDI = "ANDI"
public let kORI = "ORI"
public let kXORI = "XORI"
public let kJMP = "JMP"
public let kJR = "JR"
public let kJALR = "JALR"
public let kBEQ = "BEQ"
public let kBNE = "BNE"
public let kBLT = "BLT"
public let kBGE = "BGE"
public let kBLTU = "BLTU"
public let kBGEU = "BGEU"
public let kADC = "ADC"
public let kSBC = "SBC"

// Various high-level macro instruction opcodes
public let kCALL = "CALL"
public let kCALLPTR = "CALLPTR"
public let kENTER = "ENTER"
public let kLEAVE = "LEAVE"
public let kRET = "RET"

public class AssemblerCompiler: NSObject {
    let codeGenerator = AssemblerCodeGenerator()
    
    public var hasError: Bool {
        return !errors.isEmpty
    }
    public private(set) var errors: [CompilerError] = []
    public private(set) var instructions: [UInt16] = []
    
    public func compile(_ topLevel: TopLevel) {
        compile(ast: topLevel.children)
    }
    
    public func compile(ast: [AbstractSyntaxTreeNode]) {
        codeGenerator.begin()
        
        for node in ast {
            do {
                try compileNode(node)
            } catch let error as CompilerError {
                errors.append(error)
            } catch {
                errors.append(errorUnknown(node.sourceAnchor))
            }
        }
        
        do {
            try codeGenerator.end()
            instructions = codeGenerator.instructions
        } catch let error as CompilerError {
            errors.append(error)
        } catch {
            errors.append(errorUnknown(nil))
        }
    }
    
    fileprivate func compileNode(_ node: AbstractSyntaxTreeNode) throws {
        switch node {
        case let instructionNode as InstructionNode:
            try compileInstruction(instructionNode)
            
        case let labelDeclarationNode as LabelDeclaration:
            try codeGenerator.label(labelDeclarationNode.identifier)
            
        default:
            throw errorUnknown(node.sourceAnchor)
        }
    }
    
    fileprivate func compileInstruction(_ node: InstructionNode) throws {
        codeGenerator.sourceAnchor = node.sourceAnchor
        
        switch node.instruction {
        case kNOP:
            try compileNOP(node)
            
        case kHLT:
            try compileHLT(node)
            
        case kLOAD:
            try compileLOAD(node)
            
        case kSTORE:
            try compileSTORE(node)
            
        case kLI:
            try compileLI(node)
            
        case kLIU:
            try compileLIU(node)
            
        case kLUI:
            try compileLUI(node)
            
        case kCMP:
            try compileCMP(node)
            
        case kADD:
            try compileADD(node)
            
        case kSUB:
            try compileSUB(node)
            
        case kAND:
            try compileAND(node)
            
        case kOR:
            try compileOR(node)
            
        case kXOR:
            try compileXOR(node)
            
        case kNOT:
            try compileNOT(node)
            
        case kCMPI:
            try compileCMPI(node)
            
        case kADDI:
            try compileADDI(node)
            
        case kSUBI:
            try compileSUBI(node)
            
        case kANDI:
            try compileANDI(node)
            
        case kORI:
            try compileORI(node)
            
        case kXORI:
            try compileXORI(node)
            
        case kJMP:
            try compileJMP(node)
            
        case kJR:
            try compileJR(node)
            
        case kJALR:
            try compileJALR(node)
            
        case kBEQ:
            try compileBEQ(node)
            
        case kBNE:
            try compileBNE(node)
            
        case kBLT:
            try compileBLT(node)

        case kBGE:
            try compileBGE(node)

        case kBLTU:
            try compileBLTU(node)

        case kBGEU:
            try compileBGEU(node)
            
        case kADC:
            try compileADC(node)

        case kSBC:
            try compileSBC(node)
            
        default:
            throw errorUnknownInstruction(node)
        }
    }
    
    fileprivate func compileNOP(_ node: InstructionNode) throws {
        guard node.parameters.count == 0 else {
            throw errorExpectsZeroOperands(node)
        }
        codeGenerator.nop()
    }
    
    fileprivate func compileHLT(_ node: InstructionNode) throws {
        guard node.parameters.count == 0 else {
            throw errorExpectsZeroOperands(node)
        }
        codeGenerator.hlt()
    }
    
    fileprivate func compileLOAD(_ node: InstructionNode) throws {
        guard (2...3).contains(node.parameters.count) else {
            throw errorExpectsTwoOrThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let sourceAddress = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheSourceAddress(node)
        }
        guard let offset = ((node.parameters.count > 2 ? node.parameters[2] : nil) as? ParameterNumber)?.value else {
            throw errorExpectsThirdOperandToBeAnImmediateValueOffset(node)
        }
        try codeGenerator.load(destination, sourceAddress, offset)
    }
    
    fileprivate func compileSTORE(_ node: InstructionNode) throws {
        guard (2...3).contains(node.parameters.count) else {
            throw errorExpectsTwoOrThreeOperands(node)
        }
        guard let destinationAddress = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestinationAddress(node)
        }
        guard let source = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheSource(node)
        }
        guard let offset = ((node.parameters.count > 2 ? node.parameters[2] : nil) as? ParameterNumber)?.value else {
            throw errorExpectsThirdOperandToBeAnImmediateValueOffset(node)
        }
        try codeGenerator.store(destinationAddress, source, offset)
    }
    
    fileprivate func compileLI(_ node: InstructionNode) throws {
        guard node.parameters.count == 2 else {
            throw errorExpectsTwoOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let immediate = (node.parameters[1] as? ParameterNumber)?.value else {
            throw errorExpectsSecondOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.li(destination, immediate)
    }
    
    fileprivate func compileLIU(_ node: InstructionNode) throws {
        guard node.parameters.count == 2 else {
            throw errorExpectsTwoOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let immediate = (node.parameters[1] as? ParameterNumber)?.value else {
            throw errorExpectsSecondOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.liu(destination, immediate)
    }
    
    fileprivate func compileLUI(_ node: InstructionNode) throws {
        guard node.parameters.count == 2 else {
            throw errorExpectsTwoOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let immediate = (node.parameters[1] as? ParameterNumber)?.value else {
            throw errorExpectsSecondOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.lui(destination, immediate)
    }
    
    fileprivate func compileCMP(_ node: InstructionNode) throws {
        guard node.parameters.count == 2 else {
            throw errorExpectsTwoOperands(node)
        }
        guard let left = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheRightOperand(node)
        }
        try codeGenerator.cmp(left, right)
    }
    
    fileprivate func compileADD(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[2]) else {
            throw errorExpectsThirdOperandToBeTheRightOperand(node)
        }
        try codeGenerator.add(destination, left, right)
    }
    
    fileprivate func compileSUB(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[2]) else {
            throw errorExpectsThirdOperandToBeTheRightOperand(node)
        }
        try codeGenerator.sub(destination, left, right)
    }
    
    fileprivate func compileAND(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[2]) else {
            throw errorExpectsThirdOperandToBeTheRightOperand(node)
        }
        try codeGenerator.and(destination, left, right)
    }
    
    fileprivate func compileOR(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[2]) else {
            throw errorExpectsThirdOperandToBeTheRightOperand(node)
        }
        try codeGenerator.or(destination, left, right)
    }
    
    fileprivate func compileXOR(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[2]) else {
            throw errorExpectsThirdOperandToBeTheRightOperand(node)
        }
        try codeGenerator.xor(destination, left, right)
    }
    
    fileprivate func compileNOT(_ node: InstructionNode) throws {
        guard node.parameters.count == 2 else {
            throw errorExpectsTwoOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let source = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheSource(node)
        }
        try codeGenerator.not(destination, source)
    }
    
    fileprivate func compileCMPI(_ node: InstructionNode) throws {
        guard node.parameters.count == 2 else {
            throw errorExpectsTwoOperands(node)
        }
        guard let left = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheLeftOperand(node)
        }
        guard let right = (node.parameters[1] as? ParameterNumber)?.value else {
            throw errorExpectsSecondOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.cmpi(left, right)
    }
    
    fileprivate func compileADDI(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = (node.parameters[2] as? ParameterNumber)?.value else {
            throw errorExpectsThirdOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.addi(destination, left, right)
    }
    
    fileprivate func compileSUBI(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = (node.parameters[2] as? ParameterNumber)?.value else {
            throw errorExpectsThirdOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.subi(destination, left, right)
    }
    
    fileprivate func compileANDI(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = (node.parameters[2] as? ParameterNumber)?.value else {
            throw errorExpectsThirdOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.andi(destination, left, right)
    }
    
    fileprivate func compileORI(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = (node.parameters[2] as? ParameterNumber)?.value else {
            throw errorExpectsThirdOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.ori(destination, left, right)
    }
    
    fileprivate func compileXORI(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = (node.parameters[2] as? ParameterNumber)?.value else {
            throw errorExpectsThirdOperandToBeAnImmediateValue(node)
        }
        try codeGenerator.xori(destination, left, right)
    }
    
    fileprivate func compileJMP(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard nil == lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.jmp(name)
    }
    
    fileprivate func compileJR(_ node: InstructionNode) throws {
        guard (1...2).contains(node.parameters.count) else {
            throw errorExpectsOneOrTwoOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestinationAddress(node)
        }
        let offset: Int
        if node.parameters.count == 2 {
            guard let offset_ = (node.parameters[1] as? ParameterNumber)?.value else {
                throw errorExpectsOptionalSecondOperandToBeAnImmediateValue(node)
            }
            offset = offset_
        }
        else {
            offset = 0
        }
        try codeGenerator.jr(destination, offset)
    }
    
    fileprivate func compileJALR(_ node: InstructionNode) throws {
        guard (2...3).contains(node.parameters.count) else {
            throw errorExpectsTwoOrThreeOperands(node)
        }
        guard let link = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheLinkRegister(node)
        }
        guard let destination = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheDestinationAddress(node)
        }
        let offset: Int
        if node.parameters.count == 3 {
            guard let offset_ = (node.parameters[2] as? ParameterNumber)?.value else {
                throw errorExpectsThirdOperandToBeAnImmediateValueOffset(node)
            }
            offset = offset_
        }
        else {
            offset = 0
        }
        try codeGenerator.jalr(link, destination, offset)
    }
    
    fileprivate func compileBEQ(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard nil == lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.beq(name)
    }
    
    fileprivate func compileBNE(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard nil == lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bne(name)
    }
    
    fileprivate func compileBLT(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard nil == lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.blt(name)
    }
    
    fileprivate func compileBGE(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard nil == lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bge(name)
    }
    
    fileprivate func compileBLTU(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard nil == lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bltu(name)
    }
    
    fileprivate func compileBGEU(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard nil == lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bgeu(name)
    }
    
    fileprivate func compileADC(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[2]) else {
            throw errorExpectsThirdOperandToBeTheRightOperand(node)
        }
        try codeGenerator.adc(destination, left, right)
    }
    
    fileprivate func compileSBC(_ node: InstructionNode) throws {
        guard node.parameters.count == 3 else {
            throw errorExpectsThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let left = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheLeftOperand(node)
        }
        guard let right = lookupRegister(node.parameters[2]) else {
            throw errorExpectsThirdOperandToBeTheRightOperand(node)
        }
        try codeGenerator.sbc(destination, left, right)
    }
    
    fileprivate func lookupRegister(_ parameter: Parameter) -> AssemblerCodeGenerator.Register? {
        guard let identifier = (parameter as? ParameterIdentifier)?.value else {
            return nil
        }
        switch identifier {
        case "r0":
            return .r0
            
        case "r1":
            return .r1
            
        case "r2":
            return .r2
            
        case "r3":
            return .r3
            
        case "r4":
            return .r4
            
        case "r5":
            return .r5
            
        case "r6":
            return .r6
            
        case "r7":
            return .r7
            
        default:
            return nil
        }
    }
    
    fileprivate func errorUnknown(_ sourceAnchor: SourceAnchor?) -> CompilerError {
        return CompilerError(sourceAnchor: sourceAnchor, message: "unknown error")
    }
    
    fileprivate func errorUnknownInstruction(_ node: AbstractSyntaxTreeNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "unknown instruction")
    }
    
    fileprivate func errorExpectsZeroOperands(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects zero operands: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsOneOperand(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects one operand: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsOneOrTwoOperands(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects one or two operands: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsTwoOperands(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects two operands: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsTwoOrThreeOperands(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects two or three operands: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsThreeOperands(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects three operands: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsFirstOperandToBeLabelIdentifier(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the first operand to be a label identifier: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsFirstOperandToBeTheLinkRegister(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the first operand to be the link register: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsFirstOperandToBeTheDestination(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the first operand to be the destination register: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsFirstOperandToBeTheDestinationAddress(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the first operand to be the register containing the destination address: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsFirstOperandToBeTheLeftOperand(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the first operand to be a register containing the left operand: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsSecondOperandToBeTheSource(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the second operand to be the source register: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsSecondOperandToBeTheSourceAddress(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the second operand to be the register containing the source address: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsSecondOperandToBeTheDestinationAddress(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the second operand to be the register containing the destination address: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsSecondOperandToBeTheLeftOperand(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the second operand to be a register containing the left operand: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsSecondOperandToBeTheRightOperand(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the second operand to be a register containing the right operand: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsSecondOperandToBeAnImmediateValue(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the second operand to be an immediate value: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsOptionalSecondOperandToBeAnImmediateValue(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the optional second operand to be an immediate value: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsThirdOperandToBeAnImmediateValue(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the third operand to be an immediate value: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsThirdOperandToBeAnImmediateValueOffset(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the optional third operand to be an immediate value offset: `\(node.instruction)'")
    }
    
    fileprivate func errorExpectsThirdOperandToBeTheRightOperand(_ node: InstructionNode) -> CompilerError {
        return CompilerError(sourceAnchor: node.sourceAnchor, message: "instruction expects the third operand to be a register containing the right operand: `\(node.instruction)'")
    }
}
