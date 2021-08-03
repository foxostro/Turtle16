//
//  SnapAbstractSyntaxTreeCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapAbstractSyntaxTreeCompiler: SnapASTTransformerBase {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable? = nil) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        super.init(symbols)
    }
    
    public override func compile(varDecl node: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapASTTransformerVarDeclaration(memoryLayoutStrategy: memoryLayoutStrategy,
                                                           symbols: symbols!)
        return try subcompiler.compile(node)
    }
}
