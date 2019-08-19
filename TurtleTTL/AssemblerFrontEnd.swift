//
//  AssemblerFrontEnd.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerFrontEnd: NSObject {
    let text: String
    
    public required init(withText text: String) {
        self.text = text
    }
    
    public func compile() -> [Instruction] {
        return [Instruction(opcode: 0, immediate: 0)]
    }
}
