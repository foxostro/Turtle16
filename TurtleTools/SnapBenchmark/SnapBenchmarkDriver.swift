//
//  SnapBenchmarkDriver.swift
//  SnapBenchmark
//
//  Created by Andrew Fox on 9/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleSimulatorCore

class SnapBenchmarkDriver: NSObject {
    let kFibonacciProgram = """
        func fib(n: u8) -> u8 {
            if n <= 1 {
                return n
            } else {
                return fib(n-1) + fib(n-2)
            }
        }
        let result = fib(13)
        """

    public struct SnapBenchmarkDriverError: Error {
        public let message: String

        public init(format: String, _ args: CVarArg...) {
            message = String(format: format, arguments: args)
        }
    }

    class ConsoleLogger: NSObject, Logger {
        var stdout: TextOutputStream

        init(output stdout: TextOutputStream) {
            self.stdout = stdout
        }

        func append(_ format: String, _ args: CVarArg...) {
            let message = String(format: format, arguments: args)
            stdout.write(message + "\n")
        }
    }

    let isVerboseLogging = false
    public var status: Int32 = 1
    public var stdout: TextOutputStream = String()
    public var stderr: TextOutputStream = String()
    let arguments: [String]

    public required init(arguments: [String]) {
        self.arguments = arguments
    }

    public func run() {
        do {
            try tryRun()
        }
        catch let error as SnapBenchmarkDriverError {
            reportError(message: error.message)
        }
        catch let error as CompilerError {
            reportError(message: error.message)
        }
        catch {
            reportError(message: error.localizedDescription)
        }
    }

    func reportError(message: String) {
        stderr.write("Error: " + message + "\n")
    }

    func tryRun() throws {
        try parseArguments()
        try runProgramRuntimeBenchmark()
        status = 0
    }

    func parseArguments() throws {
        if arguments.count != 1 {
            throw SnapBenchmarkDriverError(
                format:
                    "usage: SnapBenchmark\nUnexpectedly got \(arguments.count-1) arguments: \(arguments.debugDescription)"
            )
        }
    }

    func runProgramRuntimeBenchmark() throws {
        let logger = isVerboseLogging ? ConsoleLogger(output: stdout) : nil
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: kFibonacciProgram)
        if compiler.hasError {
            let error = CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors)
            throw error
        }

        if isVerboseLogging {
            logger?.append(AssemblerListingMaker().makeListing(try compiler.assembly.get()))
            logger?.append(try compiler.tack.get().listing)
        }

        let computer = TurtleComputer(SchematicLevelCPUModel())
        computer.cpu.store = { (value: UInt16, addr: MemoryAddress) in
            if let logger = logger {
                logger.append("store ram[\(addr.value)] <- \(value)")
            }
            computer.ram[addr.value] = value
        }
        computer.cpu.load = { (addr: MemoryAddress) in
            if let logger = logger {
                logger.append("load ram[\(addr.value)] -> \(computer.ram[addr.value])")
            }
            return computer.ram[addr.value]
        }

        computer.instructions = try generateFibonacciProgram()
        computer.reset()

        let debugger = SnapDebugConsole(computer: computer)
        debugger.symbols = compiler.symbolsOfTopLevelScope
        if let logger = logger {
            debugger.logger = logger
        }

        stdout.write("Running fibonacci program now...\n")
        let elapsedTime = try measure {
            computer.run()
        }
        let expectedResult: UInt8 = 233
        let actualResult = debugger.loadSymbolU8("result")
        if actualResult != expectedResult {
            let str: String
            if let actualResult = actualResult {
                str = "\(actualResult)"
            }
            else {
                str = "nil"
            }
            throw SnapBenchmarkDriverError(
                format: "Program runtime benchmark finished with an incorrect result: \(str)"
            )
        }
        stdout.write(
            String(
                format: "Program runtime benchmark completed in %@ cycles. This took %g seconds\n",
                formatDecimal(value: computer.timeStamp),
                elapsedTime
            )
        )
    }

    func formatDecimal(value: UInt) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: value as NSNumber)
        return formattedNumber ?? "unknown"
    }

    func measure(block: () throws -> Void) throws -> TimeInterval {
        let beginningOfPeriod = CFAbsoluteTimeGetCurrent()
        try block()
        let elapsedTime = CFAbsoluteTimeGetCurrent() - beginningOfPeriod
        return elapsedTime
    }

    func generateFibonacciProgram() throws -> [UInt16] {
        var instructions: [UInt16]! = nil
        var elapsedTime: TimeInterval = 0
        let n = 1000
        stdout.write(String(format: "Compiling the benchmark program %d times now...\n", n))
        for _ in 0..<n {
            let compiler = SnapToTurtle16Compiler()
            elapsedTime += try measure {
                compiler.compile(program: kFibonacciProgram, base: 0)
            }
            if compiler.hasError {
                throw CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors)
            }
            instructions = compiler.instructions
        }
        elapsedTime = elapsedTime / Double(n)
        stdout.write(String(format: "Compile took an average of %g seconds\n", elapsedTime))
        return instructions
    }
}
