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
    
    public override func compile(func node0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode {
        let subcompiler = SnapASTTransformerFunctionDeclaration(symbols!)
        let node1 = try subcompiler.compile(node0) as! FunctionDeclaration
        let node2 = try super.compile(func: node1)
        return node2
    }
    
    public override func compile(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapASTTransformerVarDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0) as! VarDeclaration
        let node2 = try super.compile(varDecl: node1)
        return node2
    }
}
