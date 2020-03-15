//
//  ComputerRev2Tests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ComputerRev2Tests: XCTestCase {
    let isVerboseLogging = false
    
    func makeComputer() -> ComputerRev2 {
        let computer = ComputerRev2()
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.logger = makeLogger()
        return computer
    }
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    func testFunctionCallAndReturn() {
        // Perform a function call and return and assert that the return lands
        // in the expected position in the program. For Rev2 hardare, this means
        // that execution resumes on the second delay slot. (unfortunately)
        let computer = makeComputer()
        
        computer.provideInstructions(TraceUtils.assemble("""
LI A, 100
LI B, 1
LXY fn
JALR
ADD A
ADD A # The return address points here!
ADD A

HLT

fn:
LI A, 0
MOV X, G
MOV Y, H
JMP
NOP
NOP
"""))
        try! computer.runUntilHalted(maxSteps: 20)
        
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
    }
    
    func testSerialOutputDemo() {
        let computer = makeComputer()
        
        computer.provideInstructions(TraceUtils.assemble("""
LI A, 0
LI B, 0
LI D, 6 # The Serial Interface device
LI X, 0
LI Y, 0
LI U, 0
LI V, 0

LI A, 'r'
LXY serial_put
JALR
NOP
NOP

LI A, 'e'
LXY serial_put
JALR
NOP
NOP

LI A, 'a'
LXY serial_put
JALR
NOP
NOP

LI A, 'd'
LXY serial_put
JALR
NOP
NOP

LI A, 'y'
LXY serial_put
JALR
NOP
NOP

LI A, '.'
LXY serial_put
JALR
NOP
NOP

LI A, 10
LXY serial_put
JALR
NOP
NOP

HLT





serial_put:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

# The A register contains the character to output.
# Copy it into memory at address 5.
LI U, 0
LI V, 5
MOV M, A

LI D, 6 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
JALR
NOP
NOP
LI Y, 1 # Data Port
LI U, 0
LI V, 5
MOV P, M # Retrieve the byte from address 5 and pass it to the serial device.
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
JALR
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
JALR
NOP
NOP

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
JMP
NOP
NOP





# We only require a single clock cycle delay in the Simulator.
# However, this delay should be a few milliseconds on real hardware.
delay:

MOV X, G
MOV Y, H
JMP
NOP
NOP

"""))
        var serialOutput = ""
        computer.didUpdateSerialOutput = {
            serialOutput = $0
        }
        
        XCTAssertNoThrow(try computer.runUntilHalted(maxSteps: 620))
        XCTAssertEqual(serialOutput, """
ready.

""")
    }
}
