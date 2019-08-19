//
//  AssemblerFrontEnd.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerFrontEnd: NSObject {
    public struct AssemblerFrontEndError: Error {
        public let message: String
        
        public init(format: String, _ args: CVarArg...) {
            message = String(format:format, arguments:args)
        }
    }
    
    let text: String
    
    public required init(withText text: String) {
        self.text = text
    }
    
    public func compile() throws -> [Instruction] {
        var result = [Instruction(opcode: 0, immediate: 0)]
        for line in text.split(separator: "\n") {
            if line == "" {
                // do nothing
            }
            else if line == "NOP" {
                result.append(Instruction(opcode: 0, immediate: 0))
            } else {
                throw AssemblerFrontEndError(format: "Unrecognized opcode: %@", text)
            }
        }
        return result
    }
}
