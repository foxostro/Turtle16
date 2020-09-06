//
//  SnapToCrackleCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox
import TurtleCore

class SnapToCrackleCompilerTests: XCTestCase {
    let t0 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 0
    let t1 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 2
    let t2 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 4
    let t3 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 6
    let kStaticStorageStartAddress = SnapToCrackleCompiler.kStaticStorageStartAddress
    
    func testNoErrorsAtFirst() {
        let compiler = SnapToCrackleCompiler()
        XCTAssertFalse(compiler.hasError)
        XCTAssertTrue(compiler.errors.isEmpty)
    }
    
    func testCompileEmptyProgram() {
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: TopLevel(children: []))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testAbstractSyntaxTreeNodeIsIgnoredInProgramCompilation() {
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: TopLevel(children: [AbstractSyntaxTreeNode()]))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompilationIgnoresUnknownNodes() {
        class UnknownNode: AbstractSyntaxTreeNode {}
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: TopLevel(children: [UnknownNode(sourceAnchor: nil)]))
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLetDeclaration_CompileTimeConstant() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_CompileTimeConstant_RedefinesExistingSymbol() {
        let one = Expression.LiteralInt(1)
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "immutable variable redefines existing symbol: `foo'")
    }
    
    func testCompileConstantDeclaration_NotCompileTimeConstant() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("bar"),
                           explicitType: nil,
                           expression: Expression.Identifier("foo"),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        let addressBar = SnapToCrackleCompiler.kStaticStorageStartAddress+1
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1),
            .storeImmediate16(t0, addressBar),
            .copyWords(t1, addressFoo, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "bar"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressBar, isMutable: false))
    }
    
    func testCompileConstantDeclaration_TypeIsInferredFromTheExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralBool(true),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ImplicitType() {
        let expr = Expression.LiteralArray(explicitType: .u8,
                                           explicitCount: 3,
                                           elements: [Expression.LiteralInt(0),
                                                      Expression.LiteralInt(1),
                                                      Expression.LiteralInt(2)])
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: expr,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, 272),
            .storeImmediate16(t1, 1),
            .storeImmediate(t2, 0),
            .copyWordsIndirectDestination(t0, t2, 1),
            .add16(t0, t0, t1),
            .storeImmediate(t2, 1),
            .copyWordsIndirectDestination(t0, t2, 1),
            .add16(t0, t0, 18),
            .storeImmediate(t2, 2),
            .copyWordsIndirectDestination(t0, t2, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .u8), offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ExplicitType() {
        let expr = Expression.LiteralArray(explicitType: .u8,
                                           explicitCount: 3,
                                           elements: [Expression.LiteralInt(0),
                                                      Expression.LiteralInt(1),
                                                      Expression.LiteralInt(2)])
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: .array(count: nil, elementType: .u8),
                           expression: expr,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate16(t1, 1),
            .storeImmediate(t2, 0),
            .copyWordsIndirectDestination(t0, t2, 1),
            .add16(t0, t0, t1),
            .storeImmediate(t2, 1),
            .copyWordsIndirectDestination(t0, t2, 1),
            .add16(t0, t0, t1),
            .storeImmediate(t2, 2),
            .copyWordsIndirectDestination(t0, t2, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .u8), offset: addressFoo, isMutable: false))
    }
    
    func testCompileConstantDeclaration_CannotAssignFunctionToArray() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "a", type: .u8), FunctionType.Argument(name: "b", type: .u16)]),
                                body: Block(children: [
                                    Return(ExprUtils.makeBool(value: true))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier("bar"),
                           explicitType: .array(count: nil, elementType: .u16),
                           expression: Expression.Identifier("foo"),
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `(u8, u16) -> bool' to type `[_]u16'")
    }
    
    func testCompileConstantDeclaration_AssignStringLiteralToDynamicArray() {
        let elements = "Hello, World!".utf8.map({
            Expression.LiteralInt(Int($0))
        })
        let stringLiteral = Expression.LiteralArray(explicitType: .u8,
                                                    explicitCount: elements.count,
                                                    elements: elements)
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: .dynamicArray(elementType: .u8),
                           expression: stringLiteral,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .dynamicArray(elementType: .u8), offset: addressFoo, isMutable: false))
        
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        
        // The statement puts the string on the stack.
        XCTAssertEqual(computer.stackPointer, Int(UInt16(0) &- UInt16(0xd)))
        XCTAssertEqual(computer.stack(at: 0x0), 0x48) // H
        XCTAssertEqual(computer.stack(at: 0x1), 0x65) // e
        XCTAssertEqual(computer.stack(at: 0x2), 0x6c) // l
        XCTAssertEqual(computer.stack(at: 0x3), 0x6c) // l
        XCTAssertEqual(computer.stack(at: 0x4), 0x6f) // o
        XCTAssertEqual(computer.stack(at: 0x5), 0x2c) // ,
        XCTAssertEqual(computer.stack(at: 0x6), 0x20) //
        XCTAssertEqual(computer.stack(at: 0x7), 0x57) // W
        XCTAssertEqual(computer.stack(at: 0x8), 0x6f) // o
        XCTAssertEqual(computer.stack(at: 0x9), 0x72) // r
        XCTAssertEqual(computer.stack(at: 0xa), 0x6c) // l
        XCTAssertEqual(computer.stack(at: 0xb), 0x64) // d
        XCTAssertEqual(computer.stack(at: 0xc), 0x21) // !
        
        // And binds an array slice to it.
        XCTAssertEqual(computer.dataRAM.load16(from: addressFoo + 0), 0xfff3)
        XCTAssertEqual(computer.dataRAM.load16(from: addressFoo + 2), 0xd)
    }
    
    func testCompileVarDeclaration() {
        let one = Expression.LiteralInt(1)
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressFoo, isMutable: true))
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
    }
    
    func testCompileVarDeclaration_IncrementsStoragePointer() {
        let val = Expression.LiteralInt(0xabcd)
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: val,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("bar"),
                           explicitType: nil,
                           expression: val,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        var symbolFoo: Symbol? = nil
        XCTAssertNoThrow(symbolFoo = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbolFoo, Symbol(type: .u16, offset: addressFoo, isMutable: true))
        
        let addressBar = SnapToCrackleCompiler.kStaticStorageStartAddress+2
        var symbolBar: Symbol? = nil
        XCTAssertNoThrow(symbolBar = try compiler.globalSymbols.resolve(identifier: "bar"))
        XCTAssertEqual(symbolBar, Symbol(type: .u16, offset: addressBar, isMutable: true))
        
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate16(t1, 0xabcd),
            .copyWordsIndirectDestination(t0, t1, 2),
            .storeImmediate16(t0, addressBar),
            .storeImmediate16(t1, 0xabcd),
            .copyWordsIndirectDestination(t0, t1, 2)
        ])
    }
    
    func testCompileVarDeclaration_RedefinesExistingSymbol() {
        let one = Expression.LiteralInt(1)
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "variable redefines existing symbol: `foo'")
    }
    
    func testCompileVarDeclaration_LocalVarsAreAllocatedStorageInOrderInTheStackFrame_1() {
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        let three = Expression.LiteralInt(3)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: one,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    VarDeclaration(identifier: Expression.Identifier("b"),
                                                   explicitType: nil,
                                                   expression: two,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    VarDeclaration(identifier: Expression.Identifier("c"),
                                                   explicitType: nil,
                                                   expression: three,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Return(Expression.Identifier("b"))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"), arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 2)
    }
    
    func testCompileVarDeclaration_LocalVarsAreAllocatedStorageInOrderInTheStackFrame_2() {
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        let three = Expression.LiteralInt(3)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: one,
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Block(children: [
                                        VarDeclaration(identifier: Expression.Identifier("b"),
                                                       explicitType: nil,
                                                       expression: two,
                                                       storage: .stackStorage,
                                                       isMutable: false),
                                        Block(children: [
                                            VarDeclaration(identifier: Expression.Identifier("c"),
                                                           explicitType: nil,
                                                           expression: three,
                                                           storage: .stackStorage,
                                                           isMutable: false),
                                            Return(Expression.Identifier("c"))
                                        ]),
                                    ]),
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 3)
    }
    
    func testCompileVarDeclaration_ShadowsExistingSymbolInEnclosingScope() {
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: one,
                           storage: .staticStorage,
                           isMutable: false),
            Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: nil,
                               expression: two,
                               storage: .staticStorage,
                               isMutable: false)
            ])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
    }
    
    func testCompileVarDeclaration_TypeIsInferredFromTheExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralBool(true),
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress+0
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: addressFoo, isMutable: true))
    }
    
    func testCompileVarDeclaration_ConvertLiteralArrayTypeOnDeclaration() {
        let arr = Expression.LiteralArray(explicitType: .u16,
                                          explicitCount: 3,
                                          elements: [Expression.LiteralInt(1000),
                                                     ExprUtils.makeU8(value: 1),
                                                     ExprUtils.makeU8(value: 2)])
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: .array(count: nil, elementType: .u16),
                               expression: arr,
                               storage: .stackStorage,
                               isMutable: false)
            ])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+2), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+4), 2)
    }
    
    func testCompileVarDeclaration_FailToDeduceTypeOfUndefinedValue() {
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: nil,
                               expression: nil,
                               storage: .stackStorage,
                               isMutable: false)
            ])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "unable to deduce type of immutable variable `foo'")
    }
    
    func testCompileVarDeclaration_ArrayOfUndefinedValue() {
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: .array(count: 100, elementType: .u16),
                               expression: nil,
                               storage: .stackStorage,
                               isMutable: false)
            ])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
    }
    
    func testCompileSimplestExpressionStatement() {
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralInt(1)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate(t0, 1)
        ])
    }
    
    func testCompileExpressionStatement_ArrayOfU8() {
        let t0 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 0
        let t1 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 4
        
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralArray(explicitType: .u8,
                                    explicitCount: 3,
                                    elements: [Expression.LiteralInt(0xa),
                                               Expression.LiteralInt(0xb),
                                               Expression.LiteralInt(0xc)])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate(t1, 0xa),
            .copyWords(t0+0, t1, 1),
            .storeImmediate(t1, 0xb),
            .copyWords(t0+1, t1, 1),
            .storeImmediate(t1, 0xc),
            .copyWords(t0+2, t1, 1)
        ])
    }
    
    func testCompileExpressionStatement_ArrayOfU16() {
        let t0 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 0
        let t1 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 6
        
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralArray(explicitType: .u16,
                                    explicitCount: 3,
                                    elements: [ExprUtils.makeU16(value: 0xaaaa),
                                               ExprUtils.makeU16(value: 0xbbbb),
                                               ExprUtils.makeU16(value: 0xcccc)])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t1, 0xaaaa),
            .copyWords(t0+0, t1, 2),
            .storeImmediate16(t1, 0xbbbb),
            .copyWords(t0+2, t1, 2),
            .storeImmediate16(t1, 0xcccc),
            .copyWords(t0+4, t1, 2)
        ])
    }
    
    func testCompileExpressionStatement_ArrayOfArrayOfU16() {
        let t0 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 0
        let t1 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 6
        let t2 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 12
        let t3 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 18
        
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralArray(explicitType: .array(count: 3, elementType: .u16),
                                    explicitCount: nil,
                                    elements: [
                Expression.LiteralArray(explicitType: .u16,
                                        explicitCount: 3,
                                        elements: [ExprUtils.makeU16(value: 0xaaaa),
                                                   ExprUtils.makeU16(value: 0xbbbb),
                                                   ExprUtils.makeU16(value: 0xcccc)]),
                Expression.LiteralArray(explicitType: .u16,
                                        explicitCount: 3,
                                        elements: [ExprUtils.makeU16(value: 0xdddd),
                                                   ExprUtils.makeU16(value: 0xeeee),
                                                   ExprUtils.makeU16(value: 0xffff)])
            ])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t3, 0xaaaa),
            .copyWords(t2+0, t3, 2),
            .storeImmediate16(t3, 0xbbbb),
            .copyWords(t2+2, t3, 2),
            .storeImmediate16(t3, 0xcccc),
            .copyWords(t2+4, t3, 2),
            .copyWords(t0, t2, 6),
            .storeImmediate16(t3, 0xdddd),
            .copyWords(t2+0, t3, 2),
            .storeImmediate16(t3, 0xeeee),
            .copyWords(t2+2, t3, 2),
            .storeImmediate16(t3, 0xffff),
            .copyWords(t2+4, t3, 2),
            .copyWords(t1, t2, 6)
        ]
        XCTAssertEqual(compiler.instructions, expected)
    }
    
    func testCompileIfStatementWithoutElseBranch() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(0),
                           storage: .staticStorage,
                           isMutable: true),
            If(condition: Expression.LiteralBool(true),
               then: ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralInt(1)),
               else: nil)
        ])
        
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = ".L0"
        XCTAssertEqual(compiler.instructions, [
            // foo = 0
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 0),
            .copyWordsIndirectDestination(t0, t1, 1),
            
            // the condition `true'
            .storeImmediate(t0, 1),
            
            // if the condition is equal to zero then jump to L0 (else)
            .jz(L0, t0),
            
            // foo = 1
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1),
            
            .label(L0)
        ])
    }
    
    func testCompileIfStatementIncludingElseBranch() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(0),
                           storage: .staticStorage,
                           isMutable: true),
            If(sourceAnchor: nil,
               condition: Expression.LiteralBool(true),
               then: ExprUtils.makeAssignment(name: "foo",
                                              right: Expression.LiteralInt(1)),
               else: ExprUtils.makeAssignment(name: "foo",
                                              right: Expression.LiteralInt(2)))
        ])
        let addressFoo = SnapToCrackleCompiler.kStaticStorageStartAddress
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = ".L0"
        let L1 = ".L1"
        XCTAssertEqual(compiler.instructions, [
            // foo = 0
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 0),
            .copyWordsIndirectDestination(t0, t1, 1),
            
            // the condition `true'
            .storeImmediate(t0, 1),
            
            // if the condition is equal to zero then jump to L0 (else)
            .jz(L0, t0),
            
            // foo = 1
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1),
            .jmp(L1),
            
            .label(L0),
            
            // foo = 2
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 2),
            .copyWordsIndirectDestination(t0, t1, 1),
            
            .label(L1)
        ])
    }
    
    func testCompileWhileStatement() {
        let ast = TopLevel(children: [
            While(condition: Expression.LiteralBool(true),
                  body: Expression.LiteralInt(2))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let head = ".L0"
        let tail = ".L1"
        XCTAssertEqual(compiler.instructions, [
            .label(head),
            .storeImmediate(t0, 1), // the condition `true'
            .jz(tail, t0),
            .storeImmediate(t0, 2),
            .jmp(head),
            .label(tail)
        ])
    }
    
    func testCompilationFailsDueToTypeErrorInExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: ExprUtils.makeAdd(left: ExprUtils.makeU8(value: 1),
                                                         right: ExprUtils.makeBool(value: true)),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "binary operator `+' cannot be applied to operands of types `u8' and `bool'")
    }
    
    func testCompileForLoopStatement() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(0),
                           storage: .staticStorage,
                           isMutable: true),
            ForLoop(initializerClause: VarDeclaration(identifier: Expression.Identifier("i"),
                                                      explicitType: nil,
                                                      expression: Expression.LiteralInt(0),
                                                      storage: .staticStorage,
                                                      isMutable: true),
                    conditionClause: ExprUtils.makeComparisonLt(left: Expression.Identifier("i"),
                                                                right: Expression.LiteralInt(10)),
                    incrementClause: ExprUtils.makeAssignment(name: "i", right: ExprUtils.makeAdd(left: Expression.Identifier("i"), right: Expression.LiteralInt(1))),
                    body: ExprUtils.makeAssignment(name: "foo", right: Expression.Identifier("i")))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = ".L0"
        let L1 = ".L1"
        let addressOfFoo: Int = kStaticStorageStartAddress+0
        let addressOfI: Int = kStaticStorageStartAddress+1
        let expected: [CrackleInstruction] = [
            // foo = 0
            .storeImmediate16(t0, addressOfFoo),
            .storeImmediate(t1, 0),
            .copyWordsIndirectDestination(t0, t1, 1),
            
            // i = 0
            .storeImmediate16(t0, addressOfI),
            .storeImmediate(t1, 0),
            .copyWordsIndirectDestination(t0, t1, 1),
            
            .label(".L0"),
            
            // Jump if the condition `i < 10' fails.
            .storeImmediate(t0, 10),
            .copyWords(t1, addressOfI, 1),
            .lt(t2, t1, t0),
            .jz(L1, t2),
            
            // foo = i
            .storeImmediate16(t0, addressOfFoo),
            .copyWords(t1, addressOfI, 1),
            .copyWordsIndirectDestination(t0, t1, 1),
            
            // i = i + 1
            .storeImmediate16(t0, addressOfI),
            .storeImmediate(t1, 1),
            .copyWords(t2, addressOfI, 1),
            .add(t3, t2, t1),
            .copyWordsIndirectDestination(t0, t3, 1),
            
            // Loop
            .jmp(L0),
            .label(L1)
        ]
        for i in 0..<expected.count {
            assert(compiler.instructions[i] == expected[i])
        }
        XCTAssertEqual(compiler.instructions, expected)
    }
    
    func testCompilationFailsBecauseLocalVarDoesntSurviveLocalScope() {
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: nil,
                               expression: Expression.LiteralInt(0),
                               storage: .staticStorage,
                               isMutable: true),
            ]),
            ExprUtils.makeAssignment(name: "foo", right: Expression.LiteralInt(0))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testCompileFunctionDeclaration_Simplest() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block())
        ])
        let compiler = SnapToCrackleCompiler()
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
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(0),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block(children: [
                                    ExprUtils.makeAssignment(name: "a", right: Expression.LiteralInt(1))
                                ])),
            Expression.Call(callee: Expression.Identifier("foo"),
                            arguments: [])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
    }
    
    func testCompilationFailsBecauseFunctionIsMissingAReturnStatement() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block())
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(ExprUtils.makeBool(value: true))
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnVoid() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(nil)
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "non-void function should return a value")
    }
    
    func testCompilationFailsBecauseCodeAfterReturnWillNeverBeExecuted() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(Expression.LiteralBool(true)),
                                    Expression.LiteralBool(false)
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "code after return will never be executed")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideIf() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    If(condition: tr,
                                       then: Return(tr),
                                       else: nil),
                                    Return(one)
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideElse() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    If(condition: tr,
                                       then: AbstractSyntaxTreeNode(),
                                       else: Return(tr)),
                                    Return(one)
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideWhile() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    While(condition: tr,
                                          body: Return(tr)),
                                    Return(one)
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompilationFailsBecauseFunctionReturnExpressionCannotBeConvertedToReturnType_ReturnInsideFor() {
        let tr = ExprUtils.makeBool(value: true)
        let one = ExprUtils.makeU8(value: 1)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    ForLoop(initializerClause: AbstractSyntaxTreeNode(),
                                            conditionClause: tr,
                                            incrementClause: AbstractSyntaxTreeNode(),
                                            body: Return(tr)),
                                    Return(one)
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert return expression of type `bool' to return type `u8'")
    }
    
    func testCompileFunctionWithReturnValueU8() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(Expression.LiteralInt(0xaa))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func testCompileFunctionWithReturnValueU16() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u16, arguments: []),
                                body: Block(children: [
                                    Return(Expression.LiteralInt(0xabcd))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0xabcd)
    }
    
    func testCompileFunctionWithReturnValueU8PromotedToU16() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u16, arguments: []),
                                body: Block(children: [
                                    Return(Expression.LiteralInt(0xaa))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0x00aa)
    }
    
    func testCompilationFailsBecauseThereExistsAPathMissingAReturn_1() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    If(sourceAnchor: nil,
                                       condition: Expression.LiteralBool(true),
                                       then: Return(Expression.LiteralInt(1)),
                                       else: nil)
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseThereExistsAPathMissingAReturn_2() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block())
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testCompilationFailsBecauseFunctionCallUsesIncorrectParameterType() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "a", type: .u8)]),
                                body: Block(children: [
                                    Return(ExprUtils.makeU8(value: 1))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("b"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: [ExprUtils.makeBool(value: true)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert value of type `bool' to expected argument type `u8' in call to `foo'")
    }
    
    func testCompilationFailsBecauseReturnIsInvalidOutsideFunction() {
        let ast = TopLevel(children: [
            Return(Expression.LiteralBool(true))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "return is invalid outside of a function")
    }
    
    func testUnexpectedNonVoidReturnValueInVoidFunction() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block(children: [
                                    Return(ExprUtils.makeU8(value: 1))
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected non-void return value in void function")
    }
    
    func testItIsCompletelyValidToHaveMeaninglessReturnStatementAtBottomOfVoidFunction() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block(children: [
                                    Return()
                                ]))
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
    }
    
    func testCompileFunctionWithParameters_1() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(children: [
                                    Return(Expression.Identifier("bar"))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: [ExprUtils.makeU8(value: 0xaa)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    // We take steps to ensure parameters and local variables do not overlap.
    func testCompileFunctionWithParameters_2() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("baz"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralInt(0xbb),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    Return(Expression.Identifier("bar"))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: [ExprUtils.makeU8(value: 0xaa)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func testCompileFunctionWithParameters_3_ConvertIntegerConstantsToMatchingConcreteTypes() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block(children: [
                                    Return(Expression.Identifier("bar"))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: [Expression.LiteralInt(0xaa)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func testCompileNestedFunction() {
        // This AST is equivalent to the following code:
        //    func foo() -> u8 {
        //        let a = 0xaa
        //        func bar() -> u8 {
        //            return a
        //        }
        //        return bar()
        //    }
        //    let a = foo()
        //
        // The variable `a' at the bottom is a static u8 var located at kStaticStorageStartAddress.
        // The variable `a' at the top is a stack local u8 var located at offset=1.
        // The stack is setup like so at the point where bar returns:
        //    0xffff -- Preserved temporary 0x0010
        //    0xfffe --   "
        //    0xfffd -- Stack local variable "__returnValue" from `foo'
        //    0xfffc -- Return address from `foo'
        //    0xfffb --  "
        //    0xfffa -- Preserved frame pointer
        //    0xfff9 --  "
        //    0xfff8 -- Stack local variable "a" in `foo'
        //    0xfff7 -- Preserved temporary 0x0014
        //    0xfff6 --  "
        //    0xfff5 -- Stack local variable "__returnValue" from `bar'
        //    0xfff4 -- Return address from `bar'
        //    0xfff3 --  "
        //    0xfff2 -- Preserved frame pointer
        //    0xfff1 --  "
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralInt(0xaa),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                                        functionType: FunctionType(returnType: .u8, arguments: []),
                                                        body: Block(children: [
                                                            Return(Expression.Identifier("a"))
                                                        ])),
                                    Return(Expression.Call(callee: Expression.Identifier("bar"),
                                                           arguments: []))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("foo"),
                                                       arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func testFunctionNamesAreNotUnique() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralInt(0xaa),
                                                   storage: .stackStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                                        functionType: FunctionType(returnType: .u8, arguments: []),
                                                        body: Block(children: [
                                                            Return(Expression.Identifier("a"))
                                                        ])),
                                    Return(Expression.Call(callee: Expression.Identifier("bar"),
                                                           arguments: []))
                                ])),
            FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(children: [
                                    Return(Expression.LiteralInt(0xbb))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("bar"),
                                                       arguments: []),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xbb)
    }
    
    func testMutuallyRecursiveFunctions() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("isEven"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "n", type: .u8)]),
                                body: Block(children: [
                                    If(condition: ExprUtils.makeComparisonEq(left: Expression.Identifier("n"),
                                                                             right: Expression.LiteralInt(0)),
                                       then: Block(children: [
                                        Return(Expression.LiteralBool(true))
                                       ]),
                                       else: Block(children: [
                                        Return(Expression.Call(callee: Expression.Identifier("isOdd"),
                                                               arguments: [ExprUtils.makeSub(left:  Expression.Identifier("n"), right: Expression.LiteralInt(1))]))
                                       ]))
                                ])),
            FunctionDeclaration(identifier: Expression.Identifier("isOdd"),
                                functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "n", type: .u8)]),
                                body: Block(children: [
                                    If(condition: ExprUtils.makeComparisonEq(left: Expression.Identifier("n"),
                                                                             right: Expression.LiteralInt(0)),
                                       then: Block(children: [Return(Expression.LiteralBool(false))]),
                                       else: Block(children: [
                                        Return(Expression.Call(callee: Expression.Identifier("isEven"),
                                                               arguments: [
                                                                ExprUtils.makeSub(left: Expression.Identifier("n"),
                                                                                  right: Expression.LiteralInt(1))
                                                ]))
                                       ]))
                                ])),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("isOdd"),
                                                       arguments: [Expression.LiteralInt(7)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
        }
    }
        
    func test_SixteenBitGreaterThan() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: ExprUtils.makeComparisonGt(left: Expression.LiteralInt(0x1000), right: Expression.LiteralInt(0x0001)),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
        }
    }
        
    func testCompilePeekMemory() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(0xaa),
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(identifier: Expression.Identifier("b"),
                           explicitType: nil,
                           expression: Expression.Call(callee: Expression.Identifier("peekMemory"),
                                                       arguments: [Expression.LiteralInt(kStaticStorageStartAddress)]),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            XCTAssertEqual(ir, [
                .storeImmediate16(t0, kStaticStorageStartAddress+0),
                .storeImmediate(t1, 0xaa),
                .copyWordsIndirectDestination(t0, t1, 1),
                .storeImmediate16(t0, kStaticStorageStartAddress+1),
                .storeImmediate16(t1, kStaticStorageStartAddress+0),
                .copyWordsIndirectSource(t2, t1, 1),
                .copyWordsIndirectDestination(t0, t2, 1)
            ])
            let executor = CrackleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 0xaa)
            XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 0xaa)
        }
    }
        
    func testCompilePokeMemory() {
        let ast = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier("pokeMemory"),
                            arguments: [Expression.LiteralInt(0xab),
                                        Expression.LiteralInt(kStaticStorageStartAddress)])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            XCTAssertEqual(ir, [
                .storeImmediate(t0, 0xab),
                .storeImmediate16(t1, kStaticStorageStartAddress),
                .copyWordsIndirectDestination(t1, t0, 1)
            ])
            let executor = CrackleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xab)
        }
    }
        
    func testCompilePokePeripheral() {
        let ast = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier("pokePeripheral"),
                            arguments: [
                                Expression.LiteralInt(0xff),
                                Expression.LiteralInt(0xffff),
                                Expression.LiteralInt(0)
            ]),
            Expression.Call(callee: Expression.Identifier("pokePeripheral"),
                            arguments: [
                                Expression.LiteralInt(0xff),
                                Expression.LiteralInt(0xffff),
                                Expression.LiteralInt(1)
            ])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.lowerInstructionRAM.load(from: 0xffff), 0xff)
            XCTAssertEqual(computer.upperInstructionRAM.load(from: 0xffff), 0xff)
        }
    }
        
    func testCompileHlt() {
        let ast = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier("pokeMemory"),
                            arguments: [Expression.LiteralInt(0xab),
                                        Expression.LiteralInt(kStaticStorageStartAddress)]),
            Expression.Call(callee: Expression.Identifier("hlt"),
                            arguments: []),
            Expression.Call(callee: Expression.Identifier("pokeMemory"),
                            arguments: [Expression.LiteralInt(0xcd),
                                        Expression.LiteralInt(kStaticStorageStartAddress)])
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(ir: ir)
            XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xab)
        }
    }
        
    func testCompileGetArrayLength() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("r"),
                           explicitType: .u16,
                           expression: Expression.LiteralInt(0),
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: .array(count: nil, elementType: .u8),
                           expression: Expression.LiteralArray(explicitType: .u8,
                                                               explicitCount: nil,
                                                               elements: [ExprUtils.makeU8(value: 1),
                                                                          ExprUtils.makeU8(value: 2),
                                                                          ExprUtils.makeU8(value: 3)]),
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(identifier: Expression.Identifier("b"),
                           explicitType: .dynamicArray(elementType: .u8),
                           expression: Expression.Identifier("a"),
                           storage: .staticStorage,
                           isMutable: false),
            Expression.Assignment(lexpr: Expression.Identifier("r"),
                                  rexpr: Expression.Get(sourceAnchor: nil,
                                                        expr: Expression.Identifier("b"),
                                                        member: Expression.Identifier("count")))
            
        ])
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 3)
    }
}
