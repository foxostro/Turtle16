//
//  Token.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Token : NSObject {
    public let lineNumber: Int
    public let lexeme: String
    public let literal: Any?
    
    public required init(lineNumber: Int,
                         lexeme: String,
                         literal: Any? = nil) {
        self.lineNumber = lineNumber
        self.lexeme = lexeme
        self.literal = literal
        super.init()
    }
    
    public override var description: String {
        if let literal = literal {
            return String(format: "<%@: lineNumber=%d, lexeme=\"%@\", literal=%@>", String(describing: type(of: self)), lineNumber, lexeme, String(describing: literal))
        }
        
        return String(format: "<%@: lineNumber=%d, lexeme=\"%@\">", String(describing: type(of: self)), lineNumber, lexeme)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? Token {
            return self == rhs
        }
        return false
    }
}

public func ==(lhs: Token, rhs: Token) -> Bool {
    if type(of: lhs) != type(of: rhs) {
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

public class TokenEOF : Token {}
public class TokenNewline : Token {}
public class TokenComma : Token {}
public class TokenColon : Token {}
public class TokenNumber : Token {}
public class TokenRegister : Token {}
public class TokenNOP : Token {}
public class TokenCMP : Token {}
public class TokenHLT : Token {}
public class TokenJMP : Token {}
public class TokenJC : Token {}
public class TokenADD : Token {}
public class TokenLI : Token {}
public class TokenMOV : Token {}
public class TokenSTORE : Token {}
public class TokenLOAD : Token {}
public class TokenIdentifier : Token {}
