//
//  TokenOperator.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class TokenOperator : Token {
    public enum Operator { case eq, plus, minus, multiply, divide, modulus }
    public let op: Operator
    
    public init(lineNumber: Int, lexeme: String, op: Operator) {
        self.op = op
        super.init(lineNumber: lineNumber, lexeme: lexeme)
    }
    
    public override var description: String {
        return String(format: "<%@: lineNumber=%d, lexeme=\"%@\", op=%@>",
                      String(describing: type(of: self)),
                      lineNumber, lexeme,
                      String(describing: op))
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? TokenOperator else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard op == rhs.op else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(op)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
