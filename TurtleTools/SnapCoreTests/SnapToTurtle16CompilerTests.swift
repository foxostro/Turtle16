//
//  SnapToTurtle16CompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import Turtle16SimulatorCore
import TurtleCore

class SnapToTurtle16CompilerTests: XCTestCase {
    let kRuntime = "runtime"
    let kUnionPayloadOffset = 1
    
    func testEmptyProgram() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: "")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(Disassembler().disassembleToText(compiler.instructions), """
            NOP
            HLT
            """)
    }
    
    func testCompileFailsDuringLexing() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: "`")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "`")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected character: ``'")
    }
    
    func testCompileFailsDuringParsing() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: ":")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, ":")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "operand type mismatch: `:'")
    }
    
    func testCompileFailsDuringCodeGeneration() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: "foo")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testSimpleProgram() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
let a = 1
""")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(Disassembler().disassembleToText(compiler.instructions), """
            NOP
            LI r0, 16
            LUI r0, 1
            LI r1, 1
            STORE r1, r0, 0
            NOP
            HLT
            """)
    }
    
    func testFunctionDefinition() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
func foo() {
    let a = 1
}
""")
        XCTAssertFalse(compiler.hasError)
        if compiler.hasError {
            let error = CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors)
            print(error.description)
        }
        XCTAssertEqual(AssemblerListingMaker().makeListing(try compiler.assembly.get()), """
            NOP
            HLT
            foo:
            ENTER 1
            SUBI r0, fp, 1
            LI r1, 1
            STORE r1, r0, 0
            LEAVE
            RET
            """)
    }
    
    fileprivate struct Options {
        public let isVerboseLogging: Bool
        public let isBoundsCheckEnabled: Bool
        public let shouldDefineCompilerIntrinsicFunctions: Bool
        public let isUsingStandardLibrary: Bool
        public let runtimeSupport: String?
        public let shouldRunSpecificTest: String?
        public let onSerialOutput: ((UInt16) -> Void)?
        public let injectModules: [String:String]
        
        public init(isVerboseLogging: Bool = false,
                    isBoundsCheckEnabled: Bool = false,
                    shouldDefineCompilerIntrinsicFunctions: Bool = false,
                    isUsingStandardLibrary: Bool = false,
                    runtimeSupport: String? = nil,
                    shouldRunSpecificTest: String? = nil,
                    onSerialOutput: ((UInt16) -> Void)? = nil,
                    injectModules: [String:String] = [:]) {
            self.isVerboseLogging = isVerboseLogging
            self.isBoundsCheckEnabled = isBoundsCheckEnabled
            self.shouldDefineCompilerIntrinsicFunctions = shouldDefineCompilerIntrinsicFunctions
            self.isUsingStandardLibrary = isUsingStandardLibrary
            self.runtimeSupport = runtimeSupport
            self.shouldRunSpecificTest = shouldRunSpecificTest
            self.onSerialOutput = onSerialOutput
            self.injectModules = injectModules
        }
    }
    
    fileprivate let kMemoryMappedSerialOutputPort = MemoryAddress(0x0001)
    
    fileprivate func makeDebugger(options: Options, program: String) -> SnapDebugConsole? {
        let opts2 = SnapToTurtle16Compiler.Options(
            isBoundsCheckEnabled: options.isBoundsCheckEnabled,
            shouldDefineCompilerIntrinsicFunctions: options.shouldDefineCompilerIntrinsicFunctions,
            isUsingStandardLibrary: options.isUsingStandardLibrary,
            runtimeSupport: options.runtimeSupport,
            shouldRunSpecificTest: options.shouldRunSpecificTest,
            injectedModules: options.injectModules)
        let compiler = SnapToTurtle16Compiler(options: opts2)
        compiler.compile(program: program)
        XCTAssertFalse(compiler.hasError)
        guard !compiler.hasError else {
            let error = CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors)
            print("compile error: \(error.message)")
            return nil
        }
        
        if options.isVerboseLogging {
            print(AssemblerListingMaker().makeListing(try! compiler.assembly.get()))
            print((try! compiler.tack.get() as! Seq).makeChildDescriptions())
        }
        
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.cpu.store = { (value: UInt16, addr: MemoryAddress) in
            if options.isVerboseLogging {
                print("store ram[\(addr.value)] <- \(value)")
            }
            if addr == self.kMemoryMappedSerialOutputPort {
                if let onSerialOutput = options.onSerialOutput {
                    onSerialOutput(value)
                }
            }
            else {
                computer.ram[addr.value] = value
            }
        }
        computer.cpu.load = { (addr: MemoryAddress) in
            if options.isVerboseLogging {
                print("load ram[\(addr.value)] -> \(computer.ram[addr.value])")
            }
            return computer.ram[addr.value]
        }
        
        computer.instructions = compiler.instructions
        computer.reset()
        
        let debugger = SnapDebugConsole(computer: computer)
        debugger.logger = PrintLogger()
        debugger.symbols = compiler.symbolsOfTopLevelScope
        
        return debugger
    }
    
    fileprivate func run(options: Options = Options(), program: String) -> SnapDebugConsole? {
        guard let debugger = makeDebugger(options: options, program: program) else {
            return nil
        }
        
        if options.isVerboseLogging {
            while !debugger.computer.isHalted {
                print("---")
                let pc = debugger.computer.pc
                debugger.interpreter.runOne(instruction: .disassemble(.baseCount(pc, 1)))
                debugger.interpreter.runOne(instruction: .reg)
                while pc == debugger.computer.pc {
                    debugger.interpreter.runOne(instruction: .step(count: 1))
                }
            }
        }
        else {
            debugger.interpreter.runOne(instruction: .run)
        }
        
        return debugger
    }
    
    func test_EndToEndIntegration_SimplestProgram() {
        let debugger = run(program: """
            let a = 42
            """)
        let a = debugger?.loadSymbolU8("a")
        XCTAssertEqual(a, 42)
    }
    
    func test_EndToEndIntegration_i8() {
        let debugger = run(program: """
            var a: i8 = -1
            a = a - 1
            """)
        let a = debugger?.loadSymbolI8("a")
        XCTAssertEqual(a, -2)
    }
    
    func test_EndToEndIntegration_i16() {
        let debugger = run(program: """
            var a: i16 = -1000
            a = a - 1000
            """)
        let a = debugger?.loadSymbolI16("a")
        XCTAssertEqual(a, -2000)
    }
    
    func test_EndToEndIntegration_ForIn_Range_1() {
        let debugger = run(program: """
            var a: u16 = 100
            for i in 0..10 {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }
    
    func test_EndToEndIntegration_ForIn_Range_2() {
        let debugger = run(program: """
            var a: u16 = 255
            let range = 0..10
            for i in range {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }
    
    func test_EndToEndIntegration_ForIn_Range_SingleStatement() {
        let debugger = run(program: """
            var a: u16 = 255
            for i in 0..10
                a = i
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }
    
    func test_EndToEndIntegration_AssignLiteral255ToU16Variable() {
        let debugger = run(program: """
            let a: u16 = 255
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 255)
    }
    
    func test_EndToEndIntegration_AssignLiteral255ToU8Variable() {
        let debugger = run(program: """
            var a: u8 = 255
            """)
        let a = debugger?.loadSymbolU8("a")
        XCTAssertEqual(a, 255)
    }
    
    func test_EndToEndIntegration_ForIn_String() {
        let debugger = run(program: """
            var a = 255
            for i in "hello" {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU8("a")
        XCTAssertEqual(a, UInt8("o".utf8.first!))
    }
    
    func test_EndToEndIntegration_ForIn_ArrayOfU16() {
        let debugger = run(program: """
            var a: u16 = 0xffff
            for i in [_]u16{0x1000, 0x2000, 0x3000, 0x4000, 0x5000} {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x5000))
    }
    
    func test_EndToEndIntegration_SubscriptArray() {
        let debugger = run(program: """
            let arr = [_]u16{0x1000}
            let a: u16 = arr[0]
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }
    
    func test_EndToEndIntegration_SubscriptSlice() {
        let debugger = run(program: """
            let arr = [_]u16{0x1000}
            let slice: []u16 = arr
            let a: u16 = slice[0]
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }
    
    func test_EndToEndIntegration_ForIn_DynamicArray_1() {
        let debugger = run(program: """
            var a: u16 = 0xffff
            let arr = [_]u16{0x1000}
            let slice: []u16 = arr
            for i in slice {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }
    
    func test_EndToEndIntegration_ForIn_DynamicArray_2() {
        let debugger = run(program: """
            var a: u16 = 0xffff
            let arr = [_]u16{1, 2}
            let slice: []u16 = arr
            for i in slice {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(2))
    }
    
    func test_EndToEndIntegration_Fibonacci() {
        let debugger = run(program: """
            var a: u16 = 1
            var b: u16 = 1
            var fib: u16 = 0
            for i in 0..10 {
                fib = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 89)
        XCTAssertEqual(debugger?.loadSymbolU16("b"), 144)
    }
    
    func test_EndToEndIntegration_Fibonacci_ExercisingStaticKeyword() {
        let debugger = run(program: """
            var a: u16 = 1
            var b: u16 = 1
            for i in 0..10 {
                static var fib: u16 = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 89)
        XCTAssertEqual(debugger?.loadSymbolU16("b"), 144)
    }
    
    func test_EndToEndIntegration_Fibonacci_U8_1() {
        let debugger = run(program: """
            var a: u8 = 1
            var b: u8 = 1
            var fib: u8 = 0
            for i in 0..9 {
                fib = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 55)
        XCTAssertEqual(debugger?.loadSymbolU8("b"), 89)
    }
    
    func test_EndToEndIntegration_Fibonacci_U8_2() {
        // TODO: The u8 type should always use unsigned arithmetic. Add new i8 and i16 types to the compiler for signed arithmetic.
        // If we do 0..10 then b will be 144 which exceeds the maximum value of
        // 127 for a signed eight-bit integer. The compiler doesn't draw a good
        // enough distinction between signed and unsigned numbers which leads
        // this value to being sign-extended in memory to sixteen bits wide.
        // While this allows for efficient conversion from u8 to u16 by simply
        // reinterpreting the in-memory value, it is definitely not the behavior
        // we expect from a u8 type.
        let debugger = run(program: """
            var a: u8 = 1
            var b: u8 = 1
            var fib: u8 = 0
            for i in 0..10 {
                fib = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 89)
        XCTAssertEqual(debugger?.loadSymbolU8("b"), 144)
    }
    
    func testLocalVariablesDoNotSurviveTheLocalScope() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            {
                var a = 1
                a = 2
            }
            a = 3
            """)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "a")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 4..<5)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `a'")
    }
    
    func testLocalVariablesDoNotSurviveTheLocalScope_ForLoop() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            for i in 0..10 {
                var a = i
            }
            i = 3
            """)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "i")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 3..<4)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `i'")
    }
    
    func test_EndToEndIntegration_SimpleFunctionCall() {
        let debugger = run(program: """
            var a: u16 = 0
            func foo() {
                a = 0xaa
            }
            foo()
            """)
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_StaticVarInAFunctionContextIsStoredInStaticDataArea() {
        let debugger = run(program: """
            func foo() {
                static var a: u16 = 0xaa
            }
            foo()
            """)
        let word = debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress]
        XCTAssertEqual(word, 0xaa) // var a
    }
    
    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_0() {
        let debugger = run(program: """
            var a = 0xaa
            {
                var b = 0xbb
                {
                    var c = 0xcc
                }
            }
            """)
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+0], 0xaa) // var a
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+1], 0xbb) // var b
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+2], 0xcc) // var c
    }
    
    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_1() {
        let debugger = run(program: """
            var a = 0xaa
            {
                var b = a
                {
                    {
                        {
                            var c = b
                        }
                    }
                }
            }
            """)
        
        // TODO: The debugger should have a method to lookup a symbol table given a line number in the source file. Use this to look up the symbols on line 7 instead of assuming memory layouts here. Make a similar change in other unit tests which access memory at hard coded symbol addresses.
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+0], 0xaa) // var a
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+1], 0xaa) // var b
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+2], 0xaa) // var c
    }
    
    func test_EndToEndIntegration_StoreLocalVariableDefinedSeveralScopesUp_StackFramesNotEqualToScopes() {
        let debugger = run(program: """
            func foo() -> u8 {
                var b = 0xaa
                func bar() -> u8 {
                    {
                        return b
                    }
                }
                return bar()
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8() {
        let debugger = run(program: """
            func foo() -> u8 {
                return 42
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 42)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU16() {
        let debugger = run(program: """
            func foo() -> u16 {
                return 0xabcd
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 0xabcd)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8PromotedToU16() {
        let debugger = run(program: """
            func foo() -> u16 {
                return 0xaa
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 0x00aa)
    }
    
    func test_EndToEndIntegration_NestedFunctionDeclarations() {
        let debugger = run(program: """
            func foo() -> u8 {
                let val = 0xaa
                func bar() -> u8 {
                    return val
                }
                return bar()
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_ReturnFromInsideIfStmt() {
        let debugger = run(program: """
            func foo() -> u8 {
                if 1 + 1 == 2 {
                    return 0xaa
                } else {
                    return 0xbb
                }
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 0xaa)
    }
    
    func testMissingReturn_1() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            func foo() -> u8 {
            }
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testMissingReturn_2() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            func foo() -> u8 {
                if false {
                    return 1
                }
            }
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testUnexpectedNonVoidReturnValueInVoidFunction() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            func foo() {
                return 1
            }
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "1")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected non-void return value in void function")
    }
    
    func test_EndToEndIntegration_PromoteInAssignmentStatement() {
        let debugger = run(program: """
            var result = 0xabcd
            result = 42
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("result"), 42)
    }
    
    func test_EndToEndIntegration_PromoteParameterInCall() {
        let debugger = run(program: """
            var result = 0xabcd
            func foo(n: u16) {
                result = n
            }
            foo(42)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("result"), 42)
    }
    
    func test_EndToEndIntegration_PromoteReturnValue() {
        let debugger = run(program: """
            func foo(n: u8) -> u16 {
                return n
            }
            let result = foo(42)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("result"), 42)
    }
    
    func test_EndToEndIntegration_MutuallyRecursiveFunctions() {
        let debugger = run(program: """
            func isEven(n: u8) -> bool {
                if n == 0 {
                    return true
                } else {
                    return isOdd(n - 1)
                }
            }

            func isOdd(n: u8) -> bool {
                if n == 0 {
                    return false
                } else {
                    return isEven(n - 1)
                }
            }

            let a = isOdd(7)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolBool("a"), true)
    }
    
    func test_EndToEndIntegration_MutuallyRecursiveFunctions_u16() {
        let debugger = run(program: """
            func isEven(n: u16) -> bool {
                if n == 0 {
                    return true
                } else {
                    return isOdd(n - 1)
                }
            }

            func isOdd(n: u16) -> bool {
                if n == 0 {
                    return false
                } else {
                    return isEven(n - 1)
                }
            }

            let a = isOdd(3)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolBool("a"), true)
    }
    
    func test_EndToEndIntegration_RecursiveFunctions_u8() {
        let debugger = run(program: """
            var count = 0
            func foo(n: u8) {
                if n > 0 {
                    count = count + 1
                    foo(n - 1)
                }
            }
            foo(10)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("count"), 10)
    }
    
    func test_EndToEndIntegration_RecursiveFunctions_u16() {
        let debugger = run(program: """
            var count = 0
            func foo(n: u16) {
                if n > 0 {
                    count = count + 1
                    foo(n - 1)
                }
            }
            foo(10)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("count"), 10)
    }
    
    func test_EndToEndIntegration_FunctionCallsInExpression() {
        let debugger = run(program: """
            func foo(n: u8) -> u8 {
                return n
            }
            let r = foo(2) + 1
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 3)
    }
    
    func test_EndToEndIntegration_RecursiveFunctions_() {
        let debugger = run(program: """
            func foo(n: u8) -> u8 {
                if n == 0 {
                    return 0
                }
                return foo(n - 1) + 1
            }
            let count = foo(1)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("count"), 1)
    }
    
    func test_EndToEndIntegration_ReturnInVoidFunction() {
        _ = run(program: """
            func foo() {
                return
            }
            foo()
            """)
    }
    
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Let() {
        let debugger = run(program: """
            let foo: u16 = 0xffff
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 0xffff)
    }
    
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Var() {
        let debugger = run(program: """
            var foo: u16 = 0xffff
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 0xffff)
    }
    
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_PromoteU8ToU16() {
        let debugger = run(program: """
            let foo: u16 = 10
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 10)
    }
    
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Bool() {
        let debugger = run(program: """
            let foo: bool = true
            """)
        
        XCTAssertEqual(debugger?.loadSymbolBool("foo"), true)
    }
    
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_CannotConvertU16ToBool() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            let foo: bool = 0xffff
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "0xffff")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `integer constant 65535' to type `const bool'")
    }
    
    func test_EndToEndIntegration_CastU16DownToU8() {
        let debugger = run(program: """
            var foo: u16 = 1
            let bar: u8 = foo as u8
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 1)
        XCTAssertEqual(debugger?.loadSymbolU8("bar"), 1)
    }
    
    func test_EndToEndIntegration_RawMemoryAccess() {
        // TODO: Add a platform-dependent type `usize' and use that to store the address here
        let debugger = run(program: """
            let address: u16 = 0x5000
            let pointer: *u16 = address bitcastAs *u16
            pointer.pointee = 0xabcd
            let value: u16 = pointer.pointee
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("address"), 0x5000)
        XCTAssertEqual(debugger?.loadSymbolPointer("pointer"), 0x5000)
        XCTAssertEqual(debugger?.computer.ram[0x5000], 0xabcd)
        XCTAssertEqual(debugger?.loadSymbolU16("value"), 0xabcd)
    }
    
    // TODO: Instead of a flag to enable compiler intrinsics, pass the definitions of the compiler intrinsics themselves into the compiler from the top.
    
    func test_EndToEndIntegration_DeclareArrayType_InferredType() {
        let debugger = run(program: """
            let arr = [_]u8{1, 2, 3}
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU8(3, "arr"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_DeclareArrayType_ExplicitType() {
        let debugger = run(program: """
            let arr: [_]u8 = [_]u8{1, 2, 3}
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU8(3, "arr"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_FailToAssignScalarToArray() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            let arr: [_]u8 = 1
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "1")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `integer constant 1' to type `[_]const u8'")
    }
    
    // TODO: Consider changing SnapToTurtle16Compiler.compile() so it returns either the compiled program or a compiler error. Eliminate the irregular `hasError' and `errors' properties.
    
    func test_EndToEndIntegration_FailToAssignFunctionToArray() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            func foo(bar: u8, baz: u16) -> bool {
                return false
            }
            let arr: [_]u16 = foo
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 3..<4)
        XCTAssertEqual(compiler.errors.first?.message, "inappropriate use of a function type (Try taking the function's address instead.)")
    }
    
    func test_EndToEndIntegration_CannotAddArrayToInteger() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            let foo = [_]u8{1, 2, 3}
            let bar = 1 + foo
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "1 + foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(compiler.errors.first?.message, "binary operator `+' cannot be applied to operands of types `integer constant 1' and `[3]const u8'")
    }
    
    func test_EndToEndIntegration_ArrayOfIntegerConstantsConvertedToArrayOfU16OnInitialAssignment() {
        let debugger = run(program: """
        let arr: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
        """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(10, "arr"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_ArrayOfU8ConvertedToArrayOfU16OnInitialAssignment() {
        let debugger = run(program: """
            let arr: [_]u16 = [_]u16{42 as u8}
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(1, "arr"), [42])
    }
    
    func test_EndToEndIntegration_ReadArrayElement_U16() {
        let debugger = run(program: """
            var result: u16 = 0
            let arr: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            result = arr[0]
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("result"), 100)
    }
    
    func test_EndToEndIntegration_CastArrayLiteralFromArrayOfU8ToArrayOfU16() {
        let debugger = run(program: """
            let foo = [_]u8{1, 2, 3} as [_]u16
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(3, "foo"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_FailToCastIntegerLiteralToArrayOfU8BecauseOfOverflow() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            let foo = [_]u8{0x1001, 0x1002, 0x1003} as [_]u8
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "0x1001")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "integer constant `4097' overflows when stored into `u8'")
    }
    
    // TODO: Eliminate LvalueExpressionTypeChecker and RvalueExpressionTypeChecker. Replace with functions lvalueType() and rvalueType() which work like in a manner similar to existing lvalue() and rvalue() functions.
    
    func test_EndToEndIntegration_CastArrayOfU16ToArrayOfU8() {
        let debugger = run(program: """
            let foo = [_]u16{0x1001 as u16, 0x1002 as u16, 0x1003 as u16} as [_]u8
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU8(3, "foo"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_ReassignArrayContentsWithLiteralArray() {
        let debugger = run(program: """
            var arr: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
            arr = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(10, "arr"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_ReassignArrayContentsWithArrayIdentifier() {
        let debugger = run(program: """
            var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
            let b: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            a = b
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(10, "a"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_ReassignArrayContents_ConvertingFromArrayOfU8ToArrayOfU16() {
        let debugger = run(program: """
            var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
            let b = [_]u8{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            a = b
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(10, "a"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_AccessVariableInFunction_U8() {
        let debugger = run(program: """
            func foo() -> u8 {
                let result: u8 = 42
                return result
            }
            let bar = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("bar"), 42)
    }
    
    func test_EndToEndIntegration_AccessVariableInFunction_U16() {
        let debugger = run(program: """
            func foo() -> u16 {
                let result: u16 = 42
                return result
            }
            let bar: u16 = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("bar"), 42)
    }
    
    func test_EndToEndIntegration_SumLoop() {
        let debugger = run(program: """
            func sum() -> u8 {
                var accum = 0
                for i in 0..3 {
                    accum = accum + 1
                }
                return accum
            }
            let foo = sum()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("foo"), 3)
    }
    
    // TODO: Does anything ever set the initial values of sp and fp? The program needs to do that before calling alloca.
    
    func test_EndToEndIntegration_PassArrayAsFunctionParameter_0() {
        let debugger = run(program: """
            func sum(a: [1]u16) -> u16 {
                return a[0]
            }
            let foo = sum([_]u16{0xabcd})
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 0xabcd)
    }
    
    func test_EndToEndIntegration_PassArrayAsFunctionParameter_0a() {
        let debugger = run(program: """
            func sum(a: [2]u16) -> u16 {
                return a[0] + a[1]
            }
            let foo = sum([_]u16{1, 2})
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 3)
    }
    
    func test_Bug_ProgramRunsForever() {
        let debugger = run(program: """
            func sum() -> u16 {
                let a = [_]u16{1, 2}
                return a[0]
            }
            let foo = sum()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 1)
    }
    
    func test_EndToEndIntegration_PassArrayAsFunctionParameter_1() {
        let debugger = run(program: """
            func sum(a: [3]u16) -> u16 {
                return a[0] + a[1] + a[2]
            }
            let foo = sum([_]u16{1, 2, 3})
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 6)
    }
    
    func test_EndToEndIntegration_PassArrayAsFunctionParameter_2() {
        let debugger = run(program: """
            func sum(a: [3]u16) -> u16 {
                var accum: u16 = 0
                for i in 0..3 {
                    accum = accum + a[i]
                }
                return accum
            }
            let foo = sum([_]u16{1, 2, 3})
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 6)
    }
    
    func test_EndToEndIntegration_ReturnArrayByValue_U8() {
        let debugger = run(program: """
            func makeArray() -> [3]u8 {
                return [_]u8{1, 2, 3}
            }
            let foo = makeArray()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU8(3, "foo"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_ReturnArrayByValue_U16() {
        let debugger = run(program: """
            func makeArray() -> [3]u16 {
                return [_]u16{0x1234, 0x5678, 0x9abc}
            }
            let foo = makeArray()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(3, "foo"), [0x1234, 0x5678, 0x9abc])
    }
    
    // TODO: An instruction sequence like LI+LUI is used to load a sixteen-bit value into a register. This should be replaced with a new macro instruction LIU16 which is only expanded into LI+LIU after register allocation is complete. First, this is much more ergonomic. Second, when the destination register is spilled, this leads to more efficient code avoiding an unnecessary STORE.
    
    func test_EndToEndIntegration_PassTwoArraysAsFunctionParameters_1() {
        let debugger = run(program: """
            func sum(a: [3]u16, b: [3]u16, c: u16) -> u16 {
                return (a[0] + b[0] + a[1] + b[1] + a[2] + b[2]) * c
            }
            let foo = sum([_]u16{1, 2, 3}, [_]u16{4, 5, 6}, 2)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 42)
    }
    
    func test_EndToEndIntegration_PassTwoArraysAsFunctionParameters_1a() {
        let debugger = run(program: """
            func sum(a: [3]u8, b: [3]u8, c: u8) -> u8 {
                return (a[0] + b[0] + a[1] + b[1] + a[2] + b[2]) + c
            }
            let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
            """)

        XCTAssertEqual(debugger?.loadSymbolU8("foo"), 23)
    }

    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue() {
        let debugger = run(program: """
            func sum(a: [3]u8, b: [3]u8, c: u8) -> [3]u8 {
                var result = [_]u8{0, 0, 0}
                for i in 0..3 {
                    result[i] = (a[i] + b[i]) * c
                }
                return result
            }
            let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
            """)

        XCTAssertEqual(debugger?.loadSymbolArrayOfU8(3, "foo"), [10, 14, 18])
    }

    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue_U16() {
        let debugger = run(program: """
            func sum(a: [3]u16, b: [3]u16, c: u16) -> [3]u16 {
                var result = [_]u16{0, 0, 0}
                for i in 0..3 {
                    result[i] = (a[i] + b[i]) * c
                }
                return result
            }
            let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
            """)

        XCTAssertEqual(debugger?.loadSymbolArrayOfU16(3, "foo"), [10, 14, 18])
    }
    
    func test_EndToEndIntegration_BugWhenStackVariablesAreDeclaredAfterForLoop() {
        let debugger = run(program: """
            func foo() -> u16 {
                for i in 0..3 {
                }
                let a = 42
                return a
            }
            let b = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("b"), 42)
    }
    
    // TODO: The compiled program needs some code to initialize the stack and frame pointers
    
    // TODO: The compiler should link the program with a runtime that contains a platform-specific implementation of puts(). Move puts() out of stdlib.
    
    // TODO: Maybe the serial output should be accessible through the debugger object?
    
    func testSerialOutput_HelloWorld() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            puts("Hello, World!")
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }
    
    func testSerialOutput_Panic() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            panic("oops!")
            puts("Hello, World!")
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: oops!\n")
    }
    
    func testArrayOutOfBoundsError() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let arr = "Hello"
            let n = 10
            let foo = arr[n]
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }
    
    func test_EndToEndIntegration_ReadAndWriteToStructMember() {
        let debugger = run(program: """
            var result: u8 = 0
            struct Foo {
                bar: u8
            }
            var foo: Foo = undefined
            foo.bar = 42
            result = foo.bar
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("result"), 42)
    }
    
    func test_EndToEndIntegration_StructInitialization() {
        let debugger = run(program: """
            struct Foo {
                bar: u8
            }
            let foo = Foo { .bar = 42 }
            """)
        
        guard let symbol = debugger?.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        
        XCTAssertEqual(debugger?.computer.ram[symbol.offset], 42)
    }
    
    func test_EndToEndIntegration_AssignStructInitializerToStructInstance() {
        let debugger = run(program: """
            struct Foo {
                bar: u8
            }
            var foo: Foo = undefined
            foo = Foo { .bar = 42 }
            """)
        
        guard let symbol = debugger?.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        
        XCTAssertEqual(debugger?.computer.ram[symbol.offset], 42)
    }
    
    func test_EndToEndIntegration_ReadStructMembersThroughPointer() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r: u8 = 0
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            var bar = &foo
            r = bar.x
            """)
        
        guard let symbol = debugger?.symbols?.maybeResolve(identifier: "r") else {
            XCTFail("failed to resolve identifier \"r\"")
            return
        }
        
        XCTAssertEqual(debugger?.computer.ram[symbol.offset], 1)
    }
    
    func test_EndToEndIntegration_WriteStructMembersThroughPointer() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            var bar = &foo
            bar.x = 2
            """)
        
        guard let symbol = debugger?.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        
        XCTAssertEqual(debugger?.computer.ram[symbol.offset], 2)
    }
    
    func test_EndToEndIntegration_PassPointerToStructAsFunctionParameter() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r: u8 = 0
            var bar = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) -> u8 {
                return foo.x + foo.y + foo.z
            }
            r = doTheThing(&bar)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 6)
    }
    
    func test_EndToEndIntegration_CannotMakeMutatingPointerFromConstant_1() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            let foo: u16 = 0xabcd
            var bar: *u16 = &foo
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `*const u16' to type `*u16'")
    }
    
    func test_EndToEndIntegration_CannotMakeMutatingPointerFromConstant_2() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            let bar = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) {
                foo.x = foo.y * foo.z
            }
            doTheThing(&bar)
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert value of type `*const Foo' to expected argument type `*Foo' in call to `doTheThing'")
    }
    
    func test_EndToEndIntegration_MutateThePointeeThroughAPointer() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var bar = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) {
                foo.x = foo.y * foo.z
            }
            doTheThing(&bar)
            """)
        
        guard let symbol = debugger?.symbols?.maybeResolve(identifier: "bar") else {
            XCTFail("failed to resolve identifier \"bar\"")
            return
        }
        
        XCTAssertEqual(debugger?.computer.ram[symbol.offset], 6)
    }
    
    func test_EndToEndIntegration_FunctionReturnsPointerToStruct_Right() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r: u8 = 0
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) -> *Foo {
                return foo
            }
            r = doTheThing(&foo).x
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 1)
    }
    
    func test_EndToEndIntegration_FunctionReturnsPointerToStruct_Left() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) -> *Foo {
                return foo
            }
            doTheThing(&foo).x = 42
            """)
        
        guard let symbol = debugger?.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        
        XCTAssertEqual(debugger?.computer.ram[symbol.offset], 42)
    }
    
    func test_EndToEndIntegration_GetArrayCountThroughAPointer() {
        let debugger = run(program: """
            var r: u16 = 0
            let arr = [_]u8{ 1, 2, 3, 4 }
            let ptr = &arr
            r = ptr.count
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("r"), 4)
    }
    
    func test_EndToEndIntegration_GetDynamicArrayCountThroughAPointer() {
        let debugger = run(program: """
            var r: u16 = 0
            let arr = [_]u8{ 1, 2, 3, 4 }
            let dyn: []u8 = arr
            let ptr = &dyn
            r = ptr.count
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("r"), 4)
    }
    
    func test_EndToEndIntegration_GetPointeeOfAPointerThroughAPointer() {
        let debugger = run(program: """
            var r: u16 = 0
            let foo: u16 = 0xcafe
            let bar = &foo
            let baz = &bar
            r = baz.pointee.pointee
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("r"), 0xcafe)
    }
    
    func test_EndToEndIntegration_FunctionParameterIsPointerToConstType() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r = 0
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *const Foo) -> *const Foo {
                return foo
            }
            r = doTheThing(&foo).x
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 1)
    }
    
    func test_EndToEndIntegration_CallAStructMemberFunction_1() {
        let debugger = run(program: """
            var r: u8 = 0
            struct Foo {
            }
            impl Foo {
                func bar() -> u8 {
                    return 42
                }
            }
            r = Foo.bar()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 42)
    }
    
    func test_EndToEndIntegration_CallAStructMemberFunction_2() {
        let debugger = run(program: """
            var r: u8 = 0
            struct Foo {
                aa: u8
            }
            impl Foo {
                func bar(self: *const Foo, offset: u8) -> u8 {
                    return self.aa + offset
                }
            }
            let foo = Foo {
                .aa = 41
            }
            r = foo.bar(1)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 42)
    }
    
    func test_EndToEndIntegration_CallAStructMemberFunction_3() {
        let debugger = run(program: """
            var r: u8 = 0
            struct Foo {
                aa: u8
            }
            impl Foo {
                func bar(offset: u8) -> u8 {
                    return offset
                }
            }
            let foo = Foo {
                .aa = 41
            }
            r = foo.bar(42)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 42)
    }
    
    func test_EndToEndIntegration_LinkedList() {
        let debugger = run(program: """
            struct None {}
            let none = None {}
            var r: u8 | None = none
            struct LinkedList {
                next: *const LinkedList | None,
                key: u8,
                value: u8
            }
            let c = LinkedList {
                .next = none,
                .key = 2,
                .value = 42
            }
            let b = LinkedList {
                .next = &c,
                .key = 1,
                .value = 0
            }
            let a = LinkedList {
                .next = &b,
                .key = 0,
                .value = 0
            }
            impl LinkedList {
                func lookup(self: *const LinkedList, key: u8) -> u8 | None {
                    if self.key == key {
                        return self.value
                    }
                    else match self.next {
                        (next: *const LinkedList) -> {
                            return next.lookup(key)
                        },
                        else -> {
                            return none
                        }
                    }
                }
            }
            r = a.lookup(2)
            """)
        
        guard let symbol = debugger?.symbols?.maybeResolve(identifier: "r") else {
            XCTFail("failed to resolve identifier \"r\"")
            return
        }
        
        XCTAssertEqual(debugger?.computer.ram[symbol.offset+kUnionPayloadOffset], 0x002a)
    }
    
    func test_EndToEndIntegration_Match_WithExtraneousClause() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            var r: u8 = 0
            var a: u8 = 0
            match a {
                (foo: u8) -> {
                    a = 1
                },
                (foo: bool) -> {
                    a = 2
                },
                else -> {
                    a = 3
                }
            }
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo: bool")
        XCTAssertEqual(compiler.errors.first?.message, "extraneous clause in match statement: bool")
    }
    
    func test_EndToEndIntegration_Match_WithMissingClause() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            var r: u8 = 0
            var a: u8 | bool = 0
            match a {
                (foo: u8) -> {
                    a = 1
                }
            }
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "a")
        XCTAssertEqual(compiler.errors.first?.message, "match statement is not exhaustive. Missing clause: bool")
    }
    
    func testFunctionReturnsConstValue() {
        let debugger = run(program: """
            func foo() -> const u8 {
                return 42
            }
            let r = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("r"), 42)
    }
    
    func testAssignmentExpressionItselfHasAValue() {
        let debugger = run(program: """
            var foo: u8 = 0
            var bar: u8 = (foo = 42)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("foo"), 42)
        XCTAssertEqual(debugger?.loadSymbolU8("bar"), 42)
    }
    
    func testArraySlice_SliceStaticArrayWithCompileTimeRange() {
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime)
        let debugger = run(options: options, program: """
            let helloWorld = "Hello, World!"
            let hello = helloWorld[0..5]
            """)
            
        XCTAssertEqual(debugger?.loadSymbolString("helloWorld"), "Hello, World!")
        XCTAssertEqual(debugger?.loadSymbolStringSlice("hello"), "Hello")
    }
    
    func testArraySlice() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let helloWorld = "Hello, World!"
            let helloComma = helloWorld[0..6]
            let hello = helloComma[0..(helloComma.count-1)]
            puts(hello)
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello")
    }
    
    func testArraySlice_PanicDueToArrayBoundsException_1() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let helloWorld = "Hello, World!"
            let begin = 1000
            let limit = 1001
            let helloComma = helloWorld[begin..limit]
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }
    
    func testArraySlice_PanicDueToArrayBoundsException_2() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let helloWorld = "Hello, World!"
            let limit = 1000
            let helloComma = helloWorld[0..limit]
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }
    
    func testDynamicArraySlice_PanicDueToArrayBoundsException_1() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let helloWorld = "Hello, World!"
            let helloComma = helloWorld[0..6]
            let begin = 1000
            let hello = helloComma[begin..1001]
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }
    
    func testDynamicArraySlice_PanicDueToArrayBoundsException_2() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let helloWorld = "Hello, World!"
            let helloComma = helloWorld[0..6]
            let limit = 1001
            let hello = helloComma[0..limit]
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }
    
    func testAssertionFailed() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            assert(1 == 2)
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: assertion failed: `1 == 2' on line 1\n")
    }
    
    func testRunTests_AllTestsPassed() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            test "foo" {
            }
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "passed\n")
    }
    
    func testRunTests_FailingAssertMentionsFailingTestByName() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            test "foo" {
                assert(1 == 2)
            }
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: assertion failed: `1 == 2' on line 2 in test \"foo\"\n")
    }
    
    func testImportModule() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput,
                              injectModules: ["MyModule" : """
                                  public func foo() {
                                      puts("Hello, World!")
                                  }
                                  """])
        _ = run(options: options, program: """
            import MyModule
            foo()
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }
    
    func testBasicFunctionPointerDemonstration() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let ptr = &puts
            ptr("Hello, World!")
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }
    
    func testRebindAFunctionPointerAtRuntime_1() {
        let debugger = run(program: """
            var foo: u16 = 1
            func bar() {
                foo = 2
            }
            func quz() {
                foo = 3
            }
            var ptr = &bar
            ptr = &quz
            ptr()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("foo"), 3)
    }
    
    func testRebindAFunctionPointerAtRuntime_2() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            public func fakePuts(s: []const u8) {
                puts("fake")
            }
            var ptr = &puts
            ptr = &fakePuts
            ptr("Hello, World!")
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "fake")
    }
    
    func testFunctionPointerStructMemberCanBeCalledLikeAFunctionMemberCanBeCalled_1() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            struct Serial {
                puts: func ([]const u8) -> void
            }
            let serial = Serial {
                .puts = &puts
            }
            serial.puts("Hello, World!")
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }
    
    func testFunctionPointerStructMemberCanBeCalledLikeAFunctionMemberCanBeCalled_2() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            struct Foo {
                bar: func (*const Foo, []const u8) -> void
            }
            func baz(self: *const Foo, s: []const u8) -> void {
                puts(s)
            }
            let foo = Foo {
                .bar = &baz
            }
            foo.bar("Hello, World!")
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }
    
    func testStructInitializerCanHaveExplicitUndefinedValue() throws {
        let debugger = run(program: """
            struct Foo {
                arr: [64]u8
            }
            var foo = Foo {
                .arr = undefined
            }
            """)
        
        let arr = try debugger?.symbols?.resolve(identifier: "foo")
        XCTAssertNotNil(arr)
    }
    
    func testSubscriptStructMemberThatIsAnArray() {
        let debugger = run(program: """
            struct Foo {
                arr: [64]u8
            }
            var foo: Foo = undefined
            foo.arr[0] = 42
            let baz = foo.arr[0]
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("baz"), 42)
    }
    
    func testSubscriptStructMemberThatIsADynamicArray() {
        let debugger = run(program: """
            let backing: [64]u8 = undefined
            struct Foo {
                arr: []u8
            }
            var foo = Foo {
                .arr = backing
            }
            foo.arr[0] = 42
            let baz = foo.arr[0]
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("baz"), 42)
    }
    
    func testBugWithCompilerTemporaryPushedTwiceInDynamicArrayBoundsCheck() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let slice: []const u8 = "test"
            test "foo" {
                assert(slice[0] == 't')
            }
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "passed\n")
    }
    
    func testBugWhenConvertingStringLiteralToDynamicArrayInFunctionParameter() {
        let debugger = run(program: """
            public struct Foo {
            }

            impl Foo {
                func bar(self: *Foo, s: []const u8) -> u8 {
                    return s[0]
                }
            }

            var foo: Foo = undefined
            let baz = foo.bar("t")
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("baz"), 116)
    }
    
    func testVtableDemo() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "call through vtable pseudo-interface",
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            public struct Serial {
                print: func (*Serial, []const u8) -> void
            }

            public struct SerialFake {
                vtable: Serial,
                buffer: [64]u8,
                cursor: u16
            }

            impl SerialFake {
                func init() -> SerialFake {
                    var serial: SerialFake = undefined
                    serial.cursor = 0
                    for i in 0..(serial.buffer.count) {
                        serial.buffer[i] = 0
                    }
                    serial.vtable.print = &serial.print_ bitcastAs func (*Serial, []const u8) -> void
                    return serial
                }

                func asSerial(self: *SerialFake) -> *Serial {
                    return self bitcastAs *Serial
                }

                func print_(self: *SerialFake, s: []const u8) {
                    for i in 0..(s.count) {
                        self.buffer[self.cursor + i] = s[i]
                    }
                    self.cursor = self.cursor + s.count
                }
            }

            test "call through vtable pseudo-interface" {
                var serialFake = SerialFake.init()
                let serial = serialFake.asSerial()
                serial.print("test")
                assert(serialFake.cursor == 4)
                assert(serialFake.buffer[0] == 't')
                assert(serialFake.buffer[1] == 'e')
                assert(serialFake.buffer[2] == 's')
                assert(serialFake.buffer[3] == 't')
            }

            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "passed\n")
    }
    
    func testTraitsDemo() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "call through trait interface",
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            trait Serial {
                func puts(self: *Serial, s: []const u8)
            }

            struct SerialFake {
                buffer: [64]u8,
                cursor: u16
            }

            impl SerialFake {
                func init() -> SerialFake {
                    var serial: SerialFake = undefined
                    serial.cursor = 0
                    for i in 0..(serial.buffer.count) {
                        serial.buffer[i] = 0
                    }
                    return serial
                }
            }

            impl Serial for SerialFake {
                func puts(self: *SerialFake, s: []const u8) {
                    for i in 0..(s.count) {
                        self.buffer[self.cursor + i] = s[i]
                    }
                    self.cursor = self.cursor + s.count
                }
            }

            test "call through trait interface" {
                var serialFake = SerialFake.init()
                let serial: Serial = &serialFake
                serial.puts("test")
                assert(serialFake.cursor == 4)
                assert(serialFake.buffer[0] == 't')
                assert(serialFake.buffer[1] == 'e')
                assert(serialFake.buffer[2] == 's')
                assert(serialFake.buffer[3] == 't')
            }

            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "passed\n")
    }
    
    func testTraitsFailToCompileBecauseTraitNotImplementedAppropriately() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            trait Serial {
                func puts(self: *Serial, s: []const u8)
            }

            struct SerialFake {
                buffer: [64]u8,
                cursor: u16
            }

            impl SerialFake {
                func init() -> SerialFake {
                    var serial: SerialFake = undefined
                    serial.cursor = 0
                    for i in 0..(serial.buffer.count) {
                        serial.buffer[i] = 0
                    }
                    return serial
                }
            }

            impl Serial for SerialFake {
                func puts(self: *SerialFake) {
                }
            }

            test "call through trait interface" {
                var serialFake = SerialFake.init()
                let serial: Serial = &serialFake
                serial.puts("test")
                assert(serialFake.cursor == 4)
                assert(serialFake.buffer[0] == 't')
                assert(serialFake.buffer[1] == 'e')
                assert(serialFake.buffer[2] == 's')
                assert(serialFake.buffer[3] == 't')
            }

            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "impl Serial for SerialFake {")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 20..<21)
        XCTAssertEqual(compiler.errors.first?.message, "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2.")
    }
    
    func testBugSymbolResolutionInStructMethodsPutsMembersInScopeWithBrokenOffsets() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            struct Foo {
                bar: u8
            }

            impl Foo {
                func init() -> Foo {
                    var foo: Foo = undefined
                    bar = 42
                    return foo
                }
            }

            let foo = Foo.init()
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "bar")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 7..<8)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `bar'")
    }
    
    func testBugWhereRangeInSubscriptCausesUnsupportedExpressionError() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            struct Foo {
                buffer: []const u8
            }
            let foo = Foo {
                .buffer = "Hello, World!"
            }
            foo.buffer = foo.buffer[0..5]
            puts(foo.buffer)
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello")
    }
    
    func testBugWhereImplErrorIsMissingSourceAnchor() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            impl Foo {
            }
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "Foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `Foo'")
    }
    
    func testBugWhereConstSelfPointerInTraitCausesCompilerCrash() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            trait Serial {
                func print(self: *const Serial, s: []const u8)
            }
            """)
        
        XCTAssertFalse(compiler.hasError)
    }
    
    func testCrashWhenReturningAZeroSizeStruct() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            struct Empty {}
            func init() -> Empty {
                return Empty {}
            }
            let foo = init()
            """)
        
        XCTAssertFalse(compiler.hasError)
    }
    
    func testBugWhereCompilerPermitsImplicitConversionFromUnionToMemberType() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            var a: u8 | bool = 42
            var b: u8 = a
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "a")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(compiler.errors.first?.message, "cannot implicitly convert a union type `u8 | bool' to `u8'; use an explicit conversion instead")
    }
    
    func testBugWhereCompilerDoesNotConvertUnionValuesOfDifferentConstness() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            var a: u8 | bool = 42
            let b: u8 | bool = a
            """)
        
        XCTAssertFalse(compiler.hasError)
    }
    
    func testWeCannotUseVariableBeforeItIsDeclared() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            func main() {
                a = 1
                var a: u16 = 0
            }
            """)
        
        XCTAssertTrue(compiler.hasError)
    }
    
    func testBugWhereArraySliceFailsWhenArgumentExpressionIsNotALiteralStructInitializer() {
        // This test captures a bug where an array slice expression fails when
        // the argument expression (expression inside the brackets) is not a
        // literal struct-initializer for a Range. In this example, passing a
        // variable of type `Range' fails.
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            let helloWorld = "Hello, World!"
            let range = 0..6
            let helloComma = helloWorld[range]
            let hello = helloComma[0..(helloComma.count-1)]
            puts(hello)
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello")
    }
    
    func testBugWhereAssignToMemberWithTraitTypeFails() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            trait Serial {
                func print(self: *Serial, s: []const u8)
            }

            struct XmodemProtocol {
                serial: Serial
            }

            impl XmodemProtocol {
                func init(serial: Serial) -> XmodemProtocol {
                    return XmodemProtocol {
                        .serial = serial
                    }
                }
            }
            """)
        
        XCTAssertFalse(compiler.hasError)
    }
    
    func testBugWhereCannotAssignStructPointerToTraitObject() throws {
        let debugger = run(program: """
            trait Serial {
                func puts(self: *Serial, s: []const u8)
            }

            struct SerialFake {}

            impl Serial for SerialFake {
                func puts(self: *SerialFake, s: []const u8) {}
            }
            
            let obj: SerialFake = undefined
            let serial: Serial = &obj
            """)
        
        let serial = try debugger?.symbols?.resolve(identifier: "serial")
        switch serial?.type {
        case .constTraitType(let typ):
            XCTAssertEqual(typ.name, "Serial")
            
        default:
            XCTFail()
        }
    }
    
    func testBugWhereCannotAssignStructToTraitObject() throws {
        let debugger = run(program: """
            trait Serial {
                func puts(self: *Serial, s: []const u8)
            }

            struct SerialFake {}

            impl Serial for SerialFake {
                func puts(self: *SerialFake, s: []const u8) {}
            }
            
            let obj: SerialFake = undefined
            let serial: Serial = obj
            """)
        
        let serial = try debugger?.symbols?.resolve(identifier: "serial")
        switch serial?.type {
        case .constTraitType(let typ):
            XCTAssertEqual(typ.name, "Serial")
            
        default:
            XCTFail()
        }
    }
    
    func testBugWhereCannotAssignStructToMutableTraitObject() throws {
        let debugger = run(program: """
            trait Serial {
                func puts(self: *Serial, s: []const u8)
            }

            struct SerialFake {}

            impl Serial for SerialFake {
                func puts(self: *SerialFake, s: []const u8) {}
            }
            
            let obj: SerialFake = undefined
            var serial: Serial = undefined
            serial = obj
            """)
        
        let serial = try debugger?.symbols?.resolve(identifier: "serial")
        switch serial?.type {
        case .traitType(let typ):
            XCTAssertEqual(typ.name, "Serial")
            
        default:
            XCTFail()
        }
    }
    
    func test_EndToEndIntegration_SignedIntegerComparison_LessThan() {
        let debugger = run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b < a
            """)
        let a = debugger?.loadSymbolBool("c")
        XCTAssertEqual(a, true)
    }
    
    func test_EndToEndIntegration_SignedIntegerComparison_LessThanOrEqualTo() {
        let debugger = run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b <= a
            """)
        let a = debugger?.loadSymbolBool("c")
        XCTAssertEqual(a, true)
    }
    
    func test_EndToEndIntegration_SignedIntegerComparison_GreaterThan() {
        let debugger = run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b > a
            """)
        let a = debugger?.loadSymbolBool("c")
        XCTAssertEqual(a, false)
    }
    
    func test_EndToEndIntegration_SignedIntegerComparison_GreaterThanOrEqualTo() {
        let debugger = run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b >= a
            """)
        let a = debugger?.loadSymbolBool("c")
        XCTAssertEqual(a, false)
    }
    
    func test_EndToEndIntegration_SignedIntegerComparison_Equal() {
        let debugger = run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b == a
            """)
        let a = debugger?.loadSymbolBool("c")
        XCTAssertEqual(a, false)
    }
    
    func test_EndToEndIntegration_SignedIntegerComparison_NotEqual() {
        let debugger = run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b != a
            """)
        let a = debugger?.loadSymbolBool("c")
        XCTAssertEqual(a, true)
    }
    
    func test_EndToEndIntegration_Underflow_u8() {
        let debugger = run(program: """
            let a: u8 = 0
            let b = (a - 1) == 255
            """)
        let b = debugger?.loadSymbolBool("b")
        XCTAssertEqual(b, true)
    }
    
    func test_EndToEndIntegration_cast_i16_to_i8() {
        let debugger = run(program: """
            let a: i16 = -1
            let b: i8 = a as i8
            """)
        let b = debugger?.loadSymbolI8("b")
        XCTAssertEqual(b, -1)
    }
    
    func test_EndToEndIntegration_cast_i16_to_u8() {
        let debugger = run(program: """
            let a: i16 = 42
            let b: u8 = a as u8
            """)
        let b = debugger?.loadSymbolU8("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_i16_to_u16() {
        let debugger = run(program: """
            let a: i16 = 42
            let b: u16 = a as u16
            """)
        let b = debugger?.loadSymbolU16("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_i8_to_i16() {
        let debugger = run(program: """
            let a: i8 = -1
            let b: i16 = a
            """)
        let b = debugger?.loadSymbolI16("b")
        XCTAssertEqual(b, -1)
    }
    
    func test_EndToEndIntegration_cast_i8_to_u8() {
        let debugger = run(program: """
            let a: i8 = 42
            let b: u8 = a as u8
            """)
        let b = debugger?.loadSymbolU8("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_i8_to_u16() {
        let debugger = run(program: """
            let a: i8 = 42
            let b: u16 = a as u16
            """)
        let b = debugger?.loadSymbolU16("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_u8_to_i8() {
        let debugger = run(program: """
            let a: u8 = 42
            let b: i8 = a as i8
            """)
        let b = debugger?.loadSymbolI8("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_u8_to_i16() {
        let debugger = run(program: """
            let a: u8 = 42
            let b: i16 = a
            """)
        let b = debugger?.loadSymbolI16("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_u8_to_u16() {
        let debugger = run(program: """
            let a: u8 = 42
            let b: u16 = a as u16
            """)
        let b = debugger?.loadSymbolU16("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_u16_to_i8() {
        let debugger = run(program: """
            let a: u16 = 42
            let b: i8 = a as i8
            """)
        let b = debugger?.loadSymbolI8("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_u16_to_u8() {
        let debugger = run(program: """
            let a: u16 = 42
            let b: u8 = a as u8
            """)
        let b = debugger?.loadSymbolU8("b")
        XCTAssertEqual(b, 42)
    }
    
    func test_EndToEndIntegration_cast_u16_to_i16() {
        let debugger = run(program: """
            let a: u16 = 42
            let b: i16 = a as i16
            """)
        let b = debugger?.loadSymbolI16("b")
        XCTAssertEqual(b, 42)
    }
    
    func testBUG_FailToPrintStringInUnitTest1() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            test "foo" {
                let pad1: u16 = 0
                let a = "A"
                puts(a)
            }
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Apassed\n")
    }
    
    func testBUG_PanicDuringIterationOfString() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            func foo() {
                let s = "a"
                for i in s {
                    let str: [1]u8 = [1]u8{65} // This `65' is overwriting something in memory, leading to the panic. The previous value is 0.
                }
            }
            foo()
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        let didNotPanic = (str != nil) && !(str!.hasPrefix("PANIC:"))
        if !didNotPanic {
            print("output: \(str ?? "")")
        }
        XCTAssertTrue(didNotPanic)
    }
    
    func testBUG_InfiniteLoopDuringIterationOfString() {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt16) in
            serialOutput.append(UInt8(value & 0x00ff))
        }
        let options = Options(isBoundsCheckEnabled: true,
                              shouldDefineCompilerIntrinsicFunctions: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = run(options: options, program: """
            test "foo" {
                for i in 0..1 {
                    let str = "A"
                    for ch in str {
                    }
                }
            }
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "passed\n")
    }
    
    func testBUG_printU16_produces_garbage() {
        let debugger = run(program: """
            var value: u16 = 0xabcd
            var buffer = [_]u8{'0', '0', '0', '0'}
            var i: u8 = 3
            while value != 0 {
                let rem = (value % 16) as u8
                if rem > 9 {
                    buffer[i] = rem - 10 + 'a'
                } else {
                    buffer[i] = rem + '0'
                }
                value = value / 16
                i = i - 1
            }
            """)
        let buffer = debugger?.loadSymbolString("buffer")
        XCTAssertEqual(buffer, "abcd")
        
        let value = debugger?.loadSymbolU16("value")
        XCTAssertEqual(value, 0)
    }
    
    func test_EndToEndIntegration_SizeOf_Variable() {
        let debugger = run(program: """
            let a = sizeof("foo")
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 3)
    }
    
    func test_EndToEndIntegration_SizeOf_Type() {
        let debugger = run(program: """
            let a = sizeof(u8)
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 1)
    }
    
    func test_EndToEndIntegration_GenericFunctionWithExplicitInstantiation() {
        let debugger = run(program: """
            func identity[T](a: T) -> T {
                return a
            }
            let a: u16 = identity@[u16](1000)
            let b: i16 = identity@[i16](-1000)
            """)
        let a = debugger?.loadSymbolU16("a")
        let b = debugger?.loadSymbolI16("b")
        XCTAssertEqual(a, 1000)
        XCTAssertEqual(b, -1000)
    }
    
    func test_EndToEndIntegration_GenericFunctionWithAutomaticTypeArgumentDeduction() {
        let debugger = run(program: """
            func identity[T](a: T) -> T {
                return a
            }
            let a = identity(-1000)
            """)
        let a = debugger?.loadSymbolI16("a")
        XCTAssertEqual(a, -1000)
    }
    
    func test_EndToEndIntegration_CompileErrorOnConcreteInstantiationOfGenericFunction() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            func identity[T](a: T) -> T {
                return a.count
            }
            let a = identity(1)
            """)
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "a.count")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(compiler.errors.first?.message, "value of type `const u8' has no member `count'")
    }
    
    func test_EndToEndIntegration_GenericStructMethod_1() {
        let debugger = run(program: """
            struct Point {
                x: u16,
                y: u16
            }
            
            impl Point {
                func add[T](p: *Point, x: T, y: T) -> Point {
                    return Point {
                        .x = p.x + x,
                        .y = p.y + y
                    }
                }
            }
            
            let p1 = Point { .x = 0, .y = 0 }
            let p2 = Point.add@[u16](p1, 1, 1)
            let x = p2.x
            let y = p2.y
            
            """)
        
        let x = debugger?.loadSymbolU16("x")
        let y = debugger?.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 1)
    }
    
    func test_EndToEndIntegration_GenericStructMethod_2() {
        let debugger = run(program: """
            struct Point {
                x: u16,
                y: u16
            }
            
            impl Point {
                func add[T](p: *Point, x: T, y: T) -> Point {
                    return Point {
                        .x = p.x + x,
                        .y = p.y + y
                    }
                }
            }
            
            let p1 = Point { .x = 0, .y = 0 }
            let p2 = p1.add@[u16](1, 1)
            let x = p2.x
            let y = p2.y
            
            """)
        
        let x = debugger?.loadSymbolU16("x")
        let y = debugger?.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 1)
    }
    
    func test_EndToEndIntegration_GenericStruct() {
        let debugger = run(program: """
            struct Point[T] {
                x: T,
                y: T
            }
            
            var p: Point@[u16] = undefined
            p.x = 1
            p.y = 2
            let x = p.x
            let y = p.y
            """)
        
        let x = debugger?.loadSymbolU16("x")
        let y = debugger?.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 2)
    }
    
    func test_EndToEndIntegration_StructInitializerWithGenericStruct() {
        let debugger = run(program: """
            struct Point[T] {
                x: T,
                y: T
            }
            
            let p = Point@[u16] {
                .x = 1,
                .y = 2
            }
            let x = p.x
            let y = p.y
            """)
        
        let x = debugger?.loadSymbolU16("x")
        let y = debugger?.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 2)
    }
    
    func test_EndToEndIntegration_GenericStruct_Impl() {
        let debugger = run(program: """
            struct Foo[T] {
                val: T
            }
            
            impl[T] Foo@[T] {
                func baz(self: *Foo@[T]) -> T {
                    return self.val + 1
                }
            }
            
            let foo = Foo@[u8] {
                .val = 41
            }
            let p = foo.baz()
            
            let bar = Foo@[u16] {
                .val = 1041
            }
            let q = bar.baz()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("p"), 42)
        XCTAssertEqual(debugger?.loadSymbolU16("q"), 1042)
    }
    
    func test_EndToEndIntegration_GenericStruct_ImplFor() {
        let debugger = run(program: """
            trait Incrementer {
                func increment(self: *Incrementer)
            }

            struct RealIncrementer[T] {
                val: T
            }

            impl[T] Incrementer for RealIncrementer@[T] {
                func increment(self: *RealIncrementer@[T]) {
                    self.val = self.val + 1
                }
            }

            var realIncrementer = RealIncrementer@[u16] { .val = 41 }
            let incrementer: Incrementer = &realIncrementer
            incrementer.increment()
            let p = realIncrementer.val
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("p"), 42)
    }
    
    func test_EndToEndIntegration_GenericStruct_ImplFor_WithinAFunction() {
        let debugger = run(program: """
            func myFunction() -> u16 {
                trait Incrementer {
                    func increment(self: *Incrementer)
                }

                struct RealIncrementer[T] {
                    val: T
                }

                impl[T] Incrementer for RealIncrementer@[T] {
                    func increment(self: *RealIncrementer@[T]) {
                        self.val = self.val + 1
                    }
                }

                var realIncrementer = RealIncrementer@[u16] { .val = 41 }
                let incrementer: Incrementer = &realIncrementer
                incrementer.increment()
                return realIncrementer.val
            }
            let p = myFunction()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("p"), 42)
    }
    
    func test_EndToEndIntegration_GenericTrait() {
        let debugger = run(program: """
            trait Adder[T] {
                func add(self: *Adder@[T], amount: T) -> T
            }

            struct MyAdder[T] {
                val: T
            }

            impl[T] Adder@[T] for MyAdder@[T] {
                func add(self: *MyAdder@[T], amount: T) -> T {
                    self.val = self.val + amount
                    return self.val
                }
            }

            var myAdder = MyAdder@[u16] { .val = 41 }
            let adder: Adder@[u16] = &myAdder
            let a = adder.add(1)
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 42)
    }
    
    func DISABLED_test_EndToEndIntegration_InferReturnTypeVoidLeadsToCompilerCrash() {
        // We're going to infer a return type of void for `myFunction' which
        // means `p' has a return type of void. The compiler then proceeds to
        // crash in peekRegister() while trying to compile this bad assignment.
        let debugger = run(program: """
            func myFunction() {
                return 1000
            }
            let p = myFunction()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("p"), 42)
    }
    
    func test_EndToEndIntegration_UseGenericTypeVariableInFunction() {
        let debugger = run(program: """
            typealias usize = u16
            let kHeapStart: usize = 0x1000
            var addrOfNextAllocation: usize = kHeapStart
            func malloc[T]() -> *T {
                let size = sizeof(T)
                let result: *T = addrOfNextAllocation bitcastAs *T
                addrOfNextAllocation = addrOfNextAllocation + size
                return result
            }
            let a = malloc@[u16]()
            """)
        
        XCTAssertEqual(0x1000, debugger?.loadSymbolPointer("a"))
    }
}
