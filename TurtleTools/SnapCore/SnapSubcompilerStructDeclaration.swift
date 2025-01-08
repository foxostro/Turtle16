//
//  SnapSubcompilerStructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// TODO: Rename SnapSubcompilerStructDeclaration to StructScanner
public class SnapSubcompilerStructDeclaration: NSObject {
    public let symbols: SymbolTable
    public let globalEnvironment: GlobalEnvironment
    
    public init(symbols: SymbolTable,
                globalEnvironment: GlobalEnvironment) {
        self.symbols = symbols
        self.globalEnvironment = globalEnvironment
    }
    
    @discardableResult public func compile(_ node: StructDeclaration, _ evaluatedTypeArguments: [SymbolType] = []) throws -> SymbolType {
        let type: SymbolType
        if node.isGeneric {
            type = try doGeneric(node)
        }
        else {
            type = try doNonGeneric(node, evaluatedTypeArguments)
        }
        return type
    }
    
    private func doGeneric(_ node: StructDeclaration) throws -> SymbolType {
        assert(node.isGeneric)
        let name = node.identifier.identifier
        guard !symbols.exists(identifier: name) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing symbol: `\(name)'")
        }
        guard !symbols.existsAsType(identifier: name) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing type: `\(name)'")
        }
        let type = SymbolType.genericStructType(GenericStructType(template: node))
        symbols.bind(identifier: name,
                     symbolType: type,
                     visibility: node.visibility)
        return type
    }
    
    private func doNonGeneric(_ node: StructDeclaration, _ evaluatedTypeArguments: [SymbolType]) throws -> SymbolType {
        assert(!node.isGeneric)
        
        let members = SymbolTable(parent: symbols)
        let typeChecker = TypeContextTypeChecker(symbols: members, globalEnvironment: globalEnvironment)
        let name = node.identifier.identifier
        let mangledName = typeChecker.mangleStructName(name, evaluatedTypeArguments: evaluatedTypeArguments)!
        let fullyQualifiedStructType = StructType(
            name: mangledName,
            symbols: members,
            associatedTraitType: node.associatedTraitType)
        let type: SymbolType = node.isConst ? .constStructType(fullyQualifiedStructType) : .structType(fullyQualifiedStructType)
        
        guard !symbols.exists(identifier: mangledName) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing symbol: `\(mangledName)'")
        }
        
        let preexistingType = symbols.maybeResolveType(identifier: mangledName)
        
        symbols.bind(identifier: mangledName,
                     symbolType: type,
                     visibility: node.visibility)
        
        members.breadcrumb = .structType(mangledName)
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        for memberDeclaration in node.members {
            let memberType = try typeChecker.check(expression: memberDeclaration.memberType)
            guard memberType.maybeUnwrapStructType() != fullyQualifiedStructType else {
                throw CompilerError(
                    sourceAnchor: memberDeclaration.memberType.sourceAnchor,
                    message: "a struct cannot contain itself recursively")
            }
            guard try memberType.hasModule(symbols, globalEnvironment) == false else {
                throw CompilerError(
                    sourceAnchor: memberDeclaration.memberType.sourceAnchor,
                    message: "invalid use of module type")
            }
            let sizeOfMemberType = globalEnvironment.memoryLayoutStrategy.sizeof(type: memberType)
            let offset = frame.allocate(size: sizeOfMemberType)
            let symbol = Symbol(type: memberType, offset: offset, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            frame.add(identifier: memberDeclaration.name, symbol: symbol)
        }
        members.parent = nil
        
        // Check whether any type parameters incorrectly reference a module type
        for typ in evaluatedTypeArguments {
            guard try typ.hasModule(symbols, globalEnvironment) == false else {
                throw CompilerError(
                    sourceAnchor: node.typeArguments
                        .map(\.sourceAnchor)
                        .reduce(node.typeArguments.first?.sourceAnchor) {
                            $0?.union($1)
                        },
                    message: "invalid use of module type")
            }
        }
        
        // Catch all in case we missed something above
        guard try type.hasModule(symbols, globalEnvironment) == false else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "invalid use of module type")
        }
        
        // Prohibit redeclarations of the type unless we're simply scanning the
        // exact same type again. This can happen in a few situations such as
        // when instantiating a generic types in the type checker.
        // We do this check here so that we can perform a check above for any
        // structs with recursive definitions. However, if it was an error to
        // bind the new type due to invalid redeclaration of an existing type
        // then we ought throw an error before we go any further.
        if let preexistingType {
            let err = CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing type: `\(mangledName)'")
            
            guard let existing = preexistingType.maybeUnwrapStructType() else { throw err }
            guard fullyQualifiedStructType.name == existing.name else { throw err }
            
            let memberNamesSansFunctions = { (structType: StructType) in
                structType.symbols.symbolTable
                    .filter { !$0.value.type.isFunctionType }
                    .map { $0.key }
                    .sorted()
            }
            let ourMembersNames = memberNamesSansFunctions(fullyQualifiedStructType)
            let theirMembersNames = memberNamesSansFunctions(existing)
            guard ourMembersNames == theirMembersNames else { throw err }
        }
        
        return type
    }
}
