//
//  SnapLexer.swift
//  Snap
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class SnapLexer: Lexer {
    public required init(withString string: String) {
        super.init(withString: string)
        self.rules = [
            Rule(pattern: "\n") {[weak self] in
                let this = self!
                let token = TokenNewline(lineNumber: this.lineNumber, lexeme: $0)
                this.lineNumber += 1
                return token
            },
            Rule(pattern: "((#)|(//))") {[weak self] (lexeme: String) in
                self!.advanceToNewline()
                return nil
            },
            Rule(pattern: ",") {[weak self] in
                TokenComma(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: ":") {[weak self] in
                TokenColon(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "==") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .eq)
            },
            Rule(pattern: "!=") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .ne)
            },
            Rule(pattern: "<=") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .le)
            },
            Rule(pattern: ">=") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .ge)
            },
            Rule(pattern: "<") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .lt)
            },
            Rule(pattern: ">") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .gt)
            },
            Rule(pattern: "=") {[weak self] in
                TokenEqual(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "\\+") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .plus)
            },
            Rule(pattern: "-") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .minus)
            },
            Rule(pattern: "\\*") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .multiply)
            },
            Rule(pattern: "/") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .divide)
            },
            Rule(pattern: "%") {[weak self] in
                TokenOperator(lineNumber: self!.lineNumber, lexeme: $0, op: .modulus)
            },
            Rule(pattern: "\\(") {[weak self] in
                TokenParenLeft(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "\\)") {[weak self] in
                TokenParenRight(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "\\{") {[weak self] in
                TokenCurlyLeft(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "\\}") {[weak self] in
                TokenCurlyRight(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "let") {[weak self] in
                TokenLet(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "return") {[weak self] in
                TokenReturn(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "var") {[weak self] in
                TokenVar(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "if") {[weak self] in
                TokenIf(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "else") {[weak self] in
                TokenElse(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "while") {[weak self] in
                TokenWhile(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "true") {[weak self] in
                TokenBoolean(lineNumber: self!.lineNumber, lexeme: $0, literal: true)
            },
            Rule(pattern: "false") {[weak self] in
                TokenBoolean(lineNumber: self!.lineNumber, lexeme: $0, literal: false)
            },
            Rule(pattern: "[a-zA-Z_][a-zA-Z0-9_]*") {[weak self] in
                TokenIdentifier(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "[0-9]+\\b") {[weak self] in
                let scanner = Scanner(string: $0)
                var number: Int = 0
                let result = scanner.scanInt(&number)
                assert(result)
                return TokenNumber(lineNumber: self!.lineNumber, lexeme: $0, literal: number)
            },
            Rule(pattern: "\\$[0-9a-fA-F]+\\b") {[weak self] in
                let scanner = Scanner(string: String($0.dropFirst()))
                var number: UInt32 = 0
                let result = scanner.scanHexInt32(&number)
                assert(result)
                return TokenNumber(lineNumber: self!.lineNumber, lexeme: $0, literal: Int(number))
            },
            Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {[weak self] in
                let scanner = Scanner(string: String($0))
                var number: UInt32 = 0
                let result = scanner.scanHexInt32(&number)
                assert(result)
                return TokenNumber(lineNumber: self!.lineNumber, lexeme: $0, literal: Int(number))
            },
            Rule(pattern: "0b[01]+\\b") {[weak self] in
                let scanner = Scanner(string: String($0))
                var number = 0
                let result = scanner.scanBinaryInt(&number)
                assert(result)
                return TokenNumber(lineNumber: self!.lineNumber, lexeme: $0, literal: number)
            },
            Rule(pattern: "'.'") {[weak self] in
                let number = Int(String($0).split(separator: "'").first!.unicodeScalars.first!.value)
                return TokenNumber(lineNumber: self!.lineNumber, lexeme: $0, literal: number)
            },
            Rule(pattern: "[ \t]+") {(lexeme: String) in
                nil
            }
        ]
    }
}
