//
//  TurtleVMBenchmarkDriver.swift
//  TurtleVMBenchmark
//
//  Created by Andrew Fox on 2/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL

class TurtleVMBenchmarkDriver: NSObject {
    public struct TurtleVMBenchmarkDriverError: Error {
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
    
    public required init(withArguments arguments: [String]) {
        self.arguments = arguments
    }
    
    public func run() {
        do {
            try tryRun()
        } catch let error as TurtleVMBenchmarkDriverError {
            reportError(withMessage: error.message)
            } catch let error as AssemblerError {
                reportError(withMessage: error.message)
        } catch {
            reportError(withMessage: error.localizedDescription)
        }
    }
    
    func reportError(withMessage message: String) {
        stderr.write("Error: " + message + "\n")
    }
    
    func tryRun() throws {
        try parseArguments()
        try runBenchmark()
        status = 0
    }
    
    func parseArguments() throws {
        if (arguments.count != 1) {
            throw TurtleVMBenchmarkDriverError(format: "usage: TurtleVMBenchmark\nUnexpectedly got \(arguments.count-1) arguments: \(arguments.debugDescription)")
        }
    }
    
    func runBenchmark() throws {
        let computer = ComputerRev1()
        computer.logger = isVerboseLogging ? ConsoleLogger(output: stdout) : nil
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.provideInstructions(try generateFibonacciProgram())
        computer.reset()
        let elapsedTime = self.measure {
            try! computer.runUntilHalted()
        }
        if computer.cpuState.registerA.value != 233 {
            throw TurtleVMBenchmarkDriverError(format: "Benchmark finished with an incorrect result.")
        }
        stdout.write(String(format: "Benchmark completed in %.1f seconds\n", elapsedTime))
    }
    
    func measure(block: ()->Void) -> TimeInterval {
        let beginningOfPeriod = CFAbsoluteTimeGetCurrent()
        block()
        let elapsedTime = CFAbsoluteTimeGetCurrent() - beginningOfPeriod
        return elapsedTime
    }
    
    func generateFibonacciProgram() throws -> [Instruction] {
        let frontEnd = AssemblerFrontEnd()
        let programText = try getFibonacciProgram()
        frontEnd.compile(programText)
        if frontEnd.hasError {
            let error = frontEnd.makeOmnibusError(fileName: nil, errors: frontEnd.errors)
            throw error
        }
        return frontEnd.instructions
    }

    func getFibonacciProgram() throws -> String {
        return """
# ram[0x0000] --> Fn_1
# ram[0x0001] --> Fn_2
# ram[0x0002] --> Fn
# ram[0x0003] --> i
# ram[0x0004] --> j
# ram[0x0005] --> k

# k := 255
LI U, 0
LI V, 5
LI M, 255
        
outerLoopK:
        
# j := 255
LI U, 0
LI V, 4
LI M, 255

outerLoopJ:

# Fn_1 := 0
LI U, 0
LI V, 0
LI M, 0

# Fn_2 := 1
LI U, 0
LI V, 1
LI M, 1

# i := 0
LI U, 0
LI V, 3
LI M, 0

loop:

# Fn := Fn_1 + Fn_2
LI U, 0
LI V, 0
MOV A, M
LI U, 0
LI V, 1
MOV B, M
ADD A
LI U, 0
LI V, 2
MOV M, A

# Fn_1 := Fn_2
LI U, 0
LI V, 1
MOV A, M
LI U, 0
LI V, 0
MOV M, A

# Fn_2 := Fn
LI U, 0
LI V, 2
MOV A, M
LI U, 0
LI V, 1
MOV M, A

# Increment i
LI U, 0
LI V, 3
MOV A, M
LI B, 1
ADD M

# Loop as long as i is less than 12
LI U, 0
LI V, 3
MOV A, M
LI B, 12
CMP
LXY loop
JL
NOP
NOP

# Increment j
LI U, 0
LI V, 4
MOV A, M
LI B, 1
ADD A
MOV M, A

# Loop as long as j is less than 255
LI B, 255
CMP
LXY outerLoopJ
JL
NOP
NOP

# Increment k
LI U, 0
LI V, 5
MOV A, M
LI B, 1
ADD A
MOV M, A

# Loop as long as k is less than 20
LI B, 20
CMP
LXY outerLoopK
JL
NOP
NOP

# Return the final value of Fn in A. This should be 233.
LI U, 0
LI V, 2
MOV A, M

HLT
"""
    }
}
