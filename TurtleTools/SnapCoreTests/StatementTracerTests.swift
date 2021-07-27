//
//  StatementTracerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class StatementTracerTests: XCTestCase {
    func testTraceSingleReturnStatement() {
        let tracer = StatementTracer()
        let one = Expression.LiteralInt(1)
        let traces = try! tracer.trace(ast: Return(one))
        XCTAssertEqual(traces[0], [.Return])
    }
    
    func testTraceBlockContainingSingleReturnStatement() {
        let tracer = StatementTracer()
        let one = Expression.LiteralInt(1)
        let traces = try! tracer.trace(ast: Block(children: [
            Return(one)
        ]))
        XCTAssertEqual(traces, [[.Return]])
    }
    
    func testThrowErrorWhenStatementAfterReturnInBlock() {
        let tracer = StatementTracer()
        let one = Expression.LiteralInt(1)
        let ast = Block(children: [
            Return(one),
            ExprUtils.makeAssignment(name: "foo", right: one)
        ])
        XCTAssertThrowsError(try tracer.trace(ast: ast)) {
            if let error = $0 as? CompilerError {
                XCTAssertEqual(error.message, "code after return will never be executed")
            } else {
                XCTFail()
            }
        }
    }
    
    func testTraceReturnStatementsThroughIf() {
        let tracer = StatementTracer()
        let tr = Expression.LiteralBool(true)
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        let traces = try! tracer.trace(ast: Block(children: [
            If(sourceAnchor: nil,
               condition: tr,
               then: Return(one),
               else: nil),
            Return(two)
        ]))
        XCTAssertEqual(traces[0], [.IfThen, .Return])
        XCTAssertEqual(traces[1], [.IfSkipped, .Return])
    }
    
    func testTraceReturnStatementsThroughElse() {
        let tracer = StatementTracer()
        let tr = Expression.LiteralBool(true)
        let one = Expression.LiteralInt(1)
        let traces = try! tracer.trace(ast: Block(children: [
            If(sourceAnchor: nil,
               condition: tr,
               then: Block(),
               else: Return(one))
        ]))
        XCTAssertEqual(traces.count, 2)
        XCTAssertEqual(traces[0], [.IfThen])
        XCTAssertEqual(traces[1], [.IfElse, .Return])
    }
    
    func testTraceReturnStatementsThroughWhile() {
        let tracer = StatementTracer()
        let tr = Expression.LiteralBool(true)
        let one = Expression.LiteralInt(1)
        let traces = try! tracer.trace(ast: Block(children: [
            While(sourceAnchor: nil,
                  condition: tr,
                  body: Return(one))
        ]))
        XCTAssertEqual(traces.count, 2)
        XCTAssertEqual(traces[0], [.LoopBody, .Return])
        XCTAssertEqual(traces[1], [.LoopSkipped])
    }
    
    func testTraceReturnStatementsThroughMatchClause() {
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        let three = Expression.LiteralInt(3)
        let ast = Block(children: [
            Match(expr: Expression.Identifier("test"), clauses: [
                Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                             valueType: Expression.PrimitiveType(.u8),
                             block: Block(children: [
                                Return(one)
                            ])),
                Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                             valueType: Expression.PrimitiveType(.bool),
                             block: Block(children: [
                                Return(two)
                            ]))
            ], elseClause: Block(children: [
                Return(three)
            ]))
        ])
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8, offset: 0, storage: .automaticStorage)),
            ("test", Symbol(type: .unionType(UnionType([.u8, .bool])), offset: 0, storage: .automaticStorage)),
        ])
        let tracer = StatementTracer(symbols: symbols)
        let traces = try! tracer.trace(ast: ast)
        XCTAssertEqual(traces.count, 3)
        XCTAssertEqual(traces[0], [.Statement("VarDeclaration"), .IfThen, .Statement("VarDeclaration"), .Return])
        XCTAssertEqual(traces[1], [.Statement("VarDeclaration"), .IfElse, .IfThen, .Statement("VarDeclaration"), .Return])
        XCTAssertEqual(traces[2], [.Statement("VarDeclaration"), .IfElse, .IfElse, .Return])
    }
}
