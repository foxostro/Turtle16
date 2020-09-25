//
//  Typealias.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class Typealias: AbstractSyntaxTreeNode {
    public let lexpr: Expression.Identifier
    public let rexpr: Expression
    public let visibility: SymbolVisibility
    
    public convenience init(lexpr: Expression.Identifier,
                            rexpr: Expression,
                            visibility: SymbolVisibility = .publicVisibility) {
        self.init(sourceAnchor: nil,
                  lexpr: lexpr,
                  rexpr: rexpr,
                  visibility: visibility)
    }
    
    public init(sourceAnchor: SourceAnchor?,
                lexpr: Expression.Identifier,
                rexpr: Expression,
                visibility: SymbolVisibility = .publicVisibility) {
        self.lexpr = lexpr
        self.rexpr = rexpr
        self.visibility = visibility
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Typealias else { return false }
        guard lexpr == rhs.lexpr else { return false }
        guard rexpr == rhs.rexpr else { return false }
        guard visibility == rhs.visibility else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(lexpr)
        hasher.combine(rexpr)
        hasher.combine(visibility)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@lexpr: %@\n%@rexpr: %@\n%@visibility: %@",
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
