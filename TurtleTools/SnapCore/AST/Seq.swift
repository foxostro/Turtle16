//
//  Seq.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

/// A sequence of zero or more nodes
public final class Seq: AbstractSyntaxTreeNode {
    public let children: [AbstractSyntaxTreeNode]
    
    public init(sourceAnchor: SourceAnchor? = nil,
                children: [AbstractSyntaxTreeNode] = [],
                id: ID = ID()) {
        self.children = children
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Seq {
        Seq(sourceAnchor: sourceAnchor,
            children: children,
            id: id)
    }
    
    public func withChildren(_ children: [AbstractSyntaxTreeNode]) -> Seq {
        Seq(sourceAnchor: sourceAnchor,
            children: children,
            id: id)
    }
    
    public func appending(children moreChildren: [AbstractSyntaxTreeNode]) -> Seq {
        withChildren(children + moreChildren)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(children)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let leading = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let childDesc = makeChildDescriptions(depth: depth + 1)
        let result = "\(leading)\(selfDesc)\(childDesc)"
        return result
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        let result: String
        if children.isEmpty {
            result = " (empty)"
        } else {
            result = "\n" + children.map {
                $0.makeIndentedDescription(depth: depth, wantsLeadingWhitespace: true)
            }.joined(separator: "\n")
        }
        return result
    }
}
