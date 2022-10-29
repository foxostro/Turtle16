//
//  SnapAbstractSyntaxTreeCompilerDeclPassTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapAbstractSyntaxTreeCompilerDeclPassTests: XCTestCase {
    func testExample() throws {
        let globalEnvironment = GlobalEnvironment()
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(globalEnvironment: globalEnvironment)
        let result = try compiler.compile(CommentNode(string: "foo"))
        XCTAssertEqual(result, CommentNode(string: "foo"))
    }
    
    func testFunctionDeclaration() throws {
        let globalEnvironment = GlobalEnvironment()
        let globalSymbols = globalEnvironment.globalSymbols
        let originalFunctionDeclaration = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                                              argumentNames: [],
                                                              body: Block(children: []))
        let input = Block(symbols: globalSymbols, children: [
            originalFunctionDeclaration
        ])
        
        let expectedRewrittenFunctionDeclaration = originalFunctionDeclaration.withBody(Block(children: [Return()]))
        let expectedFunctionType = FunctionType(name: "foo",
                                                mangledName: "foo",
                                                returnType: .void,
                                                arguments: [],
                                                ast: expectedRewrittenFunctionDeclaration)
        let expected = Symbol(type: .function(expectedFunctionType),
                              offset: 0,
                              storage: .automaticStorage)
        
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(globalEnvironment: globalEnvironment)
        _ = try compiler.compile(input)
        let actual = try globalSymbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }
    
    func testStructDeclaration() throws {
        let globalEnvironment = GlobalEnvironment()
        let globalSymbols = globalEnvironment.globalSymbols
        let input = Block(symbols: globalSymbols, children: [
            StructDeclaration(identifier: Expression.Identifier("None"), members: [])
        ])
        
        let expected = Block(symbols: globalSymbols, children: []) // StructDeclaration is removed after being processed
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(globalEnvironment: globalEnvironment)
        let result = try? compiler.compile(input)
        XCTAssertEqual(result, expected)
        
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.enclosingFunctionNameMode = .set("None")
        let expectedType: SymbolType = .structType(StructType(name: "None", symbols: expectedStructSymbols))
        let actualType = try? globalSymbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTypealias() throws {
        let globalEnvironment = GlobalEnvironment()
        let globalSymbols = globalEnvironment.globalSymbols
        let input = Block(symbols: globalSymbols, children: [
            Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])
        
        let expected = Block(symbols: globalSymbols, children: []) // Typealias is removed after being processed
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(globalEnvironment: globalEnvironment)
        let result = try? compiler.compile(input)
        XCTAssertEqual(result, expected)
        
        let expectedType: SymbolType = .arithmeticType(.mutableInt(.u8))
        let actualType = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTraitDeclaration() throws {
        let globalEnvironment = GlobalEnvironment()
        let globalSymbols = globalEnvironment.globalSymbols
        
        let input = Block(symbols: globalSymbols, children: [
            TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        ])
        
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(globalEnvironment: globalEnvironment)
        _ = try compiler.compile(input)
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.enclosingFunctionNameMode = .set("Foo")
        let expectedType: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actualType = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expectedType, actualType)
    }
    
    func testImportStdlib() throws {
        let globalEnvironment = GlobalEnvironment()
        let globalSymbols = globalEnvironment.globalSymbols
        let input = Block(symbols: globalSymbols, children: [
            Import(moduleName: kStandardLibraryModuleName)
        ])
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(globalEnvironment: globalEnvironment)
        var output: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(output = try compiler.compile(input))
        XCTAssertNotNil(output)
        XCTAssertTrue(compiler.globalEnvironment.hasModule(kStandardLibraryModuleName))
        XCTAssertTrue(globalSymbols.modulesAlreadyImported.contains(kStandardLibraryModuleName))
        XCTAssertNotNil(try? globalSymbols.resolve(identifier: "none"))
    }
    
    func testImpl() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        
        func makeImpl() throws {
            let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
                Expression.PointerType(Expression.Identifier("Foo"))
            ])))
            let foo = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                       members: [bar],
                                       visibility: .privateVisibility)
            try SnapSubcompilerTraitDeclaration(
                globalEnvironment: globalEnvironment,
                symbols: globalEnvironment.globalSymbols).compile(foo)
        }
        try makeImpl()
        
        XCTAssertFalse(globalEnvironment.functionsToCompile.isEmpty)
        guard !globalEnvironment.functionsToCompile.isEmpty else {
            return
        }
        
        func makeExpectedMethodType(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) -> FunctionType {
            let argTypeExpr = Expression.PointerType(Expression.Identifier("__Foo_object"))
            let argType = try! RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment).check(expression: argTypeExpr)
            let expectedMethodType = FunctionType(name: "bar",
                                                  mangledName: "____Foo_object_bar",
                                                  returnType: .arithmeticType(.mutableInt(.u8)),
                                                  arguments: [argType])
            return expectedMethodType
        }
        let expectedMethodType = makeExpectedMethodType(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        
        let actualMethodType = globalEnvironment.functionsToCompile.removeFirst()
        XCTAssertEqual(actualMethodType, expectedMethodType)
    }
    
    func testCompileImplForTrait() throws {
        let globalEnvironment = GlobalEnvironment()
        let globalSymbols = globalEnvironment.globalSymbols
        
        let bar = TraitDeclaration.Member(name: "puts", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
            Expression.PointerType(Expression.Identifier("Serial")),
            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])))
        let traitDecl = TraitDeclaration(identifier: Expression.Identifier("Serial"),
                                         members: [bar],
                                         visibility: .privateVisibility)
        let fake = StructDeclaration(identifier: Expression.Identifier("SerialFake"), members: [])
        let implFor = ImplFor(typeArguments: [],
                              traitTypeExpr: Expression.Identifier("Serial"),
                              structTypeExpr: Expression.Identifier("SerialFake"),
                              children: [
                                FunctionDeclaration(identifier: Expression.Identifier("puts"),
                                                    functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [
                                                        Expression.PointerType(Expression.Identifier("Serial")),
                                                        Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                                    ]),
                                                    argumentNames: ["self", "s"],
                                                    body: Block())
                              ])
        let input = Block(symbols: globalSymbols, children: [
            traitDecl,
            fake,
            implFor
        ])
        
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(globalEnvironment: globalEnvironment)
        _ = try compiler.compile(input)
        
        // Let's examine, for correctness, the vtable symbol
        let nameOfVtableInstance = "__Serial_SerialFake_vtable_instance"
        let vtableInstance = try globalSymbols.resolve(identifier: nameOfVtableInstance)
        let vtableStructType = vtableInstance.type.unwrapStructType()
        XCTAssertEqual(vtableStructType.name, "__Serial_vtable")
        XCTAssertEqual(vtableStructType.symbols.exists(identifier: "puts"), true)
        let putsSymbol = try vtableStructType.symbols.resolve(identifier: "puts")
        XCTAssertEqual(putsSymbol.type, .pointer(.function(FunctionType(returnType: .void, arguments: [.pointer(.void), .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8)))]))))
        XCTAssertEqual(putsSymbol.offset, 0)
    }
}
