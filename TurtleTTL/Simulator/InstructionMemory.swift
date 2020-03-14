//
//  InstructionMemory.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol InstructionMemory: NSObject {
    var size: Int { get }
    var lowerROMData: Data { get }
    var upperROMData: Data { get }
    func load(from address: Int) -> Instruction
    func store(instructions: [Instruction])
    func store(instructions: [Instruction], at address: Int)
    func store(instruction: Instruction, to address: Int)
    func store(value: UInt16, to address: Int)
}
