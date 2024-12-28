//
//  TraitObjectDeclarationsBuilder.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/28/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

struct TraitObjectDeclarationsBuilder {
    struct Declarations {
        let vtableDecl: StructDeclaration
        let traitObjectDecl: StructDeclaration
        let traitObjectImpl: Impl?
    }
    
    func declarations(
        for traitDecl: TraitDeclaration,
        symbols: SymbolTable) throws -> Declarations {
        
        assert(!traitDecl.isGeneric)
        let traitType = try symbols.resolveType(identifier: traitDecl.identifier.identifier).unwrapTraitType()
            let vtableDecl = vtable(for: traitType)
            .withSourceAnchor(traitDecl.sourceAnchor)
            .withVisibility(traitDecl.visibility)
        let voidPtr = Expression.PointerType(Expression.PrimitiveType(.void))
        let vtableType = Expression.PointerType(Expression.ConstType(Expression.Identifier(traitDecl.nameOfVtableType)))
        let traitObjectDecl = StructDeclaration(
            sourceAnchor: traitDecl.sourceAnchor,
            identifier: Expression.Identifier(
                sourceAnchor: traitDecl.identifier.sourceAnchor,
                identifier: traitDecl.nameOfTraitObjectType),
            members: [
                StructDeclaration.Member(name: "object", type: voidPtr),
                StructDeclaration.Member(name: "vtable", type: vtableType)
            ],
            visibility: traitDecl.visibility,
            isConst: true)
        let traitObjectImpl = try makeTraitObjectImpl(traitDecl, symbols)
        return Declarations(
            vtableDecl: vtableDecl,
            traitObjectDecl: traitObjectDecl,
            traitObjectImpl: traitObjectImpl)
    }
    
    func makeTraitObjectImpl(
        _ traitDecl: TraitDeclaration,
        _ symbols: SymbolTable) throws -> Impl? {
        
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map { ($0 == 0) ? "self" : "arg\($0)" }
            let callee = Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier(method.name))
            let arguments = [Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))] + argumentNames[1...].map({Expression.Identifier($0)})
            let outer = SymbolTable(
                parent: symbols,
                frameLookupMode: .set(Frame(growthDirection: .down)))
            let typeChecker = TypeContextTypeChecker(symbols: symbols)
            let returnType = try typeChecker.check(expression: functionType.returnType)
            let callExpr0 = Expression.Call(
                callee: callee,
                arguments: arguments)
            let callExpr1 = (returnType == .void)
                ? callExpr0
                : Return(callExpr0)
            let fnBody = Block(
                symbols: SymbolTable(parent: outer),
                children: [callExpr1])
            let fnDecl = FunctionDeclaration(
                identifier: Expression.Identifier(method.name),
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
            structTypeExpr: Expression.Identifier(traitDecl.nameOfTraitObjectType),
            children: thunks)
        return impl
    }
    
    func rewriteTraitMemberTypeForVtable(
        _ traitName: String,
        _ expr0: Expression) -> Expression {
        
        let expr: Expression
        
        if let primitiveType = expr0 as? Expression.PrimitiveType {
            expr = primitiveType.typ.lift
        }
        else {
            expr = expr0
        }
        
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
                
                if let pointerType = arg0 as? Expression.PointerType,
                   let app = pointerType.typ as? Expression.GenericTypeApplication,
                   app.identifier.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = Expression.PointerType(Expression.PrimitiveType(.void))
                    let modifiedFunctionType = Expression.FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return Expression.PointerType(modifiedFunctionType)
                }
            }
        }
        
        return expr
    }

    func rewriteTraitMemberTypeForThunk(
        _ traitDecl: TraitDeclaration,
        _ method: TraitDeclaration.Member) -> Expression.FunctionType {
        
        rewriteTraitMemberTypeForThunk(
            traitName: traitDecl.identifier.identifier,
            traitObjectName: traitDecl.nameOfTraitObjectType,
            methodName: method.name,
            methodType: method.memberType)
    }

    func rewriteTraitMemberTypeForThunk(
        traitName: String,
        traitObjectName: String,
        methodName: String,
        methodType: Expression) -> Expression.FunctionType {
            
        let functionType = (methodType as! Expression.PointerType).typ as! Expression.FunctionType
        
        if let arg0 = functionType.arguments.first {
            if ((arg0 as? Expression.PointerType)?.typ as? Expression.Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = Expression.PointerType(Expression.Identifier(traitObjectName))
                let modifiedFunctionType = Expression.FunctionType(name: methodName, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
            
            if (((arg0 as? Expression.PointerType)?.typ as? Expression.ConstType)?.typ as? Expression.Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = Expression.PointerType(Expression.ConstType(Expression.Identifier(traitObjectName)))
                let modifiedFunctionType = Expression.FunctionType(name: methodName, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
            
            if let pointerType = arg0 as? Expression.PointerType,
               let app = pointerType.typ as? Expression.GenericTypeApplication,
               app.identifier.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = Expression.PointerType(Expression.Identifier(traitObjectName))
                let modifiedFunctionType = Expression.FunctionType(
                    name: methodName,
                    returnType: functionType.returnType,
                    arguments: arguments)
                return modifiedFunctionType
            }
        }
        
        return functionType
    }
    
    func vtable(for traitType: TraitType) -> StructDeclaration {
        StructDeclaration(
            identifier: Expression.Identifier(traitType.nameOfVtableType),
            members: traitType.members.map { name, type in
                StructDeclaration.Member(
                    name: name,
                    type: rewriteTraitMemberTypeForVtable(traitType.name, type.lift))
            },
            isConst: true)
    }
}
