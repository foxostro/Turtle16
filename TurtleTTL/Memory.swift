//
//  Memory.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Memory: NSObject {
    public let size:Int
    public var contents: [UInt8]
    
    public var data: Data {
        get {
            let data = NSMutableData()
            for value in contents {
                data.append(Data([value]))
            }
            return data as Data
        }
        set(newData) {
            contents = [UInt8](newData)
        }
    }
    
    public subscript(i:Int) -> UInt8 {
        get {
            return contents[i]
        }
        set(newValue) {
            contents[i] = newValue
        }
    }
    
    public required init(size: Int) {
        self.size = size
        contents = [UInt8]()
        contents.reserveCapacity(size)
        for _ in 0..<size {
            contents.append(0xff)
        }
        super.init()
    }
}
