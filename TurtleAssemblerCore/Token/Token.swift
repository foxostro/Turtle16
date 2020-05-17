//
//  Token.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class Token : NSObject {
    public let lineNumber: Int
    public let lexeme: String
    
    public init(lineNumber: Int, lexeme: String) {
        self.lineNumber = lineNumber
        self.lexeme = lexeme
        super.init()
    }
    
    public override var description: String {
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
    
    return true
}
