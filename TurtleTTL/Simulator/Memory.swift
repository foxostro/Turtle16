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
    var contents: [UInt8]
    
    public var size: Int {
        return contents.count
    }
    
    public convenience init(memory: Memory) {
        self.init(contents: memory.contents)
    }
    
    public convenience init(data: Data) {
        self.init(contents: [UInt8](data))
    }
    
    public convenience init(size: Int = 65536) {
        var contents = [UInt8]()
        contents.reserveCapacity(size)
        for _ in 0..<size {
            contents.append(0)
        }
        self.init(contents: contents)
    }
    
    public required init(contents: [UInt8]) {
        self.contents = contents
    }
    
    public func store(value: UInt8, to address: Int) {
        contents[address] = value
    }
    
    public func load(from address: Int) -> UInt8 {
        return contents[address]
    }
    
    public var data: Data {
        let data = NSMutableData()
        for value in contents {
            data.append(Data([value]))
        }
        return data as Data
    }
    
    public override func copy() -> Any {
        return Memory(memory: self)
    }
}
