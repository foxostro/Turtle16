//
//  AssemblerLexer.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerLexer: Lexer {
    public required init(withString string: String) {
        super.init(withString: string)
        self.rules = [
            Rule(pattern: "\n") {
                let token = TokenNewline(lineNumber: self.lineNumber, lexeme: $0)
                self.lineNumber += 1
                return token
            },
            Rule(pattern: "((#)|(//))") {(lexeme: String) in
                self.advanceToNewline()
                return nil
            },
            Rule(pattern: ",") {
                TokenComma(lineNumber: self.lineNumber, lexeme: $0)
            },
            Rule(pattern: ":") {
                TokenColon(lineNumber: self.lineNumber, lexeme: $0)
            },
            Rule(pattern: "A\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .A)
            },
            Rule(pattern: "B\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .B)
            },
            Rule(pattern: "C\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .C)
            },
            Rule(pattern: "D\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .D)
            },
            Rule(pattern: "E\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .E)
            },
            Rule(pattern: "G\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .G)
            },
            Rule(pattern: "H\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .H)
            },
            Rule(pattern: "M\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .M)
            },
            Rule(pattern: "P\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .P)
            },
            Rule(pattern: "U\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .U)
            },
            Rule(pattern: "V\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .V)
            },
            Rule(pattern: "X\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .X)
            },
            Rule(pattern: "Y\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .Y)
            },
            Rule(pattern: "_\\b") {
                TokenRegister(lineNumber: self.lineNumber, lexeme: $0, literal: .NONE)
            },
            Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+\\b") {
                TokenIdentifier(lineNumber: self.lineNumber, lexeme: $0)
            },
            Rule(pattern: "[-]{0,1}[0-9]+\\b") {
                let scanner = Scanner(string: $0)
                var number: Int = 0
                let result = scanner.scanInt(&number)
                assert(result)
                return TokenNumber(lineNumber: self.lineNumber, lexeme: $0, literal: number)
            },
            Rule(pattern: "\\$[0-9a-fA-F]+\\b") {
                let scanner = Scanner(string: String($0.dropFirst()))
                var number: UInt32 = 0
                let result = scanner.scanHexInt32(&number)
                assert(result)
                return TokenNumber(lineNumber: self.lineNumber, lexeme: $0, literal: Int(number))
            },
            Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {
                let scanner = Scanner(string: String($0))
                var number: UInt32 = 0
                let result = scanner.scanHexInt32(&number)
                assert(result)
                return TokenNumber(lineNumber: self.lineNumber, lexeme: $0, literal: Int(number))
            },
            Rule(pattern: "'.'") {
                let number = Int(String($0).split(separator: "'").first!.unicodeScalars.first!.value)
                return TokenNumber(lineNumber: self.lineNumber, lexeme: $0, literal: number)
            },
            Rule(pattern: "[ \t]+") {(lexeme: String) in
                nil
            }
        ]
    }
}
