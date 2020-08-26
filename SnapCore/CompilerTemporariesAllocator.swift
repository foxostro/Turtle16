//
//  CompilerTemporariesAllocator.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CompilerTemporariesAllocator: NSObject {
    var indexSet: IndexSet
    
    public convenience override init() {
        self.init(base: SnapToCrackleCompiler.kTemporaryStorageStartAddress, limit: SnapToCrackleCompiler.kTemporaryStorageStartAddress + SnapToCrackleCompiler.kTemporaryStorageLength)
    }
    
    public init(base: Int, limit: Int) {
        assert(base >= 0)
        assert(limit >= base)
        indexSet = IndexSet(integersIn: base..<limit)
    }
    
    public func allocate(size: Int = 2) -> CompilerTemporary {
        // TODO: need a nice compiler error when a temporary cannot be allocated
        return maybeAllocate(size: size)!
    }
    
    public func maybeAllocate(size: Int) -> CompilerTemporary? {
        assert(size >= 0)
        for range in indexSet.rangeView {
            if range.count >= size {
                indexSet.remove(integersIn: range.startIndex ..< (range.startIndex+size))
                let temporary = CompilerTemporary(address: range.startIndex, size: size, allocator: self)
                return temporary
            }
        }
        return nil
    }
    
    public func free(_ temporary: CompilerTemporary) {
        assert(temporary.refCount == 0)
        indexSet.insert(integersIn: temporary.address ..< (temporary.address+temporary.size))
    }
}
