//
//  SnapASTTransformerTestDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerTestDeclaration: SnapASTTransformerBase {
    public private(set) var testNames: [String] = []
    public private(set) var testDeclarations: [TestDeclaration] = []
    public let isUsingStandardLibrary: Bool
    var currentTest: TestDeclaration? = nil
    var depth = 0
    let shouldRunSpecificTest: String?
    
    public init(shouldRunSpecificTest: String? = nil, isUsingStandardLibrary: Bool = false) {
        self.shouldRunSpecificTest = shouldRunSpecificTest
        self.isUsingStandardLibrary = isUsingStandardLibrary
    }
    
    public override func compile(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        let globalSymbols = CompilerIntrinsicSymbolBinder().bindCompilerIntrinsics(symbols: SymbolTable())
        var children = node.children
        if isUsingStandardLibrary {
            let importStmt = Import(moduleName: kStandardLibraryModuleName)
            children.insert(importStmt, at: 0)
        }
        let block = Block(sourceAnchor: node.sourceAnchor,
                          symbols: globalSymbols,
                          children: children)
        return try compile(block: block)
    }
    
    public override func compile(block node: Block) throws -> AbstractSyntaxTreeNode? {
        depth += 1
        let result = try super.compile(block: node) as! Block
        depth -= 1
        
        if depth == 0 {
            var children = result.children
            
            if let testName = shouldRunSpecificTest,
               let testDeclaration = testDeclarations.first(where: { $0.name == testName }) {
                let testRunnerMain = FunctionDeclaration(identifier: Expression.Identifier(kTestMainFunctionName), functionType: Expression.FunctionType(name: kTestMainFunctionName, returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: [
                    testDeclaration.body,
                    Expression.Call(callee: Expression.Identifier("puts"), arguments: [Expression.LiteralString("passed\n")])
                ]))
                children += [
                    testRunnerMain,
                    Expression.Call(callee: Expression.Identifier(kTestMainFunctionName), arguments: [])
                ]
            } else {
                let hasMain = result.children.first(where: {
                    if let functionDeclaration = $0 as? FunctionDeclaration,
                       functionDeclaration.identifier.identifier == kMainFunctionName {
                        return true
                    }
                    return false
                }) != nil
                if hasMain {
                    children += [
                        Expression.Call(callee: Expression.Identifier(kMainFunctionName), arguments: [])
                    ]
                }
            }
            
            let result = Block(sourceAnchor: result.sourceAnchor,
                               symbols: result.symbols,
                               children: children)
            return result
        }
            
        return result
    }
    
    public override func compile(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        guard depth <= 1 else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "declaration is only valid at file scope")
        }
        
        guard testNames.contains(node.name) == false else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "test \"\(node.name)\" already exists")
        }
        
        currentTest = node
        defer { currentTest = nil }
        
        let modifiedNode = try super.compile(testDecl: node) as! TestDeclaration
        
        testNames.append(modifiedNode.name)
        testDeclarations.append(modifiedNode)
        
        return nil // Erase TestDeclaration at this point.
    }
    
    public override func compile(assert node: Assert) throws -> AbstractSyntaxTreeNode {
        return Assert(sourceAnchor: node.sourceAnchor,
                      condition: node.condition,
                      message: node.message,
                      enclosingTestName: currentTest?.name)
    }
}