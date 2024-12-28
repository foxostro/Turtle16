//
//  SnapSubcompilerTraitDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerTraitDeclaration: NSObject {
    public let globalEnvironment: GlobalEnvironment
    private var memoryLayoutStrategy: MemoryLayoutStrategy {
        globalEnvironment.memoryLayoutStrategy
    }
    public let symbols: SymbolTable
    
    public init(globalEnvironment: GlobalEnvironment, symbols: SymbolTable) {
        self.globalEnvironment = globalEnvironment
        self.symbols = symbols
    }
    
    public func compile(_ node: TraitDeclaration) throws -> SymbolType {
        if node.isGeneric {
            return try doGeneric(node)
        }
        else {
            return try doNonGeneric(traitDecl: node,
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
    
    public func instantiate(_ genericTraitType: GenericTraitType, _ evaluatedTypeArguments: [SymbolType]) throws -> SymbolType {
        let template = genericTraitType.template.eraseTypeArguments()
        return try doNonGeneric(traitDecl: template,
                                evaluatedTypeArguments: evaluatedTypeArguments,
                                genericTraitType: genericTraitType)
    }
    
    private func doNonGeneric(traitDecl node0: TraitDeclaration,
                              evaluatedTypeArguments: [SymbolType],
                              genericTraitType: GenericTraitType?) throws -> SymbolType {
        assert(!node0.isGeneric)
        
        let mangledName = TypeContextTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
            .mangleTraitName(node0.name, evaluatedTypeArguments: evaluatedTypeArguments)!
        let node1 = node0.withMangledName(mangledName)
        
        let result = try declareTraitType(node1, evaluatedTypeArguments, genericTraitType)
        try declareVtableType(node1)
        try declareTraitObjectType(node1)
        try declareTraitObjectThunks(node1)
        
        return result
    }
    
    private func declareTraitType(_ traitDecl: TraitDeclaration,
                                  _ evaluatedTypeArguments: [SymbolType] = [],
                                  _ genericTraitType: GenericTraitType? = nil) throws -> SymbolType {
        let mangledName = traitDecl.mangledName
        let members = SymbolTable(parent: symbols)
        let typeChecker = TypeContextTypeChecker(symbols: members, globalEnvironment: globalEnvironment)
        let fullyQualifiedTraitType = TraitType(
            name: mangledName,
            nameOfTraitObjectType: traitDecl.nameOfTraitObjectType,
            nameOfVtableType: traitDecl.nameOfVtableType,
            symbols: members)
        let result = SymbolType.traitType(fullyQualifiedTraitType)
        symbols.bind(identifier: mangledName,
                     symbolType: result,
                     visibility: traitDecl.visibility)
        
        if let genericTraitType {
            genericTraitType.instantiations[evaluatedTypeArguments] = result // memoize
        }
        
        members.enclosingFunctionNameMode = .set(mangledName)
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        for memberDeclaration in traitDecl.members {
            let memberType = try typeChecker.check(expression: memberDeclaration.memberType)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            let offset = frame.allocate(size: sizeOfMemberType)
            let symbol = Symbol(type: memberType, offset: offset, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            frame.add(identifier: memberDeclaration.name, symbol: symbol)
        }
        members.parent = nil
        
        return result
    }
    
    private func declareVtableType(_ traitDecl: TraitDeclaration) throws {
        let traitName = traitDecl.identifier.identifier
        let members: [StructDeclaration.Member] = traitDecl.members.map {
            let memberType = TraitObjectDeclarationsBuilder()
                .rewriteTraitMemberTypeForVtable(traitName, $0.memberType)
            let member = StructDeclaration.Member(name: $0.name, type: memberType)
            return member
        }
        let structDecl = StructDeclaration(sourceAnchor: traitDecl.sourceAnchor,
                                           identifier: Expression.Identifier(traitDecl.nameOfVtableType),
                                           members: members,
                                           visibility: traitDecl.visibility,
                                           isConst: true)
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment).compile(structDecl)
    }
    
    private func declareTraitObjectType(_ traitDecl: TraitDeclaration) throws {
        let members: [StructDeclaration.Member] = [
            StructDeclaration.Member(name: "object", type: Expression.PointerType(Expression.PrimitiveType(.void))),
            StructDeclaration.Member(name: "vtable", type: Expression.PointerType(Expression.ConstType(Expression.Identifier(traitDecl.nameOfVtableType))))
        ]
        let structDecl = StructDeclaration(sourceAnchor: traitDecl.sourceAnchor,
                                           identifier: Expression.Identifier(traitDecl.nameOfTraitObjectType),
                                           members: members,
                                           visibility: traitDecl.visibility,
                                           isConst: false) // TODO: Should isConst be true here?
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment).compile(structDecl)
    }
    
    private func declareTraitObjectThunks(_ traitDecl: TraitDeclaration) throws {
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = TraitObjectDeclarationsBuilder()
                .rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map {
                ($0 == 0) ? "self" : "arg\($0)"
            }
            let callee = Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier(method.name))
            let arguments = [Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))] + argumentNames[1...].map({Expression.Identifier($0)})
            
            let outer = SymbolTable(
                parent: symbols,
                frameLookupMode: .set(Frame(growthDirection: .down)))
            
            let fnBody: Block
            let returnType = try TypeContextTypeChecker(symbols: symbols).check(expression: functionType.returnType)
            if returnType == .void {
                fnBody = Block(symbols: SymbolTable(parent: outer),
                               children: [Expression.Call(callee: callee, arguments: arguments)])
            } else {
                fnBody = Block(symbols: SymbolTable(parent: outer),
                               children: [Return(Expression.Call(callee: callee, arguments: arguments))])
            }
            
            let fnDecl = FunctionDeclaration(identifier: Expression.Identifier(method.name),
                                             functionType: functionType,
                                             argumentNames: argumentNames,
                                             body: fnBody,
                                             symbols: outer)
            thunks.append(fnDecl)
        }
        let implBlock = Impl(sourceAnchor: traitDecl.sourceAnchor,
                             typeArguments: [], // TODO: Generic traits
                             structTypeExpr: Expression.Identifier(traitDecl.nameOfTraitObjectType),
                             children: thunks)
        try SnapSubcompilerImpl(
            symbols: symbols,
            globalEnvironment: globalEnvironment).compile(implBlock)
    }
}
