//
//  ImplScanner.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

/// Scans an Impl declaration and binds the function symbols in the environment
public struct ImplScanner {
    private let memoryLayoutStrategy: MemoryLayoutStrategy
    private let parent: Env
    private let typeChecker: RvalueExpressionTypeChecker

    public init(
        memoryLayoutStrategy: MemoryLayoutStrategy,
        symbols parent: Env = Env()
    ) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.parent = parent
        typeChecker = RvalueExpressionTypeChecker(
            symbols: parent,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
    }

    public func scan(impl node: Impl) throws {
        if node.isGeneric {
            try doGenericCase(node)
        }
        else {
            try doNonGenericCase(node)
        }
    }

    private func doGenericCase(_ node: Impl) throws {
        assert(node.isGeneric)

        guard let app = node.structTypeExpr as? GenericTypeApplication else {
            throw CompilerError(
                sourceAnchor: node.structTypeExpr.sourceAnchor,
                message: "expected a generic type application: `\(node.structTypeExpr)'"
            )
        }

        let structType = try parent
            .resolveTypeOfIdentifier(
                sourceAnchor: app.sourceAnchor,
                identifier: app.identifier.identifier
            )
            .unwrapGenericStructType()

        structType.implNodes.append(node)
    }

    private func doNonGenericCase(_ node: Impl) throws {
        assert(!node.isGeneric)

        guard
            let structType = try typeChecker.check(expression: node.structTypeExpr)
            .maybeUnwrapStructType()
        else {
            fatalError("unsupported expression: \(node)")
        }

        try scanImplStruct(node, structType)
    }

    private func scanImplStruct(_ node: Impl, _ typ: StructTypeInfo) throws {
        let symbols = Env(parent: parent)
        symbols.breadcrumb = .structType(typ.name)

        typ.push()
        parent.deferAction { typ.pop() }

        for child in node.children {
            let identifier = child.identifier.identifier
            guard !typ.symbols.exists(identifier: identifier) else {
                throw CompilerError(
                    sourceAnchor: child.sourceAnchor,
                    message: "function redefines existing symbol: `\(identifier)'"
                )
            }

            let scanner = FunctionScanner(
                memoryLayoutStrategy: memoryLayoutStrategy,
                symbols: symbols,
                enclosingImplId: node.id
            )
            try scanner.scan(func: child)

            // Put the symbol back into the struct type's symbol table too.
            typ.symbols.bind(
                identifier: identifier,
                symbol: symbols.symbolTable[identifier]!
            )
        }
    }
}
