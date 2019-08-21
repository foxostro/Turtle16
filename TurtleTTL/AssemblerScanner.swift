//
//  AssemblerScanner.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerScanner: CharacterStream {
    public struct AssemblerScannerError: Error {
        public let line: Int
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
    }
    
    public private(set) var tokens: [Token] = []
    var lineNumber = 1
    
    public func scanTokens() throws {
        while !isAtEnd {
            try scanToken()
        }
    }
    
    public func scanToken() throws {
        if match(",") {
            emit(type: .comma, lineNumber: lineNumber, lexeme: ",")
        } else if match("\n") {
            emit(type: .newline, lineNumber: lineNumber, lexeme: "\n")
            lineNumber += 1
        } else if match("//") {
            advanceToNewline()
        } else if match(characterSet: CharacterSet.whitespaces) {
            // consume whitespace without doing anything
        } else {
            throw unexpectedCharacterError(peek()!)
        }
    }
    
    func emit(type: Token.TokenType, lineNumber: Int, lexeme: String) {
        tokens.append(Token(type: type, lineNumber: lineNumber, lexeme: lexeme))
    }
    
    public func match(_ string: String) -> Bool {
        if (peek(count: string.count) == string) {
            advance(count: string.count)
            return true
        }
        return false
    }
    
    public func match(characterSet: CharacterSet) -> Bool {
        if let c = peek() {
            if c.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
                advance()
                return true
            }
        }
        return false
    }
    
    func advanceToNewline() {
        while let next = peek() {
            if next == "\n" {
                return
            }
            advance()
        }
    }
    
    func unexpectedCharacterError(_ character: Character) -> AssemblerScannerError {
        return AssemblerScannerError(line: lineNumber, format: "unexpected character: `%@'", String(character))
    }
}
