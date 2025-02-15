//
//  TopLevel.swift
//  TurtleCore
//
//  Created by Andrew Fox on 6/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public final class TopLevel: AbstractSyntaxTreeNode {
    public let children: [AbstractSyntaxTreeNode]
    
    public init(sourceAnchor: SourceAnchor? = nil,
                children: [AbstractSyntaxTreeNode],
                id: ID = ID()) {
        self.children = children
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TopLevel {
        TopLevel(sourceAnchor: sourceAnchor,
                 children: children,
                 id: id)
    }
    
    public func withChildren(_ children: [AbstractSyntaxTreeNode]) -> TopLevel {
        TopLevel(sourceAnchor: sourceAnchor,
                 children: children,
                 id: id)
    }
    
    public func inserting(children toInsert: [AbstractSyntaxTreeNode], at index: Int) -> TopLevel {
        var children1 = children
        children1.insert(contentsOf: toInsert, at: index)
        return withChildren(children1)
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
        String(format: "%@%@%@",
               wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
               String(describing: type(of: self)),
               makeChildDescriptions(depth: depth))
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        var result = ""
        for child in children {
            result += "\n"
            result += child.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: true)
        }
        return result
    }
}
