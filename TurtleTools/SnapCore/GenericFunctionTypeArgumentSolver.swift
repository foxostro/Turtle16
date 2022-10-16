//
//  GenericFunctionTypeArgumentSolver.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/16/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class GenericFunctionTypeArgumentSolver: NSObject {
    public func inferTypeArguments(call expr: Expression.Call,
                                   genericFunctionType generic: Expression.GenericFunctionType,
                                   symbols: SymbolTable) throws -> [SymbolType] {
        guard expr.arguments.count == generic.arguments.count else {
            throw failedToInferError(expr, generic)
        }
        
        var substitutions: [Expression.Identifier : [Expression]] = [:]
        for typeArgument in generic.typeArguments {
            for pair in zip(expr.arguments, generic.arguments) {
                if let inferredType = inferTypeArgument(concreteArgument: pair.0,
                                                        genericArgument: pair.1,
                                                        solvingFor: typeArgument) {
                    if substitutions[typeArgument] == nil {
                        substitutions[typeArgument] = []
                    }
                    substitutions[typeArgument]!.append(inferredType)
                }
            }
        }
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        
        let result = try generic.typeArguments.map { typeArgument in
            guard let subst = substitutions[typeArgument] else {
                throw failedToInferError(expr, generic)
            }
            assert(subst.count > 0)
            let types = try subst.map {
                try typeChecker.check(expression: $0).correspondingMutableType
            }
            guard types.allSatisfy({$0 == types.first}) else {
                throw failedToInferError(expr, generic)
            }
            return types.first!
        }
        
        return result
    }
    
    public func inferTypeArgument(concreteArgument: Expression,
                                  genericArgument: Expression,
                                  solvingFor typeArgument: Expression.Identifier) -> Expression? {
        guard let expr = inferTypeArgumentInner(concreteArgument: concreteArgument,
                                                genericArgument: genericArgument,
                                                solvingFor: typeArgument) else {
            return nil
        }
        return Expression.TypeOf(expr)
    }
    
    fileprivate func inferTypeArgumentInner(concreteArgument: Expression,
                                            genericArgument: Expression,
                                            solvingFor typeArgument: Expression.Identifier) -> Expression? {
        switch genericArgument {
        case let expr as Expression.Identifier:
            if expr.identifier == typeArgument.identifier {
                return concreteArgument
            }
            
        case let expr as Expression.ConstType:
            if let r = inferTypeArgumentInner(concreteArgument: concreteArgument,
                                              genericArgument: expr.typ,
                                              solvingFor: typeArgument) {
                return Expression.ConstType(r)
            }
            
        case let expr as Expression.PointerType:
            if let r = inferTypeArgumentInner(concreteArgument: concreteArgument,
                                              genericArgument: expr.typ,
                                              solvingFor: typeArgument) {
                return Expression.PointerType(r)
            }
            
        case let expr as Expression.DynamicArrayType:
            if let r = inferTypeArgumentInner(concreteArgument: concreteArgument,
                                              genericArgument: expr.elementType,
                                              solvingFor: typeArgument) {
                return Expression.DynamicArrayType(r)
            }
            
        case let expr as Expression.ArrayType:
            if let r = inferTypeArgumentInner(concreteArgument: concreteArgument,
                                              genericArgument: expr.elementType,
                                              solvingFor: typeArgument) {
                return Expression.ArrayType(count: expr.count, elementType: r)
            }

        default:
            break
        }
        
        return nil
    }
    
    fileprivate func failedToInferError(_ expr: Expression.Call, _ generic: Expression.GenericFunctionType) -> CompilerError {
        return CompilerError(sourceAnchor: expr.sourceAnchor,
                             message: "failed to infer the type arguments of the generic function `\(generic.description)' in a call expression")
    }
}
