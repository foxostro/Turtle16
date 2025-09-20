//
//  AssemblerCompiler.swift
//  TurtleSimulatorCore
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
public let kLI = "LI"
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
public let kBGT = "BGT"
public let kBLTU = "BLTU"
public let kBGTU = "BGTU"
public let kADC = "ADC"
public let kSBC = "SBC"

// Various high-level macro instruction opcodes
public let kLA = "LA"
public let kCALL = "CALL"
public let kCALLPTR = "CALLPTR"
public let kENTER = "ENTER"
public let kLEAVE = "LEAVE"
public let kRET = "RET"
public let kBREAK = "BREAK"

public final class AssemblerCompiler {
    private let codeGenerator = AssemblerCodeGenerator()

    public var hasError: Bool { !errors.isEmpty }
    public private(set) var errors: [CompilerError] = []
    public private(set) var instructions: [UInt16] = []

    public init() {}

    public func compile(_ topLevel: TopLevel) {
        compile(ast: topLevel.children)
    }

    public func compile(ast: [AbstractSyntaxTreeNode]) {
        codeGenerator.begin()

        for node in ast {
            do {
                try compileNode(node)
            }
            catch let error as CompilerError {
                errors.append(error)
            }
            catch {
                errors.append(errorUnknown(node.sourceAnchor))
            }
        }

        do {
            try codeGenerator.end()
            instructions = codeGenerator.instructions
        }
        catch let error as CompilerError {
            errors.append(error)
        }
        catch {
            errors.append(errorUnknown(nil))
        }
    }

    private func compileNode(_ node: AbstractSyntaxTreeNode) throws {
        switch node {
        case let instructionNode as InstructionNode:
            try compileInstruction(instructionNode)

        case let labelDeclarationNode as LabelDeclaration:
            try codeGenerator.label(labelDeclarationNode.identifier)

        default:
            throw errorUnknown(node.sourceAnchor)
        }
    }

    private func compileInstruction(_ node: InstructionNode) throws {
        codeGenerator.sourceAnchor = node.sourceAnchor

        switch node.instruction {
        case kNOP:
            try compileNOP(node)

        case kHLT,
             kBREAK:
            try compileHLT(node)

        case kLOAD:
            try compileLOAD(node)

        case kSTORE:
            try compileSTORE(node)

        case kLI:
            try compileLI(node)

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

        case kBGT:
            try compileBGT(node)

        case kBLTU:
            try compileBLTU(node)

        case kBGTU:
            try compileBGTU(node)

        case kADC:
            try compileADC(node)

        case kSBC:
            try compileSBC(node)

        case kLA:
            try compileLA(node)

        case kCALL:
            try compileCALL(node)

        case kCALLPTR:
            try compileCALLPTR(node)

        case kENTER:
            try compileENTER(node)

        case kLEAVE:
            try compileLEAVE(node)

        case kRET:
            try compileRET(node)

        default:
            throw errorUnknownInstruction(node)
        }
    }

    private func compileNOP(_ node: InstructionNode) throws {
        guard node.parameters.count == 0 else {
            throw errorExpectsZeroOperands(node)
        }
        codeGenerator.nop()
    }

    private func compileHLT(_ node: InstructionNode) throws {
        guard node.parameters.count == 0 else {
            throw errorExpectsZeroOperands(node)
        }
        codeGenerator.hlt()
    }

    private func compileLOAD(_ node: InstructionNode) throws {
        guard (2...3).contains(node.parameters.count) else {
            throw errorExpectsTwoOrThreeOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let sourceAddress = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheSourceAddress(node)
        }
        let offset: Int
        if node.parameters.count > 2 {
            guard let offset0 = (node.parameters[2] as? ParameterNumber)?.value else {
                throw errorExpectsThirdOperandToBeAnImmediateValueOffset(node)
            }
            offset = offset0
        }
        else {
            offset = 0
        }
        try codeGenerator.load(destination, sourceAddress, offset)
    }

    private func compileSTORE(_ node: InstructionNode) throws {
        guard (2...3).contains(node.parameters.count) else {
            throw errorExpectsTwoOrThreeOperands(node)
        }
        guard let source = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheSource(node)
        }
        guard let destinationAddress = lookupRegister(node.parameters[1]) else {
            throw errorExpectsSecondOperandToBeTheDestinationAddress(node)
        }
        let offset: Int
        if node.parameters.count > 2 {
            guard let offset0 = (node.parameters[2] as? ParameterNumber)?.value else {
                throw errorExpectsThirdOperandToBeAnImmediateValueOffset(node)
            }
            offset = offset0
        }
        else {
            offset = 0
        }
        try codeGenerator.store(source, destinationAddress, offset)
    }

    private func compileLI(_ node: InstructionNode) throws {
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

    private func compileLUI(_ node: InstructionNode) throws {
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

    private func compileCMP(_ node: InstructionNode) throws {
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

    private func compileADD(_ node: InstructionNode) throws {
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

    private func compileSUB(_ node: InstructionNode) throws {
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

    private func compileAND(_ node: InstructionNode) throws {
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

    private func compileOR(_ node: InstructionNode) throws {
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

    private func compileXOR(_ node: InstructionNode) throws {
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

    private func compileNOT(_ node: InstructionNode) throws {
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

    private func compileCMPI(_ node: InstructionNode) throws {
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

    private func compileADDI(_ node: InstructionNode) throws {
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

    private func compileSUBI(_ node: InstructionNode) throws {
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

    private func compileANDI(_ node: InstructionNode) throws {
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

    private func compileORI(_ node: InstructionNode) throws {
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

    private func compileXORI(_ node: InstructionNode) throws {
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

    private func compileJMP(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard lookupRegister(node.parameters[0]) == nil else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.jmp(name)
    }

    private func compileJR(_ node: InstructionNode) throws {
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

    private func compileJALR(_ node: InstructionNode) throws {
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

    private func compileBEQ(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard lookupRegister(node.parameters[0]) == nil else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.beq(name)
    }

    private func compileBNE(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard lookupRegister(node.parameters[0]) == nil else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bne(name)
    }

    private func compileBLT(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard lookupRegister(node.parameters[0]) == nil else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.blt(name)
    }

    private func compileBGT(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard lookupRegister(node.parameters[0]) == nil else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bgt(name)
    }

    private func compileBLTU(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard lookupRegister(node.parameters[0]) == nil else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bltu(name)
    }

    private func compileBGTU(_ node: InstructionNode) throws {
        guard node.parameters.count == 1 else {
            throw errorExpectsOneOperand(node)
        }
        guard lookupRegister(node.parameters[0]) == nil else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        guard let name = (node.parameters[0] as? ParameterIdentifier)?.value else {
            throw errorExpectsFirstOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.bgtu(name)
    }

    private func compileADC(_ node: InstructionNode) throws {
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

    private func compileSBC(_ node: InstructionNode) throws {
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

    private func compileLA(_ node: InstructionNode) throws {
        guard node.parameters.count == 2 else {
            throw errorExpectsTwoOperands(node)
        }
        guard let destination = lookupRegister(node.parameters[0]) else {
            throw errorExpectsFirstOperandToBeTheDestination(node)
        }
        guard let name = (node.parameters[1] as? ParameterIdentifier)?.value else {
            throw errorExpectsSecondOperandToBeLabelIdentifier(node)
        }
        try codeGenerator.la(destination, name)
    }

    private func compileCALL(_ node: InstructionNode) throws {
        try compileNodes([
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("ra"),
                    node.parameters[0]
                ]
            ),
            InstructionNode(
                instruction: kJALR,
                parameters: [
                    ParameterIdentifier("ra"),
                    ParameterIdentifier("ra"),
                    ParameterNumber(0)
                ]
            )
        ])
    }

    private func compileCALLPTR(_ node: InstructionNode) throws {
        try compileNodes([
            InstructionNode(
                instruction: kJALR,
                parameters: [
                    ParameterIdentifier("ra"),
                    node.parameters[0],
                    ParameterNumber(0)
                ]
            )
        ])
    }

    private let kSizeOfSavedRegisters = 7

    private func compileENTER(_ node: InstructionNode) throws {
        // The ENTER instructions pushes physical registers on the stack and
        // then establishes a new stack frame by `fp <- sp ; sp <- sp - size`.
        // TODO: While this scheme will work, it would be more efficient to only save/restore registers which are actually used in a function.
        guard node.parameters.count < 2 else {
            throw errorExpectsZeroOrOneOperands(node)
        }
        let size: Int
        if node.parameters.count == 0 {
            size = 0
        }
        else {
            guard let sizeArg = node.parameters[0] as? ParameterNumber else {
                throw errorExpectsFirstOperandToBeTheSize(node)
            }
            size = sizeArg.value
        }
        var instructions: [InstructionNode] = [
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(kSizeOfSavedRegisters)
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(6)
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(5)
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(4)
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(3)
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(2)
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("ra"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(1)
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(0)
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(0)
                ]
            )
        ]
        if size != 0 {
            if size >= 15 {
                instructions += [
                    InstructionNode(
                        instruction: kLI,
                        parameters: [
                            ParameterIdentifier("r0"),
                            ParameterNumber(Int(size & 0x00ff))
                        ]
                    ),
                    InstructionNode(
                        instruction: kLUI,
                        parameters: [
                            ParameterIdentifier("r0"),
                            ParameterNumber(Int((size & 0xff00) >> 8))
                        ]
                    ),
                    InstructionNode(
                        instruction: kSUB,
                        parameters: [
                            ParameterIdentifier("sp"),
                            ParameterIdentifier("sp"),
                            ParameterIdentifier("r0")
                        ]
                    )
                ]
            }
            else {
                instructions += [
                    InstructionNode(
                        instruction: kSUBI,
                        parameters: [
                            ParameterIdentifier("sp"),
                            ParameterIdentifier("sp"),
                            ParameterNumber(size)
                        ]
                    )
                ]
            }
        }
        try compileNodes(instructions)
    }

    private func compileLEAVE(_: InstructionNode) throws {
        // The LEAVE instructions tears down the stack frame by doing
        // `sp <- fp` and then restores physical register values by popping
        // them off the stack.
        try compileNodes([
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(0)
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(6)
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(5)
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(4)
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(3)
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r4"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(2)
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("ra"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(1)
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(0)
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(kSizeOfSavedRegisters)
                ]
            )
        ])
    }

    private func compileRET(_: InstructionNode) throws {
        try compileNodes([
            InstructionNode(
                instruction: kJR,
                parameters: [
                    ParameterIdentifier("ra"),
                    ParameterNumber(-1)
                ]
            )
        ])
    }

    private func compileNodes(_ nodes: [InstructionNode]) throws {
        for ins in nodes {
            try compileNode(ins)
        }
    }

    private func lookupRegister(_ parameter: Parameter) -> AssemblerCodeGenerator.Register? {
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

        case "r5",
             "ra":
            return .r5

        case "r6",
             "sp":
            return .r6

        case "r7",
             "fp":
            return .r7

        default:
            return nil
        }
    }

    private func errorUnknown(_ sourceAnchor: SourceAnchor?) -> CompilerError {
        CompilerError(sourceAnchor: sourceAnchor, message: "unknown error")
    }

    private func errorUnknownInstruction(_ node: AbstractSyntaxTreeNode) -> CompilerError {
        CompilerError(sourceAnchor: node.sourceAnchor, message: "unknown instruction")
    }

    private func errorExpectsZeroOperands(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects zero operands: `\(node.instruction)'"
        )
    }

    private func errorExpectsOneOperand(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects one operand: `\(node.instruction)'"
        )
    }

    private func errorExpectsZeroOrOneOperands(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects zero or one operands: `\(node.instruction)'"
        )
    }

    private func errorExpectsOneOrTwoOperands(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects one or two operands: `\(node.instruction)'"
        )
    }

    private func errorExpectsTwoOperands(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects two operands: `\(node.instruction)'"
        )
    }

    private func errorExpectsTwoOrThreeOperands(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects two or three operands: `\(node.instruction)'"
        )
    }

    private func errorExpectsThreeOperands(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects three operands: `\(node.instruction)'"
        )
    }

    private func errorExpectsFirstOperandToBeLabelIdentifier(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the first operand to be a label identifier: `\(node.instruction)'"
        )
    }

    private func errorExpectsSecondOperandToBeLabelIdentifier(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the second operand to be a label identifier: `\(node.instruction)'"
        )
    }

    private func errorExpectsFirstOperandToBeTheLinkRegister(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the first operand to be the link register: `\(node.instruction)'"
        )
    }

    private func errorExpectsFirstOperandToBeTheDestination(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the first operand to be the destination register: `\(node.instruction)'"
        )
    }

    private func errorExpectsFirstOperandToBeTheDestinationAddress(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the first operand to be the register containing the destination address: `\(node.instruction)'"
        )
    }

    private func errorExpectsFirstOperandToBeTheLeftOperand(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the first operand to be a register containing the left operand: `\(node.instruction)'"
        )
    }

    private func errorExpectsFirstOperandToBeTheSize(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the operand to be the size: `\(node.instruction)'"
        )
    }

    private func errorExpectsFirstOperandToBeTheSource(_ node: InstructionNode) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the first operand to be the source register: `\(node.instruction)'"
        )
    }

    private func errorExpectsSecondOperandToBeTheSource(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the second operand to be the source register: `\(node.instruction)'"
        )
    }

    private func errorExpectsSecondOperandToBeTheSourceAddress(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the second operand to be the register containing the source address: `\(node.instruction)'"
        )
    }

    private func errorExpectsSecondOperandToBeTheDestinationAddress(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the second operand to be the register containing the destination address: `\(node.instruction)'"
        )
    }

    private func errorExpectsSecondOperandToBeTheLeftOperand(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the second operand to be a register containing the left operand: `\(node.instruction)'"
        )
    }

    private func errorExpectsSecondOperandToBeTheRightOperand(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the second operand to be a register containing the right operand: `\(node.instruction)'"
        )
    }

    private func errorExpectsSecondOperandToBeAnImmediateValue(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the second operand to be an immediate value: `\(node.instruction)'"
        )
    }

    private func errorExpectsOptionalSecondOperandToBeAnImmediateValue(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the optional second operand to be an immediate value: `\(node.instruction)'"
        )
    }

    private func errorExpectsThirdOperandToBeAnImmediateValue(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the third operand to be an immediate value: `\(node.instruction)'"
        )
    }

    private func errorExpectsThirdOperandToBeAnImmediateValueOffset(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the optional third operand to be an immediate value offset: `\(node.instruction)'"
        )
    }

    private func errorExpectsThirdOperandToBeTheRightOperand(
        _ node: InstructionNode
    ) -> CompilerError {
        CompilerError(
            sourceAnchor: node.sourceAnchor,
            message: "instruction expects the third operand to be a register containing the right operand: `\(node.instruction)'"
        )
    }
}
