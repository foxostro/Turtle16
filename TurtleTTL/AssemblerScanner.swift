//
//  AssemblerScanner.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerScanner: TurtleScanner {
    public enum TokenType {
        case eof
        case newline
        case comma
        case colon
        case number
        case register
        case nop
        case cmp
        case hlt
        case jmp
        case jc
        case add
        case li
        case mov
        case identifier
    }
    
    public class Token : NSObject {
        public let type: TokenType
        public let lineNumber: Int
        public let lexeme: String
        public let literal: Any?
        
        public required init(type: TokenType,
                             lineNumber: Int,
                             lexeme: String,
                             literal: Any? = nil) {
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
        Rule(pattern: "[ABCDEMXY]\\b") {
            Token(type: .register, lineNumber: $0.lineNumber, lexeme: $1, literal: $1)
        },
        Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+\\b") {
            Token(type: .identifier, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[-]{0,1}[0-9]+\\b") {
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
    
    func unexpectedCharacterError(_ character: String) -> AssemblerError {
        return AssemblerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}

public func ==(lhs: AssemblerScanner.Token, rhs: AssemblerScanner.Token) -> Bool {
    if lhs.type != rhs.type {
        return false
    }
    
    if lhs.lineNumber != rhs.lineNumber {
        return false
    }
    
    if lhs.lexeme != rhs.lexeme {
        return false
    }
    
    if (lhs.literal == nil) != (rhs.literal == nil) {
        return false
    }
    
    if type(of: lhs.literal) != type(of: rhs.literal) {
        return false
    }
    
    if let a = lhs.literal as? Int {
        if let b = rhs.literal as? Int {
            return a == b
        } else {
            return false
        }
    }
    
    if let a = lhs.literal as? String {
        if let b = rhs.literal as? String {
            return a == b
        } else {
            return false
        }
    }
    
    if let a = lhs.literal as? NSObject {
        if let b = rhs.literal as? NSObject {
            return a.isEqual(b)
        } else {
            return false
        }
    }
    
    return true
}
