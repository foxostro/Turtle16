//
//  CrackleGlobalOptimizer.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CrackleGlobalOptimizer: NSObject {
    public var unoptimizedProgram = CrackleBasicBlock()
    public var optimizedProgram = CrackleBasicBlock()
    
    public func optimize() {
        let partitioner = CrackleBasicBlockPartitioner()
        partitioner.entireProgram = unoptimizedProgram
        partitioner.partition()
        let unoptimizedBasicBlocks = partitioner.allBasicBlocks
        
        let optimizedBasicBlocks: [CrackleBasicBlock] = unoptimizedBasicBlocks.map {
            let local = CrackleLocalOptimizer()
            local.unoptimizedProgram = $0
            local.optimize()
            return local.optimizedProgram
        }
        
        // Join the optimized basic blocks.
        optimizedProgram = CrackleBasicBlock()
        for basicBlock in optimizedBasicBlocks {
            optimizedProgram.instructions += basicBlock.instructions
            optimizedProgram.mapCrackleInstructionToSource += basicBlock.mapCrackleInstructionToSource
            optimizedProgram.mapCrackleInstructionToSymbols += basicBlock.mapCrackleInstructionToSymbols
        }
    }
}
