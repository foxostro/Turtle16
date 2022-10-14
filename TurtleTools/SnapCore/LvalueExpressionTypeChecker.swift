//
//  LvalueExpressionTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

// Evaluates the expression type in an lvalue context.
public class LvalueExpressionTypeChecker: NSObject {
    public let symbols: SymbolTable
    public let functionsToCompile: FunctionsToCompile!
    
    public init(symbols: SymbolTable = SymbolTable(), functionsToCompile: FunctionsToCompile? = nil) {
        self.symbols = symbols
        self.functionsToCompile = functionsToCompile
    }
        
    func rvalueContext() -> RvalueExpressionTypeChecker {
        return RvalueExpressionTypeChecker(symbols: symbols, functionsToCompile: functionsToCompile)
    }
    
    @discardableResult public func check(expression: Expression) throws -> SymbolType? {
        switch expression {
        case let identifier as Expression.Identifier:
            return try check(identifier: identifier)
        case let expr as Expression.Subscript:
            return try check(subscript: expr)
        case let expr as Expression.Get:
            return try check(get: expr)
        case let expr as Expression.Bitcast:
            if let _ = try check(expression: expr.expr) {
                let result = try rvalueContext().check(expression: expr.targetType)
                return result
            }
            else {
                return nil
            }
        case let expr as Expression.GenericTypeApplication:
            return try check(genericTypeApplication: expr)
        default:
            return nil
        }
    }
        
    public func check(identifier expr: Expression.Identifier) throws -> SymbolType? {
        return try rvalueContext().check(identifier: expr)
    }
    
    public func check(subscript expr: Expression.Subscript) throws -> SymbolType? {
        return try rvalueContext().check(subscript: expr)
    }
    
    public func check(get expr: Expression.Get) throws -> SymbolType? {
        let name = expr.member.identifier
        let resultType = try rvalueContext().check(expression: expr.expr)
        switch resultType {
        case .array:
            if name == "count" {
                return nil
            }
        case .constDynamicArray, .dynamicArray:
            if name == "count" {
                return nil
            }
        case .constStructType(let typ), .structType(let typ):
            if let symbol = typ.symbols.maybeResolve(identifier: name) {
                return symbol.type
            }
        case .constPointer(let typ), .pointer(let typ):
            if name == "pointee" {
                return typ
            } else {
                switch typ {
                case .array, .constDynamicArray, .dynamicArray:
                    if name == "count" {
                        return nil
                    }
                case .constStructType(let b):
                    if let symbol = b.symbols.maybeResolve(identifier: name) {
                        return symbol.type.correspondingConstType
                    }
                case .structType(let b):
                    if let symbol = b.symbols.maybeResolve(identifier: name) {
                        return symbol.type
                    }
                default:
                    break
                }
            }
        default:
            break
        }
        throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(resultType)' has no member `\(name)'")
    }
    
    public func check(genericTypeApplication expr: Expression.GenericTypeApplication) throws -> SymbolType? {
        return try rvalueContext().check(genericTypeApplication: expr)
    }
}
