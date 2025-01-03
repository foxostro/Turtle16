//
//  CompilerPassWithDeclScanTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/18/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassWithDeclScanTests: XCTestCase {
    var testName: String {
        let regex = try! NSRegularExpression(pattern: #"\[\w+\s+(?<testName>\w+)\]"#)
        if let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) {
            let nsRange = match.range(withName: "testName")
            if let range = Range(nsRange, in: name) {
                return String(name[range])
            }
        }
        return ""
    }
    
    func parse(_ text: String) throws -> TopLevel {
        try SnapCore.parse(text: text, url: URL(fileURLWithPath: testName))
    }
    
    func testInit() {
        let _ = CompilerPassWithDeclScan()
    }
    
    func testPassesProgramThroughUnmodified() throws {
        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(CommentNode(string: "foo"))
        XCTAssertEqual(result, CommentNode(string: "foo"))
    }
    
    func testFunctionDeclaration() throws {
        let symbols = SymbolTable()
        let originalFunctionDeclaration = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: Expression.FunctionType(
                name: "foo",
                returnType: Expression.PrimitiveType(.void),
                arguments: []),
            argumentNames: [],
            body: Block(children: []))
        let input = Block(symbols: symbols, children: [
            originalFunctionDeclaration
        ])
            .reconnect(parent: nil)
        
        let expectedRewrittenFunctionDeclaration = originalFunctionDeclaration
            .withBody(Block(children: [
                Return()
            ]))
        let expectedFunctionType = FunctionType(
            name: "foo",
            mangledName: "foo",
            returnType: .void,
            arguments: [],
            ast: expectedRewrittenFunctionDeclaration)
        let expected = Symbol(
            type: .function(expectedFunctionType),
            offset: 0,
            storage: .automaticStorage)
        
        let compiler = CompilerPassWithDeclScan()
        _ = try compiler.visit(input)
        let actual = try symbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }
    
    func testStructDeclaration() throws {
        let symbols = SymbolTable()
        let input = Block(symbols: symbols, children: [
            StructDeclaration(identifier: Expression.Identifier("None"), members: [])
        ])
        
        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(input)
        XCTAssertEqual(result, input)
        
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.frameLookupMode = .set(Frame())
        expectedStructSymbols.enclosingFunctionNameMode = .set("None")
        let expectedType: SymbolType = .structType(StructType(name: "None", symbols: expectedStructSymbols))
        let actualType = try symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTypealias() throws {
        let symbols = SymbolTable()
        let input = Block(symbols: symbols, children: [
            Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])
        
        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(input)
        XCTAssertEqual(result, input)
        
        let expectedType: SymbolType = .arithmeticType(.mutableInt(.u8))
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTraitDeclaration() throws {
        let symbols = SymbolTable()
        
        let input = Block(symbols: symbols, children: [
            TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        ])
        
        let compiler = CompilerPassWithDeclScan()
        _ = try compiler.run(input)
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.frameLookupMode = .set(Frame())
        expectedSymbols.enclosingFunctionNameMode = .set("Foo")
        let expectedType: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expectedType, actualType)
    }
    
    func testImportingAModuleCausesItToExportPublicSymbols() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        let ast0 = Block(symbols: symbols, children: [
            Import(moduleName: "Foo")
        ])
        let ast1 = try ast0.importPass(
            injectModules: [("Foo", "public struct None {}\n")],
            globalEnvironment: globalEnvironment)
        
        let compiler = CompilerPassWithDeclScan(globalEnvironment)
        let ast2 = try compiler.run(ast1)
        
        XCTAssertEqual(ast2, ast1)
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNoThrow(try symbols.resolveType(identifier: "None"))
    }
    
    func testCompileImplForTrait() throws {
        
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        
        func compileSerialTrait() throws {
            let bar = TraitDeclaration.Member(name: "puts", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
                Expression.PointerType(Expression.Identifier("Serial")),
                Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
            ])))
            let traitDecl = TraitDeclaration(
                identifier: Expression.Identifier("Serial"),
                members: [bar],
                visibility: .privateVisibility)
            try TraitScanner(
                globalEnvironment: globalEnvironment,
                symbols: symbols)
            .scan(trait: traitDecl)
        }
        
        func compileSerialFake() throws {
            let fake = StructDeclaration(identifier: Expression.Identifier("SerialFake"), members: [])
            try SnapSubcompilerStructDeclaration(
                symbols: symbols,
                globalEnvironment: globalEnvironment)
            .compile(fake)
        }
        
        try compileSerialTrait()
        try compileSerialFake()
        
        let ast = Block(
            symbols: symbols,
            children: [
                ImplFor(
                    typeArguments: [],
                    traitTypeExpr: Expression.Identifier("Serial"),
                    structTypeExpr: Expression.Identifier("SerialFake"),
                    children: [
                        FunctionDeclaration(
                            identifier: Expression.Identifier("puts"),
                            functionType: Expression.FunctionType(
                                name: "puts",
                                returnType: Expression.PrimitiveType(.void),
                                arguments: [
                                    Expression.PointerType(Expression.Identifier("Serial")),
                                    Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                ]),
                            argumentNames: ["self", "s"],
                            body: Block())
                    ])
            ])
        .reconnect(parent: nil)
        
        _ = try CompilerPassWithDeclScan(globalEnvironment: globalEnvironment).visit(ast)
        
        // Let's examine, for correctness, the vtable symbol
        let nameOfVtableInstance = "__Serial_SerialFake_vtable_instance"
        let vtableInstance = try symbols.resolve(identifier: nameOfVtableInstance)
        let vtableStructType = vtableInstance.type.unwrapStructType()
        XCTAssertEqual(vtableStructType.name, "__Serial_vtable")
        XCTAssertEqual(vtableStructType.symbols.exists(identifier: "puts"), true)
        let putsSymbol = try vtableStructType.symbols.resolve(identifier: "puts")
        XCTAssertEqual(putsSymbol.type, .pointer(.function(FunctionType(returnType: .void, arguments: [.pointer(.void), .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8)))]))))
        XCTAssertEqual(putsSymbol.offset, 0)
    }
    
    func testScanMatchClause() throws {
        let input = try parse("""
            let foo: bool | u16 = true
            match foo {
                (bar: bool) -> { let qux = false }
                else -> { let quux = false }
            }
            """)
            .replaceTopLevelWithBlock()
            .reconnect(parent: nil)
        
        let children = (input as! Block).children
        let match = children.last as! Match
        let clauseSymbols = match.clauses.first!.block.symbols
        let elseSymbols = match.elseClause!.symbols
        
        _ = try CompilerPassWithDeclScan(globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())).run(input)
        
        XCTAssertNoThrow(try elseSymbols.resolve(identifier: "quux"))
        XCTAssertNoThrow(try clauseSymbols.resolve(identifier: "qux"))
        XCTAssertNoThrow(try clauseSymbols.resolve(identifier: "bar"))
    }
}
