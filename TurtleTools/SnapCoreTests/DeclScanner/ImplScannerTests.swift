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
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment()
        
        let foo = StructDeclaration(
            identifier: Expression.Identifier("Foo"),
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
            structTypeExpr: Expression.Identifier("Foo"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("bar"),
                    functionType: Expression.FunctionType(
                        name: "bar",
                        returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("Foo"))
                        ]),
                    argumentNames: ["baz"],
                    typeArguments: [],
                    body: Block(
                        symbols: functionBodySymbols,
                        children: [
                            Return(Expression.LiteralInt(0))
                        ]),
                    symbols: functionSymbols)
            ])
        
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(foo)
        
        let scanner = ImplScanner(globalEnvironment: globalEnvironment, symbols: symbols)
        try scanner.scan(impl: impl)
        
        let fooType = try symbols.resolveType(identifier: "Foo")
        let fooStructType: StructType? = switch fooType {
        case .structType(let typ):
            typ
        default:
            nil
        }
        let barTyp = try fooStructType?.symbols.resolve(identifier: "bar").type
        let funTyp: FunctionType? = switch barTyp {
        case .function(let typ):
            typ
        default:
            nil
        }
        
        XCTAssertEqual(funTyp?.name, "bar")
        XCTAssertEqual(funTyp?.arguments, [.pointer(fooType)])
        XCTAssertEqual(funTyp?.returnType, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testRedefinesExistingSymbol() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment()
        
        let foo = StructDeclaration(
            identifier: Expression.Identifier("Foo"),
            members: [
                StructDeclaration.Member(
                    name: "bar",
                    type: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
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
            structTypeExpr: Expression.Identifier("Foo"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("bar"),
                    functionType: Expression.FunctionType(
                        name: "bar",
                        returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("Foo"))
                        ]),
                    argumentNames: ["baz"],
                    typeArguments: [],
                    body: Block(
                        symbols: functionBodySymbols,
                        children: [
                            Return(Expression.LiteralInt(0))
                        ]),
                    symbols: functionSymbols)
            ])
        
        let scanner = ImplScanner(globalEnvironment: globalEnvironment, symbols: symbols)
        XCTAssertThrowsError(try scanner.scan(impl: impl)) {
            
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `bar'")
        }
    }
}
