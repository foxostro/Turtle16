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
    func compile(expression: Expression, symbols: SymbolTable = SymbolTable()) throws -> [YertleInstruction] {
        let compiler = ExpressionSubCompiler(symbols: symbols)
        let ir = try compiler.compile(expression: expression)
        return ir
    }
    
    func testCannotCompileUnsupportedExpression() {
        let expr = Expression.UnsupportedExpression()
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "unsupported expression: <UnsupportedExpression>")
        }
    }
    
    func testCompileLiteralIntExpression_FitsIntoU8() {
        XCTAssertEqual(try compile(expression: ExprUtils.makeLiteralInt(value: 1)), [.push(1)])
        XCTAssertEqual(try compile(expression: ExprUtils.makeLiteralInt(value: 2)), [.push(2)])
    }
    
    func testCompileLiteralIntExpression_FitsIntoU16() {
        XCTAssertEqual(try compile(expression: ExprUtils.makeLiteralInt(value: 0xffff)), [.push16(0xffff)])
        XCTAssertEqual(try compile(expression: ExprUtils.makeLiteralInt(value: 256)), [.push16(256)])
    }
    
    func testCompileLiteralIntExpression_TooLarge() {
        let expr = ExprUtils.makeLiteralInt(value: 65536)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer literal `65536' overflows when stored into `u16'")
        }
    }
    
    func testCompileLiteralBooleanExpression() {
        XCTAssertEqual(try compile(expression: ExprUtils.makeLiteralBoolean(value: true)), [.push(1)])
        XCTAssertEqual(try compile(expression: ExprUtils.makeLiteralBoolean(value: false)), [.push(0)])
    }
        
    func testUnaryNegationOfU8() {
        let minus = TokenOperator(lineNumber: 1, lexeme: "-", op: .minus)
        let expr = Expression.Unary(op: minus, expression: ExprUtils.makeU8(value: 42))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(42),
            .push(0),
            .sub
        ])
        XCTAssertEqual(ir, try compile(expression: Expression.Binary(op: minus, left: ExprUtils.makeU8(value: 0), right: ExprUtils.makeU8(value: 42))))
        let expected = UInt8(0) &- UInt8(42)
        XCTAssertEqual(computer.stack(at: 0), expected)
    }
    
    func testUnaryNegationOfU16() {
        let minus = TokenOperator(lineNumber: 1, lexeme: "-", op: .minus)
        let expr = Expression.Unary(op: minus, expression: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(0),
            .sub16
        ])
        let expected = UInt16(0) &- UInt16(1000)
        XCTAssertEqual(computer.stack16(at: 0), expected)
    }
    
    func testUnaryNegationOfIntegerConstant() {
        let minus = TokenOperator(lineNumber: 1, lexeme: "-", op: .minus)
        let expr = Expression.Unary(op: minus, expression: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(0),
            .sub16
        ])
        let expected = UInt16(0) &- UInt16(1000)
        XCTAssertEqual(computer.stack16(at: 0), expected)
    }
    
    func testFailToCompileInvalidPrefixUnaryOperator() {
        let expr = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                    expression: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`*' is not a prefix unary operator")
        }
    }
    
    func testBinary_U16_Eq_U16_1() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1001),
                                              right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1001),
            .eq16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Eq_U16_2() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1000),
            .eq16
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Eq_U8() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(0),
            .push16(1000),
            .eq16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Eq_BooleanConstant() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `const bool'")
        }
    }
    
    func testBinary_U8_Eq_U16() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .eq16
        ])
    }
    
    func testBinary_U8_Eq_U8_1() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(1),
            .eq
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Eq_U8_2() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(0),
            .push(1),
            .eq
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U8_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Eq_BooleanConstant() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `const bool'")
        }
    }
    
    func testBinary_Bool_Eq_BooleanConstant() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(0),
            .push(0),
            .eq
        ])
    }
    
    func testBinary_Bool_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(0),
            .push(0),
            .eq
        ])
    }
    
    func testBinary_Bool_Eq_U8() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_BooleanConstant() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1)
        ])
    }
    
    func testBinary_BooleanConstant_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(0),
            .push(0),
            .eq
        ])
    }
    
    func testBinary_BooleanConstant_Eq_U8() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `const bool' and `u8'")
        }
    }
    
    func testBinary_U16_Ne_U16_1() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1000),
            .ne16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Ne_U16_2() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1001))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1001),
            .push16(1000),
            .ne16
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Ne_U8() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .ne16
        ])
    }
    
    func testBinary_U16_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Ne_BooleanConstant() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `const bool'")
        }
    }
    
    func testBinary_U8_Ne_U16() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .ne16
        ])
    }
    
    func testBinary_U8_Ne_U8_1() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(1),
            .ne
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U8_Ne_U8_2() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(0),
            .push(1),
            .ne
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Ne_BooleanConstant() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `const bool'")
        }
    }
    
    func testBinary_Bool_Ne_BooleanConstant() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(0),
            .push(0),
            .ne
        ])
    }
    
    func testBinary_Bool_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(0),
            .push(0),
            .ne
        ])
    }
    
    func testBinary_Bool_Ne_U8() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_BooleanConstant() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeLiteralBoolean(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(0)
        ])
    }
    
    func testBinary_BooleanConstant_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertEqual(try compile(expression: expr), [
            .push(0),
            .push(0),
            .ne
        ])
    }
    
    func testBinary_BooleanConstant_Ne_U8() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeLiteralBoolean(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `const bool' and `u8'")
        }
    }
    
    func testBinary_U16_Lt_U16_1() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 500))
        let expectedIr: [YertleInstruction] = [
            .push16(500),
            .push16(1000),
            .lt16
        ]
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, expectedIr)
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Lt_U16_2() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1001))
        let expectedIr: [YertleInstruction] = [
            .push16(1001),
            .push16(1000),
            .lt16
        ]
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, expectedIr)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Lt_U8() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .lt16
        ])
    }
    
    func testBinary_U16_Lt_Bool() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Lt_U16() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .lt16
        ])
    }
    
    func testBinary_U8_Lt_U8_1() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let expectedIr: [YertleInstruction] = [
            .push(1),
            .push(1),
            .lt
        ]
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, expectedIr)
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U8_Lt_U8_2() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 0),
                                              right: ExprUtils.makeU8(value: 1))
        let expectedIr: [YertleInstruction] = [
            .push(1),
            .push(0),
            .lt
        ]
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, expectedIr)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Lt_Bool() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Lt_Bool() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Lt_U8() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Gt_U16_1() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 0x2000),
                                              right: ExprUtils.makeU16(value: 0x1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(0x1000),
            .push16(0x2000),
            .gt16
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Gt_U16_2() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 0x1000),
                                              right: ExprUtils.makeU16(value: 0x2000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(0x2000),
            .push16(0x1000),
            .gt16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Gt_U16_3() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 0x1000),
                                              right: ExprUtils.makeU16(value: 0x1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(0x1000),
            .push16(0x1000),
            .gt16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Gt_U8() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .gt16
        ])
    }
    
    func testBinary_U16_Gt_Bool() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Gt_U16() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .gt16
        ])
    }
    
    func testBinary_U8_Gt_U8_0() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(1),
            .gt
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U8_Gt_U8_1() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(0),
            .push(1),
            .gt
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Gt_Bool() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Gt_Bool() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Gt_U8() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Le_U16_1() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 500),
                                              right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(500),
            .le16
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Le_U16_2() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1000),
            .le16
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Le_U16_3() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 500))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(500),
            .push16(1000),
            .le16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Le_U8() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .le16
        ])
    }
    
    func testBinary_U16_Le_Bool() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Le_U16() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .le16
        ])
    }
    
    func testBinary_U8_Le_U8_1() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 0),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(0),
            .le
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Le_U8_2() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(1),
            .le
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Le_U8_3() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(0),
            .push(1),
            .le
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U8_Le_Bool() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Le_Bool() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Le_U8() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_U16_Ge_U16_1() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 500),
                                              right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(500),
            .ge16
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Ge_U16_2() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1000),
            .ge16
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U16_Ge_U16_3() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 500))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(500),
            .push16(1000),
            .ge16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Ge_U8() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .ge16
        ])
    }
    
    func testBinary_U16_Ge_Bool() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Ge_U16() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .ge16
        ])
    }
    
    func testBinary_U8_Ge_U8_1() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 0),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(0),
            .ge
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U8_Ge_U8_2() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(1),
            .ge
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Ge_U8_3() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(0),
            .push(1),
            .ge
        ])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testBinary_U8_Ge_Bool() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Ge_Bool() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Ge_U8() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Plus_IntegerConstant() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeLiteralInt(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1001)
        ])
        XCTAssertEqual(computer.stack16(at: 0), 1001)
    }
    
    func testBinary_U16_Plus_IntegerConstant() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeLiteralInt(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1),
            .push16(1000),
            .add16
        ])
        XCTAssertEqual(computer.stack16(at: 0), 1001)
    }
    
    func testBinary_U16_Plus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1000),
            .add16
        ])
        XCTAssertEqual(computer.stack16(at: 0), 2000)
    }
    
    func testBinary_U16_Plus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .add16
        ])
    }
    
    func testBinary_U16_Plus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Plus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .add16
        ])
    }
    
    func testBinary_U8_Plus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(1),
            .add
        ])
        XCTAssertEqual(computer.stack(at: 0), 2)
    }
    
    func testBinary_U8_Plus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Plus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Plus_U8() {
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try compile(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_Plus_Bool() {
       let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try compile(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to two `bool' operands")
       }
   }
    
    func testBinary_U16_Minus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1000),
            .sub16
        ])
        XCTAssertEqual(computer.stack16(at: 0), 0)
    }
    
    func testBinary_U16_Minus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .sub16
        ])
    }
    
    func testBinary_U16_Minus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Minus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .sub16
        ])
    }
    
    func testBinary_U8_Minus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(1),
            .push(1),
            .sub
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U8_Minus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Minus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Minus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Minus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_U16_Multiply_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU16(value: 256),
                                     right: ExprUtils.makeU16(value: 256))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(256),
            .push16(256),
            .mul16
        ])
        XCTAssertEqual(computer.stack16(at: 0), UInt16(256) &* UInt16(256))
    }
    
    func testBinary_U16_Multiply_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .mul16
        ])
    }
    
    func testBinary_U16_Multiply_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Multiply_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .mul16
        ])
    }
    
    func testBinary_U8_Multiply_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU8(value: 2),
                                     right: ExprUtils.makeU8(value: 3))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(3),
            .push(2),
            .mul
        ])
        XCTAssertEqual(computer.stack(at: 0), 6)
    }
    
    func testBinary_U8_Multiply_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Multiply_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Multiply_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Multiply_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_U16_Divide_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU16(value: 0x1000),
                                     right: ExprUtils.makeU16(value: 0x1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(0x1000),
            .push16(0x1000),
            .div16
        ])
        XCTAssertEqual(computer.stack16(at: 0), 1)
    }
    
    func testBinary_U16_Divide_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .div16
        ])
    }
    
    func testBinary_U16_Divide_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Divide_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .div16
        ])
    }
    
    func testBinary_U8_Divide_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU8(value: 12),
                                     right: ExprUtils.makeU8(value: 4))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(4),
            .push(12),
            .div
        ])
        XCTAssertEqual(computer.stack(at: 0), 3)
    }
    
    func testBinary_U8_Divide_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Divide_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Divide_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Divide_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_U16_Modulus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(1000),
            .push16(1000),
            .mod16
        ])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testBinary_U16_Modulus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertEqual(try compile(expression: expr), [
            .push(1),
            .push(0),
            .push16(1000),
            .mod16
        ])
    }
    
    func testBinary_U16_Modulus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Modulus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertEqual(try compile(expression: expr), [
            .push16(1000),
            .push(1),
            .push(0),
            .mod16
        ])
    }
    
    func testBinary_U8_Modulus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU8(value: 15),
                                     right: ExprUtils.makeU8(value: 4))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push(4),
            .push(15),
            .mod
        ])
        XCTAssertEqual(computer.stack(at: 0), 3)
    }
    
    func testBinary_U8_Modulus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Modulus_U16() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Modulus_U8() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Modulus_Bool() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1,  lexeme: "%", op: .modulus),
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to two `bool' operands")
        }
    }
    
    func testCompileIdentifierExpression_U8_Static() {
        let expr = ExprUtils.makeIdentifier(name: "foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: false)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .load(0x0010)
        ])
    }
    
    func testCompileIdentifierExpression_U16_Static() {
        let expr = ExprUtils.makeIdentifier(name: "foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: false)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .load16(0x0010)
        ])
    }
    
    func testCompileIdentifierExpression_U8_Stack() {
        let expr = ExprUtils.makeIdentifier(name: "foo")
        let symbol = Symbol(type: .u8, offset: 0x0010, isMutable: false, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let ir = try! compile(expression: expr, symbols: symbols)
        let executor = YertleExecutor()
        executor.configure = {computer in
            // Set the value of the local variable on the stack.
            // We're going to assume the initial value of the frame pointer,
            // which is 0x0000.
            computer.dataRAM.store(value: 0xaa, to: 0xfff0)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack(at: 0), 0xaa)
    }
    
    func testCompileIdentifierExpression_U16_Stack() {
        let expr = ExprUtils.makeIdentifier(name: "foo")
        let symbol = Symbol(type: .u16, offset: 0x0010, isMutable: false, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let ir = try! compile(expression: expr, symbols: symbols)
        let executor = YertleExecutor()
        executor.configure = {computer in
            // Set the value of the local variable on the stack.
            // We're going to assume the initial value of the frame pointer,
            // which is 0x0000.
            computer.dataRAM.store16(value: 0xabcd, to: 0xfff0)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xabcd)
    }
    
    func testCompileIdentifierExpression_Boolean_Static() {
        let expr = ExprUtils.makeIdentifier(name: "foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010, isMutable: false)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .load(0x0010)
        ])
    }
    
    func testCompileIdentifierExpression_UnresolvedIdentifier() {
        let expr = ExprUtils.makeIdentifier(name: "foo")
        XCTAssertThrowsError(try compile(expression: expr)) {
            XCTAssertEqual(($0 as? CompilerError)?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testCompileAssignment_Bool_Static() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralBoolean(value: true))
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010, isMutable: true)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .push(1),
            .store(0x0010)
        ])
    }
    
    func testCompileAssignment_U8_Static() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .push(42),
            .store(0x0010)
        ])
    }
    
    func testCompileAssignment_U16_Static() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .push16(0xabcd),
            .store16(0x0010)
        ])
    }
    
    func testCompileAssignment_PromoteU8ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        XCTAssertEqual(try compile(expression: expr, symbols: symbols), [
            .push(42),
            .push(0),
            .store16(0x0010)
        ])
    }
    
    func testCompileAssignment_Bool_Stack() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralBoolean(value: false))
        let symbol = Symbol(type: .bool, offset: 0x0004, isMutable: true, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let ir = try! compile(expression: expr, symbols: symbols)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffc), 0)
    }
    
    func testCompileAssignment_U8_Stack() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 0xaa))
        let symbol = Symbol(type: .u8, offset: 0x0004, isMutable: true, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let ir = try! compile(expression: expr, symbols: symbols)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffc), 0xaa)
    }
    
    func testCompileAssignment_U16_Stack() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: 0xabcd))
        let symbol = Symbol(type: .u16, offset: 0x0004, isMutable: true, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let ir = try! compile(expression: expr, symbols: symbols)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: 0xfffc), 0xabcd)
    }
    
    func testCannotAssignToAnImmutableValue_Word() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: false)])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to immutable variable `foo'")
        }
    }
    
    func testCannotAssignToAnImmutableValue_Boolean() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: true))
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: 0x0010, isMutable: false)])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to immutable variable `foo'")
        }
    }
    
    func testAssignmentWhichConvertsU8ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 0xaa))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: 0x0010, isMutable: true)])
        let ir = try! compile(expression: expr, symbols: symbols)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 0xaa)
    }
    
    func testCompilationFailsDueToUseOfUnresolvedIdentifierInFunctionCall() {
        let expr = Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [])
        XCTAssertThrowsError(try compile(expression: expr)) {
            XCTAssertEqual(($0 as? CompilerError)?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testCompilationFailsBecauseCannotCallValueOfNonFunctionType() {
        let expr = Expression.Call(callee: ExprUtils.makeIdentifier(name: "fn"), arguments: [])
        let symbols = SymbolTable([
            "fn" : Symbol(type: .u8, offset: 0x0000, isMutable: false, storage: .staticStorage)
        ])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            XCTAssertEqual(($0 as? CompilerError)?.message, "cannot call value of non-function type `u8'")
        }
    }
    
    func testBoolasVoid() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .void)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `void'")
        }
    }
    
    func testBoolasU16() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u16'")
        }
    }
    
    func testBoolasU8() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u8'")
        }
    }
    
    func testBoolasBool() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: true),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testU8asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .void)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `void'")
        }
    }
    
    func testU8asU16() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 0xab),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0x00ab)
    }
    
    func testU8asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testU8asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `bool'")
        }
    }
    
    func testU16asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .void)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `void'")
        }
    }
    
    func testU16asU16() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xffff)
    }
    
    func testU16asU8() {
        // Casting from U16 to U8 just drops the high byte.
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xabcd),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack(at: 0), 0xcd)
    }
    
    func testU16asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .bool)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `bool'")
        }
    }
    
    func testIntegerConstantAsU8_Overflows() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 256),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u8)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows() {
        let expr = Expression.As(expr: ExprUtils.makeLiteralInt(value: 65536),
                                 tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                 targetType: .u16)
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testEmptyArray() {
        let expr = ExprUtils.makeLiteralArray([])
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(0)
        ])
        XCTAssertEqual(computer.stack16(at: 0), 0)
    }
    
    func testArrayU8() {
        let expr = ExprUtils.makeLiteralArray([ExprUtils.makeU8(value: 0),
                                               ExprUtils.makeU8(value: 1),
                                               ExprUtils.makeU8(value: 2)])
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(3),
            .push(0),
            .push(1),
            .push(2)
        ])
        XCTAssertEqual(computer.stack16(at: 3), 3)
        XCTAssertEqual(computer.stack(at: 2), 0)
        XCTAssertEqual(computer.stack(at: 1), 1)
        XCTAssertEqual(computer.stack(at: 0), 2)
    }
    
    func testArrayU16() {
        let expr = ExprUtils.makeLiteralArray([ExprUtils.makeU16(value: 1),
                                               ExprUtils.makeU16(value: 2),
                                               ExprUtils.makeU16(value: 1000)])
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(3),
            .push16(1),
            .push16(2),
            .push16(1000)
        ])
        XCTAssertEqual(computer.stack16(at: 6), 3)
        XCTAssertEqual(computer.stack16(at: 4), 1)
        XCTAssertEqual(computer.stack16(at: 2), 2)
        XCTAssertEqual(computer.stack16(at: 0), 1000)
    }
    
    func testArrayBoolean() {
        let expr = ExprUtils.makeLiteralArray([ExprUtils.makeLiteralBoolean(value: false),
                                               ExprUtils.makeLiteralBoolean(value: false),
                                               ExprUtils.makeLiteralBoolean(value: true)])
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(3),
            .push(0),
            .push(0),
            .push(1)
        ])
        XCTAssertEqual(computer.stack16(at: 3), 3)
        XCTAssertEqual(computer.stack(at: 2), 0)
        XCTAssertEqual(computer.stack(at: 1), 0)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testArrayHeterogeneousU8andBool() {
        let expr = ExprUtils.makeLiteralArray([ExprUtils.makeU8(value: 0),
                                               ExprUtils.makeBool(value: false)])
        XCTAssertThrowsError(try compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot infer type of heterogeneous array")
        }
    }
    
    func testArrayLiteralMaySpecifyAnExplicitElementType() {
        let expr = Expression.LiteralArray(tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                           elements: [ExprUtils.makeLiteralInt(value: 1000),
                                                      ExprUtils.makeU8(value: 1),
                                                      ExprUtils.makeU8(value: 2)],
                                           tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]"),
                                           explicitElementType: .u16)
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(3),
            .push16(1000),
            .push(1),
            .push(0),
            .push(2),
            .push(0)
        ])
        XCTAssertEqual(computer.stack16(at: 6), 3)
        XCTAssertEqual(computer.stack16(at: 4), 1000)
        XCTAssertEqual(computer.stack16(at: 2), 1)
        XCTAssertEqual(computer.stack16(at: 0), 2)
    }
    
    func testMoreComplicatedConstantExpressionIsAlsoEvaluatedAtCompileTime() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                     left: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                                       left: ExprUtils.makeLiteralInt(value: 1000),
                                                       right: ExprUtils.makeLiteralInt(value: 1)),
                                     right: ExprUtils.makeLiteralInt(value: 4))
        let ir = try! compile(expression: expr)
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .push16(4004)
        ])
        XCTAssertEqual(computer.stack16(at: 0), 4004)
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
        let symbols = SymbolTable([ident : Symbol(type: symbolType, offset: 0x0010, isMutable: false)])
        let zero = ExprUtils.makeLiteralInt(value: 0)
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: zero)
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `\(symbolType)' has no subscripts")
        }
    }
    
    func testArraySubscriptAccessesAnArrayElement_U16() {
        checkArraySubscriptCanAccessEveryElement(elementType: .u16)
    }
    
    func testArraySubscriptAccessesAnArrayElement_U8() {
        checkArraySubscriptCanAccessEveryElement(elementType: .u8)
    }
    
    func testArraySubscriptAccessesAnArrayElement_Bool() {
        checkArraySubscriptCanAccessEveryElement(elementType: .bool)
    }
    
    private func checkArraySubscriptCanAccessEveryElement(elementType: SymbolType) {
        let n = 3
        for i in 0..<n {
            checkArraySubscriptAccessesArrayElement(i, n, elementType)
        }
    }
    
    private func checkArraySubscriptAccessesArrayElement(_ i: Int, _ n: Int, _ elementType: SymbolType) {
        let ident = "foo"
        let symbols = SymbolTable([ident : Symbol(type: .array(count: n, elementType: elementType), offset: 0x0010, isMutable: false)])
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: ExprUtils.makeLiteralInt(value: i))
        var ir: [YertleInstruction] = []
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        let executor = YertleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(n), to: 0x0010)
            for j in 0..<n {
                switch elementType.sizeof {
                case 2:
                    computer.dataRAM.store16(value: UInt16(j), to: 0x0012 + j*elementType.sizeof)
                case 1:
                    computer.dataRAM.store(value: UInt8(j), to: 0x0012 + j*elementType.sizeof)
                default:
                    abort()
                }
            }
        }
        let computer = try! executor.execute(ir: ir)
        switch elementType.sizeof {
        case 2:
            XCTAssertEqual(computer.stack16(at: 0), UInt16(i))
        case 1:
            XCTAssertEqual(computer.stack(at: 0), UInt8(i))
        default:
            abort()
        }
    }
}
