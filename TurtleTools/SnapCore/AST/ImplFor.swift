//
//  ImplFor.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/18/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Adds methods to a struct to implement the specified trait
public final class ImplFor: AbstractSyntaxTreeNode {
    public let typeArguments: [GenericTypeArgument]
    public let traitTypeExpr: Expression
    public let structTypeExpr: Expression
    public let children: [FunctionDeclaration]
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                typeArguments: [GenericTypeArgument],
                traitTypeExpr: Expression,
                structTypeExpr: Expression,
                children: [FunctionDeclaration],
                id: ID = ID()) {
        self.typeArguments = typeArguments
        self.traitTypeExpr = traitTypeExpr
        self.structTypeExpr = structTypeExpr
        self.children = children
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public func clone() -> ImplFor {
        ImplFor(sourceAnchor: sourceAnchor,
                typeArguments: typeArguments,
                traitTypeExpr: traitTypeExpr,
                structTypeExpr: structTypeExpr,
                children: children.map{ $0.clone() },
                id: ID()) // The clone has it's own separate identity from the original.
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ImplFor {
        ImplFor(sourceAnchor: sourceAnchor,
                typeArguments: typeArguments,
                traitTypeExpr: traitTypeExpr,
                structTypeExpr: structTypeExpr,
                children: children,
                id: id)
    }
    
    public func eraseTypeArguments() -> ImplFor {
        ImplFor(sourceAnchor: sourceAnchor,
                typeArguments: [],
                traitTypeExpr: traitTypeExpr,
                structTypeExpr: structTypeExpr,
                children: children,
                id: id)
    }
    
    public func withStructTypeExpr(_ structTypeExpr: Expression) -> ImplFor {
        ImplFor(sourceAnchor: sourceAnchor,
                typeArguments: typeArguments,
                traitTypeExpr: traitTypeExpr,
                structTypeExpr: structTypeExpr,
                children: children,
                id: id)
    }
    
    public func withChildren(_ children: [FunctionDeclaration]) -> ImplFor {
        ImplFor(sourceAnchor: sourceAnchor,
                typeArguments: typeArguments,
                traitTypeExpr: traitTypeExpr,
                structTypeExpr: structTypeExpr,
                children: children,
                id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard traitTypeExpr == rhs.traitTypeExpr else { return false }
        guard structTypeExpr == rhs.structTypeExpr else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(typeArguments)
        hasher.combine(traitTypeExpr)
        hasher.combine(structTypeExpr)
        hasher.combine(children)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let leading = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let typeDesc = String(describing: type(of: self))
        let indent = makeIndent(depth: depth + 1)
        let typeArgumentsDesc = makeTypeArgumentsDescription(depth: depth + 1)
        let structTypeExprDesc = structTypeExpr.makeIndentedDescription(depth: depth + 1)
        let childDesc = makeChildrenDescription(depth: depth + 1)
        let result = """
            \(leading)\(typeDesc)
            \(indent)id: \(id)
            \(indent)typeArguments: \(typeArgumentsDesc)
            \(indent)traitTypeExpr: \(traitTypeExpr)
            \(indent)structTypeExpr: \(structTypeExprDesc)\(childDesc)
            """
        return result
    }
    
    private func makeTypeArgumentsDescription(depth: Int) -> String {
        var result: String = ""
        if typeArguments.isEmpty {
            result = "none"
        } else {
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
            result += children[i].makeIndentedDescription(depth: depth, wantsLeadingWhitespace: true)
        }
        return result
    }
}
