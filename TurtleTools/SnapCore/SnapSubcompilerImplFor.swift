//
//  SnapSubcompilerImplFor.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerImplFor: NSObject {
    public let symbols: SymbolTable
    public let globalEnvironment: GlobalEnvironment
    public let typeChecker: RvalueExpressionTypeChecker
    
    public init(symbols: SymbolTable,
                globalEnvironment: GlobalEnvironment) {
        self.symbols = symbols
        self.globalEnvironment = globalEnvironment
        typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
    }
    
    public func compile(_ node: ImplFor) throws {
        // It may be the case that we can't resolve the generic type application
        // because the arugment is an unbound generic type variables. If so then
        // we need to ensure the expression resolves to a generic struct type
        // and deal with it later.
        let structType: SymbolType
        switch node.structTypeExpr {
        case let app as Expression.GenericTypeApplication:
            if let s = try? typeChecker.check(expression: node.structTypeExpr) {
                structType = s
            }
            else {
                structType = try symbols.resolveTypeOfIdentifier(sourceAnchor: app.identifier.sourceAnchor,
                                                                 identifier: app.identifier.identifier)
            }
            
        default:
            structType = try typeChecker.check(expression: node.structTypeExpr)
        }
        
        switch structType {
        case .constStructType(let typ), .structType(let typ):
            try compile(implFor: node, structType: typ)
            
        case .genericStructType(let typ):
            typ.implForNodes.append(node)
            
        default:
            fatalError("unsupported type: \(structType)")
        }
    }
    
    private func compile(implFor node: ImplFor, structType: StructType) throws {
        let traitType = try typeChecker.check(expression: node.traitTypeExpr).unwrapTraitType()
        let vtableType = try typeChecker.check(identifier: Expression.Identifier(traitType.nameOfVtableType)).unwrapStructType()
        
        let impl = Impl(sourceAnchor: node.sourceAnchor,
                        typeArguments: node.typeArguments,
                        structTypeExpr: node.structTypeExpr,
                        children: node.children)
        try SnapSubcompilerImpl(symbols: symbols, globalEnvironment: globalEnvironment).compile(impl)
        
        let sortedTraitSymbols = traitType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (requiredMethodName, requiredMethodSymbol) in sortedTraitSymbols {
            let maybeActualMethodSymbol = structType.symbols.maybeResolve(identifier: requiredMethodName)
            guard let actualMethodSymbol = maybeActualMethodSymbol else {
                throw CompilerError(sourceAnchor: node.sourceAnchor, message: "`\(structType.name)' does not implement all trait methods; missing `\(requiredMethodName)'.")
            }
            let actualMethodType = actualMethodSymbol.type.unwrapFunctionType()
            let expectedMethodType = requiredMethodSymbol.type.unwrapPointerType().unwrapFunctionType()
            guard actualMethodType.arguments.count == expectedMethodType.arguments.count else {
                throw CompilerError(sourceAnchor: node.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has \(actualMethodType.arguments.count) parameter but the declaration in the `\(traitType.name)' trait has \(expectedMethodType.arguments.count).")
            }
            if actualMethodType.arguments.count > 0 {
                let actualArgumentType = actualMethodType.arguments[0]
                let expectedArgumentType = expectedMethodType.arguments[0]
                if actualArgumentType != expectedArgumentType {
                    let typeChecker = TypeContextTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
                    let genericMutableSelfPointerType = try typeChecker.check(expression: Expression.PointerType(Expression.Identifier(traitType.name)))
                    let concreteMutableSelfPointerType = try typeChecker.check(expression: Expression.PointerType(Expression.Identifier(structType.name)))
                    if expectedArgumentType == genericMutableSelfPointerType {
                        if actualArgumentType != concreteMutableSelfPointerType {
                            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(concreteMutableSelfPointerType)' argument, got `\(actualArgumentType)' instead")
                        }
                    }
                    else {
                        throw CompilerError(sourceAnchor: node.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedArgumentType)' argument, got `\(actualArgumentType)' instead")
                    }
                }
            }
            if actualMethodType.arguments.count > 1 {
                for i in 1..<actualMethodType.arguments.count {
                    let actualArgumentType = actualMethodType.arguments[i]
                    let expectedArgumentType = expectedMethodType.arguments[i]
                    guard actualArgumentType == expectedArgumentType else {
                        throw CompilerError(sourceAnchor: node.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedArgumentType)' argument, got `\(actualArgumentType)' instead")
                    }
                }
            }
            if actualMethodType.returnType != expectedMethodType.returnType {
                throw CompilerError(sourceAnchor: node.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedMethodType.returnType)' return value, got `\(actualMethodType.returnType)' instead")
            }
        }
        
        try makeVtableDeclaration(traitType, structType, vtableType, node)
    }
    
    private func makeVtableDeclaration(_ traitType: TraitType,
                                       _ structType: StructType,
                                       _ vtableType: StructType,
                                       _ node: ImplFor) throws {
        
        let traitScope = symbols.lookupScopeEnclosingType(identifier: traitType.name)!
        
        try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
            .compile(StructDeclaration(vtableType))
        
        let nameOfVtableInstance = "__\(traitType.name)_\(structType.name)_vtable_instance"
        var arguments: [Expression.StructInitializer.Argument] = []
        let sortedVtableSymbols = vtableType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (methodName, methodSymbol) in sortedVtableSymbols {
            let arg = Expression.StructInitializer.Argument(name: methodName, expr: Expression.Bitcast(expr: Expression.Unary(op: .ampersand, expression: Expression.Get(expr: Expression.Identifier(structType.name), member: Expression.Identifier(methodName))), targetType: Expression.PrimitiveType(methodSymbol.type)))
            arguments.append(arg)
        }
        let initializer = Expression.StructInitializer(identifier: Expression.Identifier(traitType.nameOfVtableType), arguments: arguments)
        
        let visibility = if let identifier = node.traitTypeExpr as? Expression.Identifier {
                try symbols.resolveTypeRecord(
                    sourceAnchor: node.sourceAnchor,
                    identifier: identifier.identifier)
                .visibility
            }
            else {
                SymbolVisibility.privateVisibility
            }
        
        let vtableInstanceDecl = VarDeclaration(
            identifier: Expression.Identifier(nameOfVtableInstance),
            explicitType: Expression.Identifier(vtableType.name),
            expression: initializer,
            storage: .staticStorage,
            isMutable: false,
            visibility: visibility)
        
        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment).compile(vtableInstanceDecl)!
        
        recordVtableDeclInsertion(
            pendingInsertions: &traitScope.pendingInsertions,
            traitName: traitType.name,
            toInsert: [
                StructDeclaration(vtableType),
                vtableInstanceDecl
            ])
    }
    
    /// Record an edit to the block AST to insert vtable declarations
    private func recordVtableDeclInsertion(
        pendingInsertions: inout [String : Seq],
        traitName: String,
        toInsert: [AbstractSyntaxTreeNode]) {
            
        guard !toInsert.isEmpty else { return }
        
        if pendingInsertions[traitName] == nil {
            pendingInsertions[traitName] = Seq(tags: [.vtable], children: toInsert)
        }
        else {
            pendingInsertions[traitName] = pendingInsertions[traitName]!
                .appending(children: toInsert)
                .removeDuplicateVtableDeclarations()
        }
    }
}
