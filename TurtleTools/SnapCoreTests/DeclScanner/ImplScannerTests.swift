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
    let u8: SymbolType = .arithmeticType(.mutableInt(.u8))
    typealias Identifier = Expression.Identifier
    typealias PrimitiveType = Expression.PrimitiveType
    typealias PointerType = Expression.PointerType
    typealias LiteralInt = Expression.LiteralInt
    
    func testExample() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment()
        
        let foo = StructDeclaration(
            identifier: Identifier("Foo"),
            members: [],
            visibility: .privateVisibility)
        let functionSymbols = SymbolTable(
            parent: symbols,
            frameLookupMode: .set(Frame()))
        let functionBodySymbols = SymbolTable(
            parent: functionSymbols,
            frameLookupMode: .inherit)
        let impl = Impl(
            typeArguments: [],
            structTypeExpr: Identifier("Foo"),
            children: [
                FunctionDeclaration(
                    identifier: Identifier("bar"),
                    functionType: Expression.FunctionType(
                        name: "bar",
                        returnType: PrimitiveType(u8),
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
        
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(foo)
        
        try ImplScanner(
            globalEnvironment: globalEnvironment,
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
        XCTAssertEqual(funTyp?.returnType, u8)
    }
    
    func testRedefinesExistingSymbol() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment()
        
        let foo = StructDeclaration(
            identifier: Identifier("Foo"),
            members: [
                StructDeclaration.Member(
                    name: "bar",
                    type: PrimitiveType(.arithmeticType(.mutableInt(.u8))))
            ],
            visibility: .privateVisibility)
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(foo)
        
        let functionSymbols = SymbolTable(parent: symbols, frameLookupMode: .set(Frame()))
        
        let functionBodySymbols = SymbolTable(parent: functionSymbols, frameLookupMode: .inherit)
        
        let impl = Impl(
            typeArguments: [],
            structTypeExpr: Identifier("Foo"),
            children: [
                FunctionDeclaration(
                    identifier: Identifier("bar"),
                    functionType: Expression.FunctionType(
                        name: "bar",
                        returnType: PrimitiveType(u8),
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
        
        let scanner = ImplScanner(globalEnvironment: globalEnvironment, symbols: symbols)
        XCTAssertThrowsError(try scanner.scan(impl: impl)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `bar'")
        }
    }
    
    // The methods declared in an Impl block exist only in the current scope.
    // When execution exits the scope, the methods disappear in the same manner
    // as any other type or symbol defined within that scope.
    func testImplScoping() throws {
        let globalEnvironment = GlobalEnvironment()
        
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
                                functionType: Expression.FunctionType(
                                    name: "bar",
                                    returnType: PrimitiveType(u8),
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
        
        _ = try SnapSubcompilerStructDeclaration(
            symbols: outerBlock.symbols,
            globalEnvironment: globalEnvironment)
        .compile(foo)
        
        try ImplScanner(
            globalEnvironment: globalEnvironment,
            symbols: innerBlock.symbols)
            .scan(impl: impl)
        
        let tryResolveBar = { (block: Block) in
            _ = try block
                .symbols
                .resolveType(identifier: "Foo")
                .maybeUnwrapStructType()?
                .symbols
                .resolve(identifier: "bar")
        }
        
        XCTAssertNoThrow(try tryResolveBar(innerBlock))
        XCTAssertThrowsError(try tryResolveBar(outerBlock)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "use of unresolved identifier: `bar'")
        }
    }
}
