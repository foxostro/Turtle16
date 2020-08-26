//
//  CompilerTemporary.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CompilerTemporary: NSObject {
    public let address: Int
    public let size: Int
    public private(set) var refCount = 1
    weak var allocator: CompilerTemporariesAllocator!
    
    public init(address: Int, size: Int, allocator: CompilerTemporariesAllocator) {
        assert(address >= 0)
        assert(size >= 0)
        self.address = address
        self.size = size
        self.allocator = allocator
    }
    
    public func consume() {
        assert(refCount > 0)
        refCount -= 1
        if refCount == 0 {
            allocator.free(self)
        }
    }
    
    public override var debugDescription: String {
        let addressString = String(format: "0x%04x", address)
        return "<\(type(of: self)): address=\(addressString), size=\(size), refCount=\(refCount)>"
    }
}
