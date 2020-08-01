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
        let expr = Expression.Identifier(sourceAnchor: nil, identifier: ident)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        return result
    }
    
    func testExpressionIsNotAssignable_ConstInt() {
        let expr = Expression.LiteralWord(sourceAnchor: nil, value: 0)
        let typeChecker = LvalueExpressionTypeChecker()
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "expression is not assignable")
        }
    }
    
    func testArraySubscriptYieldsMutableReferenceToArrayElement() {
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralWord(sourceAnchor: nil, value: 0))
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010, isMutable: true)])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .u8)
    }
    
    func testElementsOfImmutableArraysCannotBeModified() {
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralWord(sourceAnchor: nil, value: 0))
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010, isMutable: false)])
        let typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        XCTAssertThrowsError(try typeChecker.check(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "expression is not assignable: `foo' is immutable")
        }
    }
}
