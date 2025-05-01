//
//  LvalueExpressionTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Evaluates the expression type in an lvalue context.
public final class LvalueExpressionTypeChecker {
    private let symbols: Env
    private let staticStorageFrame: Frame
    private let memoryLayoutStrategy: MemoryLayoutStrategy

    public init(
        symbols: Env = Env(),
        staticStorageFrame: Frame = Frame(),
        memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) {
        self.symbols = symbols
        self.staticStorageFrame = staticStorageFrame
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }

    func rvalueContext() -> RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
    }

    @discardableResult public func check(expression: Expression) throws -> SymbolType? {
        switch expression {
        case let identifier as Identifier:
            return try check(identifier: identifier)
        case let expr as Subscript:
            return try check(subscript: expr)
        case let expr as Get:
            return try check(get: expr)
        case let expr as Bitcast:
            guard (try check(expression: expr.expr)) != nil else {
                return nil
            }
            let result = try rvalueContext().check(expression: expr.targetType)
            return result
        case let expr as GenericTypeApplication:
            return try check(genericTypeApplication: expr)
        case let expr as Eseq:
            return try check(eseq: expr)
        default:
            return nil
        }
    }

    public func check(identifier expr: Identifier) throws -> SymbolType? {
        try rvalueContext().check(identifier: expr)
    }

    public func check(subscript expr: Subscript) throws -> SymbolType? {
        try rvalueContext().check(subscript: expr)
    }

    public func check(get expr: Get) throws -> SymbolType? {
        if expr.member as? Identifier != nil {
            return try check(getIdent: expr)
        } else if expr.member as? GenericTypeApplication != nil {
            return nil
        } else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "unsupported get expression `\(expr)'"
            )
        }
    }

    private func check(getIdent expr: Get) throws -> SymbolType? {
        let member = expr.member as! Identifier
        let name = member.identifier
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
        throw CompilerError(
            sourceAnchor: expr.sourceAnchor,
            message: "value of type `\(resultType)' has no member `\(name)'"
        )
    }

    public func check(genericTypeApplication expr: GenericTypeApplication) throws -> SymbolType? {
        try rvalueContext().check(genericTypeApplication: expr)
    }

    public func check(eseq: Eseq) throws -> SymbolType? {
        guard let expr = eseq.children.last else {
            return nil
        }
        return try check(expression: expr)
    }
}
