//
//  CompilerPassImplFor.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Snap compiler pass to erase ImplFor declarations and traits
/// ImplFor declarations are erased and rewritten in terms of lower-level
/// concepts. The ImplFor AST node is replaced with an appropriate Impl node
/// and an appropriate vtable declaration. Traits are erased and rewritten into
/// direct manipulation of trait-objects.
public final class CompilerPassImplFor: CompilerPassWithDeclScan {
    private var typeChecker: RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
    }

    /// Each ImplFor node is transformed to an Impl node
    public override func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        let traitType = try typeChecker.check(expression: node.traitTypeExpr).unwrapTraitType()
        let structType = try typeChecker.check(expression: node.structTypeExpr).unwrapStructType()
        let vtableType = try typeChecker.check(identifier: Identifier(traitType.nameOfVtableType))
            .unwrapStructType()

        let nameOfVtableInstance = nameOfVtableInstance(
            traitName: traitType.name,
            structName: structType.name
        )
        var arguments: [StructInitializer.Argument] = []
        let sortedVtableSymbols = vtableType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (methodName, methodSymbol) in sortedVtableSymbols {
            let arg = StructInitializer.Argument(
                name: methodName,
                expr: Bitcast(
                    expr: Unary(
                        op: .ampersand,
                        expression: Get(
                            expr: Identifier(structType.name),
                            member: Identifier(methodName)
                        )
                    ),
                    targetType: PrimitiveType(methodSymbol.type)
                )
            )
            arguments.append(arg)
        }

        let initializer = StructInitializer(
            identifier: Identifier(traitType.nameOfVtableType),
            arguments: arguments
        )

        let visibility =
            if let identifier = node.traitTypeExpr as? Identifier {
                try symbols!.resolveTypeRecord(
                    sourceAnchor: node.sourceAnchor,
                    identifier: identifier.identifier
                ).visibility
            }
            else {
                SymbolVisibility.privateVisibility
            }

        let vtableInstanceDecl = VarDeclaration(
            identifier: Identifier(nameOfVtableInstance),
            explicitType: Identifier(vtableType.name),
            expression: initializer,
            storage: .staticStorage(offset: nil),
            isMutable: false,
            visibility: visibility
        )

        let result = Seq(
            sourceAnchor: node.sourceAnchor,
            children: [
                Impl(
                    sourceAnchor: node.sourceAnchor,
                    typeArguments: try node.typeArguments.compactMap {
                        try visit(genericTypeArgument: $0) as! GenericTypeArgument?
                    },
                    structTypeExpr: try visit(expr: node.structTypeExpr)!,
                    children: try node.children.compactMap {
                        try visit($0) as? FunctionDeclaration
                    },
                    id: node.id
                ),
                vtableInstanceDecl,
            ]
        )

        return result
    }

    /// All trait declarations are erased
    public override func visit(trait: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        nil
    }

    /// All references to trait types are rewritten to direct manipulation of trait objects
    public override func visit(identifier node0: Identifier) throws -> Expression? {
        guard let typ = symbols?.maybeResolveType(identifier: node0.identifier),
            let traitType = typ.maybeUnwrapTraitType()
        else {
            return node0
        }
        let node1 = node0.withIdentifier(traitType.nameOfTraitObjectType)
        return node1
    }

    /// VarDeclaration is rewritten to instantiate a trait-object
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(varDecl: node0) as! VarDeclaration
        guard let expr1 = node1.expression,
            let explicitType = node1.explicitType,
            let traitType = try maybeLookupCorrespondingTraitType(expr: explicitType),
            let expr2 = try convertToTraitObject(traitType, expr: expr1)
        else {
            return node1
        }
        let node2 =
            node1
            .withExplicitType(
                Identifier(
                    sourceAnchor: expr1.sourceAnchor,
                    identifier: traitType.nameOfTraitObjectType
                )
            )
            .withExpression(expr2)
        return node2
    }

    /// InitialAssignment is rewritten to populate a trait-object
    public override func visit(initialAssignment node0: InitialAssignment) throws -> Expression? {
        guard let traitType = try maybeLookupCorrespondingTraitType(expr: node0.lexpr),
            let rexpr1 = try convertToTraitObject(traitType, expr: node0.rexpr)
        else {
            return try super.visit(initialAssignment: node0)
        }
        let node1 = node0.withRexpr(rexpr1)
        return node1
    }

    /// Assignment is rewritten to populate a trait-object
    public override func visit(assignment node0: Assignment) throws -> Expression? {
        guard let traitType = try maybeLookupCorrespondingTraitType(expr: node0.lexpr),
            let rexpr1 = try convertToTraitObject(traitType, expr: node0.rexpr)
        else {
            return try super.visit(assignment: node0)
        }
        let node1 = node0.withRexpr(rexpr1)
        return node1
    }

    /// If the expression refers resolves to the type of a trait-object then
    /// return the name of the associated trait, else return nil.
    private func maybeLookupCorrespondingTraitType(expr: Expression) throws -> TraitTypeInfo? {
        guard let traitObjectType = try typeChecker.check(expression: expr).maybeUnwrapStructType(),
            let traitName = traitObjectType.associatedTraitType,
            let traitType = symbols?
                .maybeResolveType(identifier: traitName)?
                .maybeUnwrapTraitType()
        else {
            return nil
        }
        return traitType
    }

    /// Return an expression which converts the given expression and evaluates
    /// to an appropriate trait-object
    private func convertToTraitObject(
        _ traitType: TraitTypeInfo,
        expr expr0: Expression
    ) throws -> StructInitializer? {

        let exprTyp0 = try typeChecker.check(expression: expr0)
        return switch exprTyp0 {
        case .constStructType(let typ), .structType(let typ):
            makeTraitObject(
                traitType,
                typ,
                expr: Unary(
                    sourceAnchor: expr0.sourceAnchor,
                    op: .ampersand,
                    expression: expr0
                )
            )

        case .constPointer(.constStructType(let typ)),
            .constPointer(.structType(let typ)),
            .pointer(.constStructType(let typ)),
            .pointer(.structType(let typ)):
            makeTraitObject(traitType, typ, expr: expr0)

        default:
            nil
        }
    }

    /// Returns an expression which populates a trait-object
    private func makeTraitObject(
        _ traitType: TraitTypeInfo,
        _ structType: StructTypeInfo,
        expr: Expression
    ) -> StructInitializer {

        StructInitializer(
            sourceAnchor: expr.sourceAnchor,
            expr: Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: traitType.nameOfTraitObjectType
            ),
            arguments: [
                StructInitializer.Argument(
                    name: "object",
                    expr: Bitcast(
                        sourceAnchor: expr.sourceAnchor,
                        expr: expr,
                        targetType: PointerType(PrimitiveType(.void))
                    )
                ),
                StructInitializer.Argument(
                    name: "vtable",
                    expr: Identifier(
                        sourceAnchor: expr.sourceAnchor,
                        identifier: nameOfVtableInstance(
                            traitName: traitType.name,
                            structName: structType.name
                        )
                    )
                ),
            ]
        )
    }
}

extension AbstractSyntaxTreeNode {
    /// Erase impl-for declarations, rewriting in terms of lower-level concepts
    public func implForPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassImplFor().run(self)
    }
}
