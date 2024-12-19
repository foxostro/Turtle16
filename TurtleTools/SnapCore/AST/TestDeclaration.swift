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
    
    public init(sourceAnchor: SourceAnchor? = nil,
                name: String,
                body: Block,
                id: ID = ID()) {
        self.name = name
        self.body = body.withSourceAnchor(sourceAnchor)
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TestDeclaration {
        TestDeclaration(sourceAnchor: sourceAnchor,
                        name: name,
                        body: body,
                        id: id)
    }
    
    public func withBody(_ body: Block) -> TestDeclaration {
        TestDeclaration(sourceAnchor: sourceAnchor,
                        name: name,
                        body: body,
                        id: id)
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
        String(format: "%@%@\n%@name: %@\n%@body: %@",
               wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
               String(describing: type(of: self)),
               makeIndent(depth: depth + 1),
               name,
               makeIndent(depth: depth + 1),
               body.makeIndentedDescription(depth: depth + 1))
    }
}
