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
        compiler.compile(ast: TopLevel())
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testAbstractSyntaxTreeNodeIsIgnoredInProgramCompilation() {
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: TopLevel(children: [AbstractSyntaxTreeNode()]))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompilationIgnoresUnknownNodes() {
        class UnknownNode: AbstractSyntaxTreeNode {}
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: TopLevel(children: [UnknownNode()]))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLetDeclaration_CompileTimeConstant() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo),
            .pop
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_CompileTimeConstant_RedefinesExistingSymbol() {
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "constant redefines existing symbol: `foo'")
    }
    
    func testCompileConstantDeclaration_NotCompileTimeConstant() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "bar"),
                           expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        let addressBar = SnapToYertleCompiler.kStaticStorageStartAddress+1
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo),
            .pop,
            .load(addressFoo),
            .store(addressBar),
            .pop
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "bar"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressBar, isMutable: false))
    }
    
    func testCompileConstantDeclaration_TypeIsInferredFromTheExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           expression: ExprUtils.makeLiteralBoolean(value: true),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo),
            .pop
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: addressFoo, isMutable: false))
    }
    
    func testCompileVarDeclaration() {
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressFoo, isMutable: true))
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo),
            .pop
        ])
    }
    
    func testCompileVarDeclaration_RedefinesExistingSymbol() {
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "variable redefines existing symbol: `foo'")
    }
    
    func testCompileVarDeclaration_TypeIsInferredFromTheExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           expression: ExprUtils.makeLiteralBoolean(value: true),
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo),
            .pop
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: addressFoo, isMutable: true))
    }
    
    func testCompileVarDeclaration_StackLocalVariable() {
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                               expression: ExprUtils.makeLiteralWord(value: 0xaa),
                               storage: .stackStorage,
                               isMutable: true)
            ])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffd), 0xaa)
    }
    
    func testCompileExpression() {
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [ .push(1), .pop ])
    }
    
    func testCompileIfStatementWithoutElseBranch() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)),
                           storage: .staticStorage,
                           isMutable: true),
            If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)),
               then: Expression.Assignment(identifier: TokenIdentifier(lineNumber: 3, lexeme: "foo"),
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 3, lexeme: "1", literal: 1))),
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
            .pop,
            .push(1),
            .push(0),
            .je(L0),
            .push(1),
            .store(addressFoo),
            .pop,
            .label(L0)
        ])
    }
    
    func testCompileIfStatementIncludingElseBranch() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                              expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)),
                              storage: .staticStorage,
                              isMutable: true),
            If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)),
               then: Expression.Assignment(identifier: TokenIdentifier(lineNumber: 3, lexeme: "foo"),
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 3, lexeme: "1", literal: 1))),
               else: Expression.Assignment(identifier: TokenIdentifier(lineNumber: 5, lexeme: "foo"),
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 5, lexeme: "2", literal: 2))))
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
            .pop,
            .push(1),
            .push(0),
            .je(L0),
            .push(1),
            .store(addressFoo),
            .pop,
            .jmp(L1),
            .label(L0),
            .push(2),
            .store(addressFoo),
            .pop,
            .label(L1)
        ])
    }
    
    func testCompileWhileStatement() {
        let ast = TopLevel(children: [
            While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                  body: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)))
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
            .pop,
            .jmp(L0),
            .label(L1)
        ])
    }
    
    func testCompilationFailsDueToTypeErrorInExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           expression: ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                                         right: ExprUtils.makeLiteralBoolean(value: true)),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "binary operator `+' cannot be applied to operands of types `u8' and `bool'")
    }
    
    func testCompileForLoopStatement() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           expression: ExprUtils.makeLiteralWord(value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            ForLoop(initializerClause: VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "i"),
                                                      expression: ExprUtils.makeLiteralWord(value: 0),
                                                      storage: .staticStorage,
                                                      isMutable: true),
                    conditionClause: ExprUtils.makeComparisonLt(left: ExprUtils.makeIdentifier(name: "i"),
                                                                right: ExprUtils.makeLiteralWord(value: 10)),
                    incrementClause: ExprUtils.makeAssignment(name: "i", right: ExprUtils.makeAdd(left: ExprUtils.makeIdentifier(name: "i"), right: ExprUtils.makeLiteralWord(value: 1))),
                    body: ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeIdentifier(name: "i")))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = TokenIdentifier(lineNumber: -1, lexeme: ".L0")
        let L1 = TokenIdentifier(lineNumber: -1, lexeme: ".L1")
        let expected: [YertleInstruction] = [
            .push(0),
            .store(0x0010),
            .pop,
            .push(0),
            .store(0x0011),
            .pop,
            .label(L0),
            .push(10),
            .load(0x0011),
            .lt,
            .push(0),
            .je(L1),
            .load(0x0011),
            .store(0x0010),
            .pop,
            .push(1),
            .load(0x0011),
            .add,
            .store(0x0011),
            .pop,
            .jmp(L0),
            .label(L1)
        ]
        XCTAssertEqual(compiler.instructions, expected)
    }
    
    func testCompilationFailsBecauseLocalVarDoesntSurviveLocalScope() {
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                               expression: ExprUtils.makeLiteralWord(value: 0),
                               storage: .staticStorage,
                               isMutable: true),
            ]),
            ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralWord(value: 0))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testCompileFunctionDeclaration_Simplest() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                returnType: .void,
                                arguments: [],
                                body: Block())
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = TokenIdentifier(lineNumber: -1, lexeme: "foo")
        let L1 = TokenIdentifier(lineNumber: -1, lexeme: "foo_tail")
        XCTAssertEqual(compiler.instructions, [
            .jmp(L1),
            .label(L0),
            .enter,
            .leave,
            .leaf_ret,
            .label(L1)
        ])
    }
    
    func testCompileFunctionDeclaration_WithSideEffects() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           expression: ExprUtils.makeLiteralWord(value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                returnType: .void,
                                arguments: [],
                                body: Block(children: [
                                    ExprUtils.makeAssignment(name: "a", right: ExprUtils.makeLiteralWord(value: 1))
                                ])),
            Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
    }
}
