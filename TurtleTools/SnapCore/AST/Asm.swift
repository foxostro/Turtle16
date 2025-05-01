//
//  Asm.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/10/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import TurtleCore

/// A node carrying a block of inline assembly
public final class Asm: AbstractSyntaxTreeNode {
    public let assemblyCode: String

    public init(sourceAnchor: SourceAnchor? = nil, assemblyCode: String, id: ID = ID()) {
        self.assemblyCode = assemblyCode
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Asm {
        Asm(
            sourceAnchor: sourceAnchor,
            assemblyCode: assemblyCode,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard assemblyCode == rhs.assemblyCode else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(assemblyCode)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indentedAssemblyCode: String =
            if assemblyCode == "" {
                " (empty)"
            } else {
                "\n"
                    + assemblyCode
                    .split(separator: "\n")
                    .map { makeIndent(depth: depth + 1) + $0 }
                    .joined()
            }
        let result = "\(indent0)\(selfDesc):\(indentedAssemblyCode)"
        return result
    }
}
