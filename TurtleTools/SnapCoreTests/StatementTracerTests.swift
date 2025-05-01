//
//  StatementTracerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class StatementTracerTests: XCTestCase {
    func testTraceSingleReturnStatement() {
        let tracer = StatementTracer()
        let one = LiteralInt(1)
        let traces = try! tracer.trace(ast: Return(one))
        XCTAssertEqual(traces[0], [.Return])
    }

    func testTraceBlockContainingSingleReturnStatement() {
        let tracer = StatementTracer()
        let one = LiteralInt(1)
        let traces = try! tracer.trace(
            ast: Block(children: [
                Return(one)
            ])
        )
        XCTAssertEqual(traces, [[.Return]])
    }

    func testThrowErrorWhenStatementAfterReturnInBlock() {
        let tracer = StatementTracer()
        let one = LiteralInt(1)
        let ast = Block(children: [
            Return(one),
            ExprUtils.makeAssignment(name: "foo", right: one),
        ])
        XCTAssertThrowsError(try tracer.trace(ast: ast)) {
            if let error = $0 as? CompilerError {
                XCTAssertEqual(error.message, "code after return will never be executed")
            }
            else {
                XCTFail()
            }
        }
    }

    func testTraceReturnStatementsThroughIf() {
        let tracer = StatementTracer()
        let tr = LiteralBool(true)
        let one = LiteralInt(1)
        let two = LiteralInt(2)
        let traces = try! tracer.trace(
            ast: Block(children: [
                If(
                    sourceAnchor: nil,
                    condition: tr,
                    then: Return(one),
                    else: nil
                ),
                Return(two),
            ])
        )
        XCTAssertEqual(traces[0], [.IfThen, .Return])
        XCTAssertEqual(traces[1], [.IfSkipped, .Return])
    }

    func testTraceReturnStatementsThroughElse() {
        let tracer = StatementTracer()
        let tr = LiteralBool(true)
        let one = LiteralInt(1)
        let traces = try! tracer.trace(
            ast: Block(children: [
                If(
                    sourceAnchor: nil,
                    condition: tr,
                    then: Block(),
                    else: Return(one)
                )
            ])
        )
        XCTAssertEqual(traces.count, 2)
        XCTAssertEqual(traces[0], [.IfThen])
        XCTAssertEqual(traces[1], [.IfElse, .Return])
    }

    func testTraceReturnStatementsThroughWhile() {
        let tracer = StatementTracer()
        let tr = LiteralBool(true)
        let one = LiteralInt(1)
        let traces = try! tracer.trace(
            ast: Block(children: [
                While(
                    sourceAnchor: nil,
                    condition: tr,
                    body: Return(one)
                )
            ])
        )
        XCTAssertEqual(traces.count, 2)
        XCTAssertEqual(traces[0], [.LoopBody, .Return])
        XCTAssertEqual(traces[1], [.LoopSkipped])
    }

    func testTraceReturnStatementsThroughMatchClause() throws {
        let one = LiteralInt(1)
        let two = LiteralInt(2)
        let three = LiteralInt(3)
        let ast = Block(children: [
            Match(
                expr: Identifier("test"),
                clauses: [
                    Match.Clause(
                        valueIdentifier: Identifier("foo"),
                        valueType: PrimitiveType(.u8),
                        block: Block(children: [
                            Return(one)
                        ])
                    ),
                    Match.Clause(
                        valueIdentifier: Identifier("foo"),
                        valueType: PrimitiveType(.bool),
                        block: Block(children: [
                            Return(two)
                        ])
                    ),
                ],
                elseClause: Block(children: [
                    Return(three)
                ])
            )
        ])
        let symbols = Env()
        let tracer = StatementTracer(symbols: symbols)
        let traces = try tracer.trace(ast: ast)
        XCTAssertEqual(traces.count, 3)
        XCTAssertEqual(traces[0], [.matchClause, .Return])
        XCTAssertEqual(traces[1], [.matchClause, .Return])
        XCTAssertEqual(traces[2], [.matchElseClause, .Return])
    }
}
