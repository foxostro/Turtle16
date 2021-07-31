//
//  SnapASTTransformerTopLevel.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerTopLevel: SnapASTTransformerBase {
    public override func transform(_ root: AbstractSyntaxTreeNode) throws -> AbstractSyntaxTreeNode {
        guard let topLevel = root as? TopLevel else {
            return root
        }
        let symbols = CompilerIntrinsicSymbolBinder().bindCompilerIntrinsics(symbols: SymbolTable())
        return Block(sourceAnchor: topLevel.sourceAnchor,
                     symbols: symbols,
                     children: topLevel.children)
    }
}
