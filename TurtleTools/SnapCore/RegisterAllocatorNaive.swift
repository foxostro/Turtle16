//
//  RegisterAllocatorNaive.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/23/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public class RegisterAllocatorNaive: SnapASTTransformerBase {
    public override func visit(instruction node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        switch node.instruction {
        case kLOAD, kSTORE, kLI, kLUI, kCMP, kADD, kSUB, kAND, kOR, kXOR, kNOT, kCMPI, kADDI, kSUBI, kANDI, kORI, kXORI, kJR, kJALR, kADC, kSBC, kCALLPTR:
            return try rewriteInstructionWithRegisterIdentifiers(node)
            
        case kLA:
            return try la(node)
            
        default:
            return node
        }
    }
    
    func rewriteRegisterIdentifier(_ input: String) -> String? {
        switch input {
        case "vr0": return "r0"
        case "vr1": return "r1"
        case "vr2": return "r2"
        case "vr3": return "r3"
        case "vr4": return "r4"
        case "vr5", "ra":  return "r5"
        case "vr6", "sp":  return "r6"
        case "vr7", "fp":  return "r7"
        default: return nil
        }
    }
    
    func rewriteRegisterIdentifier(_ param: Parameter) throws -> Parameter {
        guard let ident = param as? ParameterIdentifier else {
            return param
        }
        guard let rewritten = rewriteRegisterIdentifier(ident.value) else {
            throw CompilerError(sourceAnchor: param.sourceAnchor, message: "unable to map virtual register to physical register: `\(param)'")
        }
        return ParameterIdentifier(sourceAnchor: param.sourceAnchor, value: rewritten)
    }
    
    func rewriteInstructionWithRegisterIdentifiers(_ node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor,
                               instruction: node.instruction,
                               parameters: try node.parameters.map(rewriteRegisterIdentifier))
    }
    
    func la(_ node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        var parameters = node.parameters
        parameters[0] = try rewriteRegisterIdentifier(parameters[0])
        return InstructionNode(sourceAnchor: node.sourceAnchor,
                               instruction: node.instruction,
                               parameters: parameters)
    }
}
