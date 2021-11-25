//
//  SnapSubcompilerSubroutine.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/24/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import Turtle16SimulatorCore

public class SnapSubcompilerSubroutine: SnapASTTransformerBase {
    var subroutines: [Subroutine] = []
    
    public override func compile(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        var children: [AbstractSyntaxTreeNode] = try node.children.compactMap { try compile($0) }
        if children.count == 1 {
            children += [
                InstructionNode(instruction: kHLT)
            ]
        } else {
            if subroutines.count == 0 {
                children += [
                    InstructionNode(instruction: kNOP),
                    InstructionNode(instruction: kHLT)
                ]
            }
            children += subroutines.flatMap { $0.children }
        }
        
        return TopLevel(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    public override func compile(subroutine node: Subroutine) throws -> AbstractSyntaxTreeNode? {
        subroutines.append(node)
        return nil
    }
}
