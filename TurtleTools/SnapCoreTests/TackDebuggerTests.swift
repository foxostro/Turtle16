//
//  TackDebuggerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/8/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class TackDebuggerTests: XCTestCase {
    fileprivate let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()
    
    fileprivate struct Options {
        public let isVerboseLogging: Bool
        public let isBoundsCheckEnabled: Bool
        public let isUsingStandardLibrary: Bool
        public let runtimeSupport: String?
        public let shouldRunSpecificTest: String?
        public let onSerialOutput: (UInt8) -> Void
        public let injectModules: [String:String]
        
        public init(isVerboseLogging: Bool = false,
                    isBoundsCheckEnabled: Bool = false,
                    isUsingStandardLibrary: Bool = false,
                    runtimeSupport: String? = nil,
                    shouldRunSpecificTest: String? = nil,
                    onSerialOutput: @escaping (UInt8) -> Void = {_ in},
                    injectModules: [String:String] = [:]) {
            self.isVerboseLogging = isVerboseLogging
            self.isBoundsCheckEnabled = isBoundsCheckEnabled
            self.isUsingStandardLibrary = isUsingStandardLibrary
            self.runtimeSupport = runtimeSupport
            self.shouldRunSpecificTest = shouldRunSpecificTest
            self.onSerialOutput = onSerialOutput
            self.injectModules = injectModules
        }
    }

    fileprivate func makeDebugger(options: Options, program: String) throws -> TackDebugger {
        let opts2 = SnapCompilerFrontEnd.Options(
            isBoundsCheckEnabled: options.isBoundsCheckEnabled,
            isUsingStandardLibrary: options.isUsingStandardLibrary,
            runtimeSupport: options.runtimeSupport,
            shouldRunSpecificTest: options.shouldRunSpecificTest,
            injectedModules: options.injectModules)
        
        let compiler = SnapCompilerFrontEnd(
            options: opts2,
            memoryLayoutStrategy: memoryLayoutStrategy)
        
        let tackProgram: TackProgram
        do {
            tackProgram = try compiler.compile(program: program)
        }
        catch (let error as CompilerError) {
            let omnibusError = CompilerError.makeOmnibusError(fileName: nil, errors: [error])
            print("compile error: \(omnibusError.message)")
            throw error
        }

        if options.isVerboseLogging {
            print("Listing:\n\(tackProgram.listing)")
        }
        
        let vm = TackVirtualMachine(tackProgram)
        vm.onSerialOutput = options.onSerialOutput

        let debugger = TackDebugger(vm, memoryLayoutStrategy)
        debugger.symbolsOfTopLevelScope = compiler.symbolsOfTopLevelScope

        return debugger
    }

    fileprivate func run(options: Options = Options(), program: String) throws -> TackDebugger {
        let debugger = try makeDebugger(options: options, program: program)
        try debugger.vm.run()
        return debugger
    }
    
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u8)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(b: 0xcd, address: 100)
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(w: 0xabcd, address: 100)
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.i8)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(b: 0xff, address: 100)
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.i16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(w: 0xffff, address: 100)
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
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
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .constBool,
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(o: true, address: 100)
        XCTAssertEqual(true, debugger.loadSymbolBool("foo"))
    }
    
    public func testLoadSymbolPointer_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolPointer("foo"))
    }
    
    public func testLoadSymbolPointer_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolPointer("foo"))
    }
    
    public func testLoadSymbolPointer_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .pointer(.arithmeticType(.immutableInt(.u16))),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(w: 0xabcd, address: 100)
        XCTAssertEqual(0xabcd, debugger.loadSymbolPointer("foo"))
    }
    
    public func testLoadSymbolArrayOfU8_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolArrayOfU8(3, "foo"))
    }
    
    public func testLoadSymbolSymbolArrayOfU8_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolArrayOfU8(3, "foo"))
    }
    
    public func testLoadSymbolSymbolArrayOfU8_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .arithmeticType(.immutableInt(.u8))),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(b: 0xaa, address: 100)
        debugger.vm.store(b: 0xbb, address: 101)
        debugger.vm.store(b: 0xcc, address: 102)
        XCTAssertEqual([0xaa, 0xbb, 0xcc], debugger.loadSymbolArrayOfU8(3, "foo"))
    }
    
    public func testLoadSymbolArrayOfU16_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolArrayOfU16(3, "foo"))
    }
    
    public func testLoadSymbolArrayOfU16_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolArrayOfU16(3, "foo"))
    }
    
    public func testLoadSymbolArrayOfU16_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .arithmeticType(.immutableInt(.u16))),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(w: 0xaaaa, address: 100)
        debugger.vm.store(w: 0xbbbb, address: 101)
        debugger.vm.store(w: 0xcccc, address: 102)
        XCTAssertEqual([0xaaaa, 0xbbbb, 0xcccc], debugger.loadSymbolArrayOfU16(3, "foo"))
    }
    
    public func testLoadSymbolString_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolString("foo"))
    }
    
    public func testLoadSymbolString_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.immutableInt(.u16)),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolString("foo"))
    }
    
    public func testLoadSymbolString_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .arithmeticType(.immutableInt(.u8))),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(b: 65, address: 100)
        debugger.vm.store(b: 66, address: 101)
        debugger.vm.store(b: 67, address: 102)
        XCTAssertEqual("ABC", debugger.loadSymbolString("foo"))
    }
    
    public func testLoadSymbolStringSlice_NotFound() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertNil(debugger.loadSymbolStringSlice("foo"))
    }
    
    public func testLoadSymbolStringSlice_WrongType() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .array(count: 3, elementType: .arithmeticType(.immutableInt(.u8))),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        XCTAssertNil(debugger.loadSymbolStringSlice("foo"))
    }
    
    public func testLoadSymbolStringSlice_Success() {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        debugger.symbolsOfTopLevelScope = SymbolTable(tuples: [
            ("foo", Symbol(type: .dynamicArray(elementType: .arithmeticType(.immutableInt(.u8))),
                           offset: 100,
                           storage: .staticStorage,
                           visibility: .publicVisibility))
        ])
        debugger.vm.store(w: 200, address: 100)
        debugger.vm.store(w:   3, address: 101)
        debugger.vm.store(b:  65, address: 200)
        debugger.vm.store(b:  66, address: 201)
        debugger.vm.store(b:  67, address: 202)
        XCTAssertEqual("ABC", debugger.loadSymbolStringSlice("foo"))
    }
    
    func testLoadSymbolWhileStoppedAtBreakpoint() throws {
        let debugger = try run(program: """
            func foo() {
                var bar: u16 = 0xabcd
                asm("BREAK")
            }
            foo()
            """)
        
        XCTAssertEqual(debugger.loadSymbolU16("bar"), 0xabcd)
    }
    
    func testShowSourceEmptyProgram() throws {
        let tackProgram = TackProgram()
        let vm = TackVirtualMachine(tackProgram)
        let debugger = TackDebugger(vm)
        XCTAssertEqual(debugger.showSourceList(pc: debugger.vm.pc, count: 5), nil)
    }
    
    func testShowSourceList() throws {
        let debugger = try run(program: """
            func foo() {
                asm("BREAK")
                var bar: u16 = 0xabcd
            }
            foo()
            """)
        
        XCTAssertEqual(debugger.showSourceList(pc: debugger.vm.pc, count: 5), """
                2	->	    var bar: u16 = 0xabcd
                3		}
                4		foo()
            
            """)
    }
    
    func testShowFunctionName_NotInFunction() throws {
        let debugger = try run(program: """
            let a = 1
            """)
        
        XCTAssertNil(debugger.showFunctionName(pc: 0))
    }
    
    func testShowFunctionName() throws {
        let opts = Options()
        let debugger = try run(options: opts, program: """
            func foo() {
                asm("BREAK")
                var bar: u16 = 0xabcd
            }
            foo()
            """)
        
        XCTAssertEqual(debugger.showFunctionName(pc: debugger.vm.pc), "foo")
    }
    
    func testSymbolicatedBacktrace_TopLevel() throws {
        let opts = Options()
        let debugger = try run(options: opts, program: """
            let a = 1
            asm("BREAK")
            """)
        
        XCTAssertEqual(debugger.symbolicatedBacktrace, [])
    }
    
    func testSymbolicatedBacktrace() throws {
        let opts = Options()
        let debugger = try run(options: opts, program: """
            func baz() {
                asm("BREAK")
            }
            func bar() {
                baz()
            }
            func foo() {
                bar()
            }
            foo()
            """)
        
        XCTAssertEqual(debugger.symbolicatedBacktrace, ["foo", "bar", "baz"])
    }
    
    func testFormattedBacktrace() throws {
        let opts = Options()
        let debugger = try run(options: opts, program: """
            func baz() {
                asm("BREAK")
            }
            func bar() {
                baz()
            }
            func foo() {
                bar()
            }
            foo()
            """)
        
        XCTAssertEqual(debugger.formattedBacktrace, """
            0	foo
            1	bar
            2	baz
            """)
    }
}
