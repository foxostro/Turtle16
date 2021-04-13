//
//  Token.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Foundation

public class Token : NSObject {
    public let sourceAnchor: SourceAnchor?
    public var lexeme: String {
        String(sourceAnchor?.text ?? "")
    }
    
    public init(sourceAnchor: SourceAnchor? = nil) {
        self.sourceAnchor = sourceAnchor
        super.init()
    }
    
    open override var description: String {
        let typeString = String(describing: type(of: self))
        return "<\(typeString): sourceAnchor=\(String(describing: sourceAnchor)), lexeme=\"\(lexeme)\">"
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
        guard sourceAnchor == rhs.sourceAnchor else { return false }
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(sourceAnchor)
        return hasher.finalize()
    }
}

public class TokenNumber : Token {
    public let literal: Int
    
    public convenience init(literal: Int) {
        self.init(sourceAnchor: nil, literal: literal)
    }
    
    public init(sourceAnchor: SourceAnchor?, literal: Int) {
        self.literal = literal
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override var description: String {
        return String(format: "<%@: sourceAnchor=%@, lexeme=\"%@\", literal=%@>",
                      String(describing: type(of: self)),
                      String(describing: sourceAnchor),
                      lexeme,
                      String(describing: literal))
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? TokenNumber else { return false }
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

public class TokenNewline : Token {
    public override var description: String {
        return String(format: "<%@: sourceAnchor=%@>",
                      String(describing: type(of: self)),
                      String(describing: sourceAnchor))
    }
}

public class TokenEOF : Token {
    public override var description: String {
        return String(format: "<%@: sourceAnchor=%@>",
                      String(describing: type(of: self)),
                      String(describing: sourceAnchor))
    }
}

public class TokenColon : Token {}
public class TokenSemicolon : Token {}
public class TokenForwardSlash : Token {}
public class TokenComma : Token {}
public class TokenIdentifier : Token {}
