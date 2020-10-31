//
//  PopDeadStoreEliminationOptimizationPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class PopDeadStoreEliminationOptimizationPass: NSObject {
    public var unoptimizedProgram = PopBasicBlock()
    public var optimizedProgram = PopBasicBlock()
    public enum DependencyState: Equatable { case needed, notNeeded }
    public var registers: [RegisterName : DependencyState] = [
        .A : .needed,
        .B : .needed,
        .D : .needed,
        .X : .needed,
        .Y : .needed,
        .U : .needed,
        .V : .needed
    ]
    
    public func optimize() {
        optimizedProgram = unoptimizedProgram.reversed().map({ rewrite($0) }).reversed()
    }
    
    public func rewrite(_ instruction: PopInstruction) -> PopInstruction {
        var areAnyDependentsNeeded = false
        for dependent in instruction.dependents {
            if registers[dependent] == .needed {
                areAnyDependentsNeeded = true
            }
        }
        for dependent in instruction.dependents {
            registers[dependent] = .notNeeded
        }
        for dependent in instruction.dependencies {
            registers[dependent] = .needed
        }
        if areAnyDependentsNeeded || instruction.doesInstructionHaveSideEffects {
            return instruction
        }
        return .fake
    }
    
    public func markAllRegisters(_ value: DependencyState) {
        for key in registers.keys {
            registers[key] = value
        }
    }
}
