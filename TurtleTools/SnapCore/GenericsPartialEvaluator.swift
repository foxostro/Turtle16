//
//  GenericsPartialEvaluator.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/8/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

/// Partially evaluate a generic type by applying the specified replacements
///
/// Identifiers in the generic function, struct, or other object are directly
/// replaced by the expressions to which they evaluate. This works because the
/// language forbids any identifier from shadowing an existing symbol or type.
public final class GenericsPartialEvaluator: CompilerPass {
    public typealias ScopeIdentifier = Env.ScopeIdentifier
    public struct ReplacementKey: Hashable {
        let identifier: String
        let scope: ScopeIdentifier
    }

    public typealias ReplacementMap = [ReplacementKey: Expression]

    private let map: ReplacementMap

    /// Partially evaluate the given generic function, struct, or whatever
    /// - Parameter replacements: The replacements to apply while partially
    ///   evaluating the function. The replacements must be a sequence of pairs
    ///   where each pair is a (ReplacementKey, PrimitiveType). The first
    ///   element identifies the specific symbol to replace. The second element
    ///   is the expression which replaces it.
    /// - Returns: The partially evaluated function, struct, or other object,
    ///   with replacements applied
    public static func eval<U>(
        _ ast0: U,
        replacements: some Sequence<(ReplacementKey, Expression)>
    ) throws -> U
        where U: AbstractSyntaxTreeNode {
        let replacementMap = Dictionary(uniqueKeysWithValues: replacements)
        let ast1 = try GenericsPartialEvaluator(symbols: nil, map: replacementMap)
            .run(ast0) as! U
        return ast1
    }

    public init(symbols: Env?, map: ReplacementMap) {
        self.map = map
        super.init(symbols)
    }

    public override func visit(identifier node0: Identifier) -> Expression? {
        let scope = symbols?.lookupIdOfEnclosingScope(identifier: node0.identifier) ?? NSNotFound
        let key = ReplacementKey(identifier: node0.identifier, scope: scope)
        let replacement = map[key] ?? node0
        return replacement
    }

    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try VarDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: node0.identifier, // Do not rewrite the identifier of the new symbol
            explicitType: node0.explicitType.flatMap { try visit(expr: $0) },
            expression: node0.expression.flatMap { try visit(expr: $0) },
            storage: node0.storage,
            isMutable: node0.isMutable,
            visibility: node0.visibility,
            id: node0.id
        )
        return node1
    }

    public override func visit(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try StructDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: node0.identifier, // Do not rewrite the identifier of the new type
            typeArguments: node0.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! GenericTypeArgument?
            },
            members: node0.members.map {
                try StructDeclaration.Member(
                    name: $0.name,
                    type: visit(expr: $0.memberType)!
                )
            },
            visibility: node0.visibility,
            isConst: node0.isConst,
            associatedTraitType: node0.associatedTraitType,
            id: node0.id
        )
        return node1
    }
}
