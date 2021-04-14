//
//  TestDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/9/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class TestDeclaration: AbstractSyntaxTreeNode {
    public let name: String
    public let body: Block
    
    public convenience init(name: String, body: Block) {
        self.init(sourceAnchor: nil, name: name, body: body)
    }
    
    public init(sourceAnchor: SourceAnchor?, name: String, body: Block) {
        self.name = name
        self.body = body
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? TestDeclaration else { return false }
        guard name == rhs.name else { return false }
        guard body == rhs.body else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(body)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@name: %@\n%@body: %@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      makeIndent(depth: depth + 1),
                      name,
                      makeIndent(depth: depth + 1),
                      body.makeIndentedDescription(depth: depth + 1))
    }
}
