//
//  AssemblerListingMaker.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 7/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class AssemblerListingMaker: NSObject {
    public func makeListing(_ node: AbstractSyntaxTreeNode) -> String {
        switch node {
        case let node as TopLevel:
            return makeListing(topLevel: node)

        case let node as InstructionNode:
            return makeListing(instruction: node)
            
        case let node as LabelDeclaration:
            return makeListing(label: node)
            
        case let node as CommentNode:
            return makeListing(comment: node)
        
        default:
            fatalError("unimplemented node: \(node)")
        }
    }
    
    public func makeListing(topLevel node: TopLevel) -> String {
        return node.children.map { makeListing($0) }.joined(separator: "\n")
    }
    
    public func makeListing(instruction node: InstructionNode) -> String {
        if node.parameters.count > 0 {
            return node.instruction + " " + makeListing(parameterList: node.parameters)
        } else {
            return node.instruction
        }
    }
    
    public func makeListing(parameterList: [Parameter]) -> String {
        return parameterList.map { makeListing(parameter: $0) }.joined(separator: ", ")
    }
    
    public func makeListing(parameter node: Parameter) -> String {
        switch node {
        case let node as ParameterIdentifier:
            return node.value

        case let node as ParameterNumber:
            return "\(node.value)"
        
        default:
            fatalError("unimplemented node: \(node)")
        }
    }
    
    public func makeListing(label node: LabelDeclaration) -> String {
        return "\(node.identifier):"
    }
    
    public func makeListing(comment node: CommentNode) -> String {
        return node.string.split(separator: "\n").map({"# \($0)"}).joined(separator: "\n")
    }
}
