//
//  ConstantDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class ConstantDeclaration: AbstractSyntaxTreeNode {
    public let identifier: TokenIdentifier
    public let expression: Expression
    
    public required init(identifier: TokenIdentifier, expression: Expression) {
        self.identifier = identifier
        self.expression = expression
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ConstantDeclaration else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard identifier == rhs.identifier else { return false }
        guard expression == rhs.expression else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(expression)
        return hasher.finalize()
    }
}
