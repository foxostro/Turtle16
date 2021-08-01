//
//  SnapASTTransformerTestDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerTestDeclaration: SnapASTTransformerBase {
    public var depth = 0
    public private(set) var testNames: [String] = []
    public private(set) var testDeclarations: [TestDeclaration] = []
    let shouldRunSpecificTest: String?
    
    public init(shouldRunSpecificTest: String? = nil) {
        self.shouldRunSpecificTest = shouldRunSpecificTest
    }
    
    public override func transform(block node: Block) throws -> AbstractSyntaxTreeNode {
        depth += 1
        let result = try super.transform(block: node) as! Block
        depth -= 1
        
        if depth == 0 {
            if let testName = shouldRunSpecificTest,
               let testDeclaration = testDeclarations.first(where: { $0.name == testName }) {
                let testRunnerMain = FunctionDeclaration(identifier: Expression.Identifier(kTestMainFunctionName), functionType: Expression.FunctionType(name: kTestMainFunctionName, returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: [
                    testDeclaration.body,
                    Expression.Call(callee: Expression.Identifier("puts"), arguments: [Expression.LiteralString("passed\n")])
                ]))
                var children = result.children
                children += [
                    testRunnerMain,
                    Expression.Call(callee: Expression.Identifier(kTestMainFunctionName), arguments: [])
                ]
                return Block(sourceAnchor: result.sourceAnchor,
                             symbols: result.symbols,
                             children: children)
            } else {
                let hasMain = result.children.first(where: {
                    if let functionDeclaration = $0 as? FunctionDeclaration,
                       functionDeclaration.identifier.identifier == kMainFunctionName {
                        return true
                    }
                    return false
                }) != nil
                var children = result.children
                if hasMain {
                    children += [
                        Expression.Call(callee: Expression.Identifier(kMainFunctionName), arguments: [])
                    ]
                }
                return Block(sourceAnchor: result.sourceAnchor,
                             symbols: result.symbols,
                             children: children)
            }
        }
            
        return result
    }
    
    public override func transform(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        guard depth <= 1 else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "declaration is only valid at file scope")
        }
        
        guard testNames.contains(node.name) == false else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "test \"\(node.name)\" already exists")
        }
        
        testNames.append(node.name)
        testDeclarations.append(node)
        
        let _ = try super.transform(testDecl: node)
        
        return nil
    }
}
