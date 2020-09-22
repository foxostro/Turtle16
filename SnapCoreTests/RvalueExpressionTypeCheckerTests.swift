//
//  RvalueExpressionTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class RvalueExpressionTypeCheckerTests: XCTestCase {
    func testUnsupportedExpressionThrows() {
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: Expression.UnsupportedExpression(sourceAnchor: nil))) {
            var error: CompilerError? = nil
            XCTAssertNotNil(error = $0 as? CompilerError)
            XCTAssertEqual(error?.message, "unsupported expression: <UnsupportedExpression>")
        }
    }
    
    func testEveryIntegerLiteralIsAnIntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: Expression.LiteralInt(1)))
        XCTAssertEqual(result, .compTimeInt(1))
    }
    
    func testEveryBooleanLiteralIsABooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: Expression.LiteralBool(true)))
        XCTAssertEqual(result, .compTimeBool(true))
    }
    
    func testExpressionUsesInvalidUnaryPrefixOperator() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .star,
                                    expression: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`*' is not a prefix unary operator")
        }
    }
    
    func testUnaryNegationOfIntegerConstantIsIntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .minus,
                                    expression: Expression.LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeInt(-1))
    }
    
    func testUnaryNegationOfU8IsU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testUnaryNegationOfU16IsU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testUnaryNegationOfBooleanIsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `-' cannot be applied to an operand of type `bool'")
        }
    }
    
    func testBinary_IntegerConstant_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(true))
    }
    
    func testBinary_IntegerConstant_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_IntegerConstant_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `integer constant 1000' and `boolean constant false'")
        }
    }
    
    func testBinary_U16_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `boolean constant false'")
        }
    }
    
    func testBinary_U8_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `boolean constant false'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_BooleanConstant_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(true))
    }
    
    func testBinary_BooleanConstant_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralInt(0))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `boolean constant false' and `integer constant 0'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `boolean constant false' and `u16'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `boolean constant false' and `u8'")
        }
    }
    
    func testBinary_Bool_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralInt(0))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `integer constant 0'")
        }
    }
    
    func testBinary_Bool_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(false))
    }
    
    func testBinary_IntegerConstant_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_IntegerConstant_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `integer constant 1000' and `boolean constant false'")
        }
    }
    
    func testBinary_U16_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `boolean constant false'")
        }
    }
    
    func testBinary_U8_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `boolean constant false'")
        }
    }
    
    func testBinary_Bool_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `integer constant 1'")
        }
    }
    
    func testBinary_Bool_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_BooleanConstant_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `boolean constant false' and `integer constant 1'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `boolean constant false' and `u16'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `boolean constant false' and `u8'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_BooleanConstant_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(false))
    }
    
    func testBinary_IntegerConstant_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(false))
    }
    
    func testBinary_IntegerConstant_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `integer constant 1'")
        }
    }
    
    func testBinary_IntegerConstant_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(false))
    }
    
    func testBinary_IntegerConstant_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `integer constant 1'")
        }
    }
    
    func testBinary_IntegerConstant_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(true))
    }
    
    func testBinary_IntegerConstant_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1),
                                              right: Expression.LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(true))
    }
    
    func testBinary_U8_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `integer constant 1'")
        }
    }
    
    func testBinary_IntegerConstant_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeBool(true))
    }
    
    func testBinary_IntegerConstant_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_IntegerConstant_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU16(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `integer constant 1'")
        }
    }
    
    func testBinary_IntegerConstant_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeInt(2000))
    }
    
    func testBinary_IntegerConstant_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Plus_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Plus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Plus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Plus_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .plus,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_Plus_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .plus,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to two `bool' operands")
       }
   }
   
   func testBinary_IntegerConstant_Minus_IntegerConstant() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .minus,
                                    left: Expression.LiteralInt(1000),
                                    right: Expression.LiteralInt(1000))
       var result: SymbolType? = nil
       XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
       XCTAssertEqual(result, .compTimeInt(0))
   }
    
    func testBinary_IntegerConstant_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
   
   func testBinary_U16_Minus_IntegerConstant() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .minus,
                                    left: ExprUtils.makeU16(value: 1000),
                                    right: Expression.LiteralInt(1000))
       var result: SymbolType? = nil
       XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
       XCTAssertEqual(result, .u16)
   }
    
    func testBinary_U16_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Minus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Minus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeInt(1000000))
    }
    
    func testBinary_IntegerConstant_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `integer constant 100' and `bool'")
        }
    }
    
    func testBinary_U16_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeInt(1))
    }
    
    func testBinary_IntegerConstant_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `integer constant 100' and `bool'")
        }
    }
    
    func testBinary_U16_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .compTimeInt(0))
    }
    
    func testBinary_IntegerConstant_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_IntegerConstant_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_IntegerConstant_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `integer constant 100' and `bool'")
        }
    }
    
    func testBinary_U16_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to two `bool' operands")
        }
    }
    
    func testAssignment_IntegerConstant_to_U16_Overflows() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(0x10000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testAssignment_IntegerConstant_to_U8_Overflows() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(0x100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testAssignment_IntegerConstant_to_U16() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testAssignment_IntegerConstant_to_U8() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  ExprUtils.makeU8(value: 0xab))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testAssignment_U16_to_U16() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  ExprUtils.makeU16(value: 0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testAssignment_U8_to_U8() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testAssignment_Bool_to_Bool() {
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testAssignment_ArrayOfU8_to_DynamicArrayOfU8() {
        let symbols = SymbolTable([
            "src" : Symbol(type: .array(count: 5, elementType: .u8), offset: 0x0010),
            "dst" : Symbol(type: .dynamicArray(elementType: .u8), offset: 0x0010)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "dst", right:  Expression.Identifier("src"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .u8))
    }
    
    func testIdentifier_U16() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testIdentifier_U8() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testIdentifier_Boolean() {
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testFailBecauseFunctionCallUsesIncorrectParameterType() {
        let expr = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [ExprUtils.makeBool(value: false)])
        let symbols = SymbolTable(["foo" : Symbol(type: .function(FunctionType(name: "foo", returnType: .u8, arguments: [FunctionType.Argument(name: "a", type: .u8)])), offset: 0x0000)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to expected argument type `u8' in call to `foo'")
        }
    }
    
    func testFailBecauseFunctionCallUsesIncorrectNumberOfParameters() {
        let symbols = SymbolTable(["foo" : Symbol(type: .function(FunctionType(name: "foo", returnType: .u8, arguments: [FunctionType.Argument(name: "a", type: .u8)])), offset: 0x0000)])
        let expr = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of arguments in call to `foo'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertLargeIntegerConstantToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralInt(65536))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertLargeIntegerConstantToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralInt(256))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertU16ToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `u16' to type `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertBoolToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: false))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `bool' to type `u8'")
        }
    }
    
    func testAssignmentWhichConvertsU8ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBoolasVoid() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.void))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `void'")
        }
    }
    
    func testBoolasU16() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.u16))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u16'")
        }
    }
    
    func testBoolasU8() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u8'")
        }
    }
    
    func testBoolasBool() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.bool))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testU8asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.void))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `void'")
        }
    }
    
    func testU8asU16() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.u16))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testU8asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testU8asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.bool))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `bool'")
        }
    }
    
    func testU16asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.void))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `void'")
        }
    }
    
    func testU16asU16() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.u16))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testU16asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testU16asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.bool))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `bool'")
        }
    }
    
    func testCannotConvertArrayLiteralsOfDifferentLengths() {
        let expr = Expression.As(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)),
                                                               elements: [ExprUtils.makeU8(value: 1)]),
                                 targetType: Expression.ArrayType(count: Expression.LiteralInt(10), elementType: Expression.PrimitiveType(.u16)))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `[1]u8' to type `[10]u16'")
        }
    }
    
    func testArrayOfU8AsArrayOfU16() {
        let expr = Expression.As(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)),
                                                               elements: [ExprUtils.makeU8(value: 1)]),
                                 targetType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u16)))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u16))
    }
    
    func testIntegerConstantAsU16() {
        let expr = Expression.As(expr: Expression.LiteralInt(0),
                                 targetType: Expression.PrimitiveType(.u16))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testIntegerConstantAsU8() {
        let expr = Expression.As(expr: Expression.LiteralInt(0),
                                 targetType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testIntegerConstantAsU8_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(256),
                                 targetType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(65536),
                                 targetType: Expression.PrimitiveType(.u16))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testIntegerConstantAsU8_Overflows_Negative() {
        let expr = Expression.As(expr: Expression.LiteralInt(-1),
                                 targetType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-1' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows_Negative() {
        let expr = Expression.As(expr: Expression.LiteralInt(-1),
                                 targetType: Expression.PrimitiveType(.u16))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-1' overflows when stored into `u16'")
        }
    }
    
    func testIntegerConstantasBool() {
        let expr = Expression.As(expr: Expression.LiteralInt(0),
                                 targetType: Expression.PrimitiveType(.bool))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `integer constant 0' to type `bool'")
        }
    }
    
    func testBooleanConstantasBool() {
        let expr = Expression.As(expr: Expression.LiteralBool(false),
                                 targetType: Expression.PrimitiveType(.bool))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
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
    
    private func doTestSubscriptOfZero(_ symbolType: SymbolType) {
        let ident = "foo"
        let symbols = SymbolTable([ident : Symbol(type: symbolType, offset: 0x0010)])
        let zero = Expression.LiteralInt(0)
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: zero)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `\(symbolType)' has no subscripts")
        }
    }
    
    func testArraySubscriptFailsWithNonarithmeticIndex() {
        let ident = "foo"
        let symbols = SymbolTable([ident : Symbol(type: .array(count: 3, elementType: .bool), offset: 0x0010)])
        let index = ExprUtils.makeBool(value: false)
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: index)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot subscript a value of type `[3]bool' with an argument of type `bool'")
        }
    }
    
    func testArraySubscriptAccessesAnArrayElement_U8() {
        checkArraySubscriptAccessesArrayElement(elementType: .u8)
    }
    
    func testArraySubscriptAccessesAnArrayElement_U16() {
        checkArraySubscriptAccessesArrayElement(elementType: .u16)
    }
    
    func testArraySubscriptAccessesAnArrayElement_Bool() {
        checkArraySubscriptAccessesArrayElement(elementType: .bool)
    }
    
    func testArraySubscriptAccessesAnArrayElement_ArrayOfArrays() {
        checkArraySubscriptAccessesArrayElement(elementType: .array(count: 3, elementType: .u8))
    }
    
    private func checkArraySubscriptAccessesArrayElement(elementType: SymbolType) {
        let ident = "foo"
        let symbols = SymbolTable([ident : Symbol(type: .array(count: 3, elementType: elementType), offset: 0x0010)])
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: Expression.LiteralInt(0))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, elementType)
    }
    
    func testEmptyArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.u8)),
                                          elements: [])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 0, elementType: .u8))
    }
    
    func testSingletonArrayOfU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u8))
    }
    
    func testSingletonArrayOfU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u16)),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u16))
    }
    
    func testSingletonArrayOfBoolean() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralBool(false)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.bool)),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .bool))
    }
    
    func testSingletonArrayOfArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.u8)),
                                          elements: [])
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.u8))),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .array(count: 0, elementType: .u8)))
    }
    
    func testArrayOfU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.u8)),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u8))
    }
    
    func testArrayOfU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.u16)),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u16))
    }
    
    func testArrayOfBoolean() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralBool(false)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.bool)),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .bool))
    }
    
    func testArrayOfArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.u8)),
                                          elements: [])
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.u8))),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .array(count: 0, elementType: .u8)))
    }
    
    func testArrayLiteralHasNonConvertibleType() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.bool)),
                                           elements: [Expression.LiteralInt(0),
                                                      Expression.LiteralBool(false)])
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `integer constant 0' to type `bool' in `[2]bool' array literal")
        }
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                          elements: [Expression.LiteralInt(0),
                                                     Expression.LiteralInt(1),
                                                     Expression.LiteralInt(2)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u8))
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)),
                                          elements: [Expression.LiteralInt(0),
                                                     Expression.LiteralInt(0),
                                                     Expression.LiteralInt(1000)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u16))
    }
    
    func testInferTypeOfArrayOfHeterogeneousArithmeticTypesWhichFitIntoU8() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u8)),
                                           elements: [ExprUtils.makeU8(value: 0),
                                                      ExprUtils.makeU8(value: 0),
                                                      ExprUtils.makeU8(value: 0)])
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u8))
    }
    
    func testCannotAssignFunctionToArray() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .function(FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "a", type: .u8), FunctionType.Argument(name: "b", type: .u16)])),
                           offset: 0x0010),
            "bar" : Symbol(type: .array(count: nil, elementType: .u16),
                           offset: 0x0012)
        ])
        let expr = ExprUtils.makeAssignment(name: "bar", right: Expression.Identifier("foo"))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `(u8, u16) -> bool' to type `[_]u16'")
        }
    }
    
    func testAccessInvalidMemberOfLiteralArray() {
        let expr = Expression.Get(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                                elements: [ExprUtils.makeU8(value: 0),
                                                                           ExprUtils.makeU8(value: 1),
                                                                           ExprUtils.makeU8(value: 2)]),
                                  member: Expression.Identifier("length"))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `[3]u8' has no member `length'")
        }
    }
    
    func testGetLengthOfLiteralArray() {
        let expr = Expression.Get(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                                elements: [ExprUtils.makeU8(value: 0),
                                                                           ExprUtils.makeU8(value: 1),
                                                                           ExprUtils.makeU8(value: 2)]),
                                  member: Expression.Identifier("count"))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testGetLengthOfDynamicArray() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("count"))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u8), offset: 0x0010)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testTypeOfPrimitiveTypeExpression() {
        let expr = Expression.PrimitiveType(.u8)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testTypeOfArrayTypeExpression() {
        let expr = Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: nil, elementType: .u8))
    }
    
    func testCountOfArrayTypeIsConstIntExpression() {
        let expr = Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u8))
    }
    
    func testCountOfArrayTypeIsConstIntExpressionAndWeCanDoMathThere() {
        let expr = Expression.ArrayType(count: Expression.Binary(op: .plus, left: Expression.LiteralInt(1), right: Expression.LiteralInt(1)), elementType: Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u8))
    }
    
    func testArrayCountMustHaveTypeOfConstInt() {
        let expr = Expression.ArrayType(count: ExprUtils.makeU8(value: 1), elementType: Expression.PrimitiveType(.u8))
       let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "array count must be a compile time constant, got `u8' instead")
        }
    }
    
    func testTypeOfDynamicArrayTypeExpression() {
        let expr = Expression.DynamicArrayType(Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .u8))
    }
    
    func testGetValueOfStructMemberLoadsTheValue() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: 0)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testGetValueOfNonexistentStructMember() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: 0)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `foo' has no member `asdf'")
        }
    }
    
    func testStructInitializerExpression_FailsWhenStructNameIsUnknown() {
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [])
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "use of undeclared type `Foo'")
        }
    }
    
    func testStructInitializerExpression_Empty() {
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [])
        let typ: SymbolType = .structType(StructType(name: "Foo", symbols: SymbolTable()))
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : typ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), typ)
    }
    
    func testStructInitializerExpression_IncorrectMemberName() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "asdf", expr: Expression.LiteralInt(0))
        ])
        let typ = StructType(name: "foo", symbols: SymbolTable())
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `Foo' has no member `asdf'")
        }
    }
    
    func testStructInitializerExpression_ArgumentTypeIsIncorrect() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "bar", expr: Expression.LiteralBool(false))
        ])
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `boolean constant false' to expected argument type `u16' in initialization of `bar'")
        }
    }
    
    func testStructInitializerExpression_ExpectsAndReceivesTwoValidArguments() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "bar", expr: Expression.LiteralInt(0)),
            Arg(name: "baz", expr: Expression.LiteralInt(0))
        ])
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0),
            "baz" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), .structType(typ))
    }
    
    func testStructInitializerExpression_MembersMayNotBeSpecifiedMoreThanOneTime() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "bar", expr: Expression.LiteralInt(0)),
            Arg(name: "bar", expr: Expression.LiteralInt(0))
        ])
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "initialization of member `bar' can only occur one time")
        }
    }

    func testStructInitializerExpression_TheresNothingWrongWithOmittingMembers() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [])
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0),
            "baz" : Symbol(type: .u16, offset: 2)
        ]))
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), .structType(typ))
    }
    
    func testTypeExpressionWithPointerTypeOfPrimitiveType_u8() {
        let expr = Expression.PointerType(Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.u8))
    }
    
    func testTypeExpressionWithPointerToPointer() {
        let expr = Expression.PointerType(Expression.PointerType(Expression.PrimitiveType(.u8)))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.pointer(.u8)))
    }
    
    func testTypeExpressionWithConstType_u8() {
        let expr = Expression.ConstType(Expression.PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .constU8)
    }
    
    func testCannotTakeAddressOfLiteralInt() {
        let expr = Expression.Unary(op: .ampersand, expression: Expression.LiteralInt(0))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "lvalue required as operand of unary operator `&'")
        }
    }
    
    func testCannotTakeAddressOfLiteralBool() {
        let expr = Expression.Unary(op: .ampersand, expression: Expression.LiteralBool(false))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "lvalue required as operand of unary operator `&'")
        }
    }
    
    func testAddressOfIdentifierForU8Symbol() {
        let expr = Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo"))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .u8, offset: 0xabcd)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.u8))
    }
    
    func testDereferencePointerToU8() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("pointee"))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.u8), offset: 0)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testGetValueOfStructMemberThroughPointerLoadsTheValue() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.structType(typ)), offset: 0)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testGetValueOfNonexistentStructMemberThroughPointer() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.structType(typ)), offset: 0)
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `*Foo' has no member `asdf'")
        }
    }
    
    func testResolveUnionTypeExpression() {
        let expr = Expression.UnionType([
            Expression.PrimitiveType(.u8),
            Expression.PrimitiveType(.u16),
            Expression.PrimitiveType(.bool),
            Expression.ArrayType(count: Expression.LiteralInt(5), elementType: Expression.PrimitiveType(.u8))
        ])
        let expected: SymbolType = .unionType(UnionType([
            .u8, .u16, .bool, .array(count: 5, elementType: .u8)
        ]))
        let typeChecker = TypeContextTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual?.sizeof, 6)
    }
    
    func testResolveConstUnionTypeExpression() {
        let expr = Expression.ConstType(Expression.UnionType([
            Expression.PrimitiveType(.u8),
            Expression.PrimitiveType(.u16),
            Expression.PrimitiveType(.bool),
            Expression.ArrayType(count: Expression.LiteralInt(5), elementType: Expression.PrimitiveType(.u8))
        ]))
        let expected: SymbolType = .unionType(UnionType([
            .constU8,
            .constU16,
            .constBool,
            .array(count: 5, elementType: .constU8)
        ]))
        let typeChecker = TypeContextTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual?.sizeof, 6)
    }
    
    func testCompileFailsWhenCastingUnionTypeToNonMemberType() {
        let union = Expression.Identifier("foo")
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .u16])), offset: offset, storage: .stackStorage)])
        let expr = Expression.As(expr: union, targetType: Expression.PrimitiveType(.bool))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8 | u16' to type `bool'")
        }
    }
    
    func testSuccessfullyCastUnionTypeToMemberType() {
        let expr = Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.PrimitiveType(.u8))
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .u16])), offset: offset, storage: .stackStorage)])
        let expected: SymbolType = .u8
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestPrimitiveTypeIsExpression_Succeeds() {
        let expr = Expression.Is(expr: ExprUtils.makeU8(value: 0),
                                 testType: Expression.PrimitiveType(.u8))
        let expected: SymbolType = .compTimeBool(true)
        let typeChecker = RvalueExpressionTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestPrimitiveTypeIsExpression_False() {
        let expr = Expression.Is(expr: ExprUtils.makeU8(value: 0),
                                 testType: Expression.PrimitiveType(.bool))
        let expected: SymbolType = .compTimeBool(false)
        let typeChecker = RvalueExpressionTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestUnionVariantTypeAgainstNonMemberType() {
        let union = Expression.Identifier("foo")
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .u16])), offset: offset, storage: .stackStorage)])
        let expr = Expression.Is(expr: union, testType: Expression.PrimitiveType(.bool))
        let expected: SymbolType = .compTimeBool(false)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestUnionVariantTypeAgainstKnownMemberType() {
        let union = Expression.Identifier("foo")
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .bool])), offset: offset, storage: .stackStorage)])
        let expr = Expression.Is(expr: union, testType: Expression.PrimitiveType(.u8))
        let expected: SymbolType = .bool
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testCanAssignToUnionGivenTypeWhichConvertsToMatchingUnionMember() {
        let expr = Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                         rexpr: ExprUtils.makeU8(value: 1))
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u16])), offset: 0x0010)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .unionType(UnionType([.u16])))
    }
}
