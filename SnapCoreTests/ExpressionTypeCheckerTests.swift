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
    func testUnsupportedExpressionThrows() {
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: Expression.UnsupportedExpression())) {
            var error: CompilerError? = nil
            XCTAssertNotNil(error = $0 as? CompilerError)
            XCTAssertEqual(error?.message, "unsupported expression: <UnsupportedExpression>")
        }
    }
    
    func testEveryIntegerLiteralIsAnIntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: ExprUtils.makeLiteralInt(value: 1)))
        XCTAssertEqual(result, .constInt(1))
    }
    
    func testEveryBooleanLiteralIsABooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: ExprUtils.makeLiteralBoolean(value: true)))
        XCTAssertEqual(result, .constBool(true))
    }
    
    func testExpressionUsesInvalidUnaryPrefixOperator() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                    expression: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`*' is not a prefix unary operator")
        }
    }
    
    func testUnaryNegationOfIntegerConstantIsIntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constInt(-1))
    }
    
    func testUnaryNegationOfU8IsU8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testUnaryNegationOfU16IsU16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testUnaryNegationOfBooleanIsInvalid() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `-' cannot be applied to an operand of type `bool'")
        }
    }
    
    func testBinary_IntegerConstant_Eq_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(true))
    }
    
    func testBinary_IntegerConstant_Eq_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_IntegerConstant_Eq_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `const int' and `const bool'")
        }
    }
    
    func testBinary_U16_Eq_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Eq_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `const bool'")
        }
    }
    
    func testBinary_U8_Eq_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Eq_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `const bool'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_BooleanConstant_Eq_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(true))
    }
    
    func testBinary_BooleanConstant_Eq_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 0))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `const bool' and `const int'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `const bool' and `u16'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `const bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Eq_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Eq_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 0))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_Bool_Eq_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Ne_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(false))
    }
    
    func testBinary_IntegerConstant_Ne_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_IntegerConstant_Ne_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `const int' and `const bool'")
        }
    }
    
    func testBinary_U16_Ne_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Ne_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `const bool'")
        }
    }
    
    func testBinary_U8_Ne_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Ne_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `const bool'")
        }
    }
    
    func testBinary_Bool_Ne_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_Bool_Ne_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Ne_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_BooleanConstant_Ne_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `const bool' and `const int'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `const bool' and `u16'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `const bool' and `u8'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_BooleanConstant_Ne_BooleanConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(false))
    }
    
    func testBinary_IntegerConstant_Lt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(false))
    }
    
    func testBinary_IntegerConstant_Lt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Lt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Lt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Lt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Lt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Lt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Lt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Lt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Lt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_IntegerConstant_Gt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(false))
    }
    
    func testBinary_IntegerConstant_Gt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Gt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Gt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Gt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Gt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Gt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Gt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Gt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Gt_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_IntegerConstant_Le_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(true))
    }
    
    func testBinary_IntegerConstant_Le_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Le_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Le_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Le_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Le_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Le_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Le_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(true))
    }
    
    func testBinary_U8_Le_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Le_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Le_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Le_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Le_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_IntegerConstant_Ge_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constBool(true))
    }
    
    func testBinary_IntegerConstant_Ge_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ge_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ge_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Ge_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Ge_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Ge_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Ge_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Ge_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Ge_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_IntegerConstant_Plus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constInt(2000))
    }
    
    func testBinary_IntegerConstant_Plus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Plus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Plus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Plus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Plus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Plus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Plus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Plus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Plus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_Bool_Plus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Plus_U8() {
       let typeChecker = ExpressionTypeChecker()
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_Plus_Bool() {
       let typeChecker = ExpressionTypeChecker()
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to two `bool' operands")
       }
   }
   
   func testBinary_IntegerConstant_Minus_IntegerConstant() {
       let typeChecker = ExpressionTypeChecker()
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    left: ExprUtils.makeLiteralInt(value: 1000),
                                    right: ExprUtils.makeLiteralInt(value: 1000))
       var result: SymbolType? = nil
       XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
       XCTAssertEqual(result, .constInt(0))
   }
    
    func testBinary_IntegerConstant_Minus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Minus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Minus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `const int' and `bool'")
        }
    }
   
   func testBinary_U16_Minus_IntegerConstant() {
       let typeChecker = ExpressionTypeChecker()
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    left: ExprUtils.makeU16(value: 1000),
                                    right: ExprUtils.makeLiteralInt(value: 1000))
       var result: SymbolType? = nil
       XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
       XCTAssertEqual(result, .u16)
   }
    
    func testBinary_U16_Minus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Minus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Minus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Minus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Minus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Minus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Minus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Minus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_Bool_Minus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Minus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Minus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Multiply_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constInt(1000000))
    }
    
    func testBinary_IntegerConstant_Multiply_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Multiply_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Multiply_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Multiply_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Multiply_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Multiply_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Multiply_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Multiply_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Multiply_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_Bool_Multiply_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Multiply_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Multiply_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Divide_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constInt(1))
    }
    
    func testBinary_IntegerConstant_Divide_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Divide_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Divide_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Divide_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Divide_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Divide_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Divide_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Divide_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Divide_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_Bool_Divide_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Divide_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Divide_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Modulus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constInt(0))
    }
    
    func testBinary_IntegerConstant_Modulus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Modulus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Modulus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `const int' and `bool'")
        }
    }
    
    func testBinary_U16_Modulus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Modulus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Modulus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Modulus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Modulus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Modulus_IntegerConstant() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `const int'")
        }
    }
    
    func testBinary_Bool_Modulus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Modulus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Modulus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1,  lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to two `bool' operands")
        }
    }
    
    func testAssignment_IntegerConstant_to_U16_Overflows() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralInt(value: 0x10000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testAssignment_IntegerConstant_to_U8_Overflows() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralInt(value: 0x100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testAssignment_IntegerConstant_to_U16() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralInt(value: 0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testAssignment_IntegerConstant_to_U8() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralInt(value: 0xab))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testAssignment_U16_to_U16() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeU16(value: 0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testAssignment_U8_to_U8() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testAssignment_Bool_to_Bool() {
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testIdentifier_U16() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: false)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testIdentifier_U8() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: false)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testIdentifier_Boolean() {
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010, isMutable: false)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testFailBecauseFunctionCallUsesIncorrectParameterType() {
        let functionType = FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "a", type: .u8)])
        let expr = Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [ExprUtils.makeBool(value: true)])
        let symbols = SymbolTable(["foo" : Symbol(type: .function(name: "foo", mangledName: "foo", functionType: functionType), offset: 0x0000, isMutable: false)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to expected argument type `u8' in call to `foo'")
        }
    }
    
    func testFailBecauseFunctionCallUsesIncorrectNumberOfParameters() {
        let functionType = FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "a", type: .u8)])
        let symbols = SymbolTable(["foo" : Symbol(type: .function(name: "foo", mangledName: "foo", functionType: functionType), offset: 0x0000, isMutable: false)])
        let expr = Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of arguments in call to `foo'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertLargeIntegerConstantToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralInt(value: 65536))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertLargeIntegerConstantToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralInt(value: 256))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertU16ToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `u16' to type `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertBoolToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: false))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `bool' to type `u8'")
        }
    }
    
    func testAssignmentWhichConvertsU8ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBoolasVoid() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .void)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `void'")
        }
    }
    
    func testBoolasU16() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u16'")
        }
    }
    
    func testBoolasU8() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u8'")
        }
    }
    
    func testBoolasBool() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testU8asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .void)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `void'")
        }
    }
    
    func testU8asU16() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testU8asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testU8asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `bool'")
        }
    }
    
    func testU16asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .void)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `void'")
        }
    }
    
    func testU16asU16() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testU16asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testU16asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `bool'")
        }
    }
    
    func testIntegerConstantAsU16() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 0),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testIntegerConstantAsU8() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 0),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testIntegerConstantAsU8_Overflows() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 256),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 65536),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testIntegerConstantAsU8_Overflows_Negative() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: -1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-1' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows_Negative() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: -1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-1' overflows when stored into `u16'")
        }
    }
    
    func testIntegerConstantasBool() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 0),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `const int' to type `bool'")
        }
    }
    
    func testBooleanConstantasBool() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralBoolean(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    fileprivate func doTestSubscriptOfZero(_ symbolType: SymbolType) {
        let ident = "foo"
        let symbols = SymbolTable([ident : Symbol(type: symbolType, offset: 0x0010, isMutable: false)])
        let zero = ExprUtils.makeLiteralInt(value: 0)
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: zero)
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `\(symbolType)' has no subscripts")
        }
    }
    
    func testSubscriptOfZeroWithU8() {
        doTestSubscriptOfZero(.u8)
    }
    
    func testSubscriptOfZeroWithU16() {
        doTestSubscriptOfZero(.u16)
    }
    
    func testSubscriptOfZeroWithBool() {
        doTestSubscriptOfZero(.bool)
    }
    
    func testEmptyArray() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = ExprUtils.makeLiteralArray([])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 0, elementType: .void))
    }
    
    func testSingletonArrayOfU8() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = ExprUtils.makeLiteralArray([val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u8))
    }
    
    func testSingletonArrayOfU16() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = ExprUtils.makeLiteralArray([val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u16))
    }
    
    func testSingletonArrayOfBoolean() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeBool(value: false)
        let arr = ExprUtils.makeLiteralArray([val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .bool))
    }
    
    func testSingletonArrayOfArray() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeLiteralArray([])
        let arr = ExprUtils.makeLiteralArray([val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .array(count: 0, elementType: .void)))
    }
    
    func testArrayOfU8() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = ExprUtils.makeLiteralArray([val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u8))
    }
    
    func testArrayOfU16() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = ExprUtils.makeLiteralArray([val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u16))
    }
    
    func testArrayOfBoolean() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeBool(value: false)
        let arr = ExprUtils.makeLiteralArray([val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .bool))
    }
    
    func testArrayOfArray() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeLiteralArray([])
        let arr = ExprUtils.makeLiteralArray([val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .array(count: 0, elementType: .void)))
    }
    
    func testCannotInferTypeOfHeterogeneousArray() {
        let expr = ExprUtils.makeLiteralArray([ExprUtils.makeLiteralInt(value: 0),
                                               ExprUtils.makeLiteralBoolean(value: false)])
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot infer type of heterogeneous array")
        }
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoU8() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = ExprUtils.makeLiteralArray([ExprUtils.makeLiteralInt(value: 0),
                                              ExprUtils.makeLiteralInt(value: 1),
                                              ExprUtils.makeLiteralInt(value: 2)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u8))
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoU16() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = ExprUtils.makeLiteralArray([ExprUtils.makeLiteralInt(value: 0),
                                              ExprUtils.makeLiteralInt(value: 0),
                                              ExprUtils.makeLiteralInt(value: 1000)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u16))
    }
    
    func testInferTypeOfArrayOfHeterogeneousArithmeticTypesWhichFitIntoU8() {
        let expr = ExprUtils.makeLiteralArray([ExprUtils.makeLiteralInt(value: 0),
                                               ExprUtils.makeU8(value: 0),
                                               ExprUtils.makeU8(value: 0)])
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u8))
    }
    
    func testInferTypeOfArrayOfHeterogeneousArithmeticTypesWhichFitIntoU16() {
        let expr = ExprUtils.makeLiteralArray([ExprUtils.makeLiteralInt(value: 0),
                                               ExprUtils.makeU8(value: 0),
                                               ExprUtils.makeU16(value: 0)])
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u16))
    }
    
    func testEvaluationOfArrayIdentifierIsNotYetSupported() {
        // The evaluation of a bare array identifier ought to yield a reference
        // to the array in memory. Currently, it's simply unsupported.
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010, isMutable: false)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeIdentifier(name: "foo")
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "unsupported expression: <Identifier: identifier=\'foo\'>")
        }
    }
    
    func testCannotAssignFunctionToArray() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .function(name: "foo", mangledName: "foo", functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "a", type: .u8), FunctionType.Argument(name: "b", type: .u16)])),
                           offset: 0x0010,
                           isMutable: false),
            "bar" : Symbol(type: .array(count: nil, elementType: .u16),
                           offset: 0x0012,
                           isMutable: false)
        ])
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                                         expression: ExprUtils.makeIdentifier(name: "foo"))
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `(u8, u16) -> bool' to type `[u16]'")
        }
    }
}
