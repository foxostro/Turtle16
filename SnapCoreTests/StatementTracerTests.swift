//
//  StatementTracerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class StatementTracerTests: XCTestCase {
    func testTraceSingleReturnStatement() {
        let tracer = StatementTracer()
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let traces = try! tracer.trace(ast: Return(sourceAnchor: nil, expression: one))
        XCTAssertEqual(traces[0], [.Return])
    }
    
    func testTraceBlockContainingSingleReturnStatement() {
        let tracer = StatementTracer()
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let traces = try! tracer.trace(ast: Block(sourceAnchor: nil, children: [
            Return(sourceAnchor: nil, expression: one)
        ]))
        XCTAssertEqual(traces, [[.Return]])
    }
    
    func testThrowErrorWhenStatementAfterReturnInBlock() {
        let tracer = StatementTracer()
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let ast = Block(sourceAnchor: nil, children: [
            Return(sourceAnchor: nil, expression: one),
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
        let tr = Expression.LiteralBoolean(sourceAnchor: nil, value: true)
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let two = Expression.LiteralWord(sourceAnchor: nil, value: 2)
        let traces = try! tracer.trace(ast: Block(sourceAnchor: nil, children: [
            If(sourceAnchor: nil,
               condition: tr,
               then: Return(sourceAnchor: nil, expression: one),
               else: nil),
            Return(sourceAnchor: nil, expression: two)
        ]))
        XCTAssertEqual(traces[0], [.IfThen, .Return])
        XCTAssertEqual(traces[1], [.IfSkipped, .Return])
    }
    
    func testTraceReturnStatementsThroughElse() {
        let tracer = StatementTracer()
        let tr = Expression.LiteralBoolean(sourceAnchor: nil, value: true)
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let traces = try! tracer.trace(ast: Block(sourceAnchor: nil, children: [
            If(sourceAnchor: nil,
               condition: tr,
               then: Block(sourceAnchor: nil, children: []),
               else: Return(sourceAnchor: nil, expression: one))
        ]))
        XCTAssertEqual(traces.count, 2)
        XCTAssertEqual(traces[0], [.IfThen])
        XCTAssertEqual(traces[1], [.IfElse, .Return])
    }
    
    func testTraceReturnStatementsThroughWhile() {
        let tracer = StatementTracer()
        let tr = Expression.LiteralBoolean(sourceAnchor: nil, value: true)
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let traces = try! tracer.trace(ast: Block(sourceAnchor: nil, children: [
            While(sourceAnchor: nil,
                  condition: tr,
                  body: Return(sourceAnchor: nil, expression: one))
        ]))
        XCTAssertEqual(traces.count, 2)
        XCTAssertEqual(traces[0], [.LoopBody, .Return])
        XCTAssertEqual(traces[1], [.LoopSkipped])
    }
    
    func testTraceReturnStatementsThroughForLoop() {
        let tracer = StatementTracer()
        let tr = Expression.LiteralBoolean(sourceAnchor: nil, value: true)
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let traces = try! tracer.trace(ast: Block(sourceAnchor: nil, children: [
            ForLoop(sourceAnchor: nil,
                    initializerClause: AbstractSyntaxTreeNode(sourceAnchor: nil),
                    conditionClause: tr,
                    incrementClause: AbstractSyntaxTreeNode(sourceAnchor: nil),
                    body: Return(sourceAnchor: nil, expression: one))
        ]))
        XCTAssertEqual(traces.count, 2)
        XCTAssertEqual(traces[0], [.LoopBody, .Return])
        XCTAssertEqual(traces[1], [.LoopSkipped])
    }
}
