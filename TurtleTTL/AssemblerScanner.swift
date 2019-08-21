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
        guard let character = advance() else { return }
        if character == "," {
            emit(type: .comma, lineNumber: lineNumber, lexeme: ",")
        } else if character == "\n" {
            emit(type: .newline, lineNumber: lineNumber, lexeme: "\n")
            lineNumber += 1
        } else if character == "/" {
            if peek() == "/" {
                advanceToNewline()
            }
        } else if character == " " || character == "\t" {
            // consume whitespace without doing anything
        } else {
            throw unexpectedCharacterError(character)
        }
    }
    
    func emit(type: Token.TokenType, lineNumber: Int, lexeme: String) {
        tokens.append(Token(type: type, lineNumber: lineNumber, lexeme: lexeme))
    }
    
    public func match(character: Character) -> Bool {
        if let c = peek() {
            if c == character {
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
    
//    public func match(string: String) -> Bool {
//        return match(array: Array(string))
//    }
//
//    public func match(array: Array<Character>) -> Bool {
//        for i in 1..<array.count {
//            guard let character = peek(i) else {
//                return false
//            }
//            if character == array[i] {
//                advance()
//                return true
//            }
//        }
//        return false
//    }
}
