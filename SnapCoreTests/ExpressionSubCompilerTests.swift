//
//  ExpressionSubCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ExpressionSubCompilerTests: XCTestCase {
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
    
    func makeComparisonEq(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "==", op: .eq), left: left, right: right)
    }
    
    func makeComparisonLt(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "<", op: .lt), left: left, right: right)
    }
    
    func makeIdentifier(name: String) -> Expression {
        return Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: name))
    }
    
    func makeAssignment(_ name: String, right: Expression) -> Expression {
        return Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: name), expression: right)
    }
    
    func compile(expression: Expression, symbols: SymbolTable = SymbolTable()) throws -> [YertleInstruction] {
        let compiler = ExpressionSubCompiler(symbols: symbols)
        let ir = try compiler.compile(expression: expression)
        return ir
    }
    
    func testCompileUnsupportedExpression() {
        XCTAssertEqual(try compile(expression: makeLiteral(value: 1)), [.push(1)])
        XCTAssertEqual(try compile(expression: makeLiteral(value: 2)), [.push(2)])
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
    
    func testCompileIdentifierExpression_UseOfLabelInExpression() {
        let expr = makeIdentifier(name: "foo")
        let symbols = SymbolTable(["foo" : .label(42)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .push(42)
        ])
    }
    
    func testCompileIdentifierExpression_Word_Constant() {
        let expr = makeIdentifier(name: "foo")
        let symbols = SymbolTable(["foo" : .word(.constantInt(42))])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .push(42)
        ])
    }
    
    func testCompileIdentifierExpression_Word_Static() {
        let expr = makeIdentifier(name: "foo")
        let symbols = SymbolTable(["foo" : .word(.staticStorage(address: 0x0010, isMutable: false))])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .load(0x0010)
        ])
    }
    
    func testCompileIdentifierExpression_UnresolvedIdentifier() {
        let expr = makeIdentifier(name: "foo")
        XCTAssertThrowsError(try compile(expression: expr)) {
            XCTAssertEqual(($0 as? CompilerError)?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testCompileAssignment() {
        let expr = makeAssignment("foo", right: makeLiteral(value: 42))
        let symbols = SymbolTable(["foo" : .word(.staticStorage(address: 0x0010, isMutable: true))])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .push(42),
            .store(0x0010)
        ])
    }
    
    func testCannotAssignToALabel() {
        let expr = makeAssignment("foo", right: makeLiteral(value: 42))
        let symbols = SymbolTable(["foo" : .label(0)])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to label `foo'")
        }
    }
    
    func testCannotAssignToAnImmutableValue() {
        let expr = makeAssignment("foo", right: makeLiteral(value: 42))
        let symbols = SymbolTable(["foo" : .word(.staticStorage(address: 0x0010, isMutable: false))])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to immutable variable `foo'")
        }
    }
    
    func testCannotAssignToAConstantValue() {
        let expr = makeAssignment("foo", right: makeLiteral(value: 42))
        let symbols = SymbolTable(["foo" : .word(.constantInt(0))])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to constant value `foo'")
        }
    }
    
    func testCompileComparisonEquals() {
        let expr = makeComparisonEq(left: makeLiteral(value: 2), right: makeLiteral(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(2),
            .eq
        ])
    }
    
    func testCompileComparisonLessThan() {
        let expr = makeComparisonLt(left: makeLiteral(value: 2), right: makeLiteral(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(2),
            .lt
        ])
    }
    
    func testCannotCompileUnsupportedExpression() {
        let expr = Expression.UnsupportedExpression()
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "unsupported expression: <UnsupportedExpression: children=[]>")
        }
    }
}
