//
//  MemoryLayoutStrategyNull.swift
//  SnapCore
//
//  Created by Andrew Fox on 1/18/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

public struct MemoryLayoutStrategyNull: MemoryLayoutStrategy {
    public init() {}
    public func sizeof(type: SymbolType) -> Int { 0 }
    public var sizeOfSaveArea: Int { 0 }
}
