//
//  SnapASTTransformerSymbolTables.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerSymbolTables: SnapASTTransformerBase {
    public override func transform(block node: Block) throws -> AbstractSyntaxTreeNode {
        let parent = symbols
        node.symbols.parent = parent
        node.symbols.enclosingFunctionType = nil // This type will be filled out later.
        node.symbols.enclosingFunctionName = parent?.enclosingFunctionName
        node.symbols.storagePointer = parent?.storagePointer ?? 0
        node.symbols.stackFrameIndex = parent?.stackFrameIndex ?? 0
        
        symbols = node.symbols
        let result = Block(sourceAnchor: node.sourceAnchor,
                           symbols: node.symbols,
                           children: try node.children.map { try transform($0) })
        symbols = parent
        return result
    }
    
    public override func transform(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode {
        let parent = symbols
        node.symbols.parent = parent
        node.symbols.enclosingFunctionType = nil // This type will be filled out later.
        node.symbols.enclosingFunctionName = node.identifier.identifier
        node.symbols.storagePointer = 0
        node.symbols.stackFrameIndex = (parent?.stackFrameIndex ?? 0) + 1
        symbols = node.symbols
        
        let body = Block(sourceAnchor: node.body.sourceAnchor,
                         symbols: node.symbols,
                         children: try node.body.children.map { try transform($0) })
        
        let result = FunctionDeclaration(sourceAnchor: node.sourceAnchor,
                                         identifier: node.identifier,
                                         functionType: node.functionType,
                                         argumentNames: node.argumentNames,
                                         body: body,
                                         visibility: node.visibility,
                                         symbols: node.symbols)
        symbols = parent
        return result
    }
}
