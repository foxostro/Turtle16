//
//  SnapToTackCompilerTests.swift
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
let kSliceBaseAddressType = SymbolType.u16
let kSliceCount = "count"
let kSliceCountOffset = 1
let kSliceCountType = SymbolType.u16
let kSliceType: SymbolType = .structType(StructType(name: kSliceName, symbols: SymbolTable(tuples: [
    (kSliceBase,  Symbol(type: kSliceBaseAddressType, offset: kSliceBaseAddressOffset)),
    (kSliceCount, Symbol(type: kSliceCountType, offset: kSliceCountOffset))
])))


class SnapToTackCompilerTests: XCTestCase {
    func makeCompiler(symbols: SymbolTable = SymbolTable()) -> SnapToTackCompiler {
        return SnapToTackCompiler(symbols: symbols, globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()))
    }
    
    func testLabelDeclaration() throws {
        let compiler = makeCompiler()
        let result = try compiler.compile(LabelDeclaration(identifier: "foo"))
        XCTAssertEqual(result, LabelDeclaration(identifier: "foo"))
    }
    
    func testBlockWithOneInstruction() throws {
        let compiler = makeCompiler()
        let result = try compiler.compile(Block(children: [
            LabelDeclaration(identifier: "foo")
        ]))
        XCTAssertEqual(result, LabelDeclaration(identifier: "foo"))
    }
    
    func testBlockWithTwoInstructions() throws {
        let compiler = makeCompiler()
        let result = try compiler.compile(Block(children: [
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
        let result = try compiler.compile(Block(children: [
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
        let result = try compiler.compile(Goto(target: "foo"))
        XCTAssertEqual(result, InstructionNode(instruction: Tack.kJMP, parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")])))
    }
    
    func testGotoIfFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(GotoIfFalse(condition: Expression.LiteralBool(false), target: "foo"))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: Tack.kBZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterIdentifier(value: "foo")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertTrue(compiler.registerStack.isEmpty)
    }
    
    func testRet() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Return())
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLEAVE),
            InstructionNode(instruction: Tack.kRET)
        ])
        XCTAssertEqual(actual, expected)
    }
    
    func testCompileFunctionDeclaration_Simplest() throws {
        let fn = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                     functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                     argumentNames: [],
                                     body: Block(children: [
                                        Return()
                                     ]))
        let compiler = makeCompiler()
        let actual = try compiler.compile(fn)
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "__foo_tail")
            ])),
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: Tack.kENTER, parameters: ParameterList(parameters: [
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: Tack.kLEAVE),
            InstructionNode(instruction: Tack.kRET),
            LabelDeclaration(identifier: "__foo_tail"),
        ])
        XCTAssertEqual(actual, expected)
    }
    
    func testExpr_LiteralBoolFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralBool(false))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralBoolTrue() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralBool(true))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralInt_Small_Positive() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralInt(1))
        let expected = InstructionNode(instruction: Tack.kLI8, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralInt_Small_Negative() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralInt(-1))
        let expected = InstructionNode(instruction: Tack.kLI8, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: -1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralInt_Big() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralInt(0x1000))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0x1000)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Identifier_Static_u16() throws {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = makeCompiler(symbols: SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: offset, storage: .staticStorage))
        ]))
        let actual = try compiler.compile(Expression.Identifier("foo"))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: offset)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr1")
    }
    
    func testExpr_Identifier_Stack_u16() throws {
        let offset = 4
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: offset, storage: .automaticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Identifier("foo"))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kSUBI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterIdentifier(value: "fp"),
                ParameterNumber(value: offset)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr1")
    }
    
    func testExpr_Identifier_struct() throws {
        let offset = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = makeCompiler(symbols: SymbolTable(tuples: [
            ("foo", Symbol(type: kSliceType, offset: offset, storage: .staticStorage))
        ]))
        let actual = try compiler.compile(Expression.Identifier("foo"))
        let expected = InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: offset)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_As_u8_to_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.u8)))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0xabcd)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr1")
    }
    
    func testExpr_As_u8_to_u16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.u16)))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0xabcd)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr1")
    }
    
    func testExpr_As_u16_to_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.u8)))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0xabcd)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0"),
            ])),
            InstructionNode(instruction: Tack.kANDI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1"),
                ParameterNumber(value: 0x00ff )
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr2")
    }
    
    func testExpr_As_array_to_array_of_same_type() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .u16), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16))))
        let expected = InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0xabcd)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_As_array_to_array_with_different_type_that_can_be_trivially_reinterpreted() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 0, elementType: .u8), offset: 0xabcd, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.ArrayType(count: Expression.LiteralInt(0), elementType: Expression.PrimitiveType(.u16))))
        let expected = InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0xabcd)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_As_array_to_array_where_each_element_must_be_converted() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .u16), offset: 0x1000, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8))))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0x1000)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kANDI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1"),
                ParameterNumber(value: 0x00ff)
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterNumber(value: 0x1001)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3")
            ])),
            InstructionNode(instruction: Tack.kANDI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr5"),
                ParameterIdentifier(value: "vr4"),
                ParameterNumber(value: 0x00ff)
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr6"),
                ParameterNumber(value: 0x1002)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr7"),
                ParameterIdentifier(value: "vr6")
            ])),
            InstructionNode(instruction: Tack.kANDI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr8"),
                ParameterIdentifier(value: "vr7"),
                ParameterNumber(value: 0x00ff)
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr8")
    }
    
    func testExpr_As_compTimeInt_small() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .compTimeInt(42), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.u8)))
        let expected = InstructionNode(instruction: Tack.kLI8, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 42)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_As_compTimeInt_big() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .compTimeInt(1000), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.u16)))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1000)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_As_compTimeBool_true() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .compTimeBool(true), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.bool)))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_As_compTimeBool_false() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .compTimeBool(false), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PrimitiveType(.bool)))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_As_pointer_to_pointer() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.u16), offset: 0xabcd, storage: .staticStorage))
        ])
        symbols.stackFrameIndex = 1
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.As(expr: Expression.Identifier("foo"),
                                                        targetType: Expression.PointerType(Expression.PrimitiveType(.constU16))))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0xabcd)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr1")
    }
    
    func testExpr_Group() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.Group(Expression.LiteralBool(false)))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Unary_minus_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Unary(op: .minus, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLI8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: Tack.kSUB8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Unary_minus_u16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Unary(op: .minus, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: Tack.kSUB16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr3")
    }
    
    func testExpr_Unary_bang_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool, offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Unary(op: .bang, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kNOT, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr3")
    }
    
    func testExpr_Unary_tilde_u8() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Unary(op: .tilde, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kNEG8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr3")
    }
    
    func testExpr_Unary_tilde_u16() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Unary(op: .tilde, expression: Expression.Identifier("foo")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kNEG16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr2")
    }
    
    func testExpr_Unary_addressOf_Function() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .function(FunctionType(name: "foo", mangledName: "foo", returnType: .void, arguments: []))))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo")))
        let expected = InstructionNode(instruction: Tack.kLA, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterIdentifier(value: "foo"),
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Unary_addressOf_Identifier() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo")))
        let expected = InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 100)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_add16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .plus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kADD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_sub16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .minus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kSUB16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_mul16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .star, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kMUL16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_div16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .divide, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kDIV16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_mod16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .modulus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kMOD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_lsl16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .leftDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLSL16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_lsr16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .rightDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLSR16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_and16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ampersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kAND16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_or16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .pipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kOR16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_xor16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .caret, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kXOR16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_eq16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kEQ16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_ne16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kNE16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_lt16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .lt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLT16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_ge16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ge, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kGE16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_le16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .le, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLE16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_gt16() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u16, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u16, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .gt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kGT16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_add8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .plus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kADD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_sub8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .minus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kSUB8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_mul8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .star, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kMUL8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_div8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .divide, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kDIV8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_mod8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .modulus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kMOD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_lsl8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .leftDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLSL8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_lsr8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .rightDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLSR8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_and8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ampersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kAND8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_or8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .pipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kOR8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_xor8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .caret, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kXOR8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_eq8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kEQ8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_ne8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kNE8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_lt8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .lt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLT8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_ge8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ge, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kGE8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_le8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .le, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kLE8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_gt8() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .u8, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .u8, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .gt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kGT8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_comptime_eq() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_ne() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_lt() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(2)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .lt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_gt() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(2))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .gt, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_le() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .le, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_ge() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ge, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_add() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .plus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 2)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_sub() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .minus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_mul() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .star, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_div() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(1))),
            ("right", Symbol(type: .compTimeInt(1)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .divide, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_mod() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(3))),
            ("right", Symbol(type: .compTimeInt(2)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .modulus, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_and() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(0xab))),
            ("right", Symbol(type: .compTimeInt(0x0f)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ampersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0xb)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_or() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(0xab))),
            ("right", Symbol(type: .compTimeInt(0x0f)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .pipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0xaf)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_xor() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(0xab))),
            ("right", Symbol(type: .compTimeInt(0xab)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .caret, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_lsl() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(2))),
            ("right", Symbol(type: .compTimeInt(2)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .leftDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 8)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_lsr() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeInt(8))),
            ("right", Symbol(type: .compTimeInt(2)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .rightDoubleAngle, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 2)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_eq_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kEQ16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_ne_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kNE16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr1")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_logical_and() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .doubleAmpersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kBZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: ".L0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kBZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: ".L0")
            ])),
            InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterNumber(value: 1)
            ])),
            InstructionNode(instruction: Tack.kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: ".L1")
            ])),
            LabelDeclaration(identifier: ".L0"),
            InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterNumber(value: 0)
            ])),
            LabelDeclaration(identifier: ".L1")
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_logical_or() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .bool, offset: 100, storage: .staticStorage)),
            ("right", Symbol(type: .bool, offset: 200, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .doublePipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0")
            ])),
            InstructionNode(instruction: Tack.kBNZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: ".L0")
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterNumber(value: 200)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2")
            ])),
            InstructionNode(instruction: Tack.kBNZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: ".L0")
            ])),
            InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: Tack.kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: ".L1")
            ])),
            LabelDeclaration(identifier: ".L0"),
            InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr4"),
                ParameterNumber(value: 1)
            ])),
            LabelDeclaration(identifier: ".L1")
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr4")
    }
    
    func testExpr_Binary_comptime_bool_eq() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeBool(true))),
            ("right", Symbol(type: .compTimeBool(true)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .eq, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_bool_ne() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeBool(true))),
            ("right", Symbol(type: .compTimeBool(true)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .ne, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_bool_and() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeBool(true))),
            ("right", Symbol(type: .compTimeBool(true)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .doubleAmpersand, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Binary_comptime_bool_or() throws {
        let symbols = SymbolTable(tuples: [
            ("left", Symbol(type: .compTimeBool(true))),
            ("right", Symbol(type: .compTimeBool(true)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Binary(op: .doublePipe, left: Expression.Identifier("left"), right: Expression.Identifier("right")))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Is_comptime_bool() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .compTimeBool(true)))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Is(expr: Expression.Identifier("foo"), testType: Expression.PrimitiveType(.compTimeBool(true))))
        let expected = InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_Is_test_union_type_tag() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.u8, .bool])), offset: 100, storage: .staticStorage))
        ])
        let compiler = makeCompiler(symbols: symbols)
        let actual = try compiler.compile(Expression.Is(expr: Expression.Identifier("foo"), testType: Expression.PrimitiveType(.bool)))
        let expected = Seq(children: [
            InstructionNode(instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 1)
            ])),
            InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterNumber(value: 100)
            ])),
            InstructionNode(instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr1")
            ])),
            InstructionNode(instruction: Tack.kEQ16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr3"),
                ParameterIdentifier(value: "vr2"),
                ParameterIdentifier(value: "vr0")
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr3")
    }
}
