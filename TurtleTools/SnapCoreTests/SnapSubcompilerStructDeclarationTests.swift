//
//  SnapSubcompilerStructDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerStructDeclarationTests: XCTestCase {
    fileprivate func makeCompiler(_ symbols: SymbolTable) -> SnapSubcompilerStructDeclaration {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        return SnapSubcompilerStructDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
    }
    
    func testEmptyStruct() throws {
        let symbols = SymbolTable()
        let input = StructDeclaration(identifier: Expression.Identifier("None"), members: [])
        XCTAssertNoThrow(try makeCompiler(symbols).compile(input))
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.stackFrameLookupMode = .set(Frame())
        expectedStructSymbols.enclosingFunctionNameMode = .set("None")
        let expectedType: SymbolType = .structType(StructType(name: "None", symbols: expectedStructSymbols))
        let actualType = try? symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testConstStruct() throws {
        let symbols = SymbolTable()
        let input = StructDeclaration(
            identifier: Expression.Identifier("None"),
            members: [],
            isConst: true)
        XCTAssertNoThrow(try makeCompiler(symbols).compile(input))
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.stackFrameLookupMode = .set(Frame())
        expectedStructSymbols.enclosingFunctionNameMode = .set("None")
        let expectedType: SymbolType = .constStructType(StructType(name: "None", symbols: expectedStructSymbols))
        let actualType = try? symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testStructWithOneMember() throws {
        let symbols = SymbolTable()
        let input = StructDeclaration(identifier: Expression.Identifier("Foo"), members: [
            StructDeclaration.Member(name: "bar", type: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])
        XCTAssertNoThrow(try makeCompiler(symbols).compile(input))
        let expectedStructSymbols = SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, storage: .automaticStorage))
        ])
        expectedStructSymbols.enclosingFunctionNameMode = .set("Foo")
        let frame = Frame()
        frame.bumpStoragePointer(1)
        expectedStructSymbols.stackFrameLookupMode = .set(frame)
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
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "a struct cannot contain itself recursively")
        }
    }
    
    func testGenericStruct() throws {
        let symbols = SymbolTable()
        let input = StructDeclaration(
            identifier: Expression.Identifier("Foo"),
            typeArguments: [
                Expression.GenericTypeArgument(
                    identifier: Expression.Identifier("T"),
                    constraints: [])
            ],
            members: [])
        try makeCompiler(symbols).compile(input)
        let actualType = try symbols.resolveType(identifier: "Foo")
        
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.enclosingFunctionNameMode = .set("Foo")
        let expectedType: SymbolType = .genericStructType(GenericStructType(template: input))
        
        XCTAssertEqual(actualType, expectedType)
    }
}
