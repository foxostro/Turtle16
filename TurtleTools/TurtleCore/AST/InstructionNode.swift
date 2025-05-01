//
//  InstructionNode.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Foundation

public final class InstructionNode: AbstractSyntaxTreeNode {
    public let instruction: String
    public let parameters: [Parameter]

    public convenience init(
        sourceAnchor: SourceAnchor? = nil,
        instruction: String,
        parameter: Parameter
    ) {
        self.init(
            sourceAnchor: sourceAnchor,
            instruction: instruction,
            parameters: [parameter]
        )
    }

    public init(
        sourceAnchor: SourceAnchor? = nil,
        instruction: String,
        parameters: [Parameter] = [],
        id: ID = ID()
    ) {
        self.instruction = instruction
        self.parameters = parameters
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> InstructionNode {
        InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: instruction,
            parameters: parameters,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard instruction == rhs.instruction else { return false }
        guard parameters == rhs.parameters else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(instruction)
        hasher.combine(parameters)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let param =
            parameters
            .map {
                $0.makeIndentedDescription(
                    depth: depth + 1,
                    wantsLeadingWhitespace: false
                )
            }
            .joined(separator: ", ")
        return "\(indent)\(instruction) \(param)"
    }
}
