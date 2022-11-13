//
//  TackDebuggerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/8/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

final class TackDebuggerTests: XCTestCase {
    public func testLoadSymbolU8_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolU8("foo"))
    }
    
    public func testLoadSymbolU8_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolU8("foo"))
    }
    
    public func testLoadSymbolU8_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u8)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(value: 0xabcd, address: 100)
        XCTAssertEqual(0xcd, debugger.loadSymbolU8("foo"))
    }
    
    public func testLoadSymbolU16_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolU16("foo"))
    }
    
    public func testLoadSymbolU16_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u8)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolU16("foo"))
    }
    
    public func testLoadSymbolU16_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(value: 0xabcd, address: 100)
        XCTAssertEqual(0xabcd, debugger.loadSymbolU16("foo"))
    }
    
    public func testLoadSymbolI8_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolI8("foo"))
    }
    
    public func testLoadSymbolI8_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolI8("foo"))
    }
    
    public func testLoadSymbolI8_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.i8)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(value: 0xffff, address: 100)
        XCTAssertEqual(-1, debugger.loadSymbolI8("foo"))
    }
    
    public func testLoadSymbolI16_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolI16("foo"))
    }
    
    public func testLoadSymbolI16_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolI16("foo"))
    }
    
    public func testLoadSymbolI16_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.i16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(value: 0xffff, address: 100)
        XCTAssertEqual(-1, debugger.loadSymbolI16("foo"))
    }
    
    public func testLoadSymbolBool_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolBool("foo"))
    }
    
    public func testLoadSymbolBool_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolBool("foo"))
    }
    
    public func testLoadSymbolBool_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .bool(.immutableBool),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(value: 1, address: 100)
        XCTAssertEqual(true, debugger.loadSymbolBool("foo"))
    }
}
