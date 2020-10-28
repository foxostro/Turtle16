//
//  CrackleLocalOptimizer.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CrackleLocalOptimizer: NSObject {
    public var unoptimizedProgram = CrackleBasicBlock()
    public var optimizedProgram = CrackleBasicBlock()
    
    public func optimize() {
        optimizedProgram = unoptimizedProgram
        doConstantPropagation()
    }
    
    fileprivate func doConstantPropagation() {
        let constantPropagation = CrackleConstantPropagationOptimizationPass()
        constantPropagation.unoptimizedProgram = optimizedProgram
        constantPropagation.optimize()
        optimizedProgram = constantPropagation.optimizedProgram
    }
}
