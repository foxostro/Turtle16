//
//  DebugConsoleCommandLineLexer.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class DebugConsoleCommandLineLexer: Lexer {
    public required init(_ string: String, _ url: URL? = nil) {
        super.init(string, url)
        self.rules = [
            Rule(pattern: "\n") {
                TokenNewline(sourceAnchor: $0)
            },
            Rule(pattern: ",") {
                TokenComma(sourceAnchor: $0)
            },
            Rule(pattern: ":") {
                TokenColon(sourceAnchor: $0)
            },
            Rule(pattern: "/") {
                TokenForwardSlash(sourceAnchor: $0)
            },
            Rule(pattern: "\".*\"") {[weak self] in
                TokenLiteralString(sourceAnchor: $0, literal: self!.interpretQuotedString(lexeme: String($0.text)))
            },
            Rule(pattern: "[_a-zA-Z][\\-_a-zA-Z0-9]*\\b") {
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
            Rule(pattern: "[ \t]+") {_ in
                nil
            }
        ]
    }
    
    fileprivate func interpretQuotedString(lexeme: String) -> String {
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
