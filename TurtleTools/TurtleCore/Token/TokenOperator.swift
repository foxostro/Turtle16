//
//  TokenOperator.swift
//  TurtleCore
//
//  Created by Andrew Fox on 5/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public final class TokenOperator: Token {
    public enum Operator: String, Hashable, CustomStringConvertible {
        case eq, ne, lt, gt, le, ge, plus, minus, star, divide, modulus, ampersand, doubleAmpersand,
            pipe, doublePipe, bang, caret, leftDoubleAngle, rightDoubleAngle, tilde

        public var name: String { rawValue }

        public var description: String {
            switch self {
            case .eq: "=="
            case .ne: "!="
            case .lt: "<"
            case .gt: ">"
            case .le: "<="
            case .ge: ">="
            case .plus: "+"
            case .minus: "-"
            case .star: "*"
            case .divide: "/"
            case .modulus: "%"
            case .ampersand: "&"
            case .doubleAmpersand: "&&"
            case .pipe: "|"
            case .doublePipe: "||"
            case .bang: "!"
            case .caret: "^"
            case .leftDoubleAngle: "<<"
            case .rightDoubleAngle: ">>"
            case .tilde: "~"
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
        "<\(selfDesc): sourceAnchor=\(sourceAnchorDesc), lexeme=\"\(lexeme)\", op=\(op.name)>"
    }

    public override func isEqual(_ rhs: Token) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard op == rhs.op else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(op)
    }
}
