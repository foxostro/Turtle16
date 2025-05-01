//
//  TokenType.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public final class TokenType: Token {
    public let representedType: SymbolType

    public init(sourceAnchor: SourceAnchor, type: SymbolType) {
        self.representedType = type
        super.init(sourceAnchor: sourceAnchor)
    }

    public override var description: String {
        "<\(selfDesc): sourceAnchor=\(sourceAnchorDesc), lexeme=\"\(lexeme)\", type=\(representedType)>"
    }

    public override func isEqual(_ rhs: Token) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard representedType == rhs.representedType else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(representedType)
    }
}
