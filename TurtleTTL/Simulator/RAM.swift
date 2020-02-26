//
//  RAM.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents Random Access Memory in the TurtleTTL hardware.
public class RAM {
    var contents: [UInt8]
    
    public var size: Int {
        return contents.count
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
}
