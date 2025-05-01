//
//  CompilerPassTestDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public final class CompilerPassTestDeclaration: CompilerPass {
    public private(set) var testNames: [String] = []
    public private(set) var testDeclarations: [TestDeclaration] = []
    var currentTest: TestDeclaration? = nil
    var depth = 0
    let shouldRunSpecificTest: String?

    public init(shouldRunSpecificTest: String? = nil) {
        self.shouldRunSpecificTest = shouldRunSpecificTest
    }

    public override func visit(block node: Block) throws -> AbstractSyntaxTreeNode? {
        depth += 1
        let result = try super.visit(block: node) as! Block
        depth -= 1

        if depth == 0 {
            var children = result.children

            if let testName = shouldRunSpecificTest,
                let testDeclaration = testDeclarations.first(where: { $0.name == testName })
            {
                let fnSymbols = Env(parent: result.symbols)
                let bodySymbols = Env(parent: fnSymbols)
                testDeclaration.body.symbols.parent = bodySymbols
                let body = Block(
                    symbols: bodySymbols,
                    children: [
                        testDeclaration.body,
                        Call(callee: Identifier("__puts"), arguments: [LiteralString("passed\n")]),
                    ]
                )
                let testRunnerMain = FunctionDeclaration(
                    identifier: Identifier(kTestMainFunctionName),
                    functionType: FunctionType(
                        name: kTestMainFunctionName,
                        returnType: PrimitiveType(.void),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: body,
                    symbols: fnSymbols
                )
                children += [
                    testRunnerMain,
                    Call(callee: Identifier(kTestMainFunctionName), arguments: []),
                ]
            } else {
                let hasMain =
                    result.children.first(where: {
                        if let functionDeclaration = $0 as? FunctionDeclaration,
                            functionDeclaration.identifier.identifier == kMainFunctionName
                        {
                            return true
                        }
                        return false
                    }) != nil
                if hasMain {
                    children += [
                        Call(callee: Identifier(kMainFunctionName), arguments: [])
                    ]
                }
            }

            let result1 = Block(
                sourceAnchor: result.sourceAnchor,
                symbols: result.symbols,
                children: children
            )
            .reconnect(parent: result.symbols.parent)

            return result1
        }

        return result
    }

    public override func visit(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        guard depth <= 1 else {
            throw CompilerError(
                sourceAnchor: node.sourceAnchor,
                message: "declaration is only valid at file scope"
            )
        }

        guard testNames.contains(node.name) == false else {
            throw CompilerError(
                sourceAnchor: node.sourceAnchor,
                message: "test \"\(node.name)\" already exists"
            )
        }

        currentTest = node
        defer { currentTest = nil }

        let modifiedNode = try super.visit(testDecl: node) as! TestDeclaration

        testNames.append(modifiedNode.name)
        testDeclarations.append(modifiedNode)

        return nil  // Erase TestDeclaration at this point.
    }

    public override func visit(assert node: Assert) throws -> AbstractSyntaxTreeNode {
        node.withEnclosingTestName(currentTest?.name)
    }
}

extension AbstractSyntaxTreeNode {
    /// Erase test declarations and replace with a synthesized test runner.
    public func desugarTestDeclarations(
        testNames: inout [String],
        shouldRunSpecificTest: String?
    ) throws -> AbstractSyntaxTreeNode? {
        let compiler = CompilerPassTestDeclaration(shouldRunSpecificTest: shouldRunSpecificTest)
        let result = try compiler.run(self)
        testNames = compiler.testNames
        return result
    }
}
