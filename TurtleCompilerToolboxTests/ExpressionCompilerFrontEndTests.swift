//
//  ExpressionCompilerFrontEndTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class ExpressionCompilerFrontEndTests: XCTestCase {
    func makeLiteral(value: Int) -> Expression {
        return Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "\(value)", literal: value))
    }
    
    func makeAdd(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus), left: left, right: right)
    }
    
    func makeSub(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), left: left, right: right)
    }
    
    func makeMul(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply), left: left, right: right)
    }
    
    func makeDiv(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide), left: left, right: right)
    }
    
    func makeIdentifier(name: String) -> Expression {
        return Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: name))
    }
    
    func compile(expression: Expression, symbols: SymbolTable = SymbolTable()) throws -> [StackIR] {
        let compiler = ExpressionCompilerFrontEnd(symbols: symbols)
        let ir = try compiler.compile(expression: expression)
        return ir
    }
    
    func testCompileLiteralExpression() {
        XCTAssertEqual(try compile(expression: makeLiteral(value: 1)), [.push(1)])
        XCTAssertEqual(try compile(expression: makeLiteral(value: 2)), [.push(2)])
    }
    
    func testCompileBinaryExpression_Add_1() {
        let expr = makeAdd(left: makeLiteral(value: 1), right: makeLiteral(value: 2))
        XCTAssertEqual(try compile(expression: expr), [
            .push(2),
            .push(1),
            .add
        ])
    }
    
    func testCompileBinaryExpression_Add_2() {
        let expr = makeAdd(left: makeLiteral(value: 1),
                           right: makeAdd(left: makeLiteral(value: 2),
                                          right: makeLiteral(value: 3)))
        XCTAssertEqual(try compile(expression: expr), [
            .push(3),
            .push(2),
            .add,
            .push(1),
            .add
        ])
    }
    
    func testCompileBinaryExpression_Subtract() {
        let expr = makeSub(left: makeLiteral(value: 2), right: makeLiteral(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(2),
            .sub
        ])
    }
    
    func testCompileBinaryExpression_Multiply() {
        let expr = makeMul(left: makeLiteral(value: 2), right: makeLiteral(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(2),
            .mul
        ])
    }
    
    func testCompileBinaryExpression_Divide() {
        let expr = makeDiv(left: makeLiteral(value: 1), right: makeLiteral(value: 2))
        XCTAssertEqual(try compile(expression: expr), [
            .push(2),
            .push(1),
            .div
        ])
    }
    
    func testCompileIdentifierExpression_ValueIsKnownAtCompileTime() {
        let expr = makeIdentifier(name: "foo")
        XCTAssertEqual(try compile(expression: expr, symbols: ["foo" : 42]), [
            .push(42)
        ])
    }
    
    func testCompileIdentifierExpression_UnresolvedIdentifier() {
        let expr = makeIdentifier(name: "foo")
        XCTAssertThrowsError(try compile(expression: expr)) {
            XCTAssertNotNil($0 as? Expression.MustBeCompileTimeConstantError)
        }
    }
}
