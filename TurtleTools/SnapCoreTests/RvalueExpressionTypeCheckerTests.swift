//
//  RvalueExpressionTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

extension SymbolTable {
    func withCompilerIntrinsicRangeType(_ memoryLayoutStrategy: MemoryLayoutStrategy) -> SymbolTable {
        let sizeOfU16 = memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u16)))
        let name = "Range"
        let typ: SymbolType = .structType(StructType(name: name, symbols: SymbolTable(tuples: [
            ("begin", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0*sizeOfU16, storage: .automaticStorage)),
            ("limit", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1*sizeOfU16, storage: .automaticStorage))
        ])))
        bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return self
    }
}

class RvalueExpressionTypeCheckerTests: XCTestCase {
    let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
    
    func testUnsupportedExpressionThrows() {
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: Expression.UnsupportedExpression(sourceAnchor: nil))) {
            var error: CompilerError? = nil
            XCTAssertNotNil(error = $0 as? CompilerError)
            XCTAssertEqual(error?.message, "unsupported expression: UnsupportedExpression")
        }
    }
    
    func testEveryIntegerLiteralIsAnIntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: Expression.LiteralInt(1)))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1)))
    }
    
    func testEveryBooleanLiteralIsABooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: Expression.LiteralBool(true)))
        XCTAssertEqual(result, .bool(.compTimeBool(true)))
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
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(-1)))
    }
    
    func testUnaryNegationOfU8IsU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testUnaryNegationOfU16IsU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
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
    
    func testUnaryBitwiseNegationOfIntegerConstantIsIntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .tilde,
                                    expression: Expression.LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(~1)))
    }
    
    func testUnaryBitwiseNegationOfU8IsU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .tilde,
                                    expression: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testUnaryBitwiseNegationOfU16IsU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .tilde,
                                    expression: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testUnaryBitwiseNegationOfBooleanIsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .tilde,
                                    expression: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `~' cannot be applied to an operand of type `bool'")
        }
    }
    
    func testUnaryLogicalNegationOfIntegerConstantIsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .bang,
                                    expression: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `!' cannot be applied to an operand of type `integer constant 1'")
        }
    }
    
    func testUnaryLogicalNegationOfU8IsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .bang,
                                    expression: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `!' cannot be applied to an operand of type `u8'")
        }
    }
    
    func testUnaryLogicalNegationOfU16IsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .bang,
                                    expression: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Unary operator `!' cannot be applied to an operand of type `u16'")
        }
    }
    
    func testUnaryLogicalNegationOfBooleanIsBool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Unary(op: .bang,
                                    expression: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.compTimeBool(true)))
    }
    
    func testBinary_IntegerConstant_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_BooleanConstant_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.compTimeBool(true)))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_Bool_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.compTimeBool(false)))
    }
    
    func testBinary_IntegerConstant_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_Bool_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_BooleanConstant_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.compTimeBool(false)))
    }
    
    func testBinary_IntegerConstant_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.compTimeBool(false)))
    }
    
    func testBinary_IntegerConstant_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.compTimeBool(false)))
    }
    
    func testBinary_IntegerConstant_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.compTimeBool(true)))
    }
    
    func testBinary_IntegerConstant_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(1),
                                              right: Expression.LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.compTimeBool(true)))
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
        XCTAssertEqual(result, .bool(.compTimeBool(true)))
    }
    
    func testBinary_IntegerConstant_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U16_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_U8_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(2000)))
    }
    
    func testBinary_IntegerConstant_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
       XCTAssertEqual(result, .arithmeticType(.compTimeInt(0)))
   }
    
    func testBinary_IntegerConstant_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
       XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
   }
    
    func testBinary_U16_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1000000)))
    }
    
    func testBinary_IntegerConstant_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1)))
    }
    
    func testBinary_IntegerConstant_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0)))
    }
    
    func testBinary_IntegerConstant_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(100),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
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
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
    
    func testBinary_IntegerConstant_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0b1010101010101010)))
    }
    
    func testBinary_IntegerConstant_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_BitwiseAnd_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_BitwiseAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: Expression.LiteralInt(0b10101010),
                                     right: ExprUtils.makeU8(value: 0b11111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_IntegerConstant_BitwiseAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_BitwiseAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_BitwiseAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .ampersand,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_BitwiseAnd_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .ampersand,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `&' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_BitwiseAnd_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .ampersand,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `&' cannot be applied to two `bool' operands")
       }
   }
    
    func testBinary_IntegerConstant_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0b1111111111111111)))
    }
    
    func testBinary_IntegerConstant_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_BitwiseOr_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_BitwiseOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: Expression.LiteralInt(0b10101010),
                                     right: ExprUtils.makeU8(value: 0b11111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_IntegerConstant_BitwiseOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `|' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `|' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_BitwiseOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_BitwiseOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `|' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `|' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .pipe,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `|' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_BitwiseOr_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .pipe,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `|' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_BitwiseOr_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .pipe,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `|' cannot be applied to two `bool' operands")
       }
   }
    
    func testBinary_IntegerConstant_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0b101010101010101)))
    }
    
    func testBinary_IntegerConstant_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_BitwiseXor_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_BitwiseXor_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: Expression.LiteralInt(0b10101010),
                                     right: ExprUtils.makeU8(value: 0b11111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_IntegerConstant_BitwiseXor_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `^' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseXor_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_BitwiseXor_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `^' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_BitwiseXor_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_BitwiseXor_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `^' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `^' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .caret,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `^' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_BitwiseXor_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .caret,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `^' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_BitwiseXor_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .caret,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `^' cannot be applied to two `bool' operands")
       }
   }
    
    func testBinary_IntegerConstant_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: Expression.LiteralInt(1),
                                     right: Expression.LiteralInt(2))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1 << 2)))
    }
    
    func testBinary_IntegerConstant_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_LeftShift_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_LeftShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: Expression.LiteralInt(1),
                                     right: ExprUtils.makeU8(value: 2))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_IntegerConstant_LeftShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<<' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_LeftShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_LeftShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<<' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_LeftShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_LeftShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<<' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<<' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .leftDoubleAngle,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<<' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_LeftShift_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .leftDoubleAngle,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `<<' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_LeftShift_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .leftDoubleAngle,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `<<' cannot be applied to two `bool' operands")
       }
   }
    
    func testBinary_IntegerConstant_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: Expression.LiteralInt(2),
                                     right: Expression.LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(2 >> 1)))
    }
    
    func testBinary_IntegerConstant_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_RightShift_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_IntegerConstant_RightShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: Expression.LiteralInt(1),
                                     right: ExprUtils.makeU8(value: 2))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_IntegerConstant_RightShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>>' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_RightShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U16_RightShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>>' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testBinary_U8_RightShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testBinary_U8_RightShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>>' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>>' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .rightDoubleAngle,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>>' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_RightShift_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .rightDoubleAngle,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `>>' cannot be applied to operands of types `bool' and `u8'")
       }
    }
    
    func testBinary_Bool_RightShift_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .rightDoubleAngle,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `>>' cannot be applied to two `bool' operands")
       }
    }
    
    func testBinary_IntegerConstant_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: Expression.LiteralInt(2),
                                     right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `integer constant 2' and `integer constant 1'")
        }
    }
    
    func testBinary_IntegerConstant_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `integer constant 43690' and `u16'")
        }
    }
    
    func testBinary_IntegerConstant_LogicalAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: Expression.LiteralInt(1),
                                     right: ExprUtils.makeU8(value: 2))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `integer constant 1' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_LogicalAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `u16' and `integer constant 65535'")
        }
    }
    
    func testBinary_U16_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to two `u16' operands")
        }
    }
    
    func testBinary_U16_LogicalAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `u16' and `u8'")
        }
    }
    
    func testBinary_U16_LogicalAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `u8' and `integer constant 100'")
        }
    }
    
    func testBinary_U8_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `u8' and `u16'")
        }
    }
    
    func testBinary_U8_LogicalAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to two `u8' operands")
        }
    }
    
    func testBinary_U8_LogicalAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doubleAmpersand,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_LogicalAnd_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .doubleAmpersand,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `&&' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_LogicalAnd_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .doubleAmpersand,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBinary_IntegerConstant_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: Expression.LiteralInt(2),
                                     right: Expression.LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `integer constant 2' and `integer constant 1'")
        }
    }
    
    func testBinary_IntegerConstant_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: Expression.LiteralInt(0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `integer constant 43690' and `u16'")
        }
    }
    
    func testBinary_IntegerConstant_LogicalOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: Expression.LiteralInt(1),
                                     right: ExprUtils.makeU8(value: 2))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `integer constant 1' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_LogicalOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `integer constant 1000' and `bool'")
        }
    }
    
    func testBinary_U16_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: Expression.LiteralInt(0b1111111111111111))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `u16' and `integer constant 65535'")
        }
    }
    
    func testBinary_U16_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU16(value: 0b1010101010101010),
                                     right: ExprUtils.makeU16(value: 0b1111111111111111))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to two `u16' operands")
        }
    }
    
    func testBinary_U16_LogicalOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `u16' and `u8'")
        }
    }
    
    func testBinary_U16_LogicalOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `u8' and `integer constant 100'")
        }
    }
    
    func testBinary_U8_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `u8' and `u16'")
        }
    }
    
    func testBinary_U8_LogicalOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to two `u8' operands")
        }
    }
    
    func testBinary_U8_LogicalOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeBool(value: false),
                                     right: Expression.LiteralInt(1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `bool' and `integer constant 1000'")
        }
    }
    
    func testBinary_Bool_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.Binary(op: .doublePipe,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_LogicalOr_U8() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .doublePipe,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `||' cannot be applied to operands of types `bool' and `u8'")
       }
    }
    
    func testBinary_Bool_LogicalOr_Bool() {
       let typeChecker = RvalueExpressionTypeChecker()
       let expr = Expression.Binary(op: .doublePipe,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
   }
    
    func testAssignment_IntegerConstant_to_U16_Overflows() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(0x10000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testAssignment_IntegerConstant_to_U8_Overflows() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(0x100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testAssignment_IntegerConstant_to_I16_Overflows() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(32768))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `32768' overflows when stored into `i16'")
        }
    }
    
    func testAssignment_IntegerConstant_to_I16_Underflows() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(-32769))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-32769' overflows when stored into `i16'")
        }
    }
    
    func testAssignment_IntegerConstant_to_I8_Overflows() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(128))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `128' overflows when stored into `i8'")
        }
    }
    
    func testAssignment_IntegerConstant_to_I8_Underflows() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(-129))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-129' overflows when stored into `i8'")
        }
    }
    
    func testAssignment_IntegerConstant_to_U16() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  Expression.LiteralInt(0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testAssignment_IntegerConstant_to_U8() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  ExprUtils.makeU8(value: 0xab))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testAssignment_U16_to_U16() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  ExprUtils.makeU16(value: 0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testAssignment_U8_to_U8() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right:  ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testAssignment_Bool_to_Bool() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool(.mutableBool), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testAssignment_ArrayOfU8_to_DynamicArrayOfU8() {
        let symbols = SymbolTable(tuples: [
            ("src", Symbol(type: .array(count: 5, elementType: .arithmeticType(.mutableInt(.u8))), offset: 0x0010)),
            ("dst", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8))), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "dst", right:  Expression.Identifier("src"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testIdentifier_U16() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testIdentifier_U8() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testIdentifier_Boolean() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool(.mutableBool), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testFailBecauseFunctionCallUsesIncorrectParameterType() {
        let expr = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [ExprUtils.makeBool(value: false)])
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", returnType: .arithmeticType(.mutableInt(.u8)), arguments: [.arithmeticType(.mutableInt(.u8))])), offset: 0x0000))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to expected argument type `u8' in call to `foo'")
        }
    }
    
    func testFailBecauseFunctionCallUsesIncorrectNumberOfParameters() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", returnType: .arithmeticType(.mutableInt(.u8)), arguments: [.arithmeticType(.mutableInt(.u8))])), offset: 0x0000))
        ])
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
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertLargeIntegerConstantToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralInt(256))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertU16ToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `u16' to type `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertBoolToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: false))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `bool' to type `u8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertU16ToI16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `u16' to type `i16'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertU16ToI8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `u16' to type `i8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertU8ToI8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 0xab))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `u8' to type `i8'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertI16ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeI16(value: -1))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `i16' to type `u16'")
        }
    }
    
    func testFailBecauseAssignmentCannotConvertI8ToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeI8(value: -1))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign value of type `i8' to type `u8'")
        }
    }
    
    func testAssignmentWhichConvertsU8ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testAssignmentWhichConvertsU8ToI16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i16)))
    }
    
    func testAssignmentWhichConvertsI8ToI16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeI8(value: -1))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i16)))
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
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u16'")
        }
    }
    
    func testBoolasU8() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u8'")
        }
    }
    
    func testMakeU8() {
        let expr = ExprUtils.makeU8(value: 0xff)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testMakeU16() {
        let expr = ExprUtils.makeU16(value: 0xff)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testMakeI8() {
        let expr = ExprUtils.makeI8(value: -1)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i8)))
    }
    
    func testMakeI16() {
        let expr = ExprUtils.makeI16(value: -16)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i16)))
    }
    
    func testMakeBool() {
        let expr = ExprUtils.makeBool(value: false)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBoolasI16() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `i16'")
        }
    }
    
    func testBoolasI8() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `i8'")
        }
    }
    
    func testBoolasBool() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.bool(.mutableBool)))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
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
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testU8asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testU8asI16() {
        // Every value representable in a u8 is also representable in a i16.
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 0xff),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i16)))
    }
    
    func testU8asI8() {
        // Conversion from u8 to i8 is available in an explicit cast.
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 0xff),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i8)))
    }
    
    func testU8asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.bool(.mutableBool)))
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
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testU16asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testU16asI16() {
        // Conversion from u16 to i16 is available in an explicit cast.
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i16)))
    }
    
    func testU16asI8() {
        // Conversion from u16 to i8 is available in an explicit cast.
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i8)))
    }
    
    func testU16asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.bool(.mutableBool)))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `bool'")
        }
    }
    
    func testI16asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeI16(value: -1),
                                 targetType: Expression.PrimitiveType(.void))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `i16' to type `void'")
        }
    }
    
    func testI16asU16() {
        // Conversion from i16 to u16 is available in an explicit cast.
        let expr = Expression.As(expr: ExprUtils.makeI16(value: -1),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testI16asU8() {
        // Conversion from i16 to u8 is available in an explicit cast.
        let expr = Expression.As(expr: ExprUtils.makeI16(value: -1),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testI16asI8() {
        let expr = Expression.As(expr: ExprUtils.makeI16(value: -1),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i8)))
    }
    
    func testI16asI16() {
        let expr = Expression.As(expr: ExprUtils.makeI16(value: -1),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.i16)))
    }
    
    func testI16asBool() {
        let expr = Expression.As(expr: ExprUtils.makeI16(value: -1),
                                 targetType: Expression.PrimitiveType(.bool(.mutableBool)))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `i16' to type `bool'")
        }
    }
    
    func testCannotConvertArrayLiteralsOfDifferentLengths() {
        let expr = Expression.As(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                                               elements: [ExprUtils.makeU8(value: 1)]),
                                 targetType: Expression.ArrayType(count: Expression.LiteralInt(10), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `[1]u8' to type `[10]u16'")
        }
    }
    
    func testArrayOfU8AsArrayOfU16() {
        let expr = Expression.As(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                                               elements: [ExprUtils.makeU8(value: 1)]),
                                 targetType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))))
    }
    
    func testIntegerConstantAsU16() {
        let expr = Expression.As(expr: Expression.LiteralInt(0),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testIntegerConstantAsU8() {
        let expr = Expression.As(expr: Expression.LiteralInt(0),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testIntegerConstantAsU8_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(256),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(65536),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testIntegerConstantAsI8_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(128),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `128' overflows when stored into `i8'")
        }
    }
    
    func testIntegerConstantAsI16_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(32768),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `32768' overflows when stored into `i16'")
        }
    }
    
    func testIntegerConstantAsU8_Overflows_Negative() {
        let expr = Expression.As(expr: Expression.LiteralInt(-1),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-1' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows_Negative() {
        let expr = Expression.As(expr: Expression.LiteralInt(-1),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-1' overflows when stored into `u16'")
        }
    }
    
    func testIntegerConstantAsI8_Overflows_Negative() {
        let expr = Expression.As(expr: Expression.LiteralInt(-129),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-129' overflows when stored into `i8'")
        }
    }
    
    func testIntegerConstantAsI16_Overflows_Negative() {
        let expr = Expression.As(expr: Expression.LiteralInt(-32769),
                                 targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16))))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `-32769' overflows when stored into `i16'")
        }
    }
    
    func testIntegerConstantAsBool() {
        let expr = Expression.As(expr: Expression.LiteralInt(0),
                                 targetType: Expression.PrimitiveType(.bool(.mutableBool)))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `integer constant 0' to type `bool'")
        }
    }
    
    func testBooleanConstantasBool() {
        let expr = Expression.As(expr: Expression.LiteralBool(false),
                                 targetType: Expression.PrimitiveType(.bool(.mutableBool)))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testSubscriptOfZeroWithU8() {
        doTestSubscriptOfZero(.arithmeticType(.mutableInt(.u8)))
    }
    
    func testSubscriptOfZeroWithU16() {
        doTestSubscriptOfZero(.arithmeticType(.mutableInt(.u16)))
    }
    
    func testSubscriptOfZeroWithI8() {
        doTestSubscriptOfZero(.arithmeticType(.mutableInt(.i8)))
    }
    
    func testSubscriptOfZeroWithI16() {
        doTestSubscriptOfZero(.arithmeticType(.mutableInt(.i16)))
    }
    
    func testSubscriptOfZeroWithBool() {
        doTestSubscriptOfZero(.bool(.mutableBool))
    }
    
    private func doTestSubscriptOfZero(_ symbolType: SymbolType) {
        let ident = "foo"
        let symbols = SymbolTable(tuples: [
            (ident, Symbol(type: symbolType, offset: 0x0010))
        ])
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
        let symbols = SymbolTable(tuples: [
            (ident, Symbol(type: .array(count: 3, elementType: .bool(.mutableBool)), offset: 0x0010))
        ])
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
        checkArraySubscriptAccessesArrayElement(elementType: .arithmeticType(.mutableInt(.u8)))
    }
    
    func testArraySubscriptAccessesAnArrayElement_U16() {
        checkArraySubscriptAccessesArrayElement(elementType: .arithmeticType(.mutableInt(.u16)))
    }
    
    func testArraySubscriptAccessesAnArrayElement_Bool() {
        checkArraySubscriptAccessesArrayElement(elementType: .bool(.mutableBool))
    }
    
    func testArraySubscriptAccessesAnArrayElement_ArrayOfArrays() {
        checkArraySubscriptAccessesArrayElement(elementType: .array(count: 3, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    private func checkArraySubscriptAccessesArrayElement(elementType: SymbolType) {
        let ident = "foo"
        let symbols = SymbolTable(tuples: [
            (ident, Symbol(type: .array(count: 3, elementType: elementType), offset: 0x0010))
        ])
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: Expression.LiteralInt(0))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, elementType)
    }
    
    func testEmptyArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                          elements: [])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 0, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testSingletonArrayOfU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testSingletonArrayOfU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))))
    }
    
    func testSingletonArrayOfBoolean() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralBool(false)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.bool(.mutableBool))),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .bool(.mutableBool)))
    }
    
    func testSingletonArrayOfArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                          elements: [])
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))),
                                          elements: [val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .array(count: 0, elementType: .arithmeticType(.mutableInt(.u8)))))
    }
    
    func testArrayOfU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testArrayOfU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16))))
    }
    
    func testArrayOfI8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeI8(value: 100)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8)))),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .arithmeticType(.mutableInt(.i8))))
    }
    
    func testArrayOfI16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeI16(value: 1000)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16)))),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .arithmeticType(.mutableInt(.i16))))
    }
    
    func testArrayOfBoolean() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralBool(false)
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.bool(.mutableBool))),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .bool(.mutableBool)))
    }
    
    func testArrayOfArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                          elements: [])
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))),
                                          elements: [val, val])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .array(count: 0, elementType: .arithmeticType(.mutableInt(.u8)))))
    }
    
    func testArrayLiteralHasNonConvertibleType() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.bool(.mutableBool))),
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
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                          elements: [Expression.LiteralInt(0),
                                                     Expression.LiteralInt(1),
                                                     Expression.LiteralInt(2)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))),
                                          elements: [Expression.LiteralInt(0),
                                                     Expression.LiteralInt(0),
                                                     Expression.LiteralInt(1000)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.u16))))
    }
    
    func testInferTypeOfArrayOfHeterogeneousArithmeticTypesWhichFitIntoU8() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                           elements: [ExprUtils.makeU8(value: 0),
                                                      ExprUtils.makeU8(value: 0),
                                                      ExprUtils.makeU8(value: 0)])
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI8_1() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8)))),
                                          elements: [Expression.LiteralInt(-1),
                                                     Expression.LiteralInt(-2),
                                                     Expression.LiteralInt(-3)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.i8))))
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI8_2() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8)))),
                                          elements: [Expression.LiteralInt(0),
                                                     Expression.LiteralInt(-1),
                                                     Expression.LiteralInt(-2)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.i8))))
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI16_1() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16)))),
                                          elements: [Expression.LiteralInt(-1000),
                                                     Expression.LiteralInt(-2000),
                                                     Expression.LiteralInt(-3000)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.i16))))
    }
    
    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI16_2() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16)))),
                                          elements: [Expression.LiteralInt( 1000),
                                                     Expression.LiteralInt(-2000),
                                                     Expression.LiteralInt(-3000)])
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.i16))))
    }
    
    func testCannotAssignFunctionToArray() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(returnType: .bool(.mutableBool), arguments: [.arithmeticType(.mutableInt(.u8)), .arithmeticType(.mutableInt(.u16))])), offset: 0x0010)),
            ("bar", Symbol(type: .array(count: nil, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x0012))
        ])
        let expr = ExprUtils.makeAssignment(name: "bar", right: Expression.Identifier("foo"))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "inappropriate use of a function type (Try taking the function's address instead.)")
        }
    }
    
    func testAccessInvalidMemberOfLiteralArray() {
        let expr = Expression.Get(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
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
        let expr = Expression.Get(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                                                elements: [ExprUtils.makeU8(value: 0),
                                                                           ExprUtils.makeU8(value: 1),
                                                                           ExprUtils.makeU8(value: 2)]),
                                  member: Expression.Identifier("count"))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testGetLengthOfDynamicArray() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("count"))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8))), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testGetCountOfRange() throws {
        let symbols = SymbolTable()
            .withCompilerIntrinsicRangeType(MemoryLayoutStrategyTurtle16())
        let expr = Expression.Get(
            expr: ExprUtils.makeRange(0, 10),
            member: Expression.Identifier("count"))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testTypeOfPrimitiveTypeExpression() {
        let expr = Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testTypeOfArrayTypeExpression() {
        let expr = Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: nil, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testCountOfArrayTypeIsConstIntExpression() {
        let expr = Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 1, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testCountOfArrayTypeIsConstIntExpressionAndWeCanDoMathThere() {
        let expr = Expression.ArrayType(count: Expression.Binary(op: .plus, left: Expression.LiteralInt(1), right: Expression.LiteralInt(1)), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 2, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testArrayCountMustHaveTypeOfConstInt() {
        let expr = Expression.ArrayType(count: ExprUtils.makeU8(value: 1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
       let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "array count must be a compile time constant, got `u8' instead")
        }
    }
    
    func testTypeOfDynamicArrayTypeExpression() {
        let expr = Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testGetValueOfStructMemberLoadsTheValue() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let typ = StructType(name: "foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: 0))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testGetValueOfNonexistentStructMember() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let typ = StructType(name: "foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: 0))
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
            XCTAssertEqual(compilerError?.message, "use of unresolved identifier: `Foo'")
        }
    }
    
    func testStructInitializerExpression_Empty() {
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [])
        let typ: SymbolType = .structType(StructType(name: "Foo", symbols: SymbolTable()))
        let symbols = SymbolTable(typeDict: ["Foo" : typ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), typ)
    }
    
    func testStructInitializerExpression_IncorrectMemberName() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "asdf", expr: Expression.LiteralInt(0))
        ])
        let typ = StructType(name: "foo", symbols: SymbolTable())
        let symbols = SymbolTable(typeDict: ["Foo" : .structType(typ)])
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
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(typeDict: ["Foo" : .structType(typ)])
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
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage)),
            ("baz", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(typeDict: ["Foo" : .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), .structType(typ))
    }
    
    func testStructInitializerExpression_MembersMayNotBeSpecifiedMoreThanOneTime() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "bar", expr: Expression.LiteralInt(0)),
            Arg(name: "bar", expr: Expression.LiteralInt(0))
        ])
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(typeDict: ["Foo" : .structType(typ)])
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
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage)),
            ("baz", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 2, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(typeDict: ["Foo" : .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), .structType(typ))
    }
    
    func testTypeExpressionWithPointerTypeOfPrimitiveType_u8() {
        let expr = Expression.PointerType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.arithmeticType(.mutableInt(.u8))))
    }
    
    func testTypeExpressionWithPointerToPointer() {
        let expr = Expression.PointerType(Expression.PointerType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.pointer(.arithmeticType(.mutableInt(.u8)))))
    }
    
    func testTypeExpressionWithConstType_u8() {
        let expr = Expression.ConstType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.immutableInt(.u8)))
    }
    
    func testTypeExpressionWithMutableType_u8() throws {
        let expr = Expression.MutableType(Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
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
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0xabcd))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.arithmeticType(.mutableInt(.u8))))
    }
    
    func testDereferencePointerToU8() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("pointee"))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u8))), offset: 0))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testGetValueOfStructMemberThroughPointerLoadsTheValue() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.structType(typ)), offset: 0))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testGetValueOfNonexistentStructMemberThroughPointer() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.structType(typ)), offset: 0))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `*Foo' has no member `asdf'")
        }
    }
    
    func testGetValueOfStructMemberThroughGetOnLiteralStructInitializer() throws {
        let si = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Expression.StructInitializer.Argument(name: "bar", expr: Expression.LiteralInt(1000))
        ])
        let expr = Expression.Get(expr: si, member: Expression.Identifier("bar"))
        let symbols = SymbolTable()
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1000)))
    }
    
    func testResolveUnionTypeExpression() {
        let expr = Expression.UnionType([
            Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
            Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))),
            Expression.PrimitiveType(.bool(.mutableBool)),
            Expression.ArrayType(count: Expression.LiteralInt(5), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])
        let expected: SymbolType = .unionType(UnionType([
            .arithmeticType(.mutableInt(.u8)),
            .arithmeticType(.mutableInt(.u16)),
            .bool(.mutableBool),
            .array(count: 5, elementType: .arithmeticType(.mutableInt(.u8)))
        ]))
        let typeChecker = TypeContextTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
        let actualSize: Int?
        if let actual = actual {
            actualSize = memoryLayoutStrategy.sizeof(type: actual)
        } else {
            actualSize = nil
        }
        XCTAssertEqual(actualSize, 6)
    }
    
    func testResolveConstUnionTypeExpression() {
        let expr = Expression.ConstType(Expression.UnionType([
            Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
            Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))),
            Expression.PrimitiveType(.bool(.mutableBool)),
            Expression.ArrayType(count: Expression.LiteralInt(5), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ]))
        let expected: SymbolType = .unionType(UnionType([
            .arithmeticType(.immutableInt(.u8)),
            .arithmeticType(.immutableInt(.u16)),
            .bool(.immutableBool),
            .array(count: 5, elementType: .arithmeticType(.immutableInt(.u8)))
        ]))
        let typeChecker = TypeContextTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
        let actualSize: Int?
        if let actual = actual {
            actualSize = memoryLayoutStrategy.sizeof(type: actual)
        } else {
            actualSize = nil
        }
        XCTAssertEqual(actualSize, 6)
    }
    
    func testCompileFailsWhenCastingUnionTypeToNonMemberType() {
        let union = Expression.Identifier("foo")
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u8)), .arithmeticType(.mutableInt(.u16))])), offset: offset, storage: .automaticStorage))
        ])
        let expr = Expression.As(expr: union, targetType: Expression.PrimitiveType(.bool(.mutableBool)))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8 | u16' to type `bool'")
        }
    }
    
    func testSuccessfullyCastUnionTypeToMemberType() {
        let expr = Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u8)), .arithmeticType(.mutableInt(.u16))])), offset: offset, storage: .automaticStorage))
        ])
        let expected: SymbolType = .arithmeticType(.mutableInt(.u8))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestPrimitiveTypeIsExpression_Succeeds() {
        let expr = Expression.Is(expr: ExprUtils.makeU8(value: 0),
                                 testType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let expected: SymbolType = .bool(.compTimeBool(true))
        let typeChecker = RvalueExpressionTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestPrimitiveTypeIsExpression_False() {
        let expr = Expression.Is(expr: ExprUtils.makeU8(value: 0),
                                 testType: Expression.PrimitiveType(.bool(.mutableBool)))
        let expected: SymbolType = .bool(.compTimeBool(false))
        let typeChecker = RvalueExpressionTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestUnionVariantTypeAgainstNonMemberType() {
        let union = Expression.Identifier("foo")
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u8)), .arithmeticType(.mutableInt(.u16))])), offset: offset, storage: .automaticStorage))
        ])
        let expr = Expression.Is(expr: union, testType: Expression.PrimitiveType(.bool(.mutableBool)))
        let expected: SymbolType = .bool(.compTimeBool(false))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testTestUnionVariantTypeAgainstKnownMemberType() {
        let union = Expression.Identifier("foo")
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u8)), .bool(.mutableBool)])), offset: offset, storage: .automaticStorage))
        ])
        let expr = Expression.Is(expr: union, testType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let expected: SymbolType = .bool(.mutableBool)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }
    
    func testCanAssignToUnionGivenTypeWhichConvertsToMatchingUnionMember() {
        let expr = Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                         rexpr: ExprUtils.makeU8(value: 1))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u16))])), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .unionType(UnionType([.arithmeticType(.mutableInt(.u16))])))
    }
    
    func testSubscriptAnArrayWithARange() {
        let symbols = SymbolTable(tuples: [
                ("foo", Symbol(type: .array(count: 10, elementType: .arithmeticType(.mutableInt(.u8))), offset: 0x0010))
            ])
            .withCompilerIntrinsicRangeType(MemoryLayoutStrategyTurtleTTL())
        
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(1)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(2))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testSubscriptADynamicArrayWithARange_1() {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = SymbolTable(tuples: [
                ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: offset))
            ])
            .withCompilerIntrinsicRangeType(MemoryLayoutStrategyTurtleTTL())
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(0))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))))
    }
    
    func testLiteralString() {
        let expr = Expression.LiteralString("foo")
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 3, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    func testAddressOfFunctionEvaluatesToFunctionPointerType() {
        let name = "foo"
        let expr = Expression.Unary(op: .ampersand, expression: Expression.Identifier(name))
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        let symbols = SymbolTable()
        symbols.bind(identifier: name, symbol: symbol)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        let expected: SymbolType = .pointer(.function(FunctionType(returnType: .void, arguments: [])))
        XCTAssertEqual(result, expected)
    }
    
    func testCallFunctionThroughFunctionPointer() {
        let expr = Expression.Call(callee: Expression.Identifier("bar"), arguments: [])
        let addressOfBar = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", returnType: .void, arguments: [])), offset: 0)),
            ("bar", Symbol(type: .pointer(.function(FunctionType(name: "foo", returnType: .void, arguments: []))), offset: addressOfBar)),
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        let expected: SymbolType = .void
        XCTAssertEqual(result, expected)
    }
    
    func testBitcastBoolAsU8() {
        let expr = Expression.Bitcast(expr: ExprUtils.makeU8(value: 0),
                                      targetType: Expression.PrimitiveType(.bool(.mutableBool)))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool(.mutableBool))
    }
    
    func testBitcastPointerToADifferentPointer() {
        let expr = Expression.Bitcast(expr: Expression.Identifier("foo"), targetType: Expression.PointerType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u8))), offset: SnapCompilerMetrics.kStaticStorageStartAddress))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.arithmeticType(.mutableInt(.u16))))
    }
    
    func testAssignment_automatic_conversion_from_object_to_pointer() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage)),
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2000, storage: .staticStorage))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                         rexpr: Expression.Identifier("bar"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.arithmeticType(.mutableInt(.u16))))
    }
    
    func testAssignment_automatic_conversion_from_trait_to_pointer() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        let traitDecl = TraitDeclaration(
            identifier: Expression.Identifier("Foo"),
            members: [],
            visibility: .privateVisibility)
        try TraitScanner(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .scan(trait: traitDecl)
        
        let traitObjectType = try symbols.resolveType(identifier: traitDecl.nameOfTraitObjectType)
        symbols.bind(identifier: "foo", symbol: Symbol(type: .pointer(traitObjectType), offset: 0x1000, storage: .staticStorage))
        
        let traitType = try symbols.resolveType(identifier: traitDecl.identifier.identifier)
        symbols.bind(identifier: "bar", symbol: Symbol(type: traitType, offset: 0x2000, storage: .staticStorage))
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                         rexpr: Expression.Identifier("bar"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(traitObjectType))
    }
    
    func testInitialAssignment_automatic_conversion_from_struct_to_trait_object() throws {
        let traitObjectType: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "", nameOfVtableType: "", symbols: SymbolTable()))
        let symbols = SymbolTable(tuples: [
            ("__Foo_Bar_vtable_instance", Symbol(type: .structType(StructType(name: "", symbols: SymbolTable())))),
            ("bar", Symbol(type: .structType(StructType(name: "Bar", symbols: SymbolTable())))),
            ("foo", Symbol(type: traitObjectType))
        ])
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                rexpr: Expression.Identifier("bar"))
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, traitObjectType)
    }
    
    func testSizeOfIsU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.SizeOf(ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.immutableInt(.u16)))
    }
    
    func testFunctionType() throws {
        let expected = SymbolType.function(FunctionType(name: "foo", mangledName: "foo", returnType: .void, arguments: [.arithmeticType(.immutableInt(.u16))], ast: nil))
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Expression.FunctionType(name: "foo",
                                           returnType: Expression.PrimitiveType(.void),
                                           arguments: [Expression.PrimitiveType(.arithmeticType(.immutableInt(.u16)))])
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testCannotInstantiateGenericFunctionTypeWithoutApplication() throws {
        let typeChecker = RvalueExpressionTypeChecker()
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let expr = Expression.GenericFunctionType(template: template)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic function `func foo[T](a: T) -> T'")
        }
    }
    
    func testGenericFunctionApplication_FailsWithIncorrectNumberOfArguments() throws {
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16),
                                                                 Expression.PrimitiveType(constU16)])
        
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic function type `foo@[u16, u16]'")
        }
    }
    
    func testGenericFunctionApplication() throws {
        let globalEnvironment = GlobalEnvironment()
        let constU16 = SymbolType.arithmeticType(.immutableInt(.u16))
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        let expected = SymbolType.function(FunctionType(name: "__foo_const_u16",
                                                        mangledName: "__foo_const_u16",
                                                        returnType: constU16,
                                                        arguments: [constU16],
                                                        ast: template))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testCannotTakeTheAddressOfGenericFunctionWithoutTypeArguments() {
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        
        let expr = Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo"))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic function `func foo[T](a: T) -> T'")
        }
    }
    
    func testCannotTakeTheAddressOfGenericFunctionWithInappropriateTypeArguments() {
        let constU16 = SymbolType.arithmeticType(.immutableInt(.u16))
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        
        let expr = Expression.Unary(op: .ampersand, expression: Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"), arguments: [Expression.PrimitiveType(constU16), Expression.PrimitiveType(constU16)]))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic function type `foo@[const u16, const u16]'")
        }
    }
    
    func testInferTypeArgumentsOfGenericFromContextInCall_u16() throws {
        let globalEnvironment = GlobalEnvironment()
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let expr = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [
                                    ExprUtils.makeU16(value: 65535)
                                   ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let expected = SymbolType.arithmeticType(.mutableInt(.u16))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentsOfGenericFromContextInCall_i8() throws {
        let globalEnvironment = GlobalEnvironment()
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let expr = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [
                                    ExprUtils.makeI8(value: -128)
                                   ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let expected = SymbolType.arithmeticType(.mutableInt(.i8))
        do {
            let actual = try typeChecker.check(expression: expr)
            XCTAssertEqual(actual, expected)
        }
        catch let err as CompilerError {
            print(err.description)
            throw err
        }
    }
    
    func testCannotInstantiateGenericStructTypeWithoutApplication() throws {
        let template = StructDeclaration(identifier: Expression.Identifier("foo"),
                                         typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                         members: [],
                                         visibility: .privateVisibility,
                                         isConst: false)
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericStructType(GenericStructType(template: template))))
        
        let expr = Expression.Identifier("foo")
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic struct `foo[T]'")
        }
    }
    
    func testGenericStructApplicationRequiresCorrectNumberOfArguments() throws {
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let template = StructDeclaration(identifier: Expression.Identifier("foo"),
                                         typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                         members: [],
                                         visibility: .privateVisibility,
                                         isConst: false)
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericStructType(GenericStructType(template: template))))
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16),
                                                                 Expression.PrimitiveType(constU16)])
        
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic struct type `foo@[u16, u16]'")
        }
    }
    
    func testGenericStructApplication_Empty() throws {
        let globalEnvironment = GlobalEnvironment()
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let template = StructDeclaration(identifier: Expression.Identifier("foo"),
                                         typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                         members: [],
                                         visibility: .privateVisibility,
                                         isConst: false)
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericStructType(GenericStructType(template: template))))
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        
        let concreteStructSymbols = SymbolTable(tuples: [
        ])
        let frame = Frame()
        concreteStructSymbols.frameLookupMode = .set(frame)
        concreteStructSymbols.enclosingFunctionNameMode = .set("foo")
        let expected = SymbolType.structType(StructType(name: "__foo_u16", symbols: concreteStructSymbols))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testGenericStructApplication_OneMember() throws {
        let globalEnvironment = GlobalEnvironment()
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let template = StructDeclaration(identifier: Expression.Identifier("foo"),
                                         typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                         members: [
                                            StructDeclaration.Member(name: "bar", type: Expression.Identifier("T"))
                                         ],
                                         visibility: .privateVisibility,
                                         isConst: false)
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericStructType(GenericStructType(template: template))))
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        
        let bar = Symbol(type: constU16, offset: 0, storage: .automaticStorage)
        let concreteStructSymbols = SymbolTable(tuples: [("bar", bar)])
        let frame = Frame()
        _ = frame.allocate(size: 1)
        frame.add(identifier: "bar", symbol: bar)
        concreteStructSymbols.frameLookupMode = .set(frame)
        concreteStructSymbols.enclosingFunctionNameMode = .set("foo")
        
        let expected = SymbolType.structType(StructType(name: "__foo_u16", symbols: concreteStructSymbols))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testGenericStructApplication_StructInitializer() throws {
        let globalEnvironment = GlobalEnvironment()
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let template = StructDeclaration(identifier: Expression.Identifier("foo"),
                                         typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                         members: [
                                            StructDeclaration.Member(name: "bar", type: Expression.Identifier("T"))
                                         ],
                                         visibility: .privateVisibility,
                                         isConst: false)
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericStructType(GenericStructType(template: template))))

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let app = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                    arguments: [Expression.PrimitiveType(constU16)])
        let expr = Expression.StructInitializer(expr: app, arguments: [
            Expression.StructInitializer.Argument(name: "bar", expr: Expression.LiteralInt(1)),
        ])

        let bar = Symbol(type: constU16, offset: 0, storage: .automaticStorage)
        let concreteStructSymbols = SymbolTable(tuples: [
            ("bar", bar)
        ])
        let frame = Frame()
        _ = frame.allocate(size: 1)
        frame.add(identifier: "bar", symbol: bar)
        concreteStructSymbols.frameLookupMode = .set(frame)
        concreteStructSymbols.enclosingFunctionNameMode = .set("foo")

        let expected = SymbolType.structType(StructType(name: "__foo_u16", symbols: concreteStructSymbols))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testCannotInstantiateGenericTraitTypeWithoutApplication() throws {
        let template = TraitDeclaration(
            identifier: Expression.Identifier("Foo"),
            typeArguments: [
                Expression.GenericTypeArgument(
                    identifier: Expression.Identifier("T"),
                    constraints: [])
            ],
            members: [],
            visibility: .privateVisibility)
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", symbol: Symbol(type: .genericTraitType(GenericTraitType(template: template))))
        
        let expr = Expression.Identifier("Foo")
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic trait `Foo[T]'")
        }
    }
    
    func testGenericTraitApplicationRequiresCorrectNumberOfArguments() throws {
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let template = TraitDeclaration(
            identifier: Expression.Identifier("Foo"),
            typeArguments: [
                Expression.GenericTypeArgument(
                    identifier: Expression.Identifier("T"),
                    constraints: [])
            ],
            members: [],
            visibility: .privateVisibility)
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", symbol: Symbol(type: .genericTraitType(GenericTraitType(template: template))))
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("Foo"),
                                                     arguments: [Expression.PrimitiveType(constU16),
                                                                 Expression.PrimitiveType(constU16)])
        
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic trait type `Foo@[u16, u16]'")
        }
    }
    
    func testGenericTraitApplication_Empty() throws {
        let globalEnvironment = GlobalEnvironment()
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let template = TraitDeclaration(
            identifier: Expression.Identifier("Foo"),
            typeArguments: [
                Expression.GenericTypeArgument(
                    identifier: Expression.Identifier("T"),
                    constraints: [])
            ],
            members: [],
            visibility: .privateVisibility)
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", symbol: Symbol(type: .genericTraitType(GenericTraitType(template: template))))
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("Foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        
        let expectedSymbols = SymbolTable()
        let frame = Frame()
        expectedSymbols.frameLookupMode = .set(frame)
        expectedSymbols.enclosingFunctionNameMode = .set("__Foo_u16")
        let expected = SymbolType.traitType(TraitType(
            name: "__Foo_u16",
            nameOfTraitObjectType: "__Foo_u16_object",
            nameOfVtableType: "__Foo_u16_vtable",
            symbols: expectedSymbols))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testGenericTraitApplication_OneMember() throws {
        let globalEnvironment = GlobalEnvironment()
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let template = TraitDeclaration(
            identifier: Expression.Identifier("Foo"),
            typeArguments: [
                Expression.GenericTypeArgument(
                    identifier: Expression.Identifier("T"),
                    constraints: [])
            ],
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: Expression.PointerType(Expression.FunctionType(
                            name: "bar",
                            returnType: Expression.Identifier("T"),
                            arguments: [
                                Expression.Identifier("T")
                            ])))
            ],
            visibility: .privateVisibility)
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", symbol: Symbol(type: .genericTraitType(GenericTraitType(template: template))))
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("Foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        
        let bar = Symbol(
            type: .pointer(.function(FunctionType(
                name: "bar",
                mangledName: "__Foo_u16_bar",
                returnType: constU16,
                arguments: [constU16],
                ast: nil))),
            offset: 0,
            storage: .automaticStorage)
        let concreteTraitSymbols = SymbolTable(tuples: [
            ("bar", bar)
        ])
        let frame = Frame()
        _ = frame.allocate(size: 1)
        frame.add(identifier: "bar", symbol: bar)
        concreteTraitSymbols.frameLookupMode = .set(frame)
        concreteTraitSymbols.enclosingFunctionNameMode = .set("__Foo_u16")
        
        let expected = SymbolType.traitType(TraitType(
            name: "__Foo_u16",
            nameOfTraitObjectType: "__Foo_u16_object",
            nameOfVtableType: "__Foo_u16_vtable",
            symbols: concreteTraitSymbols))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testEseq_Empty() throws {
        let expr = Expression.Eseq(children: [])
        let result = try RvalueExpressionTypeChecker().check(expression: expr)
        XCTAssertEqual(result, .void)
    }
    
    func testEseq_OneChild() throws {
        let expr = Expression.Eseq(children: [
            ExprUtils.makeU16(value: 1)
        ])
        let result = try RvalueExpressionTypeChecker().check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testEseq_MultipleChildren() throws {
        let expr = Expression.Eseq(children: [
            ExprUtils.makeBool(value: true),
            ExprUtils.makeU16(value: 1)
        ])
        let result = try RvalueExpressionTypeChecker().check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
}
