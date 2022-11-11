//
//  SnapASTToTackASTCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore
import Turtle16SimulatorCore


let kSliceName = "Slice"
let kSliceBase = "base"
let kSliceBaseAddressOffset = 0
let kSliceBaseAddressType = SymbolType.arithmeticType(.mutableInt(.u16))
let kSliceCount = "count"
let kSliceCountOffset = 1
let kSliceCountType = SymbolType.arithmeticType(.mutableInt(.u16))
let kSliceType: SymbolType = .structType(StructType(name: kSliceName, symbols: SymbolTable(tuples: [
    (kSliceBase,  Symbol(type: kSliceBaseAddressType, offset: kSliceBaseAddressOffset)),
    (kSliceCount, Symbol(type: kSliceCountType, offset: kSliceCountOffset))
])))
let kRangeName = "Range"
let kRangeBegin = "begin"
let kRangeLimit = "limit"
let kRangeType: SymbolType = .structType(StructType(name: kRangeName, symbols: SymbolTable(tuples: [
    (kRangeBegin, Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage)),
    (kRangeLimit, Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1, storage: .automaticStorage))
])))


class SnapASTToTackASTCompilerTests: XCTestCase {
    func makeCompiler(options opts: SnapASTToTackASTCompiler.Options = SnapASTToTackASTCompiler.Options(isBoundsCheckEnabled: true), symbols: SymbolTable = SymbolTable()) -> SnapASTToTackASTCompiler {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
                                                  globalSymbols: symbols)
        return SnapASTToTackASTCompiler(symbols: symbols,
                                  globalEnvironment: globalEnvironment,
                                  options: opts)
    }
    
    func testLabelDeclaration() throws {
        let compiler = makeCompiler()
        let result = try compiler.compileWithEpilog(LabelDeclaration(identifier: "foo"))
        XCTAssertEqual(result, LabelDeclaration(identifier: "foo"))
    }
    
    func testBlockWithOneInstruction() throws {
        let compiler = makeCompiler()
        let result = try compiler.compileWithEpilog(Block(children: [
            LabelDeclaration(identifier: "foo")
        ]))
        XCTAssertEqual(result, LabelDeclaration(identifier: "foo"))
    }
    
    func testBlockWithTwoInstructions() throws {
        let compiler = makeCompiler()
        let result = try compiler.compileWithEpilog(Block(children: [
            LabelDeclaration(identifier: "foo"),
            LabelDeclaration(identifier: "bar")
        ]))
        XCTAssertEqual(result, Seq(children: [
            LabelDeclaration(identifier: "foo"),
            LabelDeclaration(identifier: "bar")
        ]))
    }
    
    func testBlockWithNestedSeq() throws {
        let compiler = makeCompiler()
        let result = try compiler.compileWithEpilog(Block(children: [
            LabelDeclaration(identifier: "foo"),
            Seq(children: [
                LabelDeclaration(identifier: "bar"),
                LabelDeclaration(identifier: "baz")
            ])
        ]))
        XCTAssertEqual(result, Seq(children: [
            LabelDeclaration(identifier: "foo"),
            LabelDeclaration(identifier: "bar"),
            LabelDeclaration(identifier: "baz")
        ]))
    }
    
    func testGoto() throws {
        let compiler = makeCompiler()
        let result = try compiler.compileWithEpilog(Goto(target: "foo"))
        XCTAssertEqual(result, TackInstructionNode(.jmp("foo")))
    }
    
    func testGotoIfFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compileWithEpilog(GotoIfFalse(condition: Expression.LiteralBool(false), target: "bar"))
        let expected = Seq(children: [
            TackInstructionNode(.li16(.vr(0), 0)),
            TackInstructionNode(.bz(.vr(0), "bar"))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertTrue(compiler.registerStack.isEmpty)
    }

    func testRet() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compileWithEpilog(Return())
        let expected = Seq(children: [
            TackInstructionNode(.leave),
            TackInstructionNode(.ret)
        ])
        XCTAssertEqual(actual, expected)
    }

    func testCompileFunctionDeclaration_Simplest() throws {
        let fn1 = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                     functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                     argumentNames: [],
                                     body: Block(children: [
                                        Return()
                                     ]))
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        try SnapSubcompilerFunctionDeclaration()
            .compile(globalEnvironment: globalEnvironment,
                     symbols: symbols,
                     node: fn1)
        let opts = SnapASTToTackASTCompiler.Options(isBoundsCheckEnabled: true)
        let compiler = SnapASTToTackASTCompiler(symbols: symbols,
                                          globalEnvironment: globalEnvironment,
                                          options: opts)
        let actual = try compiler.compileWithEpilog(nil)
        let expected = Subroutine(identifier: "foo", children: [
            TackInstructionNode(.enter(0)),
            TackInstructionNode(.leave),
            TackInstructionNode(.ret)
        ])
        XCTAssertEqual(actual, expected)
    }

    func testExpr_LiteralBoolFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compileWithEpilog(Expression.LiteralBool(false))
        let expected = TackInstructionNode(.li16(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_LiteralBoolFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.LiteralBool(false))
        let expected = TackInstructionNode(.li16(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_LiteralBoolTrue() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.LiteralBool(true))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_LiteralInt_Small_Positive() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.LiteralInt(1))
        let expected = TackInstructionNode(.liu8(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_LiteralInt_Small_Negative() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.LiteralInt(-1))
        let expected = TackInstructionNode(.li8(.vr(0), -1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_LiteralInt_Big() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.LiteralInt(0x1000))
        let expected = TackInstructionNode(.liu16(.vr(0), 0x1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_LiteralInt_Big_Negative() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.LiteralInt(-1000))
        let expected = TackInstructionNode(.li16(.vr(0), -1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_LiteralArray_primitive_type() throws {
        let compiler = makeCompiler()
        let arrType = Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let actual = try compiler.rvalue(expr: Expression.LiteralArray(arrayType: arrType, elements: [Expression.LiteralInt(42)]))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu16(.vr(1), 42)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_LiteralArray_non_primitive_type() throws {
        let compiler = makeCompiler()
        let inner = Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let outer = Expression.ArrayType(count: Expression.LiteralInt(1), elementType: inner)
        let actual = try compiler.rvalue(expr: Expression.LiteralArray(arrayType: outer, elements: [
            Expression.LiteralArray(arrayType: inner, elements: [Expression.LiteralInt(42)])
        ]))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu8(.vr(1), 0)),
            TackInstructionNode(.add16(.vr(2), .vr(1), .vr(0))),
            TackInstructionNode(.liu16(.vr(3), 273)),
            TackInstructionNode(.liu16(.vr(4), 42)),
            TackInstructionNode(.store(.vr(4), .vr(3), 0)),
            TackInstructionNode(.memcpy(.vr(2), .vr(3), 1)),
            TackInstructionNode(.liu16(.vr(5), 272))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(5))
    }

    func testRvalue_LiteralString() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.LiteralString("a"))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.ststr(.vr(0), "a"))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_StructInitializer() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.StructInitializer(identifier: Expression.Identifier(kSliceName), arguments: [
            Expression.StructInitializer.Argument(name: kSliceBase,
                                                  expr: Expression.LiteralInt(0xabcd)),
            Expression.StructInitializer.Argument(name: kSliceCount,
                                                  expr: Expression.LiteralInt(0xffff))
        ]))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0xabcd)),
            TackInstructionNode(.store(.vr(2), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(3), 272)),
            TackInstructionNode(.addi16(.vr(4), .vr(3), 1)),
            TackInstructionNode(.liu16(.vr(5), 0xffff)),
            TackInstructionNode(.store(.vr(5), .vr(4), 0)),
            TackInstructionNode(.liu16(.vr(6), 272))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(6))
    }

    func testRvalue_Identifier_Static_u16() throws {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = makeCompiler(symbols: SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: offset, storage: .staticStorage))
        ]))
        let actual = try compiler.rvalue(expr: Expression.Identifier("foo"))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), offset)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Identifier_Stack_u16() throws {
        let offset = 4
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: offset, storage: .automaticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Identifier("foo"))
        let expected = Seq(children: [
            TackInstructionNode(.subi16(.vr(0), .fp, offset)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Identifier_struct() throws {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = makeCompiler(symbols: SymbolTable(tuples: [
            ("foo", Symbol(type: kSliceType, offset: offset, storage: .staticStorage))
        ]))
        let actual = try compiler.rvalue(expr: Expression.Identifier("foo"))
        let expected = TackInstructionNode(.liu16(.vr(0), offset))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_u8_to_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_As_u8_to_u16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_As_u16_to_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.andi16(.vr(2), .vr(1), 0x00ff))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_As_u8_to_i16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_As_i16_to_i8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.sxt8(.vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_As_array_to_array_of_same_type() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))))
        let expected = TackInstructionNode(.liu16(.vr(0), 0xabcd))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_array_to_array_with_different_type_that_can_be_trivially_reinterpreted() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 0, elementType: .arithmeticType(.mutableInt(.u8))), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))))
        let expected = TackInstructionNode(.liu16(.vr(0), 0xabcd))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_array_to_array_where_each_element_must_be_converted() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu8(.vr(1), 0)),
            TackInstructionNode(.add16(.vr(2), .vr(1), .vr(0))),
            TackInstructionNode(.liu16(.vr(3), 0x1000)),
            TackInstructionNode(.liu8(.vr(4), 0)),
            TackInstructionNode(.add16(.vr(5), .vr(4), .vr(3))),
            TackInstructionNode(.load(.vr(6), .vr(5), 0)),
            TackInstructionNode(.andi16(.vr(7), .vr(6), 0x00ff)),
            TackInstructionNode(.store(.vr(7), .vr(2), 0)),
            TackInstructionNode(.liu16(.vr(8), 272))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(8))
    }

    func testRvalue_As_array_to_dynamic_array() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu16(.vr(1), 0x1000)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 1)),
            TackInstructionNode(.store(.vr(2), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_literal_array_to_dynamic_array() throws {
        let compiler = makeCompiler()
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))), elements: [Expression.LiteralInt(1)])
        let actual = try compiler.rvalue(expr: Expression.As(expr: arr, targetType: Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu16(.vr(1), 274)),
            TackInstructionNode(.liu16(.vr(2), 1)),
            TackInstructionNode(.store(.vr(2), .vr(1), 0)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(3), 1)),
            TackInstructionNode(.store(.vr(3), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_compTimeInt_small() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.compTimeInt(42)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))))
        let expected = TackInstructionNode(.liu8(.vr(0), 42))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_compTimeInt_big() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.compTimeInt(1000)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))))
        let expected = TackInstructionNode(.liu16(.vr(0), 1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_compTimeBool_true() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool(.compTimeBool(true)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.bool(.mutableBool))))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_compTimeBool_false() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool(.compTimeBool(false)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.bool(.mutableBool))))
        let expected = TackInstructionNode(.li16(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_pointer_to_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PointerType(Expression.PrimitiveType(.arithmeticType(.immutableInt(.u16))))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_As_union_to_union() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u16))])), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.UnionType([Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))])))
        let expected = TackInstructionNode(.liu16(.vr(0), 0xabcd))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_union_to_primitive() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u16))])), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_As_union_to_non_primitive() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.array(count: 1, elementType: .arithmeticType(.mutableInt(.u16)))])), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_As_convert_primitive_value_to_union() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.UnionType([Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))])))
        let expected = Seq(children: [
            TackInstructionNode(.subi16(.vr(0), .fp, 2)),
            TackInstructionNode(.liu16(.vr(1), 0)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0xabcd)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.store(.vr(3), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_determine_union_type_tag() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.UnionType([Expression.PrimitiveType(.bool(.mutableBool)), Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))])))
        let expected = Seq(children: [
            TackInstructionNode(.subi16(.vr(0), .fp, 2)),
            TackInstructionNode(.liu16(.vr(1), 1)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0xabcd)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.store(.vr(3), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_convert_non_primitive_value_to_union() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"), targetType: Expression.UnionType([Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))])))
        let expected = Seq(children: [
            TackInstructionNode(.subi16(.vr(0), .fp, 3)),
            TackInstructionNode(.liu16(.vr(1), 0)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.addi16(.vr(2), .vr(0), 1)),
            TackInstructionNode(.liu16(.vr(3), 0xabcd)),
            TackInstructionNode(.memcpy(.vr(2), .vr(3), 2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_As_union_to_primitive_with_dynamic_type_check() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.bool(.mutableBool), .arithmeticType(.mutableInt(.u16))])), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.As(expr: Expression.Identifier("foo"),
                                                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.subi16(.vr(2), .vr(1), 1)),
            TackInstructionNode(.bz(.vr(2), ".L0")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.load(.vr(3), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Bitcast_u16_to_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Bitcast(expr: Expression.Identifier("foo"),
                                                                  targetType: Expression.PointerType(Expression.PrimitiveType(.arithmeticType(.immutableInt(.u16))))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Group() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.Group(Expression.LiteralBool(false)))
        let expected = TackInstructionNode(.li16(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Unary_minus_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .minus, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu8(.vr(2), 0)),
            TackInstructionNode(.sub8(.vr(3), .vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Unary_minus_u16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .minus, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0)),
            TackInstructionNode(.sub16(.vr(3), .vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Unary_minus_i8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i8)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .minus, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu8(.vr(2), 0)),
            TackInstructionNode(.sub8(.vr(3), .vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Unary_minus_i16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .minus, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0)),
            TackInstructionNode(.sub16(.vr(3), .vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Unary_bang_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool(.mutableBool), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .bang, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.not(.vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Unary_tilde_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .tilde, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.neg8(.vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Unary_tilde_u16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .tilde, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.neg16(.vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Unary_tilde_i8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i8)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .tilde, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.neg8(.vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Unary_tilde_i16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .tilde, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.neg16(.vr(2), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Unary_addressOf_Function() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .void, arguments: []))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo")))
        let expected = TackInstructionNode(.la(.vr(0), "foo"))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Unary_addressOf_Identifier() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo")))
        let expected = TackInstructionNode(.liu16(.vr(0), 100))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_add16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .plus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.add16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_sub16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .minus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.sub16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_mul16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .star, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.mul16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_div16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .divide, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.div16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_mod16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .modulus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.mod16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_lsl16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .leftDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.lsl16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_lsr16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .rightDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.lsr16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_and16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ampersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.and16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_or16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .pipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.or16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_xor16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .caret, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.xor16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_eq16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.eq16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_ne16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.ne16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_lt16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .lt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.lt16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_ge16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ge, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.ge16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_le16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .le, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.le16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_gt16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.i16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .gt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.gt16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_ltu16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .lt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.ltu16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_geu16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ge, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.geu16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_leu16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .le, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.leu16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_gtu16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .gt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.gtu16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_add8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .plus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.add8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_sub8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .minus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.sub8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_mul8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .star, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.mul8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_div8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .divide, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.div8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_mod8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .modulus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.mod8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_lsl8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .leftDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.lsl8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_lsr8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .rightDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.lsr8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_and8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ampersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.and8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_or8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .pipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.or8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_xor8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .caret, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.xor8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_eq8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.eq8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_ne8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.ne8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_ltu8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .lt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.ltu8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_geu8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ge, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.geu8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_leu8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .le, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.leu8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_gtu8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .gt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.gtu8(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_comptime_eq() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_ne() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_lt() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .lt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_gt() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(2)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .gt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_le() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .le, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_ge() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ge, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_add() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(-1000)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(-1000))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .plus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), -2000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_sub() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .minus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_mul() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .star, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_div() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .divide, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_mod() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(3)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .modulus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_and() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(0xab)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(0x0f))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ampersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 0xb))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_or() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(0xab)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(0x0f))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .pipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 0xaf))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_xor() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(0xab)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(0xab))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .caret, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_lsl() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(2)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .leftDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 8))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_lsr() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(8)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .rightDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.liu8(.vr(0), 2))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_eq_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.mutableBool), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool(.mutableBool), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.eq16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_ne_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.mutableBool), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool(.mutableBool), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 200)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 100)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.ne16(.vr(4), .vr(3), .vr(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_logical_and() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.mutableBool), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool(.mutableBool), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .doubleAmpersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.bz(.vr(1), ".L0")),
            TackInstructionNode(.liu16(.vr(2), 200)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.bz(.vr(3), ".L0")),
            TackInstructionNode(.li16(.vr(4), 1)),
            TackInstructionNode(.jmp(".L1")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.li16(.vr(4), 0)),
            LabelDeclaration(identifier: ".L1")
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_logical_or() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.mutableBool), offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool(.mutableBool), offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .doublePipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 100)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.bnz(.vr(1), ".L0")),
            TackInstructionNode(.liu16(.vr(2), 200)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.bnz(.vr(3), ".L0")),
            TackInstructionNode(.li16(.vr(4), 0)),
            TackInstructionNode(.jmp(".L1")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.li16(.vr(4), 1)),
            LabelDeclaration(identifier: ".L1")
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(4))
    }

    func testRvalue_Binary_comptime_bool_eq() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.compTimeBool(true)))),
             ("right", Symbol(type: .bool(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_bool_ne() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.compTimeBool(true)))),
            ("right", Symbol(type: .bool(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_bool_and() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.compTimeBool(true)))),
            ("right", Symbol(type: .bool(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .doubleAmpersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Binary_comptime_bool_or() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool(.compTimeBool(true)))),
            ("right", Symbol(type: .bool(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Binary(op: .doublePipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Is_comptime_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Is(expr: Expression.Identifier("foo"), testType: Expression.PrimitiveType(.bool(.compTimeBool(true)))))
        let expected = TackInstructionNode(.li16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Is_test_union_type_tag() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u8)), .bool(.mutableBool)])), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Is(expr: Expression.Identifier("foo"), testType: Expression.PrimitiveType(.bool(.mutableBool))))
        let expected = Seq(children: [
            TackInstructionNode(.li16(.vr(0), 1)),
            TackInstructionNode(.liu16(.vr(1), 100)),
            TackInstructionNode(.load(.vr(2), .vr(1), 0)),
            TackInstructionNode(.eq16(.vr(3), .vr(2), .vr(0)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Is_test_union_type_tag_const() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.immutableInt(.u8)), .bool(.immutableBool)])), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Is(expr: Expression.Identifier("foo"), testType: Expression.PrimitiveType(.bool(.mutableBool))))
        let expected = Seq(children: [
            TackInstructionNode(.li16(.vr(0), 1)),
            TackInstructionNode(.liu16(.vr(1), 100)),
            TackInstructionNode(.load(.vr(2), .vr(1), 0)),
            TackInstructionNode(.eq16(.vr(3), .vr(2), .vr(0)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Assignment_ToPrimitiveScalar() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x1000, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                                     rexpr: Expression.LiteralInt(42)))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.liu16(.vr(1), 42)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Assignment_ArrayToArray_Size_0() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 0, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage)),
            ("bar", Symbol(type: .array(count: 0, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x2000, storage: .staticStorage)),
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                                     rexpr: Expression.Identifier("bar")))
        let expected = TackInstructionNode(.liu16(.vr(0), 0x1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Assignment_ArrayToArray_Size_1() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage)),
            ("bar", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x2000, storage: .staticStorage)),
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                                     rexpr: Expression.Identifier("bar")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.liu16(.vr(1), 0x2000)),
            TackInstructionNode(.memcpy(.vr(0), .vr(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Assignment_ArrayToArray_Size_2() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage)),
            ("bar", Symbol(type: .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x2000, storage: .staticStorage)),
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                                     rexpr: Expression.Identifier("bar")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.liu16(.vr(1), 0x2000)),
            TackInstructionNode(.memcpy(.vr(0), .vr(1), 2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_SubscriptRvalue_CompileTimeIndexAndPrimitiveElement() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: Expression.LiteralInt(9)))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.liu8(.vr(1), 9)),
            TackInstructionNode(.add16(.vr(2), .vr(1), .vr(0))),
            TackInstructionNode(.load(.vr(3), .vr(2), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_SubscriptRvalue_RuntimeTimeIndexAndPrimitiveElement() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: ExprUtils.makeU16(value: 9)))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.liu16(.vr(1), 9)),
            TackInstructionNode(.li16(.vr(2), 0)),
            TackInstructionNode(.ge16(.vr(3), .vr(1), .vr(2))),
            TackInstructionNode(.bnz(.vr(3), ".L0")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.li16(.vr(4), 10)),
            TackInstructionNode(.lt16(.vr(5), .vr(1), .vr(4))),
            TackInstructionNode(.bnz(.vr(5), ".L1")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L1"),
            TackInstructionNode(.add16(.vr(6), .vr(1), .vr(0))),
            TackInstructionNode(.load(.vr(7), .vr(6), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(7))
    }

    func testRvalue_SubscriptRvalue_ZeroSizeElement() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .void), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: ExprUtils.makeU16(value: 9)))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_SubscriptRvalue_NestedArray() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: ExprUtils.makeU16(value: 9)))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.liu16(.vr(1), 9)),
            TackInstructionNode(.li16(.vr(2), 0)),
            TackInstructionNode(.ge16(.vr(3), .vr(1), .vr(2))),
            TackInstructionNode(.bnz(.vr(3), ".L0")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.li16(.vr(4), 10)),
            TackInstructionNode(.lt16(.vr(5), .vr(1), .vr(4))),
            TackInstructionNode(.bnz(.vr(5), ".L1")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L1"),
            TackInstructionNode(.muli16(.vr(6), .vr(1), 2)),
            TackInstructionNode(.add16(.vr(7), .vr(6), .vr(0)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(7))
    }

    func testRvalue_SubscriptRvalue_DynamicArray() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: ExprUtils.makeU16(value: 9)))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 9)),
            TackInstructionNode(.li16(.vr(3), 0)),
            TackInstructionNode(.ge16(.vr(4), .vr(2), .vr(3))),
            TackInstructionNode(.bnz(.vr(4), ".L0")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.load(.vr(5), .vr(0), 1)),
            TackInstructionNode(.lt16(.vr(6), .vr(2), .vr(5))),
            TackInstructionNode(.bnz(.vr(6), ".L1")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L1"),
            TackInstructionNode(.add16(.vr(7), .vr(2), .vr(1))),
            TackInstructionNode(.load(.vr(8), .vr(7), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(8))
    }

    func testRvalue_compiler_error_when_index_is_known_negative_at_compile_time() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.rvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: Expression.LiteralInt(-1)))) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Array index is always out of bounds: `-1' is less than zero")
        }
    }

    func testRvalue_compiler_error_when_index_is_known_oob_at_compile_time() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.rvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: Expression.LiteralInt(100)))) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Array index is always out of bounds: `100' is not in 0..10")
        }
    }

    func testLvalue_compiler_error_when_index_is_known_negative_at_compile_time() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.lvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: Expression.LiteralInt(-1)))) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Array index is always out of bounds: `-1' is less than zero")
        }
    }

    func testLvalue_compiler_error_when_index_is_known_oob_at_compile_time() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.lvalue(expr: Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: Expression.LiteralInt(100)))) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Array index is always out of bounds: `100' is not in 0..10")
        }
    }

    func testRvalue_Assignment_ToArrayElementViaSubscript() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 10, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Assignment(
            lexpr: Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                        argument: Expression.LiteralInt(9)),
            rexpr: Expression.LiteralInt(42))
        )
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.liu8(.vr(1), 9)),
            TackInstructionNode(.add16(.vr(2), .vr(1), .vr(0))),
            TackInstructionNode(.liu16(.vr(3), 42)),
            TackInstructionNode(.store(.vr(3), .vr(2), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Assignment_automatic_conversion_from_object_to_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage)),
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2000, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                                     rexpr: Expression.Identifier("bar")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.liu16(.vr(1), 0x2000)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Assignment_automatic_conversion_from_object_to_pointer_requires_lvalue() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u16))), offset: 0x1000, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let expr = Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                         rexpr: ExprUtils.makeU16(value: 42))
        XCTAssertThrowsError(try compiler.lvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "lvalue required")
        }
    }

    func testRvalue_Assignment_automatic_conversion_from_trait_to_pointer() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = globalEnvironment.globalSymbols
        let traitDecl = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                         members: [],
                                         visibility: .privateVisibility)
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(traitDecl)

        let traitObjectType = try symbols.resolveType(identifier: traitDecl.nameOfTraitObjectType)
        symbols.bind(identifier: "foo", symbol: Symbol(type: .pointer(traitObjectType), offset: 0x1000, storage: .staticStorage))

        let traitType = try symbols.resolveType(identifier: traitDecl.identifier.identifier)
        symbols.bind(identifier: "bar", symbol: Symbol(type: traitType, offset: 0x2000, storage: .staticStorage))

        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                                     rexpr: Expression.Identifier("bar")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.liu16(.vr(1), 0x2000)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Get_array_count() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 42, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("count")))
        let expected = TackInstructionNode(.liu16(.vr(0), 42))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Get_dynamic_array_count() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("count")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Get_struct_member_primitive() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: kSliceType, offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("count")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Get_struct_member_not_primitive() throws {
        let type: SymbolType = .structType(StructType(name: "bar", symbols: SymbolTable(tuples: [
            ("wat", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0)),
            ("baz", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))), offset: 1))
        ])))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: type, offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("baz")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Get_pointee_primitive() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("pointee")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.load(.vr(2), .vr(1), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testLvalue_Get_pointee_primitive() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.lvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("pointee")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testLvalue_Bitcast() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u16))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.lvalue(expr: Expression.Bitcast(expr: Expression.Get(expr: Expression.Identifier("foo"), member: Expression.Identifier("pointee")), targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Get_pointee_not_primitive() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.array(count: 1, elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("pointee")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_Get_array_count_via_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.array(count: 42, elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("count")))
        let expected = TackInstructionNode(.liu16(.vr(0), 42))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_Get_dynamic_array_count_via_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.dynamicArray(elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("count")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.load(.vr(2), .vr(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Get_primitive_struct_member_via_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(kSliceType), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("count")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.load(.vr(2), .vr(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Get_non_primitive_struct_member_via_pointer() throws {
        let type: SymbolType = .pointer(.structType(StructType(name: "bar", symbols: SymbolTable(tuples: [
            ("wat", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0)),
            ("baz", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))), offset: 1))
        ]))))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: type, offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Get(expr: Expression.Identifier("foo"),
                                                              member: Expression.Identifier("baz")))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.addi16(.vr(2), .vr(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Call_no_return_no_args() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .void, arguments: []))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("foo"), arguments: []))
        let expected = TackInstructionNode(.call("foo"))
        XCTAssertEqual(actual, expected)
    }

    func testRvalue_Call_return_some_primitive_value_and_no_args() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .arithmeticType(.mutableInt(.u16)), arguments: []))))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("foo"), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.alloca(.vr(0), 1)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.subi16(.vr(1), .fp, 1)),
            TackInstructionNode(.memcpy(.vr(1), .vr(0), 1)),
            TackInstructionNode(.free(1)),
            TackInstructionNode(.subi16(.vr(2), .fp, 1)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(3))
    }

    func testRvalue_Call_return_some_non_primitive_value_and_no_args() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), arguments: []))))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("foo"), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.alloca(.vr(0), 2)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.subi16(.vr(1), .fp, 2)),
            TackInstructionNode(.memcpy(.vr(1), .vr(0), 2)),
            TackInstructionNode(.free(2)),
            TackInstructionNode(.subi16(.vr(2), .fp, 2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(2))
    }

    func testRvalue_Call_one_primitive_arg() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .void, arguments: [
                .arithmeticType(.mutableInt(.u16))
            ]))))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("foo"), arguments: [
            Expression.LiteralInt(0x1000)
        ]))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.alloca(.vr(1), 1)),
            TackInstructionNode(.store(.vr(0), .vr(1), 0)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.free(1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_Call_return_value_and_one_arg() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .arithmeticType(.mutableInt(.u16)), arguments: [.arithmeticType(.mutableInt(.u16))]))))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("foo"), arguments: [Expression.LiteralInt(0xabcd)]))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.alloca(.vr(1), 1)),
            TackInstructionNode(.alloca(.vr(2), 1)),
            TackInstructionNode(.store(.vr(0), .vr(2), 0)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.subi16(.vr(3), .fp, 1)),
            TackInstructionNode(.memcpy(.vr(3), .vr(1), 1)),
            TackInstructionNode(.free(2)),
            TackInstructionNode(.subi16(.vr(4), .fp, 1)),
            TackInstructionNode(.load(.vr(5), .vr(4), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(5))
    }

    func testRvalue_Call_return_value_and_one_non_primitive_arg() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .arithmeticType(.mutableInt(.u16)), arguments: [.unionType(UnionType([.arithmeticType(.mutableInt(.u16))]))])))),
            ("bar", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u16))])), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("foo"), arguments: [
            Expression.LiteralInt(1000)
        ]))
        let expected = Seq(children: [
            TackInstructionNode(.subi16(.vr(0), .fp, 3)),
            TackInstructionNode(.liu16(.vr(1), 0)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 1000)),
            TackInstructionNode(.store(.vr(2), .vr(0), 1)),
            TackInstructionNode(.alloca(.vr(3), 1)),
            TackInstructionNode(.alloca(.vr(4), 2)),
            TackInstructionNode(.memcpy(.vr(4), .vr(0), 2)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.subi16(.vr(5), .fp, 1)),
            TackInstructionNode(.memcpy(.vr(5), .vr(3), 1)),
            TackInstructionNode(.free(3)),
            TackInstructionNode(.subi16(.vr(6), .fp, 1)),
            TackInstructionNode(.load(.vr(7), .vr(6), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(7))
    }

    func testRvalue_Call_function_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.function(FunctionType(returnType: .void, arguments: []))), offset: 0xabcd))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("foo"), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0)),
            TackInstructionNode(.callptr(.vr(1)))
        ])
        XCTAssertEqual(actual, expected)
    }

    func testRvalue_Call_panic_with_string_arg() throws {
        let symbols = SymbolTable(tuples: [
            ("panic", Symbol(type: .function(FunctionType(name: "panic", mangledName: "panic", returnType: .void, arguments: [.dynamicArray(elementType: .arithmeticType(.immutableInt(.u8)))]))))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Identifier("panic"), arguments: [
            Expression.LiteralString("panic")
        ]))
        let expected = Seq(children: [
            TackInstructionNode(.subi16(.vr(0), .fp, 2)),
            TackInstructionNode(.subi16(.vr(1), .fp, 7)),
            TackInstructionNode(.ststr(.vr(1), "panic")),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 5)),
            TackInstructionNode(.store(.vr(2), .vr(0), 1)),
            TackInstructionNode(.alloca(.vr(3), 2)), // TODO: This ALLOCA and MEMCPY are not actually necessary since vr0 contains the address of the dynamic array in memory already.
            TackInstructionNode(.memcpy(.vr(3), .vr(0), 2)),
            TackInstructionNode(.call("panic")),
            TackInstructionNode(.free(2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_Call_struct_member_function_call_1() throws {
        // Define an instance `foo' of a struct `Foo' which contains a function
        // pointer member `bar(*const Foo)'.
        // Because the first parameter of Bar is `*Foo', we can call the
        // function with a convenient syntax. A call of the form `foo.bar()' is
        // equivalent to a call `foo.bar(&foo)'.
        //
        // This test is for the case where the callee of the Call expression is
        // A Get expression where expr is of the type `Foo' and the function's
        // first argument is of the type `*Foo'
        let globalSymbols = SymbolTable()
        let fooSymbols = SymbolTable()
        let fooType = SymbolType.structType(StructType(name: "Foo", symbols: fooSymbols))
        let fnType = FunctionType(name: "bar", mangledName: "bar", returnType: .void, arguments: [
            .pointer(fooType)
        ])
        fooSymbols.bind(identifier: "bar", symbol: Symbol(type: .function(fnType)))
        globalSymbols.bind(identifier: "Foo", symbolType: fooType)
        globalSymbols.bind(identifier: "foo", symbol: Symbol(type: fooType, offset: 0x1000, storage: .staticStorage))

        let compiler = makeCompiler(symbols: globalSymbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Get(expr: Expression.Identifier("foo"), member: Expression.Identifier("bar")), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu16(.vr(1), 0x1000)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 272)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.alloca(.vr(4), 1)),
            TackInstructionNode(.store(.vr(3), .vr(4), 0)),
            TackInstructionNode(.call("bar")),
            TackInstructionNode(.free(1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_Call_struct_member_function_call_2() throws {
        // Define an instance `foo' of a struct `Foo' which contains a function
        // pointer member `bar(*const Foo)'.
        // Because the first parameter of Bar is `*const Foo', we can call the
        // function with a convenient syntax. A call of the form `foo.bar()' is
        // equivalent to a call `foo.bar(&foo)'.
        //
        // This test is for the case where the callee of the Call expression is
        // A Get expression where expr is of the type `Foo' and the function's
        // first argument is of the type `*const Foo'
        let globalSymbols = SymbolTable()
        let fooSymbols = SymbolTable()
        let fooType = SymbolType.structType(StructType(name: "Foo", symbols: fooSymbols))
        let fnType = FunctionType(name: "bar", mangledName: "bar", returnType: .void, arguments: [
            .constPointer(fooType)
        ])
        fooSymbols.bind(identifier: "bar", symbol: Symbol(type: .function(fnType)))
        globalSymbols.bind(identifier: "Foo", symbolType: fooType)
        globalSymbols.bind(identifier: "foo", symbol: Symbol(type: fooType, offset: 0x1000, storage: .staticStorage))

        let compiler = makeCompiler(symbols: globalSymbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Get(expr: Expression.Identifier("foo"), member: Expression.Identifier("bar")), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu16(.vr(1), 0x1000)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 272)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.alloca(.vr(4), 1)),
            TackInstructionNode(.store(.vr(3), .vr(4), 0)),
            TackInstructionNode(.call("bar")),
            TackInstructionNode(.free(1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_Call_struct_member_function_call_3() throws {
        // Define an instance `foo' of a struct `Foo' which contains a function
        // pointer member `bar(const *const Foo)'.
        // Because the first parameter of Bar is `const *const Foo', we can call
        // the function with a convenient syntax. A call of the form `foo.bar()'
        // is equivalent to a call `foo.bar(&foo)'.
        //
        // This test is for the case where the callee of the Call expression is
        // A Get expression where expr is of the type `Foo' and the function's
        // first argument is of the type `*const Foo'
        let globalSymbols = SymbolTable()
        let fooSymbols = SymbolTable()
        let fooType = SymbolType.structType(StructType(name: "Foo", symbols: fooSymbols))
        let fnType = FunctionType(name: "bar", mangledName: "bar", returnType: .void, arguments: [
            .constPointer(fooType.correspondingConstType)
        ])
        fooSymbols.bind(identifier: "bar", symbol: Symbol(type: .function(fnType)))
        globalSymbols.bind(identifier: "Foo", symbolType: fooType)
        globalSymbols.bind(identifier: "foo", symbol: Symbol(type: fooType, offset: 0x1000, storage: .staticStorage))

        let compiler = makeCompiler(symbols: globalSymbols)
        let actual = try compiler.rvalue(expr: Expression.Call(callee: Expression.Get(expr: Expression.Identifier("foo"), member: Expression.Identifier("bar")), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 272)),
            TackInstructionNode(.liu16(.vr(1), 0x1000)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 272)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.alloca(.vr(4), 1)),
            TackInstructionNode(.store(.vr(3), .vr(4), 0)),
            TackInstructionNode(.call("bar")),
            TackInstructionNode(.free(1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_Assignment_with_StructInitializer() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: kSliceType, offset: 0x1000, storage: .staticStorage))
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let lexpr = Expression.Identifier("foo")
        let rexpr = Expression.StructInitializer(identifier: Expression.Identifier(kSliceName), arguments: [
            Expression.StructInitializer.Argument(name: kSliceBase,
                                                  expr: Expression.LiteralInt(0xabcd)),
            Expression.StructInitializer.Argument(name: kSliceCount,
                                                  expr: Expression.LiteralInt(0xffff))
        ])
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: lexpr, rexpr: rexpr))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0xabcd)),
            TackInstructionNode(.store(.vr(2), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(3), 0x1000)),
            TackInstructionNode(.addi16(.vr(4), .vr(3), 1)),
            TackInstructionNode(.liu16(.vr(5), 0xffff)),
            TackInstructionNode(.store(.vr(5), .vr(4), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(5))
    }

    func testRvalue_Assignment_with_StructInitializer_NoArgs() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: kSliceType, offset: 0x1000, storage: .staticStorage))
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let lexpr = Expression.Identifier("foo")
        let rexpr = Expression.StructInitializer(identifier: Expression.Identifier(kSliceName), arguments: [
        ])
        let actual = try compiler.rvalue(expr: Expression.Assignment(lexpr: lexpr, rexpr: rexpr))
        let expected = Seq(children: [])
        XCTAssertEqual(actual, expected)
        XCTAssertTrue(compiler.registerStack.isEmpty)
    }

    func testFixBugInvolvingInitialAssignmentWithStructInitializer() throws {
        let symbols = SymbolTable()
        let kSliceType: SymbolType = .constStructType(StructType(name: kSliceName, symbols: SymbolTable(tuples: [
            (kSliceBase,  Symbol(type: kSliceBaseAddressType.correspondingConstType, offset: kSliceBaseAddressOffset)),
            (kSliceCount, Symbol(type: kSliceCountType.correspondingConstType, offset: kSliceCountOffset))
        ])))
        symbols.bind(identifier: "foo", symbol: Symbol(type: kSliceType, offset: 0x1000, storage: .staticStorage))
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let lexpr = Expression.Identifier("foo")
        let rexpr = Expression.StructInitializer(identifier: Expression.Identifier(kSliceName), arguments: [
            Expression.StructInitializer.Argument(name: kSliceBase,
                                                  expr: Expression.LiteralInt(0xabcd)),
            Expression.StructInitializer.Argument(name: kSliceCount,
                                                  expr: Expression.LiteralInt(0xffff))
        ])
        let actual = try compiler.rvalue(expr: Expression.InitialAssignment(lexpr: lexpr, rexpr: rexpr))
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x1000)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0xabcd)),
            TackInstructionNode(.store(.vr(2), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(3), 0x1000)),
            TackInstructionNode(.addi16(.vr(4), .vr(3), 1)),
            TackInstructionNode(.liu16(.vr(5), 0xffff)),
            TackInstructionNode(.store(.vr(5), .vr(4), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(5))
    }

    func testRvalue_As_LiteralArray() throws {
        let compiler = makeCompiler()
        let literalArrayType = Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let literalArray = Expression.LiteralArray(arrayType: literalArrayType, elements: [
            Expression.LiteralInt(42)
        ])
        let targetType = Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
        let asExpr = Expression.As(expr: literalArray, targetType: targetType)
        let actual = try compiler.rvalue(expr: asExpr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.liu16(.vr(1), 42)),
            TackInstructionNode(.store(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testFixBugWithCompilerTemporaryOfArrayTypeWithNoExplicitCount() throws {
        let compiler = makeCompiler()
        let symbols = SymbolTable(tuples: [
            ("a", Symbol(type: .array(count: nil, elementType: .arithmeticType(.mutableInt(.u16))), offset: 2, storage: .automaticStorage, visibility: .privateVisibility))
        ])
        symbols.highwaterMark = 2
        let literalArray = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))), elements: [
            Expression.LiteralInt(1), Expression.LiteralInt(2)
        ])
        _ = try compiler.rvalue(expr: literalArray)
        guard let type = try compiler.symbols?.resolve(identifier: "__temp0").type else {
            XCTFail("failed to resolve __temp0")
            return
        }
        let actual = compiler.globalEnvironment.memoryLayoutStrategy.sizeof(type: type)
        XCTAssertEqual(actual, 2)
    }

    func testAssignConstStructToNonConstStructElementOfUnion() throws {
        let None = SymbolType.structType(StructType(name: "None", symbols: SymbolTable()))
        let OptU8 = SymbolType.unionType(UnionType([.arithmeticType(.mutableInt(.u8)), None]))
        let symbols = SymbolTable(tuples: [
            ("none", Symbol(type: None.correspondingConstType, offset: SnapCompilerMetrics.kStaticStorageStartAddress, storage: .staticStorage)),
            ("r", Symbol(type: OptU8, offset: SnapCompilerMetrics.kStaticStorageStartAddress+1, storage: .staticStorage))
        ],
        typeDict: [
            "None" : None
        ])
        let compiler = makeCompiler(symbols: symbols)
        let expr = Expression.InitialAssignment(lexpr: Expression.Identifier("r"), rexpr: Expression.Identifier("none"))
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0111)),
            TackInstructionNode(.liu16(.vr(1), 0x0110)),
            TackInstructionNode(.liu16(.vr(2), 1)),
            TackInstructionNode(.store(.vr(2), .vr(1), 0)),
            TackInstructionNode(.addi16(.vr(3), .vr(1), 1)),
            TackInstructionNode(.liu16(.vr(4), 0x0110)),
            TackInstructionNode(.memcpy(.vr(3), .vr(4), 0)),
            TackInstructionNode(.memcpy(.vr(0), .vr(1), 2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testRvalue_ArraySlice_WithNonRangeArgument() throws {
        let symbols = SymbolTable(tuples: [ ("foo", Symbol(type: .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16))))) ],
                                  typeDict: [ kSliceName : kSliceType ])
        let compiler = makeCompiler(symbols: symbols)
        let arg = Expression.StructInitializer(identifier: Expression.Identifier(kSliceName), arguments: [
            Expression.StructInitializer.Argument(name: kSliceBase, expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: kSliceCount, expr: Expression.LiteralInt(0))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: arg)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot subscript a value of type `[2]u16' with an argument of type `Slice'")
        }
    }

    func testRvalue_ArraySlice_RangeBeginIsOutOfBoundsAtCompileTime() throws {
        let symbols = SymbolTable(tuples: [ ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))))) ],
                                  typeDict: [ kRangeName : kRangeType ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(200)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(201))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Array index is always out of bounds: `200' is not in 0..1")
        }
    }

    func testRvalue_ArraySlice_RangeLimitIsOutOfBoundsAtCompileTime() throws {
        let symbols = SymbolTable(tuples: [ ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))))) ],
                                  typeDict: [ kRangeName : kRangeType ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(201))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Array index is always out of bounds: `201' is not in 0..1")
        }
    }

    func testRvalue_ArraySlice_RangeLimitIsOutOfBoundsAtCompileTime_2() throws {
        let symbols = SymbolTable(tuples: [ ("foo", Symbol(type: .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16))))) ],
                                  typeDict: [ kRangeName : kRangeType ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(1)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(0))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Range requires begin less than or equal to limit: `1..0'")
        }
    }

    func testRvalue_ArraySlice_0() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u16))),
                           offset: 0x1000))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(1))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0x1000)),
            TackInstructionNode(.store(.vr(2), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(3), 0x0110)),
            TackInstructionNode(.addi16(.vr(4), .vr(3), 1)),
            TackInstructionNode(.liu16(.vr(5), 1)),
            TackInstructionNode(.store(.vr(5), .vr(4), 0)),
            TackInstructionNode(.liu16(.vr(6), 0x0110)),
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(6))
    }

    func testRvalue_ArraySlice_1() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .arithmeticType(.mutableInt(.u16))),
                           offset: 0x1000))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(1)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(3))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 1)),
            TackInstructionNode(.liu16(.vr(3), 0x1000)),
            TackInstructionNode(.add16(.vr(4), .vr(3), .vr(2))),
            TackInstructionNode(.store(.vr(4), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(5), 0x0110)),
            TackInstructionNode(.addi16(.vr(6), .vr(5), 1)),
            TackInstructionNode(.liu16(.vr(7), 2)),
            TackInstructionNode(.store(.vr(7), .vr(6), 0)),
            TackInstructionNode(.liu16(.vr(8), 0x0110)),
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(8))
    }

    func testRvalue_ArraySlice_2() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000)),
            ("a",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2000)),
            ("b",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2001))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let opts = SnapASTToTackASTCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.Identifier("a")),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.Identifier("b"))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0x2000)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.liu16(.vr(4), 0x1000)),
            TackInstructionNode(.add16(.vr(5), .vr(4), .vr(3))),
            TackInstructionNode(.store(.vr(5), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(6), 0x0110)),
            TackInstructionNode(.addi16(.vr(7), .vr(6), 1)),
            TackInstructionNode(.liu16(.vr(8), 0x2000)),
            TackInstructionNode(.load(.vr(9), .vr(8), 0)),
            TackInstructionNode(.liu16(.vr(10), 0x2001)),
            TackInstructionNode(.load(.vr(11), .vr(10), 0)),
            TackInstructionNode(.sub16(.vr(12), .vr(11), .vr(9))),
            TackInstructionNode(.store(.vr(12), .vr(7), 0)),
            TackInstructionNode(.liu16(.vr(13), 0x0110)),
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(13))
    }

    func testRvalue_ArraySlice_ElementSizeGreaterThanOne_1() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .array(count: 3, elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0x1000))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(1)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(3))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 3)),
            TackInstructionNode(.liu16(.vr(3), 0x1000)),
            TackInstructionNode(.add16(.vr(4), .vr(3), .vr(2))),
            TackInstructionNode(.store(.vr(4), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(5), 0x0110)),
            TackInstructionNode(.addi16(.vr(6), .vr(5), 1)),
            TackInstructionNode(.liu16(.vr(7), 2)),
            TackInstructionNode(.store(.vr(7), .vr(6), 0)),
            TackInstructionNode(.liu16(.vr(8), 0x0110)),
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(8))
    }

    func testRvalue_ArraySlice_Identifier() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 2, elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000)),
            ("range", Symbol(type: kRangeType, offset: 0x2000))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let opts = SnapASTToTackASTCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                        argument: Expression.Identifier("range"))
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0x2000)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.liu16(.vr(4), 0x1000)),
            TackInstructionNode(.add16(.vr(5), .vr(4), .vr(3))),
            TackInstructionNode(.store(.vr(5), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(6), 0x0110)),
            TackInstructionNode(.addi16(.vr(7), .vr(6), 1)),
            TackInstructionNode(.liu16(.vr(8), 0x2000)),
            TackInstructionNode(.load(.vr(9), .vr(8), 0)),
            TackInstructionNode(.liu16(.vr(10), 0x2000)),
            TackInstructionNode(.load(.vr(11), .vr(10), 1)),
            TackInstructionNode(.sub16(.vr(12), .vr(11), .vr(9))),
            TackInstructionNode(.store(.vr(12), .vr(7), 0)),
            TackInstructionNode(.liu16(.vr(13), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(13))
    }

    func testRvalue_ArraySlice_ElementSizeGreaterThanOne_2() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .array(count: 3, elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0x1000)),
            ("a",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2000)),
            ("b",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2001))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let opts = SnapASTToTackASTCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.Identifier("a")),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.Identifier("b"))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 3)),
            TackInstructionNode(.liu16(.vr(3), 0x2000)),
            TackInstructionNode(.load(.vr(4), .vr(3), 0)),
            TackInstructionNode(.mul16(.vr(5), .vr(4), .vr(2))),
            TackInstructionNode(.liu16(.vr(6), 0x1000)),
            TackInstructionNode(.add16(.vr(7), .vr(6), .vr(5))),
            TackInstructionNode(.store(.vr(7), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(8), 0x0110)),
            TackInstructionNode(.addi16(.vr(9), .vr(8), 1)),
            TackInstructionNode(.liu16(.vr(10), 0x2000)),
            TackInstructionNode(.load(.vr(11), .vr(10), 0)),
            TackInstructionNode(.liu16(.vr(12), 0x2001)),
            TackInstructionNode(.load(.vr(13), .vr(12), 0)),
            TackInstructionNode(.sub16(.vr(14), .vr(13), .vr(11))),
            TackInstructionNode(.store(.vr(14), .vr(9), 0)),
            TackInstructionNode(.liu16(.vr(15), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(15))
    }

    func testRvalue_SubscriptDynamicArray_WithNonRangeArgument() throws {
        let symbols = SymbolTable(tuples: [ ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))))) ],
                                  typeDict: [ kSliceName : kSliceType ])
        let compiler = makeCompiler(symbols: symbols)
        let arg = Expression.StructInitializer(identifier: Expression.Identifier(kSliceName), arguments: [
            Expression.StructInitializer.Argument(name: kSliceBase, expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: kSliceCount, expr: Expression.LiteralInt(0))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: arg)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot subscript a value of type `[]u16' with an argument of type `Slice'")
        }
    }

    func testRvalue_DynamicArraySlice_1() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .constDynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(1))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0x1000)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.store(.vr(3), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(4), 0x0110)),
            TackInstructionNode(.addi16(.vr(5), .vr(4), 1)),
            TackInstructionNode(.liu16(.vr(6), 1)),
            TackInstructionNode(.store(.vr(6), .vr(5), 0)),
            TackInstructionNode(.liu16(.vr(7), 0x0110)),
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(7))
    }

    func testRvalue_DynamicArraySlice_2() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .constDynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: 0x1000)),
            ("a",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2000)),
            ("b",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2001))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let opts = SnapASTToTackASTCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.Identifier("a")),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.Identifier("b"))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 0x2000)),
            TackInstructionNode(.load(.vr(3), .vr(2), 0)),
            TackInstructionNode(.liu16(.vr(4), 0x1000)),
            TackInstructionNode(.load(.vr(5), .vr(4), 0)),
            TackInstructionNode(.add16(.vr(6), .vr(5), .vr(3))),
            TackInstructionNode(.store(.vr(6), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(7), 0x0110)),
            TackInstructionNode(.addi16(.vr(8), .vr(7), 1)),
            TackInstructionNode(.liu16(.vr(9), 0x2000)),
            TackInstructionNode(.load(.vr(10), .vr(9), 0)),
            TackInstructionNode(.liu16(.vr(11), 0x2001)),
            TackInstructionNode(.load(.vr(12), .vr(11), 0)),
            TackInstructionNode(.sub16(.vr(13), .vr(12), .vr(10))),
            TackInstructionNode(.store(.vr(13), .vr(8), 0)),
            TackInstructionNode(.liu16(.vr(14), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(14))
    }

    func testRvalue_DynamicArraySlice_ElementSizeGreaterThanOne_1() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .constDynamicArray(elementType: .array(count: 3, elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0x1000))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let compiler = makeCompiler(symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.LiteralInt(1)),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.LiteralInt(3))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 3)),
            TackInstructionNode(.liu16(.vr(3), 0x1000)),
            TackInstructionNode(.load(.vr(4), .vr(3), 0)),
            TackInstructionNode(.add16(.vr(5), .vr(4), .vr(2))),
            TackInstructionNode(.store(.vr(5), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(6), 0x0110)),
            TackInstructionNode(.addi16(.vr(7), .vr(6), 1)),
            TackInstructionNode(.liu16(.vr(8), 2)),
            TackInstructionNode(.store(.vr(8), .vr(7), 0)),
            TackInstructionNode(.liu16(.vr(9), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(9))
    }

    func testRvalue_DynamicArraySlice_ElementSizeGreaterThanOne_2() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .constDynamicArray(elementType: .array(count: 3, elementType: .arithmeticType(.mutableInt(.u16)))), offset: 0x1000)),
            ("a",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2000)),
            ("b",   Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0x2001))
        ], typeDict: [
            kRangeName : kRangeType,
            kSliceName : kSliceType
        ])
        let opts = SnapASTToTackASTCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = Expression.StructInitializer(identifier: Expression.Identifier(kRangeName), arguments: [
            Expression.StructInitializer.Argument(name: kRangeBegin, expr: Expression.Identifier("a")),
            Expression.StructInitializer.Argument(name: kRangeLimit, expr: Expression.Identifier("b"))
        ])
        let expr = Expression.Subscript(subscriptable: Expression.Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.addi16(.vr(1), .vr(0), 0)),
            TackInstructionNode(.liu16(.vr(2), 3)),
            TackInstructionNode(.liu16(.vr(3), 0x2000)),
            TackInstructionNode(.load(.vr(4), .vr(3), 0)),
            TackInstructionNode(.mul16(.vr(5), .vr(4), .vr(2))),
            TackInstructionNode(.liu16(.vr(6), 0x1000)),
            TackInstructionNode(.load(.vr(7), .vr(6), 0)),
            TackInstructionNode(.add16(.vr(8), .vr(7), .vr(5))),
            TackInstructionNode(.store(.vr(8), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(9), 0x0110)),
            TackInstructionNode(.addi16(.vr(10), .vr(9), 1)),
            TackInstructionNode(.liu16(.vr(11), 0x2000)),
            TackInstructionNode(.load(.vr(12), .vr(11), 0)),
            TackInstructionNode(.liu16(.vr(13), 0x2001)),
            TackInstructionNode(.load(.vr(14), .vr(13), 0)),
            TackInstructionNode(.sub16(.vr(15), .vr(14), .vr(12))),
            TackInstructionNode(.store(.vr(15), .vr(10), 0)),
            TackInstructionNode(.liu16(.vr(16), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(16))
    }

    func testRvalue_convert_pointer_to_trait() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let symbols = globalEnvironment.globalSymbols

        let ast0 = Block(symbols: symbols, children: [
            TraitDeclaration(identifier: Expression.Identifier("Serial"),
                             members: [],
                             visibility: .privateVisibility),
            StructDeclaration(identifier: Expression.Identifier("SerialFake"),
                              members: []),
            ImplFor(typeArguments: [],
                    traitTypeExpr: Expression.Identifier("Serial"),
                    structTypeExpr: Expression.Identifier("SerialFake"),
                    children: []),
            VarDeclaration(identifier: Expression.Identifier("serialFake"),
                           explicitType: Expression.Identifier("SerialFake"),
                           expression: nil,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("serial"),
                           explicitType: Expression.Identifier("Serial"),
                           expression: Expression.Unary(op: .ampersand, expression: Expression.Identifier("serialFake")),
                           storage: .staticStorage,
                           isMutable: false)
        ])

        let opts = SnapASTToTackASTCompiler.Options.defaultOptions
        let contractStep = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        contractStep.compile(ast0)
        let ast1 = contractStep.ast
        let compiler = SnapASTToTackASTCompiler(symbols: symbols, globalEnvironment: globalEnvironment, options: opts)
        let actual = try compiler.compile(ast1)

        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(8), 0x0110)), // TODO: make sure the optimizer can remove dead stores like this one
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.liu16(.vr(1), 0x0112)),
            TackInstructionNode(.addi16(.vr(2), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(3), 0x0110)),
            TackInstructionNode(.store(.vr(3), .vr(2), 0)),
            TackInstructionNode(.liu16(.vr(4), 0x0112)),
            TackInstructionNode(.addi16(.vr(5), .vr(4), 1)),
            TackInstructionNode(.liu16(.vr(6), 0x0110)),
            TackInstructionNode(.store(.vr(6), .vr(5), 0)),
            TackInstructionNode(.liu16(.vr(7), 0x0112)),
            TackInstructionNode(.memcpy(.vr(0), .vr(7), 2))
        ])
        XCTAssertEqual(actual, expected)
    }

    func testRvalue_convert_struct_to_trait() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let symbols = globalEnvironment.globalSymbols

        let ast0 = Block(symbols: symbols, children: [
            TraitDeclaration(identifier: Expression.Identifier("Serial"),
                             members: [],
                             visibility: .privateVisibility),
            StructDeclaration(identifier: Expression.Identifier("SerialFake"),
                              members: []),
            ImplFor(typeArguments: [],
                    traitTypeExpr: Expression.Identifier("Serial"),
                    structTypeExpr: Expression.Identifier("SerialFake"),
                    children: []),
            VarDeclaration(identifier: Expression.Identifier("serialFake"),
                           explicitType: Expression.Identifier("SerialFake"),
                           expression: nil,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("serial"),
                           explicitType: Expression.Identifier("Serial"),
                           expression: Expression.Identifier("serialFake"),
                           storage: .staticStorage,
                           isMutable: false)
        ])

        let opts = SnapASTToTackASTCompiler.Options.defaultOptions
        let contractStep = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        contractStep.compile(ast0)
        let ast1 = contractStep.ast
        let actual = try SnapASTToTackASTCompiler(symbols: symbols, globalEnvironment: globalEnvironment, options: opts).compile(ast1)

        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(8), 0x0110)), // TODO: make sure the optimizer can remove dead stores like this one
            TackInstructionNode(.liu16(.vr(0), 0x0110)),
            TackInstructionNode(.liu16(.vr(1), 0x0112)),
            TackInstructionNode(.addi16(.vr(2), .vr(1), 0)),
            TackInstructionNode(.liu16(.vr(3), 0x0110)),
            TackInstructionNode(.store(.vr(3), .vr(2), 0)),
            TackInstructionNode(.liu16(.vr(4), 0x0112)),
            TackInstructionNode(.addi16(.vr(5), .vr(4), 1)),
            TackInstructionNode(.liu16(.vr(6), 0x0110)),
            TackInstructionNode(.store(.vr(6), .vr(5), 0)),
            TackInstructionNode(.liu16(.vr(7), 0x0112)),
            TackInstructionNode(.memcpy(.vr(0), .vr(7), 2))
        ])
        XCTAssertEqual(actual, expected)
    }

    func testLvalue_LvalueOfMemberOfStructInitializer() throws {
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0xabcd))
        ], typeDict: [
            "Foo" : .structType(typ)
        ])
        let si = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Expression.StructInitializer.Argument(name: "bar", expr: Expression.Identifier("foo"))
        ])
        let expr = Expression.Get(expr: si, member: Expression.Identifier("bar"))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.lvalue(expr: expr)
        let expected = TackInstructionNode(.liu16(.vr(0), 0xabcd))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testLvalue_CannotInstantiateGenericFunctionTypeWithoutApplication() {
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let expr = Expression.Identifier("foo")
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.lvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic function `func foo[T](a: T) -> T'")
        }
    }

    func testLvalue_GenericFunctionApplication() throws {
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
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.lvalue(expr: expr)
        let expected = TackInstructionNode(.la(.vr(0), "__foo_const_u16"))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_RvalueOfMemberOfStructInitializer() throws {
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0xabcd))
        ], typeDict: [
            "Foo" : .structType(typ)
        ])
        let si = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Expression.StructInitializer.Argument(name: "bar", expr: Expression.Identifier("foo"))
        ])
        let expr = Expression.Get(expr: si, member: Expression.Identifier("bar"))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xabcd)),
            TackInstructionNode(.load(.vr(1), .vr(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(1))
    }

    func testAsm_Empty() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(asm: Asm(assemblyCode: ""))
        let expected = TackInstructionNode(.inlineAssembly(""))
        XCTAssertEqual(actual, expected)
    }

    func testAsm_HLT() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(asm: Asm(assemblyCode: "HLT"))
        let expected = TackInstructionNode(.inlineAssembly("HLT"))
        XCTAssertEqual(actual, expected)
    }

    func testRvalue_SizeOf() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Expression.SizeOf(ExprUtils.makeU8(value: 1)))
        let expected = TackInstructionNode(.liu16(.vr(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_FunctionByIdentifier() throws {
        let symbols = SymbolTable(tuples: [
            ("panic", Symbol(type: .function(FunctionType(name: "panic", mangledName: "panic", returnType: .void, arguments: [.dynamicArray(elementType: .arithmeticType(.immutableInt(.u8)))]))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let expr = Expression.Identifier("panic")
        let actual = try compiler.rvalue(expr: expr)
        let expected = TackInstructionNode(.la(.vr(0), "panic"))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_CannotInstantiateGenericFunctionTypeWithoutApplication() throws {
        let compiler = makeCompiler()
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let expr = Expression.GenericFunctionType(template: template)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic function `func foo[T](a: T) -> T'")
        }
    }

    func testRvalue_GenericFunctionApplication_FailsWithIncorrectNumberOfArguments() throws {
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16),
                                                                 Expression.PrimitiveType(constU16)])
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic function type `foo@[u16, u16]'")
        }
    }

    func testRvalue_GenericFunctionApplication() throws {
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
        let compiler = makeCompiler(symbols: symbols)
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        let actual = try compiler.rvalue(expr: expr)
        let expected = TackInstructionNode(.la(.vr(0), "__foo_const_u16"))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testRvalue_CannotTakeTheAddressOfGenericFunctionWithoutTypeArguments() {
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])

        let expr = Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo"))
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic function `func foo[T](a: T) -> T'")
        }
    }

    func testRvalue_CannotTakeTheAddressOfGenericFunctionWithInappropriateTypeArguments() {
        let constU16 = SymbolType.arithmeticType(.immutableInt(.u16))
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])

        let expr = Expression.Unary(op: .ampersand, expression: Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"), arguments: [Expression.PrimitiveType(constU16), Expression.PrimitiveType(constU16)]))
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic function type `foo@[const u16, const u16]'")
        }
    }

    func testRvalue_TakeTheAddressOfGenericFunctionWithGoodTypeArguments() throws {
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

        let expr = Expression.Unary(op: .ampersand, expression: Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"), arguments: [Expression.PrimitiveType(constU16)]))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: expr)
        let expected = TackInstructionNode(.la(.vr(0), "__foo_const_u16"))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .vr(0))
    }

    func testCompilationFailsOnConcreteInstantiationOfGenericFunction() throws {
        let ast0 = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo",
                                                                      returnType: Expression.Identifier("T"),
                                                                      arguments: [Expression.Identifier("T")]),
                                argumentNames: ["a"],
                                typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                body: Block(children: [
                                    Return(Expression.Get(expr: Expression.Identifier("a"), member: Expression.Identifier("count")))
                                ]),
                                visibility: .privateVisibility,
                                symbols: SymbolTable()),
            Expression.Unary(op: .ampersand, expression: Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"), arguments: [
                Expression.PrimitiveType(SymbolType.arithmeticType(.immutableInt(.u16)))
            ]))
        ])

        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let contractStep = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        contractStep.compile(ast0)
        let ast1 = contractStep.ast
        let compiler = SnapASTToTackASTCompiler(symbols: symbols, globalEnvironment: globalEnvironment)

        XCTAssertThrowsError(try compiler.compileWithEpilog(ast1)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `const u16' has no member `count'")
        }
    }

    func testSuccessfulInstantiationOfGenericFunction() throws {
        let ast0 = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo",
                                                                      returnType: Expression.Identifier("T"),
                                                                      arguments: [Expression.Identifier("T")]),
                                argumentNames: ["a"],
                                typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                body: Block(children: [
                                    Return(Expression.Identifier("a"))
                                ]),
                                visibility: .privateVisibility,
                                symbols: SymbolTable()),
            Expression.Unary(op: .ampersand, expression: Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"), arguments: [
                Expression.PrimitiveType(SymbolType.arithmeticType(.immutableInt(.u16)))
            ]))
        ])

        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let contractStep = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        contractStep.compile(ast0)
        let ast1 = contractStep.ast
        let compiler = SnapASTToTackASTCompiler(symbols: symbols, globalEnvironment: globalEnvironment)
        let actual = try compiler.compileWithEpilog(ast1)
        let expected = Seq(children: [
            TackInstructionNode(.la(.vr(0), "__foo_const_u16")),
            Subroutine(identifier: "__foo_const_u16", children: [
                TackInstructionNode(.enter(0)),
                TackInstructionNode(.addi16(.vr(1), .fp, 8)),
                TackInstructionNode(.addi16(.vr(2), .fp, 7)),
                TackInstructionNode(.load(.vr(3), .vr(2), 0)),
                TackInstructionNode(.store(.vr(3), .vr(1), 0)),
                TackInstructionNode(.leave),
                TackInstructionNode(.ret)
            ])
        ])
        XCTAssertEqual(actual, expected)
    }

    func testCalleeOfCallCanBeGenericFunctionApplicationWithExplicitTypes() throws {
        let ast0 = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo",
                                                                      returnType: Expression.Identifier("T"),
                                                                      arguments: [Expression.Identifier("T")]),
                                argumentNames: ["a"],
                                typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                body: Block(children: [
                                    Return(Expression.Identifier("a"))
                                ]),
                                visibility: .privateVisibility,
                                symbols: SymbolTable()),
            Expression.Call(callee: Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"), arguments: [ Expression.PrimitiveType(SymbolType.arithmeticType(.immutableInt(.u16))) ]),
                            arguments: [ Expression.LiteralInt(65535) ])
        ])

        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let contractStep = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        contractStep.compile(ast0)
        if contractStep.hasError {
            XCTFail("contract step failed before the test")
            return
        }
        let ast1 = contractStep.ast
        let compiler = SnapASTToTackASTCompiler(symbols: symbols, globalEnvironment: globalEnvironment)
        let actual = try compiler.compileWithEpilog(ast1)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xffff)),
            TackInstructionNode(.alloca(.vr(1), 1)),
            TackInstructionNode(.alloca(.vr(2), 1)),
            TackInstructionNode(.store(.vr(0), .vr(2), 0)),
            TackInstructionNode(.call("__foo_const_u16")),
            TackInstructionNode(.liu16(.vr(3), 272)),
            TackInstructionNode(.memcpy(.vr(3), .vr(1), 1)),
            TackInstructionNode(.free(2)),
            TackInstructionNode(.liu16(.vr(4), 272)),
            TackInstructionNode(.load(.vr(5), .vr(4), 0)),
            Subroutine(identifier: "__foo_const_u16", children: [
                TackInstructionNode(.enter(0)),
                TackInstructionNode(.addi16(.vr(6), .fp, 8)),
                TackInstructionNode(.addi16(.vr(7), .fp, 7)),
                TackInstructionNode(.load(.vr(8), .vr(7), 0)),
                TackInstructionNode(.store(.vr(8), .vr(6), 0)),
                TackInstructionNode(.leave),
                TackInstructionNode(.ret)
            ])
        ])
        XCTAssertEqual(actual, expected)
    }

    func testCallCanTriggerConcreteInstantiationWithTypesInferredFromContext() throws {
        let ast0 = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo",
                                                                      returnType: Expression.Identifier("T"),
                                                                      arguments: [Expression.Identifier("T")]),
                                argumentNames: ["a"],
                                typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                body: Block(children: [
                                    Return(Expression.Identifier("a"))
                                ]),
                                visibility: .privateVisibility,
                                symbols: SymbolTable()),
            Expression.Call(callee: Expression.Identifier("foo"),
                            arguments: [ Expression.LiteralInt(65535) ])
        ])

        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let contractStep = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        contractStep.compile(ast0)
        if contractStep.hasError {
            let error = CompilerError.makeOmnibusError(fileName: nil, errors: contractStep.errors)
            XCTFail("contract step failed before the test: \(error.description)")
            return
        }
        let ast1 = contractStep.ast
        let compiler = SnapASTToTackASTCompiler(symbols: symbols, globalEnvironment: globalEnvironment)
        let actual = try compiler.compileWithEpilog(ast1)
        let expected = Seq(children: [
            TackInstructionNode(.liu16(.vr(0), 0xffff)),
            TackInstructionNode(.alloca(.vr(1), 1)),
            TackInstructionNode(.alloca(.vr(2), 1)),
            TackInstructionNode(.store(.vr(0), .vr(2), 0)),
            TackInstructionNode(.call("__foo_u16")),
            TackInstructionNode(.liu16(.vr(3), 272)),
            TackInstructionNode(.memcpy(.vr(3), .vr(1), 1)),
            TackInstructionNode(.free(2)),
            TackInstructionNode(.liu16(.vr(4), 272)),
            TackInstructionNode(.load(.vr(5), .vr(4), 0)),
            Subroutine(identifier: "__foo_u16", children: [
                TackInstructionNode(.enter(0)),
                TackInstructionNode(.addi16(.vr(6), .fp, 8)),
                TackInstructionNode(.addi16(.vr(7), .fp, 7)),
                TackInstructionNode(.load(.vr(8), .vr(7), 0)),
                TackInstructionNode(.store(.vr(8), .vr(6), 0)),
                TackInstructionNode(.leave),
                TackInstructionNode(.ret)
            ])
        ])
        XCTAssertEqual(actual, expected)
    }
}
