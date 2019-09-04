//
//  AssemblerError.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/21/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public struct AssemblerError: Error {
    public let line: Int?
    public let message: String
    
    public init(line: Int, format: String, _ args: CVarArg...) {
        self.line = line
        message = String(format:format, arguments:args)
    }
    
    public init(format: String, _ args: CVarArg...) {
        self.line = nil
        message = String(format:format, arguments:args)
    }
}
