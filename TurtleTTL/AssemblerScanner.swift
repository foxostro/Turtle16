//
//  AssemblerScanner.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerScanner: TextInputStream {
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
        if let lexeme = match(",") {
            emit(type: .comma, lineNumber: lineNumber, lexeme: lexeme)
        } else if let lexeme = match("\n") {
            emit(type: .newline, lineNumber: lineNumber, lexeme: lexeme)
            lineNumber += 1
        } else if nil != match("//") {
            advanceToNewline()
        } else if let lexeme = match("NOP") {
            emit(type: .nop, lineNumber: lineNumber, lexeme: lexeme)
        } else if let lexeme = match("CMP") {
            emit(type: .cmp, lineNumber: lineNumber, lexeme: lexeme)
        } else if let lexeme = match("HLT") {
            emit(type: .hlt, lineNumber: lineNumber, lexeme: lexeme)
        } else if let lexeme = match(characterSet: .alphanumerics) {
            emit(type: .identifier, lineNumber: lineNumber, lexeme: lexeme)
        } else if nil != match(characterSet: .whitespaces) {
            // consume whitespace without doing anything
        } else {
            throw unexpectedCharacterError(peek()!)
        }
    }
    
    func emit(type: AssemblerToken.TokenType, lineNumber: Int, lexeme: String) {
        tokens.append(AssemblerToken(type: type, lineNumber: lineNumber, lexeme: lexeme))
    }
    
    func unexpectedCharacterError(_ character: String) -> AssemblerScannerError {
        return AssemblerScannerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}
