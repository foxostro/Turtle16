//
//  LvalueExpressionTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class LvalueExpressionTypeCheckerTests: XCTestCase {
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
        XCTAssertEqual(checkIdentifier(type: .array(count: 1, elementType: .u8)),
                       .array(count: 1, elementType: .u8))
    }
    
    fileprivate func checkIdentifier(type symbolType: SymbolType) -> SymbolType? {
        let ident = "foo"
        let symbols = SymbolTable([ident : Symbol(type: symbolType, offset: 0x0010, isMutable: false)])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        let expr = Expression.Identifier(ident)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        return result
    }
    
    func testExpressionIsNotAssignable_ConstInt() {
        let expr = Expression.LiteralInt(0)
        let typeChecker = LvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "expression is not assignable")
        }
    }
    
    func testArraySubscriptYieldsMutableReferenceToArrayElement() {
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(0))
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010, isMutable: true)])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testElementsOfConstantArraysCannotBeModified() {
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(0))
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010, isMutable: false)])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "expression is not assignable: `foo' is a constant")
        }
    }
    
    func testCannotAssignToTheArrayCountProperty() {
        let expr = Expression.Get(expr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                                elements: [ExprUtils.makeU8(value: 0),
                                                                           ExprUtils.makeU8(value: 1),
                                                                           ExprUtils.makeU8(value: 2)]),
                                  member: Expression.Identifier("count"))
        
        let typeChecker = LvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "expression is not assignable")
        }
    }
    
    func testGetLvalueOfNonexistentMemberOfStruct() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: offset, isMutable: true)
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
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: offset, isMutable: true)
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testGetLvalueOfSecondMemberOfStruct() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("baz"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: offset, isMutable: true)
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u16)
    }
    
    func testLvalueOfPointerToU8() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.u8), offset: 0x0100, isMutable: true),
            "bar" : Symbol(type: .u8, offset: 0x0102, isMutable: true)
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .pointer(.u8))
    }
    
    func testDereferencePointerToU8() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("pointee"))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.u8), offset: 0x0100, isMutable: true),
            "bar" : Symbol(type: .u8, offset: 0x0102, isMutable: true)
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testGetLvalueOfNonexistentMemberOfStructThroughPointer() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let offset = 0x0100
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.structType(typ)), offset: offset, isMutable: true)
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
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.structType(typ)), offset: offset, isMutable: true)
        ])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
}
