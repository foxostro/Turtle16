//
//  RvalueExpressionCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class RvalueExpressionCompilerTests: XCTestCase {
    let t0 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 0
    let t1 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 2
    let t2 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 4
    
    let kSliceBaseAddressOffset = 0
    let kSliceCountOffset = 2
    
    func mustCompile(compiler: RvalueExpressionCompiler, expression: Expression) -> [CrackleInstruction] {
        return try! compile(compiler: compiler,
                            expression: expression,
                            shouldPrintErrors: true)
    }
    
    func mustCompile(expression: Expression, symbols: SymbolTable = SymbolTable()) -> [CrackleInstruction] {
        return try! compile(compiler: makeCompiler(symbols: symbols),
                            expression: expression,
                            shouldPrintErrors: true)
    }
    
    func tryCompile(expression: Expression, symbols: SymbolTable = SymbolTable(), shouldPrintErrors: Bool = false) throws -> [CrackleInstruction] {
        return try compile(compiler: makeCompiler(symbols: symbols),
                           expression: expression,
                           shouldPrintErrors: shouldPrintErrors)
    }
    
    func makeCompiler(symbols: SymbolTable = SymbolTable()) -> RvalueExpressionCompiler {
        let symbols2 = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: symbols)
        let compiler = RvalueExpressionCompiler(symbols: symbols2)
        return compiler
    }
    
    func compile(compiler: RvalueExpressionCompiler, expression: Expression, shouldPrintErrors: Bool = false) throws -> [CrackleInstruction] {
        var ir: [CrackleInstruction] = []
        do {
            ir = try compiler.compile(expression: expression)
        } catch let error as CompilerError {
            if shouldPrintErrors {
                let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: [error])
                print(omnibus.localizedDescription)
            }
            throw error
        } catch let error {
            throw error
        }
        return ir
    }
    
    func testCannotCompileUnsupportedExpression() {
        let expr = Expression.UnsupportedExpression(sourceAnchor: nil)
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "unsupported expression: UnsupportedExpression")
        }
    }
    
    func testCompileLiteralIntExpression_FitsIntoU8() {
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0xff)
        ]
        let actual = mustCompile(expression: Expression.LiteralInt(0xff))
        XCTAssertEqual(expected, actual)
    }
    
    func testCompileLiteralIntExpression_FitsIntoU16() {
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0xffff)
        ]
        let actual = mustCompile(expression: Expression.LiteralInt(0xffff))
        XCTAssertEqual(expected, actual)
    }
    
    func testCompileLiteralIntExpression_TooLarge() {
        let expr = Expression.LiteralInt(65536)
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer literal `65536' overflows when stored into `u16'")
        }
    }
    
    func testCompileLiteralBooleanExpression_true() {
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: Expression.LiteralBool(true))
        XCTAssertEqual(expected, actual)
    }
    
    func testCompileLiteralBooleanExpression_false() {
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: Expression.LiteralBool(false))
        XCTAssertEqual(expected, actual)
    }
        
    func testUnaryNegationOfU8() {
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeU8(value: 42))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 42),
            .storeImmediate(t1, 0),
            .sub(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        let expectedResult = UInt8(0) &- UInt8(42)
        XCTAssertEqual(computer.dataRAM.load(from: t2), expectedResult)
    }
    
    func testUnaryNegationOfU16() {
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 0),
            .sub16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        let expectedResult = UInt16(0) &- UInt16(1000)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), expectedResult)
    }
    
    func testUnaryNegationOfIntegerConstant() {
        let expr = Expression.Unary(op: .minus,
                                    expression: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 0),
            .sub16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        let expectedResult = UInt16(0) &- UInt16(1000)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), expectedResult)
    }
    
    func testFailToCompileInvalidPrefixUnaryOperator() {
        let expr = Expression.Unary(op: .star,
                                    expression: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`*' is not a prefix unary operator")
        }
    }
    
    func testBinary_ConstantInteger_Eq_ConstantInteger_false() {
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(sourceAnchor: nil, value: 1001),
                                              right: Expression.LiteralInt(sourceAnchor: nil, value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_ConstantInteger_Eq_ConstantInteger_true() {
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralInt(sourceAnchor: nil, value: 1001),
                                              right: Expression.LiteralInt(sourceAnchor: nil, value: 1001))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_U16_Eq_U16_1() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1001),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1001),
            .eq16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Eq_U16_2() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .eq16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Eq_U8() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .eq16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Eq_BooleanConstant() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u16' and `boolean constant false'")
        }
    }
    
    func testBinary_U8_Plus_IntegerConstant() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .add(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 2)
    }
    
    func testBinary_U8_Eq_U16() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .eq16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t1), 0)
    }
    
    func testBinary_U8_Eq_U8_1() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .eq(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Eq_U8_2() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 1),
            .eq(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U8_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Eq_BooleanConstant() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `u8' and `boolean constant false'")
        }
    }
    
    func testBinary_Bool_Eq_BooleanConstant() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralBool(false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 0),
            .eq(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_Bool_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 0),
            .eq(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_Bool_Eq_U8() {
        let expr = ExprUtils.makeComparisonEq(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_BooleanConstant_Eq_BooleanConstant_true() {
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_BooleanConstant_Eq_BooleanConstant_false() {
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(true))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_BooleanConstant_Eq_Bool() {
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeBool(value: false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 0),
            .eq(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_BooleanConstant_Eq_U8() {
        let expr = ExprUtils.makeComparisonEq(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `==' cannot be applied to operands of types `boolean constant false' and `u8'")
        }
    }
    
    func testBinary_ConstantInteger_Ne_ConstantInteger_false() {
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(sourceAnchor: nil, value: 1000),
                                              right: Expression.LiteralInt(sourceAnchor: nil, value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_ConstantInteger_Ne_ConstantInteger_true() {
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralInt(sourceAnchor: nil, value: 1000),
                                              right: Expression.LiteralInt(sourceAnchor: nil, value: 1001))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_U16_Ne_U16_1() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .ne16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Ne_U16_2() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1001))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1001),
            .storeImmediate16(t1, 1000),
            .ne16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Ne_U8() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .ne16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U16_Ne_BooleanConstant() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU16(value: 1000),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u16' and `boolean constant false'")
        }
    }
    
    func testBinary_U8_Ne_U16() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .ne16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t1), 1)
    }
    
    func testBinary_U8_Ne_U8_1() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .ne(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U8_Ne_U8_2() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 1),
            .ne(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_U8_Ne_BooleanConstant() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeU8(value: 1),
                                              right: Expression.LiteralBool(false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `u8' and `boolean constant false'")
        }
    }
    
    func testBinary_Bool_Ne_BooleanConstant() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: Expression.LiteralBool(false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 0),
            .ne(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_Bool_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 0),
            .ne(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_Bool_Ne_U8() {
        let expr = ExprUtils.makeComparisonNe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_BooleanConstant_Ne_BooleanConstant_true() {
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(true))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_BooleanConstant_Ne_BooleanConstant_false() {
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: Expression.LiteralBool(false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_BooleanConstant_Ne_Bool() {
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeBool(value: false))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 0),
            .ne(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_BooleanConstant_Ne_U8() {
        let expr = ExprUtils.makeComparisonNe(left: Expression.LiteralBool(false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `!=' cannot be applied to operands of types `boolean constant false' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Lt_IntegerConstant_true() {
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(500),
                                              right: Expression.LiteralInt(1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_IntegerConstant_Lt_IntegerConstant_false() {
        let expr = ExprUtils.makeComparisonLt(left: Expression.LiteralInt(1000),
                                              right: Expression.LiteralInt(500))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_U16_Lt_U16_1() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 500))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 500),
            .storeImmediate16(t1, 1000),
            .lt16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Lt_U16_2() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1001))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1001),
            .storeImmediate16(t1, 1000),
            .lt16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Lt_U8() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .lt16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Lt_Bool() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Lt_U16() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .lt16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t1), 1)
    }
    
    func testBinary_U8_Lt_U8_1() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .lt(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U8_Lt_U8_2() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 0),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 0),
            .lt(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Lt_Bool() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Lt_Bool() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Lt_U8() {
        let expr = ExprUtils.makeComparisonLt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Gt_IntegerConstant_true() {
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(0x2000),
                                              right: Expression.LiteralInt(0x1000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_IntegerConstant_Gt_IntegerConstant_false() {
        let expr = ExprUtils.makeComparisonGt(left: Expression.LiteralInt(0x1000),
                                              right: Expression.LiteralInt(0x2000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_U16_Gt_U16_1() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 0x2000),
                                              right: ExprUtils.makeU16(value: 0x1000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x1000),
            .storeImmediate16(t1, 0x2000),
            .gt16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Gt_U16_2() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 0x1000),
                                              right: ExprUtils.makeU16(value: 0x2000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x2000),
            .storeImmediate16(t1, 0x1000),
            .gt16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Gt_U16_3() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 0x1000),
                                              right: ExprUtils.makeU16(value: 0x1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x1000),
            .storeImmediate16(t1, 0x1000),
            .gt16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Gt_U8() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .gt16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Gt_Bool() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Gt_U16() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .gt16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U8_Gt_U8_0() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .gt(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U8_Gt_U8_1() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 1),
            .gt(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Gt_Bool() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Gt_Bool() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Gt_U8() {
        let expr = ExprUtils.makeComparisonGt(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Le_IntegerConstant_true() {
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(0x1000),
                                              right: Expression.LiteralInt(0x1000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_IntegerConstant_Le_IntegerConstant_false() {
        let expr = ExprUtils.makeComparisonLe(left: Expression.LiteralInt(0x2000),
                                              right: Expression.LiteralInt(0x1000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_U16_Le_U16_1() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 500),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 500),
            .le16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Le_U16_2() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .le16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Le_U16_3() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 500))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 500),
            .storeImmediate16(t1, 1000),
            .le16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Le_U8() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .le16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Le_Bool() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Le_U16() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .le16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t1), 1)
    }
    
    func testBinary_U8_Le_U8_1() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 0),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 0),
            .le(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Le_U8_2() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .le(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Le_U8_3() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 1),
            .le(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U8_Le_Bool() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Le_Bool() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Le_U8() {
        let expr = ExprUtils.makeComparisonLe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `<=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Ge_IntegerConstant_true() {
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(0x2000),
                                              right: Expression.LiteralInt(0x1000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_IntegerConstant_Ge_IntegerConstant_false() {
        let expr = ExprUtils.makeComparisonGe(left: Expression.LiteralInt(0x1000),
                                              right: Expression.LiteralInt(0x2000))
        
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0)
    }
    
    func testBinary_U16_Ge_U16_1() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 500),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 500),
            .ge16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U16_Ge_U16_2() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .ge16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Ge_U16_3() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU16(value: 500))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 500),
            .storeImmediate16(t1, 1000),
            .ge16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Ge_U8() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .ge16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U16_Ge_Bool() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU16(value: 1000),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Ge_U16() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .ge16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t1), 0)
    }
    
    func testBinary_U8_Ge_U8_1() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 0),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 0),
            .ge(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 0)
    }
    
    func testBinary_U8_Ge_U8_2() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .ge(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Ge_U8_3() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeU8(value: 0))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 0),
            .storeImmediate(t1, 1),
            .ge(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Ge_Bool() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeU8(value: 1),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Ge_Bool() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_Bool_Ge_U8() {
        let expr = ExprUtils.makeComparisonGe(left: ExprUtils.makeBool(value: false),
                                              right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `>=' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_IntegerConstant_Plus_IntegerConstant_Small() {
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1),
                                     right: Expression.LiteralInt(1))
        let ir = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .storeImmediate(t0, 2)
        ])
        XCTAssertEqual(computer.dataRAM.load(from: t0), 2)
    }
    
    func testBinary_IntegerConstant_Plus_IntegerConstant() {
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1000),
                                     right: Expression.LiteralInt(1))
        let ir = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .storeImmediate16(t0, 1001)
        ])
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 1001)
    }
    
    func testBinary_IntegerConstant_Plus_U16() {
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .add16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 2000)
    }
    
    func testBinary_IntegerConstant_Plus_U8() {
        let expr = Expression.Binary(op: .plus,
                                     left: Expression.LiteralInt(1),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .add(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 2)
    }
    
    func testBinary_U16_Plus_IntegerConstant() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: Expression.LiteralInt(1))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1),
            .storeImmediate16(t1, 1000),
            .add16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 1001)
    }
    
    func testBinary_U16_Plus_U16() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .add16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 2000)
    }
    
    func testBinary_U16_Plus_U8() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .add16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 1001)
    }
    
    func testBinary_U16_Plus_Bool() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Plus_U16() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .add16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t1), 1001)
    }
    
    func testBinary_U8_Plus_U8() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 1),
            .add(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 2)
    }
    
    func testBinary_U8_Plus_Bool() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Plus_U16() {
        let expr = Expression.Binary(op: .plus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Plus_U8() {
       let expr = Expression.Binary(op: .plus,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeU8(value: 1))
       XCTAssertThrowsError(try tryCompile(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to operands of types `bool' and `u8'")
       }
   }
    
    func testBinary_Bool_Plus_Bool() {
       let expr = Expression.Binary(op: .plus,
                                    left: ExprUtils.makeBool(value: false),
                                    right: ExprUtils.makeBool(value: false))
       XCTAssertThrowsError(try tryCompile(expression: expr)) {
           let compilerError = $0 as? CompilerError
           XCTAssertNotNil(compilerError)
           XCTAssertEqual(compilerError?.message, "binary operator `+' cannot be applied to two `bool' operands")
       }
   }
   
   func testBinary_IntegerConstant_Minus_IntegerConstant_Small() {
       let expr = Expression.Binary(op: .minus,
                                    left: Expression.LiteralInt(1000),
                                    right: Expression.LiteralInt(999))
       let expected: [CrackleInstruction] = [
           .storeImmediate(t0, 1)
       ]
       let actual = mustCompile(expression: expr)
       let executor = CrackleExecutor()
       let computer = try! executor.execute(ir: actual)
       XCTAssertEqual(actual, expected)
       XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
   }
   
   func testBinary_IntegerConstant_Minus_IntegerConstant_Big() {
       let expr = Expression.Binary(op: .minus,
                                    left: Expression.LiteralInt(1000),
                                    right: Expression.LiteralInt(1))
       let expected: [CrackleInstruction] = [
           .storeImmediate16(t0, 999)
       ]
       let actual = mustCompile(expression: expr)
       let executor = CrackleExecutor()
       let computer = try! executor.execute(ir: actual)
       XCTAssertEqual(actual, expected)
       XCTAssertEqual(computer.dataRAM.load16(from: t0), 999)
   }
   
   func testBinary_IntegerConstant_Minus_U16() {
       let expr = Expression.Binary(op: .minus,
                                    left: Expression.LiteralInt(1000),
                                    right: ExprUtils.makeU16(value: 999))
       let expected: [CrackleInstruction] = [
           .storeImmediate16(t0, 999),
           .storeImmediate16(t1, 1000),
           .sub16(t2, t1, t0)
       ]
       let actual = mustCompile(expression: expr)
       let executor = CrackleExecutor()
       let computer = try! executor.execute(ir: actual)
       XCTAssertEqual(actual, expected)
       XCTAssertEqual(computer.dataRAM.load16(from: t2), 1)
   }
   
   func testBinary_IntegerConstant_Minus_U8() {
       let expr = Expression.Binary(op: .minus,
                                    left: Expression.LiteralInt(255),
                                    right: ExprUtils.makeU8(value: 1))
       let expected: [CrackleInstruction] = [
           .storeImmediate(t0, 1),
           .storeImmediate(t1, 255),
           .sub(t2, t1, t0)
       ]
       let actual = mustCompile(expression: expr)
       let executor = CrackleExecutor()
       let computer = try! executor.execute(ir: actual)
       XCTAssertEqual(actual, expected)
       XCTAssertEqual(computer.dataRAM.load(from: t2), 254)
   }
   
   func testBinary_U16_Minus_IntegerConstant() {
       let expr = Expression.Binary(op: .minus,
                                    left: ExprUtils.makeU16(value: 1000),
                                    right: Expression.LiteralInt(999))
       let expected: [CrackleInstruction] = [
           .storeImmediate16(t0, 999),
           .storeImmediate16(t1, 1000),
           .sub16(t2, t1, t0)
       ]
       let actual = mustCompile(expression: expr)
       let executor = CrackleExecutor()
       let computer = try! executor.execute(ir: actual)
       XCTAssertEqual(actual, expected)
       XCTAssertEqual(computer.dataRAM.load16(from: t2), 1)
   }
    
    func testBinary_U16_Minus_U16() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .sub16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 0)
    }
    
    func testBinary_U16_Minus_U8() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .sub16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 999)
    }
    
    func testBinary_U16_Minus_Bool() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Minus_IntegerConstant() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 2),
                                     right: Expression.LiteralInt(1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 2),
            .sub(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Minus_U16() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .sub16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t1), UInt16(1) &- UInt16(1000))
    }
    
    func testBinary_U8_Minus_U8() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 2),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 2),
            .sub(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 1)
    }
    
    func testBinary_U8_Minus_Bool() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Minus_U16() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Minus_U8() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Minus_Bool() {
        let expr = Expression.Binary(op: .minus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `-' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Multiply_IntegerConstant_Small() {
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(8),
                                     right: Expression.LiteralInt(2))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 16)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 16)
    }
    
    func testBinary_IntegerConstant_Multiply_IntegerConstant_Big() {
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(100),
                                     right: Expression.LiteralInt(100))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, Int(10000))
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 10000)
    }
    
    func testBinary_IntegerConstant_Multiply_U16() {
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(256),
                                     right: ExprUtils.makeU16(value: 256))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 256),
            .storeImmediate16(t1, 256),
            .mul16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), UInt16(256) &* UInt16(256))
    }
    
    func testBinary_IntegerConstant_Multiply_U8() {
        let expr = Expression.Binary(op: .star,
                                     left: Expression.LiteralInt(255),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .storeImmediate(t1, 255),
            .mul(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 255)
    }
    
    func testBinary_U16_Multiply_IntegerConstant() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 256),
                                     right: Expression.LiteralInt(256))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 256),
            .storeImmediate16(t1, 256),
            .mul16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), UInt16(256) &* UInt16(256))
    }
    
    func testBinary_U16_Multiply_U16() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 256),
                                     right: ExprUtils.makeU16(value: 256))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 256),
            .storeImmediate16(t1, 256),
            .mul16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), UInt16(256) &* UInt16(256))
    }
    
    func testBinary_U16_Multiply_U8() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .mul16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 1000)
    }
    
    func testBinary_U16_Multiply_Bool() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Multiply_IntegerConstant() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: Expression.LiteralInt(255))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 255),
            .storeImmediate(t1, 1),
            .mul(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 255)
    }
    
    func testBinary_U8_Multiply_U16() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .mul16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t1), 1000)
    }
    
    func testBinary_U8_Multiply_U8() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 2),
                                     right: ExprUtils.makeU8(value: 3))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 3),
            .storeImmediate(t1, 2),
            .mul(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 6)
    }
    
    func testBinary_U8_Multiply_Bool() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Multiply_U16() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Multiply_U8() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Multiply_Bool() {
        let expr = Expression.Binary(op: .star,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `*' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Divide_IntegerConstant_Small() {
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(1000),
                                     right: Expression.LiteralInt(1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_IntegerConstant_Divide_IntegerConstant_Big() {
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(1000),
                                     right: Expression.LiteralInt(1))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 1000)
    }
    
    func testBinary_IntegerConstant_Divide_U16() {
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(0x1000),
                                     right: ExprUtils.makeU16(value: 0x1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x1000),
            .storeImmediate16(t1, 0x1000),
            .div16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 1)
    }
    
    func testBinary_IntegerConstant_Divide_U8() {
        let expr = Expression.Binary(op: .divide,
                                     left: Expression.LiteralInt(12),
                                     right: ExprUtils.makeU8(value: 4))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 4),
            .storeImmediate(t1, 12),
            .div(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 3)
    }
    
    func testBinary_U16_Divide_IntegerConstant() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 0x1000),
                                     right: Expression.LiteralInt(0x1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x1000),
            .storeImmediate16(t1, 0x1000),
            .div16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 1)
    }
    
    func testBinary_U16_Divide_U16() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 0x1000),
                                     right: ExprUtils.makeU16(value: 0x1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x1000),
            .storeImmediate16(t1, 0x1000),
            .div16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 1)
    }
    
    func testBinary_U16_Divide_U8() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .div16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 1000)
    }
    
    func testBinary_U16_Divide_Bool() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Divide_IntegerConstant() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 12),
                                     right: Expression.LiteralInt(4))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 4),
            .storeImmediate(t1, 12),
            .div(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 3)
    }
    
    func testBinary_U8_Divide_U16() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .div16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t1), 0)
    }
    
    func testBinary_U8_Divide_U8() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 12),
                                     right: ExprUtils.makeU8(value: 4))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 4),
            .storeImmediate(t1, 12),
            .div(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 3)
    }
    
    func testBinary_U8_Divide_Bool() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Divide_U16() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Divide_U8() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Divide_Bool() {
        let expr = Expression.Binary(op: .divide,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `/' cannot be applied to two `bool' operands")
        }
    }
    
    func testBinary_IntegerConstant_Modulus_IntegerConstant_Small() {
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(1),
                                     right: Expression.LiteralInt(1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testBinary_IntegerConstant_Modulus_IntegerConstant_Big() {
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(999),
                                     right: Expression.LiteralInt(1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 999)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 999)
    }
    
    func testBinary_IntegerConstant_Modulus_U16() {
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .mod16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 0)
    }
    
    func testBinary_IntegerConstant_Modulus_U8() {
        let expr = Expression.Binary(op: .modulus,
                                     left: Expression.LiteralInt(15),
                                     right: ExprUtils.makeU8(value: 4))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 4),
            .storeImmediate(t1, 15),
            .mod(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 3)
    }
    
    func testBinary_U16_Modulus_IntegerConstant() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: Expression.LiteralInt(1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .mod16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 0)
    }
    
    func testBinary_U16_Modulus_U16() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate16(t1, 1000),
            .mod16(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 0)
    }
    
    func testBinary_U16_Modulus_U8() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeU8(value: 1))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1),
            .copyWordZeroExtend(t1, t0),
            .storeImmediate16(t0, 1000),
            .mod16(t2, t0, t1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t2), 0)
    }
    
    func testBinary_U16_Modulus_Bool() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU16(value: 1000),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u16' and `bool'")
        }
    }
    
    func testBinary_U8_Modulus_IntegerConstant() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 15),
                                     right: Expression.LiteralInt(4))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 4),
            .storeImmediate(t1, 15),
            .mod(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 3)
    }
    
    func testBinary_U8_Modulus_U16() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeU16(value: 1000))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 1000),
            .storeImmediate(t1, 1),
            .copyWordZeroExtend(t2, t1),
            .mod16(t1, t2, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t1), 1)
    }
    
    func testBinary_U8_Modulus_U8() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 15),
                                     right: ExprUtils.makeU8(value: 4))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 4),
            .storeImmediate(t1, 15),
            .mod(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t2), 3)
    }
    
    func testBinary_U8_Modulus_Bool() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeU8(value: 1),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `u8' and `bool'")
        }
    }
    
    func testBinary_Bool_Modulus_U16() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU16(value: 1000))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u16'")
        }
    }
    
    func testBinary_Bool_Modulus_U8() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeU8(value: 1))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to operands of types `bool' and `u8'")
        }
    }
    
    func testBinary_Bool_Modulus_Bool() {
        let expr = Expression.Binary(op: .modulus,
                                     left: ExprUtils.makeBool(value: false),
                                     right: ExprUtils.makeBool(value: false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "binary operator `%' cannot be applied to two `bool' operands")
        }
    }
    
    func testCompileIdentifierExpression_U8_Static() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .constU8, offset: 0x0100)])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, 0x0100, 1)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0xab, to: 0x0100)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0xab)
    }
    
    func testCompileIdentifierExpression_U16_Static() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .constU16, offset: 0x0100)])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, 0x0100, 2)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0xabcd, to: 0x0100)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 0xabcd)
    }
    
    func testCompileIdentifierExpression_U8_Stack() {
        let kFramePointerAddress = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
        let expr = Expression.Identifier("foo")
        let symbol = Symbol(type: .constU8, offset: 0x0010, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, kFramePointerAddress, 2), // t0 = *kFramePointerAddress
            .subi16(t1, t0, 0x0010),                 // t1 = t0 - offset
            .copyWordsIndirectSource(t0, t1, 1),     // t0 = *t1
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            // Set the value of the local variable on the stack.
            // We're going to assume the initial value of the frame pointer,
            // which is 0x0000.
            computer.dataRAM.store(value: 0xaa, to: 0xfff0)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 0xaa)
        XCTAssertEqual(computer.dataRAM.load16(from: t1), 0xfff0)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfff0), 0xaa)
    }
    
    func testCompileIdentifierExpression_U16_Stack() {
        let kFramePointerAddress = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
        let expr = Expression.Identifier("foo")
        let symbol = Symbol(type: .constU16, offset: 0x0010, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, kFramePointerAddress, 2), // t0 = *kFramePointerAddress
            .subi16(t1, t0, 0x0010),                 // t1 = t0 - 0x0010
            .copyWordsIndirectSource(t0, t1, 2),     // t0 = *t1
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            // Set the value of the local variable on the stack.
            // We're going to assume the initial value of the frame pointer,
            // which is 0x0000.
            computer.dataRAM.store16(value: 0xabcd, to: 0xfff0)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 0xabcd)
    }
    
    func testCompileIdentifierExpression_Boolean_Static() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .constBool, offset: 0x0100)])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, 0x0100, 1)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 1, to: 0x0100)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testCompileIdentifierExpression_UnresolvedIdentifier() {
        let expr = Expression.Identifier("foo")
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            XCTAssertEqual(($0 as? CompilerError)?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testCompileIdentifierExpression_ArrayOfU16_Static() {
        let expr = Expression.Identifier("foo")
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 5, elementType: .constU16), offset: offset)])
        
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 1000, to: offset + 0)
            computer.dataRAM.store16(value: 2000, to: offset + 2)
            computer.dataRAM.store16(value: 3000, to: offset + 4)
            computer.dataRAM.store16(value: 4000, to: offset + 6)
            computer.dataRAM.store16(value: 5000, to: offset + 8)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), 2000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 4), 3000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 6), 4000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 8), 5000)
    }
    
    func testCompileIdentifierExpression_ArrayOfU16_Stack() {
        let expr = Expression.Identifier("foo")
        let symbol = Symbol(type: .array(count: 5, elementType: .constU16),
                            offset: 0x0020,
                            storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = {computer in
            // Set the value of the local variable on the stack.
            // We're going to assume the initial value of the frame pointer,
            // which is 0x0000.
            let address = Int(UInt16(0) &- UInt16(0x0020))
            computer.dataRAM.store16(value: 1000, to: address + 0)
            computer.dataRAM.store16(value: 2000, to: address + 2)
            computer.dataRAM.store16(value: 3000, to: address + 4)
            computer.dataRAM.store16(value: 4000, to: address + 6)
            computer.dataRAM.store16(value: 5000, to: address + 8)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), 2000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 4), 3000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 6), 4000)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 8), 5000)
    }
    
    func testCompileInitialAssignment_Bool_Static() {
        // An initial assignment is allowed to disregard rules about assignment
        // to constants because it sets the initial value in the first place.
        let offset = 0x0100
        let expr = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"), rexpr: Expression.LiteralBool(true))
        let symbols = SymbolTable(["foo" : Symbol(type: .constBool, offset: offset)])
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, offset),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: offset), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), UInt16(offset))
        XCTAssertEqual(computer.dataRAM.load(from: t1), 1)
    }
    
    func testCompileAssignment_Bool_Static() {
        let offset = 0x0100
        let expr = ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralBool(true))
        let symbols = SymbolTable(["foo" : Symbol(type: .bool, offset: offset)])
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, offset),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: offset), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), UInt16(offset))
        XCTAssertEqual(computer.dataRAM.load(from: t1), 1)
    }
    
    func testCompileAssignment_U8_Static() {
        let offset = 0x0100
        let value = 42
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: value))
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: offset)])
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, offset),
            .storeImmediate(t1, 42),
            .copyWordsIndirectDestination(t0, t1, 1)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: offset), 42)
    }
    
    func testCompileAssignment_U16_Static() {
        let offset = 0x0100
        let value = 0xabcd
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: value))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: offset)])
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, offset),
            .storeImmediate16(t1, 0xabcd),
            .copyWordsIndirectDestination(t0, t1, 2)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: offset), UInt16(value))
    }
    
    func testCompileAssignment_ArrayOfU16_Static() {
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)),
                                          elements: [ExprUtils.makeU16(value: 1000),
                                                     ExprUtils.makeU16(value: 2000),
                                                     ExprUtils.makeU16(value: 3000),
                                                     ExprUtils.makeU16(value: 4000),
                                                     ExprUtils.makeU16(value: 5000)])
        let expr = ExprUtils.makeAssignment(name: "foo", right: arr)
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 5, elementType: .u16), offset: offset)])
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: offset+0), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: offset+2), 2000)
        XCTAssertEqual(computer.dataRAM.load16(from: offset+4), 3000)
        XCTAssertEqual(computer.dataRAM.load16(from: offset+6), 4000)
        XCTAssertEqual(computer.dataRAM.load16(from: offset+8), 5000)
    }
    
    func testCompileAssignment_PromoteU8ToU16() {
        let offset = 0x0100
        let value = 42
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: value))
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: offset)])
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, offset),
            .storeImmediate(t1, value),
            .copyWordZeroExtend(t2, t1),
            .copyWordsIndirectDestination(t0, t2, 2)
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: offset), UInt16(value))
    }
    
    func testCompileAssignment_Bool_Stack() {
        let offset = 0x0004
        let kFramePointerAddress = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
        let expr = ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralBool(true))
        let symbol = Symbol(type: .bool, offset: offset, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, kFramePointerAddress, 2), // t0 = *kFramePointerAddress
            .subi16(t1, t0, offset),                 // t1 = t0 - offset
            .storeImmediate(t0, 1),                  // t0 = true
            .copyWordsIndirectDestination(t1, t0, 1) // *t1 = t0
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffc), 1)
    }
    
    func testCompileAssignment_U8_Stack() {
        let offset = 0x0004
        let value = 42
        let kFramePointerAddress = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: value))
        let symbol = Symbol(type: .u8, offset: offset, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, kFramePointerAddress, 2), // t0 = *kFramePointerAddress
            .subi16(t1, t0, offset),                 // t1 = t0 - offset
            .storeImmediate(t0, 42),                 // t0 = 42
            .copyWordsIndirectDestination(t1, t0, 1) // *t1 = t0
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffc), 42)
    }
    
    func testCompileAssignment_U16_Stack() {
        let offset = 0x0004
        let value = 0xabcd
        let kFramePointerAddress = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU16(value: value))
        let symbol = Symbol(type: .u16, offset: offset, storage: .stackStorage)
        let symbols = SymbolTable(["foo" : symbol])
        let expected: [CrackleInstruction] = [
            .copyWords(t0, kFramePointerAddress, 2), // t0 = *kFramePointerAddress
            .subi16(t1, t0, offset),                 // t1 = t0 - offset
            .storeImmediate16(t0, value),            // t0 = value
            .copyWordsIndirectDestination(t1, t0, 2) // *t1 = t0
        ]
        let actual = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: 0xfffc), UInt16(value))
    }
    
    func testCompileAssignment_ArrayOfU16_Stack() {
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)),
                                          elements: [ExprUtils.makeU16(value: 1000),
                                                     ExprUtils.makeU16(value: 2000),
                                                     ExprUtils.makeU16(value: 3000),
                                                     ExprUtils.makeU16(value: 4000),
                                                     ExprUtils.makeU16(value: 5000)])
        let expr = ExprUtils.makeAssignment(name: "foo", right: arr)
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 5, elementType: .u16), offset: 0x0010, storage: .stackStorage)])
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        let address = 0xfff0
        XCTAssertEqual(computer.dataRAM.load16(from: address + 0), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: address + 2), 2000)
        XCTAssertEqual(computer.dataRAM.load16(from: address + 4), 3000)
        XCTAssertEqual(computer.dataRAM.load16(from: address + 6), 4000)
        XCTAssertEqual(computer.dataRAM.load16(from: address + 8), 5000)
    }
    
    func testCompileAssignment_StructInitializerAssignedToStructIdentifier() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = ExprUtils.makeAssignment(name: "foo", right: Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "bar", expr: Expression.LiteralInt(0xabab)),
            Arg(name: "baz", expr: Expression.LiteralInt(0xcdcd)),
            Arg(name: "qux", expr: Expression.LiteralInt(0xefef))
        ]))
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0),
            "baz" : Symbol(type: .u16, offset: 2),
            "qux" : Symbol(type: .u16, offset: 4)
        ]))
        let symbols = SymbolTable(parent: nil,
                                  dict: ["foo" : Symbol(type: .structType(typ), offset: 0x0010, storage: .stackStorage)],
                                  typeDict: ["Foo" : .structType(typ)])
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        let address = 0xfff0
        XCTAssertEqual(computer.dataRAM.load16(from: address + 0), 0xabab)
        XCTAssertEqual(computer.dataRAM.load16(from: address + 2), 0xcdcd)
        XCTAssertEqual(computer.dataRAM.load16(from: address + 4), 0xefef)
    }
    
    func testCannotAssignToAConstantValue_Word() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 42))
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .constU8, offset: offset)])
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to constant `foo' of type `const u8'")
        }
    }
    
    func testCannotAssignToAConstantValue_Boolean() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeBool(value: true))
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .constBool, offset: offset)])
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to constant `foo' of type `const bool'")
        }
    }
    
    func testExpressionIsNotAssignable_IntegerConstant() {
        let expr = Expression.Assignment(lexpr: Expression.LiteralInt(0),
                                         rexpr: Expression.LiteralInt(0))
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .constBool, offset: offset)])
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "lvalue required in assignment")
        }
    }
    
    func testAssignmentWhichConvertsU8ToU16() {
        let expr = ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeU8(value: 0xaa))
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .u16, offset: offset)])
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0100), 0xaa)
    }
    
    func testCompilationFailsDueToUseOfUnresolvedIdentifierInFunctionCall() {
        let expr = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [])
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            XCTAssertEqual(($0 as? CompilerError)?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testCompilationFailsBecauseCannotCallValueOfNonFunctionType() {
        let expr = Expression.Call(callee: Expression.Identifier("fn"),
                                   arguments: [])
        let symbols = SymbolTable([
            "fn" : Symbol(type: .u8, offset: 0x0000, storage: .staticStorage)
        ])
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
            XCTAssertEqual(($0 as? CompilerError)?.message, "cannot call value of non-function type `u8'")
        }
    }
    
    func testBoolasVoid() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.void))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `void'")
        }
    }
    
    func testBoolasU16() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.u16))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u16'")
        }
    }
    
    func testBoolasU8() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: false),
                                 targetType: Expression.PrimitiveType(.u8))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `bool' to type `u8'")
        }
    }
    
    func testBoolasBool() {
        let expr = Expression.As(expr: ExprUtils.makeBool(value: true), targetType: Expression.PrimitiveType(.bool))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 1)
    }
    
    func testU8asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.void))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `void'")
        }
    }
    
    func testU8asU16() {
        let value = 42
        let expr = Expression.As(expr: ExprUtils.makeU8(value: value), targetType: Expression.PrimitiveType(.u16))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, value),
            .copyWordZeroExtend(t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t1), UInt16(value))
    }
    
    func testU8asU8() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 42), targetType: Expression.PrimitiveType(.u8))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 42)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t0), 42)
    }
    
    func testU8asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU8(value: 1),
                                 targetType: Expression.PrimitiveType(.bool))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8' to type `bool'")
        }
    }
    
    func testU16asVoid() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.void))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `void'")
        }
    }
    
    func testU16asU16() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xabcd), targetType: Expression.PrimitiveType(.u16))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0xabcd)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 0xabcd)
    }
    
    func testU16asU8() {
        // Casting from U16 to U8 just drops the high byte.
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xabcd), targetType: Expression.PrimitiveType(.u8))
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0xabcd),
            .copyWords(t1, t0+1, 1)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load(from: t1), 0xcd)
    }
    
    func testU16asBool() {
        let expr = Expression.As(expr: ExprUtils.makeU16(value: 0xffff),
                                 targetType: Expression.PrimitiveType(.bool))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u16' to type `bool'")
        }
    }
    
    func testIntegerConstantAsU8_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(256),
                                 targetType: Expression.PrimitiveType(.u8))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `256' overflows when stored into `u8'")
        }
    }
    
    func testIntegerConstantAsU16_Overflows() {
        let expr = Expression.As(expr: Expression.LiteralInt(65536),
                                 targetType: Expression.PrimitiveType(.u16))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "integer constant `65536' overflows when stored into `u16'")
        }
    }
    
    func testArrayIdentifierOfU8AsU16() {
        let expr = Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)))
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 5, elementType: .u8), offset: offset)])
        
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 1, to: offset + 0)
            computer.dataRAM.store(value: 2, to: offset + 1)
            computer.dataRAM.store(value: 3, to: offset + 2)
            computer.dataRAM.store(value: 4, to: offset + 3)
            computer.dataRAM.store(value: 5, to: offset + 4)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(tempResult.size, 10)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), 2)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 4), 3)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 6), 4)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 8), 5)
    }
    
    func testEmptyArray() {
        // The empty array is not actually materialized in memory.
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)))
        let ir = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        _ = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [])
    }
    
    func testLiteralArrayOfU8() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                           elements: [ExprUtils.makeU8(value: 0),
                                                      ExprUtils.makeU8(value: 1),
                                                      ExprUtils.makeU8(value: 2)])
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 0), 0)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 1), 1)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 2), 2)
    }
    
    func testLiteralArrayOfU8AsU16() {
        let expr = Expression.As(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)), elements: [ExprUtils.makeU8(value: 0), ExprUtils.makeU8(value: 1), ExprUtils.makeU8(value: 2)]), targetType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)))
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)

        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()

        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), 0)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 4), 2)
    }
    
    func testLiteralArrayOfU16() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)),
                                           elements: [ExprUtils.makeU16(value: 1),
                                                      ExprUtils.makeU16(value: 2),
                                                      ExprUtils.makeU16(value: 1000)])
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), 2)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 4), 1000)
    }
    
    func testLiteralArrayOfBool() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.bool)),
                                           elements: [Expression.LiteralBool(false),
                                                      Expression.LiteralBool(false),
                                                      Expression.LiteralBool(true)])
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 0), 0)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 1), 0)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 2), 1)
    }
    
    func testArrayLiteralHasNonConvertibleType() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.bool)),
                                           elements: [Expression.LiteralInt(0),
                                                      ExprUtils.makeBool(value: false)])
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `integer constant 0' to type `bool' in `[2]bool' array literal")
        }
    }
    
    func testMoreComplicatedConstantExpressionIsAlsoEvaluatedAtCompileTime() {
        let expr = Expression.Binary(op: .star,
                                     left: Expression.Binary(op: .plus,
                                                             left: Expression.LiteralInt(1000),
                                                             right: Expression.LiteralInt(1)),
                                     right: Expression.LiteralInt(4))
        let ir = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(ir, [
            .storeImmediate16(t0, 4004)
        ])
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 4004)
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
        let offset = 0x0100
        let symbols = SymbolTable([ident : Symbol(type: symbolType, offset: offset)])
        let zero = Expression.LiteralInt(0)
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: zero)
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
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
        let symbols = SymbolTable([ident : Symbol(type: .array(count: n, elementType: elementType), offset: 0x0100)])
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: Expression.LiteralInt(i))
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            for j in 0..<n {
                computer.dataRAM.storeValue(value: j,
                                            ofType: elementType,
                                            to: 0x0100 + j*elementType.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        let actual = computer.dataRAM.loadValue(ofType: elementType, from: tempResult.address)
        XCTAssertEqual(actual, i)
    }
    
    func testDynamicArraySubscriptAccessesAnArrayElement_U16() {
        checkDynamicArraySubscriptCanAccessEveryElement(elementType: .u16)
    }
    
    func testDynamicArraySubscriptAccessesAnArrayElement_U8() {
        checkDynamicArraySubscriptCanAccessEveryElement(elementType: .u8)
    }
    
    func testDynamicArraySubscriptAccessesAnArrayElement_Bool() {
        checkDynamicArraySubscriptCanAccessEveryElement(elementType: .bool)
    }
    
    private func checkDynamicArraySubscriptCanAccessEveryElement(elementType: SymbolType) {
        let n = 3
        for i in 0..<n {
            checkDynamicArraySubscriptCanAccessEveryElement(i, n, elementType)
        }
    }
    
    private func checkDynamicArraySubscriptCanAccessEveryElement(_ i: Int, _ n: Int, _ elementType: SymbolType) {
        let ident = "foo"
        let addressOfPointer = 0x0100
        let addressOfCount = 0x0102
        let addressOfData = 0x0104
        let symbols = SymbolTable([ident : Symbol(type: .dynamicArray(elementType: elementType), offset: addressOfPointer)])
        let expr = ExprUtils.makeSubscript(identifier: ident, expr: Expression.LiteralInt(i))
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            // A dynamic array is an object containing a pointer and a length
            computer.dataRAM.store16(value: UInt16(addressOfData), to: addressOfPointer)
            computer.dataRAM.store16(value: UInt16(n), to: addressOfCount)
            
            // Initialize the underlying data that the dynamic array is referencing
            for j in 0..<n {
                computer.dataRAM.storeValue(value: j,
                                            ofType: elementType,
                                            to: addressOfData + j*elementType.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        let actual = computer.dataRAM.loadValue(ofType: elementType, from: tempResult.address)
        XCTAssertEqual(actual, i)
    }
    
    func testCompileIdentifierExpression_DynamicArrayOfU16_Static() {
        let count = 5
        
        let addressOfPointer = 0x0100
        let addressOfCount = 0x0102
        let addressOfData = 0x0104
        
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u16), offset: addressOfPointer),
            "bar" : Symbol(type: .array(count: count, elementType: .u16), offset: addressOfData)
        ])
        
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(addressOfData), to: addressOfPointer)
            computer.dataRAM.store16(value: UInt16(count), to: addressOfCount)
            for i in 0..<count {
                computer.dataRAM.store16(value: UInt16(1000*i), to: addressOfData + i*SymbolType.u16.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), UInt16(addressOfData))
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), UInt16(count))
    }
    
    func testCompileAssignmentThroughArraySubscript_DynamicArray() {
        let count = 5
        
        let addressOfPointer = 0x0100
        let addressOfCount = 0x0102
        let addressOfData = 0x0104
        
        let expr = ExprUtils.makeAssignment(lexpr: ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(2)),
                                            rexpr: Expression.LiteralInt(0xcafe))
        
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u16), offset: addressOfPointer),
            "bar" : Symbol(type: .array(count: count, elementType: .u16), offset: addressOfData)
        ])
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(addressOfData), to: addressOfPointer)
            computer.dataRAM.store16(value: UInt16(count), to: addressOfCount)
            for i in 0..<count {
                computer.dataRAM.store16(value: UInt16(0xbeef), to: addressOfData + i*SymbolType.u16.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: addressOfData + 2*SymbolType.u16.sizeof), 0xcafe)
    }
    
    func testAssignment_ArrayOfU8_to_DynamicArrayOfU8() {
        let count = 5
        let addressOfPointer = 0x0100
        let addressOfCount = 0x0102
        let addressOfData = 0x0104
        let expr = ExprUtils.makeAssignment(name: "dst", right: Expression.Identifier("src"))
        let symbols = SymbolTable([
            "dst" : Symbol(type: .dynamicArray(elementType: .u8), offset: addressOfPointer),
            "src" : Symbol(type: .array(count: count, elementType: .u8), offset: addressOfData)
        ])
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0xcdcd, to: addressOfPointer)
            computer.dataRAM.store16(value: 0xcdcd, to: addressOfCount)
            for i in 0..<count {
                computer.dataRAM.store16(value: UInt16(0xbeef), to: addressOfData + i*SymbolType.u16.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: addressOfPointer), UInt16(addressOfData))
        XCTAssertEqual(computer.dataRAM.load16(from: addressOfCount), UInt16(count))
    }
    
    func testAccessInvalidMemberOfLiteralArray() {
        let expr = Expression.Get(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                                elements: [ExprUtils.makeU8(value: 0),
                                                                           ExprUtils.makeU8(value: 1),
                                                                           ExprUtils.makeU8(value: 2)]),
                                  member: Expression.Identifier("length"))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
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
        
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 3)
    }
    
    func testGetLengthOfArrayThroughIdentifier() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("count"))
        let offset = 0x0100
        let symbols = SymbolTable([
            "foo" : Symbol(type: .array(count: 3, elementType: .u8), offset: offset)
        ])
        
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 3)
    }
    
    func testGetLengthOfDynamicArray() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("count"))
        let offset = 0x0100
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u8), offset: offset)
        ])
        
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(offset+4), to: offset+0)
            computer.dataRAM.store16(value: 0x0003, to: offset+2)
        }
        let computer = try! executor.execute(ir: ir)
        
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 3)
    }
    
    func testOutOfBoundsRvalueArrayAccessCausesPanic_FixedArray() {
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: offset)])
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(1))
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0xcd, to: offset+1)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testOutOfBoundsRvalueArrayAccessCausesPanic_DynamicArray() {
        let offset = 0x0100
        let symbols = SymbolTable(["foo" : Symbol(type: .dynamicArray(elementType: .u8), offset: offset)])
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(0))
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(offset+4), to: offset+0)
            computer.dataRAM.store16(value: 0, to: offset+2)
            computer.dataRAM.store(value: 0xcd, to: offset+4)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
        
    func testGroupExpressionWithUnaryNegationOfU8() {
        let expr = Expression.Group(Expression.Unary(op: .minus, expression: ExprUtils.makeU8(value: 42)))
        let expected: [CrackleInstruction] = [
            .storeImmediate(t0, 42),
            .storeImmediate(t1, 0),
            .sub(t2, t1, t0)
        ]
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        let expectedResult = UInt8(0) &- UInt8(42)
        XCTAssertEqual(computer.dataRAM.load(from: t2), expectedResult)
    }
        
    func testCallCompilerIntrinsicFunction_peekMemory() {
        let expr = Expression.Call(callee: Expression.Identifier("peekMemory"), arguments: [ExprUtils.makeU16(value: 0xabcd)])
        let compiler = makeCompiler()
        let actual = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0xcc, to: 0xabcd)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 0xcc)
    }
        
    func testCallCompilerIntrinsicFunction_pokeMemory() {
        let expr = Expression.Call(callee: Expression.Identifier("pokeMemory"), arguments: [ExprUtils.makeU8(value: 0xcc), ExprUtils.makeU16(value: 0xabcd)])
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(computer.dataRAM.load(from: 0xabcd), 0xcc)
    }
        
    func testCallCompilerIntrinsicFunction_peekPeripheral() {
        let address = 0xffff
        let HLT: UInt16 = 0x0100
        let expr = Expression.Call(callee: Expression.Identifier("peekPeripheral"), arguments: [ExprUtils.makeU16(value: address), ExprUtils.makeU8(value: 0)])
        let compiler = makeCompiler()
        let actual = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.upperInstructionRAM.store(value: UInt8((HLT >> 8) & 0xff), to: address)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), UInt8((HLT >> 8) & 0xff))
    }
    
    func testCallCompilerIntrinsicFunction_pokePeripheral() {
        let expr = Expression.Call(callee: Expression.Identifier("pokePeripheral"), arguments: [ExprUtils.makeU8(value: 42), ExprUtils.makeU16(value: 0xffff), ExprUtils.makeU8(value: 0)])
        let actual = mustCompile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        
        // There's a hardware bug in Rev 2 where the bits of the instruction
        // RAM port are connected to the data bus are in reverse order.
        XCTAssertEqual(computer.upperInstructionRAM.load(from: 0xffff), UInt8(42).reverseBits())
    }
    
    func testCallCompilerIntrinsicFunction_hlt() {
        let expr = Expression.Call(callee: Expression.Identifier("hlt"), arguments: [])
        let expected: [CrackleInstruction] = [
            .hlt
        ]
        let actual = mustCompile(expression: expr)
        XCTAssertEqual(actual, expected)
    }
    
    func testCannotCallValueOfNonFunctionType() {
        let expr = Expression.Call(callee: Expression.Identifier("foo"), arguments: [])
        let offset = 0x0100
        let symbols = SymbolTable([
            "foo" : Symbol(type: .u8, offset: offset)
        ])
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot call value of non-function type `u8'")
        }
    }
    
    func testCallVoidFunctionWithNoArgs() {
        let expr = Expression.Call(callee: Expression.Identifier("foo"), arguments: [])
        let symbols = SymbolTable([
            "foo" : Symbol(type: .function(FunctionType(name: "foo", returnType: .void, arguments: [])), offset: 0)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = mustCompile(compiler: compiler, expression: expr)
        let executor = CrackleExecutor()
        injectFunctionFooWhichWritesToMemoryAsSideEffect(executor)
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(computer.dataRAM.load(from: 0xabcd), 42)
    }
    
    fileprivate func injectFunctionFooWhichWritesToMemoryAsSideEffect(_ executor: CrackleExecutor) {
        executor.injectCode = { (compiler: CrackleToTurtleMachineCodeCompiler) in
            try! compiler.injectCode([
                .label("foo"),
                .storeImmediate(0xabcd, 42),
                .leafRet
            ])
        }
    }
    
    func testNestFunctionCallInAdditionOnRight() {
        let left = ExprUtils.makeU16(value: 42)
        let right = Expression.Call(callee: Expression.Identifier("foo"), arguments: [])
        let expr = Expression.Binary(op: .plus, left: left, right: right)
        let symbols = SymbolTable([
            "foo" : Symbol(type: .function(FunctionType(name: "foo", returnType: .u16, arguments: [])), offset: 0)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        injectFunctionFooWhichReturnsU16AndStompsOnTemporaries(executor)
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 42)
    }
    
    func testNestFunctionCallInAdditionOnLeft() {
        let left = Expression.Call(callee: Expression.Identifier("foo"), arguments: [])
        let right = ExprUtils.makeU16(value: 42)
        let expr = Expression.Binary(op: .plus, left: left, right: right)
        let symbols = SymbolTable([
            "foo" : Symbol(type: .function(FunctionType(name: "foo", returnType: .u16, arguments: [])), offset: 0)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        injectFunctionFooWhichReturnsU16AndStompsOnTemporaries(executor)
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 42)
    }
    
    fileprivate func injectFunctionFooWhichReturnsU16AndStompsOnTemporaries(_ executor: CrackleExecutor) {
        executor.injectCode = { [weak self] (compiler: CrackleToTurtleMachineCodeCompiler) in
            try! compiler.injectCode([
                .label("foo"),
                .storeImmediate16(self!.t0, 0xffff),
                .storeImmediate16(self!.t1, 0xffff),
                .leafRet
            ])
        }
    }
    
    func testGetValueFromStructAtOffsetZero() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let value: UInt16 = 0xabcd
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: offset)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: value, to: offset)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), value)
    }
    
    func testGetValueFromStructAtNonzeroOffset() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("baz"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0),
            "baz" : Symbol(type: .u16, offset: 1)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: offset)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0xab, to: offset+0)
            computer.dataRAM.store16(value: 0xcdef, to: offset+1)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 0xcdef)
    }
    
    func testStructInitializerExpression_FailsWhenStructNameIsUnknown() {
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [])
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "use of undeclared type `Foo'")
        }
    }
    
    func testStructInitializerExpression_Empty() {
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [])
        let typ: SymbolType = .structType(StructType(name: "Foo", symbols: SymbolTable()))
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : typ])
        let compiler = makeCompiler(symbols: symbols)
        _ = mustCompile(compiler: compiler, expression: expr)
        XCTAssertFalse(compiler.temporaryStack.isEmpty)
    }
    
    func testStructInitializerExpression_IncorrectMemberName() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "asdf", expr: Expression.LiteralInt(0))
        ])
        let typ = StructType(name: "foo", symbols: SymbolTable())
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : .structType(typ)])
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
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
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `boolean constant false' to expected argument type `u16' in initialization of `bar'")
        }
    }

    func testStructInitializerExpression_ExpectsAndReceivesTwoValidArguments() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Arg(name: "bar", expr: Expression.LiteralInt(0xabab)),
            Arg(name: "baz", expr: Expression.LiteralInt(0xcdcd))
        ])
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0),
            "baz" : Symbol(type: .u16, offset: 2)
        ]))
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["Foo" : .structType(typ)])
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), 0xabab)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), 0xcdcd)
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
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
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
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 0), 0)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + 2), 0)
    }
    
    func testCannotTakeAddressOfLiteralInt() {
        let expr = Expression.Unary(op: .ampersand, expression: Expression.LiteralInt(0))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "lvalue required as operand of unary operator `&'")
        }
    }
    
    func testCannotTakeAddressOfLiteralBool() {
        let expr = Expression.Unary(op: .ampersand, expression: Expression.LiteralBool(false))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
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
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 0xabcd)
    }
    
    func testDereferencePointerToU8() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("pointee"))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.u8), offset: 0x0100),
            "bar" : Symbol(type: .u8, offset: 0x0102)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x0102, to: 0x0100)
            computer.dataRAM.store(value: 0x2a, to: 0x0102)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 0x2a)
    }
    
    func testGetValueOfStructMemberThroughPointerLoadsTheValue() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bb"))
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "aa" : Symbol(type: .u16, offset: 0),
            "bb" : Symbol(type: .u16, offset: 2)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.structType(typ)), offset: 0x0100),
            "bar" : Symbol(type: .structType(typ), offset: 0x0102)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x0102, to: 0x0100)
            computer.dataRAM.store16(value: 0xcafe, to: 0x0102)
            computer.dataRAM.store16(value: 0xbeef, to: 0x0104)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 0xbeef)
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
        XCTAssertThrowsError(try tryCompile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `*Foo' has no member `asdf'")
        }
    }
    
    func testCompileAssignment_Range() {
        typealias Arg = Expression.StructInitializer.Argument
        let expr = ExprUtils.makeAssignment(name: "foo", right: Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Arg(name: "begin", expr: Expression.LiteralInt(1)),
            Arg(name: "limit", expr: Expression.LiteralInt(10))
        ]))
        let rangeType: SymbolType = .structType(StructType(name: "Range", symbols: SymbolTable([
            "begin" : Symbol(type: .u16, offset: 0),
            "limit" : Symbol(type: .u16, offset: 2)
        ])))
        let symbols = SymbolTable(["foo" : Symbol(type: rangeType, offset: 0x0010, storage: .stackStorage)])
        let ir = mustCompile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        let address = 0xfff0
        XCTAssertEqual(computer.dataRAM.load16(from: address + 0), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: address + 2), 10)
    }
    
    func testCompileFailsWhenCastingUnionTypeToNonMemberType() {
        let union = Expression.UnionType([
            Expression.PrimitiveType(.u8),
            Expression.PrimitiveType(.u16)
        ])
        let expr = Expression.As(expr: union, targetType: Expression.PrimitiveType(.bool))
        XCTAssertThrowsError(try tryCompile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `u8 | u16' to type `bool'")
        }
    }

    func testSuccessfullyCastUnionTypeToMemberType() {
        let expr = Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.PrimitiveType(.u8))
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .u16])), offset: offset, storage: .staticStorage)])
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.isVerboseLogging = true
        executor.configure = { computer in
            computer.dataRAM.store(value: 0, to: offset+0)  // type tag
            computer.dataRAM.store(value: 42, to: offset+1) // storage[0]
            computer.dataRAM.store(value: 0, to: offset+2)  // storage[1]
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 42)
    }
    
    func testTestPrimitiveTypeIsExpression_Succeeds() {
        let expr = Expression.Is(expr: ExprUtils.makeU8(value: 0), testType: Expression.PrimitiveType(.u8))
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 1)
    }
    
    func testTestPrimitiveTypeIsExpression_False() {
        let expr = Expression.Is(expr: ExprUtils.makeU8(value: 0), testType: Expression.PrimitiveType(.bool))
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 0)
    }
    
    func testTestUnionVariantTypeAgainstNonMemberType() {
        let union = Expression.Identifier("foo")
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .u16])), offset: offset, storage: .staticStorage)])
        let expr = Expression.Is(expr: union, testType: Expression.PrimitiveType(.bool))
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 0)
    }
    
    func testTestUnionVariantTypeAgainstKnownMemberType_Tag0() {
        let union = Expression.Identifier("foo")
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .bool])), offset: offset, storage: .staticStorage)])
        let expr = Expression.Is(expr: union, testType: Expression.PrimitiveType(.u8))
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0, to: offset+0)  // type tag
            computer.dataRAM.store(value: 42, to: offset+1) // storage
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 1)
    }
    
    func testTestUnionVariantTypeAgainstKnownMemberType_Tag1() {
        let union = Expression.Identifier("foo")
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u8, .bool])), offset: offset, storage: .staticStorage)])
        let expr = Expression.Is(expr: union, testType: Expression.PrimitiveType(.bool))
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 1, to: offset+0)  // type tag
            computer.dataRAM.store(value: 42, to: offset+1) // storage
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 1)
    }
    
    func testCanAssignToUnionGivenTypeWhichConvertsToMatchingUnionMember() {
        let expr = Expression.Assignment(lexpr: Expression.Identifier("foo"), rexpr: ExprUtils.makeU8(value: 42))
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable(["foo" : Symbol(type: .unionType(UnionType([.u16])), offset: offset, storage: .staticStorage)])
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0xff, to: offset+0) // type tag
            computer.dataRAM.store(value: 0xff, to: offset+1) // storage[0]
            computer.dataRAM.store(value: 0xff, to: offset+2) // storage[1]
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: offset+0), 0)
        XCTAssertEqual(computer.dataRAM.load16(from: offset+1), 0x002a)
    }
    
    func testSubscriptAnArrayWithARange_1() {
        let arrayBase = SnapToCrackleCompiler.kStaticStorageStartAddress
        let n = 10
        let elementType = SymbolType.u8
        
        let symbols = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: SymbolTable(["foo" : Symbol(type: .array(count: n, elementType: elementType), offset: arrayBase)]))
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(1)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(2))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            for i in 0..<n {
                computer.dataRAM.storeValue(value: i, ofType: elementType, to: arrayBase + i*elementType.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        
        let actualSliceBase = computer.dataRAM.loadValue(ofType: .u16, from: tempResult.address + 0)
        let actualSliceCount = computer.dataRAM.loadValue(ofType: .u16, from: tempResult.address + 2)
        
        XCTAssertEqual(actualSliceBase, arrayBase + 1)
        XCTAssertEqual(actualSliceCount, 1)
    }
    
    func testSubscriptAnArrayWithARange_2() {
        let arrayBase = SnapToCrackleCompiler.kStaticStorageStartAddress
        let n = 10
        let elementType = SymbolType.u16
        
        let symbols = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: SymbolTable(["foo" : Symbol(type: .array(count: n, elementType: elementType), offset: arrayBase)]))
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(2)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(8))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        // The expression is evaluated and the result is written to a temporary.
        // The temporary is left at the top of the compiler's temporaries stack
        // since nothing has consumed the value.
        let tempResult = compiler.temporaryStack.peek()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            for i in 0..<n {
                computer.dataRAM.storeValue(value: i, ofType: elementType, to: arrayBase + i*elementType.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        
        let actualSliceBase = computer.dataRAM.loadValue(ofType: .u16, from: tempResult.address + 0)
        let actualSliceCount = computer.dataRAM.loadValue(ofType: .u16, from: tempResult.address + 2)
        
        XCTAssertEqual(actualSliceBase, arrayBase + 4)
        XCTAssertEqual(actualSliceCount, 6)
    }
    
    func testSubscriptAnArrayWithARange_PanicWhenRangeBeginIsOutOfBounds() {
        let arrayBase = SnapToCrackleCompiler.kStaticStorageStartAddress
        let elementType = SymbolType.u16
        
        let symbols = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: SymbolTable(["foo" : Symbol(type: .array(count: 10, elementType: elementType), offset: arrayBase)]))
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(50)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(51))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testSubscriptAnArrayWithARange_PanicWhenRangeLimitIsOutOfBounds() {
        let arrayBase = SnapToCrackleCompiler.kStaticStorageStartAddress
        let elementType = SymbolType.u16
        
        let symbols = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: SymbolTable(["foo" : Symbol(type: .array(count: 10, elementType: elementType), offset: arrayBase)]))
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(50))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testSubscriptADynamicArrayWithARange_1() {
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let elementType = SymbolType.u16
        let begin = 1
        let limit = 9
        let arrayBaseAddress = 0x1000
        let arrayCount = 10
        
        let symbols = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: SymbolTable(["foo" : Symbol(type: .dynamicArray(elementType: elementType), offset: offset)
        ]))
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(begin)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(limit))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(arrayBaseAddress), to: offset)
            computer.dataRAM.store16(value: UInt16(arrayCount), to: offset + SymbolType.u16.sizeof)
        }
        let computer = try! executor.execute(ir: ir)
        
        let actualSliceBase = computer.dataRAM.loadValue(ofType: .u16, from: tempResult.address + 0)
        let actualSliceCount = computer.dataRAM.loadValue(ofType: .u16, from: tempResult.address + SymbolType.u16.sizeof)
        
        XCTAssertEqual(actualSliceBase, arrayBaseAddress + SymbolType.u16.sizeof*begin)
        XCTAssertEqual(actualSliceCount, limit - begin)
    }
    
    func testSubscriptADynamicArrayWithARange_PanicWhenRangeBeginIsOutOfBounds() {
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let elementType = SymbolType.u16
        let begin = 100
        let limit = 109
        let arrayBaseAddress = 0x1000
        let arrayCount = 10
        
        let symbols = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: SymbolTable(["foo" : Symbol(type: .dynamicArray(elementType: elementType), offset: offset)
        ]))
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(begin)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(limit))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(arrayBaseAddress), to: offset)
            computer.dataRAM.store16(value: UInt16(arrayCount), to: offset + SymbolType.u16.sizeof)
        }
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testSubscriptADynamicArrayWithARange_PanicWhenRangeLimitIsOutOfBounds() {
        let offset = SnapToCrackleCompiler.kStaticStorageStartAddress
        let elementType = SymbolType.u16
        let begin = 0
        let limit = 100
        let arrayBaseAddress = 0x1000
        let arrayCount = 10
        
        let symbols = RvalueExpressionCompiler.bindCompilerIntrinsics(symbols: SymbolTable(["foo" : Symbol(type: .dynamicArray(elementType: elementType), offset: offset)
        ]))
        let range = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(begin)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(limit))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(arrayBaseAddress), to: offset)
            computer.dataRAM.store16(value: UInt16(arrayCount), to: offset + SymbolType.u16.sizeof)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testLiteralString() {
        let expr = Expression.LiteralString("foo")
        let compiler = makeCompiler()
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 0), "f".utf8.first)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 1), "o".utf8.first)
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address + 2), "o".utf8.first)
    }
    
    func testCannotTakeTheAddressOfAFunctionWithoutACorrespondingLabel() {
        let name = "foo"
        let expr = Expression.Unary(op: .ampersand, expression: Expression.Identifier(name))
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        let symbols = SymbolTable()
        symbols.bind(identifier: name, symbol: symbol)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let executor = CrackleExecutor()
        XCTAssertThrowsError(try executor.execute(ir: ir)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot resolve label `foo'")
        }
    }
    
    func testTakingTheAddressOfAFunctionYieldsTheAddressOfTheCorrespondingLabel() {
        let name = "panic"
        let expr = Expression.Unary(op: .ampersand, expression: Expression.Identifier(name))
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        let symbols = SymbolTable()
        symbols.bind(identifier: name, symbol: symbol)
        let compiler = makeCompiler(symbols: symbols)
        let ir = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 16)
    }
    
    func testCallFunctionThroughFunctionPointer() {
        let expr = Expression.Call(callee: Expression.Identifier("bar"), arguments: [])
        var addressOfFoo: UInt16 = 0
        let addressOfBar = SnapToCrackleCompiler.kStaticStorageStartAddress
        let symbols = SymbolTable([
            "foo" : Symbol(type: .function(FunctionType(name: "foo", returnType: .void, arguments: [])), offset: 0),
            "bar" : Symbol(type: .pointer(.function(FunctionType(name: "foo", returnType: .void, arguments: []))), offset: addressOfBar),
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = mustCompile(compiler: compiler, expression: expr)
        let executor = CrackleExecutor()
        executor.injectCode = { (compiler: CrackleToTurtleMachineCodeCompiler) in
            try! compiler.injectCode([
                .label("foo"),
                .storeImmediate(0xabcd, 42),
                .leafRet
            ])
            addressOfFoo = UInt16(compiler.labelTable["foo"]!)
        }
        executor.configure = { computer in
            computer.dataRAM.store16(value: addressOfFoo, to: addressOfBar)
        }
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(computer.dataRAM.load(from: 0xabcd), 42)
    }
    
    func testGetArrayFromStructAndSubscriptIt() {
        let foo = Expression.Identifier("foo")
        let bar = Expression.Identifier("bar")
        let zero = Expression.LiteralInt(0)
        let getExpr = Expression.Get(expr: foo, member: bar)
        let expr = Expression.Subscript(subscriptable: getExpr, argument: zero)
        
        let addressOfFoo = SnapToCrackleCompiler.kStaticStorageStartAddress
        let Foo: SymbolType = .structType(StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0)
        ])))
        let symbols = SymbolTable([
            "foo" : Symbol(type: Foo, offset: addressOfFoo)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 42, to: addressOfFoo)
        }
        let computer = try! executor.execute(ir: actual)
        
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 42)
    }
    
    func testGetDynamicArrayFromStructAndSubscriptIt() {
        let foo = Expression.Identifier("foo")
        let bar = Expression.Identifier("bar")
        let zero = Expression.LiteralInt(0)
        let getExpr = Expression.Get(expr: foo, member: bar)
        let expr = Expression.Subscript(subscriptable: getExpr, argument: zero)
        
        let addressOfFoo = SnapToCrackleCompiler.kStaticStorageStartAddress
        let Foo: SymbolType = .structType(StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .dynamicArray(elementType: .u8), offset: 0)
        ])))
        let symbols = SymbolTable([
            "foo" : Symbol(type: Foo, offset: addressOfFoo)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            let arrayBaseAddress = 0x1000
            computer.dataRAM.store(value: 42, to: arrayBaseAddress)
            computer.dataRAM.store16(value: UInt16(arrayBaseAddress), to: addressOfFoo + self.kSliceBaseAddressOffset)
            computer.dataRAM.store16(value: 1, to: addressOfFoo + self.kSliceCountOffset)
        }
        let computer = try! executor.execute(ir: actual)
        
        XCTAssertEqual(computer.dataRAM.load(from: tempResult.address), 42)
    }
    
    func testGetArrayFromStructAndSubscriptItWithARange() {
        let foo = Expression.Identifier("foo")
        let bar = Expression.Identifier("bar")
        let range = ExprUtils.makeRange(0, 1)
        let getExpr = Expression.Get(expr: foo, member: bar)
        let expr = Expression.Subscript(subscriptable: getExpr, argument: range)
        
        let addressOfFoo = SnapToCrackleCompiler.kStaticStorageStartAddress
        let Foo: SymbolType = .structType(StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0)
        ])))
        let symbols = SymbolTable([
            "foo" : Symbol(type: Foo, offset: addressOfFoo)
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = mustCompile(compiler: compiler, expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        
        // Check that the array slice is as expected.
        XCTAssertEqual(tempResult.size, 4)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + kSliceBaseAddressOffset), UInt16(addressOfFoo))
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address + kSliceCountOffset), 1)
    }
}
