//
//  SnapToTurtle16CompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore
import Turtle16SimulatorCore

class SnapToTurtle16CompilerTests: XCTestCase {
    func makeCompiler(symbols: SymbolTable = SymbolTable()) -> SnapToTurtle16Compiler {
        return SnapToTurtle16Compiler(symbols: symbols, globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()))
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
        XCTAssertEqual(result, InstructionNode(instruction: kJMP, parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")])))
    }
    
    func testGotoIfFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(GotoIfFalse(condition: Expression.LiteralBool(false), target: "foo"))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: kCMPI, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: kBEQ, parameters: ParameterList(parameters: [
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
            InstructionNode(instruction: kLEAVE),
            InstructionNode(instruction: kRET)
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
            InstructionNode(instruction: kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "__foo_tail")
            ])),
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: kENTER, parameters: ParameterList(parameters: [
                ParameterNumber(value: 0)
            ])),
            InstructionNode(instruction: kLEAVE),
            InstructionNode(instruction: kRET),
            LabelDeclaration(identifier: "__foo_tail"),
        ])
        XCTAssertEqual(actual, expected)
    }
    
    func testExpr_LiteralBoolFalse() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralBool(false))
        let expected = InstructionNode(instruction: kLI, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 0)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralBoolTrue() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralBool(true))
        let expected = InstructionNode(instruction: kLI, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralInt_Small_Positive() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralInt(1))
        let expected = InstructionNode(instruction: kLI, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: 1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralInt_Small_Negative() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralInt(-1))
        let expected = InstructionNode(instruction: kLI, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: "vr0"),
            ParameterNumber(value: -1)
        ]))
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr0")
    }
    
    func testExpr_LiteralInt_Big() throws {
        let compiler = makeCompiler()
        let actual = try compiler.compile(Expression.LiteralInt(0x1000))
        let expected = InstructionNode(instruction: kLI, parameters: ParameterList(parameters: [
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
            InstructionNode(instruction: kLIU, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterNumber(value: offset)
            ])),
            InstructionNode(instruction: kLOAD, parameters: ParameterList(parameters: [
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
            InstructionNode(instruction: kSUBI, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr0"),
                ParameterIdentifier(value: "fp"),
                ParameterNumber(value: offset)
            ])),
            InstructionNode(instruction: kLOAD, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: "vr1"),
                ParameterIdentifier(value: "vr0"),
            ]))
        ])
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(compiler.registerStack.last, "vr1")
    }
}
