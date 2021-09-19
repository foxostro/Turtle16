//
//  StructMemberFunctionCallMatcher.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class StructMemberFunctionCallMatcher: NSObject {
    public struct Match {
        public let callExpr: Expression.Call
        public let getExpr: Expression.Get
        public let fnType: FunctionType
        public let firstArgumentType: SymbolType
    }
    
    public let expr: Expression.Call
    public let typeChecker: RvalueExpressionTypeChecker
    
    public init(call expr: Expression.Call, typeChecker: RvalueExpressionTypeChecker) {
        self.expr = expr
        self.typeChecker = typeChecker
    }
    
    public func match() throws -> Match? {
        guard let typ = try getFunctionType() else {
            return nil
        }
        
        guard typ.arguments.count == expr.arguments.count+1 else {
            return nil
        }
        
        guard let getExpr = expr.callee as? Expression.Get else {
            return nil
        }
        
        guard let firstArgumentType = typ.arguments.first else {
            return nil
        }
        
        let rtype = try typeChecker.check(expression: getExpr.expr)
        let status = typeChecker.convertBetweenTypes(ltype: firstArgumentType,
                                                     rtype: rtype,
                                                     sourceAnchor: expr.sourceAnchor,
                                                     messageWhenNotConvertible: "",
                                                     isExplicitCast: false)
        switch status {
        case .acceptable:
            return Match(callExpr: expr,
                         getExpr: getExpr,
                         fnType: typ,
                         firstArgumentType: typ.arguments.first!)
            
        case .unacceptable:
            return nil
        }
    }
    
    func getFunctionType() throws -> FunctionType? {
        let result: FunctionType?
        let calleeType = try typeChecker.check(expression: expr.callee)
        switch calleeType {
        case .function(let typ), .pointer(.function(let typ)), .constPointer(.function(let typ)):
            result = typ
            
        default:
            result = nil
        }
        return result
    }
}
