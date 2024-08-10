//
//  VarDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class VarDeclaration: AbstractSyntaxTreeNode {
    public let identifier: Expression.Identifier
    public let explicitType: Expression?
    public let expression: Expression?
    public let storage: SymbolStorage
    public let isMutable: Bool
    public let visibility: SymbolVisibility
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: Expression.Identifier,
                explicitType: Expression?,
                expression: Expression?,
                storage: SymbolStorage,
                isMutable: Bool,
                visibility: SymbolVisibility = .privateVisibility) {
        self.identifier = identifier.withSourceAnchor(sourceAnchor)
        self.explicitType = explicitType?.withSourceAnchor(sourceAnchor)
        self.expression = expression?.withSourceAnchor(sourceAnchor)
        self.storage = storage
        self.isMutable = isMutable
        self.visibility = visibility
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> VarDeclaration {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return VarDeclaration(sourceAnchor: sourceAnchor,
                              identifier: identifier,
                              explicitType: explicitType,
                              expression: expression,
                              storage: storage,
                              isMutable: isMutable,
                              visibility: visibility)
    }
    
    public func withExpression(_ expression: Expression?) -> VarDeclaration {
        VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: visibility)
    }
    
    public func withExplicitType(_ explicitType: Expression?) -> VarDeclaration {
        VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: visibility)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard super.isEqual(rhs) else {
            return false
        }
        guard let rhs = rhs as? VarDeclaration else {
            return false
        }
        guard identifier == rhs.identifier else {
            return false
        }
        guard explicitType == rhs.explicitType else {
            return false
        }
        guard isMutable == rhs.isMutable else {
            return false
        }
        guard storage == rhs.storage else {
            return false
        }
        guard expression == rhs.expression else {
            return false
        }
        guard visibility == rhs.visibility else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(explicitType)
        hasher.combine(storage)
        hasher.combine(isMutable)
        hasher.combine(expression)
        hasher.combine(visibility)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@identifier: %@\n%@explicitType: %@\n%@storage: %@\n%@isMutable: %@\n%@visibility: %@\n%@expression: %@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      makeIndent(depth: depth + 1),
                      identifier.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      explicitType?.makeIndentedDescription(depth: depth + 1) ?? "nil",
                      makeIndent(depth: depth + 1),
                      String(describing: storage),
                      makeIndent(depth: depth + 1),
                      isMutable ? "true" : "false",
                      makeIndent(depth: depth + 1),
                      visibility.description,
                      makeIndent(depth: depth + 1),
                      expression?.makeIndentedDescription(depth: depth + 1) ?? "nil")
    }
}
