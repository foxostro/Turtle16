//
//  ExpressionTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ExpressionTypeCheckerTests: XCTestCase {
    func makeLiteralWord(value: Int) -> Expression {
        return Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "\(value)", literal: value))
    }
    
    func makeLiteralBoolean(value: Bool) -> Expression {
        return Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "\(value)", literal: value))
    }
    
    func testUnsupportedExpressionThrows() {
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: Expression.UnsupportedExpression())) {
            var error: CompilerError? = nil
            XCTAssertNotNil(error = $0 as? CompilerError)
            XCTAssertEqual(error?.message, "unsupported expression: <UnsupportedExpression: children=[]>")
        }
    }
    
    func testTypeOfALiteralWordIsWord() {
        let typeChecker = ExpressionTypeChecker()
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: makeLiteralWord(value: 1)))
        XCTAssertEqual(result, .word)
    }
    
    func testTypeOfALiteralBooleanIsBoolean() {
        let typeChecker = ExpressionTypeChecker()
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: makeLiteralBoolean(value: true)))
        XCTAssertEqual(result, .boolean)
    }
    
    func testExpressionUsesInvalidUnaryPrefixOperator() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                    expression: ExprUtils.makeLiteralWord(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`*' is not a prefix unary operator")
        }
    }
    
    func testUnaryNegationOfWordIsWord() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testUnaryNegationOfBooleanIsInvalid() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `-' cannot be applied to an operand of type `boolean'")
        }
    }
    
    func testBinaryWithMismatchedOperandTypes() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralWord(value: 1),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `+' cannot be applied to operands of types `word' and `boolean'")
        }
    }
    
    func testBinary_Eq_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralWord(value: 1),
                                              right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Eq_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: true),
                                              right: ExprUtils.makeLiteralBoolean(value: true))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Ne_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralWord(value: 1),
                                              right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Ne_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: true),
                                              right: ExprUtils.makeLiteralBoolean(value: true))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Lt_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralWord(value: 1),
                                              right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Lt_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralBoolean(value: true),
                                              right: ExprUtils.makeLiteralBoolean(value: true))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `<' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Gt_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralWord(value: 1),
                                              right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Gt_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralBoolean(value: true),
                                              right: ExprUtils.makeLiteralBoolean(value: true))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `>' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Le_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralWord(value: 1),
                                              right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Le_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralBoolean(value: true),
                                              right: ExprUtils.makeLiteralBoolean(value: true))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `<=' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Ge_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralWord(value: 1),
                                              right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testBinary_Ge_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralBoolean(value: true),
                                              right: ExprUtils.makeLiteralBoolean(value: true))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `>=' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Plus_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralWord(value: 1),
                                     right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testBinary_Plus_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `+' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Minus_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralWord(value: 1),
                                     right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testBinary_Minus_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `-' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Multiply_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralWord(value: 1),
                                     right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testBinary_Multiply_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `*' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Divide_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralWord(value: 1),
                                     right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testBinary_Divide_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `/' cannot be applied to two `boolean' operands")
        }
    }
    
    func testBinary_Modulus_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralWord(value: 1),
                                     right: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testBinary_Modulus_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1,  lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `%' cannot be applied to two `boolean' operands")
        }
    }
    
    func testAssignment_Word() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralWord(value: 1))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testAssignment_Boolean() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralBoolean(value: false))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testIdentifier_Word() {
        let symbols = SymbolTable(["foo" : .word(.constant(0))])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .word)
    }
    
    func testIdentifier_Boolean() {
        let symbols = SymbolTable(["foo" : .boolean(.constant(true))])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        var result: ExpressionTypeChecker.ExpressionType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .boolean)
    }
    
    func testIdentifier_Label() {
        let symbols = SymbolTable(["foo" : .label(0)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "label `foo' cannot be used in an expression")
        }
    }
    
    func testFailBecauseAdditionCannotBeAppliedToBooleanAndWord() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                     right: ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralWord(value: 1),
                                                                       right: ExprUtils.makeLiteralWord(value: 1)))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Binary operator `+' cannot be applied to operands of types `word' and `boolean'")
        }
    }
}
