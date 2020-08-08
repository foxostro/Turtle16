//
//  TokenType.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class TokenType : Token {
    public let representedType: SymbolType
    
    public init(sourceAnchor: SourceAnchor, type: SymbolType) {
        self.representedType = type
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override var description: String {
        return String(format: "<%@: sourceAnchor=%@, lexeme=\"%@\", type=%@>",
                      String(describing: type(of: self)),
                      String(describing: sourceAnchor),
                      lexeme,
                      representedType.description)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? TokenType else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard representedType == rhs.representedType else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(representedType)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
