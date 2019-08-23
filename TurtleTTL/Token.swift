//
//  Token.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Token : NSObject {
    public let type: TokenType
    public let lineNumber: Int
    public let lexeme: String
    public let literal: Any?
    
    public required init(type: TokenType,
                         lineNumber: Int,
                         lexeme: String,
                         literal: Any? = nil) {
        self.type = type
        self.lineNumber = lineNumber
        self.lexeme = lexeme
        self.literal = literal
        super.init()
    }
    
    public override var description: String {
        if let literal = literal {
            return String(format: "<Token: type=%@, lineNumber=%d, lexeme=\"%@\", literal=%@>", String(describing: type), lineNumber, lexeme, String(describing: literal))
        }
        
        return String(format: "<Token: type=%@, lineNumber=%d, lexeme=\"%@\">", String(describing: type), lineNumber, lexeme)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? Token {
            return self == rhs
        }
        return false
    }
}

public func ==(lhs: Token, rhs: Token) -> Bool {
    if lhs.type != rhs.type {
        return false
    }
    
    if lhs.lineNumber != rhs.lineNumber {
        return false
    }
    
    if lhs.lexeme != rhs.lexeme {
        return false
    }
    
    if (lhs.literal == nil) != (rhs.literal == nil) {
        return false
    }
    
    if (lhs.literal == nil) && (rhs.literal == nil) {
        return true
    }
    
    let a = lhs.literal as! NSObject
    let b = rhs.literal as! NSObject
    return a.isEqual(b)
}
