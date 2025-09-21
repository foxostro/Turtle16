//
//  StructScanner.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Adds a new struct type to the environment for a given StructDeclaration
public struct StructScanner {
    private let symbols: Env
    private let memoryLayoutStrategy: MemoryLayoutStrategy

    public init(
        symbols: Env,
        memoryLayoutStrategy: MemoryLayoutStrategy
    ) {
        self.symbols = symbols
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }

    @discardableResult public func compile(
        _ node: StructDeclaration,
        _ evaluatedTypeArguments: [SymbolType] = []
    ) throws -> SymbolType {
        if node.isGeneric {
            try doGeneric(node)
        }
        else {
            try doNonGeneric(node, evaluatedTypeArguments)
        }
    }

    private func doGeneric(_ node: StructDeclaration) throws -> SymbolType {
        assert(node.isGeneric)
        let name = node.identifier.identifier
        guard !symbols.exists(identifier: name, maxDepth: 0) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing symbol: `\(name)'"
            )
        }
        guard !symbols.existsAsType(identifier: name, maxDepth: 0) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing type: `\(name)'"
            )
        }
        let type = SymbolType.genericStructType(GenericStructTypeInfo(template: node))
        symbols.bind(
            identifier: name,
            symbolType: type,
            visibility: node.visibility
        )
        return type
    }

    private func doNonGeneric(
        _ node: StructDeclaration,
        _ evaluatedTypeArguments: [SymbolType]
    ) throws -> SymbolType {
        assert(!node.isGeneric)

        let members = Env(parent: symbols)
        let typeChecker = RvalueExpressionTypeChecker(
            symbols: members,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        let name = node.identifier.identifier
        let mangledName = typeChecker.mangleStructName(
            name,
            evaluatedTypeArguments: evaluatedTypeArguments
        )!
        let fullyQualifiedStructType = StructTypeInfo(
            name: mangledName,
            fields: members,
            associatedTraitType: node.associatedTraitType
        )
        let type: SymbolType = node.isConst
            ? .constStructType(fullyQualifiedStructType) : .structType(fullyQualifiedStructType)

        guard !symbols.exists(identifier: mangledName, maxDepth: 0) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing symbol: `\(mangledName)'"
            )
        }

        let preexistingType = symbols.maybeResolveType(identifier: mangledName, maxDepth: 0)

        symbols.bind(
            identifier: mangledName,
            symbolType: type,
            visibility: node.visibility
        )

        members.breadcrumb = .structType(mangledName)
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        for memberDeclaration in node.members {
            let memberType = try typeChecker.check(expression: memberDeclaration.memberType)
            guard memberType.maybeUnwrapStructType() != fullyQualifiedStructType else {
                throw CompilerError(
                    sourceAnchor: memberDeclaration.memberType.sourceAnchor,
                    message: "a struct cannot contain itself recursively"
                )
            }
            guard try memberType.hasModule(symbols) == false else {
                throw CompilerError(
                    sourceAnchor: memberDeclaration.memberType.sourceAnchor,
                    message: "invalid use of module type"
                )
            }
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            let offset = frame.allocate(size: sizeOfMemberType)
            let symbol = Symbol(type: memberType, storage: .automaticStorage(offset: offset))
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            frame.add(identifier: memberDeclaration.name, symbol: symbol)
        }
        members.parent = nil

        // Check whether any type parameters incorrectly reference a module type
        for typ in evaluatedTypeArguments {
            guard try typ.hasModule(symbols) == false else {
                throw CompilerError(
                    sourceAnchor: node.typeArguments
                        .map(\.sourceAnchor)
                        .reduce(node.typeArguments.first?.sourceAnchor) {
                            $0?.union($1)
                        },
                    message: "invalid use of module type"
                )
            }
        }

        // Catch all in case we missed something above
        guard try type.hasModule(symbols) == false else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "invalid use of module type"
            )
        }

        // Throw an error if the identifier is already bound in the environment
        // and cannot be shadowed. The error is thrown at this point to ensure
        // that errors for above cases are given priority.
        guard preexistingType == nil else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing type: `\(mangledName)'"
            )
        }

        return type
    }
}
