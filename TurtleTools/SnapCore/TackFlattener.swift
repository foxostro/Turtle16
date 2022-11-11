//
//  TackFlattener.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/6/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class TackFlattener: NSObject {
    private var instructions: [TackInstruction] = []
    private var labels: [String : Int] = [:]
    
    public func compile(_ node: AbstractSyntaxTreeNode) throws -> TackProgram {
        try innerCompile(node)
        return TackProgram(instructions: instructions,
                        labels: labels,
                        ast: node)
    }
    
    private func innerCompile(_ node: AbstractSyntaxTreeNode) throws {
        switch node {
        case let node as TackInstructionNode:
            instructions.append(node.instruction)
            
        case let node as Seq:
            for child in node.children {
                try innerCompile(child)
            }
            
        case let node as LabelDeclaration:
            try label(node.sourceAnchor, node.identifier)
            
        case let node as Subroutine:
            try label(node.sourceAnchor, node.identifier)
            for child in node.children {
                try innerCompile(child)
            }
            
        default:
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "unsupported node: `\(node.description)'")
        }
    }
    
    private func label(_ sourceAnchor: SourceAnchor?, _ name: String) throws {
        guard labels[name] == nil else {
            throw CompilerError(sourceAnchor: sourceAnchor, message: "label redefines existing symbol: `\(name)'")
        }
        labels[name] = instructions.count
    }
}
