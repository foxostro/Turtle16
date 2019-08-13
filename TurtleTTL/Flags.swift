//
//  Flags.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Flags: NSObject {
    public var carryFlag:Int = 0
    public var equalFlag:Int = 0
    override public var description: String {
        return String(format:"{carryFlag: %d, equalFlag: %d}", carryFlag, equalFlag)
    }
}

