//
//  LvalueExpressionCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class LvalueExpressionCompilerTests: XCTestCase {
    let t0 = SnapToCrackleCompiler.kTemporaryStorageStartAddress + 0
    
    func compile(expression: Expression, symbols: SymbolTable = SymbolTable()) throws -> [CrackleInstruction] {
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try compiler.compile(expression: expression)
        return ir
    }
    
    func testCannotAssignToAnImmutableVariable() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0100, isMutable: false)])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to immutable variable `foo'")
        }
    }
    
    func testCannotAssignToAnImmutableVariableExceptOnInitialAssignment() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0100, isMutable: false)])
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x0100)
        ]
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        compiler.shouldIgnoreMutabilityRules = true
        let actual = try! compiler.compile(expression: expr)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 0x0100)
    }
    
    func testAssignToMutableVariable() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0100, isMutable: true)])
        let expected: [CrackleInstruction] = [
            .storeImmediate16(t0, 0x0100)
        ]
        let actual = try! compile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: actual)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(computer.dataRAM.load16(from: t0), 0x0100)
    }
    
    func testCompileAssignmentThroughArraySubscript() {
        let expr = Expression.Subscript(identifier: Expression.Identifier("foo"),
                                        expr: Expression.LiteralInt(1))
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 2, elementType: .bool), offset: 0x0100, isMutable: true)])
        
        // We don't really care about the exact sequence of instructions which
        // computes this address so long as it is computed. Look at the compiler
        // temporaries stack to determine which temporary contains the lvalue.
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try! compiler.compile(expression: expr)
        let dst = compiler.temporaryStack.pop()
        
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: dst.address), 0x0101)
    }
    
    func testCompileDynamicArraySubscriptLvalueExpression() {
        let count = 5
        
        let addressOfPointer = 0x0100
        let addressOfCount = 0x0102
        let addressOfData = 0x0104
        
        let expr = Expression.Subscript(identifier: Expression.Identifier("foo"),
                                        expr: Expression.LiteralInt(2))
        
        let expected = UInt16(addressOfData + 2*SymbolType.u16.sizeof)
        
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u16), offset: addressOfPointer, isMutable: true),
            "bar" : Symbol(type: .array(count: count, elementType: .u16), offset: addressOfData, isMutable: true)
        ])
        
        // We don't really care about the exact sequence of instructions which
        // computes this address so long as it is computed. Look at the compiler
        // temporaries stack to determine which temporary contains the lvalue.
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try! compiler.compile(expression: expr)
        let dst = compiler.temporaryStack.pop()
        
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(addressOfData), to: addressOfPointer)
            computer.dataRAM.store16(value: UInt16(count), to: addressOfCount)
            for i in 0..<count {
                computer.dataRAM.store16(value: UInt16(0xbeef), to: addressOfData + i*SymbolType.u16.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: dst.address), expected)
    }
    
    func testOutOfBoundsLvalueArrayAccessCausesPanic_StaticArray() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0100, isMutable: true)
        ])
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(1))
        var ir: [CrackleInstruction] = []
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0xcd, to: 0x0101)
        }
        let computer = try! executor.execute(ir: ir)
        
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testOutOfBoundsLvalueArrayAccessCausesPanic_DynamicArray() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u8), offset: 0x0100, isMutable: true)
        ])
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(0))
        var ir: [CrackleInstruction] = []
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x0104, to: 0x0100)
            computer.dataRAM.store16(value: 0, to: 0x0102)
            computer.dataRAM.store(value: 0xcd, to: 0x0104)
        }
        let computer = try! executor.execute(ir: ir)
        
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testGetLvalueFromMemberOfStruct_1() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u16, offset: 0, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: offset, isMutable: true)
        ])
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try! compiler.compile(expression: expr)
        let dst = compiler.temporaryStack.pop()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: dst.address), UInt16(offset+0))
    }
    
    func testGetLvalueFromMemberOfStruct_2() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("baz"))
        let offset = 0x0100
        let typ = StructType(name: "foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .structType(typ), offset: offset, isMutable: true)
        ])
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try! compiler.compile(expression: expr)
        let dst = compiler.temporaryStack.pop()
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: dst.address), UInt16(offset+1))
    }
    
    func testLvalueOfPointerToU8() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.u8), offset: 0x0100, isMutable: true),
            "bar" : Symbol(type: .u8, offset: 0x0102, isMutable: false)
        ])
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try! compiler.compile(expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x0102, to: 0x0100)
            computer.dataRAM.store(value: 0x2a, to: 0x0102)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 0x0100)
    }
    
    func testDereferencePointerToU8() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("pointee"))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.u8), offset: 0x0100, isMutable: true),
            "bar" : Symbol(type: .u8, offset: 0x0102, isMutable: true)
        ])
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try! compiler.compile(expression: expr)
        let tempResult = compiler.temporaryStack.peek()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x0102, to: 0x0100)
            computer.dataRAM.store(value: 0x2a, to: 0x0102)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: tempResult.address), 0x0102)
    }
    
    func testGetLvalueOfNonexistentMemberOfStructThroughPointer() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("asdf"))
        let offset = 0x0100
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.structType(typ)), offset: offset, isMutable: true)
        ])
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        XCTAssertThrowsError(try compiler.compile(expression: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "value of type `*Foo' has no member `asdf'")
        }
    }
    
    func testGetLvalueOfFirstMemberOfStructThroughPointer() {
        let expr = Expression.Get(expr: Expression.Identifier("foo"),
                                  member: Expression.Identifier("bar"))
        let offset = 0x0100
        let typ = StructType(name: "Foo", symbols: SymbolTable([
            "bar" : Symbol(type: .u8, offset: 0, isMutable: true),
            "baz" : Symbol(type: .u16, offset: 1, isMutable: true)
        ]))
        let symbols = SymbolTable([
            "foo" : Symbol(type: .pointer(.structType(typ)), offset: offset, isMutable: true)
        ])
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try! compiler.compile(expression: expr)
        let dst = compiler.temporaryStack.pop()
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x1000, to: offset)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: dst.address), 0x1000)
    }
}
