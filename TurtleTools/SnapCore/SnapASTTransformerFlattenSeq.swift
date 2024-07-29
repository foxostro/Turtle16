//
//  SnapASTTransformerFlattenSeq.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/27/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerFlattenSeq: CompilerPass {
    public override func visit(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        let flatChildren = flatten(node.children)
        return TopLevel(sourceAnchor: node.sourceAnchor, children: flatChildren)
    }
    
    public override func visit(subroutine node: Subroutine) throws -> AbstractSyntaxTreeNode? {
        let flatChildren = flatten(node.children)
        return Subroutine(sourceAnchor: node.sourceAnchor, identifier: node.identifier, children: flatChildren)
    }
    
    public override func visit(seq node: Seq) throws -> AbstractSyntaxTreeNode? {
        let flatChildren = flatten(node.children)
        if flatChildren.count < 2 {
            return flatChildren.first
        } else {
            return Seq(sourceAnchor: node.sourceAnchor, children: flatChildren)
        }
    }
    
    public override func visit(block node: Block) throws -> AbstractSyntaxTreeNode? {
        let flatChildren = flatten(node.children)
        return Block(sourceAnchor: node.sourceAnchor,
                     symbols: node.symbols,
                     children: flatChildren)
    }
    
    func flatten(_ children0: [AbstractSyntaxTreeNode]) -> [AbstractSyntaxTreeNode] {
        let children1: [AbstractSyntaxTreeNode] = try! children0.compactMap { try visit($0) }
        var children2: [AbstractSyntaxTreeNode] = []
        for node in children1 {
            if let seq = node as? Seq {
                children2 += seq.children
            } else {
                children2.append(node)
            }
        }
        return children2
    }
}
