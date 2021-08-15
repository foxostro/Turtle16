//
//  Goto.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Goto: AbstractSyntaxTreeNode {
    public let target: String
    
    public required init(sourceAnchor: SourceAnchor? = nil, target: String) {
        self.target = target
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Goto else { return false }
        guard target == rhs.target else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(target)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let this = String(describing: type(of: self))
        return "\(indent)\(this) \(target)"
    }
}
