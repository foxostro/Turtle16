//
//  ImplFor.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/18/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class ImplFor: AbstractSyntaxTreeNode {
    public let typeArguments: [Expression.GenericTypeArgument]
    public let traitTypeExpr: Expression
    public let structTypeExpr: Expression
    public let children: [FunctionDeclaration]
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                typeArguments: [Expression.GenericTypeArgument],
                traitTypeExpr: Expression,
                structTypeExpr: Expression,
                children: [FunctionDeclaration]) {
        self.typeArguments = typeArguments.map { $0.withSourceAnchor(sourceAnchor) }
        self.traitTypeExpr = traitTypeExpr.withSourceAnchor(sourceAnchor)
        self.structTypeExpr = structTypeExpr.withSourceAnchor(sourceAnchor)
        self.children = children.map { $0.withSourceAnchor(sourceAnchor) }
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ImplFor {
        ImplFor(sourceAnchor: sourceAnchor,
                typeArguments: typeArguments,
                traitTypeExpr: traitTypeExpr,
                structTypeExpr: structTypeExpr,
                children: children)
    }
    
    public func eraseTypeArguments() -> ImplFor {
        return ImplFor(sourceAnchor: sourceAnchor,
                       typeArguments: [],
                       traitTypeExpr: traitTypeExpr,
                       structTypeExpr: structTypeExpr,
                       children: children)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? ImplFor else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard traitTypeExpr == rhs.traitTypeExpr else { return false }
        guard structTypeExpr == rhs.structTypeExpr else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(typeArguments)
        hasher.combine(traitTypeExpr)
        hasher.combine(structTypeExpr)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@typeArguments: %@\n%@traitTypeExpr: %@\n%@structTypeExpr: %@%@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      makeIndent(depth: depth+1),
                      makeTypeArgumentsDescription(depth: depth+1),
                      makeIndent(depth: depth + 1),
                      traitTypeExpr.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      structTypeExpr.makeIndentedDescription(depth: depth + 1),
                      makeChildrenDescription(depth: depth + 1))
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
