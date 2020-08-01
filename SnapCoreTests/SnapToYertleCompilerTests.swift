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
        compiler.compile(ast: TopLevel(sourceAnchor: nil, children: []))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testAbstractSyntaxTreeNodeIsIgnoredInProgramCompilation() {
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: TopLevel(sourceAnchor: nil, children: [AbstractSyntaxTreeNode(sourceAnchor: nil)]))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompilationIgnoresUnknownNodes() {
        class UnknownNode: AbstractSyntaxTreeNode {}
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: TopLevel(sourceAnchor: nil, children: [UnknownNode(sourceAnchor: nil)]))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLetDeclaration_CompileTimeConstant() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 1),
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
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_CompileTimeConstant_RedefinesExistingSymbol() {
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                           explicitType: nil,
                           expression: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
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
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "bar"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressBar, isMutable: false))
    }
    
    func testCompileConstantDeclaration_TypeIsInferredFromTheExpression() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: Expression.LiteralBoolean(sourceAnchor: nil, value: true),
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
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ImplicitType() {
        let expr = Expression.LiteralArray(sourceAnchor: nil,
                                           explicitType: .u8,
                                           explicitCount: 3,
                                           elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0),
                                                      Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                                      Expression.LiteralWord(sourceAnchor: nil, value: 2)])
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: expr,
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
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .u8), offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ExplicitType() {
        let expr = Expression.LiteralArray(sourceAnchor: nil,
                                           explicitType: .u8,
                                           explicitCount: 3,
                                           elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0),
                                                      Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                                      Expression.LiteralWord(sourceAnchor: nil, value: 2)])
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: .array(count: nil, elementType: .u8),
                           expression: expr,
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
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .u8), offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_CannotAssignFunctionToArray() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "a", type: .u8), FunctionType.Argument(name: "b", type: .u16)]),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: ExprUtils.makeBool(value: true))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                           explicitType: .array(count: nil, elementType: .u16),
                           expression: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `(u8, u16) -> bool' to type `[_]u16'")
    }
    
    func testCompileConstantDeclaration_AssignStringLiteralToDynamicArray() {
        let elements = "Hello, World!".utf8.map({
            Expression.LiteralWord(sourceAnchor: nil, value: Int($0))
        })
        let stringLiteral = Expression.LiteralArray(sourceAnchor: nil,
                                                    explicitType: .u8,
                                                    explicitCount: elements.count,
                                                    elements: elements)
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: .dynamicArray(elementType: .u8),
                           expression: stringLiteral,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .dynamicArray(elementType: .u8), offset: addressFoo, isMutable: false))
        
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: addressFoo + 0), 0xfff3)
        XCTAssertEqual(computer.dataRAM.load16(from: addressFoo + 2), 0xd)
    }
    
    func testCompileVarDeclaration() {
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressFoo, isMutable: true))
        XCTAssertEqual(compiler.instructions, [
            .push(1),
            .store(addressFoo),
            .pop
        ])
    }
    
    func testCompileVarDeclaration_IncrementsStoragePointer() {
        let val = Expression.LiteralWord(sourceAnchor: nil, value: 0xabcd)
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: val,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                           explicitType: nil,
                           expression: val,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress+0
        var symbolFoo: Symbol? = nil
        XCTAssertNoThrow(symbolFoo = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbolFoo, Symbol(type: .u16, offset: addressFoo, isMutable: true))
        
        let addressBar = SnapToYertleCompiler.kStaticStorageStartAddress+2
        var symbolBar: Symbol? = nil
        XCTAssertNoThrow(symbolBar = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "bar"))
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
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
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
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let two = Expression.LiteralWord(sourceAnchor: nil, value: 2)
        let three = Expression.LiteralWord(sourceAnchor: nil, value: 3)
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    VarDeclaration(sourceAnchor: nil,
                                                   identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                                                   explicitType: nil,
                                                   expression: one,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    VarDeclaration(sourceAnchor: nil,
                                                   identifier: Expression.Identifier(sourceAnchor: nil, identifier: "b"),
                                                   explicitType: nil,
                                                   expression: two,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    VarDeclaration(sourceAnchor: nil,
                                                   identifier: Expression.Identifier(sourceAnchor: nil, identifier: "c"),
                                                   explicitType: nil,
                                                   expression: three,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Return(sourceAnchor: nil,
                                           expression: Expression.Identifier(sourceAnchor: nil, identifier: "b"))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil, callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"), arguments: []),
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
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let two = Expression.LiteralWord(sourceAnchor: nil, value: 2)
        let three = Expression.LiteralWord(sourceAnchor: nil, value: 3)
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    VarDeclaration(sourceAnchor: nil,
                                                   identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                                                   explicitType: nil,
                                                   expression: one,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Block(sourceAnchor: nil, children: [
                                        VarDeclaration(sourceAnchor: nil,
                                                       identifier: Expression.Identifier(sourceAnchor: nil, identifier: "b"),
                                                       explicitType: nil,
                                                       expression: two,
                                                       storage: .stackStorage,
                                                       isMutable: false),
                                        Block(sourceAnchor: nil, children: [
                                            VarDeclaration(sourceAnchor: nil,
                                                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "c"),
                                                           explicitType: nil,
                                                           expression: three,
                                                           storage: .stackStorage,
                                                           isMutable: false),
                                            Return(sourceAnchor: nil,
                                                   expression: Expression.Identifier(sourceAnchor: nil, identifier: "c"))
                                        ]),
                                    ]),
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: []),
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
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let two = Expression.LiteralWord(sourceAnchor: nil, value: 2)
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false),
            Block(sourceAnchor: nil, children: [
                VarDeclaration(sourceAnchor: nil,
                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                               explicitType: nil,
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: Expression.LiteralBoolean(sourceAnchor: nil, value: true),
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
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: addressFoo, isMutable: true))
    }
    
    func testCompileVarDeclaration_StackLocalVariable() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            Block(sourceAnchor: nil, children: [
                VarDeclaration(sourceAnchor: nil,
                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                               explicitType: nil,
                               expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xaa),
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
        let arr = Expression.LiteralArray(sourceAnchor: nil,
                                          explicitType: .u16,
                                          explicitCount: 3,
                                          elements: [Expression.LiteralWord(sourceAnchor: nil, value: 1000),
                                                     ExprUtils.makeU8(value: 1),
                                                     ExprUtils.makeU8(value: 2)])
        let ast = TopLevel(sourceAnchor: nil, children: [
            Block(sourceAnchor: nil, children: [
                VarDeclaration(sourceAnchor: nil,
                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                               explicitType: .array(count: nil, elementType: .u16),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Expression.LiteralWord(sourceAnchor: nil, value: 1)
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Expression.LiteralArray(sourceAnchor: nil,
                                          explicitType: .u8,
                                          explicitCount: 3,
                                          elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0),
                                                     Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                                     Expression.LiteralWord(sourceAnchor: nil, value: 2)])
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Expression.LiteralArray(sourceAnchor: nil,
                                    explicitType: .u16,
                                    explicitCount: 3,
                                    elements: [ExprUtils.makeU16(value: 0xaaaa),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Expression.LiteralArray(sourceAnchor: nil,
                                    explicitType: .array(count: 3, elementType: .u16),
                                    explicitCount: nil,
                                    elements: [
                Expression.LiteralArray(sourceAnchor: nil,
                                        explicitType: .u16,
                                        explicitCount: 3,
                                        elements: [ExprUtils.makeU16(value: 0xaaaa),
                                                   ExprUtils.makeU16(value: 0xbbbb),
                                                   ExprUtils.makeU16(value: 0xcccc)]),
                Expression.LiteralArray(sourceAnchor: nil,
                                        explicitType: .u16,
                                        explicitCount: 3,
                                        elements: [ExprUtils.makeU16(value: 0xdddd),
                                                   ExprUtils.makeU16(value: 0xeeee),
                                                   ExprUtils.makeU16(value: 0xffff)])
            ])
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            If(sourceAnchor: nil,
               condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
               then: ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
               else: nil)
        ])
        
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = ".L0"
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            If(sourceAnchor: nil,
               condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
               then: ExprUtils.makeAssignment(name: "foo",
                                              right: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
               else: ExprUtils.makeAssignment(name: "foo",
                                              right: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
        ])
        let addressFoo = SnapToYertleCompiler.kStaticStorageStartAddress
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = ".L0"
        let L1 = ".L1"
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            While(sourceAnchor: nil,
                  condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                  body: Expression.LiteralWord(sourceAnchor: nil, value: 2))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = ".L0"
        let L1 = ".L1"
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                           explicitType: nil,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            ForLoop(sourceAnchor: nil,
                    initializerClause: VarDeclaration(sourceAnchor: nil,
                                                      identifier: Expression.Identifier(sourceAnchor: nil, identifier: "i"),
                                                      explicitType: nil,
                                                      expression: Expression.LiteralWord(sourceAnchor: nil, value: 0),
                                                      storage: .staticStorage,
                                                      isMutable: true),
                    conditionClause: ExprUtils.makeComparisonLt(left: Expression.Identifier(sourceAnchor: nil, identifier: "i"),
                                                                right: Expression.LiteralWord(sourceAnchor: nil, value: 10)),
                    incrementClause: ExprUtils.makeAssignment(name: "i", right: ExprUtils.makeAdd(left: Expression.Identifier(sourceAnchor: nil, identifier: "i"), right: Expression.LiteralWord(sourceAnchor: nil, value: 1))),
                    body: ExprUtils.makeAssignment(name: "foo", right: Expression.Identifier(sourceAnchor: nil, identifier: "i")))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = ".L0"
        let L1 = ".L1"
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Block(sourceAnchor: nil, children: [
                VarDeclaration(sourceAnchor: nil,
                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                               explicitType: nil,
                               expression: Expression.LiteralWord(sourceAnchor: nil, value: 0),
                               storage: .staticStorage,
                               isMutable: true),
            ]),
            ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralWord(sourceAnchor: nil, value: 0))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testCompileFunctionDeclaration_Simplest() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block(sourceAnchor: nil, children: []))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = "foo"
        let L1 = "__foo_tail"
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    ExprUtils.makeAssignment(name: "a", right: Expression.LiteralWord(sourceAnchor: nil, value: 1))
                                ])),
            Expression.Call(sourceAnchor: nil,
                            callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                            arguments: [])
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: []))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil, expression: ExprUtils.makeBool(value: true))
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnVoid() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil, expression: nil)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "non-void function should return a value")
    }
    
    func testCompilationFailsBecauseCodeAfterReturnWillNeverBeExecuted() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil, expression: Expression.LiteralBoolean(sourceAnchor: nil, value: true)),
                                    Expression.LiteralBoolean(sourceAnchor: nil, value: false)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "code after return will never be executed")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideIf() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    If(sourceAnchor: nil,
                                       condition: tr,
                                       then: Return(sourceAnchor: nil, expression: tr),
                                       else: nil),
                                    Return(sourceAnchor: nil, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideElse() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    If(sourceAnchor: nil,
                                       condition: tr,
                                       then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                                       else: Return(sourceAnchor: nil, expression: tr)),
                                    Return(sourceAnchor: nil, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideWhile() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    While(sourceAnchor: nil,
                                          condition: tr,
                                          body: Return(sourceAnchor: nil, expression: tr)),
                                    Return(sourceAnchor: nil, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideFor() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    ForLoop(sourceAnchor: nil,
                                            initializerClause: AbstractSyntaxTreeNode(sourceAnchor: nil),
                                            conditionClause: tr,
                                            incrementClause: AbstractSyntaxTreeNode(sourceAnchor: nil),
                                            body: Return(sourceAnchor: nil, expression: tr)),
                                    Return(sourceAnchor: nil, expression: one)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompileFunctionWithReturnValueU8() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xaa))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: []),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u16, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xabcd))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: []),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u16, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xaa))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: []),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    If(sourceAnchor: nil,
                                       condition: Expression.LiteralBoolean(sourceAnchor: nil, value: true),
                                       then: Return(sourceAnchor: nil,
                                                    expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                                       else: nil)
                                ]))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseThereExistsAPathMissingAReturn_2() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: []))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseFunctionCallUsesIncorrectParameterType() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "a", type: .u8)]),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: ExprUtils.makeU8(value: 1))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "b"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Return(sourceAnchor: nil, expression: Expression.LiteralBoolean(sourceAnchor: nil, value: true))
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "return is invalid outside of a function")
    }
    
    func testCompileFunctionWithParameters_1() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: Expression.Identifier(sourceAnchor: nil, identifier: "bar"))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: [ExprUtils.makeU8(value: 0xaa)]),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(sourceAnchor: nil, children: [
                                    VarDeclaration(sourceAnchor: nil,
                                                   identifier: Expression.Identifier(sourceAnchor: nil, identifier: "baz"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xbb),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Return(sourceAnchor: nil,
                                           expression: Expression.Identifier(sourceAnchor: nil, identifier: "bar"))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: [ExprUtils.makeU8(value: 0xaa)]),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: Expression.Identifier(sourceAnchor: nil, identifier: "bar"))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 0xaa)]),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    VarDeclaration(sourceAnchor: nil,
                                                   identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xaa),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(sourceAnchor: nil,
                                                        identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                                        functionType: FunctionType(returnType: .u8, arguments: []),
                                                        body: Block(sourceAnchor: nil, children: [
                                                            Return(sourceAnchor: nil,
                                                                   expression: Expression.Identifier(sourceAnchor: nil, identifier: "a"))
                                                        ])),
                                    Return(sourceAnchor: nil,
                                           expression: Expression.Call(sourceAnchor: nil,
                                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                                                       arguments: []))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                                       arguments: []),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    VarDeclaration(sourceAnchor: nil,
                                                   identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xaa),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(sourceAnchor: nil,
                                                        identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                                        functionType: FunctionType(returnType: .u8, arguments: []),
                                                        body: Block(sourceAnchor: nil, children: [
                                                            Return(sourceAnchor: nil,
                                                                   expression: Expression.Identifier(sourceAnchor: nil, identifier: "a"))
                                                        ])),
                                    Return(sourceAnchor: nil,
                                           expression: Expression.Call(sourceAnchor: nil,
                                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                                                       arguments: []))
                                ])),
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: nil, children: [
                                    Return(sourceAnchor: nil,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xbb))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                                       arguments: []),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "isEven"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "n", type: .u8)]),
                                body: Block(sourceAnchor: nil, children: [
                                    If(sourceAnchor: nil,
                                       condition: ExprUtils.makeComparisonEq(left: Expression.Identifier(sourceAnchor: nil, identifier: "n"),
                                                                             right: Expression.LiteralWord(sourceAnchor: nil, value: 0)),
                                       then: Block(sourceAnchor: nil, children: [
                                        Return(sourceAnchor: nil,
                                               expression: Expression.LiteralBoolean(sourceAnchor: nil, value: true))
                                       ]),
                                       else: Block(sourceAnchor: nil, children: [
                                        Return(sourceAnchor: nil,
                                               expression: Expression.Call(sourceAnchor: nil,
                                                                           callee: Expression.Identifier(sourceAnchor: nil, identifier: "isOdd"),
                                                                           arguments: [ExprUtils.makeSub(left:  Expression.Identifier(sourceAnchor: nil, identifier: "n"), right: Expression.LiteralWord(sourceAnchor: nil, value: 1))]))
                                       ]))
                                ])),
            FunctionDeclaration(sourceAnchor: nil,
                                identifier: Expression.Identifier(sourceAnchor: nil, identifier: "isOdd"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "n", type: .u8)]),
                                body: Block(sourceAnchor: nil, children: [
                                    If(sourceAnchor: nil,
                                       condition: ExprUtils.makeComparisonEq(left: Expression.Identifier(sourceAnchor: nil, identifier: "n"),
                                                                             right: Expression.LiteralWord(sourceAnchor: nil, value: 0)),
                                       then: Block(sourceAnchor: nil, children: [Return(sourceAnchor: nil, expression: Expression.LiteralBoolean(sourceAnchor: nil, value: false))]),
                                       else: Block(sourceAnchor: nil, children: [
                                        Return(sourceAnchor: nil,
                                               expression: Expression.Call(sourceAnchor: nil,
                                                                           callee: Expression.Identifier(sourceAnchor: nil, identifier: "isEven"),
                                                                           arguments: [
                                                                            ExprUtils.makeSub(left: Expression.Identifier(sourceAnchor: nil, identifier: "n"),
                                                                                          right: Expression.LiteralWord(sourceAnchor: nil, value: 1))
                                               ]))
                                       ]))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "isOdd"),
                                                       arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 7)]),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: ExprUtils.makeComparisonGt(left: Expression.LiteralWord(sourceAnchor: nil, value: 0x1000), right: Expression.LiteralWord(sourceAnchor: nil, value: 0x0001)),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: nil,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0xaa),
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "b"),
                           explicitType: nil,
                           expression: Expression.Call(sourceAnchor: nil,
                                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "peekMemory"),
                                                       arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 0x0010)]),
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Expression.Call(sourceAnchor: nil,
                            callee: Expression.Identifier(sourceAnchor: nil, identifier: "pokeMemory"),
                            arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 0xab),
                                        Expression.LiteralWord(sourceAnchor: nil, value: 0x0010)])
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            Expression.Call(sourceAnchor: nil,
                            callee: Expression.Identifier(sourceAnchor: nil, identifier: "pokePeripheral"),
                            arguments: [
                                Expression.LiteralWord(sourceAnchor: nil, value: 0xff),
                                Expression.LiteralWord(sourceAnchor: nil, value: 0xffff),
                                Expression.LiteralWord(sourceAnchor: nil, value: 0)
            ]),
            Expression.Call(sourceAnchor: nil,
                            callee: Expression.Identifier(sourceAnchor: nil, identifier: "pokePeripheral"),
                            arguments: [
                                Expression.LiteralWord(sourceAnchor: nil, value: 0xff),
                                Expression.LiteralWord(sourceAnchor: nil, value: 0xffff),
                                Expression.LiteralWord(sourceAnchor: nil, value: 1)
            ])
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
        
    func testCompileHlt() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            Expression.Call(sourceAnchor: nil,
                            callee: Expression.Identifier(sourceAnchor: nil, identifier: "pokeMemory"),
                            arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 0xab),
                                        Expression.LiteralWord(sourceAnchor: nil, value: 0x0010)]),
            Expression.Call(sourceAnchor: nil,
                            callee: Expression.Identifier(sourceAnchor: nil, identifier: "hlt"),
                            arguments: []),
            Expression.Call(sourceAnchor: nil,
                            callee: Expression.Identifier(sourceAnchor: nil, identifier: "pokeMemory"),
                            arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 0xcd),
                                        Expression.LiteralWord(sourceAnchor: nil, value: 0x0010)])
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
            XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xab)
        }
    }
        
    func testCompileGetArrayLength() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "r"),
                           explicitType: .u16,
                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 0),
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           explicitType: .array(count: nil, elementType: .u8),
                           expression: Expression.LiteralArray(sourceAnchor: nil,
                                                               explicitType: .u8,
                                                               explicitCount: nil,
                                                               elements: [ExprUtils.makeU8(value: 1),
                                                                          ExprUtils.makeU8(value: 2),
                                                                          ExprUtils.makeU8(value: 3)]),
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "b"),
                           explicitType: .dynamicArray(elementType: .u8),
                           expression: Expression.Identifier(sourceAnchor: nil, identifier: "a"),
                           storage: .staticStorage,
                           isMutable: false),
            Expression.Assignment(sourceAnchor: nil,
                                  lexpr: Expression.Identifier(sourceAnchor: nil, identifier: "r"),
                                  rexpr: Expression.Call(sourceAnchor: nil,
                                                         callee: Expression.Identifier(sourceAnchor: nil, identifier: "length"),
                                                         arguments: [Expression.Identifier(sourceAnchor: nil, identifier: "b")]))
            
        ])
        let compiler = SnapToYertleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
            return
        }
        let ir = compiler.instructions
        let executor = YertleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 3)
    }
}
