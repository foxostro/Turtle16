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
    public private(set) var storagePointer: Int
    
    public init(storagePointer: Int = 0) {
        self.storagePointer = storagePointer
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
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(storagePointer)
        return hasher.finalize()
    }
    
    @discardableResult public func bumpStoragePointer(_ delta: Int) -> Int {
        storagePointer += delta
        return storagePointer
    }
}
