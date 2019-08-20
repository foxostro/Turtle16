//
//  AssemblerTokenizer.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/19/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerTokenizer: NSObject {
    public struct AssemblerTokenizerError: Error {
        public let line: Int
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
    }
    
    public enum TokenType {
        case token
        case newline
    }
    
    public class Token : NSObject {
        public let type: TokenType
        public let lineNumber: Int
        public let string: String
        
        public required init(type: TokenType,
                             lineNumber: Int,
                             string: String) {
            self.type = type
            self.lineNumber = lineNumber
            self.string = string
            super.init()
        }
    }
    
    public var tokens: [Token] = []
    let text: String
    let newLine = "\n"
    
    public required init(withText text: String) {
        self.text = text
    }
    
    public func tokenize() throws {
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil
        var lineNumber = 1
        while (!scanner.isAtEnd) {
            try consumeLine(lineNumber: lineNumber, scanner: scanner)
            lineNumber += 1
        }
    }
    
    public func emit(type: TokenType, lineNumber: Int, string: String) {
        tokens.append(Token(type: type, lineNumber: lineNumber, string: string))
    }

    public func consumeLine(lineNumber: Int, scanner: Scanner) throws {
        var maybeLine: NSString?
        if scanner.scanUpTo(newLine, into: &maybeLine) {
            let line = stripComments(maybeLine! as String)
            let scanner = Scanner(string: line)
            scanner.charactersToBeSkipped = nil
            try consumeTokens(lineNumber: lineNumber, scanner: scanner)
        }
        
        var maybeNewline: NSString?
        if scanner.scanString(newLine, into: &maybeNewline) {
            emit(type: .newline, lineNumber: lineNumber, string: maybeNewline! as String)
        }
    }
    
    func stripComments(_ line: String) -> String {
        let scanner = Scanner(string: line)
        scanner.charactersToBeSkipped = nil
        var maybe: NSString?
        if scanner.scanString("//", into: &maybe) {
            return ""
        } else if scanner.scanUpTo("//", into: &maybe) {
            let beforeComment = maybe! as String
            return beforeComment
        } else {
            return line
        }
    }
    
    public func consumeTokens(lineNumber: Int, scanner: Scanner) throws {
        while (!scanner.isAtEnd) {
            try consumeToken(lineNumber: lineNumber, scanner: scanner)
        }
    }
    
    public func consumeToken(lineNumber: Int, scanner: Scanner) throws {
        let delimiterTokens = CharacterSet(charactersIn: ",")
        let tokenDelimiters = CharacterSet.whitespaces.union(delimiterTokens)
        scanner.charactersToBeSkipped = CharacterSet.whitespaces
        var maybeToken: NSString?
        if scanner.scanUpToCharacters(from: tokenDelimiters, into: &maybeToken) {
            let token = maybeToken! as String
            emit(type: .token, lineNumber: lineNumber, string: token)
        } else if scanner.scanCharacters(from: delimiterTokens, into: &maybeToken) {
            let token = maybeToken! as String
            emit(type: .token, lineNumber: lineNumber, string: token)
        }
    }
}
