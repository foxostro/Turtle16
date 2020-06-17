//
//  Return.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class Return: AbstractSyntaxTreeNode {
    public let token: TokenReturn
    public let expression: Expression?
    
    public required init(token: TokenReturn, expression: Expression?) {
        self.token = token
        self.expression = expression
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? Return else { return false }
        guard token == rhs.token else { return false }
        guard expression == rhs.expression else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(token)
        hasher.combine(expression)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: expression=\n%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      expression?.makeIndentedDescription(depth: depth + 1) ?? "nil")
    }
}
