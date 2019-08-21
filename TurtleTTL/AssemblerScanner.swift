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
    
    public enum TokenType {
        case newline
        case comma
        case nop
        case cmp
        case hlt
        case identifier
    }
    
    public class Token : NSObject {
        public let type: TokenType
        public let lineNumber: Int
        public let lexeme: String
        
        public required init(type: TokenType,
                             lineNumber: Int,
                             lexeme: String) {
            self.type = type
            self.lineNumber = lineNumber
            self.lexeme = lexeme
            super.init()
        }
        
        public override var description: String {
            return String(format: "<Token: type=%@, lineNumber=%d, lexeme=\"%@\">", String(describing: type), lineNumber, lexeme)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            if let rhs = rhs as? Token {
                return self == rhs
            } else {
                return false
            }
        }
    }
    
    struct Rule {
        let pattern: String
        let emit: (AssemblerScanner, String) -> Token?
    }
    
    let rules: [Rule] = [
        Rule(pattern: ",") {
            Token(type: .comma, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "\n") {
            let token = Token(type: .newline, lineNumber: $0.lineNumber, lexeme: $1)
            $0.lineNumber += 1
            return token
        },
        Rule(pattern: "//") {(scanner: AssemblerScanner, lexeme: String) in
            scanner.advanceToNewline()
            return nil
        },
        Rule(pattern: "NOP") {
            Token(type: .nop, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "CMP") {
            Token(type: .cmp, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "HLT") {
            Token(type: .hlt, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+") {
            Token(type: .identifier, lineNumber: $0.lineNumber, lexeme: $1)
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
    
    func unexpectedCharacterError(_ character: String) -> AssemblerScannerError {
        return AssemblerScannerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}

public func ==(lhs: AssemblerScanner.Token, rhs: AssemblerScanner.Token) -> Bool {
    return lhs.type == rhs.type
        && lhs.lineNumber == rhs.lineNumber
        && lhs.lexeme == rhs.lexeme
}
