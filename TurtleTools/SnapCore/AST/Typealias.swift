//
//  Typealias.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Declare a new type alias, basically rebinding the definition of a type under a new identifier
public final class Typealias: AbstractSyntaxTreeNode {
    public let lexpr: Expression.Identifier
    public let rexpr: Expression
    public let visibility: SymbolVisibility
    
    public init(sourceAnchor: SourceAnchor? = nil,
                lexpr: Expression.Identifier,
                rexpr: Expression,
                visibility: SymbolVisibility = .privateVisibility,
                id: ID = ID()) {
        self.lexpr = lexpr
        self.rexpr = rexpr
        self.visibility = visibility
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Typealias {
        Typealias(sourceAnchor: sourceAnchor,
                  lexpr: lexpr,
                  rexpr: rexpr,
                  visibility: visibility,
                  id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard lexpr == rhs.lexpr else { return false }
        guard rexpr == rhs.rexpr else { return false }
        guard visibility == rhs.visibility else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(lexpr)
        hasher.combine(rexpr)
        hasher.combine(visibility)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        String(format: "%@%@\n%@lexpr: %@\n%@rexpr: %@\n%@visibility: %@",
               wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
               String(describing: type(of: self)),
               makeIndent(depth: depth + 1),
               lexpr.makeIndentedDescription(depth: depth),
               makeIndent(depth: depth + 1),
               rexpr.makeIndentedDescription(depth: depth),
               makeIndent(depth: depth + 1),
               visibility.description)
    }
}
