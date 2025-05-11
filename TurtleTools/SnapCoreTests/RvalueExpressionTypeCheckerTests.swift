//
//  RvalueExpressionTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

extension Env {
    func withCompilerIntrinsicRangeType(_ memoryLayoutStrategy: MemoryLayoutStrategy) -> Env {
        let sizeOfU16 = memoryLayoutStrategy.sizeof(type: .u16)
        let name = "Range"
        let typ: SymbolType = .structType(
            StructTypeInfo(
                name: name,
                fields: Env(tuples: [
                    (
                        "begin",
                        Symbol(type: .u16, storage: .automaticStorage(offset: 0 * sizeOfU16))
                    ),
                    (
                        "limit",
                        Symbol(type: .u16, storage: .automaticStorage(offset: 1 * sizeOfU16))
                    )
                ])
            )
        )
        bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return self
    }
}

final class RvalueExpressionTypeCheckerTests: XCTestCase {
    let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()

    func testUnsupportedExpressionThrows() {
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(
            try typeChecker.check(expression: UnsupportedExpression(sourceAnchor: nil))
        ) {
            var error: CompilerError? = nil
            XCTAssertNotNil(error = $0 as? CompilerError)
            XCTAssertEqual(error?.message, "unsupported expression: UnsupportedExpression")
        }
    }

    func testEveryIntegerLiteralIsAnIntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: LiteralInt(1)))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1)))
    }

    func testEveryBooleanLiteralIsABooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: LiteralBool(true)))
        XCTAssertEqual(result, .booleanType(.compTimeBool(true)))
    }

    func testExpressionUsesInvalidUnaryPrefixOperator() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(
            op: .star,
            expression: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`*' is not a prefix unary operator")
        }
    }

    func testUnaryNegationOfIntegerConstantIsIntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(
            op: .minus,
            expression: LiteralInt(1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(-1)))
    }

    func testUnaryNegationOfU8IsU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(
            op: .minus,
            expression: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testUnaryNegationOfU16IsU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(
            op: .minus,
            expression: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testUnaryNegationOfBooleanIsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(
            op: .minus,
            expression: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Unary operator `-' cannot be applied to an operand of type `bool'"
            )
        }
    }

    func testUnaryBitwiseNegationOfIntegerConstantIsIntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .tilde, expression: LiteralInt(1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(~1)))
    }

    func testUnaryBitwiseNegationOfU8IsU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .tilde, expression: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testUnaryBitwiseNegationOfU16IsU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .tilde, expression: ExprUtils.makeU16(value: 1000))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testUnaryBitwiseNegationOfBooleanIsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .tilde, expression: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Unary operator `~' cannot be applied to an operand of type `bool'"
            )
        }
    }

    func testUnaryLogicalNegationOfIntegerConstantIsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .bang, expression: LiteralInt(1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Unary operator `!' cannot be applied to an operand of type `integer constant 1'"
            )
        }
    }

    func testUnaryLogicalNegationOfU8IsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .bang, expression: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Unary operator `!' cannot be applied to an operand of type `u8'"
            )
        }
    }

    func testUnaryLogicalNegationOfU16IsInvalid() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .bang, expression: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Unary operator `!' cannot be applied to an operand of type `u16'"
            )
        }
    }

    func testUnaryLogicalNegationOfBooleanIsBool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Unary(op: .bang, expression: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(true)))
    }

    func testBinary_IntegerConstant_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_IntegerConstant_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralInt(1000),
            right: LiteralBool(false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `integer constant 1000' and `boolean constant false'"
            )
        }
    }

    func testBinary_U16_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U16_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralBool(false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `u16' and `boolean constant false'"
            )
        }
    }

    func testBinary_U8_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_U8_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralBool(false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `u8' and `boolean constant false'"
            )
        }
    }

    func testBinary_BooleanConstant_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralBool(false),
            right: ExprUtils.makeBool(value: false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_BooleanConstant_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralBool(false),
            right: LiteralBool(false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(true)))
    }

    func testBinary_BooleanConstant_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralBool(false),
            right: LiteralInt(0)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `boolean constant false' and `integer constant 0'"
            )
        }
    }

    func testBinary_BooleanConstant_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralBool(false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `boolean constant false' and `u16'"
            )
        }
    }

    func testBinary_BooleanConstant_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: LiteralBool(false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `boolean constant false' and `u8'"
            )
        }
    }

    func testBinary_Bool_Eq_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_Bool_Eq_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeBool(value: false),
            right: LiteralBool(false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_Bool_Eq_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(0)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `bool' and `integer constant 0'"
            )
        }
    }

    func testBinary_Bool_Eq_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Eq_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonEq(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `==' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_IntegerConstant_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(false)))
    }

    func testBinary_IntegerConstant_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_IntegerConstant_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralInt(1000),
            right: LiteralBool(false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `integer constant 1000' and `boolean constant false'"
            )
        }
    }

    func testBinary_U16_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U16_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralBool(false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `u16' and `boolean constant false'"
            )
        }
    }

    func testBinary_U8_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_U8_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralBool(false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `u8' and `boolean constant false'"
            )
        }
    }

    func testBinary_Bool_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `bool' and `integer constant 1'"
            )
        }
    }

    func testBinary_Bool_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_Bool_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: ExprUtils.makeBool(value: false),
            right: LiteralBool(false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_BooleanConstant_Ne_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralBool(false),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `boolean constant false' and `integer constant 1'"
            )
        }
    }

    func testBinary_BooleanConstant_Ne_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralBool(false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `boolean constant false' and `u16'"
            )
        }
    }

    func testBinary_BooleanConstant_Ne_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralBool(false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `!=' cannot be applied to operands of types `boolean constant false' and `u8'"
            )
        }
    }

    func testBinary_BooleanConstant_Ne_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralBool(false),
            right: ExprUtils.makeBool(value: false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_BooleanConstant_Ne_BooleanConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonNe(
            left: LiteralBool(false),
            right: LiteralBool(false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(false)))
    }

    func testBinary_IntegerConstant_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(false)))
    }

    func testBinary_IntegerConstant_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Lt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_Bool_Lt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Lt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Lt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLt(
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<' cannot be applied to operands of types `bool' and `integer constant 1'"
            )
        }
    }

    func testBinary_IntegerConstant_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(false)))
    }

    func testBinary_IntegerConstant_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Gt_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_Bool_Gt_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Gt_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Gt_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGt(
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>' cannot be applied to operands of types `bool' and `integer constant 1'"
            )
        }
    }

    func testBinary_IntegerConstant_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(true)))
    }

    func testBinary_IntegerConstant_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<=' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<=' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: LiteralInt(1),
            right: LiteralInt(1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(true)))
    }

    func testBinary_U8_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<=' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Le_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<=' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_Bool_Le_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<=' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Le_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<=' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Le_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonLe(
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<=' cannot be applied to operands of types `bool' and `integer constant 1'"
            )
        }
    }

    func testBinary_IntegerConstant_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .booleanType(.compTimeBool(true)))
    }

    func testBinary_IntegerConstant_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>=' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U16_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>=' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_U8_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>=' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Ge_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>=' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_Bool_Ge_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>=' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Ge_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>=' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Ge_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = ExprUtils.makeComparisonGe(
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>=' cannot be applied to operands of types `bool' and `integer constant 1'"
            )
        }
    }

    func testBinary_IntegerConstant_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(2000)))
    }

    func testBinary_IntegerConstant_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_Plus_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: LiteralInt(100),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_Plus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Plus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Plus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Plus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_Plus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Plus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Plus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .plus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_Minus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0)))
    }

    func testBinary_IntegerConstant_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: LiteralInt(100),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `-' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_Minus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `-' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Minus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `-' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Minus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `-' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_Minus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `-' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Minus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `-' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Minus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .minus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `-' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1_000_000)))
    }

    func testBinary_IntegerConstant_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: LiteralInt(100),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: LiteralInt(100),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `*' cannot be applied to operands of types `integer constant 100' and `bool'"
            )
        }
    }

    func testBinary_U16_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `*' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `*' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Multiply_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `*' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_Multiply_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `*' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Multiply_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `*' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Multiply_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .star,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `*' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1)))
    }

    func testBinary_IntegerConstant_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: LiteralInt(100),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: LiteralInt(100),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `/' cannot be applied to operands of types `integer constant 100' and `bool'"
            )
        }
    }

    func testBinary_U16_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `/' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `/' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Divide_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `/' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_Divide_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `/' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Divide_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `/' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Divide_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .divide,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `/' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: LiteralInt(1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0)))
    }

    func testBinary_IntegerConstant_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: LiteralInt(1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: LiteralInt(100),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: LiteralInt(100),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `%' cannot be applied to operands of types `integer constant 100' and `bool'"
            )
        }
    }

    func testBinary_U16_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU16(value: 1000),
            right: LiteralInt(1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `%' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 1000)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `%' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_Modulus_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `%' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_Modulus_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `%' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_Modulus_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `%' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_Modulus_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .modulus,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `%' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: LiteralInt(0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0b10101010_10101010)))
    }

    func testBinary_IntegerConstant_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_BitwiseAnd_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_BitwiseAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: LiteralInt(0b10101010),
            right: ExprUtils.makeU8(value: 0b11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_BitwiseAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_BitwiseAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_BitwiseAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_BitwiseAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_BitwiseAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_BitwiseAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_BitwiseAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .ampersand,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: LiteralInt(0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0b11111111_11111111)))
    }

    func testBinary_IntegerConstant_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_BitwiseOr_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_BitwiseOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: LiteralInt(0b10101010),
            right: ExprUtils.makeU8(value: 0b11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_BitwiseOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `|' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `|' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_BitwiseOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_BitwiseOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `|' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_BitwiseOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `|' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_BitwiseOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `|' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_BitwiseOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `|' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_BitwiseOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .pipe,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `|' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: LiteralInt(0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(0b1010101_01010101)))
    }

    func testBinary_IntegerConstant_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_BitwiseXor_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_BitwiseXor_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: LiteralInt(0b10101010),
            right: ExprUtils.makeU8(value: 0b11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_BitwiseXor_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `^' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseXor_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_BitwiseXor_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `^' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_BitwiseXor_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_BitwiseXor_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `^' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_BitwiseXor_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `^' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_BitwiseXor_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `^' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_BitwiseXor_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `^' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_BitwiseXor_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .caret,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `^' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: LiteralInt(1),
            right: LiteralInt(2)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1 << 2)))
    }

    func testBinary_IntegerConstant_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_LeftShift_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_LeftShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: LiteralInt(1),
            right: ExprUtils.makeU8(value: 2)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_LeftShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<<' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_LeftShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_LeftShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<<' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_LeftShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_LeftShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<<' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_LeftShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<<' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_LeftShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<<' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_LeftShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<<' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_LeftShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .leftDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `<<' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: LiteralInt(2),
            right: LiteralInt(1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(2 >> 1)))
    }

    func testBinary_IntegerConstant_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_RightShift_U8_YieldingU16() {
        // Adding an integer constant to u8 may yield a u16 value if we can
        // determine at compile time that the value will be greater than 255.
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: LiteralInt(1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_IntegerConstant_RightShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: LiteralInt(1),
            right: ExprUtils.makeU8(value: 2)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_IntegerConstant_RightShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>>' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_RightShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U16_RightShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>>' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testBinary_U8_RightShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testBinary_U8_RightShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>>' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_RightShift_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>>' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_RightShift_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>>' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_RightShift_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>>' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_RightShift_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .rightDoubleAngle,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `>>' cannot be applied to two `bool' operands"
            )
        }
    }

    func testBinary_IntegerConstant_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: LiteralInt(2),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `integer constant 2' and `integer constant 1'"
            )
        }
    }

    func testBinary_IntegerConstant_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `integer constant 43690' and `u16'"
            )
        }
    }

    func testBinary_IntegerConstant_LogicalAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: LiteralInt(1),
            right: ExprUtils.makeU8(value: 2)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `integer constant 1' and `u8'"
            )
        }
    }

    func testBinary_IntegerConstant_LogicalAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `u16' and `integer constant 65535'"
            )
        }
    }

    func testBinary_U16_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to two `u16' operands"
            )
        }
    }

    func testBinary_U16_LogicalAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `u16' and `u8'"
            )
        }
    }

    func testBinary_U16_LogicalAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `u8' and `integer constant 100'"
            )
        }
    }

    func testBinary_U8_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `u8' and `u16'"
            )
        }
    }

    func testBinary_U8_LogicalAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to two `u8' operands"
            )
        }
    }

    func testBinary_U8_LogicalAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_LogicalAnd_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_LogicalAnd_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_LogicalAnd_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `&&' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_LogicalAnd_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doubleAmpersand,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBinary_IntegerConstant_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: LiteralInt(2),
            right: LiteralInt(1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `integer constant 2' and `integer constant 1'"
            )
        }
    }

    func testBinary_IntegerConstant_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: LiteralInt(0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `integer constant 43690' and `u16'"
            )
        }
    }

    func testBinary_IntegerConstant_LogicalOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: LiteralInt(1),
            right: ExprUtils.makeU8(value: 2)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `integer constant 1' and `u8'"
            )
        }
    }

    func testBinary_IntegerConstant_LogicalOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: LiteralInt(1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `integer constant 1000' and `bool'"
            )
        }
    }

    func testBinary_U16_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: LiteralInt(0b11111111_11111111)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `u16' and `integer constant 65535'"
            )
        }
    }

    func testBinary_U16_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU16(value: 0b10101010_10101010),
            right: ExprUtils.makeU16(value: 0b11111111_11111111)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to two `u16' operands"
            )
        }
    }

    func testBinary_U16_LogicalOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `u16' and `u8'"
            )
        }
    }

    func testBinary_U16_LogicalOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU16(value: 1000),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `u16' and `bool'"
            )
        }
    }

    func testBinary_U8_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU8(value: 1),
            right: LiteralInt(100)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `u8' and `integer constant 100'"
            )
        }
    }

    func testBinary_U8_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU16(value: 100)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `u8' and `u16'"
            )
        }
    }

    func testBinary_U8_LogicalOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to two `u8' operands"
            )
        }
    }

    func testBinary_U8_LogicalOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeU8(value: 1),
            right: ExprUtils.makeBool(value: false)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `u8' and `bool'"
            )
        }
    }

    func testBinary_Bool_LogicalOr_IntegerConstant() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeBool(value: false),
            right: LiteralInt(1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `bool' and `integer constant 1000'"
            )
        }
    }

    func testBinary_Bool_LogicalOr_U16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU16(value: 1000)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `bool' and `u16'"
            )
        }
    }

    func testBinary_Bool_LogicalOr_U8() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeU8(value: 1)
        )
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `||' cannot be applied to operands of types `bool' and `u8'"
            )
        }
    }

    func testBinary_Bool_LogicalOr_Bool() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = Binary(
            op: .doublePipe,
            left: ExprUtils.makeBool(value: false),
            right: ExprUtils.makeBool(value: false)
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testAssignment_IntegerConstant_to_U16_Overflows() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(0x10000))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `65536' overflows when stored into `u16'"
            )
        }
    }

    func testAssignment_IntegerConstant_to_U8_Overflows() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(0x100))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `256' overflows when stored into `u8'"
            )
        }
    }

    func testAssignment_IntegerConstant_to_I16_Overflows() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(32768))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `32768' overflows when stored into `i16'"
            )
        }
    }

    func testAssignment_IntegerConstant_to_I16_Underflows() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(-32769))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `-32769' overflows when stored into `i16'"
            )
        }
    }

    func testAssignment_IntegerConstant_to_I8_Overflows() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(128))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `128' overflows when stored into `i8'"
            )
        }
    }

    func testAssignment_IntegerConstant_to_I8_Underflows() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(-129))
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `-129' overflows when stored into `i8'"
            )
        }
    }

    func testAssignment_IntegerConstant_to_U16() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testAssignment_IntegerConstant_to_U8() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 0xab))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testAssignment_U16_to_U16() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testAssignment_U8_to_U8() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testAssignment_Bool_to_Bool() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .bool, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: false))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testAssignment_ArrayOfU8_to_DynamicArrayOfU8() {
        let symbols = Env(tuples: [
            ("src", Symbol(type: .array(count: 5, elementType: .u8), offset: 0x0010)),
            ("dst", Symbol(type: .dynamicArray(elementType: .u8), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = ExprUtils.makeAssignment(name: "dst", right: Identifier("src"))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .u8))
    }

    func testIdentifier_U16() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testIdentifier_U8() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testIdentifier_Boolean() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .bool, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testFailBecauseFunctionCallUsesIncorrectParameterType() {
        let expr = Call(
            callee: Identifier("foo"),
            arguments: [ExprUtils.makeBool(value: false)]
        )
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(name: "foo", returnType: .u8, arguments: [.u8])
                    ),
                    offset: 0x0000
                )
            )
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `bool' to expected argument type `u8' in call to `foo'"
            )
        }
    }

    func testFailBecauseFunctionCallUsesIncorrectNumberOfParameters() {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(name: "foo", returnType: .u8, arguments: [.u8])
                    ),
                    offset: 0x0000
                )
            )
        ])
        let expr = Call(
            callee: Identifier("foo"),
            arguments: []
        )
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of arguments in call to `foo'")
        }
    }

    func testFailBecauseAssignmentCannotConvertLargeIntegerConstantToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(65536))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `65536' overflows when stored into `u16'"
            )
        }
    }

    func testFailBecauseAssignmentCannotConvertLargeIntegerConstantToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: LiteralInt(256))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `256' overflows when stored into `u8'"
            )
        }
    }

    func testFailBecauseAssignmentCannotConvertU16ToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
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
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot assign value of type `bool' to type `u8'"
            )
        }
    }

    func testFailBecauseAssignmentCannotConvertU16ToI16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot assign value of type `u16' to type `i16'"
            )
        }
    }

    func testFailBecauseAssignmentCannotConvertU16ToI8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i8, offset: 0x0010))
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
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i8, offset: 0x0010))
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
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot assign value of type `i16' to type `u16'"
            )
        }
    }

    func testFailBecauseAssignmentCannotConvertI8ToU8() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeI8(value: -1))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0x0010))
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
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testAssignmentWhichConvertsU8ToI16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i16)
    }

    func testAssignmentWhichConvertsI8ToI16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeI8(value: -1))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i16)
    }

    func testBoolasVoid() {
        let expr = As(
            expr: ExprUtils.makeBool(value: false),
            targetType: PrimitiveType(.void)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `bool' to type `void'"
            )
        }
    }

    func testBoolasU16() {
        let expr = As(
            expr: ExprUtils.makeBool(value: false),
            targetType: PrimitiveType(.u16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `bool' to type `u16'"
            )
        }
    }

    func testBoolasU8() {
        let expr = As(
            expr: ExprUtils.makeBool(value: false),
            targetType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `bool' to type `u8'"
            )
        }
    }

    func testMakeU8() {
        let expr = ExprUtils.makeU8(value: 0xff)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testMakeU16() {
        let expr = ExprUtils.makeU16(value: 0xff)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testMakeI8() {
        let expr = ExprUtils.makeI8(value: -1)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i8)
    }

    func testMakeI16() {
        let expr = ExprUtils.makeI16(value: -16)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i16)
    }

    func testMakeBool() {
        let expr = ExprUtils.makeBool(value: false)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBoolasI16() {
        let expr = As(
            expr: ExprUtils.makeBool(value: false),
            targetType: PrimitiveType(.i16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `bool' to type `i16'"
            )
        }
    }

    func testBoolasI8() {
        let expr = As(
            expr: ExprUtils.makeBool(value: false),
            targetType: PrimitiveType(.i8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `bool' to type `i8'"
            )
        }
    }

    func testBoolasBool() {
        let expr = As(
            expr: ExprUtils.makeBool(value: false),
            targetType: PrimitiveType(.bool)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testU8asVoid() {
        let expr = As(
            expr: ExprUtils.makeU8(value: 1),
            targetType: PrimitiveType(.void)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `u8' to type `void'"
            )
        }
    }

    func testU8asU16() {
        let expr = As(
            expr: ExprUtils.makeU8(value: 1),
            targetType: PrimitiveType(.u16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testU8asU8() {
        let expr = As(
            expr: ExprUtils.makeU8(value: 1),
            targetType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testU8asI16() {
        // Every value representable in a u8 is also representable in a i16.
        let expr = As(
            expr: ExprUtils.makeU8(value: 0xff),
            targetType: PrimitiveType(.i16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i16)
    }

    func testU8asI8() {
        // Conversion from u8 to i8 is available in an explicit cast.
        let expr = As(
            expr: ExprUtils.makeU8(value: 0xff),
            targetType: PrimitiveType(.i8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i8)
    }

    func testU8asBool() {
        let expr = As(
            expr: ExprUtils.makeU8(value: 1),
            targetType: PrimitiveType(.bool)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `u8' to type `bool'"
            )
        }
    }

    func testU16asVoid() {
        let expr = As(
            expr: ExprUtils.makeU16(value: 0xffff),
            targetType: PrimitiveType(.void)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `u16' to type `void'"
            )
        }
    }

    func testU16asU16() {
        let expr = As(
            expr: ExprUtils.makeU16(value: 0xffff),
            targetType: PrimitiveType(.u16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testU16asU8() {
        let expr = As(
            expr: ExprUtils.makeU16(value: 0xffff),
            targetType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testU16asI16() {
        // Conversion from u16 to i16 is available in an explicit cast.
        let expr = As(
            expr: ExprUtils.makeU16(value: 0xffff),
            targetType: PrimitiveType(.i16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i16)
    }

    func testU16asI8() {
        // Conversion from u16 to i8 is available in an explicit cast.
        let expr = As(
            expr: ExprUtils.makeU16(value: 0xffff),
            targetType: PrimitiveType(.i8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i8)
    }

    func testU16asBool() {
        let expr = As(
            expr: ExprUtils.makeU16(value: 0xffff),
            targetType: PrimitiveType(.bool)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `u16' to type `bool'"
            )
        }
    }

    func testI16asVoid() {
        let expr = As(
            expr: ExprUtils.makeI16(value: -1),
            targetType: PrimitiveType(.void)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `i16' to type `void'"
            )
        }
    }

    func testI16asU16() {
        // Conversion from i16 to u16 is available in an explicit cast.
        let expr = As(
            expr: ExprUtils.makeI16(value: -1),
            targetType: PrimitiveType(.u16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testI16asU8() {
        // Conversion from i16 to u8 is available in an explicit cast.
        let expr = As(
            expr: ExprUtils.makeI16(value: -1),
            targetType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testI16asI8() {
        let expr = As(
            expr: ExprUtils.makeI16(value: -1),
            targetType: PrimitiveType(.i8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i8)
    }

    func testI16asI16() {
        let expr = As(
            expr: ExprUtils.makeI16(value: -1),
            targetType: PrimitiveType(.i16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .i16)
    }

    func testI16asBool() {
        let expr = As(
            expr: ExprUtils.makeI16(value: -1),
            targetType: PrimitiveType(.bool)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `i16' to type `bool'"
            )
        }
    }

    func testCannotConvertArrayLiteralsOfDifferentLengths() {
        let expr = As(
            expr: LiteralArray(
                arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
                elements: [ExprUtils.makeU8(value: 1)]
            ),
            targetType: ArrayType(count: LiteralInt(10), elementType: PrimitiveType(.u16))
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `[1]u8' to type `[10]u16'"
            )
        }
    }

    func testArrayOfU8AsArrayOfU16() {
        let expr = As(
            expr: LiteralArray(
                arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
                elements: [ExprUtils.makeU8(value: 1)]
            ),
            targetType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u16))
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u16))
    }

    func testIntegerConstantAsU16() {
        let expr = As(
            expr: LiteralInt(0),
            targetType: PrimitiveType(.u16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testIntegerConstantAsU8() {
        let expr = As(
            expr: LiteralInt(0),
            targetType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testIntegerConstantAsU8_Overflows() {
        let expr = As(
            expr: LiteralInt(256),
            targetType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `256' overflows when stored into `u8'"
            )
        }
    }

    func testIntegerConstantAsU16_Overflows() {
        let expr = As(
            expr: LiteralInt(65536),
            targetType: PrimitiveType(.u16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `65536' overflows when stored into `u16'"
            )
        }
    }

    func testIntegerConstantAsI8_Overflows() {
        let expr = As(
            expr: LiteralInt(128),
            targetType: PrimitiveType(.i8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `128' overflows when stored into `i8'"
            )
        }
    }

    func testIntegerConstantAsI16_Overflows() {
        let expr = As(
            expr: LiteralInt(32768),
            targetType: PrimitiveType(.i16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `32768' overflows when stored into `i16'"
            )
        }
    }

    func testIntegerConstantAsU8_Overflows_Negative() {
        let expr = As(
            expr: LiteralInt(-1),
            targetType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `-1' overflows when stored into `u8'"
            )
        }
    }

    func testIntegerConstantAsU16_Overflows_Negative() {
        let expr = As(
            expr: LiteralInt(-1),
            targetType: PrimitiveType(.u16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `-1' overflows when stored into `u16'"
            )
        }
    }

    func testIntegerConstantAsI8_Overflows_Negative() {
        let expr = As(
            expr: LiteralInt(-129),
            targetType: PrimitiveType(.i8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `-129' overflows when stored into `i8'"
            )
        }
    }

    func testIntegerConstantAsI16_Overflows_Negative() {
        let expr = As(
            expr: LiteralInt(-32769),
            targetType: PrimitiveType(.i16)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "integer constant `-32769' overflows when stored into `i16'"
            )
        }
    }

    func testIntegerConstantAsBool() {
        let expr = As(
            expr: LiteralInt(0),
            targetType: PrimitiveType(.bool)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `integer constant 0' to type `bool'"
            )
        }
    }

    func testBooleanConstantasBool() {
        let expr = As(
            expr: LiteralBool(false),
            targetType: PrimitiveType(.bool)
        )
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

    func testSubscriptOfZeroWithI8() {
        doTestSubscriptOfZero(.i8)
    }

    func testSubscriptOfZeroWithI16() {
        doTestSubscriptOfZero(.i16)
    }

    func testSubscriptOfZeroWithBool() {
        doTestSubscriptOfZero(.bool)
    }

    private func doTestSubscriptOfZero(_ symbolType: SymbolType) {
        let ident = "foo"
        let symbols = Env(tuples: [
            (ident, Symbol(type: symbolType, offset: 0x0010))
        ])
        let zero = LiteralInt(0)
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: zero)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "value of type `\(symbolType)' has no subscripts"
            )
        }
    }

    func testArraySubscriptFailsWithNonarithmeticIndex() {
        let ident = "foo"
        let symbols = Env(tuples: [
            (ident, Symbol(type: .array(count: 3, elementType: .bool), offset: 0x0010))
        ])
        let index = ExprUtils.makeBool(value: false)
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: index)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot subscript a value of type `[3]bool' with an argument of type `bool'"
            )
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
        let symbols = Env(tuples: [
            (ident, Symbol(type: .array(count: 3, elementType: elementType), offset: 0x0010))
        ])
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: LiteralInt(0))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, elementType)
    }

    func testEmptyArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(0), elementType: PrimitiveType(.u8)),
            elements: []
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 0, elementType: .u8))
    }

    func testSingletonArrayOfU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
            elements: [val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u8))
    }

    func testSingletonArrayOfU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u16)),
            elements: [val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u16))
    }

    func testSingletonArrayOfBoolean() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = LiteralBool(false)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.bool)),
            elements: [val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .bool))
    }

    func testSingletonArrayOfArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(0), elementType: PrimitiveType(.u8)),
            elements: []
        )
        let arr = LiteralArray(
            arrayType: ArrayType(
                count: LiteralInt(1),
                elementType: ArrayType(count: LiteralInt(0), elementType: PrimitiveType(.u8))
            ),
            elements: [val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 1, elementType: .array(count: 0, elementType: .u8)))
    }

    func testArrayOfU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU8(value: 0)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(2), elementType: PrimitiveType(.u8)),
            elements: [val, val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u8))
    }

    func testArrayOfU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeU16(value: 1000)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(2), elementType: PrimitiveType(.u16)),
            elements: [val, val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u16))
    }

    func testArrayOfI8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeI8(value: 100)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(2), elementType: PrimitiveType(.i8)),
            elements: [val, val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .i8))
    }

    func testArrayOfI16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = ExprUtils.makeI16(value: 1000)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(2), elementType: PrimitiveType(.i16)),
            elements: [val, val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .i16))
    }

    func testArrayOfBoolean() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = LiteralBool(false)
        let arr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(2), elementType: PrimitiveType(.bool)),
            elements: [val, val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .bool))
    }

    func testArrayOfArray() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let val = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(0), elementType: PrimitiveType(.u8)),
            elements: []
        )
        let arr = LiteralArray(
            arrayType: ArrayType(
                count: LiteralInt(2),
                elementType: ArrayType(count: LiteralInt(0), elementType: PrimitiveType(.u8))
            ),
            elements: [val, val]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 2, elementType: .array(count: 0, elementType: .u8)))
    }

    func testArrayLiteralHasNonConvertibleType() {
        let expr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(2), elementType: PrimitiveType(.bool)),
            elements: [
                LiteralInt(0),
                LiteralBool(false)
            ]
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `integer constant 0' to type `bool' in `[2]bool' array literal"
            )
        }
    }

    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoU8() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
            elements: [
                LiteralInt(0),
                LiteralInt(1),
                LiteralInt(2)
            ]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u8))
    }

    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u16)),
            elements: [
                LiteralInt(0),
                LiteralInt(0),
                LiteralInt(1000)
            ]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u16))
    }

    func testInferTypeOfArrayOfHeterogeneousArithmeticTypesWhichFitIntoU8() {
        let expr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(3), elementType: PrimitiveType(.u8)),
            elements: [
                ExprUtils.makeU8(value: 0),
                ExprUtils.makeU8(value: 0),
                ExprUtils.makeU8(value: 0)
            ]
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u8))
    }

    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI8_1() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.i8)),
            elements: [
                LiteralInt(-1),
                LiteralInt(-2),
                LiteralInt(-3)
            ]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .i8))
    }

    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI8_2() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.i8)),
            elements: [
                LiteralInt(0),
                LiteralInt(-1),
                LiteralInt(-2)
            ]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .i8))
    }

    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI16_1() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.i16)),
            elements: [
                LiteralInt(-1000),
                LiteralInt(-2000),
                LiteralInt(-3000)
            ]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .i16))
    }

    func testInferTypeOfArrayOfIntegerConstantsWhichFitIntoI16_2() {
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        let arr = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.i16)),
            elements: [
                LiteralInt(1000),
                LiteralInt(-2000),
                LiteralInt(-3000)
            ]
        )
        XCTAssertNoThrow(result = try typeChecker.check(expression: arr))
        XCTAssertEqual(result, .array(count: 3, elementType: .i16))
    }

    func testCannotAssignFunctionToArray() {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(FunctionTypeInfo(returnType: .bool, arguments: [.u8, .u16])),
                    offset: 0x0010
                )
            ),
            ("bar", Symbol(type: .array(count: nil, elementType: .u16), offset: 0x0012))
        ])
        let expr = ExprUtils.makeAssignment(name: "bar", right: Identifier("foo"))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "inappropriate use of a function type (Try taking the function's address instead.)"
            )
        }
    }

    func testAccessInvalidMemberOfLiteralArray() {
        let expr = Get(
            expr: LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [
                    ExprUtils.makeU8(value: 0),
                    ExprUtils.makeU8(value: 1),
                    ExprUtils.makeU8(value: 2)
                ]
            ),
            member: Identifier("length")
        )
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `[3]u8' has no member `length'")
        }
    }

    func testGetLengthOfLiteralArray() {
        let expr = Get(
            expr: LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [
                    ExprUtils.makeU8(value: 0),
                    ExprUtils.makeU8(value: 1),
                    ExprUtils.makeU8(value: 2)
                ]
            ),
            member: Identifier("count")
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testGetLengthOfDynamicArray() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("count")
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .u8), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testGetCountOfRange() throws {
        let symbols = Env()
            .withCompilerIntrinsicRangeType(MemoryLayoutStrategyNull())
        let expr = Get(
            expr: ExprUtils.makeRange(0, 10),
            member: Identifier("count")
        )
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .u16)
    }

    func testTypeOfPrimitiveTypeExpression() {
        let expr = PrimitiveType(.u8)
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testTypeOfArrayTypeExpression() {
        let expr = ArrayType(count: nil, elementType: PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: nil, elementType: .u8))
    }

    func testCountOfArrayTypeIsConstIntExpression() {
        let expr = ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 1, elementType: .u8))
    }

    func testCountOfArrayTypeIsConstIntExpressionAndWeCanDoMathThere() {
        let expr = ArrayType(
            count: Binary(op: .plus, left: LiteralInt(1), right: LiteralInt(1)),
            elementType: PrimitiveType(.u8)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 2, elementType: .u8))
    }

    func testArrayCountMustHaveTypeOfConstInt() {
        let expr = ArrayType(count: ExprUtils.makeU8(value: 1), elementType: PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "array count must be a compile time constant, got `u8' instead"
            )
        }
    }

    func testTypeOfDynamicArrayTypeExpression() {
        let expr = DynamicArrayType(PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .u8))
    }

    func testGetValueOfStructMemberLoadsTheValue() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("bar")
        )
        let typ = StructTypeInfo(
            name: "foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: 0))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testGetValueOfNonexistentStructMember() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("asdf")
        )
        let typ = StructTypeInfo(
            name: "foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(tuples: [
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
        let expr = StructInitializer(identifier: Identifier("Foo"), arguments: [])
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "use of unresolved identifier: `Foo'")
        }
    }

    func testStructInitializerExpression_Empty() {
        let expr = StructInitializer(identifier: Identifier("Foo"), arguments: [])
        let typ: SymbolType = .structType(StructTypeInfo(name: "Foo", fields: Env()))
        let symbols = Env(typeDict: ["Foo": typ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), typ)
    }

    func testStructInitializerExpression_IncorrectMemberName() {
        typealias Arg = StructInitializer.Argument
        let expr = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                Arg(name: "asdf", expr: LiteralInt(0))
            ]
        )
        let typ = StructTypeInfo(name: "foo", fields: Env())
        let symbols = Env(typeDict: ["Foo": .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `Foo' has no member `asdf'")
        }
    }

    func testStructInitializerExpression_ArgumentTypeIsIncorrect() {
        typealias Arg = StructInitializer.Argument
        let expr = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                Arg(name: "bar", expr: LiteralBool(false))
            ]
        )
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(typeDict: ["Foo": .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `boolean constant false' to expected argument type `u16' in initialization of `bar'"
            )
        }
    }

    func testStructInitializerExpression_ExpectsAndReceivesTwoValidArguments() {
        typealias Arg = StructInitializer.Argument
        let expr = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                Arg(name: "bar", expr: LiteralInt(0)),
                Arg(name: "baz", expr: LiteralInt(0))
            ]
        )
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0))),
                ("baz", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(typeDict: ["Foo": .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), .structType(typ))
    }

    func testStructInitializerExpression_MembersMayNotBeSpecifiedMoreThanOneTime() {
        typealias Arg = StructInitializer.Argument
        let expr = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                Arg(name: "bar", expr: LiteralInt(0)),
                Arg(name: "bar", expr: LiteralInt(0))
            ]
        )
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(typeDict: ["Foo": .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "initialization of member `bar' can only occur one time"
            )
        }
    }

    func testStructInitializerExpression_TheresNothingWrongWithOmittingMembers() {
        typealias Arg = StructInitializer.Argument
        let expr = StructInitializer(identifier: Identifier("Foo"), arguments: [])
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0))),
                ("baz", Symbol(type: .u16, storage: .automaticStorage(offset: 2)))
            ])
        )
        let symbols = Env(typeDict: ["Foo": .structType(typ)])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertEqual(try typeChecker.check(expression: expr), .structType(typ))
    }

    func testTypeExpressionWithPointerTypeOfPrimitiveType_u8() {
        let expr = PointerType(PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.u8))
    }

    func testTypeExpressionWithPointerToPointer() {
        let expr = PointerType(PointerType(PrimitiveType(.u8)))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.pointer(.u8)))
    }

    func testTypeExpressionWithConstType_u8() {
        let expr = ConstType(PrimitiveType(.u8))
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.immutableInt(.u8)))
    }

    func testTypeExpressionWithMutableType_u8() throws {
        let expr = MutableType(PrimitiveType(.arithmeticType(.immutableInt(.u8))))
        let typeChecker = RvalueExpressionTypeChecker()
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .u8)
    }

    func testCannotTakeAddressOfLiteralInt() {
        let expr = Unary(op: .ampersand, expression: LiteralInt(0))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "lvalue required as operand of unary operator `&'"
            )
        }
    }

    func testCannotTakeAddressOfLiteralBool() {
        let expr = Unary(op: .ampersand, expression: LiteralBool(false))
        let typeChecker = RvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "lvalue required as operand of unary operator `&'"
            )
        }
    }

    func testAddressOfIdentifierForU8Symbol() {
        let expr = Unary(op: .ampersand, expression: Identifier("foo"))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, offset: 0xabcd))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.u8))
    }

    func testDereferencePointerToU8() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("pointee")
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u8), offset: 0))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testGetValueOfStructMemberThroughPointerLoadsTheValue() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("bar")
        )
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.structType(typ)), offset: 0))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testGetValueOfNonexistentStructMemberThroughPointer() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("asdf")
        )
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(tuples: [
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
        let si = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                StructInitializer.Argument(name: "bar", expr: LiteralInt(1000))
            ]
        )
        let expr = Get(expr: si, member: Identifier("bar"))
        let symbols = Env()
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.compTimeInt(1000)))
    }

    func testResolveUnionTypeExpression() {
        let expr = UnionType([
            PrimitiveType(.u8),
            PrimitiveType(.u16),
            PrimitiveType(.bool),
            ArrayType(count: LiteralInt(5), elementType: PrimitiveType(.u8))
        ])
        let expected: SymbolType = .unionType(
            UnionTypeInfo([
                .u8,
                .u16,
                .bool,
                .array(count: 5, elementType: .u8)
            ])
        )
        let typeChecker = TypeContextTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
        let actualSize: Int?
        if let actual = actual {
            actualSize = memoryLayoutStrategy.sizeof(type: actual)
        }
        else {
            actualSize = nil
        }
        XCTAssertEqual(actualSize, 6)
    }

    func testResolveConstUnionTypeExpression() {
        let expr = ConstType(
            UnionType([
                PrimitiveType(.u8),
                PrimitiveType(.u16),
                PrimitiveType(.bool),
                ArrayType(count: LiteralInt(5), elementType: PrimitiveType(.u8))
            ])
        )
        let expected: SymbolType = .unionType(
            UnionTypeInfo([
                .arithmeticType(.immutableInt(.u8)),
                .arithmeticType(.immutableInt(.u16)),
                .constBool,
                .array(count: 5, elementType: .arithmeticType(.immutableInt(.u8)))
            ])
        )
        let typeChecker = TypeContextTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
        let actualSize: Int?
        if let actual = actual {
            actualSize = memoryLayoutStrategy.sizeof(type: actual)
        }
        else {
            actualSize = nil
        }
        XCTAssertEqual(actualSize, 6)
    }

    func testCompileFailsWhenCastingUnionTypeToNonMemberType() {
        let union = Identifier("foo")
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .unionType(UnionTypeInfo([.u8, .u16])),
                    storage: .automaticStorage(offset: offset)
                )
            )
        ])
        let expr = As(expr: union, targetType: PrimitiveType(.bool))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `u8 | u16' to type `bool'"
            )
        }
    }

    func testSuccessfullyCastUnionTypeToMemberType() {
        let expr = As(expr: Identifier("foo"), targetType: PrimitiveType(.u8))
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .unionType(UnionTypeInfo([.u8, .u16])),
                    storage: .automaticStorage(offset: offset)
                )
            )
        ])
        let expected: SymbolType = .u8
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }

    func testTestPrimitiveTypeIsExpression_Succeeds() {
        let expr = Is(
            expr: ExprUtils.makeU8(value: 0),
            testType: PrimitiveType(.u8)
        )
        let expected: SymbolType = .booleanType(.compTimeBool(true))
        let typeChecker = RvalueExpressionTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }

    func testTestPrimitiveTypeIsExpression_False() {
        let expr = Is(
            expr: ExprUtils.makeU8(value: 0),
            testType: PrimitiveType(.bool)
        )
        let expected: SymbolType = .booleanType(.compTimeBool(false))
        let typeChecker = RvalueExpressionTypeChecker()
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }

    func testTestUnionVariantTypeAgainstNonMemberType() {
        let union = Identifier("foo")
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .unionType(UnionTypeInfo([.u8, .u16])),
                    storage: .automaticStorage(offset: offset)
                )
            )
        ])
        let expr = Is(expr: union, testType: PrimitiveType(.bool))
        let expected: SymbolType = .booleanType(.compTimeBool(false))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }

    func testTestUnionVariantTypeAgainstKnownMemberType() {
        let union = Identifier("foo")
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .unionType(UnionTypeInfo([.u8, .bool])),
                    storage: .automaticStorage(offset: offset)
                )
            )
        ])
        let expr = Is(expr: union, testType: PrimitiveType(.u8))
        let expected: SymbolType = .bool
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var actual: SymbolType? = nil
        XCTAssertNoThrow(actual = try typeChecker.check(expression: expr))
        XCTAssertEqual(actual, expected)
    }

    func testCanAssignToUnionGivenTypeWhichConvertsToMatchingUnionMember() {
        let expr = Assignment(
            lexpr: Identifier("foo"),
            rexpr: ExprUtils.makeU8(value: 1)
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .unionType(UnionTypeInfo([.u16])), offset: 0x0010))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .unionType(UnionTypeInfo([.u16])))
    }

    func testSubscriptAnArrayWithARange() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .u8), offset: 0x0010))
        ])
        .withCompilerIntrinsicRangeType(MemoryLayoutStrategyTurtleTTL())

        let range = StructInitializer(
            identifier: Identifier("Range"),
            arguments: [
                StructInitializer.Argument(name: "begin", expr: LiteralInt(1)),
                StructInitializer.Argument(name: "limit", expr: LiteralInt(2))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .u8))
    }

    func testSubscriptADynamicArrayWithARange_1() {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .u16), offset: offset))
        ])
        .withCompilerIntrinsicRangeType(MemoryLayoutStrategyTurtleTTL())
        let range = StructInitializer(
            identifier: Identifier("Range"),
            arguments: [
                StructInitializer.Argument(name: "begin", expr: LiteralInt(0)),
                StructInitializer.Argument(name: "limit", expr: LiteralInt(0))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .dynamicArray(elementType: .u16))
    }

    func testLiteralString() {
        let expr = LiteralString("foo")
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .array(count: 3, elementType: .u8))
    }

    func testAddressOfFunctionEvaluatesToFunctionPointerType() {
        let name = "foo"
        let expr = Unary(op: .ampersand, expression: Identifier(name))
        let typ: SymbolType = .function(
            FunctionTypeInfo(name: name, returnType: .void, arguments: [])
        )
        let symbol = Symbol(
            type: typ,
            storage: .staticStorage(offset: 0x0000),
            visibility: .privateVisibility
        )
        let symbols = Env()
        symbols.bind(identifier: name, symbol: symbol)
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        let expected: SymbolType = .pointer(
            .function(FunctionTypeInfo(returnType: .void, arguments: []))
        )
        XCTAssertEqual(result, expected)
    }

    func testCallFunctionThroughFunctionPointer() {
        let expr = Call(callee: Identifier("bar"), arguments: [])
        let addressOfBar = SnapCompilerMetrics.kStaticStorageStartAddress
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(name: "foo", returnType: .void, arguments: [])
                    ),
                    offset: 0
                )
            ),
            (
                "bar",
                Symbol(
                    type: .pointer(
                        .function(FunctionTypeInfo(name: "foo", returnType: .void, arguments: []))
                    ),
                    offset: addressOfBar
                )
            )
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        let expected: SymbolType = .void
        XCTAssertEqual(result, expected)
    }

    func testBitcastBoolAsU8() {
        let expr = Bitcast(
            expr: ExprUtils.makeU8(value: 0),
            targetType: PrimitiveType(.bool)
        )
        let typeChecker = RvalueExpressionTypeChecker()
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .bool)
    }

    func testBitcastPointerToADifferentPointer() {
        let expr = Bitcast(expr: Identifier("foo"), targetType: PointerType(PrimitiveType(.u16)))
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(type: .pointer(.u8), offset: SnapCompilerMetrics.kStaticStorageStartAddress)
            )
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.u16))
    }

    func testAssignment_automatic_conversion_from_object_to_pointer() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u16), storage: .staticStorage(offset: 0x1000))),
            ("bar", Symbol(type: .u16, storage: .staticStorage(offset: 0x2000)))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Assignment(
            lexpr: Identifier("foo"),
            rexpr: Identifier("bar")
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.u16))
    }

    func testAssignment_automatic_conversion_from_trait_to_pointer() throws {
        let symbols = Env()
        let traitDecl = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [],
            visibility: .privateVisibility
        )
        try TraitScanner(symbols: symbols).scan(trait: traitDecl)

        let traitObjectType = try symbols.resolveType(identifier: traitDecl.nameOfTraitObjectType)
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(
                type: .pointer(traitObjectType),
                storage: .staticStorage(offset: 0x1000)
            )
        )

        let traitType = try symbols.resolveType(identifier: traitDecl.identifier.identifier)
        symbols.bind(
            identifier: "bar",
            symbol: Symbol(type: traitType, storage: .staticStorage(offset: 0x2000))
        )

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = Assignment(
            lexpr: Identifier("foo"),
            rexpr: Identifier("bar")
        )
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(traitObjectType))
    }

    func testInitialAssignment_automatic_conversion_from_struct_to_trait_object() throws {
        let traitObjectType: SymbolType = .traitType(
            TraitTypeInfo(
                name: "Foo",
                nameOfTraitObjectType: "",
                nameOfVtableType: "",
                symbols: Env()
            )
        )
        let symbols = Env(tuples: [
            (
                "__Foo_Bar_vtable_instance",
                Symbol(type: .structType(StructTypeInfo(name: "", fields: Env())))
            ),
            ("bar", Symbol(type: .structType(StructTypeInfo(name: "Bar", fields: Env())))),
            ("foo", Symbol(type: traitObjectType))
        ])

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: Identifier("bar")
        )
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, traitObjectType)
    }

    func testSizeOfIsU16() {
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = SizeOf(ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.immutableInt(.u16)))
    }

    func testFunctionType() throws {
        let expected = SymbolType.function(
            FunctionTypeInfo(
                name: "foo",
                mangledName: "foo",
                returnType: .void,
                arguments: [.arithmeticType(.immutableInt(.u16))],
                ast: nil
            )
        )
        let typeChecker = RvalueExpressionTypeChecker()
        let expr = FunctionType(
            name: "foo",
            returnType: PrimitiveType(.void),
            arguments: [PrimitiveType(.arithmeticType(.immutableInt(.u16)))]
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testCannotInstantiateGenericFunctionTypeWithoutApplication() throws {
        let typeChecker = RvalueExpressionTypeChecker()
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let expr = GenericFunctionType(template: template)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot instantiate generic function `func foo[T](a: T) -> T'"
            )
        }
    }

    func testGenericFunctionApplication_FailsWithIncorrectNumberOfArguments() throws {
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let genericFunctionType = GenericFunctionType(template: template)
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [
                PrimitiveType(.u16),
                PrimitiveType(.u16)
            ]
        )

        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "incorrect number of type arguments in application of generic function type `foo@[u16, u16]'"
            )
        }
    }

    func testGenericFunctionApplication() throws {
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let genericFunctionType = GenericFunctionType(template: template)
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [PrimitiveType(.constU16)]
        )
        let expected = SymbolType.function(
            FunctionTypeInfo(
                name: "foo[const u16]",
                mangledName: "foo[const u16]",
                returnType: .constU16,
                arguments: [.constU16],
                ast: template
            )
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testCannotTakeTheAddressOfGenericFunctionWithoutTypeArguments() {
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let genericFunctionType = GenericFunctionType(template: template)
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])

        let expr = Unary(op: .ampersand, expression: Identifier("foo"))
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot instantiate generic function `func foo[T](a: T) -> T'"
            )
        }
    }

    func testCannotTakeTheAddressOfGenericFunctionWithInappropriateTypeArguments() {
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let genericFunctionType = GenericFunctionType(template: template)
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])

        let expr = Unary(
            op: .ampersand,
            expression: GenericTypeApplication(
                identifier: Identifier("foo"),
                arguments: [PrimitiveType(.constU16), PrimitiveType(.constU16)]
            )
        )
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "incorrect number of type arguments in application of generic function type `foo@[const u16, const u16]'"
            )
        }
    }

    func testInferTypeArgumentsOfGenericFromContextInCall_u16() throws {
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let genericFunctionType = GenericFunctionType(template: template)
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let expr = Call(
            callee: Identifier("foo"),
            arguments: [
                ExprUtils.makeU16(value: 65535)
            ]
        )
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expected = SymbolType.u16
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testInferTypeArgumentsOfGenericFromContextInCall_i8() throws {
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let genericFunctionType = GenericFunctionType(template: template)
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let expr = Call(
            callee: Identifier("foo"),
            arguments: [
                ExprUtils.makeI8(value: -128)
            ]
        )
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expected = SymbolType.i8
        do {
            let actual = try typeChecker.check(expression: expr)
            XCTAssertEqual(actual, expected)
        }
        catch let err as CompilerError {
            print("\(err)")
            throw err
        }
    }

    func testCannotInstantiateGenericStructTypeWithoutApplication() throws {
        let template = StructDeclaration(
            identifier: Identifier("foo"),
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            members: [],
            visibility: .privateVisibility,
            isConst: false
        )
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericStructType(GenericStructTypeInfo(template: template)))
        )

        let expr = Identifier("foo")
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic struct `foo[T]'")
        }
    }

    func testGenericStructApplicationRequiresCorrectNumberOfArguments() throws {
        let template = StructDeclaration(
            identifier: Identifier("foo"),
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            members: [],
            visibility: .privateVisibility,
            isConst: false
        )
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericStructType(GenericStructTypeInfo(template: template)))
        )

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [
                PrimitiveType(.u16),
                PrimitiveType(.u16)
            ]
        )

        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "incorrect number of type arguments in application of generic struct type `foo@[u16, u16]'"
            )
        }
    }

    func testGenericStructApplication_Empty() throws {
        let template = StructDeclaration(
            identifier: Identifier("foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: [],
            visibility: .privateVisibility,
            isConst: false
        )
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericStructType(GenericStructTypeInfo(template: template)))
        )

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [PrimitiveType(.u16)]
        )

        let concreteStructSymbols = Env()
        let frame = Frame()
        concreteStructSymbols.frameLookupMode = .set(frame)
        concreteStructSymbols.breadcrumb = .structType("foo[u16]")
        let expected = SymbolType.structType(
            StructTypeInfo(
                name: "foo[u16]",
                fields: concreteStructSymbols
            )
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testGenericStructApplication_OneMember() throws {
        let template = StructDeclaration(
            identifier: Identifier("foo"),
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            members: [
                StructDeclaration.Member(name: "bar", type: Identifier("T"))
            ],
            visibility: .privateVisibility,
            isConst: false
        )
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericStructType(GenericStructTypeInfo(template: template)))
        )

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [PrimitiveType(.u16)]
        )

        let bar = Symbol(type: .u16, storage: .automaticStorage(offset: 0))
        let concreteStructSymbols = Env(tuples: [("bar", bar)])
        let frame = Frame()
        _ = frame.allocate(size: 1)
        frame.add(identifier: "bar", symbol: bar)
        concreteStructSymbols.frameLookupMode = .set(frame)
        concreteStructSymbols.breadcrumb = .structType("foo[u16]")

        let expected = SymbolType.structType(
            StructTypeInfo(name: "foo[u16]", fields: concreteStructSymbols)
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testGenericStructApplication_StructInitializer() throws {
        let template = StructDeclaration(
            identifier: Identifier("foo"),
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            members: [
                StructDeclaration.Member(name: "bar", type: Identifier("T"))
            ],
            visibility: .privateVisibility,
            isConst: false
        )
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericStructType(GenericStructTypeInfo(template: template)))
        )

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let app = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [PrimitiveType(.u16)]
        )
        let expr = StructInitializer(
            expr: app,
            arguments: [
                StructInitializer.Argument(name: "bar", expr: LiteralInt(1))
            ]
        )

        let bar = Symbol(type: .u16, storage: .automaticStorage(offset: 0))
        let concreteStructSymbols = Env(tuples: [
            ("bar", bar)
        ])
        let frame = Frame()
        _ = frame.allocate(size: 1)
        frame.add(identifier: "bar", symbol: bar)
        concreteStructSymbols.frameLookupMode = .set(frame)
        concreteStructSymbols.breadcrumb = .structType("foo[u16]")

        let expected = SymbolType.structType(
            StructTypeInfo(name: "foo[u16]", fields: concreteStructSymbols)
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testCannotInstantiateGenericTraitTypeWithoutApplication() throws {
        let template = TraitDeclaration(
            identifier: Identifier("Foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: [],
            visibility: .privateVisibility
        )
        let symbols = Env()
        symbols.bind(
            identifier: "Foo",
            symbol: Symbol(type: .genericTraitType(GenericTraitTypeInfo(template: template)))
        )

        let expr = Identifier("Foo")
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic trait `Foo[T]'")
        }
    }

    func testGenericTraitApplicationRequiresCorrectNumberOfArguments() throws {
        let template = TraitDeclaration(
            identifier: Identifier("Foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: [],
            visibility: .privateVisibility
        )
        let symbols = Env()
        symbols.bind(
            identifier: "Foo",
            symbol: Symbol(type: .genericTraitType(GenericTraitTypeInfo(template: template)))
        )

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("Foo"),
            arguments: [
                PrimitiveType(.u16),
                PrimitiveType(.u16)
            ]
        )

        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "incorrect number of type arguments in application of generic trait type `Foo@[u16, u16]'"
            )
        }
    }

    func testGenericTraitApplication_Empty() throws {
        let template = TraitDeclaration(
            identifier: Identifier("Foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: [],
            visibility: .privateVisibility
        )
        let symbols = Env()
        symbols.bind(
            identifier: "Foo",
            symbol: Symbol(type: .genericTraitType(GenericTraitTypeInfo(template: template)))
        )

        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("Foo"),
            arguments: [PrimitiveType(.u16)]
        )

        let expectedSymbols = Env()
        let frame = Frame()
        expectedSymbols.frameLookupMode = .set(frame)
        expectedSymbols.breadcrumb = .traitType("Foo[u16]")
        let expected = SymbolType.traitType(
            TraitTypeInfo(
                name: "Foo[u16]",
                nameOfTraitObjectType: "__Foo[u16]_object",
                nameOfVtableType: "__Foo[u16]_vtable",
                symbols: expectedSymbols
            )
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testGenericTraitApplication_OneMember() throws {
        let template = TraitDeclaration(
            identifier: Identifier("Foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: PointerType(
                        FunctionType(
                            name: "bar",
                            returnType: Identifier("T"),
                            arguments: [
                                Identifier("T")
                            ]
                        )
                    )
                )
            ],
            visibility: .privateVisibility
        )
        let symbols = Env()
        symbols.bind(
            identifier: "Foo",
            symbol: Symbol(type: .genericTraitType(GenericTraitTypeInfo(template: template)))
        )

        let typeChecker = RvalueExpressionTypeChecker(
            symbols: symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()
        )
        let expr = GenericTypeApplication(
            identifier: Identifier("Foo"),
            arguments: [PrimitiveType(.u16)]
        )

        let bar = Symbol(
            type: .pointer(
                .function(
                    FunctionTypeInfo(
                        name: "bar",
                        mangledName: "Foo[u16]::bar",
                        returnType: .u16,
                        arguments: [.u16],
                        ast: nil
                    )
                )
            ),
            storage: .automaticStorage(offset: 0)
        )
        let concreteTraitSymbols = Env(tuples: [
            ("bar", bar)
        ])
        let frame = Frame()
        _ = frame.allocate(size: 1)
        frame.add(identifier: "bar", symbol: bar)
        concreteTraitSymbols.frameLookupMode = .set(frame)
        concreteTraitSymbols.breadcrumb = .traitType("Foo[u16]")

        let expected = SymbolType.traitType(
            TraitTypeInfo(
                name: "Foo[u16]",
                nameOfTraitObjectType: "__Foo[u16]_object",
                nameOfVtableType: "__Foo[u16]_vtable",
                symbols: concreteTraitSymbols
            )
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testEseq_EmptySequence() throws {
        let expr = Eseq(
            seq: Seq(),
            expr: ExprUtils.makeU16(value: 1)
        )
        let result = try RvalueExpressionTypeChecker().check(expression: expr)
        XCTAssertEqual(result, .u16)
    }

    func testEseq_MultipleChildren() throws {
        let expr = Eseq(
            seq: Seq(children: [
                ExprUtils.makeBool(value: true)
            ]),
            expr: ExprUtils.makeU16(value: 1)
        )
        let result = try RvalueExpressionTypeChecker().check(expression: expr)
        XCTAssertEqual(result, .u16)
    }
    
    func testSubscriptArrayThroughPointerToArray() {
        let ident = "foo"
        let symbols = Env(tuples: [
            (ident, Symbol(type: .pointer(.array(count: 3, elementType: .u16))))
        ])
        let expr = Subscript(
            subscriptable: Identifier(ident),
            argument: LiteralInt(0)
        )
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testSubscriptArrayThroughConstPointerToArray() {
        let ident = "foo"
        let symbols = Env(tuples: [
            (ident, Symbol(type: .constPointer(.array(count: 3, elementType: .u16))))
        ])
        let expr = Subscript(
            subscriptable: Identifier(ident),
            argument: LiteralInt(0)
        )
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
}
