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
