//
//  Impl.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class Impl: AbstractSyntaxTreeNode {
    public let identifier: Expression.Identifier
    public let children: [FunctionDeclaration]
    
    public convenience init(identifier: Expression.Identifier,
                            children: [FunctionDeclaration]) {
        self.init(sourceAnchor: nil,
                  identifier: identifier,
                  children: children)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         identifier: Expression.Identifier,
                         children: [FunctionDeclaration]) {
        self.identifier = identifier
        self.children = children
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Impl else { return false }
        guard identifier == rhs.identifier else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: identifier=%@, children=\n%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier.makeIndentedDescription(depth: depth + 1),
                      children.map({$0.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: true)}).joined(separator: "\n"))
    }
}
