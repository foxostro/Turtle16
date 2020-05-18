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
            Rule(pattern: "A\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .A)
            },
            Rule(pattern: "B\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .B)
            },
            Rule(pattern: "C\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .C)
            },
            Rule(pattern: "D\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .D)
            },
            Rule(pattern: "E\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .E)
            },
            Rule(pattern: "G\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .G)
            },
            Rule(pattern: "H\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .H)
            },
            Rule(pattern: "M\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .M)
            },
            Rule(pattern: "P\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .P)
            },
            Rule(pattern: "U\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .U)
            },
            Rule(pattern: "V\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .V)
            },
            Rule(pattern: "X\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .X)
            },
            Rule(pattern: "Y\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .Y)
            },
            Rule(pattern: "_\\b") {[weak self] in
                TokenRegister(lineNumber: self!.lineNumber, lexeme: $0, literal: .NONE)
            },
            Rule(pattern: "=") {[weak self] in
                TokenEqual(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "let") {[weak self] in
                TokenLet(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+\\b") {[weak self] in
                TokenIdentifier(lineNumber: self!.lineNumber, lexeme: $0)
            },
            Rule(pattern: "[-]{0,1}[0-9]+\\b") {[weak self] in
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
