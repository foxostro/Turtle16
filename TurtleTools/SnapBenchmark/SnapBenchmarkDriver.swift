//
//  SnapBenchmarkDriver.swift
//  SnapBenchmark
//
//  Created by Andrew Fox on 9/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleSimulatorCore
import TurtleCore

class SnapBenchmarkDriver: NSObject {
    public struct SnapBenchmarkDriverError: Error {
        public let message: String
        
        public init(format: String, _ args: CVarArg...) {
            message = String(format:format, arguments:args)
        }
    }
    
    class ConsoleLogger: NSObject, Logger {
        var stdout: TextOutputStream
        
        init(output stdout: TextOutputStream) {
            self.stdout = stdout
        }
        
        func append(_ format: String, _ args: CVarArg...) {
            let message = String(format:format, arguments:args)
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
        } catch let error as SnapBenchmarkDriverError {
            reportError(message: error.message)
            } catch let error as CompilerError {
                reportError(message: error.message)
        } catch {
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
        if (arguments.count != 1) {
            throw SnapBenchmarkDriverError(format: "usage: SnapBenchmark\nUnexpectedly got \(arguments.count-1) arguments: \(arguments.debugDescription)")
        }
    }
    
    func runProgramRuntimeBenchmark() throws {
        let computer = Computer()
        computer.logger = isVerboseLogging ? ConsoleLogger(output: stdout) : nil
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.provideInstructions(try generateFibonacciProgram())
        computer.reset()
        stdout.write("Running fibonacci program now...\n")
        let elapsedTime = self.measure {
            try! computer.runUntilHalted()
        }
        let resultAddress = SnapCompilerMetrics.kStaticStorageStartAddress
        let expectedResult = 233
        if computer.dataRAM.load(from: resultAddress) != expectedResult {
            throw SnapBenchmarkDriverError(format: "Program runtime benchmark finished with an incorrect result.")
        }
        stdout.write(String(format: "Program runtime benchmark completed in %@ cycles. This took %g seconds\n", formatDecimal(value: Int(computer.cpuState.uptime)), elapsedTime))
    }
    
    func formatDecimal(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: value))
        return formattedNumber ?? "unknown"
    }
    
    func measure(block: ()->Void) -> TimeInterval {
        let beginningOfPeriod = CFAbsoluteTimeGetCurrent()
        block()
        let elapsedTime = CFAbsoluteTimeGetCurrent() - beginningOfPeriod
        return elapsedTime
    }
    
    func generateFibonacciProgram() throws -> [Instruction] {
        var instructions: [Instruction]! = nil
        let programText = getFibonacciProgram()
        var elapsedTime: TimeInterval = 0
        let n = 1000
        stdout.write(String(format: "Compiling the benchmark program %d times now...\n", n))
        for _ in 0..<n {
            let compiler = SnapCompiler()
            elapsedTime += self.measure {
                compiler.compile(program: programText, base: 0)
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

    func getFibonacciProgram() -> String {
        return """
func fib(n: u8) -> u8 {
    if n <= 1 {
        return n
    } else {
        return fib(n-1) + fib(n-2)
    }
}
let result = fib(13)
"""
    }
}
