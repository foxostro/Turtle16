//
//  TokenNumber.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class TokenNumber : Token {
    public let literal: Int
    
    public init(lineNumber: Int, lexeme: String, literal: Int) {
        self.literal = literal
        super.init(lineNumber: lineNumber, lexeme: lexeme)
    }
    
    public override var description: String {
        return String(format: "<%@: lineNumber=%d, lexeme=\"%@\", literal=%@>", String(describing: type(of: self)), lineNumber, lexeme, String(describing: literal))
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenNumber {
            return self == rhs
        }
        return false
    }
}

public func ==(lhs: TokenNumber, rhs: TokenNumber) -> Bool {
    if lhs.lineNumber != rhs.lineNumber {
        return false
    }
    
    if lhs.lexeme != rhs.lexeme {
        return false
    }
    
    return lhs.literal == rhs.literal
}
