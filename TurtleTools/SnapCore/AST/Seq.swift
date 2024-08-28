//
//  Seq.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

extension String {
    /// A tag to mark the "scopePrologue" code sequence, recorded in the symbol table
    public static let scopePrologue = "scopePrologue"
}

public class Seq: AbstractSyntaxTreeNode {
    public let tags: Set<String>
    public let children: [AbstractSyntaxTreeNode]
    
    public init(sourceAnchor: SourceAnchor? = nil,
                tags: Set<String> = Set<String>(),
                children: [AbstractSyntaxTreeNode] = []) {
        self.tags = tags
        self.children = children
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Seq {
        Seq(sourceAnchor: sourceAnchor,
            tags: tags,
            children: children)
    }
    
    public func withChildren(_ children: [AbstractSyntaxTreeNode]) -> Seq {
        Seq(sourceAnchor: sourceAnchor,
            tags: tags,
            children: children)
    }
    
    public func appending(child: AbstractSyntaxTreeNode) -> Seq {
        appending(children: [child])
    }
    
    public func appending(children moreChildren: [AbstractSyntaxTreeNode]) -> Seq {
        withChildren(children + moreChildren)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Seq else { return false }
        guard tags == rhs.tags else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(tags)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let leading = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let selfDesc = String(describing: type(of: self))
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
