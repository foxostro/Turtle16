//
//  Subroutine.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/24/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

/// A subroutine is a low-level procedure abstraction, lower than the function
/// abstraction. A function is lowered to a subroutine.
public final class Subroutine: AbstractSyntaxTreeNode {
    public let identifier: String
    public let children: [AbstractSyntaxTreeNode]
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: String,
                children: [AbstractSyntaxTreeNode] = [],
                id: ID = ID()) {
        self.identifier = identifier
        self.children = children
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Subroutine {
        Subroutine(sourceAnchor: sourceAnchor,
                   identifier: identifier,
                   children: children,
                   id: id)
    }
    
    public func withChildren(_ children: [AbstractSyntaxTreeNode]) -> Subroutine {
        Subroutine(sourceAnchor: sourceAnchor,
                   identifier: identifier,
                   children: children,
                   id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard identifier == rhs.identifier else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(identifier)
        hasher.combine(children)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        return "\(indent)\(selfDesc)(\(identifier)):\(makeChildDescriptions(depth: depth + 1))"
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        if children.isEmpty {
            " empty"
        }
        else {
            "\n" + children
                .map {
                    $0.makeIndentedDescription(depth: depth, wantsLeadingWhitespace: true)
                }
                .joined(separator: "\n")
        }
    }
}
