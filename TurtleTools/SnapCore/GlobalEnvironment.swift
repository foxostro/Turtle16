//
//  GlobalEnvironment.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class FunctionsToCompile: NSObject {
    private var queue: [FunctionType] = []
    private var alreadyQueued = Set<String>()
    
    public var isEmpty: Bool {
        queue.isEmpty
    }
    
    public func removeFirst() -> FunctionType {
        queue.removeFirst()
    }
    
    public func enqueue(_ fn: FunctionType) {
        let mangledName = fn.mangledName!
        if !alreadyQueued.contains(mangledName) { // skip duplicates
            queue.append(fn)
            alreadyQueued.insert(mangledName)
        }
    }
}

public class GlobalEnvironment: NSObject {
    public let staticStorageFrame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public let labelMaker = LabelMaker()
    public let tempNameMaker = LabelMaker(prefix: "__temp")
    public var modules: [String : Block] = [:]
    public let functionsToCompile: FunctionsToCompile
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16(),
                functionsToCompile: FunctionsToCompile = FunctionsToCompile()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.functionsToCompile = functionsToCompile
    }
    
    public func hasModule(_ name: String) -> Bool {
        return modules[name] != nil
    }
}
