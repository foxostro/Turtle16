//
//  GenericCompilerFrontEndTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleCompilerToolbox

class GenericCompilerFrontEndTests: XCTestCase {
    class NullLexer : Lexer {
        var hasError: Bool = false
        var errors: [CompilerError] = []
        var tokens: [Token] = []
        func scanTokens() {}
    }
    class NullParser : Parser {
        var hasError: Bool = false
        var errors: [CompilerError] = []
        var syntaxTree: AbstractSyntaxTreeNode? = AbstractSyntaxTreeNode()
        func parse() {}
    }
    class NullCodeGenerator : CodeGenerator {
        var hasError: Bool = false
        var errors: [CompilerError] = []
        var instructions: [Instruction] = []
        func compile(ast root: AbstractSyntaxTreeNode, base: Int) {}
    }
    
    func testCompileFailsDuringLexing() {
        class MockLexer : Lexer {
            var hasError: Bool = true
            var errors: [CompilerError] = [ CompilerError(line: 1, message: "unexpected character: `@'") ]
            var tokens: [Token] = []
            func scanTokens() {}
        }
        let compiler = GenericCompilerFrontEnd(lexerFactory: { _ in MockLexer() },
                                               parserFactory: { _ in NullParser() },
                                               codeGeneratorFactory: { _ in NullCodeGenerator() } )
        compiler.compile("@")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("unexpected character: `@'"))
    }
    
    func testCompileFailsDuringParsing() {
        class MockParser : Parser {
            var hasError: Bool = true
            var errors: [CompilerError] = [ CompilerError(line: 1, message: "unexpected end of input") ]
            var syntaxTree: AbstractSyntaxTreeNode? = nil
            func parse() {}
        }
        let compiler = GenericCompilerFrontEnd(lexerFactory: { _ in NullLexer() },
                                               parserFactory: { _ in MockParser() },
                                               codeGeneratorFactory: { _ in NullCodeGenerator() } )
        compiler.compile(":")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("unexpected end of input"))
    }
    
    func testCompileFailsDuringCodeGeneration() {
        class MockCodeGenerator : CodeGenerator {
            var hasError: Bool = true
            var errors: [CompilerError] = [ CompilerError(line: 1, message: "use of undeclared identifier: `foo'") ]
            var instructions: [Instruction] = []
            func compile(ast root: AbstractSyntaxTreeNode, base: Int) {}
        }
        let compiler = GenericCompilerFrontEnd(lexerFactory: { _ in NullLexer() },
                                               parserFactory: { _ in NullParser() },
                                               codeGeneratorFactory: { _ in MockCodeGenerator() } )
        compiler.compile("LI B, foo")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("use of undeclared identifier: `foo'"))
    }
    
    func testEnsureDisassemblyWorks() {
        class MockCodeGenerator : CodeGenerator {
            var hasError: Bool = false
            var errors: [CompilerError] = []
            var instructions: [Instruction] = [ Instruction(opcode: 0, immediate: 0) ]
            func compile(ast root: AbstractSyntaxTreeNode, base: Int) {}
        }
        let compiler = GenericCompilerFrontEnd(lexerFactory: { _ in NullLexer() },
                                               parserFactory: { _ in NullParser() },
                                               codeGeneratorFactory: { _ in MockCodeGenerator() } )
        compiler.compile("")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions.count, 1)
        XCTAssertEqual(compiler.instructions.first?.disassembly, "NOP")
    }
    
    func testOmnibusErrorWithNoErrors() {
        let compiler = GenericCompilerFrontEnd(lexerFactory: { _ in NullLexer() },
                                               parserFactory: { _ in NullParser() },
                                               codeGeneratorFactory: { _ in NullCodeGenerator() } )
        let error = compiler.makeOmnibusError(fileName: nil, errors: [])
        XCTAssertEqual(error.line, nil)
        XCTAssertEqual(error.message, "0 errors generated\n")
    }
    
    func testOmnibusErrorWithOneError() {
        let errors = [CompilerError(line: 1, message: "register cannot be used as a destination: `E'")]
        let compiler = GenericCompilerFrontEnd(lexerFactory: { _ in NullLexer() },
                                               parserFactory: { _ in NullParser() },
                                               codeGeneratorFactory: { _ in NullCodeGenerator() } )
        let omnibusError = compiler.makeOmnibusError(fileName: "foo.s", errors: errors)
        XCTAssertEqual(omnibusError.line, nil)
        XCTAssertEqual(omnibusError.message, "foo.s:1: error: register cannot be used as a destination: `E'\n1 error generated\n")
    }
    
    func testOmnibusErrorWithMultipleErrors() {
        let errors = [
            CompilerError(line: 1, message: "register cannot be used as a destination: `E'"),
            CompilerError(line: 2, message: "operand type mismatch: `MOV'")
        ]
        let compiler = GenericCompilerFrontEnd(lexerFactory: { _ in NullLexer() },
                                               parserFactory: { _ in NullParser() },
                                               codeGeneratorFactory: { _ in NullCodeGenerator() } )
        let omnibusError = compiler.makeOmnibusError(fileName: "foo.s", errors: errors)
        XCTAssertEqual(omnibusError.line, nil)
        XCTAssertEqual(omnibusError.message, "foo.s:1: error: register cannot be used as a destination: `E'\nfoo.s:2: error: operand type mismatch: `MOV'\n2 errors generated\n")
    }
}
