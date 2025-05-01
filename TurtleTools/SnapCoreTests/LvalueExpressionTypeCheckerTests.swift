//
//  LvalueExpressionTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class LvalueExpressionTypeCheckerTests: XCTestCase {
    func testIdentifier_U16() {
        XCTAssertEqual(checkIdentifier(type: .u16), .u16)
    }

    func testIdentifier_U8() {
        XCTAssertEqual(checkIdentifier(type: .u8), .u8)
    }

    func testIdentifier_Bool() {
        XCTAssertEqual(checkIdentifier(type: .bool), .bool)
    }

    func testIdentifier_ArrayOfU8() {
        XCTAssertEqual(
            checkIdentifier(type: .array(count: 1, elementType: .u8)),
            .array(count: 1, elementType: .u8)
        )
    }

    fileprivate func checkIdentifier(type symbolType: SymbolType) -> SymbolType? {
        let ident = "foo"
        let symbols = Env(tuples: [
            (ident, Symbol(type: symbolType, offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let expr = Identifier(ident)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        return result
    }

    func testExpressionHasNoLvalue_ConstInt() {
        let expr = LiteralInt(0)
        let typeChecker = LvalueExpressionTypeChecker()
        XCTAssertNil(try typeChecker.check(expression: expr))
    }

    func testArraySubscriptYieldsMutableReferenceToArrayElement() {
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: LiteralInt(0))
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testWeCanTakeTheLvalueOfAConstantArray() {
        // It's legal to take the lvalue of a constant array. It's illegal to
        // then assign to that address. However, the lvalue expression type
        // checker doesn't concern itself with that policy.
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: LiteralInt(1))
        let symbols = Env(tuples: [
            (
                "foo",
                Symbol(
                    type: .array(count: 2, elementType: .arithmeticType(.immutableInt(.u16))),
                    offset: 0x0010
                )
            )
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var lvalue: SymbolType? = nil
        XCTAssertNoThrow(lvalue = try typeChecker.check(expression: expr))
        XCTAssertEqual(lvalue, .arithmeticType(.immutableInt(.u16)))
    }

    func testCannotTakeTheLvalueOfTheArrayCountProperty() {
        let expr = Get(
            expr: LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [
                    ExprUtils.makeU8(value: 0),
                    ExprUtils.makeU8(value: 1),
                    ExprUtils.makeU8(value: 2),
                ]
            ),
            member: Identifier("count")
        )

        let typeChecker = LvalueExpressionTypeChecker()
        var lvalue: SymbolType? = nil
        XCTAssertNoThrow(lvalue = try typeChecker.check(expression: expr))
        XCTAssertNil(lvalue)
    }

    func testGetLvalueOfNonexistentMemberOfStruct() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("asdf")
        )
        let offset = 0x0100
        let typ = StructTypeInfo(
            name: "foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u8, offset: 0, qualifier: .automaticStorage)),
                ("baz", Symbol(type: .u16, offset: 1, qualifier: .automaticStorage)),
            ])
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `foo' has no member `asdf'")
        }
    }

    func testGetLvalueOfFirstMemberOfStruct() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("bar")
        )
        let offset = 0x0100
        let typ = StructTypeInfo(
            name: "foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u8, offset: 0, qualifier: .automaticStorage)),
                ("baz", Symbol(type: .u16, offset: 1, qualifier: .automaticStorage)),
            ])
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testGetLvalueOfSecondMemberOfStruct() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("baz")
        )
        let offset = 0x0100
        let typ = StructTypeInfo(
            name: "foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u8, offset: 0, qualifier: .automaticStorage)),
                ("baz", Symbol(type: .u16, offset: 1, qualifier: .automaticStorage)),
            ])
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }

    func testLvalueOfPointerToU8() {
        let expr = Identifier("foo")
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.u8), offset: 0x0100)),
            ("bar", Symbol(type: .u8, offset: 0x0102)),
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
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
            ("foo", Symbol(type: .pointer(.u8), offset: 0x0100)),
            ("bar", Symbol(type: .u8, offset: 0x0102)),
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testGetLvalueOfNonexistentMemberOfStructThroughPointer() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("asdf")
        )
        let offset = 0x0100
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u8, offset: 0, qualifier: .automaticStorage)),
                ("baz", Symbol(type: .u16, offset: 1, qualifier: .automaticStorage)),
            ])
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.structType(typ)), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `*Foo' has no member `asdf'")
        }
    }

    func testGetLvalueOfFirstMemberOfStructThroughPointer() {
        let expr = Get(
            expr: Identifier("foo"),
            member: Identifier("bar")
        )
        let offset = 0x0100
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u8, offset: 0, qualifier: .automaticStorage)),
                ("baz", Symbol(type: .u16, offset: 1, qualifier: .automaticStorage)),
            ])
        )
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .pointer(.structType(typ)), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }

    func testGetLvalueOfUnion() {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .unionType(UnionTypeInfo([.u16])), offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let expr = Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .unionType(UnionTypeInfo([.u16])))
    }

    func testBitcast() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let expr = Bitcast(expr: Identifier("foo"), targetType: PrimitiveType(.u8))
        let result: SymbolType? = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .u8)
    }

    func testGetLvalueOfStructMemberThroughGetOnLiteralStructInitializer() throws {
        let si = StructInitializer(
            identifier: Identifier("Foo"),
            arguments: [
                StructInitializer.Argument(name: "bar", expr: Identifier("foo"))
            ]
        )
        let expr = Get(expr: si, member: Identifier("bar"))
        let typ = StructTypeInfo(
            name: "Foo",
            fields: Env(tuples: [
                ("bar", Symbol(type: .u16, offset: 0, qualifier: .automaticStorage))
            ])
        )
        let symbols = Env(
            tuples: [
                ("foo", Symbol(type: .u16, offset: 0))
            ],
            typeDict: [
                "Foo": .structType(typ)
            ]
        )
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .u16)
    }

    func testSizeOfHasNoLvalue() {
        let typeChecker = LvalueExpressionTypeChecker()
        let expr = SizeOf(ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertNil(result)
    }

    func testCannotInstantiateGenericFunctionTypeWithoutApplication() throws {
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
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(identifier: Identifier("foo"))) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot instantiate generic function `func foo[T](a: T) -> T'"
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
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
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
                ast: nil
            )
        )
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }

    func testEseq_Empty() throws {
        let expr = Eseq(children: [])
        let result = try LvalueExpressionTypeChecker().check(expression: expr)
        XCTAssertNil(result)
    }

    func testEseq_OneChild() throws {
        let ident = "foo"
        let symbols = Env(tuples: [
            (ident, Symbol(type: .u16, offset: 0x0010))
        ])
        let expr = Eseq(children: [
            Identifier("foo")
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .u16)
    }

    func testEseq_MultipleChildren() throws {
        let symbols = Env(tuples: [
            ("foo", Symbol(type: .u16)),
            ("bar", Symbol(type: .i16)),
        ])
        let expr = Eseq(children: [
            Identifier("bar"),
            Identifier("foo"),
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .u16)
    }
}
