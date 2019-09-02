//
//  AssemblerScanner.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerScanner: TurtleScanner {
    struct Rule {
        let pattern: String
        let emit: (AssemblerScanner, String) -> Token?
    }
    
    let rules: [Rule] = [
        Rule(pattern: "\n") {
            let token = TokenNewline(lineNumber: $0.lineNumber, lexeme: $1)
            $0.lineNumber += 1
            return token
        },
        Rule(pattern: "((#)|(//))") {(scanner: AssemblerScanner, lexeme: String) in
            scanner.advanceToNewline()
            return nil
        },
        Rule(pattern: ",") {
            TokenComma(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: ":") {
            TokenColon(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "NOP\\b") {
            TokenNOP(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "CMP\\b") {
            TokenCMP(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "HLT\\b") {
            TokenHLT(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "JMP\\b") {
            TokenJMP(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "JC\\b") {
            TokenJC(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "ADD\\b") {
            TokenADD(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "LI\\b") {
            TokenLI(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "MOV\\b") {
            TokenMOV(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "STORE\\b") {
            TokenSTORE(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "LOAD\\b") {
            TokenLOAD(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[ABCDEMXY]\\b") {
            TokenRegister(lineNumber: $0.lineNumber, lexeme: $1, literal: $1)
        },
        Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+\\b") {
            TokenIdentifier(lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[-]{0,1}[0-9]+\\b") {
            let scanner = Scanner(string: $1)
            var number: Int = 0
            var result = scanner.scanInt(&number)
            assert(result)
            return TokenNumber(lineNumber: $0.lineNumber, lexeme: $1, literal: number)
        },
        Rule(pattern: "\\$[0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($1.dropFirst()))
            var number: UInt32 = 0
            var result = scanner.scanHexInt32(&number)
            assert(result)
            return TokenNumber(lineNumber: $0.lineNumber, lexeme: $1, literal: Int(number))
        },
        Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($1))
            var number: UInt32 = 0
            var result = scanner.scanHexInt32(&number)
            assert(result)
            return TokenNumber(lineNumber: $0.lineNumber, lexeme: $1, literal: Int(number))
        },
        Rule(pattern: "[ \t]+") {(scanner: AssemblerScanner, lexeme: String) in
            nil
        }
    ]
    
    public private(set) var tokens: [Token] = []
    var lineNumber = 1
    
    public func scanTokens() throws {
        while !isAtEnd {
            try scanToken()
        }
        tokens.append(TokenEOF(lineNumber: lineNumber, lexeme: ""))
    }
    
    public func scanToken() throws {
        for rule in rules {
            if let lexeme = match(pattern: rule.pattern) {
                if let token = rule.emit(self, lexeme) {
                    tokens.append(token)
                }
                return
            }
        }
        
        throw unexpectedCharacterError(peek()!)
    }
    
    func unexpectedCharacterError(_ character: String) -> AssemblerError {
        return AssemblerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}
