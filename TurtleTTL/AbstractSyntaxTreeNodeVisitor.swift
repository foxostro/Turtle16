//
//  AbstractSyntaxTreeNodeVisitor.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol AbstractSyntaxTreeNodeVisitor {
    func visit(node: NOPNode) throws
    func visit(node: CMPNode) throws
    func visit(node: HLTNode) throws
    func visit(node: JMPToLabelNode) throws
    func visit(node: JMPToAddressNode) throws
    func visit(node: JCToLabelNode) throws
    func visit(node: JCToAddressNode) throws
    func visit(node: ADDNode) throws
    func visit(node: LINode) throws
    func visit(node: MOVNode) throws
    func visit(node: LabelDeclarationNode) throws
}
