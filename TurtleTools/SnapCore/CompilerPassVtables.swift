//
//  CompilerPassTraits.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to emit vtable and such for traits
// TODO: Add another compiler pass after the implForInPass() to erase traits. This one would rewrite expressions that refer to traits and would erase the trait declarations themselves.
public class CompilerPassVtables: CompilerPassWithDeclScan {
    override func scan(trait node: TraitDeclaration) throws {
        // TODO: remove the scan(trait:) override when we change the super class to replace SnapSubcompilerTraitDeclaration with TraitScanner
        let scanner = TraitScanner(globalEnvironment: globalEnvironment, symbols: symbols!)
        try scanner.scan(trait: node)
    }
    
    public override func visit(trait traitDecl0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        assert(!traitDecl0.isGeneric)
        let traitDecl1 = try super.visit(trait: traitDecl0) as! TraitDeclaration
        let traitType = try symbols!.resolveType(identifier: traitDecl1.identifier.identifier).unwrapTraitType()
        let vtableDecl = traitType
            .vtableStructDeclaration
            .withSourceAnchor(traitDecl1.sourceAnchor)
            .withVisibility(traitDecl1.visibility)
        let voidPtr = Expression.PointerType(Expression.PrimitiveType(.void))
        let vtableType = Expression.PointerType(Expression.ConstType(Expression.Identifier(traitDecl1.nameOfVtableType)))
        let traitObjectDecl = StructDeclaration(
            sourceAnchor: traitDecl1.sourceAnchor,
            identifier: Expression.Identifier(
                sourceAnchor: traitDecl1.identifier.sourceAnchor,
                identifier: traitDecl1.nameOfTraitObjectType),
            members: [
                StructDeclaration.Member(name: "object", type: voidPtr),
                StructDeclaration.Member(name: "vtable", type: vtableType)
            ],
            visibility: traitDecl1.visibility,
            isConst: true)
        let traitObjectImpl = try makeTraitObjectImpl(traitDecl1)
        let seq = Seq(children: [
            traitDecl1,
            vtableDecl,
            traitObjectDecl,
            traitObjectImpl
        ])
        return seq
    }
    
    private func makeTraitObjectImpl(_ traitDecl: TraitDeclaration) throws -> Impl {
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map { ($0 == 0) ? "self" : "arg\($0)" }
            let callee = Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier(method.name))
            let arguments = [Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))] + argumentNames[1...].map({Expression.Identifier($0)})
            
            let outer = SymbolTable(
                parent: symbols,
                frameLookupMode: .set(Frame(growthDirection: .down)))
            
            let fnBody: Block
            let returnType = try typeChecker.check(expression: functionType.returnType)
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
        let impl = Impl(
            sourceAnchor: traitDecl.sourceAnchor,
            typeArguments: [],
            structTypeExpr: Expression.Identifier(traitDecl.nameOfTraitObjectType),
            children: thunks)
        return impl
    }
    
    private var typeChecker: TypeContextTypeChecker {
        TypeContextTypeChecker(symbols: symbols!)
    }
}

func rewriteTraitMemberTypeForVtable(_ traitName: String, _ expr0: Expression) -> Expression {
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

extension AbstractSyntaxTreeNode {
    /// Compiler pass to emit vtable and such for traits
    public func vtablesPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassVtables(globalEnvironment: globalEnvironment).run(self)
    }
}
