//
//  SnapASTTransformerStructDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerStructDeclarationTests: XCTestCase {
    fileprivate func makeCompiler(_ symbols: SymbolTable) -> SnapASTTransformerStructDeclaration {
        return SnapASTTransformerStructDeclaration(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
    }
    
    func testIgnoresUnrecognizedNodes() throws {
        let symbols = SymbolTable()
        let result = try? makeCompiler(symbols).compile(CommentNode(string: ""))
        XCTAssertEqual(result, CommentNode(string: ""))
    }
    
    func testEmptyStruct() throws {
        let symbols = SymbolTable()
        let input = StructDeclaration(identifier: Expression.Identifier("None"), members: [])
        var result: AbstractSyntaxTreeNode?
        XCTAssertNoThrow(result = try makeCompiler(symbols).compile(struct: input))
        XCTAssertNil(result)
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.enclosingFunctionName = "None"
        let expectedType: SymbolType = .structType(StructType(name: "None", symbols: expectedStructSymbols))
        let actualType = try? symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testStructWithOneMember() throws {
        let symbols = SymbolTable()
        let input = StructDeclaration(identifier: Expression.Identifier("Foo"), members: [
            StructDeclaration.Member(name: "bar", type: Expression.PrimitiveType(.u8))
        ])
        var result: AbstractSyntaxTreeNode?
        XCTAssertNoThrow(result = try makeCompiler(symbols).compile(struct: input))
        XCTAssertNil(result)
        let expectedStructSymbols = SymbolTable(tuples: [
            ("bar", Symbol(type: .u8, offset: 0, storage: .automaticStorage))
        ])
        expectedStructSymbols.enclosingFunctionName = "Foo"
        expectedStructSymbols.storagePointer = 1
        let expectedType: SymbolType = .structType(StructType(name: "Foo", symbols: expectedStructSymbols))
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testStructCannotContainItselfRecursively() throws {
        let symbols = SymbolTable()
        let input = StructDeclaration(identifier: Expression.Identifier("Foo"), members: [
            StructDeclaration.Member(name: "bar", type: Expression.Identifier("Foo"))
        ])
        let compiler = makeCompiler(symbols)
        XCTAssertThrowsError(try compiler.compile(struct: input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "a struct cannot contain itself recursively")
        }
    }
}
