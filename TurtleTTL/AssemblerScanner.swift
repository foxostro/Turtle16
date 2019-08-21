//
//  AssemblerScanner.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerScanner: TurtleScanner {
    public struct AssemblerScannerError: Error {
        public let line: Int
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
    }
    
    public private(set) var tokens: [AssemblerToken] = []
    var lineNumber = 1
    
    public func scanTokens() throws {
        while !isAtEnd {
            try scanToken()
        }
    }
    
    public func scanToken() throws {
        let rules: [(String, (String) -> AssemblerToken?)] = [
            (
                ",", {
                    AssemblerToken(type: .comma, lineNumber: self.lineNumber, lexeme: $0)
                }
            ),
            (
                "\n", {
                    let token = AssemblerToken(type: .newline, lineNumber: self.lineNumber, lexeme: $0)
                    self.lineNumber += 1
                    return token
                }
            ),
            (
                "//", {_ in
                    self.advanceToNewline()
                    return nil
                }
            ),
            (
                "NOP", {
                    AssemblerToken(type: .nop, lineNumber: self.lineNumber, lexeme: $0)
                }
            ),
            (
                "CMP", {
                    AssemblerToken(type: .cmp, lineNumber: self.lineNumber, lexeme: $0)
                }
            ),
            (
                "HLT", {
                    AssemblerToken(type: .hlt, lineNumber: self.lineNumber, lexeme: $0)
                }
            ),
            (
                "[_a-zA-Z][_a-zA-Z0-9]+", {
                    AssemblerToken(type: .identifier, lineNumber: self.lineNumber, lexeme: $0)
                }
            ),
            (
                "[ \t]+", { _ in
                    nil
                }
            )
        ]
        
        for rule in rules {
            if let lexeme = match(pattern: rule.0) {
                if let token = rule.1(lexeme) {
                    tokens.append(token)
                }
                return
            }
        }
        
        throw unexpectedCharacterError(peek()!)
    }
    
    func emit(type: AssemblerToken.TokenType, lineNumber: Int, lexeme: String) {
        tokens.append(AssemblerToken(type: type, lineNumber: lineNumber, lexeme: lexeme))
    }
    
    func unexpectedCharacterError(_ character: String) -> AssemblerScannerError {
        return AssemblerScannerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}
