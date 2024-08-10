//
//  Frame.swift
//  SnapCore
//
//  Created by Andrew Fox on 3/5/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation

// An activation record, usually a stack frame
public class Frame: NSObject {
    public enum GrowthDirection {
        case down, up
    }
    public let growthDirection: GrowthDirection
    public private(set) var storagePointer: Int
    public let initialStoragePointer: Int
    
    public struct Pair: Hashable, Equatable {
        let identifier: String
        let symbol: Symbol
    }
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
        return lhs.isEqual(rhs)
    }
    
    open override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? Frame else {
            return false
        }
        guard storagePointer == rhs.storagePointer else {
            return false
        }
        guard growthDirection == rhs.growthDirection else {
            return false
        }
        guard symbols == rhs.symbols else {
            return false
        }
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(storagePointer)
        hasher.combine(growthDirection)
        hasher.combine(symbols)
        return hasher.finalize()
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
