//
//  AssemblerListingMaker.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 7/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public struct AssemblerListingMaker {
    public init() {}

    public func makeListing(_ node: AbstractSyntaxTreeNode) -> String {
        switch node {
        case let node as TopLevel:
            makeListing(topLevel: node)

        case let node as InstructionNode:
            makeListing(instruction: node)

        case let node as LabelDeclaration:
            makeListing(label: node)

        case let node as CommentNode:
            makeListing(comment: node)

        case let node as Subroutine:
            makeListing(subroutine: node)

        default:
            fatalError("unimplemented node: \(node)")
        }
    }

    public func makeListing(topLevel node: TopLevel) -> String {
        node.children.map { makeListing($0) }.joined(separator: "\n")
    }

    public func makeListing(instruction node: InstructionNode) -> String {
        if node.parameters.count > 0 {
            node.instruction + " " + makeListing(parameterList: node.parameters)
        }
        else {
            node.instruction
        }
    }

    public func makeListing(parameterList: [Parameter]) -> String {
        parameterList.map { makeListing(parameter: $0) }.joined(separator: ", ")
    }

    public func makeListing(parameter node: Parameter) -> String {
        switch node {
        case let node as ParameterIdentifier:
            node.value

        case let node as ParameterNumber: "\(node.value)"

        default:
            fatalError("unimplemented node: \(node)")
        }
    }

    public func makeListing(label node: LabelDeclaration) -> String {
        "\(node.identifier):"
    }

    public func makeListing(comment node: CommentNode) -> String {
        node.string.split(separator: "\n").map { "# \($0)" }.joined(separator: "\n")
    }

    public func makeListing(subroutine node: Subroutine) -> String {
        let label = "\(node.identifier):"
        let body = node.children.map { makeListing($0) }.joined(separator: "\n")
        return body.isEmpty ? label : "\(label)\n\(body)"
    }
}
