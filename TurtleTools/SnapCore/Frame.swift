//
//  Frame.swift
//  SnapCore
//
//  Created by Andrew Fox on 3/5/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation

// An activation record, usually a stack frame
public final class Frame: Equatable, Hashable {
    public enum GrowthDirection { case down, up }
    
    public struct Pair: Hashable, Equatable {
        let identifier: String
        let symbol: Symbol
    }
    
    public let growthDirection: GrowthDirection
    public private(set) var storagePointer: Int
    public let initialStoragePointer: Int
    public private(set) var symbols: [Pair] = []
    
    public init(storagePointer: Int = 0, growthDirection: GrowthDirection = .up) {
        self.initialStoragePointer = storagePointer
        self.storagePointer = storagePointer
        self.growthDirection = growthDirection
    }
    
    public func reset() {
        storagePointer = initialStoragePointer
        symbols.removeAll()
    }
    
    public static func ==(lhs: Frame, rhs: Frame) -> Bool {
        guard lhs.storagePointer == rhs.storagePointer else { return false }
        guard lhs.growthDirection == rhs.growthDirection else { return false }
        guard lhs.symbols == rhs.symbols else { return false }
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storagePointer)
        hasher.combine(growthDirection)
        hasher.combine(symbols)
    }
    
    // Allocate memory within a frame, returning the offset for the allocation
    public func allocate(size: Int) -> Int {
        switch growthDirection {
        case .down:
            storagePointer += size
            return storagePointer
            
        case .up:
            let result = storagePointer
            storagePointer += size
            return result
        }
    }
    
    // Record that a symbol is attached to this frame.
    public func add(identifier: String, symbol: Symbol) {
        symbols.append(Pair(identifier: identifier, symbol: symbol))
    }
}
