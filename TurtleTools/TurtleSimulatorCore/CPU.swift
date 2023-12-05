//
//  CPU.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public struct PipelineStageInfo {
    public let name: String
    public let pc: UInt16?
    public let status: String
}

public struct MemoryAddress: Equatable {
    public let value: Int
    
    public init(_ value: UInt16) {
        self.value = Int(value)
    }
}

// Provides an abstract interface to a model of the Turtle16 CPU.
public protocol CPU: NSObject, NSSecureCoding {
    var timeStamp: UInt { get }
    var isResetting: Bool { get }
    var isHalted: Bool { get }
    var isStalling: Bool { get }
    var pc: UInt16 { get set }
    var instructions: [UInt16] { get set }
    var decoder: Decoder { get set }
    
    var n: UInt { get }
    var c: UInt { get }
    var z: UInt { get }
    var v: UInt { get }
    
    var load: (MemoryAddress) -> UInt16 { get set }
    var store: (UInt16, MemoryAddress) -> Void { get set }
    
    var numberOfRegisters: Int { get }
    func setRegister(_ idx: Int, _ val: UInt16)
    func getRegister(_ idx: Int) -> UInt16
    
    var numberOfPipelineStages: Int { get }
    func getPipelineStageInfo(_ idx: Int) -> PipelineStageInfo
    
    func reset()
    func run()
    func step()
}
