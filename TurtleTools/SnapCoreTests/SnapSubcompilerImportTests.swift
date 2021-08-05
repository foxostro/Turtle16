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
        return SnapSubcompilerImport(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
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
        XCTAssertTrue(symbols.existsAsModule(identifier: "Foo"))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
    }
    
    func testInjectModuleWithPrivateSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", moduleSymbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .u8, offset: 0, visibility: .privateVisibility))
        ]))
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: "Foo")
        let output = try compiler.compile(input)
        XCTAssertNil(output)
        XCTAssertTrue(symbols.existsAsModule(identifier: "Foo"))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNil(try? symbols.resolve(identifier: "bar"))
    }
    
    func testInjectModuleWithPublicSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", moduleSymbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .u8, offset: 0, visibility: .publicVisibility))
        ]))
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: "Foo")
        let output = try compiler.compile(input)
        XCTAssertNil(output)
        XCTAssertTrue(symbols.existsAsModule(identifier: "Foo"))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNotNil(try? symbols.resolve(identifier: "bar"))
    }
    
    func testInjectModuleWithPublicType() throws {
        let symbols = SymbolTable()
        let moduleSymbols = SymbolTable()
        moduleSymbols.bind(identifier: "bar", symbolType: .u8, visibility: .publicVisibility)
        symbols.bind(identifier: "Foo", moduleSymbols: moduleSymbols)
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: "Foo")
        let output = try compiler.compile(input)
        XCTAssertNil(output)
        XCTAssertTrue(symbols.existsAsModule(identifier: "Foo"))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNotNil(try? symbols.resolveType(identifier: "bar"))
    }
    
    func testImportCannotRedefineExistingSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "bar", symbol: Symbol(type: .u8, offset: 0, visibility: .publicVisibility))
        symbols.bind(identifier: "Foo", moduleSymbols: SymbolTable(tuples: [
            ("bar", Symbol(type: .u8, offset: 0, visibility: .publicVisibility))
        ]))
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: "Foo")
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "import of module `Foo' redefines existing symbol: `bar'")
        }
    }
    
    func testImportCannotRedefineExistingType() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "bar", symbolType: .u8)
        let moduleSymbols = SymbolTable()
        moduleSymbols.bind(identifier: "bar", symbolType: .u8, visibility: .publicVisibility)
        symbols.bind(identifier: "Foo", moduleSymbols: moduleSymbols)
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: "Foo")
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "import of module `Foo' redefines existing type: `bar'")
        }
    }
    
    func testImportFromBundleResource() throws {
        let stdlib = SnapToCrackleCompiler.kStandardLibraryModuleName
        let symbols = SymbolTable()
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: stdlib)
        let output = try compiler.compile(input)
        XCTAssertNotNil(output)
        XCTAssertTrue(symbols.existsAsModule(identifier: stdlib))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains(stdlib))
        XCTAssertNotNil(try? symbols.resolveType(identifier: "None"))
    }
    
    func testImportTwice() throws {
        let stdlib = SnapToCrackleCompiler.kStandardLibraryModuleName
        let symbols = SymbolTable()
        symbols.bind(identifier: stdlib, moduleSymbols: SymbolTable())
        symbols.modulesAlreadyImported.insert(stdlib)
        let compiler = makeCompiler(symbols)
        let input = Import(moduleName: stdlib)
        XCTAssertNoThrow(try compiler.compile(input))
        XCTAssertTrue(symbols.existsAsModule(identifier: stdlib))
        XCTAssertTrue(symbols.modulesAlreadyImported.contains(stdlib))
    }
}
