//
//  SnapSubcompilerImportTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerImportTests: XCTestCase {
    fileprivate func makeCompiler(_ symbols: SymbolTable) -> SnapSubcompilerImport {
        return SnapSubcompilerImport(symbols: symbols, globalEnvironment: GlobalEnvironment())
    }
    
    func testEmptyModuleName() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: "")
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "no such module `'")
        }
    }
    
    func testNoSuchModule() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: "fake")
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "no such module `fake'")
        }
    }
    
    func testInjectEmptyModule() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        compiler.injectModule(name: "Foo", sourceCode: "")
        let input = Import(moduleName: "Foo")
        _ = try compiler.compile(input)
        XCTAssertTrue(compiler.globalEnvironment.hasModule("Foo"))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
    }
    
    func testImportModuleWithPrivateSymbol() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        let moduleSymbols = SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, visibility: .privateVisibility))
        ])
        compiler.globalEnvironment.modules["Foo"] = Block(symbols: moduleSymbols, children: [])
        let input = Import(moduleName: "Foo")
        try compiler.compile(input)
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNil(try? symbols.resolve(identifier: "bar"))
    }
    
    func testImportModuleWithPublicSymbol() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        let moduleSymbols = SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, visibility: .publicVisibility))
        ])
        compiler.globalEnvironment.modules["Foo"] = Block(symbols: moduleSymbols, children: [])
        let input = Import(moduleName: "Foo")
        try compiler.compile(input)
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNotNil(try? symbols.resolve(identifier: "bar"))
    }
    
    func testImportModuleWithPublicType() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        let moduleSymbols = SymbolTable()
        moduleSymbols.bind(identifier: "bar", symbolType: .arithmeticType(.mutableInt(.u8)), visibility: .publicVisibility)
        compiler.globalEnvironment.modules["Foo"] = Block(symbols: moduleSymbols, children: [])
        let input = Import(moduleName: "Foo")
        try compiler.compile(input)
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNotNil(try? symbols.resolveType(identifier: "bar"))
    }
    
    func testImportCannotRedefineExistingSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "bar", symbol: Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, visibility: .publicVisibility))
        let compiler = makeCompiler(symbols)
        let moduleSymbols = SymbolTable(tuples: [
            ("bar", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0, visibility: .publicVisibility))
        ])
        compiler.globalEnvironment.modules["Foo"] = Block(symbols: moduleSymbols, children: [])
        let input = Import(moduleName: "Foo")
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "import of module `Foo' redefines existing symbol: `bar'")
        }
    }
    
    func testImportCannotRedefineExistingType() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "bar", symbolType: .arithmeticType(.mutableInt(.u8)))
        let compiler = makeCompiler(symbols)
        let moduleSymbols = SymbolTable()
        moduleSymbols.bind(identifier: "bar", symbolType: .arithmeticType(.mutableInt(.u8)), visibility: .publicVisibility)
        compiler.globalEnvironment.modules["Foo"] = Block(symbols: moduleSymbols, children: [])
        let input = Import(moduleName: "Foo")
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "import of module `Foo' redefines existing type: `bar'")
        }
    }
    
    func testImportFromBundleResource() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: kStandardLibraryModuleName)
        try compiler.compile(input)
        XCTAssertTrue(compiler.globalEnvironment.hasModule(kStandardLibraryModuleName))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains(kStandardLibraryModuleName))
        XCTAssertNotNil(try? symbols.resolveType(identifier: "None"))
    }
    
    func testImportModuleThatsAlreadyBeenImportedBefore() throws {
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        symbols.modulesAlreadyImported.insert(kStandardLibraryModuleName)
        let input = Import(moduleName: kStandardLibraryModuleName)
        XCTAssertNoThrow(try compiler.compile(input))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains(kStandardLibraryModuleName))
    }
}
