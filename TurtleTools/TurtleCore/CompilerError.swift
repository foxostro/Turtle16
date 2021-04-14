//
//  CompilerError.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/21/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class CompilerError: Error {
    public let sourceAnchor: SourceAnchor?
    public let message: String
    
    public convenience init(message: String) {
        self.init(sourceAnchor: nil, message: message)
    }
    
    public init(sourceAnchor: SourceAnchor?, message: String) {
        self.sourceAnchor = sourceAnchor
        self.message = message
    }
    
    public convenience init(sourceAnchor: SourceAnchor?, format: String, _ args: CVarArg...) {
        self.init(sourceAnchor: sourceAnchor,
                  message: String(format:format, arguments:args))
    }
    
    private var lineNumberPrefix: String? {
        return sourceAnchor?.lineNumberPrefix ?? nil
    }
    
    public var context: String? {
        return sourceAnchor?.context ?? nil
    }
    
    public var localizedDescription: String {
        return message
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
            var didIncludeAnyPrefix = false
            if fileName != nil {
                message += fileName! + ":"
                didIncludeAnyPrefix = true
            }
            if let lineNumber = error.lineNumberPrefix {
                message += lineNumber
                didIncludeAnyPrefix = true
            }
            if didIncludeAnyPrefix {
                message += " "
            }
            message += "\(error.message)\n"
            if let context = error.context {
                message += "\(context)\n"
            }
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
