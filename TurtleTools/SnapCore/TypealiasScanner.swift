//
//  TypealiasScanner.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public struct TypealiasScanner {
    private let symbols: Env

    public init(_ symbols: Env) {
        self.symbols = symbols
    }

    public func compile(_ node: Typealias) throws {
        guard !symbols.exists(identifier: node.lexpr.identifier) else {
            throw CompilerError(
                sourceAnchor: node.lexpr.sourceAnchor,
                message: "typealias redefines existing symbol: `\(node.lexpr.identifier)'"
            )
        }
        guard !symbols.existsAsType(identifier: node.lexpr.identifier) else {
            throw CompilerError(
                sourceAnchor: node.lexpr.sourceAnchor,
                message: "typealias redefines existing type: `\(node.lexpr.identifier)'"
            )
        }
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let symbolType = try typeChecker.check(expression: node.rexpr)
        guard try symbolType.hasModule(symbols) == false else {
            throw CompilerError(
                sourceAnchor: node.rexpr.sourceAnchor,
                message: "invalid use of module type"
            )
        }
        symbols.bind(
            identifier: node.lexpr.identifier,
            symbolType: symbolType,
            visibility: node.visibility
        )

        // Erase the typealias now that we've bound the new type.
    }
}
