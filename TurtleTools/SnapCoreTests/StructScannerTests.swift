//
//  StructScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class StructScannerTests: XCTestCase {
    fileprivate let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()

    fileprivate func makeCompiler(_ symbols: Env) -> StructScanner {
        StructScanner(
            symbols: symbols,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
    }

    func testStructDeclarationMayNotRedefineExistingSymbol() throws {
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(
                type: .void,
                storage: .staticStorage(offset: 0),
                visibility: .privateVisibility
            )
        )
        let input = StructDeclaration(
            identifier: Identifier("foo"),
            members: []
        )
        let compiler = makeCompiler(symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "struct declaration redefines existing symbol: `foo'")
        }
    }

    func testStructDeclarationMayNotRedefineExistingType() throws {
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbolType: .void,
            visibility: .privateVisibility
        )
        let input = StructDeclaration(
            identifier: Identifier("foo"),
            members: []
        )
        let compiler = makeCompiler(symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "struct declaration redefines existing type: `foo'")
        }
    }

    func testGenericStructDeclarationMayNotRedefineExistingSymbol() throws {
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(
                type: .void,
                storage: .staticStorage(offset: 0),
                visibility: .privateVisibility
            )
        )
        let input = StructDeclaration(
            identifier: Identifier("foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: []
        )
        let compiler = makeCompiler(symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "struct declaration redefines existing symbol: `foo'")
        }
    }

    func testGenericStructDeclarationMayNotRedefineExistingType() throws {
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbolType: .void,
            visibility: .privateVisibility
        )
        let input = StructDeclaration(
            identifier: Identifier("foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: []
        )
        let compiler = makeCompiler(symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "struct declaration redefines existing type: `foo'")
        }
    }

    func testEmptyStruct() throws {
        let symbols = Env()
        let input = StructDeclaration(identifier: Identifier("None"), members: [])
        XCTAssertNoThrow(try makeCompiler(symbols).compile(input))
        let expectedStructSymbols = Env()
        expectedStructSymbols.frameLookupMode = .set(Frame())
        expectedStructSymbols.breadcrumb = .structType("None")
        let expectedType: SymbolType = .structType(
            StructTypeInfo(name: "None", fields: expectedStructSymbols)
        )
        let actualType = try? symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }

    func testConstStruct() throws {
        let symbols = Env()
        let input = StructDeclaration(
            identifier: Identifier("None"),
            members: [],
            isConst: true
        )
        XCTAssertNoThrow(try makeCompiler(symbols).compile(input))
        let expectedStructSymbols = Env()
        expectedStructSymbols.frameLookupMode = .set(Frame())
        expectedStructSymbols.breadcrumb = .structType("None")
        let expectedType: SymbolType = .constStructType(
            StructTypeInfo(name: "None", fields: expectedStructSymbols)
        )
        let actualType = try? symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }

    func testStructWithOneMember() throws {
        let symbols = Env()
        let input = StructDeclaration(
            identifier: Identifier("Foo"),
            members: [
                StructDeclaration.Member(name: "bar", type: PrimitiveType(.u8))
            ]
        )
        XCTAssertNoThrow(try makeCompiler(symbols).compile(input))
        let bar = Symbol(
            type: .u8,
            storage: .automaticStorage(offset: 0)
        )
        let expectedStructSymbols = Env(tuples: [
            ("bar", bar)
        ])
        expectedStructSymbols.breadcrumb = .structType("Foo")
        let frame = Frame()
        _ = frame.allocate(size: 1)
        frame.add(identifier: "bar", symbol: bar)
        expectedStructSymbols.frameLookupMode = .set(frame)
        let expectedType: SymbolType = .structType(
            StructTypeInfo(name: "Foo", fields: expectedStructSymbols)
        )
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }

    func testStructCannotContainItselfRecursively() throws {
        let symbols = Env()
        let input = StructDeclaration(
            identifier: Identifier("Foo"),
            members: [
                StructDeclaration.Member(name: "bar", type: Identifier("Foo"))
            ]
        )
        let compiler = makeCompiler(symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "a struct cannot contain itself recursively")
        }
    }

    func testGenericStruct() throws {
        let symbols = Env()
        let input = StructDeclaration(
            identifier: Identifier("Foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: []
        )
        try makeCompiler(symbols).compile(input)
        let actualType = try symbols.resolveType(identifier: "Foo")

        let expectedStructSymbols = Env()
        expectedStructSymbols.breadcrumb = .structType("Foo")
        let expectedType: SymbolType = .genericStructType(GenericStructTypeInfo(template: input))

        XCTAssertEqual(actualType, expectedType)
    }
}
