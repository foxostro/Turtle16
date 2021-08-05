//
//  SnapSubcompilerTraitDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerTraitDeclaration: NSObject {
    public private(set) var symbols: SymbolTable? = nil
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable) {
        self.symbols = symbols
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(_ node: TraitDeclaration) throws -> [AbstractSyntaxTreeNode] {
        try declareTraitType(node)
        let vtable = try declareVtableType(node)
        let traitObject = declareTraitObjectType(node)
        return [vtable, traitObject]
    }
    
    func declareTraitType(_ traitDecl: TraitDeclaration) throws {
        let name = traitDecl.identifier.identifier
        
        let members = SymbolTable(parent: symbols)
        let fullyQualifiedTraitType = TraitType(name: name, nameOfTraitObjectType: traitDecl.nameOfTraitObjectType, nameOfVtableType: traitDecl.nameOfVtableType, symbols: members)
        symbols!.bind(identifier: name,
                      symbolType: .traitType(fullyQualifiedTraitType),
                      visibility: traitDecl.visibility)
        
        members.enclosingFunctionName = name
        for memberDeclaration in traitDecl.members {
            let memberType = try TypeContextTypeChecker(symbols: members).check(expression: memberDeclaration.memberType)
            let symbol = Symbol(type: memberType, offset: members.storagePointer, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            members.storagePointer += sizeOfMemberType
        }
        members.parent = nil
    }
    
    func declareVtableType(_ traitDecl: TraitDeclaration) throws -> StructDeclaration {
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
        return structDecl
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
        
        fatalError("TODO: add a test to trigger this case")
        return expr
    }
    
    func declareTraitObjectType(_ traitDecl: TraitDeclaration) -> StructDeclaration {
        let members: [StructDeclaration.Member] = [
            StructDeclaration.Member(name: "object", type: Expression.PointerType(Expression.PrimitiveType(.void))),
            StructDeclaration.Member(name: "vtable", type: Expression.PointerType(Expression.ConstType(Expression.Identifier(traitDecl.nameOfVtableType))))
        ]
        let structDecl = StructDeclaration(sourceAnchor: traitDecl.sourceAnchor,
                                           identifier: Expression.Identifier(traitDecl.nameOfTraitObjectType),
                                           members: members,
                                           visibility: traitDecl.visibility,
                                           isConst: false) // TODO: Should isConst be true here?
        return structDecl
    }
}
