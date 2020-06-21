//
//  TokenType.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class TokenType : Token {
    public let representedType: SymbolType
    
    public init(lineNumber: Int, lexeme: String, type: SymbolType) {
        self.representedType = type
        super.init(lineNumber: lineNumber, lexeme: lexeme)
    }
    
    public override var description: String {
        return String(format: "<%@: lineNumber=%d, lexeme=\"%@\", type=%@>",
                      String(describing: type(of: self)),
                      lineNumber, lexeme,
                      String(describing: representedType))
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
