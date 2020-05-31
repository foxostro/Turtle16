//
//  CompilerError.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 8/21/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class CompilerError: Error {
    public let line: Int?
    public let message: String
    
    public init(line: Int, format: String, _ args: CVarArg...) {
        self.line = line
        message = String(format:format, arguments:args)
    }
    
    public init(line: Int, message: String) {
        self.line = line
        self.message = message
    }
    
    public init(message: String) {
        line = nil
        self.message = message
    }
    
    public init(format: String, _ args: CVarArg...) {
        line = nil
        message = String(format:format, arguments:args)
    }
    
    public var localizedDescription: String {
        if let line = line {
            return "\(line): \(message)"
        } else {
            return message
        }
    }
    
    public var debugDescription: String {
        return localizedDescription
    }
    
    public var description: String {
        return localizedDescription
    }
    
    public static func makeOmnibusError(fileName: String?, errors: [CompilerError]) -> CompilerError {
        var message = ""
        
        for error in errors {
            if fileName != nil {
                message += fileName! + ":"
            }
            if let lineNumber = error.line {
                message += String(lineNumber) + ": "
            }
            message += String(format: "error: %@\n", error.message)
        }
        
        if errors.count == 1 {
            message += String(format: "1 error generated\n")
        } else {
            message += String(format: "%d errors generated\n", errors.count)
        }
        
        return CompilerError(message: message)
    }
}

public func ==(lhs: CompilerError, rhs: CompilerError) -> Bool {
    guard lhs.line == rhs.line else { return false }
    guard lhs.message == rhs.message else { return false }
    return true
}
