//
//  TokenOperator.swift
//  TurtleCore
//
//  Created by Andrew Fox on 5/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class TokenOperator : Token {
    public enum Operator {
        case eq, ne, lt, gt, le, ge, plus, minus, star, divide, modulus, ampersand, doubleAmpersand, pipe, doublePipe, bang, caret, leftDoubleAngle, rightDoubleAngle, tilde
        
        public var description: String {
            switch self {
            case .eq: return "=="
            case .ne: return "!="
            case .lt: return "<"
            case .gt: return ">"
            case .le: return "<="
            case .ge: return ">="
            case .plus: return "+"
            case .minus: return "-"
            case .star: return "*"
            case .divide: return "/"
            case .modulus: return "%"
            case .ampersand: return "&"
            case .doubleAmpersand: return "&&"
            case .pipe: return "|"
            case .doublePipe: return "||"
            case .bang: return "!"
            case .caret: return "^"
            case .leftDoubleAngle: return "<<"
            case .rightDoubleAngle: return ">>"
            case .tilde: return "~"
            }
        }
    }
    public let op: Operator
    
    public convenience init(op: Operator) {
        self.init(sourceAnchor: nil, op: op)
    }
    
    public init(sourceAnchor: SourceAnchor?, op: Operator) {
        self.op = op
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override var description: String {
        return String(format: "<%@: sourceAnchor=%@, lexeme=\"%@\", op=%@>",
                      String(describing: type(of: self)),
                      String(describing: sourceAnchor),
                      lexeme,
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
