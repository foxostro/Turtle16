//
//  Frame.swift
//  SnapCore
//
//  Created by Andrew Fox on 3/5/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation

// An activation record, usually a stack frame
public class Frame: NSObject {
    public let index: Int
    
    public init(index: Int) {
        self.index = index
    }
}
