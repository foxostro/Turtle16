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

public class TokenEOF : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenEOF {
            return self == rhs
        }
        return false
    }
}

public class TokenNewline : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenNewline {
            return self == rhs
        }
        return false
    }
}

public class TokenComma : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenComma {
            return self == rhs
        }
        return false
    }
}

public class TokenColon : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenColon {
            return self == rhs
        }
        return false
    }
}

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

public class TokenRegister : Token {
    public let literal: RegisterName
    
    public init(lineNumber: Int, lexeme: String, literal: RegisterName) {
        self.literal = literal
        super.init(lineNumber: lineNumber, lexeme: lexeme)
    }
    
    public override var description: String {
        return String(format: "<%@: lineNumber=%d, lexeme=\"%@\", literal=%@>", String(describing: type(of: self)), lineNumber, lexeme, String(describing: literal))
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenRegister {
            return self == rhs
        }
        return false
    }
}

public class TokenNOP : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenNOP {
            return self == rhs
        }
        return false
    }
}

public class TokenCMP : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenCMP {
            return self == rhs
        }
        return false
    }
}

public class TokenHLT : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenHLT {
            return self == rhs
        }
        return false
    }
}

public class TokenJMP : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenJMP {
            return self == rhs
        }
        return false
    }
}

public class TokenJC : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenJC {
            return self == rhs
        }
        return false
    }
}

public class TokenADD : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenADD {
            return self == rhs
        }
        return false
    }
}

public class TokenLI : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenLI {
            return self == rhs
        }
        return false
    }
}

public class TokenMOV : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenMOV {
            return self == rhs
        }
        return false
    }
}

public class TokenSTORE : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenSTORE {
            return self == rhs
        }
        return false
    }
}

public class TokenLOAD : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenLOAD {
            return self == rhs
        }
        return false
    }
}

public class TokenIdentifier : Token {
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? TokenIdentifier {
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

public func ==(lhs: TokenRegister, rhs: TokenRegister) -> Bool {
    if type(of: lhs) != type(of: rhs) {
        return false
    }
    
    if lhs.lineNumber != rhs.lineNumber {
        return false
    }
    
    if lhs.lexeme != rhs.lexeme {
        return false
    }
    
    return lhs.literal == rhs.literal
}

public func ==(lhs: TokenNumber, rhs: TokenNumber) -> Bool {
    if type(of: lhs) != type(of: rhs) {
        return false
    }
    
    if lhs.lineNumber != rhs.lineNumber {
        return false
    }
    
    if lhs.lexeme != rhs.lexeme {
        return false
    }
    
    return lhs.literal == rhs.literal
}
