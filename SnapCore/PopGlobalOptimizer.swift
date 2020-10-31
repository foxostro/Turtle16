//
//  PopGlobalOptimizer.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class PopGlobalOptimizer: NSObject {
    public var unoptimizedProgram = PopBasicBlock()
    public var optimizedProgram = PopBasicBlock()
    
    public func optimize() {
        let partitioner = PopBasicBlockPartitioner()
        partitioner.entireProgram = unoptimizedProgram
        partitioner.partition()
        let unoptimizedBasicBlocks = partitioner.allBasicBlocks
        
        let optimizedBasicBlocks: [PopBasicBlock] = unoptimizedBasicBlocks.map {
            let local = PopLocalOptimizer()
            local.unoptimizedProgram = $0
            local.optimize()
            return local.optimizedProgram
        }
        
        // Join the optimized basic blocks.
        optimizedProgram = PopBasicBlock()
        for basicBlock in optimizedBasicBlocks {
            optimizedProgram += basicBlock
        }
    }
}
