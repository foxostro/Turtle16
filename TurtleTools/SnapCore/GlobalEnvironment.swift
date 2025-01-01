//
//  GlobalEnvironment.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class GlobalEnvironment: NSObject {
    public let staticStorageFrame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public let labelMaker = LabelMaker()
    public let tempNameMaker = LabelMaker(prefix: "__temp")
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
}
