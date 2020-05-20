//
//  TokenNumber.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

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
        guard let rhs = rhs as? TokenNumber else { return false }
        guard lineNumber == rhs.lineNumber else { return false }
        guard lexeme == rhs.lexeme else { return false }
        guard literal == rhs.literal else { return false }
        return super.isEqual(rhs)
    }
}

public func ==(lhs: TokenNumber, rhs: TokenNumber) -> Bool {
    return lhs.isEqual(rhs)
}
