//
//  SnapSubcompilerSubroutine.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/24/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public final class SnapSubcompilerSubroutine: CompilerPass {
    var subroutines: [Subroutine] = []
    
    public override func visit(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        var children: [AbstractSyntaxTreeNode] = try node.children.compactMap { try visit($0) }
        
        children += [
            InstructionNode(instruction: kNOP),
            InstructionNode(instruction: kHLT)
        ]
        
        for subroutine in subroutines {
            children.append(LabelDeclaration(identifier: subroutine.identifier))
            children += subroutine.children
        }
        
        return node.withChildren(children)
    }
    
    public override func visit(subroutine node: Subroutine) throws -> AbstractSyntaxTreeNode? {
        subroutines.append(node)
        return nil
    }
}
