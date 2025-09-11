//
//  SnapSubcompilerVarDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class SnapSubcompilerVarDeclarationTests: XCTestCase {
    func testDeclareVariable_StaticStorage() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariable_AutomaticStorage() throws {
        let symbols = Env()
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL()
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .automaticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .automaticStorage(offset: 1),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testConstantRedefinesExistingSymbol() throws {
        let symbols = Env()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols)
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "constant redefines existing symbol: `foo\'")
        }
    }

    func testVariableRedefinesExistingSymbol() throws {
        let symbols = Env()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols)
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: true
        )
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "variable redefines existing symbol: `foo\'")
        }
    }

    func testConstantRedefinesExistingType() throws {
        let symbols = Env()
        symbols.bind(identifier: "foo", symbolType: .bool)
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols)
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "constant redefines existing type: `foo\'")
        }
    }

    func testVariableRedefinesExistingType() throws {
        let symbols = Env()
        symbols.bind(identifier: "foo", symbolType: .bool)
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols)
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: true
        )
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "variable redefines existing type: `foo\'")
        }
    }

    func testDeclareVariableWithExpressionAndExplicitType() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.arithmeticType(.immutableInt(.u8))),
            expression: LiteralInt(0),
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        let expected = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: LiteralInt(0)
        )
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithExpression_compTimeU8_mutableVariable() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: nil,
            expression: LiteralInt(0),
            storage: .staticStorage(offset: nil),
            isMutable: true
        )
        let actual = try? compiler.compile(input)
        let expected = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: LiteralInt(0)
        )
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .u8,
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithExpression_compTimeU8() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: nil,
            expression: LiteralInt(0),
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        let expected = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: LiteralInt(0)
        )
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithExpression_compTimeU16() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: nil,
            expression: LiteralInt(1000),
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        let expected = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: LiteralInt(1000)
        )
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u16)),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithExpression_compTimeBool() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: nil,
            expression: LiteralBool(true),
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        let expected = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: LiteralBool(true)
        )
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .constBool,
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithExpression_structInitializer() throws {
        let symbols = Env()
        let typ = StructTypeInfo(name: "bar", fields: Env())
        symbols.bind(identifier: "bar", symbolType: .structType(typ))
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: nil,
            expression: StructInitializer(identifier: Identifier("bar"), arguments: []),
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        let expected = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: StructInitializer(identifier: Identifier("bar"), arguments: [])
        )
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .constStructType(typ),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithExplicitTypeButNoExpression_immutable() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.arithmeticType(.immutableInt(.u8))),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithExplicitTypeButNoExpression_mutable() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: true
        )
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .u8,
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testUnableToDeduceTypeOfConstant() throws {
        let symbols = Env()
        let compiler = SnapSubcompilerVarDeclaration(symbols: symbols)
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: nil,
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "unable to deduce type of constant `foo'")
        }
    }

    func testUnableToDeduceTypeOfVariable() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: nil,
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: true
        )
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "unable to deduce type of variable `foo'")
        }
    }

    func testDeclareVariableWithExpressionAndExplicitType_literalArray() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let arrayExpr = LiteralArray(
            arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
            elements: [LiteralInt(0)]
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
            expression: arrayExpr,
            storage: .staticStorage(offset: nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        let expected = InitialAssignment(
            lexpr: Identifier("foo"),
            rexpr: arrayExpr
        )
        XCTAssertEqual(actual, expected)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .array(count: 1, elementType: .arithmeticType(.immutableInt(.u8))),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariableWithNoExpression() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
            expression: nil,
            storage: .staticStorage(offset: nil),
            isMutable: true
        )
        let actual = try compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .array(count: 1, elementType: .u8),
            storage: .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariable_StaticStorage_AlreadyAssignedMemoryAddress() throws {
        let symbols = Env()
        let frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: frame
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .staticStorage(offset: 42),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .staticStorage(offset: 42),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariable_AutomaticStorage_AlreadyAssignedMemoryAddress() throws {
        let symbols = Env()
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL()
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .automaticStorage(offset: 42),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .automaticStorage(offset: 42),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }

    func testDeclareVariable_RegisterStorage() throws {
        let symbols = Env()
        symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        let compiler = SnapSubcompilerVarDeclaration(
            symbols: symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL()
        )
        let input = VarDeclaration(
            identifier: Identifier("foo"),
            explicitType: PrimitiveType(.u8),
            expression: nil,
            storage: .registerStorage(nil),
            isMutable: false
        )
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
        let foo = try? symbols.resolve(identifier: "foo")
        let expectedSymbol = Symbol(
            type: .arithmeticType(.immutableInt(.u8)),
            storage: .registerStorage(nil),
            visibility: .privateVisibility,
            decl: input.id
        )
        XCTAssertEqual(foo, expectedSymbol)
    }
}
