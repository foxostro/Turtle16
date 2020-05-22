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
    public var expression: Expression {
        children.first! as! Expression
    }
    
    public required init(identifier: TokenIdentifier, expression: Expression) {
        self.identifier = identifier
        super.init(children: [expression])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ConstantDeclaration else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard identifier == rhs.identifier else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
