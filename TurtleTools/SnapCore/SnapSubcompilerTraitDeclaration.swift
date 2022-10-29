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
    
    public func compile(_ node: TraitDeclaration) throws {
        try declareTraitType(node)
        try declareVtableType(node)
        try declareTraitObjectType(node)
        try declareTraitObjectThunks(node)
    }
    
    func declareTraitType(_ traitDecl: TraitDeclaration) throws {
        let name = traitDecl.identifier.identifier
        
        let members = SymbolTable(parent: symbols)
        let fullyQualifiedTraitType = TraitType(name: name, nameOfTraitObjectType: traitDecl.nameOfTraitObjectType, nameOfVtableType: traitDecl.nameOfVtableType, symbols: members)
        symbols.bind(identifier: name,
                     symbolType: .traitType(fullyQualifiedTraitType),
                     visibility: traitDecl.visibility)
        
        members.enclosingFunctionNameMode = .set(name)
        for memberDeclaration in traitDecl.members {
            let memberType = try TypeContextTypeChecker(symbols: members).check(expression: memberDeclaration.memberType)
            let symbol = Symbol(type: memberType, offset: members.storagePointer, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            members.storagePointer += sizeOfMemberType
        }
        members.parent = nil
    }
    
    func declareVtableType(_ traitDecl: TraitDeclaration) throws {
        let traitName = traitDecl.identifier.identifier
        let members: [StructDeclaration.Member] = traitDecl.members.map {
            let memberType = rewriteTraitMemberTypeForVtable(traitName, $0.memberType)
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
    
    func rewriteTraitMemberTypeForVtable(_ traitName: String, _ expr: Expression) -> Expression {
        if let functionType = (expr as? Expression.PointerType)?.typ as? Expression.FunctionType {
            if let arg0 = functionType.arguments.first {
                if ((arg0 as? Expression.PointerType)?.typ as? Expression.Identifier)?.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = Expression.PointerType(Expression.PrimitiveType(.void))
                    let modifiedFunctionType = Expression.FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return Expression.PointerType(modifiedFunctionType)
                }
                
                if (((arg0 as? Expression.PointerType)?.typ as? Expression.ConstType)?.typ as? Expression.Identifier)?.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = Expression.PointerType(Expression.PrimitiveType(.void))
                    let modifiedFunctionType = Expression.FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return Expression.PointerType(modifiedFunctionType)
                }
            }
        }
        
        return expr
    }
    
    func declareTraitObjectType(_ traitDecl: TraitDeclaration) throws {
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
    
    func declareTraitObjectThunks(_ traitDecl: TraitDeclaration) throws {
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map { ($0 == 0) ? "self" : "arg\($0)" }
            let callee = Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier(method.name))
            let arguments = [Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))] + argumentNames[1...].map({Expression.Identifier($0)})
            
            let outer = SymbolTable(parent: symbols)
            
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
    
    func rewriteTraitMemberTypeForThunk(_ traitDecl: TraitDeclaration, _ method: TraitDeclaration.Member) -> Expression.FunctionType {
        
        let traitName = traitDecl.identifier.identifier
        let traitObjectName = traitDecl.nameOfTraitObjectType
        let functionType = (method.memberType as! Expression.PointerType).typ as! Expression.FunctionType
        
        if let arg0 = functionType.arguments.first {
            if ((arg0 as? Expression.PointerType)?.typ as? Expression.Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = Expression.PointerType(Expression.Identifier(traitObjectName))
                let modifiedFunctionType = Expression.FunctionType(name: method.name, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
            
            if (((arg0 as? Expression.PointerType)?.typ as? Expression.ConstType)?.typ as? Expression.Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = Expression.PointerType(Expression.ConstType(Expression.Identifier(traitObjectName)))
                let modifiedFunctionType = Expression.FunctionType(name: method.name, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
        }
        
        return functionType
    }
}
