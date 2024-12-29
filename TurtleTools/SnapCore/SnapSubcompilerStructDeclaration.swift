//
//  SnapSubcompilerStructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

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
        
        // TODO: This is a hack to get vtable StructDeclarations to work across compiler passes before we've implemented an ImplFor compiler pass. Do that and then remove this hack.
        let allowRedefinition = mangledName.hasPrefix("__") && (mangledName.hasSuffix("_vtable") || mangledName.hasSuffix("_object"))
        guard allowRedefinition || !symbols.existsAsType(identifier: mangledName) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "struct declaration redefines existing type: `\(mangledName)'")
        }
        
        symbols.bind(identifier: mangledName,
                     symbolType: type,
                     visibility: node.visibility)
        
        members.enclosingFunctionNameMode = .set(name)
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        for memberDeclaration in node.members {
            let memberType = try typeChecker.check(expression: memberDeclaration.memberType)
            if memberType == .structType(fullyQualifiedStructType) || memberType == .constStructType(fullyQualifiedStructType) {
                throw CompilerError(sourceAnchor: memberDeclaration.memberType.sourceAnchor, message: "a struct cannot contain itself recursively")
            }
            let sizeOfMemberType = globalEnvironment.memoryLayoutStrategy.sizeof(type: memberType)
            let offset = frame.allocate(size: sizeOfMemberType)
            let symbol = Symbol(type: memberType, offset: offset, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            frame.add(identifier: memberDeclaration.name, symbol: symbol)
        }
        members.parent = nil
        
        return type
    }
}
