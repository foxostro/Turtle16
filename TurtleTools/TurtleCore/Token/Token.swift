//
//  Token.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class Token : NSObject {
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
        lhs.isEqual(rhs)
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
