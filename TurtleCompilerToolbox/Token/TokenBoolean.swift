//
//  TokenBoolean.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class TokenBoolean : Token {
    public let literal: Bool
    
    public init(lineNumber: Int, lexeme: String, literal: Bool) {
        self.literal = literal
        super.init(lineNumber: lineNumber, lexeme: lexeme)
    }
    
    public override var description: String {
        return String(format: "<%@: lineNumber=%d, lexeme=\"%@\", literal=%@>", String(describing: type(of: self)), lineNumber, lexeme, String(describing: literal))
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? TokenBoolean else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard literal == rhs.literal else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(literal)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
