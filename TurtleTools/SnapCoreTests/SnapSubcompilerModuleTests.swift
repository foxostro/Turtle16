//
//  SnapSubcompilerModuleTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

// Module nodes contain library code which is compiled in isolation from the
// main body of the program. The results of compilation are passed to the
// compiler backend to be compiled to machine code. The module's public symbols
// may be imported into the global symbol table later, when an Import node is
// encountered.
class SnapSubcompilerModuleTests: XCTestCase {
    fileprivate func makeCompiler(_ symbols: SymbolTable) -> SnapSubcompilerModule {
        return SnapSubcompilerModule(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
    }
    
    func testEmptyModule() throws {
        let globalSymbols = SymbolTable()
        let input = Module(name: "Foo")
        _ = try? makeCompiler(globalSymbols).compile(input)
        XCTAssertTrue(globalSymbols.symbolTable.isEmpty)
        XCTAssertTrue(input.symbols.symbolTable.isEmpty)
    }
    
    func testModuleWithPublicSymbol() throws {
        let globalSymbols = SymbolTable()
        let input = Module(name: "Foo", children: [
            FunctionDeclaration(identifier: Expression.Identifier("puts"), functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [Expression.DynamicArrayType(Expression.PrimitiveType(.u8))]), argumentNames: ["s"], body: Block(children: []), visibility: .publicVisibility)
        ])
        let result = try makeCompiler(globalSymbols).compile(input)
        XCTAssertTrue(globalSymbols.symbolTable.isEmpty)
        let puts = try? result.symbols.resolve(identifier: "puts")
        XCTAssertNotNil(puts)
    }
    
    func testModuleRedefinesExistingModule() throws {
        let globalSymbols = SymbolTable()
        globalSymbols.bind(identifier: "Foo", moduleSymbols: SymbolTable())
        
        let input = Module(name: "Foo", children: [])
        
        let compiler = makeCompiler(globalSymbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "module redefines existing module: `Foo'")
        }
    }
}
