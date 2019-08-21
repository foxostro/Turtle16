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
        case eof
        case newline
        case comma
        case colon
        case number
        case identifier
        case nop
        case cmp
        case hlt
        case registerA
        case registerB
        case registerC
        case registerD
        case registerE
        case registerM
        case registerX
        case registerY
    }
    
    public class Token : NSObject {
        public let type: TokenType
        public let lineNumber: Int
        public let lexeme: String
        public let literal: Int?
        
        public required init(type: TokenType,
                             lineNumber: Int,
                             lexeme: String,
                             literal: Int? = nil) {
            self.type = type
            self.lineNumber = lineNumber
            self.lexeme = lexeme
            self.literal = literal
            super.init()
        }
        
        public override var description: String {
            if let literal = literal {
                return String(format: "<Token: type=%@, lineNumber=%d, lexeme=\"%@\", literal=%@>", String(describing: type), lineNumber, lexeme, String(describing: literal))
            } else {
                return String(format: "<Token: type=%@, lineNumber=%d, lexeme=\"%@\">", String(describing: type), lineNumber, lexeme)
            }
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
        Rule(pattern: "\n") {
            let token = Token(type: .newline, lineNumber: $0.lineNumber, lexeme: $1)
            $0.lineNumber += 1
            return token
        },
        Rule(pattern: "//") {(scanner: AssemblerScanner, lexeme: String) in
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
        Rule(pattern: "A\\b") {
            Token(type: .registerA, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "B\\b") {
            Token(type: .registerB, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "C\\b") {
            Token(type: .registerC, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "D\\b") {
            Token(type: .registerD, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "E\\b") {
            Token(type: .registerE, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "M\\b") {
            Token(type: .registerM, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "X\\b") {
            Token(type: .registerX, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "Y\\b") {
            Token(type: .registerY, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+\\b") {
            Token(type: .identifier, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[0-9]+\\b") {
            let scanner = Scanner(string: $1)
            var number: Int = 0
            if scanner.scanInt(&number) {
                return Token(type: .number, lineNumber: $0.lineNumber, lexeme: $1, literal: number)
            } else {
                assert(false)
            }
        },
        Rule(pattern: "\\$[0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($1.dropFirst()))
            var number: UInt32 = 0
            if scanner.scanHexInt32(&number) {
                return Token(type: .number, lineNumber: $0.lineNumber, lexeme: $1, literal: Int(number))
            } else {
                assert(false)
            }
        },
        Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($1))
            var number: UInt32 = 0
            if scanner.scanHexInt32(&number) {
                return Token(type: .number, lineNumber: $0.lineNumber, lexeme: $1, literal: Int(number))
            } else {
                assert(false)
            }
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
    
    func unexpectedCharacterError(_ character: String) -> AssemblerScannerError {
        return AssemblerScannerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}

public func ==(lhs: AssemblerScanner.Token, rhs: AssemblerScanner.Token) -> Bool {
    return lhs.type == rhs.type
        && lhs.lineNumber == rhs.lineNumber
        && lhs.lexeme == rhs.lexeme
        && lhs.literal == rhs.literal
}
