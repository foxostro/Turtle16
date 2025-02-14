//
//  Token.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class Token: Hashable, CustomStringConvertible {
    public let sourceAnchor: SourceAnchor?
    public var lexeme: String { String(sourceAnchor?.text ?? "") }
    public var sourceAnchorDesc: String { String(describing: sourceAnchor) }
    public var selfDesc: String { String(describing: type(of: self)) }
    
    public init(sourceAnchor: SourceAnchor? = nil) {
        self.sourceAnchor = sourceAnchor
    }
    
    open var description: String {
        "<\(selfDesc): sourceAnchor=\(sourceAnchorDesc), lexeme=\"\(lexeme)\">"
    }
    
    open func hash(into hasher: inout Hasher) {
        hasher.combine(sourceAnchor)
    }
    
    public static func ==(lhs: Token, rhs: Token) -> Bool {
        lhs.isEqual(rhs)
    }
    
    open func isEqual(_ rhs: Token) -> Bool {
        guard type(of: self) == type(of: rhs) else { return false }
        guard sourceAnchor == rhs.sourceAnchor else { return false }
        return true
    }
}

/// A token that represents a literal value of some generic type
public class TokenLiteral<T: Hashable> : Token {
    public let literal: T
    
    public convenience init(_ literal: T) {
        self.init(sourceAnchor: nil, literal: literal)
    }
    
    public init(sourceAnchor: SourceAnchor? = nil, literal: T) {
        self.literal = literal
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override var description: String {
        "<\(selfDesc): sourceAnchor=\(sourceAnchorDesc), lexeme=\"\(lexeme)\", literal=\(literal)>"
    }
    
    public override func isEqual(_ rhs: Token) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard literal == rhs.literal else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(literal)
    }
}
