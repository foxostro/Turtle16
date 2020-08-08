//
//  VarDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class VarDeclaration: AbstractSyntaxTreeNode {
    public let identifier: Expression.Identifier
    public let explicitType: SymbolType?
    public let expression: Expression
    public let storage: SymbolStorage
    public let isMutable: Bool
    
    public convenience init(identifier: Expression.Identifier,
                            explicitType: SymbolType?,
                            expression: Expression,
                            storage: SymbolStorage,
                            isMutable: Bool) {
        self.init(sourceAnchor: nil,
                  identifier: identifier,
                  explicitType: explicitType,
                  expression: expression,
                  storage: storage,
                  isMutable: isMutable)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         identifier: Expression.Identifier,
                         explicitType: SymbolType?,
                         expression: Expression,
                         storage: SymbolStorage,
                         isMutable: Bool) {
        self.identifier = identifier
        self.explicitType = explicitType
        self.storage = storage
        self.isMutable = isMutable
        self.expression = expression
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard super.isEqual(rhs) else {
            return false
        }
        guard let rhs = rhs as? VarDeclaration else {
            return false
        }
        guard identifier == rhs.identifier else {
            return false
        }
        guard explicitType == rhs.explicitType else {
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
        hasher.combine(explicitType)
        hasher.combine(storage)
        hasher.combine(isMutable)
        hasher.combine(expression)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: identifier=%@, explicitType=%@, storage=%@, isMutable=%@, expression=%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier.makeIndentedDescription(depth: depth + 1),
                      explicitType?.description ?? "nil",
                      String(describing: storage),
                      isMutable ? "true" : "false",
                      expression.makeIndentedDescription(depth: depth + 1))
    }
}
