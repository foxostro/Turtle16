//
//  SnapLexer.swift
//  Snap
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapLexer: Lexer {
    public required init(_ string: String, _ url: URL? = nil) {
        super.init(string, url)
        self.rules = [
            Rule(pattern: "\n") {
                return TokenNewline(sourceAnchor: $0)
            },
            Rule(pattern: "((#)|(//))") {[weak self] _ in
                self!.advanceToNewline()
                return nil
            },
            Rule(pattern: "\\.\\.") {
                TokenDoubleDot(sourceAnchor: $0)
            },
            Rule(pattern: "\\.") {
                TokenDot(sourceAnchor: $0)
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
            Rule(pattern: "!") {
                TokenOperator(sourceAnchor: $0, op: .bang)
            },
            Rule(pattern: "<=") {
                TokenOperator(sourceAnchor: $0, op: .le)
            },
            Rule(pattern: ">=") {
                TokenOperator(sourceAnchor: $0, op: .ge)
            },
            Rule(pattern: "<<") {
                TokenOperator(sourceAnchor: $0, op: .leftDoubleAngle)
            },
            Rule(pattern: "<") {
                TokenOperator(sourceAnchor: $0, op: .lt)
            },
            Rule(pattern: ">>") {
                TokenOperator(sourceAnchor: $0, op: .rightDoubleAngle)
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
                TokenOperator(sourceAnchor: $0, op: .star)
            },
            Rule(pattern: "/") {
                TokenOperator(sourceAnchor: $0, op: .divide)
            },
            Rule(pattern: "%") {
                TokenOperator(sourceAnchor: $0, op: .modulus)
            },
            Rule(pattern: "&&") {
                TokenOperator(sourceAnchor: $0, op: .doubleAmpersand)
            },
            Rule(pattern: "&") {
                TokenOperator(sourceAnchor: $0, op: .ampersand)
            },
            Rule(pattern: "\\|\\|") {
                TokenOperator(sourceAnchor: $0, op: .doublePipe)
            },
            Rule(pattern: "\\|") {
                TokenOperator(sourceAnchor: $0, op: .pipe)
            },
            Rule(pattern: "\\^") {
                TokenOperator(sourceAnchor: $0, op: .caret)
            },
            Rule(pattern: "~") {
                TokenOperator(sourceAnchor: $0, op: .tilde)
            },
            Rule(pattern: "bitcastAs\\b") {
                TokenBitcastAs(sourceAnchor: $0)
            },
            Rule(pattern: "as\\b") {
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
            Rule(pattern: "_(?![a-zA-Z0-9_])") {
                TokenUnderscore(sourceAnchor: $0)
            },
            Rule(pattern: "typealias\\b") {
                TokenTypealias(sourceAnchor: $0)
            },
            Rule(pattern: "let\\b") {
                TokenLet(sourceAnchor: $0)
            },
            Rule(pattern: "return\\b") {
                TokenReturn(sourceAnchor: $0)
            },
            Rule(pattern: "var\\b") {
                TokenVar(sourceAnchor: $0)
            },
            Rule(pattern: "if\\b") {
                TokenIf(sourceAnchor: $0)
            },
            Rule(pattern: "else\\b") {
                TokenElse(sourceAnchor: $0)
            },
            Rule(pattern: "while\\b") {
                TokenWhile(sourceAnchor: $0)
            },
            Rule(pattern: "for\\b") {
                TokenFor(sourceAnchor: $0)
            },
            Rule(pattern: "in\\b") {
                TokenIn(sourceAnchor: $0)
            },
            Rule(pattern: "static\\b") {
                TokenStatic(sourceAnchor: $0)
            },
            Rule(pattern: "func\\b") {
                TokenFunc(sourceAnchor: $0)
            },
            Rule(pattern: "struct\\b") {
                TokenStruct(sourceAnchor: $0)
            },
            Rule(pattern: "trait\\b") {
                TokenTrait(sourceAnchor: $0)
            },
            Rule(pattern: "const\\b") {
                TokenConst(sourceAnchor: $0)
            },
            Rule(pattern: "impl\\b") {
                TokenImpl(sourceAnchor: $0)
            },
            Rule(pattern: "is\\b") {
                TokenIs(sourceAnchor: $0)
            },
            Rule(pattern: "match\\b") {
                TokenMatch(sourceAnchor: $0)
            },
            Rule(pattern: "public\\b") {
                TokenPublic(sourceAnchor: $0)
            },
            Rule(pattern: "private\\b") {
                TokenPrivate(sourceAnchor: $0)
            },
            Rule(pattern: "assert\\b") {
                TokenAssert(sourceAnchor: $0)
            },
            Rule(pattern: "test\\b") {
                TokenTest(sourceAnchor: $0)
            },
            Rule(pattern: "u8\\b") {
                TokenType(sourceAnchor: $0, type: .arithmeticType(.mutableInt(.u8)))
            },
            Rule(pattern: "u16\\b") {
                TokenType(sourceAnchor: $0, type: .arithmeticType(.mutableInt(.u16)))
            },
            Rule(pattern: "i8\\b") {
                TokenType(sourceAnchor: $0, type: .arithmeticType(.mutableInt(.i8)))
            },
            Rule(pattern: "i16\\b") {
                TokenType(sourceAnchor: $0, type: .arithmeticType(.mutableInt(.i16)))
            },
            Rule(pattern: "bool\\b") {
                TokenType(sourceAnchor: $0, type: .bool(.mutableBool))
            },
            Rule(pattern: "void\\b") {
                TokenType(sourceAnchor: $0, type: .void)
            },
            Rule(pattern: "true\\b") {
                TokenBoolean(sourceAnchor: $0, literal: true)
            },
            Rule(pattern: "false\\b") {
                TokenBoolean(sourceAnchor: $0, literal: false)
            },
            Rule(pattern: "undefined\\b") {
                TokenUndefined(sourceAnchor: $0)
            },
            Rule(pattern: "import\\b") {
                TokenImport(sourceAnchor: $0)
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
                var number: UInt64 = 0
                let result = scanner.scanHexInt64(&number)
                assert(result)
                return TokenNumber(sourceAnchor: $0, literal: Int(number))
            },
            Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {
                let scanner = Scanner(string: String($0.text))
                var number: UInt64 = 0
                let result = scanner.scanHexInt64(&number)
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
            Rule(pattern: "'\\\\.'") {[weak self] in
                let string = self!.interpretQuotedString(lexeme: String($0.text))
                let number = Int(string.split(separator: "'").first!.unicodeScalars.first!.value)
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
