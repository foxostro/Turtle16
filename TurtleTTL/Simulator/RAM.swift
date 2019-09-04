//
//  RAM.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents RAM in the TurtleTTL hardware.
public class RAM: Memory {
    public convenience init() {
        self.init(withSize: 65536)
    }
}
