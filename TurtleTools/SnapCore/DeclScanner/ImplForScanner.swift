//
//  ImplForScanner.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

/// Scans an ImplFor declaration and binds the function symbols in the environment
public struct ImplForScanner {
    private let staticStorageFrame: Frame
    private let memoryLayoutStrategy: MemoryLayoutStrategy
    private let symbols: Env
    private let typeChecker: RvalueExpressionTypeChecker
    private var implScanner: ImplScanner {
        ImplScanner(
            memoryLayoutStrategy: memoryLayoutStrategy,
            symbols: symbols
        )
    }

    public init(
        staticStorageFrame: Frame,
        memoryLayoutStrategy: MemoryLayoutStrategy,
        symbols: Env = Env()
    ) {
        self.staticStorageFrame = staticStorageFrame
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.symbols = symbols
        typeChecker = RvalueExpressionTypeChecker(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
    }

    public func scan(implFor node: ImplFor) throws {
        // It may be the case that we can't resolve the generic type application
        // because the arugment is an unbound generic type variables. If so then
        // we need to ensure the expression resolves to a generic struct type
        // and deal with it later.
        let structType: SymbolType
        switch node.structTypeExpr {
        case let app as GenericTypeApplication:
            if let s = try? typeChecker.check(expression: node.structTypeExpr) {
                structType = s
            } else {
                structType = try symbols.resolveTypeOfIdentifier(
                    sourceAnchor: app.identifier.sourceAnchor,
                    identifier: app.identifier.identifier
                )
            }

        default:
            structType = try typeChecker.check(expression: node.structTypeExpr)
        }

        switch structType {
        case .constStructType(let typ), .structType(let typ):
            try scan(implFor: node, structType: typ)

        case .genericStructType(let typ):
            typ.implForNodes.append(node)

        default:
            fatalError("unsupported type: \(structType)")
        }
    }

    private func scan(implFor node: ImplFor, structType: StructTypeInfo) throws {
        let traitType = try typeChecker.check(expression: node.traitTypeExpr).unwrapTraitType()

        try implScanner.scan(
            impl: Impl(
                sourceAnchor: node.sourceAnchor,
                typeArguments: node.typeArguments,
                structTypeExpr: node.structTypeExpr,
                children: node.children
            )
        )

        let sortedTraitSymbols = traitType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (requiredMethodName, requiredMethodSymbol) in sortedTraitSymbols {
            let maybeActualMethodSymbol = structType.symbols.maybeResolve(
                identifier: requiredMethodName
            )
            guard let actualMethodSymbol = maybeActualMethodSymbol else {
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message:
                        "`\(structType.name)' does not implement all trait methods; missing `\(requiredMethodName)'."
                )
            }
            let actualMethodType = actualMethodSymbol.type.unwrapFunctionType()
            let expectedMethodType = requiredMethodSymbol.type.unwrapPointerType()
                .unwrapFunctionType()
            guard actualMethodType.arguments.count == expectedMethodType.arguments.count else {
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message:
                        "`\(structType.name)' method `\(requiredMethodName)' has \(actualMethodType.arguments.count) parameter but the declaration in the `\(traitType.name)' trait has \(expectedMethodType.arguments.count)."
                )
            }
            if actualMethodType.arguments.count > 0 {
                let actualArgumentType = actualMethodType.arguments[0]
                let expectedArgumentType = expectedMethodType.arguments[0]
                if actualArgumentType != expectedArgumentType {
                    let typeChecker = TypeContextTypeChecker(
                        symbols: symbols,
                        staticStorageFrame: staticStorageFrame,
                        memoryLayoutStrategy: memoryLayoutStrategy
                    )
                    let genericMutableSelfPointerType = try typeChecker.check(
                        expression: PointerType(Identifier(traitType.name))
                    )
                    let concreteMutableSelfPointerType = try typeChecker.check(
                        expression: PointerType(Identifier(structType.name))
                    )
                    guard expectedArgumentType == genericMutableSelfPointerType else {
                        throw CompilerError(
                            sourceAnchor: node.sourceAnchor,
                            message:
                                "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedArgumentType)' argument, got `\(actualArgumentType)' instead"
                        )
                    }
                    guard actualArgumentType == concreteMutableSelfPointerType else {
                        throw CompilerError(
                            sourceAnchor: node.sourceAnchor,
                            message:
                                "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(concreteMutableSelfPointerType)' argument, got `\(actualArgumentType)' instead"
                        )
                    }
                }
            }
            if actualMethodType.arguments.count > 1 {
                for i in 1..<actualMethodType.arguments.count {
                    let actualArgumentType = actualMethodType.arguments[i]
                    let expectedArgumentType = expectedMethodType.arguments[i]
                    guard actualArgumentType == expectedArgumentType else {
                        throw CompilerError(
                            sourceAnchor: node.sourceAnchor,
                            message:
                                "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedArgumentType)' argument, got `\(actualArgumentType)' instead"
                        )
                    }
                }
            }
            guard actualMethodType.returnType == expectedMethodType.returnType else {
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message:
                        "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedMethodType.returnType)' return value, got `\(actualMethodType.returnType)' instead"
                )
            }
        }

        try makeVtableDeclaration(traitType, structType, node)
    }

    private func makeVtableDeclaration(
        _ traitType: TraitTypeInfo,
        _ structType: StructTypeInfo,
        _ node: ImplFor
    ) throws {
        let vtableType = try symbols.resolveType(identifier: traitType.nameOfVtableType)
            .unwrapStructType()
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

        let visibility: SymbolVisibility
        if let identifier = node.traitTypeExpr as? Identifier {
            let typeRecord = try symbols.resolveTypeRecord(
                sourceAnchor: node.sourceAnchor,
                identifier: identifier.identifier
            )
            visibility = typeRecord.visibility
        } else {
            visibility = .privateVisibility
        }

        let vtableInstanceDecl = VarDeclaration(
            identifier: Identifier(
                nameOfVtableInstance(
                    traitName: traitType.name,
                    structName: structType.name
                )
            ),
            explicitType: Identifier(vtableType.name),
            expression: StructInitializer(
                identifier: Identifier(traitType.nameOfVtableType),
                arguments: arguments
            ),
            storage: .staticStorage,
            isMutable: false,
            visibility: visibility
        )

        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(vtableInstanceDecl)!
    }
}

// TODO: where should the `nameOfVtableInstance(traitName:,structName:)` function live?
func nameOfVtableInstance(traitName: String, structName structName0: String) -> String {
    let structName1 =
        structName0.hasPrefix("__")
        ? String(structName0.dropFirst(2))
        : structName0
    let nameOfVtableInstance = "__\(traitName)_\(structName1)_vtable_instance"
    return nameOfVtableInstance
}
