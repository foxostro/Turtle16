//
//  CompilerTemporariesAllocator.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CompilerTemporariesAllocator: NSObject {
    var indexSet: IndexSet
    public private(set) var liveTemporaries: [CompilerTemporary] = []
    
    public convenience override init() {
        self.init(base: SnapCompilerMetrics.kTemporaryStorageStartAddress, limit: SnapCompilerMetrics.kTemporaryStorageStartAddress + SnapCompilerMetrics.kTemporaryStorageLength)
    }
    
    public init(base: Int, limit: Int) {
        assert(base >= 0)
        assert(limit >= base)
        indexSet = IndexSet(integersIn: base..<limit)
    }
    
    public func allocate(size: Int = 2) -> CompilerTemporary {
        // TODO: I wonder whether this should throw a CompilerError instead of dying in an abort?
        guard let temporary = maybeAllocate(size: size) else {
            print("Failed to allocate compiler temporary of size \(size).")
            abort()
        }
        return temporary
    }
    
    public func maybeAllocate(size size0: Int) -> CompilerTemporary? {
        assert(size0 >= 0)
        
        let size = size0 + (size0 % 2) // round up to nearest multiple of two
        
        for range in indexSet.rangeView {
            if range.count >= size {
                indexSet.remove(integersIn: range.startIndex ..< (range.startIndex+size))
                let temporary = CompilerTemporary(address: range.startIndex, size: size, allocator: self)
                liveTemporaries.append(temporary)
                return temporary
            }
        }
        return nil
    }
    
    public func free(_ temporary: CompilerTemporary) {
        assert(temporary.refCount == 0)
        indexSet.insert(integersIn: temporary.unsafeAddress ..< (temporary.unsafeAddress+temporary.size))
        liveTemporaries.removeAll(where: {
            indexSet.contains(integersIn: $0.unsafeAddress ..< ($0.unsafeAddress+$0.size))
        })
    }
}
