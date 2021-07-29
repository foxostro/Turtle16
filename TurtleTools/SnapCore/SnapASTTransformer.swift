//
//  SnapASTTransformer.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformer: NSObject {
    public private(set) var ast: Block = Block()
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool {
        !errors.isEmpty
    }
    
    public func transform(_ root: AbstractSyntaxTreeNode) {
        do {
            try tryTransform(root)
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    public func tryTransform(_ t0: AbstractSyntaxTreeNode) throws {
        let t1 = SnapASTTransformerTopLevel().transform(t0)
        guard let topLevel = t1 as? Block else {
            throw CompilerError(sourceAnchor: t0.sourceAnchor, message: "expected Block at root of tree after AST transformation")
        }
        ast = topLevel
    }
}
