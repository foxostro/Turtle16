//
//  FuseListMaker.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

/// Tool for making a JEDEC fuse list. This is useful when simulating ATF22V10.
public final class FuseListMaker {
    public private(set) var fuseList: [UInt] = []
    public var defaultFuseState: UInt = 0
    
    public var numberOfFuses: Int {
        get {
            return fuseList.count
        }
        
        set (value) {
            if value > fuseList.count {
                fuseList += Array<UInt>(repeating: defaultFuseState, count: value - fuseList.count)
            } else {
                fuseList.removeLast(fuseList.count - value)
            }
        }
    }
    
    public func set(begin: Int, array: [UInt]) {
        assert(begin >= 0 && begin + array.count <= fuseList.count)
        for i in 0..<array.count {
            fuseList[begin+i] = array[i] & 1
        }
    }
    
    public func set(begin: Int, bitmap: String) {
        set(begin: begin, array: bitmap.unicodeScalars.map({ (scalar) -> UInt in
            assert(scalar == "0" || scalar == "1")
            return scalar == "0" ? 0 : 1
        }))
    }
    
    public init() {}
}
