//
//  Block.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class Block: AbstractSyntaxTreeNode {
    public let children: [AbstractSyntaxTreeNode]
    
    public init(children: [AbstractSyntaxTreeNode] = []) {
        self.children = children
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? Block else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: children=[%@]>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      makeChildDescriptions(depth: depth + 1))
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        let result = children.map({"\n" + $0.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: true)}).joined(separator: ",")
        return result
    }
}
