//
//  TraitObjectDeclarationsBuilder.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/28/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

struct TraitObjectDeclarationsBuilder {
    fileprivate typealias PointerType = Expression.PointerType
    fileprivate typealias ConstType = Expression.ConstType
    fileprivate typealias PrimitiveType = Expression.PrimitiveType
    fileprivate typealias Identifier = Expression.Identifier
    fileprivate typealias Get = Expression.Get
    fileprivate typealias Call = Expression.Call
    fileprivate typealias FunctionType = Expression.FunctionType
    fileprivate typealias GenericTypeApplication = Expression.GenericTypeApplication
    
    struct Declarations {
        let vtableDecl: StructDeclaration
        let traitObjectDecl: StructDeclaration
        let traitObjectImpl: Impl?
    }
    
    func declarations(for traitDecl: TraitDeclaration,
                      symbols: SymbolTable) throws -> Declarations {
        assert(!traitDecl.isGeneric)
        let vtableDecl = vtable(for: traitDecl)
        let traitObjectDecl = traitObjectDecl(for: traitDecl)
        let traitObjectImpl = try traitObjectImpl(for: traitDecl, symbols)
        return Declarations(
            vtableDecl: vtableDecl,
            traitObjectDecl: traitObjectDecl,
            traitObjectImpl: traitObjectImpl)
    }
    
    func vtable(for traitDecl: TraitDeclaration) -> StructDeclaration {
        StructDeclaration(
            sourceAnchor: traitDecl.sourceAnchor,
            identifier: traitDecl.identifier
                .withIdentifier(traitDecl.nameOfVtableType),
            members: traitDecl.members.map { member in
                StructDeclaration.Member(
                    name: member.name,
                    type: rewriteTraitMemberTypeForVtable(
                        traitDecl.name,
                        member.memberType))
            },
            visibility: traitDecl.visibility,
            isConst: false)
    }
    
    func traitObjectDecl(for traitDecl: TraitDeclaration) -> StructDeclaration {
        let voidPtr = PointerType(PrimitiveType(.void))
        let vtableType = PointerType(ConstType(Identifier(traitDecl.nameOfVtableType)))
        let traitObjectDecl = StructDeclaration(
            sourceAnchor: traitDecl.sourceAnchor,
            identifier: Identifier(
                sourceAnchor: traitDecl.identifier.sourceAnchor,
                identifier: traitDecl.nameOfTraitObjectType),
            members: [
                StructDeclaration.Member(name: "object", type: voidPtr),
                StructDeclaration.Member(name: "vtable", type: vtableType)
            ],
            visibility: traitDecl.visibility,
            isConst: false,
            associatedTraitType: traitDecl.name)
        return traitObjectDecl
    }
    
    func traitObjectImpl(
        for traitDecl: TraitDeclaration,
        _ symbols: SymbolTable) throws -> Impl? {
        
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map { ($0 == 0) ? "self" : "arg\($0)" }
            let callee = Get(expr: Get(expr: Identifier("self"), member: Identifier("vtable")), member: Identifier(method.name))
            let arguments = [Get(expr: Identifier("self"), member: Identifier("object"))] + argumentNames[1...].map({Identifier($0)})
            let outer = SymbolTable(
                parent: symbols,
                frameLookupMode: .set(Frame(growthDirection: .down)))
            let typeChecker = TypeContextTypeChecker(symbols: symbols)
            let returnType = try typeChecker.check(expression: functionType.returnType)
            let callExpr0 = Call(
                callee: callee,
                arguments: arguments)
            let callExpr1 = (returnType == .void)
                ? callExpr0
                : Return(callExpr0)
            let fnBody = Block(
                symbols: SymbolTable(parent: outer),
                children: [callExpr1])
            let fnDecl = FunctionDeclaration(
                identifier: Identifier(method.name),
                functionType: functionType,
                argumentNames: argumentNames,
                body: fnBody,
                symbols: outer)
            thunks.append(fnDecl)
        }
        guard !thunks.isEmpty else { return nil }
        let impl = Impl(
            sourceAnchor: traitDecl.sourceAnchor,
            typeArguments: [],
            structTypeExpr: Identifier(traitDecl.nameOfTraitObjectType),
            children: thunks)
        return impl
    }
    
    func rewriteTraitMemberTypeForVtable( // TODO: The `rewriteTraitMemberTypeForVtable` method should be fileprivate
        _ traitName: String,
        _ expr0: Expression
    ) -> Expression {
        let expr: Expression
        
        if let primitiveType = expr0 as? PrimitiveType {
            expr = primitiveType.typ.lift
        }
        else {
            expr = expr0
        }
        
        if let functionType = (expr as? PointerType)?.typ as? FunctionType {
            if let arg0 = functionType.arguments.first {
                if ((arg0 as? PointerType)?.typ as? Identifier)?.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = PointerType(PrimitiveType(.void))
                    let modifiedFunctionType = FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return PointerType(modifiedFunctionType)
                }
                
                if (((arg0 as? PointerType)?.typ as? ConstType)?.typ as? Identifier)?.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = PointerType(PrimitiveType(.void))
                    let modifiedFunctionType = FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return PointerType(modifiedFunctionType)
                }
                
                if let pointerType = arg0 as? PointerType,
                   let app = pointerType.typ as? GenericTypeApplication,
                   app.identifier.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = PointerType(PrimitiveType(.void))
                    let modifiedFunctionType = FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return PointerType(modifiedFunctionType)
                }
            }
        }
        
        return expr
    }

    func rewriteTraitMemberTypeForThunk( // TODO: The `rewriteTraitMemberTypeForThunk` method should be fileprivate
        _ traitDecl: TraitDeclaration,
        _ method: TraitDeclaration.Member) -> Expression.FunctionType {
        
        rewriteTraitMemberTypeForThunk(
            traitName: traitDecl.identifier.identifier,
            traitObjectName: traitDecl.nameOfTraitObjectType,
            methodName: method.name,
            methodType: method.memberType)
    }

    fileprivate func rewriteTraitMemberTypeForThunk(
        traitName: String,
        traitObjectName: String,
        methodName: String,
        methodType: Expression) -> Expression.FunctionType {
            
        let functionType = (methodType as! PointerType).typ as! FunctionType
        
        if let arg0 = functionType.arguments.first {
            if ((arg0 as? PointerType)?.typ as? Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = PointerType(Identifier(traitObjectName))
                let modifiedFunctionType = FunctionType(name: methodName, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
            
            if (((arg0 as? PointerType)?.typ as? ConstType)?.typ as? Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = PointerType(ConstType(Identifier(traitObjectName)))
                let modifiedFunctionType = FunctionType(name: methodName, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
            
            if let pointerType = arg0 as? PointerType,
               let app = pointerType.typ as? GenericTypeApplication,
               app.identifier.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = PointerType(Identifier(traitObjectName))
                let modifiedFunctionType = FunctionType(
                    name: methodName,
                    returnType: functionType.returnType,
                    arguments: arguments)
                return modifiedFunctionType
            }
        }
        
        return functionType
    }
}
