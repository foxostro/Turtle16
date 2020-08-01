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
            Rule(pattern: "\n") {
                return TokenNewline(sourceAnchor: $0)
            },
            Rule(pattern: "((#)|(//))") {[weak self] _ in
                self!.advanceToNewline()
                return nil
            },
            Rule(pattern: ",") {
                TokenComma(sourceAnchor: $0)
            },
            Rule(pattern: ":") {
                TokenColon(sourceAnchor: $0)
            },
            Rule(pattern: ";") {
                TokenSemicolon(sourceAnchor: $0)
            },
            Rule(pattern: "->") {
                TokenArrow(sourceAnchor: $0)
            },
            Rule(pattern: "==") {
                TokenOperator(sourceAnchor: $0, op: .eq)
            },
            Rule(pattern: "!=") {
                TokenOperator(sourceAnchor: $0, op: .ne)
            },
            Rule(pattern: "<=") {
                TokenOperator(sourceAnchor: $0, op: .le)
            },
            Rule(pattern: ">=") {
                TokenOperator(sourceAnchor: $0, op: .ge)
            },
            Rule(pattern: "<") {
                TokenOperator(sourceAnchor: $0, op: .lt)
            },
            Rule(pattern: ">") {
                TokenOperator(sourceAnchor: $0, op: .gt)
            },
            Rule(pattern: "=") {
                TokenEqual(sourceAnchor: $0)
            },
            Rule(pattern: "\\+") {
                TokenOperator(sourceAnchor: $0, op: .plus)
            },
            Rule(pattern: "-") {
                TokenOperator(sourceAnchor: $0, op: .minus)
            },
            Rule(pattern: "\\*") {
                TokenOperator(sourceAnchor: $0, op: .multiply)
            },
            Rule(pattern: "/") {
                TokenOperator(sourceAnchor: $0, op: .divide)
            },
            Rule(pattern: "%") {
                TokenOperator(sourceAnchor: $0, op: .modulus)
            },
            Rule(pattern: "as") {
                TokenAs(sourceAnchor: $0)
            },
            Rule(pattern: "\\(") {
                TokenParenLeft(sourceAnchor: $0)
            },
            Rule(pattern: "\\)") {
                TokenParenRight(sourceAnchor: $0)
            },
            Rule(pattern: "\\{") {
                TokenCurlyLeft(sourceAnchor: $0)
            },
            Rule(pattern: "\\}") {
                TokenCurlyRight(sourceAnchor: $0)
            },
            Rule(pattern: "\\[") {
                TokenSquareBracketLeft(sourceAnchor: $0)
            },
            Rule(pattern: "\\]") {
                TokenSquareBracketRight(sourceAnchor: $0)
            },
            Rule(pattern: "_") {
                TokenUnderscore(sourceAnchor: $0)
            },
            Rule(pattern: "let") {
                TokenLet(sourceAnchor: $0)
            },
            Rule(pattern: "return") {
                TokenReturn(sourceAnchor: $0)
            },
            Rule(pattern: "var") {
                TokenVar(sourceAnchor: $0)
            },
            Rule(pattern: "if") {
                TokenIf(sourceAnchor: $0)
            },
            Rule(pattern: "else") {
                TokenElse(sourceAnchor: $0)
            },
            Rule(pattern: "while") {
                TokenWhile(sourceAnchor: $0)
            },
            Rule(pattern: "for") {
                TokenFor(sourceAnchor: $0)
            },
            Rule(pattern: "static") {
                TokenStatic(sourceAnchor: $0)
            },
            Rule(pattern: "func") {
                TokenFunc(sourceAnchor: $0)
            },
            Rule(pattern: "u8") {
                TokenType(sourceAnchor: $0, type: .u8)
            },
            Rule(pattern: "u16") {
                TokenType(sourceAnchor: $0, type: .u16)
            },
            Rule(pattern: "bool") {
                TokenType(sourceAnchor: $0, type: .bool)
            },
            Rule(pattern: "void") {
                TokenType(sourceAnchor: $0, type: .void)
            },
            Rule(pattern: "true") {
                TokenBoolean(sourceAnchor: $0, literal: true)
            },
            Rule(pattern: "false") {
                TokenBoolean(sourceAnchor: $0, literal: false)
            },
            Rule(pattern: "\".*\"") {[weak self] in 
                TokenLiteralString(sourceAnchor: $0, literal: self!.interpretQuotedString(lexeme: String($0.text)))
            },
            Rule(pattern: "[a-zA-Z_][a-zA-Z0-9_]*") {
                TokenIdentifier(sourceAnchor: $0)
            },
            Rule(pattern: "[0-9]+\\b") {
                let scanner = Scanner(string: String($0.text))
                var number: Int = 0
                let result = scanner.scanInt(&number)
                assert(result)
                return TokenNumber(sourceAnchor: $0, literal: number)
            },
            Rule(pattern: "\\$[0-9a-fA-F]+\\b") {
                let scanner = Scanner(string: String($0.text.dropFirst()))
                var number: UInt32 = 0
                let result = scanner.scanHexInt32(&number)
                assert(result)
                return TokenNumber(sourceAnchor: $0, literal: Int(number))
            },
            Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {
                let scanner = Scanner(string: String($0.text))
                var number: UInt32 = 0
                let result = scanner.scanHexInt32(&number)
                assert(result)
                return TokenNumber(sourceAnchor: $0, literal: Int(number))
            },
            Rule(pattern: "0b[01]+\\b") {
                let scanner = Scanner(string: String($0.text))
                var number = 0
                let result = scanner.scanBinaryInt(&number)
                assert(result)
                return TokenNumber(sourceAnchor: $0, literal: number)
            },
            Rule(pattern: "'.'") {
                let number = Int(String($0.text).split(separator: "'").first!.unicodeScalars.first!.value)
                return TokenNumber(sourceAnchor: $0, literal: number)
            },
            Rule(pattern: "[ \t]+") {_ in
                nil
            }
        ]
    }
    
    func interpretQuotedString(lexeme: String) -> String {
        var result = String(lexeme.dropFirst().dropLast())
        let map = ["\0" : "\\0",
                   "\t" : "\\t",
                   "\n" : "\\n",
                   "\r" : "\\r",
                   "\"" : "\\\"",
                   "\'" : "\\\'",
                   "\\" : "\\\\"]
        for (entity, description) in map {
            result = result.replacingOccurrences(of: description, with: entity)
        }
        return result
    }
}
