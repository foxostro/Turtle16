//
//  CompilerError.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 8/21/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class CompilerError: Error {
    public let sourceAnchor: SourceAnchor?
    public let message: String
    
    public init(sourceAnchor: SourceAnchor?, message: String) {
        self.sourceAnchor = sourceAnchor
        self.message = message
    }
    
    public convenience init(sourceAnchor: SourceAnchor?, format: String, _ args: CVarArg...) {
        self.init(sourceAnchor: sourceAnchor,
                  message: String(format:format, arguments:args))
    }
    
    private var lineNumberPrefix: String {
        var result: String = ""
        if let lineNumbers = sourceAnchor?.lineNumbers {
            if lineNumbers.count == 1 {
                result = "\(lineNumbers.lowerBound+1): "
            } else {
                result = "\(lineNumbers.lowerBound+1)..\(lineNumbers.upperBound): "
            }
        }
        return result
    }
    
    public var localizedDescription: String {
        return lineNumberPrefix + message
    }
    
    public var debugDescription: String {
        return localizedDescription
    }
    
    public var description: String {
        return localizedDescription
    }
    
    public static func makeOmnibusError(fileName: String?, errors: [CompilerError]) -> CompilerError {
        var sourceAnchor: SourceAnchor? = errors.first?.sourceAnchor
        var message = ""
        
        for error in errors {
            sourceAnchor = sourceAnchor?.union(error.sourceAnchor)
            if fileName != nil {
                message += fileName! + ": "
            }
            message += "error: \(error.localizedDescription)\n"
        }
        
        if errors.count == 1 {
            message += "1 error generated\n"
        } else {
            message += "\(errors.count) errors generated\n"
        }
        
        return CompilerError(sourceAnchor: sourceAnchor, message: message)
    }
}

public func ==(lhs: CompilerError, rhs: CompilerError) -> Bool {
    guard lhs.sourceAnchor == rhs.sourceAnchor else { return false }
    guard lhs.message == rhs.message else { return false }
    return true
}
