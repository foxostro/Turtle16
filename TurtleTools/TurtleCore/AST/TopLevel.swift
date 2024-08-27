//
//  TopLevel.swift
//  TurtleCore
//
//  Created by Andrew Fox on 6/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class TopLevel: AbstractSyntaxTreeNode {
    public let children: [AbstractSyntaxTreeNode]
    
    public init(sourceAnchor: SourceAnchor? = nil, children: [AbstractSyntaxTreeNode]) {
        self.children = children
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TopLevel {
        TopLevel(sourceAnchor: sourceAnchor, children: children)
    }
    
    public func withChildren(_ children: [AbstractSyntaxTreeNode]) -> TopLevel {
        TopLevel(sourceAnchor: sourceAnchor, children: children)
    }
    
    public func inserting(children toInsert: [AbstractSyntaxTreeNode], at index: Int) -> TopLevel {
        var children1 = children
        children1.insert(contentsOf: toInsert, at: index)
        return withChildren(children1)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard super.isEqual(rhs) else {
            return false
        }
        guard let rhs = rhs as? TopLevel else {
            return false
        }
        guard children == rhs.children else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@%@",
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
