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
        public let line: Int
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
    }
    
    public func compile(_ text: String) throws -> [Instruction] {
        var result = [Instruction(opcode: 0, immediate: 0)]
        let lines = text.split(separator: "\n")
        for i in 0..<lines.count {
            let line = String(lines[i])
            if line == "" {
                // do nothing
            } else if line == "NOP" {
                result.append(Instruction())
            } else {
                throw AssemblerFrontEndError(line: i+1,
                                             format: "Unrecognized opcode: %@",
                                             text)
            }
        }
        return result
    }
}
