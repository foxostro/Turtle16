//
//  SnapSubcompilerVarDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerVarDeclarationTests: XCTestCase {
    func testDeclareVariable_StaticStorage() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.PrimitiveType(.u8),
                                   expression: nil,
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constU8,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariable_AutomaticStorage() throws {
        let symbols = SymbolTable()
        symbols.stackFrameIndex = 1
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.PrimitiveType(.u8),
                                   expression: nil,
                                   storage: .automaticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constU8,
                                    offset: 1,
                                    storage: .automaticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testConstantRedefinesExistingSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.PrimitiveType(.u8),
                                   expression: nil,
                                   storage: .staticStorage,
                                   isMutable: false)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "constant redefines existing symbol: `foo\'")
        }
    }
    
    func testVariableRedefinesExistingSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.PrimitiveType(.u8),
                                   expression: nil,
                                   storage: .staticStorage,
                                   isMutable: true)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "variable redefines existing symbol: `foo\'")
        }
    }
    
    func testDeclareVariableWithExpressionAndExplicitType() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.PrimitiveType(.constU8),
                                   expression: Expression.LiteralInt(0),
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        let expected = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                    rexpr: Expression.LiteralInt(0))
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constU8,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeU8_mutableVariable() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: nil,
                                   expression: Expression.LiteralInt(0),
                                   storage: .staticStorage,
                                   isMutable: true)
        let actual = try? compiler.compile(input)
        let expected = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                    rexpr: Expression.LiteralInt(0))
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .u8,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeU8() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: nil,
                                   expression: Expression.LiteralInt(0),
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        let expected = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                    rexpr: Expression.LiteralInt(0))
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constU8,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeU16() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: nil,
                                   expression: Expression.LiteralInt(1000),
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        let expected = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                    rexpr: Expression.LiteralInt(1000))
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constU16,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeBool() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: nil,
                                   expression: Expression.LiteralBool(true),
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        let expected = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                    rexpr: Expression.LiteralBool(true))
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constBool,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_structInitializer() throws {
        let symbols = SymbolTable()
        let typ = StructType(name: "bar", symbols: SymbolTable())
        symbols.bind(identifier: "bar", symbolType: .structType(typ))
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: nil,
                                   expression: Expression.StructInitializer(identifier: Expression.Identifier("bar"), arguments: []),
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        let expected = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                    rexpr: Expression.StructInitializer(identifier: Expression.Identifier("bar"), arguments: []))
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constStructType(typ),
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExplicitTypeButNoExpression_immutable() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.PrimitiveType(.constU8),
                                   expression: nil,
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .constU8,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExplicitTypeButNoExpression_mutable() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.PrimitiveType(.u8),
                                   expression: nil,
                                   storage: .staticStorage,
                                   isMutable: true)
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .u8,
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testUnableToDeduceTypeOfConstant() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: nil,
                                   expression: nil,
                                   storage: .staticStorage,
                                   isMutable: false)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "unable to deduce type of constant `foo'")
        }
    }
    
    func testUnableToDeduceTypeOfVariable() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: nil,
                                   expression: nil,
                                   storage: .staticStorage,
                                   isMutable: true)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "unable to deduce type of variable `foo'")
        }
    }
    
    func testDeclareVariableWithExpressionAndExplicitType_literalArray() throws {
        let symbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
        let arrayExpr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)), elements: [Expression.LiteralInt(0)])
        let input = VarDeclaration(identifier: Expression.Identifier("foo"),
                                   explicitType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)),
                                   expression: arrayExpr,
                                   storage: .staticStorage,
                                   isMutable: false)
        let actual = try? compiler.compile(input)
        let expected = Expression.InitialAssignment(lexpr: Expression.Identifier("foo"),
                                                    rexpr: arrayExpr)
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .array(count: 1, elementType: .constU8),
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
}
