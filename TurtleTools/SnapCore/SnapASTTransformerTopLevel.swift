//
//  SnapASTTransformerTopLevel.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerTopLevel: NSObject {
    public func transform(_ root: AbstractSyntaxTreeNode) -> AbstractSyntaxTreeNode {
        guard let topLevel = root as? TopLevel else {
            return root
        }
        return Block(sourceAnchor: topLevel.sourceAnchor,
                     children: topLevel.children)
    }
}
