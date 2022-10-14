//
//  GlobalEnvironment.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public class FunctionsToCompile: NSObject {
    private var queue: [FunctionType] = []
    
    public var isEmpty: Bool {
        queue.isEmpty
    }
    
    public func removeFirst() -> FunctionType {
        queue.removeFirst()
    }
    
    public func enqueue(_ fn: FunctionType) {
        queue.append(fn)
    }
}

public class GlobalEnvironment: NSObject {
    public var staticStorageOffset = SnapCompilerMetrics.kStaticStorageStartAddress
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public let labelMaker = LabelMaker()
    public let tempNameMaker = LabelMaker(prefix: "__temp")
    public var modules: [String : Block] = [:]
    public let functionsToCompile = FunctionsToCompile()
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func hasModule(_ name: String) -> Bool {
        return modules[name] != nil
    }
}
