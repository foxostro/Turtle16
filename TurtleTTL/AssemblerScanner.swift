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
            let token = Token(type: .newline, lineNumber: $0.lineNumber, lexeme: $1)
            $0.lineNumber += 1
            return token
        },
        Rule(pattern: "((#)|(//))") {(scanner: AssemblerScanner, lexeme: String) in
            scanner.advanceToNewline()
            return nil
        },
        Rule(pattern: ",") {
            Token(type: .comma, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: ":") {
            Token(type: .colon, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "NOP\\b") {
            Token(type: .nop, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "CMP\\b") {
            Token(type: .cmp, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "HLT\\b") {
            Token(type: .hlt, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "JMP\\b") {
            Token(type: .jmp, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "JC\\b") {
            Token(type: .jc, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "ADD\\b") {
            Token(type: .add, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "LI\\b") {
            Token(type: .li, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "MOV\\b") {
            Token(type: .mov, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "STORE\\b") {
            Token(type: .store, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "LOAD\\b") {
            Token(type: .load, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[ABCDEMXY]\\b") {
            Token(type: .register, lineNumber: $0.lineNumber, lexeme: $1, literal: $1)
        },
        Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+\\b") {
            Token(type: .identifier, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[-]{0,1}[0-9]+\\b") {
            let scanner = Scanner(string: $1)
            var number: Int = 0
            var result = scanner.scanInt(&number)
            assert(result)
            return Token(type: .number, lineNumber: $0.lineNumber, lexeme: $1, literal: number)
        },
        Rule(pattern: "\\$[0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($1.dropFirst()))
            var number: UInt32 = 0
            var result = scanner.scanHexInt32(&number)
            assert(result)
            return Token(type: .number, lineNumber: $0.lineNumber, lexeme: $1, literal: Int(number))
        },
        Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($1))
            var number: UInt32 = 0
            var result = scanner.scanHexInt32(&number)
            assert(result)
            return Token(type: .number, lineNumber: $0.lineNumber, lexeme: $1, literal: Int(number))
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
        emit(type: .eof, lineNumber: lineNumber, lexeme: "")
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
    
    func emit(type: TokenType, lineNumber: Int, lexeme: String) {
        tokens.append(Token(type: type, lineNumber: lineNumber, lexeme: lexeme))
    }
    
    func unexpectedCharacterError(_ character: String) -> AssemblerError {
        return AssemblerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}
