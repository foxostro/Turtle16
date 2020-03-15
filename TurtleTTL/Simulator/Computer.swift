//
//  Computer.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 1/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol Computer {
    var logger: Logger? { get set }
    var stopwatch: ComputerStopwatch? { get set }
    var cpuState: CPUStateSnapshot { get }
    var flagBreak: AtomicBooleanFlag { get }
    var serialInput: SerialInput! { get }
    
    func runUntilHalted(maxSteps: Int) throws -> Void
    func singleStep() -> Void
    func step() -> Void
    func reset() -> Void
    
    func saveMicrocode(to: URL) throws
    
    func provideInstructions(_ instructions: [Instruction]) -> Void
    func loadProgram(from: URL) throws
    func saveProgram(to: URL) throws
    
    var didUpdateSerialOutput:(String)->Void { get set }
}
