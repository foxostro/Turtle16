//
//  TypeContextTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/7/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

// Evaluates the expression type in a Type context.
public class TypeContextTypeChecker: RvalueExpressionTypeChecker {
    public override func check(identifier expr: Expression.Identifier) throws -> SymbolType {
        return try symbols.resolveType(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier)
    }
}
