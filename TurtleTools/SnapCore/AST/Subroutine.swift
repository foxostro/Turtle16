//
//  Subroutine.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/24/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Subroutine: AbstractSyntaxTreeNode {
    public let identifier: String
    public let children: [AbstractSyntaxTreeNode]
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: String,
                children: [AbstractSyntaxTreeNode] = []) {
        self.identifier = identifier
        self.children = children.map { $0.withSourceAnchor(sourceAnchor) }
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Subroutine {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return Subroutine(sourceAnchor: sourceAnchor, identifier: identifier, children: children)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Subroutine else { return false }
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
        return String(format: "%@%@(%@):%@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier,
                      makeChildDescriptions(depth: depth + 1))
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        let result: String
        if children.isEmpty {
            result = " empty"
        } else {
            result = "\n" + children.map {
                $0.makeIndentedDescription(depth: depth, wantsLeadingWhitespace: true)
            }.joined(separator: "\n")
        }
        return result
    }
}
