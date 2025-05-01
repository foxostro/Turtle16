//
//  SnapCompilerFrontEndTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/7/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class SnapCompilerFrontEndTests: XCTestCase {
    fileprivate typealias Word = TackVirtualMachine.Word
    fileprivate let kRuntime = "runtime_TackVM"
    fileprivate let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()
    fileprivate lazy var kUnionPayloadOffset: Int = {
        memoryLayoutStrategy.sizeof(type: .u16)
    }()
    
    fileprivate func makeCompiler() -> SnapCompilerFrontEnd {
        SnapCompilerFrontEnd(memoryLayoutStrategy: memoryLayoutStrategy)
    }
    
    fileprivate func compile(program: String) throws -> TackProgram {
        let compiler = makeCompiler()
        do {
            return try compiler.compile(program: program)
        }
        catch (let error as CompilerError) {
            let omnibusError = CompilerError.makeOmnibusError(fileName: nil, errors: [error])
            print("compile error: \(omnibusError.message)")
            throw error
        }
    }
    
    fileprivate func expectError(_ result: Result<TackProgram, Error>, _ block: (CompilerError) -> Void) {
        switch result {
        case .failure(let error as CompilerError):
            block(error)
            
        default:
            XCTFail()
        }
    }
    
    func testEmptyProgram() throws {
        let compiler = makeCompiler()
        let tackProgram = try compiler.compile(program: "")
        XCTAssertEqual(tackProgram.listing, "")
    }
    
    func testCompileFailsDuringLexing() {
        let compiler = makeCompiler()
        let result = Result { try compiler.compile(program: "`") }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "`")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "unexpected character: ``'")
        }
    }

    func testCompileFailsDuringParsing() {
        let compiler = makeCompiler()
        let result = Result { try compiler.compile(program: ":") }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, ":")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "operand type mismatch: `:'")
        }
    }

    func testCompileFailsDuringCodeGeneration() {
        let compiler = makeCompiler()
        let result = Result { try compiler.compile(program: "foo") }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "foo")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "use of unresolved identifier: `foo'")
        }
    }

    func testSimpleProgram() throws {
        let tackProgram = try compile(program: """
            let a = 1
            """)
        XCTAssertEqual(tackProgram.listing, """
            0000  LIP p0, 272
            0001  LIUB b1, 1
            0002  SB b1, p0, 0
            """)
    }

    func testFunctionDefinition() throws {
        let tackProgram = try compile(program: """
            func foo() {
                let a = 1
            }
            """)
        
        XCTAssertEqual(tackProgram.listing, """
            0000       HLT
            0001  foo: ENTER 1
            0002       SUBIP p0, fp, 1
            0003       LIUB b1, 1
            0004       SB b1, p0, 0
            0005       LEAVE
            0006       RET
            """)
    }

    fileprivate struct Options {
        public let isVerboseLogging: Bool
        public let isBoundsCheckEnabled: Bool
        public let isUsingStandardLibrary: Bool
        public let runtimeSupport: String?
        public let shouldRunSpecificTest: String?
        public let onSerialOutput: (UInt8) -> Void
        public var onSerialInput: () -> UInt8
        public let injectModules: [String:String]
        
        public init(isVerboseLogging: Bool = false,
                    isBoundsCheckEnabled: Bool = false,
                    isUsingStandardLibrary: Bool = false,
                    runtimeSupport: String? = nil,
                    shouldRunSpecificTest: String? = nil,
                    onSerialOutput: @escaping (UInt8) -> Void = {_ in},
                    onSerialInput: @escaping () -> UInt8 = { 0 },
                    injectModules: [String:String] = [:]) {
            self.isVerboseLogging = isVerboseLogging
            self.isBoundsCheckEnabled = isBoundsCheckEnabled
            self.isUsingStandardLibrary = isUsingStandardLibrary
            self.runtimeSupport = runtimeSupport
            self.shouldRunSpecificTest = shouldRunSpecificTest
            self.onSerialOutput = onSerialOutput
            self.onSerialInput = onSerialInput
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
        vm.onSerialInput = options.onSerialInput

        let debugger = TackDebugger(vm, memoryLayoutStrategy)
        debugger.symbolsOfTopLevelScope = compiler.symbolsOfTopLevelScope

        return debugger
    }

    fileprivate func run(options: Options = Options(), program: String) throws -> TackDebugger {
        let debugger = try makeDebugger(options: options, program: program)
        try debugger.vm.run()
        return debugger
    }

    func test_EndToEndIntegration_SimplestProgram() throws {
        let debugger = try run(program: """
            let a = 42
            """)
        let a = debugger.loadSymbolU8("a")
        XCTAssertEqual(a, 42)
    }

    func test_EndToEndIntegration_i8() throws {
        let debugger = try run(program: """
            var a: i8 = -1
            a = a - 1
            """)
        let a = debugger.loadSymbolI8("a")
        XCTAssertEqual(a, -2)
    }

    func test_EndToEndIntegration_i16() throws {
        let debugger = try run(program: """
            var a: i16 = -1000
            a = a - 1000
            """)
        let a = debugger.loadSymbolI16("a")
        XCTAssertEqual(a, -2000)
    }

    func test_EndToEndIntegration_ForIn_Range_1() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u16 = 100
            for i in 0..10 {
                a = i
            }
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }

    func test_EndToEndIntegration_ForIn_Range_2() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u16 = 255
            let range = 0..10
            for i in range {
                a = i
            }
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }

    func test_EndToEndIntegration_ForIn_Range_SingleStatement() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u16 = 255
            for i in 0..10
                a = i
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }

    func test_EndToEndIntegration_AssignLiteral255ToU16Variable() throws {
        let debugger = try run(program: """
            let a: u16 = 255
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, 255)
    }

    func test_EndToEndIntegration_AssignLiteral255ToU8Variable() throws {
        let debugger = try run(program: """
            var a: u8 = 255
            """)
        let a = debugger.loadSymbolU8("a")
        XCTAssertEqual(a, 255)
    }

    func test_EndToEndIntegration_ForIn_String() throws {
        let debugger = try run(program: """
            var a = 255
            for i in "hello" {
                a = i
            }
            """)
        let a = debugger.loadSymbolU8("a")
        XCTAssertEqual(a, UInt8("o".utf8.first!))
    }

    func test_EndToEndIntegration_ForIn_ArrayOfU16() throws {
        let debugger = try run(program: """
            var a: u16 = 0xffff
            for i in [_]u16{0x1000, 0x2000, 0x3000, 0x4000, 0x5000} {
                a = i
            }
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x5000))
    }

    func test_EndToEndIntegration_SubscriptArray() throws {
        let debugger = try run(program: """
            let arr = [_]u16{0x1000}
            let a: u16 = arr[0]
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }

    func test_EndToEndIntegration_SubscriptSlice() throws {
        let debugger = try run(program: """
            let arr = [_]u16{0x1000}
            let slice: []u16 = arr
            let a: u16 = slice[0]
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }

    func test_EndToEndIntegration_ForIn_DynamicArray_1() throws {
        let debugger = try run(program: """
            var a: u16 = 0xffff
            let arr = [_]u16{0x1000}
            let slice: []u16 = arr
            for i in slice {
                a = i
            }
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }

    func test_EndToEndIntegration_ForIn_DynamicArray_2() throws {
        let debugger = try run(program: """
            var a: u16 = 0xffff
            let arr = [_]u16{1, 2}
            let slice: []u16 = arr
            for i in slice {
                a = i
            }
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(2))
    }

    func test_EndToEndIntegration_Fibonacci() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u16 = 1
            var b: u16 = 1
            var fib: u16 = 0
            for i in 0..10 {
                fib = b + a
                a = b
                b = fib
            }
            """)

        XCTAssertEqual(debugger.loadSymbolU16("a"), 89)
        XCTAssertEqual(debugger.loadSymbolU16("b"), 144)
    }

    func test_EndToEndIntegration_Fibonacci_ExercisingStaticKeyword() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u16 = 1
            var b: u16 = 1
            for i in 0..10 {
                static var fib: u16 = b + a
                a = b
                b = fib
            }
            """)

        XCTAssertEqual(debugger.loadSymbolU16("a"), 89)
        XCTAssertEqual(debugger.loadSymbolU16("b"), 144)
    }

    func test_EndToEndIntegration_Fibonacci_U8_1() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u8 = 1
            var b: u8 = 1
            var fib: u8 = 0
            for i in 0..9 {
                fib = b + a
                a = b
                b = fib
            }
            """)

        XCTAssertEqual(debugger.loadSymbolU8("a"), 55)
        XCTAssertEqual(debugger.loadSymbolU8("b"), 89)
    }

    func test_EndToEndIntegration_Fibonacci_U8_2() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u8 = 1
            var b: u8 = 1
            var fib: u8 = 0
            for i in 0..10 {
                fib = b + a
                a = b
                b = fib
            }
            """)

        XCTAssertEqual(debugger.loadSymbolU8("a"), 89)
        XCTAssertEqual(debugger.loadSymbolU8("b"), 144)
    }

    func testLocalVariablesDoNotSurviveTheLocalScope() throws {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                {
                    var a = 1
                    a = 2
                }
                a = 3
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 4..<5)
            XCTAssertEqual(error.message, "use of unresolved identifier: `a'")
        }
    }

    func testLocalVariablesDoNotSurviveTheLocalScope_ForLoop() {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
                for i in 0..10 {
                    var a = i
                }
                i = 3
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "i")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 3..<4)
            XCTAssertEqual(error.message, "use of unresolved identifier: `i'")
        }
    }
    
    func testVariableDeclarationMayNotShadowAnExistingVariableInSameScope() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
            let a = 1
            let a = false
            """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "constant redefines existing symbol: `a'")
        }
    }
    
    func testVariableDeclarationMayShadowAnExistingVariableInEnclosingScope() throws {
        let program = """
            let a: u16 = 1
            {
                let a = false
            }
            """
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        XCTAssertNoThrow(try compiler.compile(program: program))
    }
    
    func testVariableDeclarationMayShadowAnExistingTypeNameInEnclosingScope() throws {
        let program = """
            typealias a = u8
            {
                let a = false
            }
            """
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        XCTAssertNoThrow(try compiler.compile(program: program))
    }
    
    func testStructDeclarationMayNotShadowTypeInSameScope() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
            struct a {}
            struct a {}
            """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "struct declaration redefines existing type: `a'")
        }
    }
    
    func testStructDeclarationMayShadowAnExistingTypeNameInEnclosingScope() throws {
        let program = """
            struct a {}
            {
                struct a {}
            }
            """
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        XCTAssertNoThrow(try compiler.compile(program: program))
    }
    
    func testStructDeclarationMayShadowAnExistingSymbolNameInEnclosingScope() throws {
        let program = """
            let a = 1
            {
                struct a {
                }
            }
            """
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        XCTAssertNoThrow(try compiler.compile(program: program))
    }
    
    func testFunctionDeclarationMayNotShadowExistingTypeInSameScope() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
            struct a {}
            func a() {}
            """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "function redefines existing type: `a'")
        }
    }
    
    func testFunctionDeclarationMayShadowExistingSymbolInEnclosingScope() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        XCTAssertNoThrow(try compiler.compile(program: """
            func a() {}
            
            func b() {
                func a() {}
            }
            """))
    }
    
    func testFunctionDeclarationMayShadowExistingTypeInEnclosingScope() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(runtimeSupport: kRuntime),
            memoryLayoutStrategy: memoryLayoutStrategy)
        XCTAssertNoThrow(try compiler.compile(program: """
            struct a {}
            
            func b() {
                func a() {}
            }
            """))
    }
    
    func test_EndToEndIntegration_SimpleFunctionCall() throws {
        let debugger = try run(program: """
            var a: u16 = 0
            func foo() {
                a = 0xaa
            }
            foo()
            """)
        XCTAssertEqual(debugger.loadSymbolU16("a"), 0xaa)
    }

    func test_EndToEndIntegration_StaticVarInAFunctionContextIsGivenStaticStorage() throws {
        let debugger = try run(program: """
            func foo() {
                static var a: u16 = 0xaa
                asm("BREAK")
            }
            foo()
            """)
        let symbol = try debugger.symbols?.resolve(identifier: "a")
        XCTAssertEqual(symbol?.storage, .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress))
        XCTAssertEqual(debugger.loadSymbolU16("a"), 0xaa) // var a
        try debugger.vm.run()
    }
    
    func test_EndToEndIntegration_VarInFunctionIsGivenAutomaticStackStorageByDefault() throws {
        let debugger = try run(program: """
            func foo() {
                var a: u16 = 0xaa
                asm("BREAK")
            }
            foo()
            """)
        let symbol = try debugger.symbols?.resolve(identifier: "a")
        XCTAssertEqual(symbol?.storage, .automaticStorage(offset: 1))
        XCTAssertEqual(debugger.loadSymbolU16("a"), 0xaa) // var a
        try debugger.vm.run()
    }

    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_0() throws {
        let debugger = try run(program: """
            var a = 0xaa
            {
                var b = 0xbb
                {
                    var c = 0xcc
                    asm("BREAK")
                }
            }
            """)
        
        let a = try debugger.symbols?.resolve(identifier: "a")
        XCTAssertEqual(a?.storage, .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress+0))
        XCTAssertEqual(debugger.loadSymbolU8("a"), 0xaa)
        
        let b = try debugger.symbols?.resolve(identifier: "b")
        XCTAssertEqual(b?.storage, .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress+1))
        XCTAssertEqual(debugger.loadSymbolU8("b"), 0xbb)
        
        let c = try debugger.symbols?.resolve(identifier: "c")
        XCTAssertEqual(c?.storage, .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress+2))
        XCTAssertEqual(debugger.loadSymbolU8("c"), 0xcc)
    }

    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_1() throws {
        let debugger = try run(program: """
            var a = 0xaa
            {
                var b = a
                {
                    {
                        {
                            var c = b
                            asm("BREAK")
                        }
                    }
                }
            }
            """)
        
        let a = try debugger.symbols?.resolve(identifier: "a")
        XCTAssertEqual(a?.storage, .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress+0))
        XCTAssertEqual(debugger.loadSymbolU8("a"), 0xaa)
        
        let b = try debugger.symbols?.resolve(identifier: "b")
        XCTAssertEqual(b?.storage, .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress+1))
        XCTAssertEqual(debugger.loadSymbolU8("b"), 0xaa)
        
        let c = try debugger.symbols?.resolve(identifier: "c")
        XCTAssertEqual(c?.storage, .staticStorage(offset: SnapCompilerMetrics.kStaticStorageStartAddress+2))
        XCTAssertEqual(debugger.loadSymbolU8("c"), 0xaa)
    }

    func test_EndToEndIntegration_StoreLocalVariableDefinedSeveralScopesUp_StackFramesNotEqualToScopes() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU8("a"), 0xaa)
    }

    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8() throws {
        let debugger = try run(program: """
            func foo() -> u8 {
                return 42
            }
            let a = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("a"), 42)
    }

    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU16() throws {
        let debugger = try run(program: """
            func foo() -> u16 {
                return 0xabcd
            }
            let a = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU16("a"), 0xabcd)
    }

    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8PromotedToU16() throws {
        let debugger = try run(program: """
            func foo() -> u16 {
                return 0xaa
            }
            let a = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU16("a"), 0x00aa)
    }

    func test_EndToEndIntegration_NestedFunctionDeclarations() throws {
        let debugger = try run(program: """
            func foo() -> u8 {
                let val = 0xaa
                func bar() -> u8 {
                    return val
                }
                return bar()
            }
            let a = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("a"), 0xaa)
    }

    func test_EndToEndIntegration_ReturnFromInsideIfStmt() throws {
        let debugger = try run(program: """
            func foo() -> u8 {
                if 1 + 1 == 2 {
                    return 0xaa
                } else {
                    return 0xbb
                }
            }
            let a = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("a"), 0xaa)
    }

    func testMissingReturn_1() throws {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                func foo() -> u8 {
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "foo")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "missing return in a function expected to return `u8'")
        }
    }

    func testMissingReturn_2() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                func foo() -> u8 {
                    if false {
                        return 1
                    }
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "foo")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "missing return in a function expected to return `u8'")
        }
    }

    func testUnexpectedNonVoidReturnValueInVoidFunction() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                func foo() {
                    return 1
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "1")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "unexpected non-void return value in void function")
        }
    }

    func test_EndToEndIntegration_PromoteInAssignmentStatement() throws {
        let debugger = try run(program: """
            var result = 0xabcd
            result = 42
            """)

        XCTAssertEqual(debugger.loadSymbolU16("result"), 42)
    }

    func test_EndToEndIntegration_PromoteParameterInCall() throws {
        let debugger = try run(program: """
            var result = 0xabcd
            func foo(n: u16) {
                result = n
            }
            foo(42)
            """)

        XCTAssertEqual(debugger.loadSymbolU16("result"), 42)
    }

    func test_EndToEndIntegration_PromoteReturnValue() throws {
        let debugger = try run(program: """
            func foo(n: u8) -> u16 {
                return n
            }
            let result = foo(42)
            """)

        XCTAssertEqual(debugger.loadSymbolU16("result"), 42)
    }

    func test_EndToEndIntegration_MutuallyRecursiveFunctions() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolBool("a"), true)
    }

    func test_EndToEndIntegration_MutuallyRecursiveFunctions_u16() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolBool("a"), true)
    }

    func test_EndToEndIntegration_RecursiveFunctions_u8() throws {
        let debugger = try run(program: """
            var count = 0
            func foo(n: u8) {
                if n > 0 {
                    count = count + 1
                    foo(n - 1)
                }
            }
            foo(10)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("count"), 10)
    }

    func test_EndToEndIntegration_RecursiveFunctions_u16() throws {
        let debugger = try run(program: """
            var count = 0
            func foo(n: u16) {
                if n > 0 {
                    count = count + 1
                    foo(n - 1)
                }
            }
            foo(10)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("count"), 10)
    }

    func test_EndToEndIntegration_FunctionCallsInExpression() throws {
        let debugger = try run(program: """
            func foo(n: u8) -> u8 {
                return n
            }
            let r = foo(2) + 1
            """)

        XCTAssertEqual(debugger.loadSymbolU8("r"), 3)
    }

    func test_EndToEndIntegration_RecursiveFunctions_() throws {
        let debugger = try run(program: """
            func foo(n: u8) -> u8 {
                if n == 0 {
                    return 0
                }
                return foo(n - 1) + 1
            }
            let count = foo(1)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("count"), 1)
    }

    func test_EndToEndIntegration_ReturnInVoidFunction() throws {
        _ = try run(program: """
            func foo() {
                return
            }
            foo()
            """)
    }

    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Let() throws {
        let debugger = try run(program: """
            let foo: u16 = 0xffff
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 0xffff)
    }

    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Var() throws {
        let debugger = try run(program: """
            var foo: u16 = 0xffff
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 0xffff)
    }

    func test_EndToEndIntegration_DeclareVariableWithExplicitType_PromoteU8ToU16() throws {
        let debugger = try run(program: """
            let foo: u16 = 10
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 10)
    }

    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Bool() throws {
        let debugger = try run(program: """
            let foo: bool = true
            """)

        XCTAssertEqual(debugger.loadSymbolBool("foo"), true)
    }

    func test_EndToEndIntegration_DeclareVariableWithExplicitType_CannotConvertU16ToBool() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                let foo: bool = 0xffff
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "0xffff")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "cannot assign value of type `integer constant 65535' to type `const bool'")
        }
    }

    func test_EndToEndIntegration_CastU16DownToU8() throws {
        let debugger = try run(program: """
            var foo: u16 = 1
            let bar: u8 = foo as u8
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 1)
        XCTAssertEqual(debugger.loadSymbolU8("bar"), 1)
    }

    func test_EndToEndIntegration_RawMemoryAccess() throws {
        // TODO: Add a platform-dependent type `usize' and use that to store the address here
        let debugger = try run(program: """
            let address: u16 = 0x5000
            let pointer: *u16 = address bitcastAs *u16
            pointer.pointee = 0xabcd
            let value: u16 = pointer.pointee
            """)

        XCTAssertEqual(debugger.loadSymbolU16("address"), 0x5000)
        XCTAssertEqual(debugger.loadSymbolPointer("pointer"), 0x5000)
        XCTAssertEqual(debugger.vm.loadw(address: 0x5000), 0xabcd)
        XCTAssertEqual(debugger.loadSymbolU16("value"), 0xabcd)
    }
    
    func test_EndToEndIntegration_Hlt() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var p: *u16 = 0x8000 bitcastAs *u16
            p.pointee = 0
            __hlt()
            p.pointee = 1
            """)
        let word = debugger.vm.loadw(address: 0x8000)
        XCTAssertEqual(word, 0)
    }

    func test_EndToEndIntegration_DeclareArrayType_InferredType() throws {
        let debugger = try run(program: """
            let arr = [_]u8{1, 2, 3}
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU8(3, "arr"), [1, 2, 3])
    }

    func test_EndToEndIntegration_DeclareArrayType_ExplicitType() throws {
        let debugger = try run(program: """
            let arr: [_]u8 = [_]u8{1, 2, 3}
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU8(3, "arr"), [1, 2, 3])
    }

    func test_EndToEndIntegration_FailToAssignScalarToArray() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                let arr: [_]u8 = 1
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "1")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "cannot assign value of type `integer constant 1' to type `[_]const u8'")
        }
    }

    func test_EndToEndIntegration_FailToAssignFunctionToArray() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                func foo(bar: u8, baz: u16) -> bool {
                    return false
                }
                let arr: [_]u16 = foo
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "foo")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 3..<4)
            XCTAssertEqual(error.message, "inappropriate use of a function type (Try taking the function's address instead.)")
        }
    }

    func test_EndToEndIntegration_CannotAddArrayToInteger() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                let foo = [_]u8{1, 2, 3}
                let bar = 1 + foo
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "1 + foo")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "binary operator `+' cannot be applied to operands of types `integer constant 1' and `[3]const u8'")
        }
    }

    func test_EndToEndIntegration_ArrayOfIntegerConstantsConvertedToArrayOfU16OnInitialAssignment() throws {
        let debugger = try run(program: """
        let arr: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
        """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(10, "arr"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }

    func test_EndToEndIntegration_ArrayOfU8ConvertedToArrayOfU16OnInitialAssignment() throws {
        let debugger = try run(program: """
            let arr: [_]u16 = [_]u16{42 as u8}
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(1, "arr"), [42])
    }

    func test_EndToEndIntegration_ReadArrayElement_U16() throws {
        let debugger = try run(program: """
            var result: u16 = 0
            let arr: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            result = arr[0]
            """)

        XCTAssertEqual(debugger.loadSymbolU16("result"), 100)
    }

    func test_EndToEndIntegration_CastArrayLiteralFromArrayOfU8ToArrayOfU16() throws {
        let debugger = try run(program: """
            let foo = [_]u8{1, 2, 3} as [_]u16
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(3, "foo"), [1, 2, 3])
    }

    func test_EndToEndIntegration_FailToCastIntegerLiteralToArrayOfU8BecauseOfOverflow() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                let foo = [_]u8{0x1001, 0x1002, 0x1003} as [_]u8
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "0x1001")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "integer constant `4097' overflows when stored into `u8'")
        }
    }

    // TODO: Eliminate LvalueExpressionTypeChecker and RvalueExpressionTypeChecker. Replace with functions lvalueType() and rvalueType() which work like in a manner similar to existing lvalue() and rvalue() functions.

    func test_EndToEndIntegration_CastArrayOfU16ToArrayOfU8() throws {
        let debugger = try run(program: """
            let foo = [_]u16{0x1001 as u16, 0x1002 as u16, 0x1003 as u16} as [_]u8
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU8(3, "foo"), [1, 2, 3])
    }

    func test_EndToEndIntegration_ReassignArrayContentsWithLiteralArray() throws {
        let debugger = try run(program: """
            var arr: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
            arr = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(10, "arr"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }

    func test_EndToEndIntegration_ReassignArrayContentsWithArrayIdentifier() throws {
        let debugger = try run(program: """
            var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
            let b: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            a = b
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(10, "a"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }

    func test_EndToEndIntegration_ReassignArrayContents_ConvertingFromArrayOfU8ToArrayOfU16() throws {
        let debugger = try run(program: """
            var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
            let b = [_]u8{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
            a = b
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(10, "a"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }

    func test_EndToEndIntegration_AccessVariableInFunction_U8() throws {
        let debugger = try run(program: """
            func foo() -> u8 {
                let result: u8 = 42
                return result
            }
            let bar = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("bar"), 42)
    }

    func test_EndToEndIntegration_AccessVariableInFunction_U16() throws {
        let debugger = try run(program: """
            func foo() -> u16 {
                let result: u16 = 42
                return result
            }
            let bar: u16 = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU16("bar"), 42)
    }

    func test_EndToEndIntegration_SumLoop() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            func sum() -> u8 {
                var accum = 0
                for i in 0..3 {
                    accum = accum + 1
                }
                return accum
            }
            let foo = sum()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("foo"), 3)
    }

    func test_EndToEndIntegration_PassArrayAsFunctionParameter_0() throws {
        let debugger = try run(program: """
            func sum(a: [1]u16) -> u16 {
                return a[0]
            }
            let foo = sum([_]u16{0xabcd})
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 0xabcd)
    }

    func test_EndToEndIntegration_PassArrayAsFunctionParameter_0a() throws {
        let debugger = try run(program: """
            func sum(a: [2]u16) -> u16 {
                return a[0] + a[1]
            }
            let foo = sum([_]u16{1, 2})
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 3)
    }

    func test_Bug_ProgramRunsForever() throws {
        let opts = Options()
        let debugger = try run(options: opts, program: """
            func sum() -> u16 {
                let a = [_]u16{1, 2}
                return a[0]
            }
            let foo = sum()
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 1)
    }

    func test_EndToEndIntegration_PassArrayAsFunctionParameter_1() throws {
        let debugger = try run(program: """
            func sum(a: [3]u16) -> u16 {
                return a[0] + a[1] + a[2]
            }
            let foo = sum([_]u16{1, 2, 3})
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 6)
    }

    func test_EndToEndIntegration_PassArrayAsFunctionParameter_2() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            func sum(a: [3]u16) -> u16 {
                var accum: u16 = 0
                for i in 0..3 {
                    accum = accum + a[i]
                }
                return accum
            }
            let foo = sum([_]u16{1, 2, 3})
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 6)
    }

    func test_EndToEndIntegration_ReturnArrayByValue_U8() throws {
        let debugger = try run(program: """
            func makeArray() -> [3]u8 {
                return [_]u8{1, 2, 3}
            }
            let foo = makeArray()
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU8(3, "foo"), [1, 2, 3])
    }

    func test_EndToEndIntegration_ReturnArrayByValue_U16() throws {
        let debugger = try run(program: """
            func makeArray() -> [3]u16 {
                return [_]u16{0x1234, 0x5678, 0x9abc}
            }
            let foo = makeArray()
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(3, "foo"), [0x1234, 0x5678, 0x9abc])
    }

    func test_EndToEndIntegration_PassTwoArraysAsFunctionParameters_1() throws {
        let debugger = try run(program: """
            func sum(a: [3]u16, b: [3]u16, c: u16) -> u16 {
                return (a[0] + b[0] + a[1] + b[1] + a[2] + b[2]) * c
            }
            let foo = sum([_]u16{1, 2, 3}, [_]u16{4, 5, 6}, 2)
            """)

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 42)
    }

    func test_EndToEndIntegration_PassTwoArraysAsFunctionParameters_1a() throws {
        let debugger = try run(program: """
            func sum(a: [3]u8, b: [3]u8, c: u8) -> u8 {
                return (a[0] + b[0] + a[1] + b[1] + a[2] + b[2]) + c
            }
            let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("foo"), 23)
    }

    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            func sum(a: [3]u8, b: [3]u8, c: u8) -> [3]u8 {
                var result = [_]u8{0, 0, 0}
                for i in 0..3 {
                    result[i] = (a[i] + b[i]) * c
                }
                return result
            }
            let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU8(3, "foo"), [10, 14, 18])
    }

    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue_U16() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            func sum(a: [3]u16, b: [3]u16, c: u16) -> [3]u16 {
                var result = [_]u16{0, 0, 0}
                for i in 0..3 {
                    result[i] = (a[i] + b[i]) * c
                }
                return result
            }
            let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
            """)

        XCTAssertEqual(debugger.loadSymbolArrayOfU16(3, "foo"), [10, 14, 18])
    }

    func test_EndToEndIntegration_BugWhenStackVariablesAreDeclaredAfterForLoop() throws {
        let opts = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            func foo() -> u16 {
                for i in 0..3 {
                }
                let a = 42
                return a
            }
            let b = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU16("b"), 42)
    }

    func testSerialOutput_HelloWorld() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            __puts("Hello, World!")
            """)
        
        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }

    func testSerialOutput_Panic() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            __panic("oops!")
            __puts("Hello, World!")
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: oops!\n")
    }

    func testArrayOutOfBoundsError() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let arr = "Hello"
            let n = 10
            let foo = arr[n]
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }

    func test_EndToEndIntegration_ReadAndWriteToStructMember() throws {
        let debugger = try run(program: """
            var result: u8 = 0
            struct Foo {
                bar: u8
            }
            var foo: Foo = undefined
            foo.bar = 42
            result = foo.bar
            """)

        XCTAssertEqual(debugger.loadSymbolU8("result"), 42)
    }

    func test_EndToEndIntegration_StructInitialization() throws {
        let debugger = try run(program: """
            struct Foo {
                bar: u8
            }
            let foo = Foo { .bar = 42 }
            """)

        guard let symbol = debugger.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        
        guard let offset = symbol.storage.offset else {
            XCTFail("symbol is missing an expected offset: \(symbol)")
            return
        }
        
        XCTAssertEqual(debugger.vm.loadb(address: UInt(offset)), 42)
    }

    func test_EndToEndIntegration_AssignStructInitializerToStructInstance() throws {
        let debugger = try run(program: """
            struct Foo {
                bar: u8
            }
            var foo: Foo = undefined
            foo = Foo { .bar = 42 }
            """)

        guard let symbol = debugger.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        guard let offset = symbol.storage.offset else {
            XCTFail("symbol is missing an expected offset: \(symbol)")
            return
        }

        XCTAssertEqual(debugger.vm.loadb(address: UInt(offset)), 42)
    }

    func test_EndToEndIntegration_ReadStructMembersThroughPointer() throws {
        let debugger = try run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r: u8 = 0
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            var bar = &foo
            r = bar.x
            """)

        guard let symbol = debugger.symbols?.maybeResolve(identifier: "r") else {
            XCTFail("failed to resolve identifier \"r\"")
            return
        }
        guard let offset = symbol.storage.offset else {
            XCTFail("symbol is missing an expected offset: \(symbol)")
            return
        }

        XCTAssertEqual(debugger.vm.loadb(address: UInt(offset)), 1)
    }

    func test_EndToEndIntegration_WriteStructMembersThroughPointer() throws {
        let debugger = try run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            var bar = &foo
            bar.x = 2
            """)

        guard let symbol = debugger.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        guard let offset = symbol.storage.offset else {
            XCTFail("symbol is missing an expected offset: \(symbol)")
            return
        }

        XCTAssertEqual(debugger.vm.loadb(address: UInt(offset)), 2)
    }

    func test_EndToEndIntegration_PassPointerToStructAsFunctionParameter() throws {
        let debugger = try run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r: u8 = 0
            var bar = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) -> u8 {
                return foo.x + foo.y + foo.z
            }
            r = doTheThing(&bar)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("r"), 6)
    }

    func test_EndToEndIntegration_CannotMakeMutatingPointerFromConstant_1() throws {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                let foo: u16 = 0xabcd
                var bar: *u16 = &foo
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.message, "cannot assign value of type `*const u16' to type `*u16'")
        }
    }

    func test_EndToEndIntegration_CannotMakeMutatingPointerFromConstant_2() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                struct Foo { x: u8, y: u8, z: u8 }
                let bar = Foo { .x = 1, .y = 2, .z = 3 }
                func doTheThing(foo: *Foo) {
                    foo.x = foo.y * foo.z
                }
                doTheThing(&bar)
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.message, "cannot convert value of type `*const Foo' to expected argument type `*Foo' in call to `doTheThing'")
        }
    }

    func test_EndToEndIntegration_MutateThePointeeThroughAPointer() throws {
        let debugger = try run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var bar = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) {
                foo.x = foo.y * foo.z
            }
            doTheThing(&bar)
            """)

        guard let symbol = debugger.symbols?.maybeResolve(identifier: "bar") else {
            XCTFail("failed to resolve identifier \"bar\"")
            return
        }
        guard let offset = symbol.storage.offset else {
            XCTFail("symbol is missing an expected offset: \(symbol)")
            return
        }

        XCTAssertEqual(debugger.vm.loadb(address: UInt(offset)), 6)
    }

    func test_EndToEndIntegration_FunctionReturnsPointerToStruct_Right() throws {
        let debugger = try run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r: u8 = 0
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) -> *Foo {
                return foo
            }
            r = doTheThing(&foo).x
            """)

        XCTAssertEqual(debugger.loadSymbolU8("r"), 1)
    }

    func test_EndToEndIntegration_FunctionReturnsPointerToStruct_Left() throws {
        let debugger = try run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *Foo) -> *Foo {
                return foo
            }
            doTheThing(&foo).x = 42
            """)

        guard let symbol = debugger.symbols?.maybeResolve(identifier: "foo") else {
            XCTFail("failed to resolve identifier \"foo\"")
            return
        }
        guard let offset = symbol.storage.offset else {
            XCTFail("symbol is missing an expected offset: \(symbol)")
            return
        }

        XCTAssertEqual(debugger.vm.loadb(address: UInt(offset)), 42)
    }

    func test_EndToEndIntegration_GetArrayCountThroughAPointer() throws {
        let debugger = try run(program: """
            var r: u16 = 0
            let arr = [_]u8{ 1, 2, 3, 4 }
            let ptr = &arr
            r = ptr.count
            """)

        XCTAssertEqual(debugger.loadSymbolU16("r"), 4)
    }

    func test_EndToEndIntegration_GetDynamicArrayCountThroughAPointer() throws {
        let debugger = try run(program: """
            var r: u16 = 0
            let arr = [_]u8{ 1, 2, 3, 4 }
            let dyn: []u8 = arr
            let ptr = &dyn
            r = ptr.count
            """)

        XCTAssertEqual(debugger.loadSymbolU16("r"), 4)
    }

    func test_EndToEndIntegration_GetPointeeOfAPointerThroughAPointer() throws {
        let debugger = try run(program: """
            var r: u16 = 0
            let foo: u16 = 0xcafe
            let bar = &foo
            let baz = &bar
            r = baz.pointee.pointee
            """)

        XCTAssertEqual(debugger.loadSymbolU16("r"), 0xcafe)
    }

    func test_EndToEndIntegration_FunctionParameterIsPointerToConstType() throws {
        let debugger = try run(program: """
            struct Foo { x: u8, y: u8, z: u8 }
            var r = 0
            var foo = Foo { .x = 1, .y = 2, .z = 3 }
            func doTheThing(foo: *const Foo) -> *const Foo {
                return foo
            }
            r = doTheThing(&foo).x
            """)

        XCTAssertEqual(debugger.loadSymbolU8("r"), 1)
    }

    func test_EndToEndIntegration_CallAStructMemberFunction_1() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU8("r"), 42)
    }

    func test_EndToEndIntegration_CallAStructMemberFunction_2() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU8("r"), 42)
    }

    func test_EndToEndIntegration_CallAStructMemberFunction_3() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU8("r"), 42)
    }

    func test_EndToEndIntegration_CallAStructMemberFunction_4() throws {
        let debugger = try run(program: """
            var r: u8 = 0
            struct Foo {
                val: u8
            }
            impl Foo {
                func bar(self: *Foo) -> u8 {
                    return self.val
                }
            }
            let foo = Foo {
                .val = 42
            }
            r = foo.bar()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("r"), 42)
    }
    
    func test_EndToEndIntegration_CallAStructMemberFunction_5() throws {
        let debugger = try run(program: """
            var r: u8 = 0
            struct Foo {
                val: u8
            }
            impl Foo {
                func bar(self: *Foo) -> u8 {
                    return self.val
                }
            }
            let foo = Foo {
                .val = 42
            }
            r = Foo.bar(foo)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("r"), 42)
    }

    func test_EndToEndIntegration_LinkedList() throws {
        let debugger = try run(program: """
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

        guard let symbol = debugger.symbols?.maybeResolve(identifier: "r") else {
            XCTFail("failed to resolve identifier \"r\"")
            return
        }
        guard let offset = symbol.storage.offset else {
            XCTFail("symbol is missing an expected offset: \(symbol)")
            return
        }

        XCTAssertEqual(debugger.vm.loadb(address: UInt(offset+kUnionPayloadOffset)), 0x2a)
    }

    func test_EndToEndIntegration_Match_WithExtraneousClause() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
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
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "foo: bool")
            XCTAssertEqual(error.message, "extraneous clause in match statement: bool")
        }
    }

    func test_EndToEndIntegration_Match_WithMissingClause() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                var r: u8 = 0
                var a: u8 | bool = 0
                match a {
                    (foo: u8) -> {
                        a = 1
                    }
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a")
            XCTAssertEqual(error.message, "match statement is not exhaustive. Missing clause: bool")
        }
    }

    func testFunctionReturnsConstValue() throws {
        let debugger = try run(program: """
            func foo() -> const u8 {
                return 42
            }
            let r = foo()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("r"), 42)
    }

    func testAssignmentExpressionItselfHasAValue() throws {
        let debugger = try run(program: """
            var foo: u8 = 0
            var bar: u8 = (foo = 42)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("foo"), 42)
        XCTAssertEqual(debugger.loadSymbolU8("bar"), 42)
    }

    func testArraySlice_SliceStaticArrayWithCompileTimeRange() throws {
        let options = Options(runtimeSupport: kRuntime)
        let debugger = try run(options: options, program: """
            let helloWorld = "Hello, World!"
            let hello = helloWorld[0..5]
            """)

        XCTAssertEqual(debugger.loadSymbolString("helloWorld"), "Hello, World!")
        XCTAssertEqual(debugger.loadSymbolStringSlice("hello"), "Hello")
    }

    func testArraySlice() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let helloWorld = "Hello, World!"
            let helloComma = helloWorld[0..6]
            let hello = helloComma[0..(helloComma.count-1)]
            __puts(hello)
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello")
    }

    func testArraySlice_PanicDueToArrayBoundsException_1() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let helloWorld = "Hello, World!"
            let begin = 1000
            let limit = 1001
            let helloComma = helloWorld[begin..limit]
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }

    func testArraySlice_PanicDueToArrayBoundsException_2() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let helloWorld = "Hello, World!"
            let limit = 1000
            let helloComma = helloWorld[0..limit]
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }

    func testDynamicArraySlice_PanicDueToArrayBoundsException_1() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let helloWorld = "Hello, World!"
            let helloComma = helloWorld[0..6]
            let begin = 1000
            let hello = helloComma[begin..1001]
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }

    func testDynamicArraySlice_PanicDueToArrayBoundsException_2() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let helloWorld = "Hello, World!"
            let helloComma = helloWorld[0..6]
            let limit = 1001
            let hello = helloComma[0..limit]
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: array access is out of bounds\n")
    }

    func testAssertionFailed() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            assert(1 == 2)
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: assertion failed: `1 == 2' on line 1\n")
    }

    func testRunTests_AllTestsPassed() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            test "foo" {
            }
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "passed\n")
    }

    func testRunTests_FailingAssertMentionsFailingTestByName() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            test "foo" {
                assert(1 == 2)
            }
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "PANIC: assertion failed: `1 == 2' on line 2 in test \"foo\"\n")
    }

    func testImportModule() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(
            isBoundsCheckEnabled: true,
            runtimeSupport: kRuntime,
            onSerialOutput: onSerialOutput,
            injectModules: [
                "MyModule" : """
                             public func foo() {
                                 __puts("Hello, World!")
                             }
                             """
            ])
        _ = try run(
            options: options,
            program: """
                     import MyModule
                     MyModule.foo()
                     """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }
    
    func testCannotInstantiateVariableWithModuleType() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(
                injectedModules: [ "MyModule" : "" ]),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
                import MyModule
                let foo: MyModule = undefined
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "MyModule")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "invalid use of module type")
        }
    }
    
    func testCannotHaveFunctionParameterWithModuleType() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(
                injectedModules: [ "MyModule" : "" ]),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
                import MyModule
                func foo(bar: MyModule) {
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "foo")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "invalid use of module type")
        }
    }
    
    func testCannotDeclareStructWithModuleType() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(
                injectedModules: [ "MyModule" : "" ]),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
                import MyModule
                struct Foo {
                    bar: MyModule
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "MyModule")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 2..<3)
            XCTAssertEqual(error.message, "invalid use of module type")
        }
    }
    
    func testCannotDeclareTraitWithModuleType() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(
                injectedModules: [ "MyModule" : "" ]),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
                import MyModule
                trait Foo {
                    func foo(bar: MyModule)
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "func foo(bar: MyModule)")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 2..<3)
            XCTAssertEqual(error.message, "invalid use of module type")
        }
    }
    
    func testCannotDeclareUnionWithModuleType() throws {
        let compiler = SnapCompilerFrontEnd(
            options: SnapCompilerFrontEnd.Options(
                injectedModules: [ "MyModule" : "" ]),
            memoryLayoutStrategy: memoryLayoutStrategy)
        let result = Result {
            try compiler.compile(program: """
                import MyModule
                typealias Foo = MyModule | u16
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "MyModule | u16")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "invalid use of module type")
        }
    }

    func testBasicFunctionPointerDemonstration() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let ptr = &__puts
            ptr("Hello, World!")
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }

    func testRebindAFunctionPointerAtRuntime_1() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU16("foo"), 3)
    }

    func testRebindAFunctionPointerAtRuntime_2() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            public func fakePuts(s: []const u8) {
                __puts("fake")
            }
            var ptr = &__puts
            ptr = &fakePuts
            ptr("Hello, World!")
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "fake")
    }

    func testFunctionPointerStructMemberCanBeCalledLikeAFunctionMemberCanBeCalled_1() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            struct Serial {
                puts: func ([]const u8) -> void
            }
            let serial = Serial {
                .puts = &__puts
            }
            serial.puts("Hello, World!")
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello, World!")
    }

    func testFunctionPointerStructMemberCanBeCalledLikeAFunctionMemberCanBeCalled_2() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            struct Foo {
                bar: func (*const Foo, []const u8) -> void
            }
            func baz(self: *const Foo, s: []const u8) -> void {
                __puts(s)
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
        let debugger = try run(program: """
            struct Foo {
                arr: [64]u8
            }
            var foo = Foo {
                .arr = undefined
            }
            """)

        let arr = try debugger.symbols?.resolve(identifier: "foo")
        XCTAssertNotNil(arr)
    }

    func testSubscriptStructMemberThatIsAnArray() throws {
        let debugger = try run(program: """
            struct Foo {
                arr: [64]u8
            }
            var foo: Foo = undefined
            foo.arr[0] = 42
            let baz = foo.arr[0]
            """)

        XCTAssertEqual(debugger.loadSymbolU8("baz"), 42)
    }

    func testSubscriptStructMemberThatIsADynamicArray() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU8("baz"), 42)
    }

    func testBugWithCompilerTemporaryPushedTwiceInDynamicArrayBoundsCheck() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let slice: []const u8 = "test"
            test "foo" {
                assert(slice[0] == 't')
            }
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "passed\n")
    }

    func testBugWhenConvertingStringLiteralToDynamicArrayInFunctionParameter() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU8("baz"), 116)
    }

    func testVtableDemo() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "call through vtable pseudo-interface",
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
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

    func testTraitsDemo() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "call through trait interface",
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
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

    func testTraitsFailToCompileBecauseTraitNotImplementedAppropriately() throws {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
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
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "impl Serial for SerialFake {")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 20..<21)
            XCTAssertEqual(error.message, "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2.")
        }
    }

    func testBugSymbolResolutionInStructMethodsPutsMembersInScopeWithBrokenOffsets() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                struct Foo {
                    bar: u8
                }
                
                impl Foo {
                    func init() -> Foo {
                        var baz: Foo = undefined
                        bar = 42
                        return baz
                    }
                }
                
                let foo = Foo.init()
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "bar")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 7..<8)
            XCTAssertEqual(error.message, "use of unresolved identifier: `bar'")
        }
    }

    func testBugWhereRangeInSubscriptCausesUnsupportedExpressionError() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            struct Foo {
                buffer: []const u8
            }
            let foo = Foo {
                .buffer = "Hello, World!"
            }
            foo.buffer = foo.buffer[0..5]
            __puts(foo.buffer)
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello")
    }

    func testBugWhereImplErrorIsMissingSourceAnchor() throws {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                impl Foo {
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "Foo")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 0..<1)
            XCTAssertEqual(error.message, "use of unresolved identifier: `Foo'")
        }
    }

    func testBugWhereConstSelfPointerInTraitCausesCompilerCrash() throws {
        _ = try makeCompiler().compile(program: """
            trait Serial {
                func print(self: *const Serial, s: []const u8)
            }
            """)
    }

    func testCrashWhenReturningAZeroSizeStruct() throws {
        _ = try makeCompiler().compile(program: """
            struct Empty {}
            func init() -> Empty {
                return Empty {}
            }
            let foo = init()
            """)
    }

    func testBugWhereCompilerPermitsImplicitConversionFromUnionToMemberType() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                var a: u8 | bool = 42
                var b: u8 = a
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "cannot implicitly convert a union type `u8 | bool' to `u8'; use an explicit conversion instead")
        }
    }

    func testBugWhereCompilerDoesNotConvertUnionValuesOfDifferentConstness() throws {
        let compiler = makeCompiler()
        _ = try compiler.compile(program: """
            var a: u8 | bool = 42
            let b: u8 | bool = a
            """)
    }

    func testWeCannotUseVariableBeforeItIsDeclared() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                func main() {
                    a = 1
                    var a: u16 = 0
                }
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "use of unresolved identifier: `a'")
        }
    }

    func testBugWhereArraySliceFailsWhenArgumentExpressionIsNotALiteralStructInitializer() throws {
        // This test captures a bug where an array slice expression fails when
        // the argument expression (expression inside the brackets) is not a
        // literal struct-initializer for a Range. In this example, passing a
        // variable of type `Range' fails.
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            let helloWorld = "Hello, World!"
            let range = 0..6
            let helloComma = helloWorld[range]
            let hello = helloComma[0..(helloComma.count-1)]
            __puts(hello)
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Hello")
    }

    func testBugWhereAssignToMemberWithTraitTypeFails() throws {
        let compiler = makeCompiler()
        _ = try compiler.compile(program: """
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
    }

    func testBugWhereCannotAssignStructPointerToTraitObject() throws {
        let debugger = try run(program: """
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

        let serialType = try debugger.symbols?.resolve(identifier: "serial").type
        switch serialType {
        case .constStructType(let typ):
            XCTAssertEqual(typ.associatedTraitType, "Serial")

        default:
            XCTFail("unexpected type: \(String(describing: serialType))")
        }
    }

    func testBugWhereCannotAssignStructToTraitObject() throws {
        let debugger = try run(program: """
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

        let serialType = try debugger.symbols?.resolve(identifier: "serial").type
        switch serialType {
        case .constStructType(let typ):
            XCTAssertEqual(typ.associatedTraitType, "Serial")

        default:
            XCTFail("unexpected type: \(String(describing: serialType))")
        }
    }

    func testBugWhereCannotAssignStructToMutableTraitObject() throws {
        let debugger = try run(program: """
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

        let serialType = try debugger.symbols?.resolve(identifier: "serial").type
        switch serialType {
        case .structType(let typ):
            XCTAssertEqual(typ.associatedTraitType, "Serial")

        default:
            XCTFail("unexpected type: \(String(describing: serialType))")
        }
    }

    func test_EndToEndIntegration_SignedIntegerComparison_LessThan() throws {
        let debugger = try run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b < a
            """)
        let a = debugger.loadSymbolBool("c")
        XCTAssertEqual(a, true)
    }

    func test_EndToEndIntegration_SignedIntegerComparison_LessThanOrEqualTo() throws {
        let debugger = try run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b <= a
            """)
        let a = debugger.loadSymbolBool("c")
        XCTAssertEqual(a, true)
    }

    func test_EndToEndIntegration_SignedIntegerComparison_GreaterThan() throws {
        let debugger = try run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b > a
            """)
        let a = debugger.loadSymbolBool("c")
        XCTAssertEqual(a, false)
    }

    func test_EndToEndIntegration_SignedIntegerComparison_GreaterThanOrEqualTo() throws {
        let debugger = try run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b >= a
            """)
        let a = debugger.loadSymbolBool("c")
        XCTAssertEqual(a, false)
    }

    func test_EndToEndIntegration_SignedIntegerComparison_Equal() throws {
        let debugger = try run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b == a
            """)
        let a = debugger.loadSymbolBool("c")
        XCTAssertEqual(a, false)
    }

    func test_EndToEndIntegration_SignedIntegerComparison_NotEqual() throws {
        let debugger = try run(program: """
            var a: i16 = 1
            var b: i16 = -1
            var c: bool = b != a
            """)
        let a = debugger.loadSymbolBool("c")
        XCTAssertEqual(a, true)
    }

    func test_EndToEndIntegration_Underflow_u8() throws {
        let debugger = try run(program: """
            let a: u8 = 0
            let b = (a - 1) == 255
            """)
        let b = debugger.loadSymbolBool("b")
        XCTAssertEqual(b, true)
    }

    func test_EndToEndIntegration_cast_i16_to_i8() throws {
        let debugger = try run(program: """
            let a: i16 = -1
            let b: i8 = a as i8
            """)
        let b = debugger.loadSymbolI8("b")
        XCTAssertEqual(b, -1)
    }

    func test_EndToEndIntegration_cast_i16_to_u8() throws {
        let debugger = try run(program: """
            let a: i16 = 42
            let b: u8 = a as u8
            """)
        let b = debugger.loadSymbolU8("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_i16_to_u16() throws {
        let debugger = try run(program: """
            let a: i16 = 42
            let b: u16 = a as u16
            """)
        let b = debugger.loadSymbolU16("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_i8_to_i16() throws {
        let debugger = try run(program: """
            let a: i8 = -1
            let b: i16 = a
            """)
        let b = debugger.loadSymbolI16("b")
        XCTAssertEqual(b, -1)
    }

    func test_EndToEndIntegration_cast_i8_to_u8() throws {
        let debugger = try run(program: """
            let a: i8 = 42
            let b: u8 = a as u8
            """)
        let b = debugger.loadSymbolU8("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_i8_to_u16() throws {
        let debugger = try run(program: """
            let a: i8 = 42
            let b: u16 = a as u16
            """)
        let b = debugger.loadSymbolU16("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_u8_to_i8() throws {
        let debugger = try run(program: """
            let a: u8 = 42
            let b: i8 = a as i8
            """)
        let b = debugger.loadSymbolI8("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_u8_to_i16() throws {
        let debugger = try run(program: """
            let a: u8 = 42
            let b: i16 = a
            """)
        let b = debugger.loadSymbolI16("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_u8_to_u16() throws {
        let debugger = try run(program: """
            let a: u8 = 42
            let b: u16 = a as u16
            """)
        let b = debugger.loadSymbolU16("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_u16_to_i8() throws {
        let debugger = try run(program: """
            let a: u16 = 42
            let b: i8 = a as i8
            """)
        let b = debugger.loadSymbolI8("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_u16_to_u8() throws {
        let debugger = try run(program: """
            let a: u16 = 42
            let b: u8 = a as u8
            """)
        let b = debugger.loadSymbolU8("b")
        XCTAssertEqual(b, 42)
    }

    func test_EndToEndIntegration_cast_u16_to_i16() throws {
        let debugger = try run(program: """
            let a: u16 = 42
            let b: i16 = a as i16
            """)
        let b = debugger.loadSymbolI16("b")
        XCTAssertEqual(b, 42)
    }

    func testBUG_FailToPrintStringInUnitTest1() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
            test "foo" {
                let pad1: u16 = 0
                let a = "A"
                __puts(a)
            }
            """)

        let str = String(bytes: serialOutput, encoding: .utf8)
        XCTAssertEqual(str, "Apassed\n")
    }

    func testBUG_PanicDuringIterationOfString() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
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

    func testBUG_InfiniteLoopDuringIterationOfString() throws {
        var serialOutput: [UInt8] = []
        let onSerialOutput = { (value: UInt8) in
            serialOutput.append(value)
        }
        let options = Options(isBoundsCheckEnabled: true,
                              runtimeSupport: kRuntime,
                              shouldRunSpecificTest: "foo",
                              onSerialOutput: onSerialOutput)
        _ = try run(options: options, program: """
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

    func testBUG_printU16_produces_garbage() throws {
        let debugger = try run(program: """
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
        let buffer = debugger.loadSymbolString("buffer")
        XCTAssertEqual(buffer, "abcd")

        let value = debugger.loadSymbolU16("value")
        XCTAssertEqual(value, 0)
    }

    func test_EndToEndIntegration_SizeOf_Variable() throws {
        let debugger = try run(program: """
            let a = sizeof("foo")
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, 3)
    }

    func test_EndToEndIntegration_SizeOf_Type() throws {
        let debugger = try run(program: """
            let a = sizeof(u8)
            """)
        let a = debugger.loadSymbolU16("a")
        XCTAssertEqual(a, 1)
    }

    func test_EndToEndIntegration_GenericFunctionWithExplicitInstantiation() throws {
        let debugger = try run(program: """
            func identity[T](a: T) -> T {
                return a
            }
            let a: u16 = identity@[u16](1000)
            let b: i16 = identity@[i16](-1000)
            """)
        let a = debugger.loadSymbolU16("a")
        let b = debugger.loadSymbolI16("b")
        XCTAssertEqual(a, 1000)
        XCTAssertEqual(b, -1000)
    }

    func test_EndToEndIntegration_GenericFunctionWithAutomaticTypeArgumentDeduction() throws {
        let debugger = try run(program: """
            func identity[T](a: T) -> T {
                return a
            }
            let a = identity(-1000)
            """)
        let a = debugger.loadSymbolI16("a")
        XCTAssertEqual(a, -1000)
    }

    func test_EndToEndIntegration_CompileErrorOnConcreteInstantiationOfGenericFunction() {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                func identity[T](a: T) -> T {
                    return a.count
                }
                let a = identity(1)
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "a.count")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "value of type `const u8' has no member `count'")
        }
    }

    func test_EndToEndIntegration_GenericStructMethod_1() throws {
        let debugger = try run(program: """
            struct Point {
                x: u16,
                y: u16
            }

            impl Point {
                func add[T](p: *const Point, x: T, y: T) -> Point {
                    return Point {
                        .x = p.x + x,
                        .y = p.y + y
                    }
                }
            }

            let p1 = Point { .x = 0, .y = 0 }
            let p2 = Point.add@[u16](&p1, 1, 1)
            let x = p2.x
            let y = p2.y

            """)

        let x = debugger.loadSymbolU16("x")
        let y = debugger.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 1)
    }

    func test_EndToEndIntegration_GenericStructMethod_2() throws {
        let debugger = try run(program: """
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

        let x = debugger.loadSymbolU16("x")
        let y = debugger.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 1)
    }

    func test_EndToEndIntegration_GenericStruct() throws {
        let debugger = try run(program: """
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

        let x = debugger.loadSymbolU16("x")
        let y = debugger.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 2)
    }

    func test_EndToEndIntegration_StructInitializerWithGenericStruct() throws {
        let debugger = try run(program: """
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

        let x = debugger.loadSymbolU16("x")
        let y = debugger.loadSymbolU16("y")
        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 2)
    }

    func test_EndToEndIntegration_GenericStruct_Impl() throws {
        let opts = Options()
        let debugger = try run(options: opts, program: """
            struct Foo[T] {
                val: T
            }

            impl[T] Foo@[T] {
                func baz(self: *const Foo@[T]) -> T {
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

        XCTAssertEqual(debugger.loadSymbolU8("p"), 42)
        XCTAssertEqual(debugger.loadSymbolU16("q"), 1042)
    }

    func test_EndToEndIntegration_GenericStruct_ImplFor() throws {
        let debugger = try run(program: """
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
            var incrementer: Incrementer = &realIncrementer
            incrementer.increment()
            let p = realIncrementer.val
            """)

        XCTAssertEqual(debugger.loadSymbolU16("p"), 42)
    }

    func test_EndToEndIntegration_GenericStruct_ImplFor_WithinAFunction() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU16("p"), 42)
    }

    func test_EndToEndIntegration_GenericTrait() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(debugger.loadSymbolU16("a"), 42)
    }

    func test_EndToEndIntegration_InferReturnTypeVoidLeadsToCompilerCrash() throws {
        // This test tracks a fix for a bug where we try to assign a `void' type
        // to a variable with inferred type `void'. The function myFunction()
        // has an inferred type `void' and so `p' also has the type `void' The
        // two types are equal and so the assignment was deemed acceptable.
        // However, when we later underflow the compiler's register stack when
        // we try to pop the stack to get the register containing its value.
        // This leads to a crash in peekRegister(). The solution is to add a
        // case to ban conversions from `void' to `void'.
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
                func myFunction() {
                }
                let p = myFunction()
                """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "myFunction()")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 2..<3)
            XCTAssertEqual(error.message, "cannot assign value of type `void' to type `void'")
        }
    }

    func test_EndToEndIntegration_UseGenericTypeVariableInFunction() throws {
        let debugger = try run(program: """
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

        XCTAssertEqual(0x1000, debugger.loadSymbolPointer("a"))
    }
    
    func test_EndToEndIntegration_syscall_invalid() throws {
        let opts = Options(
            isUsingStandardLibrary: true,
            runtimeSupport: kRuntime)
        let debugger = try run(options: opts, program: """
            var a: u16 = 0xffff
            asm("BREAK")
            let ptr: *void = undefined
            __syscall(0, ptr)
            a = 0
            """)
        let addr = debugger.addressOfSymbol(try debugger.symbols!.resolve(identifier: "a"))!
        try debugger.vm.run()
        XCTAssertEqual(0xffff, debugger.vm.loadw(address: addr))
    }
    
    func test_EndToEndIntegration_syscall_getc() throws {
        let opts = Options(
            isVerboseLogging: false,
            runtimeSupport: kRuntime,
            onSerialInput: { 65 })
        let debugger = try run(options: opts, program: """
            let result = __getc()
            """)
        
        XCTAssertEqual(65, debugger.loadSymbolU8("result"))
    }
    
    func test_EndToEndIntegration_syscall_putc() throws {
        var output: UInt8? = nil
        let opts = Options(
            runtimeSupport: kRuntime,
            onSerialOutput: { output = $0 })
        _ = try run(options: opts, program: """
            __putc(65)
            """)
        
        XCTAssertEqual(output, 65)
    }
    
    func test_EndToEndIntegration_DisjointImpl() throws {
        let debugger = try run(program: """
            struct Foo {}
            func a() -> u8 {
                impl Foo {
                    func bar() -> u8 {
                        return 42
                    }
                }
                let p = Foo{}
                return p.bar()
            }
            func b() -> u8 {
                impl Foo {
                    func bar() -> u8 {
                        return 13
                    }
                }
                let p = Foo{}
                return p.bar()
            }
            let u = a()
            let v = b()
            """)

        XCTAssertEqual(debugger.loadSymbolU8("u"), 42)
        XCTAssertEqual(debugger.loadSymbolU8("v"), 13)
    }
    
    /// A single struct type may have two independent conformances to the same
    /// trait if they are in entirely disjoint scopes.
    func test_EndToEndIntegration_DisjointImplFor_1() throws {
        let debugger = try run(program: """
            trait Baring {
                func bar(self: *Baring) -> u8
            }
            struct Foo {}
            func a(it: *Foo) -> u8 {
                impl Baring for Foo {
                    func bar(self: *Foo) -> u8 {
                        return 42
                    }
                }
                return it.bar()
            }
            func b(it: *Foo) -> u8 {
                impl Baring for Foo {
                    func bar(self: *Foo) -> u8 {
                        return 13
                    }
                }
                return it.bar()
            }
            let it = Foo{}
            let u = a(it)
            let v = b(it)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("u"), 42)
        XCTAssertEqual(debugger.loadSymbolU8("v"), 13)
    }
    
    /// A trait-object uses a snapshot of the methods on the struct at the time
    /// the trait-object was created
    func test_EndToEndIntegration_DisjointImplFor_2() throws {
        let debugger = try run(program: """
            trait Baring {
                func bar(self: *Baring) -> u8
            }
            struct Foo {}
            func a(p: *Foo) -> *Baring {
                impl Baring for Foo {
                    func bar(self: *Baring) -> u8 {
                        return 42
                    }
                }
                static let q: Baring = p
                return q
            }
            func b(q: *Baring) -> u8 {
                impl Baring for Foo {
                    func bar(self: *Baring) -> u8 {
                        return 13
                    }
                }
                return q.bar()
            }
            var p = Foo{}
            var q = a(p)
            let v = b(q)
            """)

        XCTAssertEqual(debugger.loadSymbolU8("v"), 42)
    }
    
    /// Methods must have a self parameter
    func test_EndToEndIntegration_MethodsMustHaveSelfParameter() throws
    {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
            trait Fooing {
                func foo() -> u8
            }

            struct MyStruct {}

            impl Fooing for MyStruct {
                func foo() -> u8 {
                    return 42
                }
            }

            var obj: Fooing = MyStruct {}
            let v = obj.foo()
            """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "func foo() -> u8")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "every method on a trait must have, as its first parameter, an appropriate `self' parameter")
        }
    }
    
    /// Methods must have a self parameter of an appropriate type
    func test_EndToEndIntegration_MethodSelfParameterMustHaveAppropriateType() throws
    {
        let compiler = makeCompiler()
        let result = Result {
            try compiler.compile(program: """
            trait Fooing {
                func foo(self: bool) -> u8
            }

            struct MyStruct {}

            impl Fooing for MyStruct {
                func foo(self: bool) -> u8 {
                    return 42
                }
            }

            var obj: Fooing = MyStruct {}
            let v = obj.foo(false)
            """)
        }
        expectError(result) { error in
            XCTAssertEqual(error.sourceAnchor?.text, "func foo(self: bool) -> u8")
            XCTAssertEqual(error.sourceAnchor?.lineNumbers, 1..<2)
            XCTAssertEqual(error.message, "every method on a trait must have, as its first parameter, an appropriate `self' parameter: the `self' parameter must have a type that is a pointer to the trait type")
        }
    }
}
