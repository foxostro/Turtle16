//
//  SnapSubcompilerImplFor.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerImplFor: NSObject {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public let symbols: SymbolTable
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable) {
        self.symbols = symbols
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(_ node: ImplFor) throws -> Seq {
        var resultArr: [AbstractSyntaxTreeNode] = []
        
        let traitType = try symbols.resolveType(sourceAnchor: node.sourceAnchor,
                                                identifier: node.traitIdentifier.identifier).unwrapTraitType()
        let structType = try symbols.resolveType(sourceAnchor: node.sourceAnchor,
                                                 identifier: node.structIdentifier.identifier).unwrapStructType()
        let vtableType = try symbols.resolveType(sourceAnchor: node.sourceAnchor,
                                                 identifier: traitType.nameOfVtableType).unwrapStructType()
        
        let impl = Impl(sourceAnchor: node.sourceAnchor, identifier: node.structIdentifier, children: node.children)
        resultArr.append(try SnapSubcompilerImpl(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols).compile(impl))
        
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
                    let typeChecker = TypeContextTypeChecker(symbols: symbols)
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
        
        let nameOfVtableInstance = "__\(traitType.name)_\(structType.name)_vtable_instance"
        var arguments: [Expression.StructInitializer.Argument] = []
        let sortedVtableSymbols = vtableType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (methodName, methodSymbol) in sortedVtableSymbols {
            let arg = Expression.StructInitializer.Argument(name: methodName, expr: Expression.Bitcast(expr: Expression.Unary(op: .ampersand, expression: Expression.Get(expr: Expression.Identifier(structType.name), member: Expression.Identifier(methodName))), targetType: Expression.PrimitiveType(methodSymbol.type)))
            arguments.append(arg)
        }
        let initializer = Expression.StructInitializer(identifier: Expression.Identifier(traitType.nameOfVtableType), arguments: arguments)
        let visibility = try symbols.resolveTypeRecord(sourceAnchor: node.sourceAnchor,
                                                       identifier: node.traitIdentifier.identifier).visibility
        
        let vtableDeclaration = VarDeclaration(identifier: Expression.Identifier(nameOfVtableInstance),
                                               explicitType: Expression.Identifier(traitType.nameOfVtableType),
                                               expression: initializer,
                                               storage: .staticStorage,
                                               isMutable: false,
                                               visibility: visibility)
        resultArr.append(vtableDeclaration)
        
        return Seq(sourceAnchor: node.sourceAnchor, children: resultArr)
    }
}
