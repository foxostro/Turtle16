//
//  AbstractSyntaxTreeNodeVisitor.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol AbstractSyntaxTreeNodeVisitor {
    func visit(node: InstructionNode) throws
    func visit(node: LabelDeclarationNode) throws
    func visit(node: ConstantDeclarationNode) throws
}
