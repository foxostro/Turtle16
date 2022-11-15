//
//  TackFlattener.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/6/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

// Accepts a Tack AST and produces a TackProgram.
public class TackFlattener: NSObject {
    private var instructions: [(TackInstruction, SourceAnchor?, SymbolTable?, String?)] = []
    private var didProcessSubroutine = false
    private var labels: [String : Int] = [:]
    private var currentSubroutine: String? = nil
    
    public func compile(_ node: AbstractSyntaxTreeNode) throws -> TackProgram {
        try innerCompile(node)
        return TackProgram(
            instructions: instructions.map{$0.0},
            sourceAnchor: instructions.map{$0.1},
            symbols: instructions.map{$0.2},
            subroutines: instructions.map{$0.3},
            labels: labels,
            ast: node)
    }
    
    private func innerCompile(_ node: AbstractSyntaxTreeNode) throws {
        switch node {
        case let node as TackInstructionNode:
            instructions.append((
                node.instruction,
                node.sourceAnchor,
                node.symbols,
                currentSubroutine))
            
        case let node as Seq:
            for child in node.children {
                try innerCompile(child)
            }
            
        case let node as LabelDeclaration:
            try label(node.sourceAnchor, node.identifier)
            
        case let node as Subroutine:
            if !didProcessSubroutine {
                instructions.append((.hlt, nil, nil, nil))
            }
            currentSubroutine = node.identifier
            try label(node.sourceAnchor, node.identifier)
            for child in node.children {
                try innerCompile(child)
            }
            currentSubroutine = nil
            didProcessSubroutine = true
            
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
