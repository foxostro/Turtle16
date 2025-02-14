//
//  RegisterAllocatorNaive.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/23/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public final class RegisterAllocatorNaive: CompilerPass {
    public override func visit(instruction node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        switch node.instruction {
        case kLOAD, kSTORE, kLI, kLUI, kCMP, kADD, kSUB, kAND, kOR, kXOR, kNOT, kCMPI, kADDI, kSUBI, kANDI, kORI, kXORI, kJR, kJALR, kADC, kSBC, kCALLPTR:
            try rewriteInstructionWithRegisterIdentifiers(node)
            
        case kLA:
            try la(node)
            
        default:
            node
        }
    }
    
    func rewriteRegisterIdentifier(_ input: String) -> String? {
        switch input {
        case "vr0": "r0"
        case "vr1": "r1"
        case "vr2": "r2"
        case "vr3": "r3"
        case "vr4": "r4"
        case "vr5", "ra":  "r5"
        case "vr6", "sp":  "r6"
        case "vr7", "fp":  "r7"
        default: nil
        }
    }
    
    func rewriteRegisterIdentifier(_ param: Parameter) throws -> Parameter {
        guard let ident = param as? ParameterIdentifier else {
            return param
        }
        guard let rewritten = rewriteRegisterIdentifier(ident.value) else {
            throw CompilerError(sourceAnchor: param.sourceAnchor, message: "unable to map virtual register to physical register: `\(param)'")
        }
        return ParameterIdentifier(
            sourceAnchor: param.sourceAnchor,
            value: rewritten,
            id: param.id)
    }
    
    func rewriteInstructionWithRegisterIdentifiers(_ node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        InstructionNode(
            sourceAnchor: node.sourceAnchor,
            instruction: node.instruction,
            parameters: try node.parameters.map(rewriteRegisterIdentifier),
            id: node.id)
    }
    
    func la(_ node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        var parameters = node.parameters
        parameters[0] = try rewriteRegisterIdentifier(parameters[0])
        return InstructionNode(sourceAnchor: node.sourceAnchor,
                               instruction: node.instruction,
                               parameters: parameters,
                               id: node.id)
    }
}
