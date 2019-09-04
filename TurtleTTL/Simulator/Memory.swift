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
    let contents: [UInt8]
    
    public var size: Int {
        return contents.count
    }
    
    public convenience init(withData data: Data) {
        self.init(withContents: [UInt8](data))
    }
    
    public convenience init(withSize size: Int) {
        var contents = [UInt8]()
        contents.reserveCapacity(size)
        for _ in 0..<size {
            contents.append(0)
        }
        self.init(withContents: contents)
    }
    
    public required init(withContents contents: [UInt8]) {
        self.contents = contents
    }
    
    public func withStore(value: UInt8, to address: Int) -> RAM {
        var updatedContents = self.contents
        updatedContents[address] = value
        return RAM(withContents: updatedContents)
    }
    
    public func load(from address: Int) -> UInt8 {
        return self.contents[address]
    }
    
    public var data: Data {
        let data = NSMutableData()
        for value in contents {
            data.append(Data([value]))
        }
        return data as Data
    }
}
