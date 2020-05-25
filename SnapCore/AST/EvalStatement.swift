//
//  EvalStatement.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class EvalStatement: AbstractSyntaxTreeNode {
    public let token: TokenEval
    public var expression: Expression {
        return children.first! as! Expression
    }
    
    public required init(token: TokenEval, expression: Expression) {
        self.token = token
        super.init(children: [expression])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? EvalStatement else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard token == rhs.token else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(token)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
