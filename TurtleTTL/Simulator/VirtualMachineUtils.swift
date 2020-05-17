//
//  VirtualMachineUtils.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class VirtualMachineUtils: NSObject {
    public static func makeInstructionROM(program: String) -> InstructionMemory {
        let instructionMemory = InstructionMemoryRev1()
        let instructions = TraceUtils.assemble(program)
        instructionMemory.store(instructions: instructions)
        return instructionMemory
    }
    
    public static func assertEquivalentStateProgressions(logger: Logger?,
                                                         expected: [CPUStateSnapshot],
                                                         actual: [CPUStateSnapshot]) -> Bool {
        if actual.count != expected.count {
            logger?.append("The two sequences have different lengths: expected.count=\(expected.count) and actual.count=\(actual.count)")
        }
        
        var expected = expected
        var actual = actual
        
        var prevExpectedState = expected.removeFirst()
        var prevActualState = actual.removeFirst()
        
        for i in 0..<min(expected.count, actual.count) {
            let expectedState = expected[i]
            let actualState = actual[i]
            if expectedState != actualState {
                if let logger = logger {
                    logger.append("The sequence diverges from expectation at uptime=\(actualState.uptime).")
                    logger.append("Expected the following progression:")
                    CPUStateSnapshot.logChanges(logger: logger,
                                                prevState: prevExpectedState,
                                                nextState: expectedState)
                    logger.append("Got the following progression instead:")
                    CPUStateSnapshot.logChanges(logger: logger,
                                                prevState: prevActualState,
                                                nextState: actualState)
                }
                return false
            }
            prevExpectedState = expectedState
            prevActualState = actualState
        }
        
        return true
    }
}
