//
//  TraitScanner.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation

/// Scans a trait declaration and binds the trait type in the environment
public class TraitScanner: NSObject {
    public let globalEnvironment: GlobalEnvironment
    public let symbols: SymbolTable
    
    private var memoryLayoutStrategy: MemoryLayoutStrategy {
        globalEnvironment.memoryLayoutStrategy
    }
    
    public init(globalEnvironment: GlobalEnvironment = GlobalEnvironment(), symbols: SymbolTable = SymbolTable()) {
        self.globalEnvironment = globalEnvironment
        self.symbols = symbols
    }
    
    @discardableResult
    public func scan(trait node: TraitDeclaration) throws -> SymbolType {
        if node.isGeneric {
            try doGeneric(node)
        }
        else {
            try doNonGeneric(traitDecl: node,
                             evaluatedTypeArguments: [],
                             genericTraitType: nil)
        }
    }
    
    private func doGeneric(_ node: TraitDeclaration) throws -> SymbolType {
        assert(node.isGeneric)
        let name = node.identifier.identifier
        let type = SymbolType.genericTraitType(GenericTraitType(template: node))
        symbols.bind(identifier: name,
                     symbolType: type,
                     visibility: node.visibility)
        return type
    }
    
    private func doNonGeneric(traitDecl node0: TraitDeclaration,
                              evaluatedTypeArguments: [SymbolType],
                              genericTraitType: GenericTraitType?) throws -> SymbolType {
        assert(!node0.isGeneric)
        let mangledName = mangleTraitName(
            name: node0.name,
            evaluatedTypeArguments: evaluatedTypeArguments)
        let node1 = node0.withMangledName(mangledName)
        let members = SymbolTable(parent: symbols)
        let traitType = SymbolType.traitType(TraitType(
            name: mangledName,
            nameOfTraitObjectType: node1.nameOfTraitObjectType,
            nameOfVtableType: node1.nameOfVtableType,
            symbols: members))
        
        symbols.bind(identifier: mangledName,
                     symbolType: traitType,
                     visibility: node1.visibility)
        
        if let genericTraitType {
            genericTraitType.instantiations[evaluatedTypeArguments] = traitType // memoize
        }
        
        let typeChecker = typeChecker(symbols: members)
        members.breadcrumb = .traitType(traitType.unwrapTraitType().name)
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        for memberDeclaration in node1.members {
            let memberType = try typeChecker.check(expression: memberDeclaration.memberType)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            let offset = frame.allocate(size: sizeOfMemberType)
            let symbol = Symbol(type: memberType, offset: offset, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            frame.add(identifier: memberDeclaration.name, symbol: symbol)
        }
        members.parent = nil
        
        // Put types into the environment for the vtable and trait-object
        try scan(decls: try TraitObjectDeclarationsBuilder().declarations(
            for: node0,
            symbols: symbols))
        
        return traitType
    }
    
    /// Put types into the environment for the vtable and trait-object
    private func scan(decls: TraitObjectDeclarationsBuilder.Declarations) throws {
        try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(decls.vtableDecl)
        try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(decls.traitObjectDecl)
        if let traitObjectImpl = decls.traitObjectImpl {
            try ImplScanner(
                globalEnvironment: globalEnvironment,
                symbols: symbols)
            .scan(impl: traitObjectImpl)
        }
    }
    
    /// Mangle the name of a concrete instance of a generic trait, given its evaluated type arguments
    private func mangleTraitName(name: String?, evaluatedTypeArguments: [SymbolType] = []) -> String {
        typeChecker().mangleTraitName(name, evaluatedTypeArguments: evaluatedTypeArguments)!
    }
    
    private func typeChecker() -> TypeContextTypeChecker {
        typeChecker(symbols: symbols)
    }
    
    private func typeChecker(symbols: SymbolTable) -> TypeContextTypeChecker {
        TypeContextTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
    }
}
