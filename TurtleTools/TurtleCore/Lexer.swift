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
        public init(pattern: String, emit: @escaping (SourceAnchor) -> Token?) {
            self.regex = try? NSRegularExpression(pattern: "^\(pattern)", options: [])
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
}
