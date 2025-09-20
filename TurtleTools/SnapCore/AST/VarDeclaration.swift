//
//  VarDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Declare a variable in the current scope
public final class VarDeclaration: AbstractSyntaxTreeNode {
    public let identifier: Identifier
    public let explicitType: Expression?
    public let expression: Expression?
    public let storage: SymbolStorage
    public let isMutable: Bool
    public let visibility: SymbolVisibility

    public init(
        sourceAnchor: SourceAnchor? = nil,
        identifier: Identifier,
        explicitType: Expression?,
        expression: Expression?,
        storage: SymbolStorage,
        isMutable: Bool,
        visibility: SymbolVisibility = .privateVisibility,
        id: ID = ID()
    ) {
        self.identifier = identifier
        self.explicitType = explicitType
        self.expression = expression
        self.storage = storage
        self.isMutable = isMutable
        self.visibility = visibility
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> VarDeclaration {
        VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: visibility,
            id: id
        )
    }

    public func withExpression(_ expression: Expression?) -> VarDeclaration {
        VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: visibility,
            id: id
        )
    }

    public func withExplicitType(_ explicitType: Expression?) -> VarDeclaration {
        VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: visibility,
            id: id
        )
    }
    
    public func withStorage(_ storage: SymbolStorage) -> VarDeclaration {
        VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: visibility,
            id: id
        )
    }
    
    public func withMutable(_ isMutable: Bool) -> VarDeclaration {
        VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: visibility,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard identifier == rhs.identifier else { return false }
        guard explicitType == rhs.explicitType else { return false }
        guard isMutable == rhs.isMutable else { return false }
        guard storage == rhs.storage else { return false }
        guard expression == rhs.expression else { return false }
        guard visibility == rhs.visibility else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(identifier)
        hasher.combine(explicitType)
        hasher.combine(storage)
        hasher.combine(isMutable)
        hasher.combine(expression)
        hasher.combine(visibility)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        return """
            \(indent0)\(selfDesc)
            \(indent1)identifier: \(identifier.makeIndentedDescription(depth: depth + 1))
            \(indent1)explicitType: \(explicitType?.makeIndentedDescription(depth: depth + 1) ?? "nil")
            \(indent1)storage: \(storage)
            \(indent1)isMutable: \(isMutable ? "true" : "false")
            \(indent1)visibility: \(visibility)
            \(indent1)expression: \(expression?.makeIndentedDescription(depth: depth + 1) ?? "nil")
            """
    }
}
