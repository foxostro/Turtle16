//
//  Memory.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents a memory-like object in hardware such as a ROM or RAM.
public class Memory: NSObject {
    public let storage: UnsafeMutableRawBufferPointer
    
    public var size: Int {
        return storage.count
    }
    
    deinit {
        storage.deallocate()
    }
    
    public convenience init(memory: Memory) {
        self.init(memory.data)
    }
    
    public convenience init<C>(_ source: C) where C : Collection, C.Element == UInt8 {
        self.init(size: source.count)
        storage.copyBytes(from: source)
    }
    
    public init(size: Int = 65536) {
        storage = UnsafeMutableRawBufferPointer.allocate(byteCount: size, alignment: 4)
    }
    
    public func store(value: UInt8, to address: Int) {
        storage.storeBytes(of: value, toByteOffset: address, as: UInt8.self)
    }
    
    public func load(from address: Int) -> UInt8 {
        return storage.load(fromByteOffset: address, as: UInt8.self)
    }
    
    public var data: Data {
        return Data(storage)
    }
    
    public override func copy() -> Any {
        return Memory(memory: self)
    }
}
