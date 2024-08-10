//
//  CompilerPassDecomposeVarDeclTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/5/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class CompilerPassDecomposeVarDeclTests: XCTestCase {
    
#if false
    func testDeclareVariable_StaticStorage() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false)
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariable_AutomaticStorage() throws {
        let symbols = SymbolTable()
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))),
                    expression: nil,
                    storage: .automaticStorage,
                    isMutable: false)
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                    expression: nil,
                    storage: .automaticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            offset: 1,
            storage: .automaticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testConstantRedefinesExistingSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false)
            ])
        
        let compiler = CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL()))
        
        XCTAssertThrowsError(try compiler.visit(ast0)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "constant redefines existing symbol: `foo\'")
        }
    }
    
    func testVariableRedefinesExistingSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: true)
            ])
        
        let compiler = CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL()))
        
        XCTAssertThrowsError(try compiler.visit(ast0)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "variable redefines existing symbol: `foo\'")
        }
    }
    
    func testDeclareVariableWithExpressionAndExplicitType() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false),
                Expression.InitialAssignment(
                    lexpr: Expression.Identifier("foo"),
                    rexpr: Expression.LiteralInt(0))
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))),
                    expression: Expression.LiteralInt(0),
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .arithmeticType(.immutableInt(.u8)),
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeU8_mutableVariable() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: true),
                Expression.InitialAssignment(
                    lexpr: Expression.Identifier("foo"),
                    rexpr: Expression.LiteralInt(0))
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: nil,
                    expression: Expression.LiteralInt(0),
                    storage: .staticStorage,
                    isMutable: true)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.mutableInt(.u8)),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeU8() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false),
                Expression.InitialAssignment(
                    lexpr: Expression.Identifier("foo"),
                    rexpr: Expression.LiteralInt(0))
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: nil,
                    expression: Expression.LiteralInt(0),
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeU16() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u16))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false),
                Expression.InitialAssignment(
                    lexpr: Expression.Identifier("foo"),
                    rexpr: Expression.LiteralInt(1000))
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: nil,
                    expression: Expression.LiteralInt(1000),
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u16)),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_compTimeBool() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.bool(.immutableBool)),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false),
                Expression.InitialAssignment(
                    lexpr: Expression.Identifier("foo"),
                    rexpr: Expression.LiteralBool(true))
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: nil,
                    expression: Expression.LiteralBool(true),
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(type: .bool(.immutableBool),
                                    offset: SnapCompilerMetrics.kStaticStorageStartAddress,
                                    storage: .staticStorage,
                                    visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExpression_structInitializer() throws {
        let symbols = SymbolTable()
        let typ = StructType(name: "bar", symbols: SymbolTable())
        symbols.bind(identifier: "bar", symbolType: .structType(typ))
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.constStructType(typ)),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false),
                Expression.InitialAssignment(
                    lexpr: Expression.Identifier("foo"),
                    rexpr: Expression.StructInitializer(
                        identifier: Expression.Identifier("bar"),
                        arguments: []))
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: nil,
                    expression: Expression.StructInitializer(identifier: Expression.Identifier("bar"), arguments: []),
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .constStructType(typ),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExplicitTypeButNoExpression_immutable() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false)
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.immutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithExplicitTypeButNoExpression_mutable() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: true)
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: true)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.mutableInt(.u8)),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testUnableToDeduceTypeOfConstant() throws {
        let symbols = SymbolTable()
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: nil,
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false)
            ])
        
        let compiler = CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL()))
        
        XCTAssertThrowsError(try compiler.visit(ast0)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "unable to deduce type of constant `foo'")
        }
    }
    
    func testUnableToDeduceTypeOfVariable() throws {
        let symbols = SymbolTable()
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: nil,
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: true)
            ])
        
        let compiler = CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL()))
        
        XCTAssertThrowsError(try compiler.visit(ast0)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "unable to deduce type of variable `foo'")
        }
    }
    
    func testDeclareVariableWithExpressionAndExplicitType_literalArray() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.array(count: 1, elementType: .arithmeticType(.immutableInt(.u8)))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: false),
                Expression.InitialAssignment(
                    lexpr: Expression.Identifier("foo"),
                    rexpr: Expression.LiteralArray(
                        arrayType: Expression.ArrayType(
                            count: Expression.LiteralInt(1),
                            elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                        elements: [Expression.LiteralInt(0)]))
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.ArrayType(
                        count: Expression.LiteralInt(1),
                        elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                    expression: Expression.LiteralArray(
                        arrayType: Expression.ArrayType(
                            count: Expression.LiteralInt(1),
                            elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                        elements: [Expression.LiteralInt(0)]),
                    storage: .staticStorage,
                    isMutable: false)
            ],
            id: expected.id)
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .array(count: 1, elementType: .arithmeticType(.immutableInt(.u8))),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
    
    func testDeclareVariableWithNoExpression() throws {
        let symbols = SymbolTable()
        
        let expected = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.PrimitiveType(.array(count: 1, elementType: .arithmeticType(.mutableInt(.u8)))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: true)
            ])
        
        let ast0 = Block(
            symbols: symbols,
            children: [
                VarDeclaration(
                    identifier: Expression.Identifier("foo"),
                    explicitType: Expression.ArrayType(
                        count: Expression.LiteralInt(1),
                        elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))),
                    expression: nil,
                    storage: .staticStorage,
                    isMutable: true)
            ])
        
        let ast1 = try CompilerPassDecomposeVarDecl(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())).visit(ast0)
        
        XCTAssertEqual(ast1, expected)
        
        let foo = try symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .array(count: 1, elementType: .arithmeticType(.mutableInt(.u8))),
            offset: SnapCompilerMetrics.kStaticStorageStartAddress,
            storage: .staticStorage,
            visibility: .privateVisibility)
        XCTAssertEqual(foo, expectedSymbol)
    }
#endif
    
}
