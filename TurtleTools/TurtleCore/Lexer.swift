//
//  Lexer.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class Lexer: NSObject {
    public let string: String
    private var position: String.Index
    public var isAtEnd:Bool {
        return position == string.endIndex
    }
    public let lineMapper: SourceLineRangeMapper
    public private(set) var tokens: [Token] = []
    
    public class Rule : NSObject {
        public let regex: NSRegularExpression?
        public let emit: (SourceAnchor) -> Token?
        public init(pattern: String, options: NSRegularExpression.Options = [], emit: @escaping (SourceAnchor) -> Token?) {
            self.regex = try? NSRegularExpression(pattern: "^\(pattern)", options: options)
            self.emit = emit
        }
    }
    public var rules: [Rule] = []
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public required init(_ string: String, _ url: URL? = nil) {
        self.string = string
        position = string.startIndex
        lineMapper = SourceLineRangeMapper(url: url, text: string)
    }
    
    public func peekRange(_ ahead: Int = 0) -> Range<String.Index>? {
        var start: String.Index = position
        for _ in 0..<ahead {
            string.formIndex(after: &start)
            if start >= string.endIndex {
                return nil
            }
        }
        
        var end: String.Index = start
        if start < string.endIndex {
            string.formIndex(after: &end)
        } else {
            return nil
        }
        
        let range = start..<end
        return range
    }
    
    public func peek(_ ahead: Int = 0) -> Substring? {
        guard let range = peekRange(ahead) else {
            return nil
        }
        let substring = string[range]
        return substring
    }
    
    public func advance() {
        if position != string.endIndex {
            string.formIndex(after: &position)
        }
    }
    
    public func match(pattern: String) -> SourceAnchor? {
        return match(rule: Rule(pattern: pattern, emit: {_ in return nil}))
    }
    
    public func match(rule: Rule) -> SourceAnchor? {
        guard let regex = rule.regex else {
            return nil
        }
        guard let match = regex.firstMatch(in: string, options: [], range: NSRange(position..., in: string)) else {
            return nil
        }
        let matchedRange = Range(match.range, in: string)!
        position = matchedRange.upperBound
        return SourceAnchor(range: matchedRange, lineMapper: lineMapper)
    }
    
    public func advanceToNewline() {
        while let c = peek() {
            if c == "\n" {
                break
            }
            advance()
        }
    }
    
    public func scanTokens() {
        errors = []
        while !isAtEnd {
            do {
                try scanToken()
            } catch let error as CompilerError {
                errors.append(error)
                advanceToNewline() // recover by skipping to the next line
            } catch {
                // This catch block should be unreachable because scanToken()
                // only throws CompilerError. Regardless, we need it to satisfy
                // the compiler.
                errors.append(CompilerError(sourceAnchor: tokens.last?.sourceAnchor,
                                            message: "unrecoverable error: \(error.localizedDescription)"))
                return
            }
        }
        let eofAnchor = SourceAnchor(range: string.endIndex..<string.endIndex, lineMapper: lineMapper)
        tokens.append(TokenEOF(sourceAnchor: eofAnchor))
    }
    
    public func scanToken() throws {
        for rule in rules {
            if let anchor = match(rule: rule) {
                if let token = rule.emit(anchor) {
                    tokens.append(token)
                }
                return
            }
        }
        
        throw unexpectedCharacterError(sourceAnchor: SourceAnchor(range: peekRange()!, lineMapper: lineMapper))
    }
    
    func unexpectedCharacterError(sourceAnchor: SourceAnchor) -> CompilerError {
        return CompilerError(sourceAnchor: sourceAnchor, message: "unexpected character: `\(sourceAnchor.text)'")
    }
    
    public func makeNewlineRule() -> Lexer.Rule {
        return Rule(pattern: "\n") {
            TokenNewline(sourceAnchor: $0)
        }
    }
    
    public func makeCommaRule() -> Lexer.Rule {
        return Rule(pattern: ",") {
            TokenComma(sourceAnchor: $0)
        }
    }
    
    public func makeColonRule() -> Lexer.Rule {
        return Rule(pattern: ":") {
            TokenColon(sourceAnchor: $0)
        }
    }
    
    public func makeForwardSlashRule() -> Lexer.Rule {
        return Rule(pattern: "/") {
            TokenForwardSlash(sourceAnchor: $0)
        }
    }
    
    public func makeQuotedStringRule() -> Lexer.Rule {
        return Rule(pattern: "\".*\"") {[weak self] in
            TokenLiteralString(sourceAnchor: $0, literal: self!.interpretQuotedString(lexeme: String($0.text)))
        }
    }
    
    fileprivate func interpretQuotedString(lexeme: String) -> String {
        var result = String(lexeme.dropFirst().dropLast())
        let map = ["\0" : "\\0",
                   "\t" : "\\t",
                   "\n" : "\\n",
                   "\r" : "\\r",
                   "\"" : "\\\"",
                   "\'" : "\\\'",
                   "\\" : "\\\\"]
        for (entity, description) in map {
            result = result.replacingOccurrences(of: description, with: entity)
        }
        return result
    }
    
    public func makeIdentifierRule() -> Lexer.Rule {
        return Rule(pattern: "[_a-zA-Z][\\-_a-zA-Z0-9]*\\b") {
            TokenIdentifier(sourceAnchor: $0)
        }
    }
    
    public func makeDecimalNumberRule() -> Lexer.Rule {
        return Rule(pattern: "[-]{0,1}[0-9]+\\b") {
            let scanner = Scanner(string: String($0.text))
            var number: Int = 0
            let result = scanner.scanInt(&number)
            assert(result)
            return TokenNumber(sourceAnchor: $0, literal: number)
        }
    }
    
    public func makeHexadecimalNumberWithDollarSigilRule() -> Lexer.Rule {
        return Rule(pattern: "\\$[0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($0.text.dropFirst()))
            var number: UInt64 = 0
            let result = scanner.scanHexInt64(&number)
            assert(result)
            return TokenNumber(sourceAnchor: $0, literal: Int(number))
        }
    }
    
    public func makeHexadecimalNumberRule() -> Lexer.Rule {
        return Rule(pattern: "0[xX][0-9a-fA-F]+\\b") {
            let scanner = Scanner(string: String($0.text))
            var number: UInt64 = 0
            let result = scanner.scanHexInt64(&number)
            assert(result)
            return TokenNumber(sourceAnchor: $0, literal: Int(number))
        }
    }
    
    public func makeBinaryNumberRule() -> Lexer.Rule {
        return Rule(pattern: "0b[01]+\\b") {
            let scanner = Scanner(string: String($0.text))
            var number = 0
            let result = scanner.scanBinaryInt(&number)
            assert(result)
            return TokenNumber(sourceAnchor: $0, literal: number)
        }
    }
    
    public func makeQuotedCharacterRule() -> Lexer.Rule {
        return Rule(pattern: "'.'") {
            let number = Int(String($0.text).split(separator: "'").first!.unicodeScalars.first!.value)
            return TokenNumber(sourceAnchor: $0, literal: number)
        }
    }
    
    public func makeWhitespaceRule() -> Lexer.Rule {
        return Rule(pattern: "[ \t]+") {_ in
            nil
        }
    }
    
    public func makeCommentRule() -> Lexer.Rule {
        return Rule(pattern: "((#)|(//))") {[weak self] _ in
            self!.advanceToNewline()
            return nil
        }
    }
    
    public func makeParenLeftRule() -> Lexer.Rule {
        return Rule(pattern: "\\(") {
            TokenParenLeft(sourceAnchor: $0)
        }
    }
    
    public func makeParenRightRule() -> Lexer.Rule {
        return Rule(pattern: "\\)") {
            TokenParenRight(sourceAnchor: $0)
        }
    }
}
