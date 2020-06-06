//
//  SnapToYertleCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class SnapToYertleCompilerTests: XCTestCase {
    func testNoErrorsAtFirst() {
        let compiler = SnapToYertleCompiler()
        XCTAssertFalse(compiler.hasError)
        XCTAssertTrue(compiler.errors.isEmpty)
    }
    
    func testCompileEmptyProgram() {
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: AbstractSyntaxTreeNode())
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testAbstractSyntaxTreeNodeIsIgnoredInProgramCompilation() {
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: AbstractSyntaxTreeNode(children: [AbstractSyntaxTreeNode()]))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompilationIgnoresUnknownNodes() {
        class UnknownNode: AbstractSyntaxTreeNode {}
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: UnknownNode())
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLabelDeclaration() {
        let ast = AbstractSyntaxTreeNode(children: [
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertEqual(compiler.instructions, [.label(foo)])
    }
    
    func testCompileLetDeclaration_CompileTimeConstant() {
        let ast = AbstractSyntaxTreeNode(children: [
            LetDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo)
        ])
        var symbol: SymbolTable.Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.symbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, .word(.staticStorage(address: addressFoo, isMutable: false)))
    }
    
    func testCompileConstantDeclaration_CompileTimeConstant_RedefinesExistingSymbol() {
        let one = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = AbstractSyntaxTreeNode(children: [
            LetDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: one),
            LetDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"), expression: one)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "constant redefines existing symbol: `foo'")
    }
    
    func testCompileConstantDeclaration_NotCompileTimeConstant() {
        let ast = AbstractSyntaxTreeNode(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
            LetDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "bar"),
                                expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")))
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        let addressBar = SnapToYertleCompiler.kStaticStorageStartAddress+1
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo),
            .load(addressFoo),
            .store(addressBar)
        ])
        var symbol: SymbolTable.Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.symbols.resolve(identifier: "bar"))
        XCTAssertEqual(symbol, .word(.staticStorage(address: addressBar, isMutable: false)))
    }
    
    func testCompileVarDeclaration() {
        let one = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = AbstractSyntaxTreeNode(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: one)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        var symbol: SymbolTable.Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.symbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, .word(.staticStorage(address: addressFoo, isMutable: true)))
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo)
        ])
    }
    
    func testCompileVarDeclaration_RedefinesExistingSymbol() {
        let one = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = AbstractSyntaxTreeNode(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: one),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"), expression: one)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "variable redefines existing symbol: `foo'")
    }
    
    func testCompileExpression() {
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        let ast = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [ .push(1) ])
    }
    
    func testCompileIfStatementWithoutElseBranch() {
        let ast = AbstractSyntaxTreeNode(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                              expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0))),
            If(condition: Expression.Literal(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)),
               then: Expression.Assignment(identifier: TokenIdentifier(lineNumber: 3, lexeme: "foo"),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 3, lexeme: "1", literal: 1))),
               else: nil)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = TokenIdentifier(lineNumber: -1, lexeme: ".L0")
        XCTAssertEqual(compiler.instructions, [
            .push(0),
            .store(addressFoo),
            .push(1),
            .push(0),
            .je(L0),
            .push(1),
            .store(addressFoo),
            .label(L0)
        ])
    }
    
    func testCompileIfStatementIncludingElseBranch() {
        let ast = AbstractSyntaxTreeNode(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                              expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0))),
            If(condition: Expression.Literal(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)),
               then: Expression.Assignment(identifier: TokenIdentifier(lineNumber: 3, lexeme: "foo"),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 3, lexeme: "1", literal: 1))),
               else: Expression.Assignment(identifier: TokenIdentifier(lineNumber: 5, lexeme: "foo"),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 5, lexeme: "2", literal: 2))))
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = TokenIdentifier(lineNumber: -1, lexeme: ".L0")
        let L1 = TokenIdentifier(lineNumber: -1, lexeme: ".L1")
        XCTAssertEqual(compiler.instructions, [
            .push(0),
            .store(addressFoo),
            .push(1),
            .push(0),
            .je(L0),
            .push(1),
            .store(addressFoo),
            .jmp(L1),
            .label(L0),
            .push(2),
            .store(addressFoo),
            .label(L1)
        ])
    }
    
    func testCompileWhileStatement() {
        let ast = AbstractSyntaxTreeNode(children: [
            While(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                  body: Expression.Literal(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = TokenIdentifier(lineNumber: -1, lexeme: ".L0")
        let L1 = TokenIdentifier(lineNumber: -1, lexeme: ".L1")
        XCTAssertEqual(compiler.instructions, [
            .label(L0),
            .push(1),
            .push(0),
            .je(L1),
            .push(2),
            .jmp(L0),
            .label(L1)
        ])
    }
}
