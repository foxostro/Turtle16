//
//  GenericFunctionPartialEvaluator.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/8/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

/// Partially evaluate a generic function by applying the specified replacements
/// 
/// Identifiers in the generic function are directly replaced by the expressions
/// to which they evaluate. This works because the language forbids any
/// identifier from shadowing an existing symbol or type.
public class GenericFunctionPartialEvaluator: CompilerPass {
    private let map: [String : Expression]
    
    /// Partially evalute the given generic function
    /// - Parameter replacements: The replacements to apply while partially
    ///   evaluating the function. The replacements must be a sequence of pairs
    ///   where each pair is a (String, Expression.PrimitiveType). The first
    ///   element, the string, is an identifier to replace. The second element
    ///   is the expression which replaces it.
    /// - Returns: The partially evaluated function with replacements applied
    public static func eval<S>(_ ast0: FunctionDeclaration, replacements: S) throws -> FunctionDeclaration  where S : Sequence, S.Element == (String, Expression.PrimitiveType) {
        let replacementMap = Dictionary(uniqueKeysWithValues: replacements)
        let ast1 = try GenericFunctionPartialEvaluator(symbols: nil, map: replacementMap)
            .visit(func: ast0) as! FunctionDeclaration
        return ast1
    }
    
    public init(symbols: SymbolTable?, map: [String : Expression]) {
        self.map = map
        super.init(symbols)
    }
    
    public override func visit(identifier node0: Expression.Identifier) -> Expression? {
        map[node0.identifier] ?? node0
    }
    
}
