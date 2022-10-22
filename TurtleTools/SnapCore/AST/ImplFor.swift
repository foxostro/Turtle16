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
    public let traitIdentifier: Expression.Identifier
    public let structIdentifier: Expression.Identifier
    public let children: [FunctionDeclaration]
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                typeArguments: [Expression.GenericTypeArgument],
                traitIdentifier: Expression.Identifier,
                structIdentifier: Expression.Identifier,
                children: [FunctionDeclaration]) {
        self.typeArguments = typeArguments.map { $0.withSourceAnchor(sourceAnchor) }
        self.traitIdentifier = traitIdentifier.withSourceAnchor(sourceAnchor)
        self.structIdentifier = structIdentifier.withSourceAnchor(sourceAnchor)
        self.children = children.map { $0.withSourceAnchor(sourceAnchor) }
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ImplFor {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return ImplFor(sourceAnchor: sourceAnchor,
                       typeArguments: typeArguments,
                       traitIdentifier: traitIdentifier,
                       structIdentifier: structIdentifier,
                       children: children)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? ImplFor else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard traitIdentifier == rhs.traitIdentifier else { return false }
        guard structIdentifier == rhs.structIdentifier else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(typeArguments)
        hasher.combine(traitIdentifier)
        hasher.combine(structIdentifier)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@typeArguments: %@\n%@traitIdentifier: %@\n%@structIdentifier: %@%@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      makeIndent(depth: depth+1),
                      makeTypeArgumentsDescription(depth: depth+1),
                      makeIndent(depth: depth + 1),
                      traitIdentifier.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      structIdentifier.makeIndentedDescription(depth: depth + 1),
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
