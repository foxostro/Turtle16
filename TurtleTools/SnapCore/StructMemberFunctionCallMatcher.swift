//
//  StructMemberFunctionCallMatcher.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public struct StructMemberFunctionCallMatcher {
    public struct Match {
        public let callExpr: Call
        public let getExpr: Get
        public let fnType: FunctionTypeInfo
        public let firstArgumentType: SymbolType
    }

    public let expr: Call
    public let typeChecker: RvalueExpressionTypeChecker

    public init(call expr: Call, typeChecker: RvalueExpressionTypeChecker) {
        self.expr = expr
        self.typeChecker = typeChecker
    }

    public func match() throws -> Match? {
        guard let typ = try getFunctionType() else { return nil }
        guard typ.arguments.count == expr.arguments.count + 1 else { return nil }
        guard let getExpr = expr.callee as? Get else { return nil }
        guard let firstArgumentType = typ.arguments.first else { return nil }

        let rtype = try typeChecker.check(expression: getExpr.expr)
        let status = typeChecker.convertBetweenTypes(
            ltype: firstArgumentType,
            rtype: rtype,
            sourceAnchor: expr.sourceAnchor,
            messageWhenNotConvertible: "",
            isExplicitCast: false
        )
        return switch status {
        case .acceptable:
            Match(
                callExpr: expr,
                getExpr: getExpr,
                fnType: typ,
                firstArgumentType: typ.arguments.first!
            )

        case .unacceptable:
            nil
        }
    }

    func getFunctionType() throws -> FunctionTypeInfo? {
        switch try typeChecker.check(expression: expr.callee) {
        case .function(let typ),
            .pointer(.function(let typ)),
            .constPointer(.function(let typ)):
            typ

        default:
            nil
        }
    }
}
