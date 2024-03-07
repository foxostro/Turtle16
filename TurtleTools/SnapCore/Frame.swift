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
    
    public init(storagePointer: Int = 0, growthDirection: GrowthDirection = .up) {
        self.storagePointer = storagePointer
        self.growthDirection = growthDirection
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
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(storagePointer)
        hasher.combine(growthDirection)
        return hasher.finalize()
    }
    
    @discardableResult public func bumpStoragePointer(_ delta: Int) -> Int {
        switch growthDirection {
        case .down:
            storagePointer += delta
            return storagePointer
            
        case .up:
            let result = storagePointer
            storagePointer += delta
            return result
        }
    }
}
