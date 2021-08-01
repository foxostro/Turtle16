//
//  SnapASTTransformerTestDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerTestDeclarationTests: XCTestCase {
    func testTestDeclarationMustBeAtFileScope() {
        let original = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("puts"), functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [Expression.DynamicArrayType(Expression.PrimitiveType(.u8))]), argumentNames: ["s"], body: Block(children: [])),
            TestDeclaration(name: "bar", body: Block(children: [
                TestDeclaration(name: "baz", body: Block(children: [
                    Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                          rexpr: Expression.LiteralInt(42))
                ]))
            ]))
        ])
        
        // It's super annoying to connect symbol table chains by hand. Do it automatically.
        let modified = try! SnapASTTransformerSymbolTables().transform(original) as! Block
        
        let transformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: "bar")
        XCTAssertThrowsError(try transformer.transform(modified)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "declaration is only valid at file scope")
        }
    }
    
    func testTestDeclarationsMustHaveUniqueName() {
        let original = Block(children: [
            FunctionDeclaration(identifier: Expression.Identifier("puts"), functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [Expression.DynamicArrayType(Expression.PrimitiveType(.u8))]), argumentNames: ["s"], body: Block(children: [])),
            TestDeclaration(name: "bar", body: Block(children: [])),
            TestDeclaration(name: "bar", body: Block(children: []))
        ])
        
        // It's super annoying to connect symbol table chains by hand. Do it automatically.
        let modified = try! SnapASTTransformerSymbolTables().transform(original) as! Block
        
        let transformer = SnapASTTransformerTestDeclaration()
        XCTAssertThrowsError(try transformer.transform(modified)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "test \"bar\" already exists")
        }
    }
    
    func testTestsDisappearWhenNotBuildingForTesting() {
        let input = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            TestDeclaration(name: "bar", body: Block(children: []))
        ])
        let expected = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true)
        ])
        
        let transformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: nil)
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.transform(input))
        
        XCTAssertEqual(actual, expected)
    }
    
    func testCallMainFunctionWhenNotBuildingForTesting() {
        let input = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            TestDeclaration(name: "bar", body: Block(children: [])),
            FunctionDeclaration(identifier: Expression.Identifier("main"), functionType: Expression.FunctionType(name: "main", returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: []))
        ])
        let expected = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("main"), functionType: Expression.FunctionType(name: "main", returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: [])),
            Expression.Call(callee: Expression.Identifier("main"), arguments: [])
        ])
        
        let transformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: nil)
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.transform(input))
        
        XCTAssertEqual(actual, expected)
    }
    
    func testTheTestRunnerContainsTheTestBody() {
        let input = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            TestDeclaration(name: "bar", body: Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                      rexpr: Expression.LiteralInt(42))
            ]))
        ])
        let expected = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("__testMain"), functionType: Expression.FunctionType(name: "__testMain", returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: [
                Block(children: [
                    Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                          rexpr: Expression.LiteralInt(42))
                ]),
                Expression.Call(callee: Expression.Identifier("puts"), arguments: [Expression.LiteralString("passed\n")])
            ])),
            Expression.Call(callee: Expression.Identifier("__testMain"), arguments: [])
        ])
        
        let transformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: "bar")
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.transform(input))
        
        XCTAssertEqual(actual, expected)
    }
    
    func testTheTestRunnerContainsTheTestBodyOfSpecificTest() {
        let input = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            TestDeclaration(name: "bar", body: Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                      rexpr: Expression.LiteralInt(42))
            ])),
            TestDeclaration(name: "baz", body: Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                      rexpr: Expression.LiteralInt(41))
            ]))
        ])
        let expected = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("__testMain"), functionType: Expression.FunctionType(name: "__testMain", returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: [
                Block(children: [
                    Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                          rexpr: Expression.LiteralInt(42))
                ]),
                Expression.Call(callee: Expression.Identifier("puts"), arguments: [Expression.LiteralString("passed\n")])
            ])),
            Expression.Call(callee: Expression.Identifier("__testMain"), arguments: [])
        ])
        
        let transformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: "bar")
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.transform(input))
        
        XCTAssertEqual(actual, expected)
    }
    
    func testDuringTestingCallTestMainNotActualMain() {
        let input = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            TestDeclaration(name: "bar", body: Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                      rexpr: Expression.LiteralInt(42))
            ])),
            TestDeclaration(name: "baz", body: Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                      rexpr: Expression.LiteralInt(41))
            ])),
            FunctionDeclaration(identifier: Expression.Identifier("main"), functionType: Expression.FunctionType(name: "main", returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: []))
        ])
        let expected = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("main"), functionType: Expression.FunctionType(name: "main", returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: [])),
            FunctionDeclaration(identifier: Expression.Identifier("__testMain"), functionType: Expression.FunctionType(name: "__testMain", returnType: Expression.PrimitiveType(.void), arguments: []), argumentNames: [], body: Block(children: [
                Block(children: [
                    Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                          rexpr: Expression.LiteralInt(42))
                ]),
                Expression.Call(callee: Expression.Identifier("puts"), arguments: [Expression.LiteralString("passed\n")])
            ])),
            Expression.Call(callee: Expression.Identifier("__testMain"), arguments: [])
        ])
        
        let transformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: "bar")
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.transform(input))
        
        XCTAssertEqual(actual, expected)
    }
}
