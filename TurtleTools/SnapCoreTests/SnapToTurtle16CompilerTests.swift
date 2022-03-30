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
        compiler.compile(program: "@")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "@")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected character: `@'")
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
        XCTAssertEqual(AssemblerListingMaker().makeListing(try compiler.assembly.get()), """
            NOP
            HLT
            foo:
            ENTER 1
            SUBI r0, fp, 1
            LI r1, 1
            STORE r1, r0
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
        
        public init(isVerboseLogging: Bool = false,
                    isBoundsCheckEnabled: Bool = false,
                    shouldDefineCompilerIntrinsicFunctions: Bool = false,
                    isUsingStandardLibrary: Bool = false,
                    runtimeSupport: String? = nil,
                    shouldRunSpecificTest: String? = nil,
                    onSerialOutput: ((UInt16) -> Void)? = nil) {
            self.isVerboseLogging = isVerboseLogging
            self.isBoundsCheckEnabled = isBoundsCheckEnabled
            self.shouldDefineCompilerIntrinsicFunctions = shouldDefineCompilerIntrinsicFunctions
            self.isUsingStandardLibrary = isUsingStandardLibrary
            self.runtimeSupport = runtimeSupport
            self.shouldRunSpecificTest = shouldRunSpecificTest
            self.onSerialOutput = onSerialOutput
        }
    }
    
    fileprivate let kMemoryMappedSerialOutputPort = MemoryAddress(0x0001)
    
    fileprivate func makeDebugger(options: Options, program: String) -> SnapDebugConsole? {
        let opts2 = SnapToTurtle16Compiler.Options(isBoundsCheckEnabled: options.isBoundsCheckEnabled,
                                                   shouldDefineCompilerIntrinsicFunctions: options.shouldDefineCompilerIntrinsicFunctions,
                                                   isUsingStandardLibrary: options.isUsingStandardLibrary,
                                                   runtimeSupport: options.runtimeSupport,
                                                   shouldRunSpecificTest: options.shouldRunSpecificTest)
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
        debugger.symbols = compiler.symbolTableRoot
        
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
    
    // TODO: The hlt() compiler intrinsic should probably compile directly to a `HLT' instruction and not to `CALL hlt'. The compiler should inline the definition at the call site. Perhaps we include a compile pass which examines all CALL instructions to determine if they can be directly replaced with a function body from the subroutines table.
    
    // TODO: Remove the GlobalEnvironment object. Move the label maker and module table to SymbolTable. Move the memory layout strategy, and such, to an object which contains platform-specific configuration.
    
    // TODO: Move the subroutines table into SymbolTable.
    
    func test_EndToEndIntegration_Hlt() {
        let opts = Options(shouldDefineCompilerIntrinsicFunctions: true)
        let debugger = run(options: opts, program: """
            var a: u16 = 0
            hlt()
            a = 1
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 0)
    }
    
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
        
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress], 42)
    }
    
    func test_EndToEndIntegration_AssignStructInitializerToStructInstance() {
        let debugger = run(program: """
            struct Foo {
                bar: u8
            }
            var foo: Foo = undefined
            foo = Foo { .bar = 42 }
            """)
        
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress], 42)
    }
    
    func test_EndToEndIntegration_ReadStructMembersThroughPointer() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r: u8 = 0
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            var bar = &foo
            r = bar.x
            """)
        
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress], 1)
    }
    
    func test_EndToEndIntegration_WriteStructMembersThroughPointer() {
        let debugger = run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            var bar = &foo
            bar.x = 2
            """)
        
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress], 2)
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
}
