//
//  PopDeadStoreEliminationOptimizationPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore

public class PopDeadStoreEliminationOptimizationPass: NSObject {
    public var unoptimizedProgram = PopBasicBlock()
    public var optimizedProgram = PopBasicBlock()
    public enum DependencyState: Equatable { case needed, notNeeded }
    public var registers: [RegisterName : DependencyState] = [:]
    let setOfTrackedRegisters: Set<RegisterName> = [.A, .B, .D, .G, .H, .X, .Y, .U, .V]
    
    public override init() {
        super.init()
        markAllRegisters(.needed)
    }
    
    public func optimize() {
        markAllRegisters(.needed)
        optimizedProgram = unoptimizedProgram.reversed().map({ rewrite($0) }).reversed()
    }
    
    public func rewrite(_ instruction: PopInstruction) -> PopInstruction {
        let rewrittenInstruction: PopInstruction
        if doesAnySubsequentInstructionDependOnThisOne(instruction) {
            rewrittenInstruction = instruction
        } else {
            rewrittenInstruction = .fake
        }
        markRegisters(instruction.setOfRegistersModifiedByThisInstruction, .notNeeded)
        markRegisters(instruction.setOfRegistersOnWhichThisInstructionDepends, .needed)
        return rewrittenInstruction
    }
    
    fileprivate func doesAnySubsequentInstructionDependOnThisOne(_ instruction: PopInstruction) -> Bool {
        if instruction.doesInstructionModifyStateOtherThanRegisterValues {
            return true
        }
        return isAnyRegisterNeeded(instruction.setOfRegistersModifiedByThisInstruction)
    }
    
    public func markAllRegisters(_ value: DependencyState) {
        registers = [:]
        for name in setOfTrackedRegisters {
            registers[name] = value
        }
    }
    
    public func markRegisters(_ set: Set<RegisterName>, _ value: DependencyState) {
        for reg in set {
            markRegister(reg, value)
        }
    }
    
    public func markRegister(_ name: RegisterName, _ value: DependencyState) {
        if name == .NONE {
            return
        }
        assert(setOfTrackedRegisters.contains(name))
        if setOfTrackedRegisters.contains(name) {
            registers[name] = value
        }
    }
    
    public func isAnyRegisterNeeded(_ set: Set<RegisterName>) -> Bool {
        for reg in set {
            if isRegisterNeeded(reg) {
                return true
            }
        }
        return false
    }
    
    public func isRegisterNeeded(_ name: RegisterName) -> Bool {
        assert(setOfTrackedRegisters.contains(name))
        assert(registers.keys.contains(name))
        return registers[name]! == .needed
    }
}
