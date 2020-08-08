//
//  AssemblerLexer.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class AssemblerLexer: Lexer {
    public required init(withString string: String) {
        super.init(withString: string)
        self.rules = [
            Rule(pattern: "\n") {
                TokenNewline(sourceAnchor: $0)
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
            Rule(pattern: "A\\b") {
                TokenRegister(sourceAnchor: $0, literal: .A)
            },
            Rule(pattern: "B\\b") {
                TokenRegister(sourceAnchor: $0, literal: .B)
            },
            Rule(pattern: "C\\b") {
                TokenRegister(sourceAnchor: $0, literal: .C)
            },
            Rule(pattern: "D\\b") {
                TokenRegister(sourceAnchor: $0, literal: .D)
            },
            Rule(pattern: "E\\b") {
                TokenRegister(sourceAnchor: $0, literal: .E)
            },
            Rule(pattern: "G\\b") {
                TokenRegister(sourceAnchor: $0, literal: .G)
            },
            Rule(pattern: "H\\b") {
                TokenRegister(sourceAnchor: $0, literal: .H)
            },
            Rule(pattern: "M\\b") {
                TokenRegister(sourceAnchor: $0, literal: .M)
            },
            Rule(pattern: "P\\b") {
                TokenRegister(sourceAnchor: $0, literal: .P)
            },
            Rule(pattern: "U\\b") {
                TokenRegister(sourceAnchor: $0, literal: .U)
            },
            Rule(pattern: "V\\b") {
                TokenRegister(sourceAnchor: $0, literal: .V)
            },
            Rule(pattern: "X\\b") {
                TokenRegister(sourceAnchor: $0, literal: .X)
            },
            Rule(pattern: "Y\\b") {
                TokenRegister(sourceAnchor: $0, literal: .Y)
            },
            Rule(pattern: "_\\b") {
                TokenRegister(sourceAnchor: $0, literal: .NONE)
            },
            Rule(pattern: "=") {
                TokenEqual(sourceAnchor: $0)
            },
            Rule(pattern: "let") {
                TokenLet(sourceAnchor: $0)
            },
            Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+\\b") {
                TokenIdentifier(sourceAnchor: $0)
            },
            Rule(pattern: "[-]{0,1}[0-9]+\\b") {
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
}
