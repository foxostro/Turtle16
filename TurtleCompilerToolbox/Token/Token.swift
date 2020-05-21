//
//  Token.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class Token : NSObject {
    public let lineNumber: Int
    public let lexeme: String
    
    public init(lineNumber: Int, lexeme: String) {
        self.lineNumber = lineNumber
        self.lexeme = lexeme
        super.init()
    }
    
    open override var description: String {
        return String(format: "<%@: lineNumber=%d, lexeme=\"%@\">", String(describing: type(of: self)), lineNumber, lexeme)
    }
    
    public static func ==(lhs: Token, rhs: Token) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    open override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        return isBaseClassPartEqual(rhs)
    }
    
    public final func isBaseClassPartEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? Token else { return false }
        guard lineNumber == rhs.lineNumber else { return false }
        guard lexeme == rhs.lexeme else { return false }
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(lineNumber)
        hasher.combine(lexeme)
        return hasher.finalize()
    }
}
