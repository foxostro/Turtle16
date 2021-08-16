//
//  GlobalEnvironment.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public class GlobalEnvironment: NSObject {
    public var staticStorageOffset = SnapCompilerMetrics.kStaticStorageStartAddress
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public let labelMaker = LabelMaker()
    public var modules: [String : Block] = [:]
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func hasModule(_ name: String) -> Bool {
        return modules[name] != nil
    }
}
