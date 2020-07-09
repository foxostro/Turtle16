//
//  VarDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class VarDeclaration: AbstractSyntaxTreeNode {
    public let storage: SymbolStorage
    public let isMutable: Bool
    public let identifier: TokenIdentifier
    public let expression: Expression
    
    public required init(identifier: TokenIdentifier,
                         expression: Expression,
                         storage: SymbolStorage,
                         isMutable: Bool) {
        self.identifier = identifier
        self.storage = storage
        self.isMutable = isMutable
        self.expression = expression
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? VarDeclaration else {
            return false
        }
        guard identifier == rhs.identifier else {
            return false
        }
        guard isMutable == rhs.isMutable else {
            return false
        }
        guard storage == rhs.storage else {
            return false
        }
        guard expression == rhs.expression else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(storage)
        hasher.combine(isMutable)
        hasher.combine(expression)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: identifier=\"%@\", storage=%@, isMutable=%@, expression=%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier.lexeme,
                      String(describing: storage),
                      isMutable ? "true" : "false",
                      expression.makeIndentedDescription(depth: depth + 1))
    }
}
