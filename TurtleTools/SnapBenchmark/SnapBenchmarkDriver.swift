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
    struct SnapBenchmarkDriverError: Error {
        let message: String

        init(format: String, _ args: CVarArg...) {
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
    var status: Int32 = 1
    var stdout: TextOutputStream = String()
    var stderr: TextOutputStream = String()
    let arguments: [String]
    var benchmarkFilePath: String?

    required init(arguments: [String]) {
        self.arguments = arguments
    }

    func getProgramText() throws -> String {
        guard let filePath = benchmarkFilePath else {
            throw SnapBenchmarkDriverError(
                format: "No benchmark file specified. Usage: SnapBenchmark <file.snap>"
            )
        }

        do {
            return try String(contentsOfFile: filePath, encoding: .utf8)
        } catch {
            throw SnapBenchmarkDriverError(
                format: "Failed to read file '\(filePath)': \(error.localizedDescription)"
            )
        }
    }

    func run() {
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
        var argIndex = 1
        var benchmarkFilePath: String?

        // Parse benchmark file path
        while argIndex < arguments.count {
            let arg = arguments[argIndex]

            if arg.hasPrefix("--") {
                throw SnapBenchmarkDriverError(
                    format: "unknown option '\(arg)'"
                )
            } else {
                // This is the benchmark file path
                benchmarkFilePath = arg
                argIndex += 1
                break
            }
        }

        // Check for extra arguments
        if argIndex < arguments.count {
            throw SnapBenchmarkDriverError(
                format: "unexpected argument '\(arguments[argIndex])'"
            )
        }

        // Require benchmark file path
        guard let filePath = benchmarkFilePath else {
            throw SnapBenchmarkDriverError(
                format: """
                    usage: SnapBenchmark <benchmark_file.snap>

                    Examples:
                      SnapBenchmark Examples/benchmarks/fibonacci.snap
                      SnapBenchmark Examples/benchmarks/micro.snap
                    """
            )
        }

        self.benchmarkFilePath = filePath
        stdout.write("Running benchmark from file: \(filePath)...\n")
    }

    func runProgramRuntimeBenchmark() throws {

        let logger = isVerboseLogging ? ConsoleLogger(output: stdout) : nil
        let compiler = SnapToTurtle16Compiler()
        let programText = try getProgramText()
        let options = SnapToTurtle16Compiler.Options(runtimeSupport: "runtime_Turtle16")
        let program = try compiler.compile(program: programText, options: options)

        if isVerboseLogging {
            logger?.append(AssemblerListingMaker().makeListing(program.assembly))
            logger?.append(program.tackProgram.listing)
        }

        let computer = TurtleComputer(SchematicLevelCPUModel())
        computer.cpu.store = { (value: UInt16, addr: MemoryAddress) in
            if let logger {
                logger.append("store ram[\(addr.value)] <- \(value)")
            }
            computer.ram[addr.value] = value
        }
        computer.cpu.load = { (addr: MemoryAddress) in
            if let logger {
                logger.append("load ram[\(addr.value)] -> \(computer.ram[addr.value])")
            }
            return computer.ram[addr.value]
        }

        computer.instructions = try generateBenchmarkProgram()
        computer.reset()

        let debugger = SnapDebugConsole(computer: computer)
        debugger.symbols = program.symbolsOfTopLevelScope
        if let logger {
            debugger.logger = logger
        }

        let fileName = benchmarkFilePath?.split(separator: "/").last.map(String.init) ?? "program"
        stdout.write("Running \(fileName) program now...\n")
        let elapsedTime = try measure {
            computer.run()
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

    func generateBenchmarkProgram() throws -> [UInt16] {

        var instructions: [UInt16]! = nil
        var elapsedTime: TimeInterval = 0
        let n = 1000
        let programText =
            try getProgramText() // Use the updated method that supports external files

        let benchmarkName = benchmarkFilePath?.split(separator: "/").last.map(String.init) ?? "program"
        stdout.write(String(
            format: "Compiling the %@ benchmark program %d times now...\n",
            benchmarkName,
            n
        ))
        for _ in 0..<n {
            let compiler = SnapToTurtle16Compiler()
            elapsedTime += try measure {
                let options = SnapToTurtle16Compiler.Options(runtimeSupport: "runtime_Turtle16")
                let program = try compiler.compile(program: programText, base: 0, options: options)
                instructions = program.instructions
            }
        }
        elapsedTime = elapsedTime / Double(n)
        stdout.write(String(format: "Compile took an average of %g seconds\n", elapsedTime))
        return instructions
    }
}
