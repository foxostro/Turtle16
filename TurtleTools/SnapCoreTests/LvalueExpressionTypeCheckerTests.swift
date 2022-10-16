//
//  LvalueExpressionTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class LvalueExpressionTypeCheckerTests: XCTestCase {
    func testIdentifier_U16() {
        XCTAssertEqual(checkIdentifier(type: .arithmeticType(.mutableInt(.u16))), .arithmeticType(.mutableInt(.u16)))
    }
    
    func testIdentifier_U8() {
        XCTAssertEqual(checkIdentifier(type: .arithmeticType(.mutableInt(.u8))), .arithmeticType(.mutableInt(.u8)))
    }
    
    func testIdentifier_Bool() {
        XCTAssertEqual(checkIdentifier(type: .bool(.mutableBool)), .bool(.mutableBool))
    }
    
    func testIdentifier_ArrayOfU8() {
        XCTAssertEqual(checkIdentifier(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u8)))),
                       .array(count: 1, elementType: .arithmeticType(.mutableInt(.u8))))
    }
    
    fileprivate func checkIdentifier(type symbolType: SymbolType) -> SymbolType? {
        let ident = "foo"
        let symbols = SymbolTable(tuples: [
            (ident, Symbol(type: symbolType, offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(ident)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        return result
    }
    
    func testExpressionHasNoLvalue_ConstInt() {
        let expr = Expression.LiteralInt(0)
        let typeChecker = LvalueExpressionTypeChecker()
        XCTAssertNil(try typeChecker.check(expression: expr))
    }
    
    func testArraySubscriptYieldsMutableReferenceToArrayElement() {
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(0))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u8))), offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testWeCanTakeTheLvalueOfAConstantArray() {
        // It's legal to take the lvalue of a constant array. It's illegal to
        // then assign to that address. However, the lvalue expression type
        // checker doesn't concern itself with that policy.
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(1))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 2, elementType: .arithmeticType(.immutableInt(.u16))), offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var lvalue: SymbolType? = nil
        XCTAssertNoThrow(lvalue = try typeChecker.check(expression: expr))
        XCTAssertEqual(lvalue, .arithmeticType(.immutableInt(.u16)))
    }
    
    func testCannotTakeTheLvalueOfTheArrayCountProperty() {
        let expr = Expression.Get(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                                                                elements: [ExprUtils.makeU8(value: 0),
                                                                           ExprUtils.makeU8(value: 1),
                                                                           ExprUtils.makeU8(value: 2)]),
                                  member: Expression.Identifier("count"))
        
        let typeChecker = LvalueExpressionTypeChecker()
        var lvalue: SymbolType? = nil
        XCTAssertNoThrow(lvalue = try typeChecker.check(expression: expr))
        XCTAssertNil(lvalue)
    }
    
    func testGetLvalueOfNonexistentMemberOfStruct() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, storage: .automaticStorage)),
            ("baz", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
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
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, storage: .automaticStorage)),
            ("baz", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testGetLvalueOfSecondMemberOfStruct() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("baz"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, storage: .automaticStorage)),
            ("baz", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .structType(typ), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testLvalueOfPointerToU8() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u8))), offset: 0x0100)),
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0102))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.arithmeticType(.mutableInt(.u8))))
    }
    
    func testDereferencePointerToU8() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("pointee"))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.mutableInt(.u8))), offset: 0x0100)),
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0x0102))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testGetLvalueOfNonexistentMemberOfStructThroughPointer() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let offset = 0x0100
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, storage: .automaticStorage)),
            ("baz", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
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
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let offset = 0x0100
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, storage: .automaticStorage)),
            ("baz", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.structType(typ)), offset: offset))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testGetLvalueOfUnion() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.arithmeticType(.mutableInt(.u16))])), offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier("foo")
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .unionType(UnionType([.arithmeticType(.mutableInt(.u16))])))
    }
    
    func testBitcast() throws {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u8))), offset: 0x0010))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Bitcast(expr: Expression.Identifier("foo"), targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        let result: SymbolType? = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testGetLvalueOfStructMemberThroughGetOnLiteralStructInitializer() throws {
        let si = Expression.StructInitializer(identifier: Expression.Identifier("Foo"), arguments: [
            Expression.StructInitializer.Argument(name: "bar", expr: Expression.Identifier("foo"))
        ])
        let expr = Expression.Get(expr: si, member: Expression.Identifier("bar"))
        let typ = StructType(name: "Foo", symbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage))
        ]))
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0))
        ], typeDict: [
            "Foo" : .structType(typ)
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let result = try typeChecker.check(expression: expr)
        XCTAssertEqual(result, .arithmeticType(.mutableInt(.u16)))
    }
    
    func testSizeOfHasNoLvalue() {
        let typeChecker = LvalueExpressionTypeChecker()
        let expr = Expression.SizeOf(ExprUtils.makeU8(value: 1))
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertNil(result)
    }
    
    func testCannotInstantiateGenericFunctionTypeWithoutApplication() throws {
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.Identifier("T")],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(identifier: Expression.Identifier("foo"))) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot instantiate generic function `func foo<T>(a: T) -> T'")
        }
    }
    
    func testGenericFunctionApplication() throws {
        let constU16 = SymbolType.arithmeticType(.immutableInt(.u16))
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.Identifier("T")],
                                           body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .genericFunction(genericFunctionType)))
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols, functionsToCompile: FunctionsToCompile())
        let expr = Expression.GenericTypeApplication(identifier: Expression.Identifier("foo"),
                                                     arguments: [Expression.PrimitiveType(constU16)])
        let expected = SymbolType.function(FunctionType(name: "foo",
                                                        mangledName: "foo_const_u16",
                                                        returnType: constU16,
                                                        arguments: [constU16],
                                                        ast: nil))
        let actual = try typeChecker.check(expression: expr)
        XCTAssertEqual(actual, expected)
    }
}
