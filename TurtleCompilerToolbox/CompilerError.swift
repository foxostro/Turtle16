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
}

public func ==(lhs: CompilerError, rhs: CompilerError) -> Bool {
    guard lhs.line == rhs.line else { return false }
    guard lhs.message == rhs.message else { return false }
    return true
}
