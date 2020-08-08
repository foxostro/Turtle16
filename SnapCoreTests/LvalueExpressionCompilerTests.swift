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
    func compile(expression: Expression, symbols: SymbolTable = SymbolTable()) throws -> [CrackleInstruction] {
        let compiler = LvalueExpressionCompiler(symbols: symbols)
        let ir = try compiler.compile(expression: expression)
        return ir
    }
    
    func testCannotAssignToAnImmutableVariable() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: false)])
        XCTAssertThrowsError(try compile(expression: expr, symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot assign to immutable variable `foo'")
        }
    }
    
    func testAssignToMutableVariable() {
        let expr = Expression.Identifier("foo")
        let symbols = SymbolTable(["foo" : Symbol(type: .u8, offset: 0x0010, isMutable: true)])
        let ir = try! compile(expression: expr, symbols: symbols)
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0x0010)
    }
    
    func testCompileAssignmentThroughArraySubscript() {
        let expr = Expression.Subscript(identifier: Expression.Identifier("foo"),
                                        expr: Expression.LiteralInt(1))
        let symbols = SymbolTable(["foo" : Symbol(type: .array(count: 2, elementType: .bool), offset: 0x0010, isMutable: true)])
        var ir: [CrackleInstruction]? = nil
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        if ir == nil {
            XCTFail()
            return
        }
        let executor = CrackleExecutor()
        let computer = try! executor.execute(ir: ir!)
        XCTAssertEqual(computer.stack16(at: 0), 0x0011)
    }
    
    func testCompileDynamicArraySubscriptLvalueExpression() {
        let count = 5
        
        let addressOfPointer = 0x0010
        let addressOfCount = 0x0012
        let addressOfData = 0x0014
        
        let expr = Expression.Subscript(identifier: Expression.Identifier("foo"),
                                        expr: Expression.LiteralInt(2))
        
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u16), offset: addressOfPointer, isMutable: true),
            "bar" : Symbol(type: .array(count: count, elementType: .u16), offset: addressOfData, isMutable: true)
        ])
        
        var ir: [CrackleInstruction]? = nil
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        let executor = CrackleExecutor()
        if ir == nil {
            XCTFail()
            return
        }
        executor.configure = { computer in
            computer.dataRAM.store16(value: UInt16(addressOfData), to: addressOfPointer)
            computer.dataRAM.store16(value: UInt16(count), to: addressOfCount)
            for i in 0..<count {
                computer.dataRAM.store16(value: UInt16(0xbeef), to: addressOfData + i*SymbolType.u16.sizeof)
            }
        }
        let computer = try! executor.execute(ir: ir!)
        XCTAssertEqual(computer.stack16(at: 0), UInt16(addressOfData + 2*SymbolType.u16.sizeof))
    }
    
    func testOutOfBoundsLvalueArrayAccessCausesPanic_StaticArray() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .array(count: 1, elementType: .u8), offset: 0x0010, isMutable: true)
        ])
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(1))
        var ir: [CrackleInstruction] = []
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store(value: 0xcd, to: 0x0011)
        }
        let computer = try! executor.execute(ir: ir)
        
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
    
    func testLvalueDynamicArrayAccess_InBounds() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u8), offset: 0x0010, isMutable: true)
        ])
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(0))
        var ir: [CrackleInstruction] = []
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x0014, to: 0x0010)
            computer.dataRAM.store16(value: 1, to: 0x0012)
            computer.dataRAM.store(value: 0xcd, to: 0x0014)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0x0014)
    }
    
    func testOutOfBoundsLvalueArrayAccessCausesPanic_DynamicArray() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .dynamicArray(elementType: .u8), offset: 0x0010, isMutable: true)
        ])
        let expr = ExprUtils.makeSubscript(identifier: "foo", expr: Expression.LiteralInt(0))
        var ir: [CrackleInstruction] = []
        XCTAssertNoThrow(ir = try compile(expression: expr, symbols: symbols))
        let executor = CrackleExecutor()
        executor.configure = { computer in
            computer.dataRAM.store16(value: 0x0014, to: 0x0010)
            computer.dataRAM.store16(value: 0, to: 0x0012)
            computer.dataRAM.store(value: 0xcd, to: 0x0014)
        }
        let computer = try! executor.execute(ir: ir)
        
        XCTAssertEqual(computer.stack16(at: 0), 0xdead)
    }
}
