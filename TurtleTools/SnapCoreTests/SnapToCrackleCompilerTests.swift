//
//  SnapToCrackleCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapToCrackleCompilerTests: XCTestCase {
    let t0 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 0
    let t1 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 2
    let t2 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 4
    let t3 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 6
    let kStaticStorageStartAddress = SnapCompilerMetrics.kStaticStorageStartAddress
    
    func compile(_ ast0: TopLevel,
                 isUsingStandardLibrary: Bool = false,
                 injectModules: [(String, String)] = []) -> SnapToCrackleCompiler {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let globalEnvironment = GlobalEnvironment()
        let contractionStep = SnapAbstractSyntaxTreeCompiler(memoryLayoutStrategy: memoryLayoutStrategy,
                                                             injectModules: injectModules,
                                                             isUsingStandardLibrary: isUsingStandardLibrary,
                                                             globalEnvironment: globalEnvironment)
        contractionStep.compile(ast0)
        if contractionStep.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: contractionStep.errors).message)
            XCTFail()
            return SnapToCrackleCompiler(memoryLayoutStrategy, globalEnvironment)
        }
        let ast1 = contractionStep.ast
        
        // Compile to Crackle IR
        let compiler = SnapToCrackleCompiler(memoryLayoutStrategy, globalEnvironment)
        compiler.compile(ast: ast1)
        
        return compiler
    }
    
    func testNoErrorsAtFirst() {
        let compiler = SnapToCrackleCompiler()
        XCTAssertFalse(compiler.hasError)
        XCTAssertTrue(compiler.errors.isEmpty)
    }
    
    func testCompileEmptyProgram() {
        let compiler = SnapToCrackleCompiler()
        compiler.compile(ast: Block(children: []))
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
        let compiler = compile(ast)
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .constU8, offset: addressFoo))
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
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        let addressBar = SnapCompilerMetrics.kStaticStorageStartAddress+1
        let compiler = compile(ast)
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
        XCTAssertEqual(symbol, Symbol(type: .constU8, offset: addressBar))
    }
    
    func testCompileConstantDeclaration_TypeIsInferredFromTheExpression() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralBool(true),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .constBool, offset: addressFoo))
    }
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ImplicitType() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u8)),
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
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        let compiler = compile(ast)
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
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .constU8), offset: addressFoo))
    }
    
    func testCompileConstantDeclaration_ArrayWithStaticStorage_ExplicitType() {
        let expr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u8)),
                                           elements: [Expression.LiteralInt(0),
                                                      Expression.LiteralInt(1),
                                                      Expression.LiteralInt(2)])
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                           expression: expr,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        let compiler = compile(ast)
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
        XCTAssertEqual(symbol, Symbol(type: .array(count: 3, elementType: .constU8), offset: addressFoo))
    }
    
    func testCompileConstantDeclaration_CannotAssignFunctionToArray() {
        let functionType = Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.bool), arguments: [
            Expression.PrimitiveType(.u8),
            Expression.PrimitiveType(.u16)
        ])
        let arrayType = Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16))
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: functionType,
                                argumentNames: ["a", "b"],
                                body: Block(children: [
                                    Return(ExprUtils.makeBool(value: true))
                                ])),
            VarDeclaration(sourceAnchor: nil,
                           identifier: Expression.Identifier("bar"),
                           explicitType: arrayType,
                           expression: Expression.Identifier("foo"),
                           storage: .staticStorage,
                           isMutable: true)
        ])
        let compiler = compile(ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "inappropriate use of a function type (Try taking the function's address instead.)")
    }
    
    func testCompileConstantDeclaration_AssignStringLiteralToDynamicArray() {
        let elements = "Hello, World!".utf8.map({
            Expression.LiteralInt(Int($0))
        })
        let arrayType = Expression.ArrayType(count: Expression.LiteralInt(elements.count),
                                             elementType: Expression.PrimitiveType(.u8))
        let stringLiteral = Expression.LiteralArray(arrayType: arrayType,
                                                    elements: elements)
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: Expression.DynamicArrayType(Expression.PrimitiveType(.u8)),
                           expression: stringLiteral,
                           storage: .staticStorage,
                           isMutable: false)
        ])
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .constDynamicArray(elementType: .u8), offset: addressFoo))
        
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        
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
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .u8, offset: addressFoo))
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
        
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        var symbolFoo: Symbol? = nil
        XCTAssertNoThrow(symbolFoo = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbolFoo, Symbol(type: .u16, offset: addressFoo))
        
        let addressBar = SnapCompilerMetrics.kStaticStorageStartAddress+2
        var symbolBar: Symbol? = nil
        XCTAssertNoThrow(symbolBar = try compiler.globalSymbols.resolve(identifier: "bar"))
        XCTAssertEqual(symbolBar, Symbol(type: .u16, offset: addressBar))
        
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate16(t1, 0xabcd),
            .copyWordsIndirectDestination(t0, t1, 2),
            .storeImmediate16(t0, addressBar),
            .storeImmediate16(t1, 0xabcd),
            .copyWordsIndirectDestination(t0, t1, 2)
        ])
    }
    
    func testCompileVarDeclaration_LocalVarsAreAllocatedStorageInOrderInTheStackFrame_1() {
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        let three = Expression.LiteralInt(3)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                argumentNames: [],
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: one,
                                                   storage: .automaticStorage,
                                                   isMutable: false),
                                    VarDeclaration(identifier: Expression.Identifier("b"),
                                                   explicitType: nil,
                                                   expression: two,
                                                   storage: .automaticStorage,
                                                   isMutable: false),
                                    VarDeclaration(identifier: Expression.Identifier("c"),
                                                   explicitType: nil,
                                                   expression: three,
                                                   storage: .automaticStorage,
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 2)
    }
    
    func testCompileVarDeclaration_LocalVarsAreAllocatedStorageInOrderInTheStackFrame_2() {
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        let three = Expression.LiteralInt(3)
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                argumentNames: [],
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: one,
                                                   storage: .automaticStorage,
                                                   isMutable: false),
                                    Block(children: [
                                        VarDeclaration(identifier: Expression.Identifier("b"),
                                                       explicitType: nil,
                                                       expression: two,
                                                       storage: .automaticStorage,
                                                       isMutable: false),
                                        Block(children: [
                                            VarDeclaration(identifier: Expression.Identifier("c"),
                                                           explicitType: nil,
                                                           expression: three,
                                                           storage: .automaticStorage,
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
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
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress+0
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate16(t0, addressFoo),
            .storeImmediate(t1, 1),
            .copyWordsIndirectDestination(t0, t1, 1)
        ])
        var symbol: Symbol? = nil
        XCTAssertNoThrow(symbol = try compiler.globalSymbols.resolve(identifier: "foo"))
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: addressFoo))
    }
    
    func testCompileVarDeclaration_ConvertLiteralArrayTypeOnDeclaration() {
        let arr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u16)),
                                          elements: [Expression.LiteralInt(1000),
                                                     ExprUtils.makeU8(value: 1),
                                                     ExprUtils.makeU8(value: 2)])
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)),
                               expression: arr,
                               storage: .automaticStorage,
                               isMutable: false)
            ])
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+2), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+4), 2)
    }
    
    func testCompileVarDeclaration_ArrayOfUndefinedValue() {
        let ast = TopLevel(children: [
            Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: Expression.ArrayType(count: Expression.LiteralInt(100), elementType: Expression.PrimitiveType(.u16)),
                               expression: nil,
                               storage: .automaticStorage,
                               isMutable: false)
            ])
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
    }
    
    func testCompileVarDeclaration_EmptyStructOfUndefinedValue() {
        let ast = TopLevel(children: [
            Block(children: [
                StructDeclaration(identifier: Expression.Identifier("bar"),
                                  members: []),
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: Expression.Identifier("bar"),
                               expression: nil,
                               storage: .automaticStorage,
                               isMutable: false)
            ])
        ])
        let compiler = compile(ast)
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [
            .storeImmediate(t0, 1)
        ])
    }
    
    func testCompileExpressionStatement_ArrayOfU8() {
        let t0 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 0
        let t1 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 4
        
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u8)),
                                    elements: [Expression.LiteralInt(0xa),
                                               Expression.LiteralInt(0xb),
                                               Expression.LiteralInt(0xc)])
        ])
        let compiler = compile(ast)
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
        let t0 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 0
        let t1 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 6
        
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u16)),
                                    elements: [ExprUtils.makeU16(value: 0xaaaa),
                                               ExprUtils.makeU16(value: 0xbbbb),
                                               ExprUtils.makeU16(value: 0xcccc)])
        ])
        let compiler = compile(ast)
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
        let t0 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 0
        let t1 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 6
        let t2 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 12
        let t3 = SnapCompilerMetrics.kTemporaryStorageStartAddress + 18
        
        // The expression compiler contains more detailed tests. This is more
        // for testing integration between the two classes.
        // When an expression is compiled as an independent statement, the
        // result on the top of the expression stack and must be cleaned up at
        // the end of the statement.
        let ast = TopLevel(children: [
            Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u16))),
                                    elements: [
                Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u16)),
                                        elements: [ExprUtils.makeU16(value: 0xaaaa),
                                                   ExprUtils.makeU16(value: 0xbbbb),
                                                   ExprUtils.makeU16(value: 0xcccc)]),
                Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(3), elementType: Expression.PrimitiveType(.u16)),
                                        elements: [ExprUtils.makeU16(value: 0xdddd),
                                                   ExprUtils.makeU16(value: 0xeeee),
                                                   ExprUtils.makeU16(value: 0xffff)])
            ])
        ])
        let compiler = compile(ast)
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
        
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = compile(ast)
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
        let addressFoo = SnapCompilerMetrics.kStaticStorageStartAddress
        let compiler = compile(ast)
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
        let compiler = compile(ast)
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
        let compiler = compile(ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testCompileFunctionDeclaration_Simplest() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                argumentNames: [],
                                body: Block())
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let L0 = "foo"
        let L1 = "__foo_tail"
        XCTAssertEqual(compiler.instructions, [
            .jmp(L1),
            .label(L0),
            .pushReturnAddress,
            .enter(0),
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
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                argumentNames: [],
                                body: Block(children: [
                                    ExprUtils.makeAssignment(name: "a", right: Expression.LiteralInt(1))
                                ])),
            Expression.Call(callee: Expression.Identifier("foo"),
                            arguments: [])
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
    }
    
    func testCompileFunctionWithReturnValueU8() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                argumentNames: [],
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func testCompileFunctionWithReturnValueU16() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u16), arguments: []),
                                argumentNames: [],
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0xabcd)
    }
    
    func testCompileFunctionWithReturnValueU8PromotedToU16() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u16), arguments: []),
                                argumentNames: [],
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0x00aa)
    }
    
    func testItIsCompletelyValidToHaveMeaninglessReturnStatementAtBottomOfVoidFunction() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                argumentNames: [],
                                body: Block(children: [
                                    Return()
                                ]))
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
    }
    
    func testCompileFunctionWithParameters_1() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PrimitiveType(.u8)]),
                                argumentNames: ["bar"],
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    // We take steps to ensure parameters and local variables do not overlap.
    func testCompileFunctionWithParameters_2() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PrimitiveType(.u8)]),
                                argumentNames: ["bar"],
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("baz"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralInt(0xbb),
                                                   storage: .automaticStorage,
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func testCompileFunctionWithParameters_3_ConvertIntegerConstantsToMatchingConcreteTypes() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PrimitiveType(.u8)]),
                                argumentNames: ["bar"],
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
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
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                argumentNames: [],
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralInt(0xaa),
                                                   storage: .automaticStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                                        functionType: Expression.FunctionType(name: "bar", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                                        argumentNames: [],
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func testFunctionNamesAreNotUnique() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                argumentNames: [],
                                body: Block(children: [
                                    VarDeclaration(identifier: Expression.Identifier("a"),
                                                   explicitType: nil,
                                                   expression: Expression.LiteralInt(0xaa),
                                                   storage: .automaticStorage,
                                                   isMutable: false),
                                    FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                                        functionType: Expression.FunctionType(name: "bar", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                                        argumentNames: [],
                                                        body: Block(children: [
                                                            Return(Expression.Identifier("a"))
                                                        ])),
                                    Return(Expression.Call(callee: Expression.Identifier("bar"),
                                                           arguments: []))
                                ])),
            FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                functionType: Expression.FunctionType(name: "bar", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                argumentNames: [],
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
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xbb)
    }
    
    func testMutuallyRecursiveFunctions() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("isEven"),
                                functionType: Expression.FunctionType(name: "isEven", returnType: Expression.PrimitiveType(.bool), arguments: [Expression.PrimitiveType(.u8)]),
                                argumentNames: ["n"],
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
                                functionType: Expression.FunctionType(name: "isOdd", returnType: Expression.PrimitiveType(.bool), arguments: [Expression.PrimitiveType(.u8)]),
                                argumentNames: ["n"],
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
        
        let compiler = compile(ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(crackle: ir)
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
        
        let compiler = compile(ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(crackle: ir)
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
        let compiler = compile(ast)
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
            let computer = try! executor.execute(crackle: ir)
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
        let compiler = compile(ast)
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
            let computer = try! executor.execute(crackle: ir)
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
        let compiler = compile(ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(crackle: ir)
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
        let compiler = compile(ast)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            XCTFail()
        } else {
            let ir = compiler.instructions
            let executor = CrackleExecutor()
            let computer = try! executor.execute(crackle: ir)
            XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xab)
        }
    }
        
    func testCompileGetArrayLength() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("r"),
                           explicitType: Expression.PrimitiveType(.u16),
                           expression: Expression.LiteralInt(0),
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("a"),
                           explicitType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                           expression: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                               elements: [ExprUtils.makeU8(value: 1),
                                                                          ExprUtils.makeU8(value: 2),
                                                                          ExprUtils.makeU8(value: 3)]),
                           storage: .staticStorage,
                           isMutable: false),
            VarDeclaration(identifier: Expression.Identifier("b"),
                           explicitType: Expression.DynamicArrayType(Expression.PrimitiveType(.u8)),
                           expression: Expression.Identifier("a"),
                           storage: .staticStorage,
                           isMutable: false),
            Expression.Assignment(lexpr: Expression.Identifier("r"),
                                  rexpr: Expression.Get(sourceAnchor: nil,
                                                        expr: Expression.Identifier("b"),
                                                        member: Expression.Identifier("count")))
            
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 3)
    }
        
    func testCompileEmptyStructAddsToTypeTable() {
        let ast = TopLevel(children: [
            StructDeclaration(identifier: Expression.Identifier("foo"), members: [])
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let symbolType = try! compiler.globalSymbols.resolveType(identifier: "foo")
        
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.enclosingFunctionNameMode = .set("foo")
        let expected: SymbolType = .structType(StructType(name: "foo", symbols: expectedStructSymbols))
        
        XCTAssertEqual(symbolType, expected)
    }
        
    func testCompileStructAddsToTypeTable() {
        let ast = TopLevel(children: [
            StructDeclaration(identifier: Expression.Identifier("foo"), members: [
                StructDeclaration.Member(name: "bar", type: Expression.PrimitiveType(.u8))
            ])
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let symbolType = try! compiler.globalSymbols.resolveType(identifier: "foo")
        
        let expectedSymbols = SymbolTable(tuples: [
            ("bar", Symbol(type: .u8, offset: 0, storage: .automaticStorage))
        ])
        expectedSymbols.enclosingFunctionNameMode = .set("foo")
        expectedSymbols.storagePointer = 1
        let expected: SymbolType = .structType(StructType(name: "foo", symbols: expectedSymbols))
        
        XCTAssertEqual(symbolType, expected)
    }
    
    func testCompileConstantDeclaration_PointerToU8_UndefinedValueAtInitialization() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: Expression.PointerType(Expression.PrimitiveType(.u8)),
                           expression: nil,
                           storage: .automaticStorage,
                           isMutable: false)
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        // The value of the pointer is undefined. Don't test it.
        // It's enough to check that the expression compiles.
    }
    
    func testCompileConstantDeclaration_PointerToU8_GivenAddressOfAnotherVariable() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: Expression.PrimitiveType(.u8),
                           expression: Expression.LiteralInt(42),
                           storage: .automaticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("bar"),
                           explicitType: Expression.PointerType(Expression.PrimitiveType(.u8)),
                           expression: Expression.Unary(op: .ampersand, expression: Expression.Identifier("foo")),
                           storage: .automaticStorage,
                           isMutable: true)
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+1), UInt16(kStaticStorageStartAddress))
    }
    
    func testCompileCallStructMemberFunction() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("result"),
                           explicitType: Expression.PrimitiveType(.u8),
                           expression: Expression.LiteralInt(0),
                           storage: .automaticStorage,
                           isMutable: true),
            StructDeclaration(identifier: Expression.Identifier("Foo"), members: []),
            Impl(identifier: Expression.Identifier("Foo"),
                 children: [
                    FunctionDeclaration(identifier: Expression.Identifier("baz"),
                                        functionType: Expression.FunctionType(name: "baz", returnType: Expression.PrimitiveType(.void), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: [
                                            Expression.Assignment(lexpr: Expression.Identifier("result"), rexpr: Expression.LiteralInt(42))
                                        ]))
                 ]),
            Expression.Call(callee: Expression.Get(expr: Expression.Identifier("Foo"), member: Expression.Identifier("baz")), arguments: [])
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 42)
    }
    
    func testFailCompileIfStatementWithNonbooleanCondition() {
        let ast = TopLevel(children: [
            If(condition: Expression.LiteralInt(0),
               then: Block(children: []),
               else: nil)
        ])
        let compiler = compile(ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert value of type `integer constant 0' to type `bool'")
    }
    
    func testFailToCompileAssertStatementWithNonbooleanCondition() {
        let ast = TopLevel(children: [
            Assert(condition: Expression.LiteralInt(0), message: "0")
        ])
        let compiler = compile(ast)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "binary operator `==' cannot be applied to operands of types `integer constant 0' and `boolean constant false'")
    }
    
    func testPassingAssertDoesNothing() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("panic"), functionType: Expression.FunctionType(name: "panic", returnType: Expression.PrimitiveType(.void), arguments: [Expression.DynamicArrayType(Expression.PrimitiveType(.u8))]), argumentNames: ["s"], body: Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                      rexpr: Expression.LiteralInt(2)),
                Expression.Call(callee: Expression.Identifier("hlt"), arguments: [])
            ])),
            Assert(condition: Expression.LiteralBool(true), message: "true"),
            Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                  rexpr: Expression.LiteralInt(42))
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        executor.injectPanicStub = false
        let computer = try! executor.execute(crackle: ir)
        
        let addressOfFoo = try! compiler.globalSymbols.resolve(identifier: "foo").offset
        XCTAssertEqual(computer.dataRAM.load(from: addressOfFoo), 42)
    }
    
    func testFailingAssertPanics() {
        let ast = TopLevel(children: [
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.LiteralInt(1),
                           storage: .staticStorage,
                           isMutable: true),
            FunctionDeclaration(identifier: Expression.Identifier("panic"), functionType: Expression.FunctionType(name: "panic", returnType: Expression.PrimitiveType(.void), arguments: [Expression.DynamicArrayType(Expression.PrimitiveType(.u8))]), argumentNames: ["s"], body: Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                      rexpr: Expression.LiteralInt(2)),
                Expression.Call(callee: Expression.Identifier("hlt"), arguments: [])
            ])),
            Assert(condition: Expression.LiteralBool(false), message: "false"),
            Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                  rexpr: Expression.LiteralInt(42))
        ])
        
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        executor.injectPanicStub = false
        let computer = try! executor.execute(crackle: ir)
        
        let addressOfFoo = try! compiler.globalSymbols.resolve(identifier: "foo").offset
        XCTAssertEqual(computer.dataRAM.load(from: addressOfFoo), 2)
    }
    
    func testDeclareAFunctionPointerVariable() {
        let ast = TopLevel(children: [
            FunctionDeclaration(identifier: Expression.Identifier("myfunc"), functionType: Expression.FunctionType(name: "myfunc", returnType: .PrimitiveType(.void), arguments: []), argumentNames: [], body: Block()),
            VarDeclaration(identifier: Expression.Identifier("foo"),
                           explicitType: nil,
                           expression: Expression.Unary(op: .ampersand, expression: Expression.Identifier("myfunc")),
                           storage: .automaticStorage,
                           isMutable: true)
        ])
        let compiler = compile(ast)
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return
        }
        let ir = compiler.instructions
        let executor = CrackleExecutor()
        let computer = try! executor.execute(crackle: ir)
        
        let addressOfFoo = try! compiler.globalSymbols.resolve(identifier: "foo").offset
        XCTAssertEqual(computer.dataRAM.load16(from: addressOfFoo), 10)
    }
}
