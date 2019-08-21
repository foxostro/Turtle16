//
//  AssemblerToken.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerToken : NSObject {
    public enum TokenType {
        case newline
        case comma
        case nop
        case cmp
        case hlt
        case identifier
    }
    
    public let type: TokenType
    public let lineNumber: Int
    public let lexeme: String
    
    public required init(type: TokenType,
                         lineNumber: Int,
                         lexeme: String) {
        self.type = type
        self.lineNumber = lineNumber
        self.lexeme = lexeme
        super.init()
    }
    
    public override var description: String {
        return String(format: "<AssemblerToken: type=%@, lineNumber=%d, lexeme=\"%@\">", String(describing: type), lineNumber, lexeme)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? AssemblerToken {
            return self == rhs
        } else {
            return false
        }
    }
}

public func ==(lhs: AssemblerToken, rhs: AssemblerToken) -> Bool {
    return lhs.type == rhs.type
        && lhs.lineNumber == rhs.lineNumber
        && lhs.lexeme == rhs.lexeme
}
