//
//  TestDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/9/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Declare a unit test which is only run when the program is built for testing
public final class TestDeclaration: AbstractSyntaxTreeNode {
    public let name: String
    public let body: Block

    public init(
        sourceAnchor: SourceAnchor? = nil,
        name: String,
        body: Block,
        id: ID = ID()
    ) {
        self.name = name
        self.body = body.withSourceAnchor(sourceAnchor)  // TODO: I don't think I should remap the source anchor here. Remove this.
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TestDeclaration {
        TestDeclaration(
            sourceAnchor: sourceAnchor,
            name: name,
            body: body,
            id: id
        )
    }

    public func withBody(_ body: Block) -> TestDeclaration {
        TestDeclaration(
            sourceAnchor: sourceAnchor,
            name: name,
            body: body,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard name == rhs.name else { return false }
        guard body == rhs.body else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(name)
        hasher.combine(body)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        return """
            \(indent0)\(selfDesc)
            \(indent1)name: \(name)
            \(indent1)body: \(body.makeIndentedDescription(depth: depth + 1))
            """
    }
}
