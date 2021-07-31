//
//  SnapASTTransformerAssertTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerAssertTests: XCTestCase {
    func testIgnoresUnrecognizedNodes() throws {
        let result = try? SnapASTTransformerAssert().transform(CommentNode(string: ""))
        XCTAssertEqual(result, CommentNode(string: ""))
    }
    
    func testTransformAssert_Bare() throws {
        let input = makeAssertFalse()
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = makeAssertFalseResult()
        XCTAssertEqual(result, expected)
    }
    
    fileprivate func makeAssertFalse() -> AbstractSyntaxTreeNode {
        return Assert(condition: Expression.LiteralBool(false), message: "false")
    }
    
    fileprivate func makeAssertFalseResult() -> AbstractSyntaxTreeNode {
        let panic = Expression.Call(callee: Expression.Identifier("panic"), arguments: [
            Expression.LiteralString("false")
        ])
        let condition = Expression.Binary(op: .eq,
                                          left: Expression.LiteralBool(false),
                                          right: Expression.LiteralBool(false))
        return If(condition: condition, then: Block(children: [panic]))
    }
    
    func testTransformAssert_InsideBlock() throws {
        let input = Block(children: [makeAssertFalse()])
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = Block(children: [makeAssertFalseResult()])
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideIf() throws {
        let input = If(condition: Expression.LiteralBool(true), then: makeAssertFalse())
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = If(condition: Expression.LiteralBool(true), then: makeAssertFalseResult())
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideElse() throws {
        let input = If(condition: Expression.LiteralBool(true), then: Block(), else: makeAssertFalse())
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = If(condition: Expression.LiteralBool(true), then: Block(), else: makeAssertFalseResult())
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideWhile() throws {
        let input = While(condition: Expression.LiteralBool(true), body: makeAssertFalse())
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = While(condition: Expression.LiteralBool(true), body: makeAssertFalseResult())
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideForIn() throws {
        let input = ForIn(identifier: Expression.Identifier(""),
                          sequenceExpr: Expression.LiteralBool(true),
                          body: Block(children: [makeAssertFalse()]))
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = ForIn(identifier: Expression.Identifier(""),
                             sequenceExpr: Expression.LiteralBool(true),
                             body: Block(children: [makeAssertFalseResult()]))
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideFunctionBody() throws {
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: [makeAssertFalse()]))
        
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [makeAssertFalseResult()]))
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideImpl() throws {
        let input = Impl(identifier: Expression.Identifier(""), children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                            functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                            argumentNames: [],
                                            body: Block(children: [makeAssertFalse()]))
        ])
        
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = Impl(identifier: Expression.Identifier(""), children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                            functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                            argumentNames: [],
                                            body: Block(children: [makeAssertFalseResult()]))
        ])
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideImplFor() throws {
        let input = ImplFor(traitIdentifier: Expression.Identifier("foo"), structIdentifier: Expression.Identifier("bar"), children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                            functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                            argumentNames: [],
                                            body: Block(children: [makeAssertFalse()]))
        ])
        
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = ImplFor(traitIdentifier: Expression.Identifier("foo"), structIdentifier: Expression.Identifier("bar"), children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                            functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                            argumentNames: [],
                                            body: Block(children: [makeAssertFalseResult()]))
        ])
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideMatchElse() throws {
        let input = Match(expr: Expression.LiteralBool(false),
                          clauses: [],
                          elseClause: Block(children: [makeAssertFalse()]))
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = Match(expr: Expression.LiteralBool(false),
                             clauses: [],
                             elseClause: Block(children: [makeAssertFalseResult()]))
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideMatchClause() throws {
        let input = Match(expr: Expression.LiteralBool(false),
                          clauses: [Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                                                 valueType: Expression.PrimitiveType(.u8),
                                                 block: Block(children: [makeAssertFalse()]))],
                          elseClause: nil)
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = Match(expr: Expression.LiteralBool(false),
                             clauses: [Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                                                    valueType: Expression.PrimitiveType(.u8),
                                                    block: Block(children: [makeAssertFalseResult()]))],
                             elseClause: nil)
        XCTAssertEqual(result, expected)
    }
    
    func testTransformAssert_InsideTest() throws {
        let input = TestDeclaration(name: "foo", body: Block(children: [makeAssertFalse()]))
        let result = try? SnapASTTransformerAssert().transform(input)
        let expected = TestDeclaration(name: "foo", body: Block(children: [
            If(condition: Expression.Binary(op: .eq,
                                            left: Expression.LiteralBool(false),
                                            right: Expression.LiteralBool(false)),
               then: Block(children: [
                Expression.Call(callee: Expression.Identifier("panic"), arguments: [
                    Expression.LiteralString("false in test \"foo\"")
                ])
            ]))
        ]))
        XCTAssertEqual(result, expected)
    }
}
