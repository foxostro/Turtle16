//
//  CompilerPassClearSymbols.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/1/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

// Snap compiler pass to erase symbols from the AST
public class CompilerPassClearSymbols: CompilerPass {
    public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
        let block1 = try super.visit(block: block0) as! Block
        block1.symbols.clear()
        return block1
    }
    
    public override func visit(func func0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let func1 = try super.visit(func: func0) as! FunctionDeclaration
        func1.symbols.clear()
        return func1
    }
}

extension AbstractSyntaxTreeNode {
    /// Clear all symbols from the AST and reconnect all symbol tables, lexically
    public func clearSymbols(_ globalEnvironment: GlobalEnvironment? = nil) throws -> AbstractSyntaxTreeNode? {
        let result = try CompilerPassClearSymbols().run(self)
        
        if let globalEnvironment {
            globalEnvironment.staticStorageFrame.reset()
            globalEnvironment.functionsToCompile.removeAll()
        }
        
        return result
    }
}
