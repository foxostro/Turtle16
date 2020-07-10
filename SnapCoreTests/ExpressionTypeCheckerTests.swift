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
    
    func testLiteralIntIsU8Sometimes() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: ExprUtils.makeLiteralInt(value: 1)))
        XCTAssertEqual(result, .u8)
    }
    
    func testLiteralIntIsU16Sometimes() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: ExprUtils.makeLiteralInt(value: 256)))
        XCTAssertEqual(result, .u16)
    }
    
    func testTypeOfALiteralBooleanIsBoolean() {
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: ExprUtils.makeLiteralBoolean(value: true)))
        XCTAssertEqual(result, .bool)
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
    
    func testUnaryNegationOfU8IsU8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testUnaryNegationOfU16IsU16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testUnaryNegationOfBooleanIsInvalid() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                    expression: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `-' cannot be applied to an operand of type `bool'")
        }
    }
    
    func testBinary_U16_Eq_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Eq_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Eq_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Eq_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Ne_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Ne_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Ne_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_Bool_Ne_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Lt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Lt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Lt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Lt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Lt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Lt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Gt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Gt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Gt_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Gt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Gt_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Gt_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Le_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Le_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Le_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
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
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Le_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Le_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Le_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Ge_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U16_Ge_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Ge_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testBinary_U8_Ge_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralInt(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Ge_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Ge_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Plus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Plus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Plus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Plus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Plus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Plus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Plus_U8() {
       let typeChecker = ExpressionTypeChecker()
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                    left: ExprUtils.makeLiteralBoolean(value: false),
                                    right: ExprUtils.makeLiteralInt(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_Plus_Bool() {
       let typeChecker = ExpressionTypeChecker()
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                    left: ExprUtils.makeLiteralBoolean(value: false),
                                    right: ExprUtils.makeLiteralBoolean(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to two `bool' operands")
       }
   }
    
    func testBinary_U16_Minus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Minus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Minus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Minus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Minus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Minus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Minus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Minus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Minus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_U16_Multiply_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Multiply_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Multiply_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Multiply_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Multiply_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Multiply_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Multiply_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Multiply_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_U16_Divide_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Divide_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Divide_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Divide_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Divide_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Divide_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Divide_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Divide_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_U16_Modulus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U16_Modulus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Modulus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBinary_U8_Modulus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testBinary_U8_Modulus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralInt(value: 1),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Modulus_U16() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Modulus_U8() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Modulus_Bool() {
        let typeChecker = ExpressionTypeChecker()
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1,  lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeLiteralBoolean(value: false),
                                     right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to two `bool' operands")
        }
    }
    
    func testAssignment_U16() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralInt(value: 0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testAssignment_U8() {
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralInt(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testAssignment_Boolean() {
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         expression: ExprUtils.makeLiteralBoolean(value: false))
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
        let expr = Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [ExprUtils.makeLiteralBoolean(value: true)])
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
    
    func testFailBecauseAssignmentCannotConvertU16ToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralInt(value: 0xabcd))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `u16' to type `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertBoolToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralBoolean(value: false))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `bool' to type `u8'")
        }
    }
    
    func testAssignmentWhichConvertsU8ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralInt(value: 42))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let typeChecker = ExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testBoolasVoid() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralBoolean(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "void", type: .void))
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `void'")
        }
    }
    
    func testBoolasU16() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralBoolean(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "u16", type: .u16))
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u16'")
        }
    }
    
    func testBoolasU8() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralBoolean(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "u8", type: .u8))
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u8'")
        }
    }
    
    func testBoolasBool() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralBoolean(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "bool", type: .bool))
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }
    
    func testU8asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "void", type: .void))
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `void'")
        }
    }
    
    func testU8asU16() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "u16", type: .u16))
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testU8asU8() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "u8", type: .u8))
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testU8asBool() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "bool", type: .bool))
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `bool'")
        }
    }
    
    func testU16asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "void", type: .void))
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `void'")
        }
    }
    
    func testU16asU16() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "u16", type: .u16))
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testU16asU8() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "u8", type: .u8))
        let typeChecker = ExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testU16asBool() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 tokenType: TokenType(lineNumber: 1, lexeme: "bool", type: .bool))
        let typeChecker = ExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `bool'")
        }
    }
}
