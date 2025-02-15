//
//  Goto.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Node represents a class GOTO statement. It's an unconditional branch.
public final class Goto: AbstractSyntaxTreeNode {
    public let target: String
    
    public init(sourceAnchor: SourceAnchor? = nil,
                target: String,
                id: ID = ID()) {
        self.target = target
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Goto {
        Goto(sourceAnchor: sourceAnchor,
             target: target,
             id: id)
    }
    
    public func withTarget(_ target: String) -> Goto {
        Goto(sourceAnchor: sourceAnchor,
             target: target,
             id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard target == rhs.target else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(target)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let this = String(describing: type(of: self))
        return "\(indent)\(this) \(target)"
    }
}
