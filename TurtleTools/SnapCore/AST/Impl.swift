//
//  Impl.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Adds zero or more methods to an existing struct
public final class Impl: AbstractSyntaxTreeNode {
    public let typeArguments: [GenericTypeArgument]
    public let structTypeExpr: Expression
    public let children: [FunctionDeclaration]

    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }

    public init(
        sourceAnchor: SourceAnchor? = nil,
        typeArguments: [GenericTypeArgument],
        structTypeExpr: Expression,
        children: [FunctionDeclaration],
        id: ID = ID()
    ) {
        self.typeArguments = typeArguments
        self.structTypeExpr = structTypeExpr
        self.children = children
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public func clone() -> Impl {
        Impl(
            sourceAnchor: sourceAnchor,
            typeArguments: typeArguments,
            structTypeExpr: structTypeExpr,
            children: children.map { $0.clone() },
            id: ID()
        )  // The clone has it's own separate identity from the original.
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Impl {
        Impl(
            sourceAnchor: sourceAnchor,
            typeArguments: typeArguments,
            structTypeExpr: structTypeExpr,
            children: children,
            id: id
        )
    }

    public func eraseTypeArguments() -> Impl {
        Impl(
            sourceAnchor: sourceAnchor,
            typeArguments: [],
            structTypeExpr: structTypeExpr,
            children: children,
            id: id
        )
    }

    public func withStructTypeExpr(_ structTypeExpr: Expression) -> Impl {
        Impl(
            sourceAnchor: sourceAnchor,
            typeArguments: typeArguments,
            structTypeExpr: structTypeExpr,
            children: children,
            id: id
        )
    }

    public func withChildren(_ children: [FunctionDeclaration]) -> Impl {
        Impl(
            sourceAnchor: sourceAnchor,
            typeArguments: typeArguments,
            structTypeExpr: structTypeExpr,
            children: children,
            id: id
        )
    }

    public func inserting(children toInsert: [FunctionDeclaration], at index: Int) -> Impl {
        var children = self.children
        children.insert(contentsOf: toInsert, at: index)
        return withChildren(children)
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard structTypeExpr == rhs.structTypeExpr else { return false }
        guard children == rhs.children else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(typeArguments)
        hasher.combine(structTypeExpr)
        hasher.combine(children)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let leading = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let typeDesc = String(describing: type(of: self))
        let indent = makeIndent(depth: depth + 1)
        let childDesc = makeChildrenDescription(depth: depth + 1)
        let typeArgumentsDesc = makeTypeArgumentsDescription(depth: depth + 1)
        let structTypeExprDesc = structTypeExpr.makeIndentedDescription(depth: depth + 1)
        let result = """
            \(leading)\(typeDesc)
            \(indent)id: \(id)
            \(indent)typeArguments: \(typeArgumentsDesc)
            \(indent)structTypeExpr: \(structTypeExprDesc)
            \(indent)children: \(childDesc)
            """
        return result
    }

    private func makeTypeArgumentsDescription(depth: Int) -> String {
        var result: String = ""
        if typeArguments.isEmpty {
            result = "none"
        }
        else {
            for i in 0..<typeArguments.count {
                let argument = typeArguments[i]
                result += "\n"
                result += makeIndent(depth: depth + 1)
                result += "\(i) -- "
                result += argument.makeIndentedDescription(depth: depth + 1)
            }
        }
        return result
    }

    private func makeChildrenDescription(depth: Int) -> String {
        var result = ""
        for i in 0..<children.count {
            result += "\n"
            result += children[i].makeIndentedDescription(
                depth: depth,
                wantsLeadingWhitespace: true
            )
        }
        return result
    }
}
