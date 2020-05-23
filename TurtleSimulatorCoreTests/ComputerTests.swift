//
//  ComputerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class ComputerTests: XCTestCase {
    let isVerboseLogging = false
    let kUpperInstructionRAM = 0
    let kLowerInstructionRAM = 1
    
    func makeComputer() -> Computer {
        let computer = Computer()
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.logger = makeLogger()
        return computer
    }
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    func testReset() {
        let computer = makeComputer()
        computer.reset()
        XCTAssertEqual(computer.cpuState.pc.value, 0)
        XCTAssertEqual(computer.cpuState.pc_if.value, 0)
        XCTAssertEqual(computer.cpuState.registerC.value, 0)
        XCTAssertEqual(computer.cpuState.controlWord.unsignedIntegerValue, ControlWord().unsignedIntegerValue)
        XCTAssertEqual(computer.cpuState.uptime, 0)
    }
    
    func testSerialOutput() {
        let computer = makeComputer()
        
        var serialOutput = ""
        computer.didUpdateSerialOutput = {
            serialOutput += $0
        }
        computer.provideInstructions(TraceUtils.assemble("""
LI D, 7 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay
LI Y, 1 # Data Port
LI P, 65 # Output 'A' through the serial interface device
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay
HLT
"""))
        XCTAssertNoThrow(try computer.runUntilHalted())
        XCTAssertEqual(serialOutput, "A")
    }
    
    func testSerialInput() {
        let computer = makeComputer()
        
        let serialInput = computer.serialInput!
        
        var serialOutput = ""
        computer.didUpdateSerialOutput = {
            serialOutput += $0
        }
        
        serialInput.provide(bytes: [65])
        
        computer.provideInstructions(TraceUtils.assemble("""
LI D, 7 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 2 # "Get" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
MOV A, P # Store the input byte in register A
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay
HLT
"""))
        XCTAssertNoThrow(try computer.runUntilHalted(maxSteps: 14))
        XCTAssertEqual(computer.cpuState.registerA.value, 65)
    }
    
    func testCountUpLoop() {
        let n: UInt8 = 10
        let computer = makeComputer()
        
        computer.provideInstructions(TraceUtils.assemble("""
LXY loop
LI A, 0
loop:
LI B, 1
ADD _
ADD A
LI B, \(n)
CMP
CMP
NOP
NOP
JNE
NOP # branch delay slot
NOP # branch delay slot
HLT
"""))
        XCTAssertNoThrow(try computer.runUntilHalted(maxSteps: 5000))
        XCTAssertEqual(computer.cpuState.registerA.value, n)
    }
    
    func testFibonacci() {
        let computer = makeComputer()
        
        computer.provideInstructions(TraceUtils.assemble("""
# ram[0x0000] --> Fn_1
# ram[0x0001] --> Fn_2
# ram[0x0002] --> Fn
# ram[0x0003] --> i

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
ADD _
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
ADD _
ADD M

# Loop as long as i is less than 12
LI U, 0
LI V, 3
MOV A, M
LI B, 12
CMP
CMP
LXY loop
JL
NOP
NOP

# Return the final value of Fn in A. This should be 233.
LI U, 0
LI V, 2
MOV A, M

HLT
"""))
        XCTAssertNoThrow(try computer.runUntilHalted(maxSteps: 496))
        XCTAssertEqual(computer.cpuState.registerA.value, 233)
    }
    
    func testFunctionCallAndReturn() {
        // Perform a function call and return and assert that the return lands
        // in the expected position in the program. For Rev2 hardare, this means
        // that execution resumes on the second delay slot. (unfortunately)
        let computer = makeComputer()
        
        computer.provideInstructions(TraceUtils.assemble("""
LI V, 100
LI B, 1
LXY fn
JALR
INUV
INUV # The return address points here!
INUV

HLT

fn:
LI V, 0
MOV X, G
MOV Y, H
JMP
NOP
NOP
"""))
        XCTAssertNoThrow(try computer.runUntilHalted(maxSteps: 20))
        XCTAssertEqual(computer.cpuState.registerV.value, 2)
    }
    
    func testSerialGetNumberOfBytes() {
        let computer = makeComputer()
        
        computer.provideInstructions(TraceUtils.assemble("""
LI D, 7 # kSerialInterface
LI Y, 1 # Data Port
LI P, 3 # "Get Number of Bytes" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
MOV A, P # Store the number of available bytes in register A
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay

HLT
"""))

        let serialInput = computer.serialInput!
        serialInput.provide(bytes: Array("hello".data(using: .utf8)!))
        
        XCTAssertNoThrow(try computer.runUntilHalted(maxSteps: 14))
        XCTAssertEqual(computer.cpuState.registerA.value, 5)
    }
    
    func testSerialOutputDemo() {
        let computer = makeComputer()
        
        computer.provideInstructions(TraceUtils.assemble("""
LI A, 0
LI B, 0
LI D, 7 # The Serial Interface device
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

LI D, 7 # The Serial Interface device
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
    
    func testSerialInputDemo() {
        let program = """
beginningOfInputLoop:

LXY serial_get_number_available_bytes
JALR
NOP
NOP
LI B, 0
CMP
CMP
LXY done
JE
NOP
NOP


# Read a byte and echo it back.
LXY serial_get
JALR # The return value is in "A".
NOP
NOP

LXY serial_put # The parameter is in "A".
JALR
NOP
NOP

LXY beginningOfInputLoop
JMP
NOP
NOP

done:
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

LI D, 7 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay
LI Y, 1 # Data Port
LI U, 0
LI V, 5
MOV P, M # Retrieve the byte from address 5 and pass it to the serial device.
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay

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





serial_get:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

LI Y, 1 # Data Port
LI P, 2 # "Get" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
LI U, 0
LI V, 5
MOV M, P # Store the input byte in memory at address 5.
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay

# Set the return value in "A".
LI U, 0
LI V, 5
MOV A, M

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





serial_get_number_available_bytes:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

LI D, 7 # kSerialInterface
LI Y, 1 # Data Port
LI P, 3 # "Get Number of Bytes" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
LI U, 0
LI V, 5
MOV M, P # Store the number of available bytes in memory at address 5.
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay

# Set the return value in "A".
LI U, 0
LI V, 5
MOV A, M

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
"""
        let instructions = TraceUtils.assemble(program)
        let serialInput = Array("hello".data(using: .utf8)!)
        
        let reference = makeComputer()
        reference.logger = nil
        reference.allowsRunningTraces = false
        reference.shouldRecordStatesOverTime = true
        reference.provideInstructions(instructions)
        let referenceSerialInputToken = reference.serialInput!
        referenceSerialInputToken.provide(bytes: serialInput)
        
        XCTAssertNoThrow(try reference.runUntilHalted(maxSteps: 661))
        
        let computer = makeComputer()
        computer.shouldRecordStatesOverTime = true
        computer.provideInstructions(instructions)
        var serialOutput = ""
        computer.didUpdateSerialOutput = { serialOutput = $0 }
        let serialInputToken = computer.serialInput!
        serialInputToken.provide(bytes: serialInput)
        
        XCTAssertNoThrow(try computer.runUntilHalted(maxSteps: 661))
        
        XCTAssertEqual(serialOutput, "hello")
        XCTAssertTrue(VirtualMachineUtils.assertEquivalentStateProgressions(logger: computer.logger,
                                                                            expected: reference.recordedStatesOverTime,
                                                                            actual: computer.recordedStatesOverTime))
    }
        
    func testSubtraction() {
        let computer = makeComputer()
        computer.provideInstructions(TraceUtils.assemble("""
LI A, 10
LI B, 1
SUB _
SUB X
HLT
"""))
        XCTAssertNoThrow(try computer.runUntilHalted())
        XCTAssertEqual(computer.cpuState.registerX.value, 9)
    }
}
