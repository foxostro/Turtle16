//
//  PopLocalOptimizer.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class PopLocalOptimizer: NSObject {
    public var unoptimizedProgram = PopBasicBlock()
    public var optimizedProgram = PopBasicBlock()
    
    public func optimize() {
        optimizedProgram = unoptimizedProgram
    
        let constantPropagation = PopConstantPropagationOptimizationPass()
        constantPropagation.unoptimizedProgram = optimizedProgram
        constantPropagation.optimize()
        optimizedProgram = constantPropagation.optimizedProgram
        
        let deadStoreElimination = PopDeadStoreEliminationOptimizationPass()
        deadStoreElimination.unoptimizedProgram = optimizedProgram
        deadStoreElimination.optimize()
        optimizedProgram = deadStoreElimination.optimizedProgram
    }
}
