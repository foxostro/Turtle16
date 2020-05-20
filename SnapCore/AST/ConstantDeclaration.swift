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
        guard let rhs = rhs as? ConstantDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard expression == rhs.expression else { return false }
        return super.isEqual(rhs)
    }
}

public func ==(lhs: ConstantDeclaration, rhs: ConstantDeclaration) -> Bool {
    return lhs.isEqual(rhs)
}
