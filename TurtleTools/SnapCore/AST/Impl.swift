//
//  Impl.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Impl: AbstractSyntaxTreeNode {
    public let typeArguments: [Expression.GenericTypeArgument]
    public let structTypeExpr: Expression
    public let children: [FunctionDeclaration]
    public let id: ID
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                typeArguments: [Expression.GenericTypeArgument],
                structTypeExpr: Expression,
                children: [FunctionDeclaration],
                id: ID = ID()) {
        self.typeArguments = typeArguments
        self.structTypeExpr = structTypeExpr
        self.children = children
        self.id = id
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public func clone() -> Impl {
        Impl(sourceAnchor: sourceAnchor,
             typeArguments: typeArguments,
             structTypeExpr: structTypeExpr,
             children: children.map{ $0.clone() },
             id: ID()) // The clone has it's own separate identity from the original.
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Impl {
        Impl(sourceAnchor: sourceAnchor,
             typeArguments: typeArguments,
             structTypeExpr: structTypeExpr,
             children: children,
             id: id)
    }
    
    public func eraseTypeArguments() -> Impl {
        Impl(sourceAnchor: sourceAnchor,
             typeArguments: [],
             structTypeExpr: structTypeExpr,
             children: children,
             id: id)
    }
    
    public func inserting(children toInsert: [FunctionDeclaration], at index: Int) -> Impl {
        var children1 = children
        children1.insert(contentsOf: toInsert, at: index)
        
        return Impl(sourceAnchor: sourceAnchor,
                    typeArguments: typeArguments,
                    structTypeExpr: structTypeExpr,
                    children: children1,
                    id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Impl else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard structTypeExpr == rhs.structTypeExpr else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(typeArguments)
        hasher.combine(structTypeExpr)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
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
