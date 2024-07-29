//
//  SnapAbstractSyntaxTreeCompilerImplPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiles an Abstract Syntax Tree to another, simpler AST and symbol table.
// Accepts an AST and walks the tree. For each matched node, it may rewrite
// that node in terms of simpler concepts, and it may update the symbol table
// to record additional information derived from the program.
//
// SnapAbstractSyntaxTreeCompilerImplPass delegates most the specific work to
// various subcompilers classes.
public class SnapAbstractSyntaxTreeCompilerImplPass: CompilerPass {
    public let globalEnvironment: GlobalEnvironment
    
    public init(symbols: SymbolTable? = nil,
                globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func visit(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        try RvalueExpressionTypeChecker(symbols: symbols!, globalEnvironment: globalEnvironment).check(expression: node)
        return node
    }
    
    public override func visit(assert node0: Assert) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerAssert().compile(symbols, node0)
        let node2 = try super.visit(node1)
        return node2
    }
    
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerVarDeclaration(symbols: symbols!, globalEnvironment: globalEnvironment)
        let node1 = try subcompiler.compile(node0)
        return node1
    }
    
    public override func visit(forIn node0: ForIn) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerForIn(symbols!).compile(node0)
        let node2 = try visit(block: node1)
        return node2
    }
    
    public override func visit(match node0: Match) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerMatch(
            memoryLayoutStrategy: globalEnvironment.memoryLayoutStrategy,
            symbols: symbols!)
        .compile(node0)
        
        let node2 = try super.visit(node1)
        return node2
    }
    
    public override func visit(return node0: Return) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerReturn(symbols!)
        let node1 = try subcompiler.compile(node0)
        return node1
    }
    
    public override func visit(if node0: If) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerIf().compile(
            if: node0,
            symbols: symbols!,
            labelMaker: globalEnvironment.labelMaker)
        let node2 = try super.visit(node1)
        return node2
    }
    
    public override func visit(while node0: While) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerWhile().compile(
            while: node0,
            symbols: symbols!,
            labelMaker: globalEnvironment.labelMaker)
        let node2 = try super.visit(node1)
        return node2
    }
    
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        // We defer compilation of the function body until later.
        return node
    }
}
