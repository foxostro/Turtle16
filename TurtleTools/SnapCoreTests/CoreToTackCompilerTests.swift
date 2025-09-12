//
//  CoreToTackCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleSimulatorCore
import XCTest

let kSliceName = "Slice"
let kSliceBase = "base"
let kSliceBaseAddressOffset = 0
let kSliceBaseAddressType = SymbolType.u16
let kSliceCount = "count"
let kSliceCountOffset = 1
let kSliceCountType = SymbolType.u16
let kSliceType: SymbolType = .structType(
    StructTypeInfo(
        name: kSliceName,
        fields: Env(tuples: [
            (kSliceBase, Symbol(type: kSliceBaseAddressType, offset: kSliceBaseAddressOffset)),
            (kSliceCount, Symbol(type: kSliceCountType, offset: kSliceCountOffset))
        ])
    )
)
let kRangeName = "Range"
let kRangeBegin = "begin"
let kRangeLimit = "limit"
let kRangeType: SymbolType = .structType(
    StructTypeInfo(
        name: kRangeName,
        fields: Env(tuples: [
            (kRangeBegin, Symbol(type: .u16, storage: .automaticStorage(offset: 0))),
            (kRangeLimit, Symbol(type: .u16, storage: .automaticStorage(offset: 1)))
        ])
    )
)

final class CoreToTackCompilerTests: XCTestCase {
    fileprivate let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()

    fileprivate func makeCompiler(
        options opts: CoreToTackCompiler.Options = CoreToTackCompiler.Options(
            isBoundsCheckEnabled: true
        ),
        symbols: Env = Env()
    ) -> CoreToTackCompiler {
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = CoreToTackCompiler(
            symbols: symbols,
            staticStorageFrame: frame,
            memoryLayoutStrategy: memoryLayoutStrategy,
            options: opts
        )
        return compiler
    }

    func testLabelDeclaration() throws {
        let compiler = makeCompiler()
        let result = try compiler.run(LabelDeclaration(identifier: "foo"))
        XCTAssertEqual(result, LabelDeclaration(identifier: "foo"))
    }

    func testBlockWithOneInstruction() throws {
        let compiler = makeCompiler()
        let result = try compiler.run(
            Block(children: [
                LabelDeclaration(identifier: "foo")
            ])
        )
        XCTAssertEqual(result, LabelDeclaration(identifier: "foo"))
    }

    func testBlockWithTwoInstructions() throws {
        let compiler = makeCompiler()
        let result = try compiler.run(
            Block(children: [
                LabelDeclaration(identifier: "foo"),
                LabelDeclaration(identifier: "bar")
            ])
        )
        XCTAssertEqual(
            result,
            Seq(children: [
                LabelDeclaration(identifier: "foo"),
                LabelDeclaration(identifier: "bar")
            ])
        )
    }

    func testBlockWithNestedSeq() throws {
        let compiler = makeCompiler()
        let result = try compiler.run(
            Block(children: [
                LabelDeclaration(identifier: "foo"),
                Seq(children: [
                    LabelDeclaration(identifier: "bar"),
                    LabelDeclaration(identifier: "baz")
                ])
            ])
        )
        XCTAssertEqual(
            result,
            Seq(children: [
                LabelDeclaration(identifier: "foo"),
                LabelDeclaration(identifier: "bar"),
                LabelDeclaration(identifier: "baz")
            ])
        )
    }

    func testGoto() throws {
        let compiler = makeCompiler()
        let result = try compiler.run(Goto(target: "foo"))
        XCTAssertEqual(result, TackInstructionNode(.jmp("foo")))
    }

    func testGotoIfFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.run(GotoIfFalse(condition: LiteralBool(false), target: "bar"))
        let expected = Seq(children: [
            TackInstructionNode(.lio(.o(0), false)),
            TackInstructionNode(.bz(.o(0), "bar"))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertTrue(compiler.registerStack.isEmpty)
    }

    func testRet() throws {
        let compiler = makeCompiler()
        let actual = try compiler.run(Return())
        let expected = Seq(children: [
            TackInstructionNode(.leave),
            TackInstructionNode(.ret)
        ])
        XCTAssertEqual(actual, expected)
    }

    func testCompileFunctionDeclaration_Simplest() throws {
        let expected = Subroutine(
            identifier: "foo",
            children: [
                TackInstructionNode(.enter(0)),
                TackInstructionNode(.leave),
                TackInstructionNode(.ret)
            ]
        )
        let ast0 = Block(children: [
            FunctionDeclaration(
                identifier: Identifier("foo"),
                functionType: FunctionType(
                    name: "foo",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [
                    Return()
                ])
            )
        ])
        .reconnect(parent: nil)
        let ast1 = try CompilerPassWithDeclScan().run(ast0)
        let actual = try CoreToTackCompiler().run(ast1)
        XCTAssertEqual(actual, expected)
    }

    func testExpr_LiteralBoolFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.run(LiteralBool(false))
        let expected = TackInstructionNode(.lio(.o(0), false))
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_LiteralBoolFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: LiteralBool(false))
        let expected = TackInstructionNode(.lio(.o(0), false))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_LiteralBoolTrue() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: LiteralBool(true))
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_LiteralInt_Small_Positive() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: LiteralInt(1))
        let expected = TackInstructionNode(.liub(.b(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_LiteralInt_Small_Negative() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: LiteralInt(-1))
        let expected = TackInstructionNode(.lib(.b(0), -1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_LiteralInt_Big() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: LiteralInt(0x1000))
        let expected = TackInstructionNode(.liuw(.w(0), 0x1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
    }

    func testRvalue_LiteralInt_Big_Negative() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: LiteralInt(-1000))
        let expected = TackInstructionNode(.liw(.w(0), -1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
    }

    func testRvalue_LiteralArray_primitive_type() throws {
        let compiler = makeCompiler()
        let arrType = ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u16))
        let actual = try compiler.rvalue(
            expr: LiteralArray(arrayType: arrType, elements: [LiteralInt(42)])
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 272)),
            TackInstructionNode(.liuw(.w(1), 42)),
            TackInstructionNode(.sw(.w(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_LiteralArray_non_primitive_type() throws {
        let compiler = makeCompiler()
        let inner = ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u16))
        let outer = ArrayType(count: LiteralInt(1), elementType: inner)
        let actual = try compiler.rvalue(
            expr: LiteralArray(
                arrayType: outer,
                elements: [
                    LiteralArray(arrayType: inner, elements: [LiteralInt(42)])
                ]
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 272)),
            TackInstructionNode(.liuw(.w(1), 0)),
            TackInstructionNode(.addpw(.p(2), .p(0), .w(1))),
            TackInstructionNode(.lip(.p(3), 273)),
            TackInstructionNode(.liuw(.w(4), 42)),
            TackInstructionNode(.sw(.w(4), .p(3), 0)),
            TackInstructionNode(.memcpy(.p(2), .p(3), 1)),
            TackInstructionNode(.lip(.p(5), 272))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(5)))
    }

    func testRvalue_LiteralString() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: LiteralString("a"))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 272)),
            TackInstructionNode(.ststr(.p(0), "a"))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_StructInitializer() throws {
        let symbols = Env()
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: StructInitializer(
                identifier: Identifier(kSliceName),
                arguments: [
                    StructInitializer.Argument(
                        name: kSliceBase,
                        expr: LiteralInt(0xabcd)
                    ),
                    StructInitializer.Argument(
                        name: kSliceCount,
                        expr: LiteralInt(0xffff)
                    )
                ]
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 272)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 0xabcd)),
            TackInstructionNode(.sw(.w(2), .p(1), 0)),
            TackInstructionNode(.lip(.p(3), 272)),
            TackInstructionNode(.addip(.p(4), .p(3), 1)),
            TackInstructionNode(.liuw(.w(5), 0xffff)),
            TackInstructionNode(.sw(.w(5), .p(4), 0)),
            TackInstructionNode(.lip(.p(6), 272))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(6)))
    }

    func testRvalue_Identifier_Static_u16() throws {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = makeCompiler(
            symbols: Env(tuples: [
                ("foo", Symbol(type: .u16, storage: .staticStorage(offset: offset)))
            ])
        )
        let actual = try compiler.rvalue(expr: Identifier("foo"))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), offset)),
            TackInstructionNode(.lw(.w(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1)))
    }

    func testRvalue_Identifier_Stack_u16() throws {
        let offset = 4
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .automaticStorage(offset: offset)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Identifier("foo"))
        let expected = Seq(children: [
            TackInstructionNode(.subip(.p(0), .fp, offset)),
            TackInstructionNode(.lw(.w(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1)))
    }

    func testRvalue_Identifier_struct() throws {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = makeCompiler(
            symbols: Env(tuples: [
                ("foo", Symbol(type: kSliceType, storage: .staticStorage(offset: offset)))
            ])
        )
        let actual = try compiler.rvalue(expr: Identifier("foo"))
        let expected = TackInstructionNode(.lip(.p(0), offset))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_As_u8_to_u8() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lb(.b(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(1)))
    }

    func testRvalue_As_u8_to_u16() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u16)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.movzwb(.w(2), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testRvalue_As_u16_to_u8() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.movzbw(.b(2), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(2)))
    }

    func testRvalue_As_u8_to_i16() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.i16)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.movzwb(.w(2), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testRvalue_As_i16_to_i8() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.i8)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.movsbw(.b(2), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(2)))
    }

    func testRvalue_As_i8_to_i16() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i8, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.i16)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.movswb(.w(2), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testRvalue_As_array_to_array_of_same_type() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 1, elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: ArrayType(count: nil, elementType: PrimitiveType(.u16))
            )
        )
        let expected = TackInstructionNode(.lip(.p(0), 0xabcd))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_As_array_to_array_with_different_type_that_can_be_trivially_reinterpreted()
        throws
    {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 0, elementType: .u8),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: ArrayType(count: LiteralInt(0), elementType: PrimitiveType(.u8))
            )
        )
        let expected = TackInstructionNode(.lip(.p(0), 0xabcd))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_As_array_to_array_where_each_element_must_be_converted() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 1, elementType: .u16),
                    storage: .staticStorage(offset: 0x1000)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: ArrayType(count: nil, elementType: PrimitiveType(.u8))
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 272)),
            TackInstructionNode(.liuw(.w(1), 0)),
            TackInstructionNode(.addpw(.p(2), .p(0), .w(1))),
            TackInstructionNode(.lip(.p(3), 0x1000)),
            TackInstructionNode(.liuw(.w(4), 0)),
            TackInstructionNode(.addpw(.p(5), .p(3), .w(4))),
            TackInstructionNode(.lw(.w(6), .p(5), 0)),
            TackInstructionNode(.movzbw(.b(7), .w(6))),
            TackInstructionNode(.sb(.b(7), .p(2), 0)),
            TackInstructionNode(.lip(.p(8), 272))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(8)))
    }

    func testRvalue_As_array_to_dynamic_array() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 1, elementType: .u16),
                    storage: .staticStorage(offset: 0x1000)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(expr: Identifier("foo"), targetType: DynamicArrayType(PrimitiveType(.u16)))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 272)),
            TackInstructionNode(.lip(.p(1), 0x1000)),
            TackInstructionNode(.sp(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 1)),
            TackInstructionNode(.sw(.w(2), .p(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_As_literal_array_to_dynamic_array() throws {
        let compiler = makeCompiler()
        let arr = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u16)),
            elements: [LiteralInt(1)]
        )
        let actual = try compiler.rvalue(
            expr: As(expr: arr, targetType: DynamicArrayType(PrimitiveType(.u16)))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 272)),
            TackInstructionNode(.lip(.p(1), 274)),
            TackInstructionNode(.liuw(.w(2), 1)),
            TackInstructionNode(.sw(.w(2), .p(1), 0)),
            TackInstructionNode(.sp(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(3), 1)),
            TackInstructionNode(.sw(.w(3), .p(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_As_compTimeInt_small() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .arithmeticType(.compTimeInt(42)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            )
        )
        let expected = TackInstructionNode(.liub(.b(0), 42))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_As_compTimeInt_big() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .arithmeticType(.compTimeInt(1000)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u16)
            )
        )
        let expected = TackInstructionNode(.liuw(.w(0), 1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
    }

    func testRvalue_As_compTimeBool_true() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .booleanType(.compTimeBool(true)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.bool)
            )
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_As_compTimeBool_false() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .booleanType(.compTimeBool(false)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.bool)
            )
        )
        let expected = TackInstructionNode(.lio(.o(0), false))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_As_pointer_to_pointer() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u16), storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: As(
                expr: Identifier("foo"),
                targetType: PointerType(PrimitiveType(.arithmeticType(.immutableInt(.u16))))
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testRvalue_Bitcast_u16_to_pointer() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Bitcast(
                expr: Identifier("foo"),
                targetType: PointerType(PrimitiveType(.arithmeticType(.immutableInt(.u16))))
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.bitcast(.p(.p(2)), .w(.w(1))))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(2)))
    }

    func testRvalue_Group() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(expr: Group(LiteralBool(false)))
        let expected = TackInstructionNode(.lio(.o(0), false))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Unary_minus_u8() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .minus, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.liub(.b(2), 0)),
            TackInstructionNode(.subb(.b(3), .b(2), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(3)))
    }

    func testRvalue_Unary_minus_u16() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .minus, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 0)),
            TackInstructionNode(.subw(.w(3), .w(2), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(3)))
    }

    func testRvalue_Unary_minus_i8() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i8, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .minus, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.liub(.b(2), 0)),
            TackInstructionNode(.subb(.b(3), .b(2), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(3)))
    }

    func testRvalue_Unary_minus_i16() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .minus, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 0)),
            TackInstructionNode(.subw(.w(3), .w(2), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(3)))
    }

    func testRvalue_Unary_bang_bool() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .bool, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .bang, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lo(.o(1), .p(0), 0)),
            TackInstructionNode(.not(.o(2), .o(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(2)))
    }

    func testRvalue_Unary_tilde_u8() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .tilde, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.negb(.b(2), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(2)))
    }

    func testRvalue_Unary_tilde_u16() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .tilde, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.negw(.w(2), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testRvalue_Unary_tilde_i8() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i8, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .tilde, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.negb(.b(2), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(2)))
    }

    func testRvalue_Unary_tilde_i16() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .i16, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .tilde, expression: Identifier("foo")))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.negw(.w(2), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testRvalue_Unary_addressOf_Function() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "foo",
                            mangledName: "foo",
                            returnType: .void,
                            arguments: []
                        )
                    )
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .ampersand, expression: Identifier("foo")))
        let expected = TackInstructionNode(.la(.p(0), "foo"))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_Unary_addressOf_Identifier() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .staticStorage(offset: 100)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Unary(op: .ampersand, expression: Identifier("foo")))
        let expected = TackInstructionNode(.lip(.p(0), 100))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_Binary_addw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .plus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.addw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_subw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .minus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.subw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_mulw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .star, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.mulw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_divw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .i16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .i16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .divide, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.divw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_divuw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .divide, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.divuw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_mod16() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .modulus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.modw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_lslw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .leftDoubleAngle, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.lslw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_lsrw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(
                op: .rightDoubleAngle,
                left: Identifier("left"),
                right: Identifier("right")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.lsrw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_andw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ampersand, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.andw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_orw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .pipe, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.orw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_xorw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .caret, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.xorw(.w(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }

    func testRvalue_Binary_eqw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .eq, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.eqw(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_new() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ne, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.new(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_ltw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .i16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .i16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .lt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.ltw(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_gew() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .i16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .i16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ge, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.gew(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_lew() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .i16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .i16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .le, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.lew(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_gtw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .i16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .i16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .gt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.gtw(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_ltuw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .lt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.ltuw(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_geuw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ge, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.geuw(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_leuw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .le, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.leuw(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_gtuw() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u16, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .gt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lw(.w(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.gtuw(.o(4), .w(3), .w(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_add8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .plus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.addb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_sub8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .minus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.subb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_mul8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .star, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.mulb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_divb() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .i8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .i8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .divide, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.divb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_divub() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .divide, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.divub(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_mod8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .modulus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.modb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_lsl8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .leftDoubleAngle, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.lslb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_lsr8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(
                op: .rightDoubleAngle,
                left: Identifier("left"),
                right: Identifier("right")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.lsrb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_and8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ampersand, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.andb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_or8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .pipe, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.orb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_xor8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .caret, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.xorb(.b(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(4)))
    }

    func testRvalue_Binary_eq8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .eq, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.eqb(.o(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_ne8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ne, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.neb(.o(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_ltu8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .lt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.ltub(.o(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_geu8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ge, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.geub(.o(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_leu8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .le, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.leub(.o(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_gtu8() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u8, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .u8, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .gt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lb(.b(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lb(.b(3), .p(2), 0)),
            TackInstructionNode(.gtub(.o(4), .b(3), .b(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_comptime_eq() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .eq, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_ne() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ne, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), false))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_lt() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .lt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_gt() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(2)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .gt, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_le() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .le, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_ge() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ge, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_add() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(-1000)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(-1000))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .plus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liw(.w(0), -2000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
    }

    func testRvalue_Binary_comptime_sub() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .minus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_mul() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .star, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_div() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(1)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(1))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .divide, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_mod() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(3)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .modulus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 1))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_and() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(0xab)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(0x0f))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ampersand, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 0xb))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_or() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(0xab)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(0x0f))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .pipe, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 0xaf))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_xor() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(0xab)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(0xab))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .caret, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 0))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_lsl() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(2)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .leftDoubleAngle, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.liub(.b(0), 8))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_comptime_lsr() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .arithmeticType(.compTimeInt(8)))),
            ("right", Symbol(type: .arithmeticType(.compTimeInt(2))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(
                op: .rightDoubleAngle,
                left: Identifier("left"),
                right: Identifier("right")
            )
        )
        let expected = TackInstructionNode(.liub(.b(0), 2))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(0)))
    }

    func testRvalue_Binary_eq_bool() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .bool, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .bool, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .eq, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lo(.o(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lo(.o(3), .p(2), 0)),
            TackInstructionNode(.eqo(.o(4), .o(3), .o(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_ne_bool() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .bool, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .bool, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ne, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 200)),
            TackInstructionNode(.lo(.o(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 100)),
            TackInstructionNode(.lo(.o(3), .p(2), 0)),
            TackInstructionNode(.neo(.o(4), .o(3), .o(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_logical_and() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .bool, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .bool, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .doubleAmpersand, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lo(.o(1), .p(0), 0)),
            TackInstructionNode(.bz(.o(1), ".L0")),
            TackInstructionNode(.lip(.p(2), 200)),
            TackInstructionNode(.lo(.o(3), .p(2), 0)),
            TackInstructionNode(.bz(.o(3), ".L0")),
            TackInstructionNode(.lio(.o(4), true)),
            TackInstructionNode(.jmp(".L1")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.lio(.o(4), false)),
            LabelDeclaration(identifier: ".L1")
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_logical_or() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .bool, storage: .staticStorage(offset: 100))),
            ("right", Symbol(type: .bool, storage: .staticStorage(offset: 200)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .doublePipe, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 100)),
            TackInstructionNode(.lo(.o(1), .p(0), 0)),
            TackInstructionNode(.bnz(.o(1), ".L0")),
            TackInstructionNode(.lip(.p(2), 200)),
            TackInstructionNode(.lo(.o(3), .p(2), 0)),
            TackInstructionNode(.bnz(.o(3), ".L0")),
            TackInstructionNode(.lio(.o(4), false)),
            TackInstructionNode(.jmp(".L1")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.lio(.o(4), true)),
            LabelDeclaration(identifier: ".L1")
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(4)))
    }

    func testRvalue_Binary_comptime_bool_eq() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .booleanType(.compTimeBool(true)))),
            ("right", Symbol(type: .booleanType(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .eq, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_bool_ne() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .booleanType(.compTimeBool(true)))),
            ("right", Symbol(type: .booleanType(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .ne, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), false))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_bool_and() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .booleanType(.compTimeBool(true)))),
            ("right", Symbol(type: .booleanType(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .doubleAmpersand, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Binary_comptime_bool_or() throws {
        let symbols = Env(tuples: [
            ("left", Symbol(type: .booleanType(.compTimeBool(true)))),
            ("right", Symbol(type: .booleanType(.compTimeBool(true))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .doublePipe, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(.lio(.o(0), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    func testRvalue_Assignment_ToPrimitiveScalar() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .staticStorage(offset: 0x1000)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: LiteralInt(42)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.liuw(.w(1), 42)),
            TackInstructionNode(.sw(.w(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1)))
    }

    func testRvalue_Assignment_ArrayToArray_Size_0() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 0, elementType: .u16),
                    storage: .staticStorage(offset: 0x1000)
                )
            ),
            (
                "bar",
                Symbol(
                    type: .array(count: 0, elementType: .u16),
                    storage: .staticStorage(offset: 0x2000)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: Identifier("bar")
            )
        )
        let expected = TackInstructionNode(.lip(.p(0), 0x1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_Assignment_ArrayToArray_Size_1() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 1, elementType: .u16),
                    storage: .staticStorage(offset: 0x1000)
                )
            ),
            (
                "bar",
                Symbol(
                    type: .array(count: 1, elementType: .u16),
                    storage: .staticStorage(offset: 0x2000)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: Identifier("bar")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.lip(.p(1), 0x2000)),
            TackInstructionNode(.memcpy(.p(0), .p(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testRvalue_Assignment_ArrayToArray_Size_2() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 2, elementType: .u16),
                    storage: .staticStorage(offset: 0x1000)
                )
            ),
            (
                "bar",
                Symbol(
                    type: .array(count: 2, elementType: .u16),
                    storage: .staticStorage(offset: 0x2000)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: Identifier("bar")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.lip(.p(1), 0x2000)),
            TackInstructionNode(.memcpy(.p(0), .p(1), 2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testRvalue_SubscriptRvalue_CompileTimeIndexAndPrimitiveElement() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 10, elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Subscript(subscriptable: Identifier("foo"), argument: LiteralInt(9))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.liuw(.w(1), 9)),
            TackInstructionNode(.addpw(.p(2), .p(0), .w(1))),
            TackInstructionNode(.lw(.w(3), .p(2), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(3)))
    }

    func testRvalue_SubscriptRvalue_RuntimeTimeIndexAndPrimitiveElement() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 10, elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Subscript(subscriptable: Identifier("foo"), argument: ExprUtils.makeU16(value: 9))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.liuw(.w(1), 9)),
            TackInstructionNode(.liw(.w(2), 0)),
            TackInstructionNode(.gew(.o(3), .w(1), .w(2))),
            TackInstructionNode(.bnz(.o(3), ".L0")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.liw(.w(4), 10)),
            TackInstructionNode(.ltw(.o(5), .w(1), .w(4))),
            TackInstructionNode(.bnz(.o(5), ".L1")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L1"),
            TackInstructionNode(.addpw(.p(6), .p(0), .w(1))),
            TackInstructionNode(.lw(.w(7), .p(6), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(7)))
    }

    func testRvalue_SubscriptRvalue_ZeroSizeElement() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 10, elementType: .void),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Subscript(subscriptable: Identifier("foo"), argument: ExprUtils.makeU16(value: 9))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lw(.w(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1)))
    }

    func testRvalue_SubscriptRvalue_NestedArray() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 10, elementType: .array(count: 2, elementType: .u16)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Subscript(subscriptable: Identifier("foo"), argument: ExprUtils.makeU16(value: 9))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.liuw(.w(1), 9)),
            TackInstructionNode(.liw(.w(2), 0)),
            TackInstructionNode(.gew(.o(3), .w(1), .w(2))),
            TackInstructionNode(.bnz(.o(3), ".L0")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.liw(.w(4), 10)),
            TackInstructionNode(.ltw(.o(5), .w(1), .w(4))),
            TackInstructionNode(.bnz(.o(5), ".L1")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L1"),
            TackInstructionNode(.muliw(.w(6), .w(1), 2)),
            TackInstructionNode(.addpw(.p(7), .p(0), .w(6)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(7)))
    }

    func testRvalue_SubscriptRvalue_DynamicArray() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .dynamicArray(elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Subscript(subscriptable: Identifier("foo"), argument: ExprUtils.makeU16(value: 9))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 9)),
            TackInstructionNode(.liw(.w(3), 0)),
            TackInstructionNode(.gew(.o(4), .w(2), .w(3))),
            TackInstructionNode(.bnz(.o(4), ".L0")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L0"),
            TackInstructionNode(.lw(.w(5), .p(0), 1)),
            TackInstructionNode(.ltw(.o(6), .w(2), .w(5))),
            TackInstructionNode(.bnz(.o(6), ".L1")),
            TackInstructionNode(.call("__oob")),
            LabelDeclaration(identifier: ".L1"),
            TackInstructionNode(.addpw(.p(7), .p(1), .w(2))),
            TackInstructionNode(.lw(.w(8), .p(7), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(8)))
    }

    func testRvalue_compiler_error_when_index_is_known_negative_at_compile_time() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .dynamicArray(elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(
            try compiler.rvalue(
                expr: Subscript(subscriptable: Identifier("foo"), argument: LiteralInt(-1))
            )
        ) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Array index is always out of bounds: `-1' is less than zero"
            )
        }
    }

    func testRvalue_compiler_error_when_index_is_known_oob_at_compile_time() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 10, elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(
            try compiler.rvalue(
                expr: Subscript(subscriptable: Identifier("foo"), argument: LiteralInt(100))
            )
        ) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Array index is always out of bounds: `100' is not in 0..10"
            )
        }
    }

    func testLvalue_compiler_error_when_index_is_known_negative_at_compile_time() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .dynamicArray(elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(
            try compiler.lvalue(
                expr: Subscript(subscriptable: Identifier("foo"), argument: LiteralInt(-1))
            )
        ) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Array index is always out of bounds: `-1' is less than zero"
            )
        }
    }

    func testLvalue_compiler_error_when_index_is_known_oob_at_compile_time() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 10, elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(
            try compiler.lvalue(
                expr: Subscript(subscriptable: Identifier("foo"), argument: LiteralInt(100))
            )
        ) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Array index is always out of bounds: `100' is not in 0..10"
            )
        }
    }

    func testRvalue_Assignment_ToArrayElementViaSubscript() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 10, elementType: .u16),
                    storage: .staticStorage(offset: 0x1000)
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Subscript(
                    subscriptable: Identifier("foo"),
                    argument: LiteralInt(9)
                ),
                rexpr: LiteralInt(42)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.liuw(.w(1), 9)),
            TackInstructionNode(.addpw(.p(2), .p(0), .w(1))),
            TackInstructionNode(.liuw(.w(3), 42)),
            TackInstructionNode(.sw(.w(3), .p(2), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(3)))
    }

    func testRvalue_Assignment_automatic_conversion_from_object_to_pointer() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u16), storage: .staticStorage(offset: 0x1000))),
            ("bar", Symbol(type: .u16, storage: .staticStorage(offset: 0x2000)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: Identifier("bar")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.lip(.p(1), 0x2000)),
            TackInstructionNode(.sp(.p(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testRvalue_Assignment_automatic_conversion_from_object_to_pointer_requires_lvalue() throws
    {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u16), storage: .staticStorage(offset: 0x1000)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let expr = Assignment(
            lexpr: Identifier("foo"),
            rexpr: ExprUtils.makeU16(value: 42)
        )
        XCTAssertThrowsError(try compiler.lvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "lvalue required")
        }
    }

    func testRvalue_Get_array_count() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 42, elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("count")
            )
        )
        let expected = TackInstructionNode(.liuw(.w(0), 42))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
    }

    func testRvalue_Get_dynamic_array_count() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .dynamicArray(elementType: .u16),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("count")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lw(.w(1), .p(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1)))
    }

    func testRvalue_Get_struct_member_primitive() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: kSliceType, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("count")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lw(.w(1), .p(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1)))
    }

    func testRvalue_Get_struct_member_not_primitive() throws {
        let type: SymbolType = .structType(
            StructTypeInfo(
                name: "bar",
                fields: Env(tuples: [
                    ("wat", Symbol(type: .u16, offset: 0)),
                    ("baz", Symbol(type: .array(count: 1, elementType: .u16), offset: 1))
                ])
            )
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: type, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("baz")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.addip(.p(1), .p(0), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testRvalue_Get_pointee_primitive() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u16), storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("pointee")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.lw(.w(2), .p(1), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testLvalue_Get_pointee_primitive() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u16), storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.lvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("pointee")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testLvalue_Bitcast() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u16), storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.lvalue(
            expr: Bitcast(
                expr: Get(expr: Identifier("foo"), member: Identifier("pointee")),
                targetType: PrimitiveType(.u8)
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testRvalue_Get_pointee_not_primitive() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .pointer(.array(count: 1, elementType: .u16)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("pointee")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(1)))
    }

    func testRvalue_Get_array_count_via_pointer() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .pointer(.array(count: 42, elementType: .u16)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("count")
            )
        )
        let expected = TackInstructionNode(.liuw(.w(0), 42))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
    }

    func testRvalue_Get_dynamic_array_count_via_pointer() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .pointer(.dynamicArray(elementType: .u16)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("count")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.lw(.w(2), .p(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testRvalue_Get_primitive_struct_member_via_pointer() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(kSliceType), storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("count")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.lw(.w(2), .p(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(2)))
    }

    func testRvalue_Get_non_primitive_struct_member_via_pointer() throws {
        let type: SymbolType = .pointer(
            .structType(
                StructTypeInfo(
                    name: "bar",
                    fields: Env(tuples: [
                        ("wat", Symbol(type: .u16, offset: 0)),
                        ("baz", Symbol(type: .array(count: 1, elementType: .u16), offset: 1))
                    ])
                )
            )
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: type, storage: .staticStorage(offset: 0xabcd)))
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Get(
                expr: Identifier("foo"),
                member: Identifier("baz")
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.addip(.p(2), .p(1), 1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(2)))
    }

    func testRvalue_Call_no_return_no_args() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "foo",
                            mangledName: "foo",
                            returnType: .void,
                            arguments: []
                        )
                    )
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Call(callee: Identifier("foo"), arguments: []))
        let expected = TackInstructionNode(.call("foo"))
        XCTAssertEqual(actual, expected)
    }

    func testRvalue_Call_return_some_primitive_value_and_no_args() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "foo",
                            mangledName: "foo",
                            returnType: .u16,
                            arguments: []
                        )
                    )
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Call(callee: Identifier("foo"), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.alloca(.p(0), 1)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.subip(.p(1), .fp, 1)),
            TackInstructionNode(.memcpy(.p(1), .p(0), 1)),
            TackInstructionNode(.free(1)),
            TackInstructionNode(.subip(.p(2), .fp, 1)),
            TackInstructionNode(.lw(.w(3), .p(2), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(3)))
    }

    func testRvalue_Call_return_some_non_primitive_value_and_no_args() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "foo",
                            mangledName: "foo",
                            returnType: .dynamicArray(elementType: .u16),
                            arguments: []
                        )
                    )
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Call(callee: Identifier("foo"), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.alloca(.p(0), 2)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.subip(.p(1), .fp, 2)),
            TackInstructionNode(.memcpy(.p(1), .p(0), 2)),
            TackInstructionNode(.free(2)),
            TackInstructionNode(.subip(.p(2), .fp, 2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(2)))
    }

    func testRvalue_Call_one_primitive_arg() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "foo",
                            mangledName: "foo",
                            returnType: .void,
                            arguments: [
                                .u16
                            ]
                        )
                    )
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Call(
                callee: Identifier("foo"),
                arguments: [
                    LiteralInt(0x1000)
                ]
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.liuw(.w(0), 0x1000)),
            TackInstructionNode(.alloca(.p(1), 1)),
            TackInstructionNode(.sw(.w(0), .p(1), 0)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.free(1))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_Call_return_value_and_one_arg() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "foo",
                            mangledName: "foo",
                            returnType: .u16,
                            arguments: [.u16]
                        )
                    )
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Call(callee: Identifier("foo"), arguments: [LiteralInt(0xabcd)])
        )
        let expected = Seq(children: [
            TackInstructionNode(.liuw(.w(0), 0xabcd)),
            TackInstructionNode(.alloca(.p(1), 1)),
            TackInstructionNode(.alloca(.p(2), 1)),
            TackInstructionNode(.sw(.w(0), .p(2), 0)),
            TackInstructionNode(.call("foo")),
            TackInstructionNode(.subip(.p(3), .fp, 1)),
            TackInstructionNode(.memcpy(.p(3), .p(1), 1)),
            TackInstructionNode(.free(2)),
            TackInstructionNode(.subip(.p(4), .fp, 1)),
            TackInstructionNode(.lw(.w(5), .p(4), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(5)))
    }

    func testRvalue_Call_function_pointer() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .pointer(.function(FunctionTypeInfo(returnType: .void, arguments: []))),
                    offset: 0xabcd
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Call(callee: Identifier("foo"), arguments: []))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.callptr(.p(1)))
        ])
        XCTAssertEqual(actual, expected)
    }

    func testRvalue_Call_panic_with_string_arg() throws {
        let symbols = Env(tuples: [
            (
                "panic",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "panic",
                            mangledName: "panic",
                            returnType: .void,
                            arguments: [
                                .dynamicArray(elementType: .arithmeticType(.immutableInt(.u8)))
                            ]
                        )
                    )
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Call(
                callee: Identifier("panic"),
                arguments: [
                    LiteralString("panic")
                ]
            )
        )
        let expected = Seq(children: [
            TackInstructionNode(.subip(.p(0), .fp, 2)),
            TackInstructionNode(.subip(.p(1), .fp, 7)),
            TackInstructionNode(.ststr(.p(1), "panic")),
            TackInstructionNode(.sp(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 5)),
            TackInstructionNode(.sw(.w(2), .p(0), 1)),
            TackInstructionNode(.alloca(.p(3), 2)),  // TODO: This ALLOCA and MEMCPY are not actually necessary since vr0 contains the address of the dynamic array in memory already.
            TackInstructionNode(.memcpy(.p(3), .p(0), 2)),
            TackInstructionNode(.call("panic")),
            TackInstructionNode(.free(2))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertNil(compiler.registerStack.last)
    }

    func testRvalue_Assignment_with_StructInitializer() throws {
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: kSliceType, storage: .staticStorage(offset: 0x1000))
        )
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let lexpr = Identifier("foo")
        let rexpr = StructInitializer(
            identifier: Identifier(kSliceName),
            arguments: [
                StructInitializer.Argument(
                    name: kSliceBase,
                    expr: LiteralInt(0xabcd)
                ),
                StructInitializer.Argument(
                    name: kSliceCount,
                    expr: LiteralInt(0xffff)
                )
            ]
        )
        let actual = try compiler.rvalue(expr: Assignment(lexpr: lexpr, rexpr: rexpr))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 0xabcd)),
            TackInstructionNode(.sw(.w(2), .p(1), 0)),
            TackInstructionNode(.lip(.p(3), 0x1000)),
            TackInstructionNode(.addip(.p(4), .p(3), 1)),
            TackInstructionNode(.liuw(.w(5), 0xffff)),
            TackInstructionNode(.sw(.w(5), .p(4), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(5)))
    }

    func testRvalue_Assignment_with_StructInitializer_NoArgs() throws {
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: kSliceType, storage: .staticStorage(offset: 0x1000))
        )
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let lexpr = Identifier("foo")
        let rexpr = StructInitializer(identifier: Identifier(kSliceName), arguments: [])
        let actual = try compiler.rvalue(expr: Assignment(lexpr: lexpr, rexpr: rexpr))
        let expected = Seq(children: [])
        XCTAssertEqual(actual, expected)
        XCTAssertTrue(compiler.registerStack.isEmpty)
    }

    func testFixBugInvolvingInitialAssignmentWithStructInitializer() throws {
        let symbols = Env()
        let kSliceType: SymbolType = .constStructType(
            StructTypeInfo(
                name: kSliceName,
                fields: Env(tuples: [
                    (
                        kSliceBase,
                        Symbol(
                            type: kSliceBaseAddressType.correspondingConstType,
                            offset: kSliceBaseAddressOffset
                        )
                    ),
                    (
                        kSliceCount,
                        Symbol(
                            type: kSliceCountType.correspondingConstType,
                            offset: kSliceCountOffset
                        )
                    )
                ])
            )
        )
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(
                type: kSliceType,
                storage: .staticStorage(offset: 0x1000)
            )
        )
        symbols.bind(identifier: kSliceName, symbolType: kSliceType)
        let compiler = makeCompiler(symbols: symbols)
        let lexpr = Identifier("foo")
        let rexpr = StructInitializer(
            identifier: Identifier(kSliceName),
            arguments: [
                StructInitializer.Argument(
                    name: kSliceBase,
                    expr: LiteralInt(0xabcd)
                ),
                StructInitializer.Argument(
                    name: kSliceCount,
                    expr: LiteralInt(0xffff)
                )
            ]
        )
        let actual = try compiler.rvalue(expr: InitialAssignment(lexpr: lexpr, rexpr: rexpr))
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 0xabcd)),
            TackInstructionNode(.sw(.w(2), .p(1), 0)),
            TackInstructionNode(.lip(.p(3), 0x1000)),
            TackInstructionNode(.addip(.p(4), .p(3), 1)),
            TackInstructionNode(.liuw(.w(5), 0xffff)),
            TackInstructionNode(.sw(.w(5), .p(4), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(5)))
    }

    func testRvalue_As_LiteralArray() throws {
        let compiler = makeCompiler()
        let literalArrayType = ArrayType(count: nil, elementType: PrimitiveType(.u8))
        let literalArray = LiteralArray(
            arrayType: literalArrayType,
            elements: [
                LiteralInt(42)
            ]
        )
        let targetType = ArrayType(count: nil, elementType: PrimitiveType(.u16))
        let asExpr = As(expr: literalArray, targetType: targetType)
        let actual = try compiler.rvalue(expr: asExpr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.liuw(.w(1), 42)),
            TackInstructionNode(.sw(.w(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testFixBugWithCompilerTemporaryOfArrayTypeWithNoExplicitCount() throws {
        let compiler = makeCompiler()
        let literalArray = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u16)),
            elements: [
                LiteralInt(1), LiteralInt(2)
            ]
        )
        _ = try compiler.rvalue(expr: literalArray)
        guard let type = try compiler.symbols?.resolve(identifier: "__temp0").type else {
            XCTFail("failed to resolve __temp0")
            return
        }
        let actual = memoryLayoutStrategy.sizeof(type: type)
        XCTAssertEqual(actual, 2)
    }

    func testRvalue_ArraySlice_WithNonRangeArgument() throws {
        let symbols = Env(
            tuples: [("foo", Symbol(type: .array(count: 2, elementType: .u16)))],
            typeDict: [kSliceName: kSliceType]
        )
        let compiler = makeCompiler(symbols: symbols)
        let arg = StructInitializer(
            identifier: Identifier(kSliceName),
            arguments: [
                StructInitializer.Argument(name: kSliceBase, expr: LiteralInt(0)),
                StructInitializer.Argument(name: kSliceCount, expr: LiteralInt(0))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: arg)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot subscript a value of type `[2]u16' with an argument of type `Slice'"
            )
        }
    }

    func testRvalue_ArraySlice_RangeBeginIsOutOfBoundsAtCompileTime() throws {
        let symbols = Env(
            tuples: [("foo", Symbol(type: .array(count: 1, elementType: .u16)))],
            typeDict: [kRangeName: kRangeType]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(200)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(201))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Array index is always out of bounds: `200' is not in 0..1"
            )
        }
    }

    func testRvalue_ArraySlice_RangeLimitIsOutOfBoundsAtCompileTime() throws {
        let symbols = Env(
            tuples: [("foo", Symbol(type: .array(count: 1, elementType: .u16)))],
            typeDict: [kRangeName: kRangeType]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(0)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(201))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Array index is always out of bounds: `201' is not in 0..1"
            )
        }
    }

    func testRvalue_ArraySlice_RangeLimitIsOutOfBoundsAtCompileTime_2() throws {
        let symbols = Env(
            tuples: [("foo", Symbol(type: .array(count: 2, elementType: .u16)))],
            typeDict: [kRangeName: kRangeType]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(1)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(0))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Range requires begin less than or equal to limit: `1..0'"
            )
        }
    }

    func testRvalue_ArraySlice_0() throws {
        let symbols = Env(
            tuples: [
                (
                    "foo",
                    Symbol(
                        type: .array(count: 1, elementType: .u16),
                        offset: 0x1000
                    )
                )
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(0)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(1))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 0x1000)),
            TackInstructionNode(.bitcast(.w(.w(3)), .p(.p(2)))),
            TackInstructionNode(.sw(.w(3), .p(1), 0)),
            TackInstructionNode(.lip(.p(4), 0x0110)),
            TackInstructionNode(.addip(.p(5), .p(4), 1)),
            TackInstructionNode(.liuw(.w(6), 1)),
            TackInstructionNode(.sw(.w(6), .p(5), 0)),
            TackInstructionNode(.lip(.p(7), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(7)))
    }

    func testRvalue_ArraySlice_1() throws {
        let symbols = Env(
            tuples: [
                (
                    "foo",
                    Symbol(
                        type: .array(count: 3, elementType: .u16),
                        offset: 0x1000
                    )
                )
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(1)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(3))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 1)),
            TackInstructionNode(.lip(.p(3), 0x1000)),
            TackInstructionNode(.bitcast(.w(.w(4)), .p(.p(3)))),
            TackInstructionNode(.addw(.w(5), .w(4), .w(2))),
            TackInstructionNode(.sw(.w(5), .p(1), 0)),
            TackInstructionNode(.lip(.p(6), 0x0110)),
            TackInstructionNode(.addip(.p(7), .p(6), 1)),
            TackInstructionNode(.liuw(.w(8), 2)),
            TackInstructionNode(.sw(.w(8), .p(7), 0)),
            TackInstructionNode(.lip(.p(9), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(9)))
    }

    func testRvalue_ArraySlice_2() throws {
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: .array(count: 3, elementType: .u16), offset: 0x1000)),
                ("a", Symbol(type: .u16, offset: 0x2000)),
                ("b", Symbol(type: .u16, offset: 0x2001))
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let opts = CoreToTackCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: Identifier("a")),
                StructInitializer.Argument(name: kRangeLimit, expr: Identifier("b"))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 0x2000)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.lip(.p(4), 0x1000)),
            TackInstructionNode(.bitcast(.w(.w(5)), .p(.p(4)))),
            TackInstructionNode(.addw(.w(6), .w(5), .w(3))),
            TackInstructionNode(.sw(.w(6), .p(1), 0)),
            TackInstructionNode(.lip(.p(7), 0x0110)),
            TackInstructionNode(.addip(.p(8), .p(7), 1)),
            TackInstructionNode(.lip(.p(9), 0x2000)),
            TackInstructionNode(.lw(.w(10), .p(9), 0)),
            TackInstructionNode(.lip(.p(11), 0x2001)),
            TackInstructionNode(.lw(.w(12), .p(11), 0)),
            TackInstructionNode(.subw(.w(13), .w(12), .w(10))),
            TackInstructionNode(.sw(.w(13), .p(8), 0)),
            TackInstructionNode(.lip(.p(14), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(14)))
    }

    func testRvalue_ArraySlice_ElementSizeGreaterThanOne_1() throws {
        let symbols = Env(
            tuples: [
                (
                    "foo",
                    Symbol(
                        type: .array(count: 3, elementType: .array(count: 3, elementType: .u16)),
                        offset: 0x1000
                    )
                )
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(1)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(3))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 3)),
            TackInstructionNode(.lip(.p(3), 0x1000)),
            TackInstructionNode(.bitcast(.w(.w(4)), .p(.p(3)))),
            TackInstructionNode(.addw(.w(5), .w(4), .w(2))),
            TackInstructionNode(.sw(.w(5), .p(1), 0)),
            TackInstructionNode(.lip(.p(6), 0x0110)),
            TackInstructionNode(.addip(.p(7), .p(6), 1)),
            TackInstructionNode(.liuw(.w(8), 2)),
            TackInstructionNode(.sw(.w(8), .p(7), 0)),
            TackInstructionNode(.lip(.p(9), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(9)))
    }

    func testRvalue_ArraySlice_Identifier() throws {
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: .array(count: 2, elementType: .u16), offset: 0x1000)),
                ("range", Symbol(type: kRangeType, offset: 0x2000))
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let opts = CoreToTackCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let expr = Subscript(
            subscriptable: Identifier("foo"),
            argument: Identifier("range")
        )
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 0x2000)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.lip(.p(4), 0x1000)),
            TackInstructionNode(.bitcast(.w(.w(5)), .p(.p(4)))),
            TackInstructionNode(.addw(.w(6), .w(5), .w(3))),
            TackInstructionNode(.sw(.w(6), .p(1), 0)),
            TackInstructionNode(.lip(.p(7), 0x0110)),
            TackInstructionNode(.addip(.p(8), .p(7), 1)),
            TackInstructionNode(.lip(.p(9), 0x2000)),
            TackInstructionNode(.lw(.w(10), .p(9), 0)),
            TackInstructionNode(.lip(.p(11), 0x2000)),
            TackInstructionNode(.lw(.w(12), .p(11), 1)),
            TackInstructionNode(.subw(.w(13), .w(12), .w(10))),
            TackInstructionNode(.sw(.w(13), .p(8), 0)),
            TackInstructionNode(.lip(.p(14), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(14)))
    }

    func testRvalue_ArraySlice_ElementSizeGreaterThanOne_2() throws {
        let symbols = Env(
            tuples: [
                (
                    "foo",
                    Symbol(
                        type: .array(count: 3, elementType: .array(count: 3, elementType: .u16)),
                        offset: 0x1000
                    )
                ),
                ("a", Symbol(type: .u16, offset: 0x2000)),
                ("b", Symbol(type: .u16, offset: 0x2001))
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let opts = CoreToTackCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: Identifier("a")),
                StructInitializer.Argument(name: kRangeLimit, expr: Identifier("b"))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 3)),
            TackInstructionNode(.lip(.p(3), 0x2000)),
            TackInstructionNode(.lw(.w(4), .p(3), 0)),
            TackInstructionNode(.mulw(.w(5), .w(4), .w(2))),
            TackInstructionNode(.lip(.p(6), 0x1000)),
            TackInstructionNode(.bitcast(.w(.w(7)), .p(.p(6)))),
            TackInstructionNode(.addw(.w(8), .w(7), .w(5))),
            TackInstructionNode(.sw(.w(8), .p(1), 0)),
            TackInstructionNode(.lip(.p(9), 0x0110)),
            TackInstructionNode(.addip(.p(10), .p(9), 1)),
            TackInstructionNode(.lip(.p(11), 0x2000)),
            TackInstructionNode(.lw(.w(12), .p(11), 0)),
            TackInstructionNode(.lip(.p(13), 0x2001)),
            TackInstructionNode(.lw(.w(14), .p(13), 0)),
            TackInstructionNode(.subw(.w(15), .w(14), .w(12))),
            TackInstructionNode(.sw(.w(15), .p(10), 0)),
            TackInstructionNode(.lip(.p(16), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(16)))
    }

    func testRvalue_SubscriptDynamicArray_WithNonRangeArgument() throws {
        let symbols = Env(
            tuples: [("foo", Symbol(type: .dynamicArray(elementType: .u16)))],
            typeDict: [kSliceName: kSliceType]
        )
        let compiler = makeCompiler(symbols: symbols)
        let arg = StructInitializer(
            identifier: Identifier(kSliceName),
            arguments: [
                StructInitializer.Argument(name: kSliceBase, expr: LiteralInt(0)),
                StructInitializer.Argument(name: kSliceCount, expr: LiteralInt(0))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: arg)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot subscript a value of type `[]u16' with an argument of type `Slice'"
            )
        }
    }

    func testRvalue_DynamicArraySlice_1() throws {
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: .constDynamicArray(elementType: .u16), offset: 0x1000))
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(0)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(1))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 0x1000)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.sw(.w(3), .p(1), 0)),
            TackInstructionNode(.lip(.p(4), 0x0110)),
            TackInstructionNode(.addip(.p(5), .p(4), 1)),
            TackInstructionNode(.liuw(.w(6), 1)),
            TackInstructionNode(.sw(.w(6), .p(5), 0)),
            TackInstructionNode(.lip(.p(7), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(7)))
    }

    func testRvalue_DynamicArraySlice_2() throws {
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: .constDynamicArray(elementType: .u16), offset: 0x1000)),
                ("a", Symbol(type: .u16, offset: 0x2000)),
                ("b", Symbol(type: .u16, offset: 0x2001))
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let opts = CoreToTackCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: Identifier("a")),
                StructInitializer.Argument(name: kRangeLimit, expr: Identifier("b"))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.lip(.p(2), 0x2000)),
            TackInstructionNode(.lw(.w(3), .p(2), 0)),
            TackInstructionNode(.lip(.p(4), 0x1000)),
            TackInstructionNode(.lw(.w(5), .p(4), 0)),
            TackInstructionNode(.addw(.w(6), .w(5), .w(3))),
            TackInstructionNode(.sw(.w(6), .p(1), 0)),
            TackInstructionNode(.lip(.p(7), 0x0110)),
            TackInstructionNode(.addip(.p(8), .p(7), 1)),
            TackInstructionNode(.lip(.p(9), 0x2000)),
            TackInstructionNode(.lw(.w(10), .p(9), 0)),
            TackInstructionNode(.lip(.p(11), 0x2001)),
            TackInstructionNode(.lw(.w(12), .p(11), 0)),
            TackInstructionNode(.subw(.w(13), .w(12), .w(10))),
            TackInstructionNode(.sw(.w(13), .p(8), 0)),
            TackInstructionNode(.lip(.p(14), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(14)))
    }

    func testRvalue_DynamicArraySlice_ElementSizeGreaterThanOne_1() throws {
        let symbols = Env(
            tuples: [
                (
                    "foo",
                    Symbol(
                        type: .constDynamicArray(elementType: .array(count: 3, elementType: .u16)),
                        offset: 0x1000
                    )
                )
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let compiler = makeCompiler(symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: LiteralInt(1)),
                StructInitializer.Argument(name: kRangeLimit, expr: LiteralInt(3))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 3)),
            TackInstructionNode(.lip(.p(3), 0x1000)),
            TackInstructionNode(.lw(.w(4), .p(3), 0)),
            TackInstructionNode(.addw(.w(5), .w(4), .w(2))),
            TackInstructionNode(.sw(.w(5), .p(1), 0)),
            TackInstructionNode(.lip(.p(6), 0x0110)),
            TackInstructionNode(.addip(.p(7), .p(6), 1)),
            TackInstructionNode(.liuw(.w(8), 2)),
            TackInstructionNode(.sw(.w(8), .p(7), 0)),
            TackInstructionNode(.lip(.p(9), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(9)))
    }

    func testRvalue_DynamicArraySlice_ElementSizeGreaterThanOne_2() throws {
        let symbols = Env(
            tuples: [
                (
                    "foo",
                    Symbol(
                        type: .constDynamicArray(elementType: .array(count: 3, elementType: .u16)),
                        offset: 0x1000
                    )
                ),
                ("a", Symbol(type: .u16, offset: 0x2000)),
                ("b", Symbol(type: .u16, offset: 0x2001))
            ],
            typeDict: [
                kRangeName: kRangeType,
                kSliceName: kSliceType
            ]
        )
        let opts = CoreToTackCompiler.Options(isBoundsCheckEnabled: false)
        let compiler = makeCompiler(options: opts, symbols: symbols)
        let range = StructInitializer(
            identifier: Identifier(kRangeName),
            arguments: [
                StructInitializer.Argument(name: kRangeBegin, expr: Identifier("a")),
                StructInitializer.Argument(name: kRangeLimit, expr: Identifier("b"))
            ]
        )
        let expr = Subscript(subscriptable: Identifier("foo"), argument: range)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x0110)),
            TackInstructionNode(.addip(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 3)),
            TackInstructionNode(.lip(.p(3), 0x2000)),
            TackInstructionNode(.lw(.w(4), .p(3), 0)),
            TackInstructionNode(.mulw(.w(5), .w(4), .w(2))),
            TackInstructionNode(.lip(.p(6), 0x1000)),
            TackInstructionNode(.lw(.w(7), .p(6), 0)),
            TackInstructionNode(.addw(.w(8), .w(7), .w(5))),
            TackInstructionNode(.sw(.w(8), .p(1), 0)),
            TackInstructionNode(.lip(.p(9), 0x0110)),
            TackInstructionNode(.addip(.p(10), .p(9), 1)),
            TackInstructionNode(.lip(.p(11), 0x2000)),
            TackInstructionNode(.lw(.w(12), .p(11), 0)),
            TackInstructionNode(.lip(.p(13), 0x2001)),
            TackInstructionNode(.lw(.w(14), .p(13), 0)),
            TackInstructionNode(.subw(.w(15), .w(14), .w(12))),
            TackInstructionNode(.sw(.w(15), .p(10), 0)),
            TackInstructionNode(.lip(.p(16), 0x0110))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(16)))
    }

    func testLvalue_LvalueOfMemberOfStructInitializer() throws {
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: .u16, offset: 0xabcd))
            ],
            typeDict: [
                "Foo": .structType(typ)
            ]
        )
        let si = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                StructInitializer.Argument(name: "bar", expr: Identifier("foo"))
            ]
        )
        let expr = Get(expr: si, member: Identifier("bar"))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.lvalue(expr: expr)
        let expected = TackInstructionNode(.lip(.p(0), 0xabcd))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testLvalue_CannotInstantiateGenericFunctionTypeWithoutApplication() {
        // Create a symbol table with a generic function defined
        let symbols = Env()
        let funSym = Env(parent: symbols)
        let bodySym = Env(parent: funSym)
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
            body: Block(symbols: bodySym),
            visibility: .privateVisibility,
            symbols: funSym
        )
        let genericFunctionType = GenericFunctionType(template: template)
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericFunction(genericFunctionType)))

        // Compile the expression. We expect this to fail because we're missing
        // a generic type application which would turn it into a concrete type.
        let expr = Identifier("foo")
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.lvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot instantiate generic function `func foo[T](a: T) -> T'"
            )
        }
    }

    func testRvalue_CannotInstantiateGenericFunctionTypeWithoutApplication() throws {
        let compiler = makeCompiler()
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
            body: Block(),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let expr = GenericFunctionType(template: template)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot instantiate generic function `func foo[T](a: T) -> T'"
            )
        }
    }

    func testRvalue_CannotTakeTheAddressOfGenericFunctionWithoutTypeArguments() {
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
            body: Block(),
            visibility: .privateVisibility,
            symbols: Env()
        )
        let genericFunctionType = GenericFunctionType(template: template)
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])

        let expr = Unary(op: .ampersand, expression: Identifier("foo"))
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.rvalue(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot instantiate generic function `func foo[T](a: T) -> T'"
            )
        }
    }

    func testRvalue_RvalueOfMemberOfStructInitializer() throws {
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, storage: .automaticStorage(offset: 0)))
            ])
        )
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: .u16, offset: 0xabcd))
            ],
            typeDict: [
                "Foo": .structType(typ)
            ]
        )
        let si = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                StructInitializer.Argument(name: "bar", expr: Identifier("foo"))
            ]
        )
        let expr = Get(expr: si, member: Identifier("bar"))
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lw(.w(1), .p(0), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1)))
    }

    func testAsm_Empty() throws {
        let compiler = makeCompiler()
        let actual = try compiler.visit(asm: Asm(assemblyCode: ""))
        let expected = TackInstructionNode(.inlineAssembly(""))
        XCTAssertEqual(actual, expected)
    }

    func testAsm_HLT() throws {
        let compiler = makeCompiler()
        let actual = try compiler.visit(asm: Asm(assemblyCode: "HLT"))
        let expected = TackInstructionNode(.inlineAssembly("HLT"))
        XCTAssertEqual(actual, expected)
    }

    func testRvalue_FunctionByIdentifier() throws {
        let symbols = Env(tuples: [
            (
                "panic",
                Symbol(
                    type: .function(
                        FunctionTypeInfo(
                            name: "panic",
                            mangledName: "panic",
                            returnType: .void,
                            arguments: [
                                .dynamicArray(elementType: .arithmeticType(.immutableInt(.u8)))
                            ]
                        )
                    )
                )
            )
        ])
        let compiler = makeCompiler(symbols: symbols)
        let expr = Identifier("panic")
        let actual = try compiler.rvalue(expr: expr)
        let expected = TackInstructionNode(.la(.p(0), "panic"))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .p(.p(0)))
    }

    func testRvalue_Eseq() throws {
        let compiler = makeCompiler()
        let actual = try compiler.rvalue(
            expr: Eseq(
                seq: Seq(),
                expr: LiteralBool(false)
            )
        )
        let expected = TackInstructionNode(.lio(.o(0), false))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(0)))
    }

    // TODO: Need unit tests which exercise the syscall path on Turtle16. On this target, the SYSCALL Tack instruction ought to compile to basically a function call to a system call handler in the Turtle16 runtime.

    func testRvalue_SubscriptRangeObject() throws {
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: kRangeType, offset: 0xabcd))
            ],
            typeDict: [
                kRangeName: kRangeType
            ]
        )
        let compiler = makeCompiler(symbols: symbols)
        let expr = Subscript(
            subscriptable: Identifier("foo"),
            argument: LiteralInt(1)
        )
        let actual = try compiler.rvalue(expr: expr)
        let expected = Seq(children: [
            TackInstructionNode(.liuw(.w(0), 1)),
            TackInstructionNode(.lip(.p(1), 0xabcd)),
            TackInstructionNode(.lw(.w(2), .p(1), 0)),
            TackInstructionNode(.addw(.w(3), .w(2), .w(0)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(3)))
    }

    func testRvalue_Assignment_ToSymbolWithRegisterStorage_p() throws {
        let dst: TackInstruction.Register = .p(.p(1000))
        let symbols = Env(tuples: [
            ("dst", Symbol(type: .pointer(.void), storage: .registerStorage(dst))),
            ("src", Symbol(type: .pointer(.void), storage: .staticStorage(offset: 0x1000)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("dst"),
                rexpr: Identifier("src")
            )
        )

        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0x1000)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.movp(dst.unwrapPointer!, .p(1)))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, dst)
    }

    func testRvalue_Assignment_ToSymbolWithRegisterStorage_w() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .registerStorage(.w(.w(1000)))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: LiteralInt(1000)
            )
        )
        let expected = TackInstructionNode(.liuw(.w(1000), 1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(1000)))
    }

    func testRvalue_Assignment_ToSymbolWithRegisterStorage_b() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, storage: .registerStorage(.b(.b(1000)))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: LiteralInt(42)
            )
        )
        let expected = TackInstructionNode(.liub(.b(1000), 42))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .b(.b(1000)))
    }

    func testRvalue_Assignment_ToSymbolWithRegisterStorage_o() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .bool, storage: .registerStorage(.o(.o(1000)))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: LiteralBool(true)
            )
        )
        let expected = TackInstructionNode(.lio(.o(1000), true))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .o(.o(1000)))
    }

    func testRvalue_ReadSymbolWithRegisterStorage_p() throws {
        let foo: TackInstruction.Register = .p(.p(1000))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.void), storage: .registerStorage(foo)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Identifier("foo"))

        XCTAssertEqual(actual, Seq())
        XCTAssertEqual(compiler.registerStack.last, foo)
    }

    func testRvalue_ReadSymbolWithRegisterStorage_w() throws {
        let foo: TackInstruction.Register = .w(.w(1000))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .registerStorage(foo)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Identifier("foo"))

        XCTAssertEqual(actual, Seq())
        XCTAssertEqual(compiler.registerStack.last, foo)
    }

    func testRvalue_ReadSymbolWithRegisterStorage_b() throws {
        let foo: TackInstruction.Register = .b(.b(1000))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u8, storage: .registerStorage(foo)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Identifier("foo"))

        XCTAssertEqual(actual, Seq())
        XCTAssertEqual(compiler.registerStack.last, foo)
    }

    func testRvalue_ReadSymbolWithRegisterStorage_o() throws {
        let foo: TackInstruction.Register = .o(.o(1000))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .bool, storage: .registerStorage(foo)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(expr: Identifier("foo"))

        XCTAssertEqual(actual, Seq())
        XCTAssertEqual(compiler.registerStack.last, foo)
    }

    // Symbols with register storage may be used in expressions. The emitted
    // code will assume the value is already stored in the specified register.
    func testRvalue_Binary_addw_RegisterStorage() throws {
        let leftReg: TackInstruction.Register = .w(.w(1000))
        let rightReg: TackInstruction.Register = .w(.w(2000))
        let symbols = Env(tuples: [
            ("left", Symbol(type: .u16, storage: .registerStorage(leftReg))),
            ("right", Symbol(type: .u16, storage: .registerStorage(rightReg)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Binary(op: .plus, left: Identifier("left"), right: Identifier("right"))
        )
        let expected = TackInstructionNode(
            .addw(.w(0), leftReg.unwrap16!, rightReg.unwrap16!)
        )
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
    }

    // If a symbol has register storage, but does not specify which register to
    // use, then attempting to read that value will cause an error.
    func testRvalue_ReadSymbolWithRegisterStorage_Unbound() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .registerStorage(nil)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.rvalue(expr: Identifier("foo"))) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "symbol has register storage with no bound register: foo"
            )
        }
    }

    // If a symbol has register storage, but does not specify which register to
    // use, then attempting to store a value to that symbol will cause the
    // compiler to choose a register to bind it to.
    func testRvalue_Assignment_ToSymbolWithRegisterStorage_Unbound() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16, storage: .registerStorage(nil)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Assignment(
                lexpr: Identifier("foo"),
                rexpr: LiteralInt(1000)
            )
        )
        let expected = TackInstructionNode(.liuw(.w(0), 1000))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(0)))
        XCTAssertEqual(
            symbols.maybeResolve(identifier: "foo")?.storage,
            .registerStorage(.w(.w(0)))
        )
    }

    func testRvalue_SubscriptRvalue_SubscriptThroughPointerToArray() throws {
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .pointer(.array(count: 10, elementType: .u16)),
                    storage: .staticStorage(offset: 0xabcd)
                )
            )
        ])
        symbols.frameLookupMode = .set(Frame())
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.rvalue(
            expr: Subscript(subscriptable: Identifier("foo"), argument: LiteralInt(9))
        )
        let expected = Seq(children: [
            TackInstructionNode(.lip(.p(0), 0xabcd)),
            TackInstructionNode(.lp(.p(1), .p(0), 0)),
            TackInstructionNode(.liuw(.w(2), 9)),
            TackInstructionNode(.addpw(.p(3), .p(1), .w(2))),
            TackInstructionNode(.lw(.w(4), .p(3), 0))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, .w(.w(4)))
    }
}
