//
//  ImplScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class ImplScannerTests: XCTestCase {
    func testExample() throws {
        let symbols = Env()
        
        let foo = StructDeclaration(
            identifier: Identifier("Foo"),
            members: [],
            visibility: .privateVisibility)
        let functionSymbols = Env(
            parent: symbols,
            frameLookupMode: .set(Frame()))
        let functionBodySymbols = Env(
            parent: functionSymbols,
            frameLookupMode: .inherit)
        let impl = Impl(
            typeArguments: [],
            structTypeExpr: Identifier("Foo"),
            children: [
                FunctionDeclaration(
                    identifier: Identifier("bar"),
                    functionType: FunctionType(
                        name: "bar",
                        returnType: PrimitiveType(.u8),
                        arguments: [
                            PointerType(Identifier("Foo"))
                        ]),
                    argumentNames: ["baz"],
                    typeArguments: [],
                    body: Block(
                        symbols: functionBodySymbols,
                        children: [
                            Return(LiteralInt(0))
                        ]),
                    symbols: functionSymbols)
            ])
        
        _ = try StructScanner(
            symbols: symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyNull())
        .compile(foo)
        
        try ImplScanner(
            memoryLayoutStrategy: MemoryLayoutStrategyNull(),
            symbols: symbols)
        .scan(impl: impl)
        
        let fooType = try symbols.resolveType(identifier: "Foo")
        let funTyp = try fooType
            .maybeUnwrapStructType()?
            .symbols
            .resolve(identifier: "bar")
            .type
            .maybeUnwrapFunctionType()
        
        XCTAssertEqual(funTyp?.name, "bar")
        XCTAssertEqual(funTyp?.arguments, [.pointer(fooType)])
        XCTAssertEqual(funTyp?.returnType, .u8)
    }
    
    func testRedefinesExistingSymbol() throws {
        let symbols = Env()
        
        let foo = StructDeclaration(
            identifier: Identifier("Foo"),
            members: [
                StructDeclaration.Member(
                    name: "bar",
                    type: PrimitiveType(.u8))
            ],
            visibility: .privateVisibility)
        _ = try StructScanner(
            symbols: symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyNull())
        .compile(foo)
        
        let functionSymbols = Env(parent: symbols, frameLookupMode: .set(Frame()))
        
        let functionBodySymbols = Env(parent: functionSymbols, frameLookupMode: .inherit)
        
        let impl = Impl(
            typeArguments: [],
            structTypeExpr: Identifier("Foo"),
            children: [
                FunctionDeclaration(
                    identifier: Identifier("bar"),
                    functionType: FunctionType(
                        name: "bar",
                        returnType: PrimitiveType(.u8),
                        arguments: [
                            PointerType(Identifier("Foo"))
                        ]),
                    argumentNames: ["baz"],
                    typeArguments: [],
                    body: Block(
                        symbols: functionBodySymbols,
                        children: [
                            Return(LiteralInt(0))
                        ]),
                    symbols: functionSymbols)
            ])
        
        let scanner = ImplScanner(
            memoryLayoutStrategy: MemoryLayoutStrategyNull(),
            symbols: symbols)
        XCTAssertThrowsError(try scanner.scan(impl: impl)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `bar'")
        }
    }
    
    // The methods declared in an Impl block exist only in the current scope.
    // When execution exits the scope, the methods disappear in the same manner
    // as any other type or symbol defined within that scope.
    func testImplScoping() throws {
        
        let outerBlock = Block(children: [
                StructDeclaration(
                    identifier: Identifier("Foo"),
                    members: [],
                    visibility: .privateVisibility),
                Block(children: [
                    Impl(
                        typeArguments: [],
                        structTypeExpr: Identifier("Foo"),
                        children: [
                            FunctionDeclaration(
                                identifier: Identifier("bar"),
                                functionType: FunctionType(
                                    name: "bar",
                                    returnType: PrimitiveType(.u8),
                                    arguments: [
                                        PointerType(Identifier("Foo"))
                                    ]),
                                argumentNames: ["baz"],
                                typeArguments: [],
                                body: Block(children: [
                                    Return(LiteralInt(0))
                                ]))
                        ])
                ])
            ])
            .reconnect(parent: nil)
        
        let foo = outerBlock.children[0] as! StructDeclaration
        let innerBlock = outerBlock.children[1] as! Block
        let impl = innerBlock.children[0] as! Impl
        
        _ = try StructScanner(
            symbols: outerBlock.symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyNull())
        .compile(foo)
        
        try ImplScanner(
            memoryLayoutStrategy: MemoryLayoutStrategyNull(),
            symbols: innerBlock.symbols)
        .scan(impl: impl)
        
        innerBlock.symbols.performDeferredActions()
        
        XCTAssertThrowsError(try outerBlock
            .symbols
            .resolveType(identifier: "Foo")
            .maybeUnwrapStructType()?
            .symbols
            .resolve(identifier: "bar")
        ) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "use of unresolved identifier: `bar'")
        }
    }
}
