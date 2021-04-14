//
//  CPU.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// Provides an abstract interface to a model of the Turtle16 CPU.
public protocol CPU: NSObject {
    var isResetting: Bool { get }
    var isHalted: Bool { get }
    var pc: UInt16 { get set }
    var instructions: [UInt16] { get set }
    var carry: UInt { get }
    var z: UInt { get }
    var ovf: UInt { get }
    
    var load: (UInt16) -> UInt16 { get set }
    var store: (UInt16, UInt16) -> Void { get set }
    
    var numberOfRegisters: Int { get }
    func setRegister(_ idx: Int, _ val: UInt16)
    func getRegister(_ idx: Int) -> UInt16
    
    func reset()
    func run()
    func step()
}
