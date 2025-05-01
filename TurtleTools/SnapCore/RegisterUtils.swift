//
//  RegisterUtils.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public struct RegisterUtils {
    public static func getReferencedRegisters(_ node: AbstractSyntaxTreeNode) -> [String] {
        guard let ins = node as? InstructionNode else { return [] }
        switch ins.instruction {
        case kLOAD, kSTORE, kLI, kLUI, kCMP, kADD, kSUB, kAND, kOR, kXOR, kNOT, kCMPI, kADDI, kSUBI,
            kANDI, kORI, kXORI, kJR, kJALR, kADC, kSBC, kCALLPTR:
            return ins.parameters.reversed().compactMap { ($0 as? ParameterIdentifier)?.value }

        case kLA:
            return [ins.parameters.first].compactMap { ($0 as? ParameterIdentifier)?.value }

        default:
            return []
        }
    }

    public static func getSourceRegisters(_ node: AbstractSyntaxTreeNode) -> [String] {
        guard let ins = node as? InstructionNode else { return [] }
        switch ins.instruction {
        case kLOAD, kADD, kSUB, kAND, kOR, kXOR, kNOT, kADDI, kSUBI, kANDI, kORI, kXORI, kJR, kJALR,
            kADC, kSBC, kCALLPTR:
            return ins.parameters[1...].reversed().compactMap {
                ($0 as? ParameterIdentifier)?.value
            }

        case kSTORE, kCMPI, kCMP:
            return ins.parameters.reversed().compactMap { ($0 as? ParameterIdentifier)?.value }

        case kLA:
            return []

        default:
            return []
        }
    }

    public static func getDestinationRegisters(_ node: AbstractSyntaxTreeNode) -> [String] {
        guard let ins = node as? InstructionNode else { return [] }
        switch ins.instruction {
        case kLOAD, kLI, kLUI, kADD, kSUB, kAND, kOR, kXOR, kNOT, kADDI, kSUBI, kANDI, kORI, kXORI,
            kJR, kJALR, kADC, kSBC, kCALLPTR, kLA:
            return [ins.parameters.first].compactMap { ($0 as? ParameterIdentifier)?.value }

        default:
            return []
        }
    }

    public static func rewrite(
        nodes: [AbstractSyntaxTreeNode],
        from currName: String,
        to updatedName: String
    ) -> [AbstractSyntaxTreeNode] {
        let result = nodes.map {
            rewrite(node: $0, from: currName, to: updatedName)
        }
        return result
    }

    static func rewrite(
        node: AbstractSyntaxTreeNode,
        from currName: String,
        to updatedName: String
    ) -> AbstractSyntaxTreeNode {
        guard let instruction = node as? InstructionNode else { return node }
        switch instruction.instruction {
        case kLOAD, kSTORE, kLI, kLUI, kCMP, kADD, kSUB, kAND, kOR, kXOR, kNOT, kCMPI, kADDI, kSUBI,
            kANDI, kORI, kXORI, kJR, kJALR, kADC, kSBC, kCALLPTR:
            let updatedParameters = instruction.parameters.map {
                rewriteRegisterIdentifier($0, currName, updatedName)
            }
            return InstructionNode(
                sourceAnchor: instruction.sourceAnchor,
                instruction: instruction.instruction,
                parameters: updatedParameters
            )

        case kLA:
            var parameters = instruction.parameters
            parameters[0] = rewriteRegisterIdentifier(parameters[0], currName, updatedName)
            return InstructionNode(
                sourceAnchor: instruction.sourceAnchor,
                instruction: instruction.instruction,
                parameters: parameters
            )

        default:
            return instruction
        }
    }

    static func rewriteRegisterIdentifier(
        _ param: Parameter,
        _ currName: String,
        _ updatedName: String
    ) -> Parameter {
        guard let ident = param as? ParameterIdentifier, currName == ident.value else {
            return param
        }
        return ParameterIdentifier(sourceAnchor: param.sourceAnchor, value: updatedName)
    }
}
