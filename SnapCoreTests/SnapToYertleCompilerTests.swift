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
import TurtleCore

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
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
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
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
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
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "bar"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
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
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
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
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ImplicitType() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeLiteralArray([ExprUtils.makeLiteralInt(value: 0),
                                                                   ExprUtils.makeLiteralInt(value: 1),
                                                                   ExprUtils.makeLiteralInt(value: 2)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(2),
            .push(1),
            .push(0),
            .push16(addressFoo),
            .storeIndirectN(3),
            .popn(3)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .u8), offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ExplicitType() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           explicitType: .array(count: nil, elementType: .u8),
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeLiteralArray([ExprUtils.makeLiteralInt(value: 0),
                                                                   ExprUtils.makeLiteralInt(value: 1),
                                                                   ExprUtils.makeLiteralInt(value: 2)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(2),
            .push(1),
            .push(0),
            .push16(addressFoo),
            .storeIndirectN(3),
            .popn(3)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .u8), offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_CannotAssignFunctionToArray() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "a", type: .u8), FunctionType.Argument(name: "b", type: .u16)]),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeBool(value: true))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                           explicitType: .array(count: nil, elementType: .u16),
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeIdentifier(name: "foo"),
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `(u8, u16) -> bool' to type `[u16]'")
    }
    
    func testCompileVarDeclaration() {
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
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
    
    func testCompileVarDeclaration_IncrementsStoragePointer() {
        let val = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xabcd", literal: 0xabcd))
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: val,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: val,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        var symbolFoo: Symbol? = nil
        XCTAssertNoThrow(symbolFoo = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbolFoo, Symbol(type: .u16, offset: addressFoo, isMutable: true))
        
        let addressBar = SnapToYertleCompiler.kStaticStorageStartAddress+2
        var symbolBar: Symbol? = nil
        XCTAssertNoThrow(symbolBar = try compiler.globalSymbols.resolve(identifier: "bar"))
        XCTAssertEqual(symbolBar, Symbol(type: .u16, offset: addressBar, isMutable: true))
        
        XCTAssertEqual(compiler.instructions, [
            .push16(0xabcd),
            .store16(addressFoo),
            .pop16,
            .push16(0xabcd),
            .store16(addressBar),
            .pop16
        ])
    }
    
    func testCompileVarDeclaration_RedefinesExistingSymbol() {
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "variable redefines existing symbol: `foo'")
    }
    
    func testCompileVarDeclaration_LocalVarsAreAllocatedStorageInOrderInTheStackFrame_1() {
        let one = ExprUtils.makeLiteralInt(value: 1)
        let two = ExprUtils.makeLiteralInt(value: 2)
        let three = ExprUtils.makeLiteralInt(value: 3)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                                                   explicitType: nil,
                                                   tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                   expression: one,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "b"),
                                                   explicitType: nil,
                                                   tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                   expression: two,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "c"),
                                                   explicitType: nil,
                                                   tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                   expression: three,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeIdentifier(name: "b"))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 2)
    }
    
    func testCompileVarDeclaration_LocalVarsAreAllocatedStorageInOrderInTheStackFrame_2() {
        let one = ExprUtils.makeLiteralInt(value: 1)
        let two = ExprUtils.makeLiteralInt(value: 2)
        let three = ExprUtils.makeLiteralInt(value: 3)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                                                   explicitType: nil,
                                                   tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                   expression: one,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Block(children: [
                                        VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "b"),
                                                       explicitType: nil,
                                                       tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                       expression: two,
                                                       storage: .stackStorage,
                                                       isMutable: false),
                                        Block(children: [
                                            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "c"),
                                                           explicitType: nil,
                                                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                           expression: three,
                                                           storage: .stackStorage,
                                                           isMutable: false),
                                            Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                                   expression: ExprUtils.makeIdentifier(name: "c"))
                                        ]),
                                    ]),
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 3)
    }
    
    func testCompileVarDeclaration_ShadowsExistingSymbolInEnclosingScope() {
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let two = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false),
            Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                               explicitType: nil,
                               tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                               expression: two,
                               storage: .staticStorage,
                               isMutable: false)
            ])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
    }
    
    func testCompileVarDeclaration_TypeIsInferredFromTheExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
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
                               explicitType: nil,
                               tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                               expression: ExprUtils.makeLiteralInt(value: 0xaa),
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
        XCTAssertEqual(computer.dataRAM.load(from: 0xffff), 0xaa)
    }
    
    func testCompileVarDeclaration_ConvertLiteralArrayTypeOnDeclaration() {
        let arr = Expression.LiteralArray(tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                          elements: [ExprUtils.makeLiteralInt(value: 1000),
                                                     ExprUtils.makeU8(value: 1),
                                                     ExprUtils.makeU8(value: 2)],
                                          tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]"))
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                               explicitType: .array(count: nil, elementType: .u16),
                               tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                               expression: arr,
                               storage: .stackStorage,
                               isMutable: false)
            ])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0012), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0014), 2)
    }
    
    func testCompileSimplestExpressionStatement() {
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
    
    func testCompileExpressionStatement_ArrayOfU8() {
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            ExprUtils.makeLiteralArray([ExprUtils.makeU8(value: 0),
                                        ExprUtils.makeU8(value: 1),
                                        ExprUtils.makeU8(value: 2)])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push(2),
            .push(1),
            .push(0),
            .popn(3)
        ])
    }
    
    func testCompileExpressionStatement_ArrayOfU16() {
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            ExprUtils.makeLiteralArray([ExprUtils.makeU16(value: 0xaaaa),
                                        ExprUtils.makeU16(value: 0xbbbb),
                                        ExprUtils.makeU16(value: 0xcccc)])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push16(0xcccc),
            .push16(0xbbbb),
            .push16(0xaaaa),
            .popn(6)
        ])
    }
    
    func testCompileExpressionStatement_ArrayOfArrayOfU16() {
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            ExprUtils.makeLiteralArray([ExprUtils.makeLiteralArray([ExprUtils.makeU16(value: 0xaaaa),
                                                                    ExprUtils.makeU16(value: 0xbbbb),
                                                                    ExprUtils.makeU16(value: 0xcccc)]),
                                        ExprUtils.makeLiteralArray([ExprUtils.makeU16(value: 0xdddd),
                                                                    ExprUtils.makeU16(value: 0xeeee),
                                                                    ExprUtils.makeU16(value: 0xffff)])])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .push16(0xffff),
            .push16(0xeeee),
            .push16(0xdddd),
            .push16(0xcccc),
            .push16(0xbbbb),
            .push16(0xaaaa),
            .popn(12)
        ])
    }
    
    func testCompileIfStatementWithoutElseBranch() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)),
                           storage: .staticStorage,
                           isMutable: true),
            If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)),
               then: ExprUtils.makeAssignment(lineNumber: 3, name: "foo", right: ExprUtils.makeLiteralInt(lineNumber: 3, value: 1)),
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
            .push16(addressFoo),
            .storeIndirect,
            .pop,
            .label(L0)
        ])
    }
    
    func testCompileIfStatementIncludingElseBranch() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)),
                           storage: .staticStorage,
                           isMutable: true),
            If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)),
               then: ExprUtils.makeAssignment(lineNumber: 3,
                                              name: "foo",
                                              right: ExprUtils.makeLiteralInt(lineNumber: 3, value: 1)),
               else: ExprUtils.makeAssignment(lineNumber: 5,
                                              name: "foo",
                                              right: ExprUtils.makeLiteralInt(lineNumber: 5, value: 2)))
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
            .push16(addressFoo),
            .storeIndirect,
            .pop,
            .jmp(L1),
            .label(L0),
            .push(2),
            .push16(addressFoo),
            .storeIndirect,
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
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeAdd(left: ExprUtils.makeU8(value: 1),
                                                         right: ExprUtils.makeBool(value: true)),
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
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeLiteralInt(value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            ForLoop(initializerClause: VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "i"),
                                                      explicitType: nil,
                                                      tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                      expression: ExprUtils.makeLiteralInt(value: 0),
                                                      storage: .staticStorage,
                                                      isMutable: true),
                    conditionClause: ExprUtils.makeComparisonLt(left: ExprUtils.makeIdentifier(name: "i"),
                                                                right: ExprUtils.makeLiteralInt(value: 10)),
                    incrementClause: ExprUtils.makeAssignment(name: "i", right: ExprUtils.makeAdd(left: ExprUtils.makeIdentifier(name: "i"), right: ExprUtils.makeLiteralInt(value: 1))),
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
            .push16(0x0010),
            .storeIndirect,
            .pop,
            .push(1),
            .load(0x0011),
            .add,
            .push16(0x0011),
            .storeIndirect,
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
                               explicitType: nil,
                               tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                               expression: ExprUtils.makeLiteralInt(value: 0),
                               storage: .staticStorage,
                               isMutable: true),
            ]),
            ExprUtils.makeAssignment(name: "foo", right: ExprUtils.makeLiteralInt(value: 0))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testCompileFunctionDeclaration_Simplest() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block())
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = TokenIdentifier(lineNumber: -1, lexeme: "foo")
        let L1 = TokenIdentifier(lineNumber: -1, lexeme: "__foo_tail")
        XCTAssertEqual(compiler.instructions, [
            .jmp(L1),
            .label(L0),
            .pushReturnAddress,
            .enter,
            .leave,
            .ret,
            .label(L1)
        ])
    }
    
    func testCompileFunctionDeclaration_WithSideEffects() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeLiteralInt(value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block(children: [
                                    ExprUtils.makeAssignment(name: "a", right: ExprUtils.makeLiteralInt(value: 1))
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
    
    func testCompilationFailsBecauseFunctionIsMissingAReturnStatement() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: []))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: ExprUtils.makeBool(value: true))
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnVoid() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: nil)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "non-void function should return a value")
    }
    
    func testCompilationFailsBecauseCodeAfterReturnWillNeverBeExecuted() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: ExprUtils.makeLiteralBoolean(value: true)),
                                    ExprUtils.makeLiteralBoolean(value: false)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "code after return will never be executed")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideIf() {
        let ret = TokenReturn(lineNumber: 1, lexeme: "return")
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    If(condition: tr,
                                       then: Return(token: ret, expression: tr),
                                       else: nil),
                                    Return(token: ret, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideElse() {
        let ret = TokenReturn(lineNumber: 1, lexeme: "return")
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    If(condition: tr,
                                       then: AbstractSyntaxTreeNode(),
                                       else: Return(token: ret, expression: tr)),
                                    Return(token: ret, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideWhile() {
        let ret = TokenReturn(lineNumber: 1, lexeme: "return")
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    While(condition: tr, body: Return(token: ret, expression: tr)),
                                    Return(token: ret, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideFor() {
        let ret = TokenReturn(lineNumber: 1, lexeme: "return")
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    ForLoop(initializerClause: AbstractSyntaxTreeNode(),
                                            conditionClause: tr,
                                            incrementClause: AbstractSyntaxTreeNode(),
                                            body: Return(token: ret, expression: tr)),
                                    Return(token: ret, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompileFunctionWithReturnValueU8() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeLiteralInt(value: 0xaa))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
    }
    
    func testCompileFunctionWithReturnValueU16() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u16, arguments: []),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeLiteralInt(value: 0xabcd))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 0xabcd)
    }
    
    func testCompileFunctionWithReturnValueU8PromotedToU16() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u16, arguments: []),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeLiteralInt(value: 0xaa))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 0x00aa)
    }
    
    func testCompilationFailsBecauseThereExistsAPathMissingAReturn_1() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    If(condition: ExprUtils.makeLiteralBoolean(value: true),
                                       then: Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                                    expression: ExprUtils.makeLiteralInt(value: 1)),
                                       else: nil)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseThereExistsAPathMissingAReturn_2() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block())
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseFunctionCallUsesIncorrectParameterType() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "a", type: .u8)]),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeU8(value: 1))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "b"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                                       arguments: [ExprUtils.makeBool(value: true)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert value of type `bool' to expected argument type `u8' in call to `foo'")
    }
    
    func testCompilationFailsBecauseReturnIsInvalidOutsideFunction() {
        let ast = TopLevel(children: [
            Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: ExprUtils.makeLiteralBoolean(value: true))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "return is invalid outside of a function")
    }
    
    func testCompileFunctionWithParameters_1() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeIdentifier(name: "bar"))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [ExprUtils.makeU8(value: 0xaa)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
    }
    
    // We take steps to ensure parameters and local variables do not overlap.
    func testCompileFunctionWithParameters_2() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(children: [
                                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "baz"),
                                                   explicitType: nil,
                                                   tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                   expression: ExprUtils.makeLiteralInt(value: 0xbb),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeIdentifier(name: "bar"))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [ExprUtils.makeU8(value: 0xaa)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
    }
    
    func testCompileFunctionWithParameters_3_ConvertIntegerConstantsToMatchingConcreteTypes() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeIdentifier(name: "bar"))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [ExprUtils.makeLiteralInt(value: 0xaa)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
    }
    
    func testCompileNestedFunction() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                                                   explicitType: nil,
                                                   tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                   expression: ExprUtils.makeLiteralInt(value: 0xaa),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                                                        functionType: FunctionType(returnType: .u8, arguments: []),
                                                        body: Block(children: [
                                                            Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                                                   expression: ExprUtils.makeIdentifier(name: "a"))
                                                        ])),
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "bar"),
                                                                       arguments: []))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
    }
    
    func testFunctionNamesAreNotUnique() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                                                   explicitType: nil,
                                                   tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                   expression: ExprUtils.makeLiteralInt(value: 0xaa),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                                                        functionType: FunctionType(returnType: .u8, arguments: []),
                                                        body: Block(children: [
                                                            Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                                                   expression: ExprUtils.makeIdentifier(name: "a"))
                                                        ])),
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "bar"),
                                                                       arguments: []))
                                ])),
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                           expression: ExprUtils.makeLiteralInt(value: 0xbb))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "bar"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xbb)
    }
    
    func testMutuallyRecursiveFunctions() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "isEven"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "n", type: .u8)]),
                                body: Block(children: [
                                    If(condition: ExprUtils.makeComparisonEq(left: ExprUtils.makeIdentifier(name: "n"),
                                                                             right: ExprUtils.makeLiteralInt(value: 0)),
                                       then: Block(children: [
                                        Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                               expression: ExprUtils.makeLiteralBoolean(value: true))
                                       ]),
                                       else: Block(children: [
                                        Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                               expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "isOdd"),
                                                                    arguments: [
                                                                        ExprUtils.makeSub(left: ExprUtils.makeIdentifier(name: "n"),
                                                                                          right: ExprUtils.makeLiteralInt(value: 1))
                                               ]))
                                       ]))
                                ])),
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "isOdd"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "n", type: .u8)]),
                                body: Block(children: [
                                    If(condition: ExprUtils.makeComparisonEq(left: ExprUtils.makeIdentifier(name: "n"),
                                                                             right: ExprUtils.makeLiteralInt(value: 0)),
                                       then: Block(children: [
                                        Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                               expression: ExprUtils.makeLiteralBoolean(value: false))
                                       ]),
                                       else: Block(children: [
                                        Return(token: TokenReturn(lineNumber: 1, lexeme: "return"),
                                               expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "isEven"),
                                                                    arguments: [
                                                                        ExprUtils.makeSub(left: ExprUtils.makeIdentifier(name: "n"),
                                                                                          right: ExprUtils.makeLiteralInt(value: 1))
                                               ]))
                                       ]))
                                ])),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: ExprUtils.makeIdentifier(name: "isOdd"),
                                                       arguments: [ExprUtils.makeLiteralInt(value: 7)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = YertleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
        }
    }
        
    func test_SixteenBitGreaterThan() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeComparisonGt(left: ExprUtils.makeLiteralInt(value: 0x1000), right: ExprUtils.makeLiteralInt(value: 0x0001)),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = YertleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
        }
    }
        
    func testCompilePeekMemory() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "a"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: ExprUtils.makeLiteralInt(value: 0xaa),
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "b"),
                           explicitType: nil,
                           tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                           expression: Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "peekMemory")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0x0010", literal: 0x0010))]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            print("IR:\n" + YertleInstruction.makeListing(instructions: ir) + "\n\n")
            XCTAssertEqual(ir, [
                .push(0xaa),
                .store(0x0010),
                .pop,
                .push16(0x0010),
                .loadIndirect,
                .store(0x0011),
                .pop,
            ])
            let executor = YertleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
            XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 0xaa)
        }
    }
        
    func testCompilePokeMemory() {
        let ast = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "pokeMemory")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xab", literal: 0xab)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0x0010", literal: 0x0010))])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            XCTAssertEqual(ir, [
                .push(0xab),
                .push16(0x0010),
                .storeIndirect,
                .pop
            ])
            let executor = YertleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xab)
        }
    }
        
    func testCompilePokePeripheral() {
        let ast = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "pokePeripheral")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xff", literal: 0xff)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xffff", literal: 0xffff)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0))]),
            Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "pokePeripheral")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xff", literal: 0xff)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xffff", literal: 0xffff)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))])
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = YertleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.lowerInstructionRAM.load(from: 0xffff), 0xff)
            XCTAssertEqual(computer.upperInstructionRAM.load(from: 0xffff), 0xff)
        }
    }
}
