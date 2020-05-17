//
//  Lexer.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class Lexer: NSObject {
    public private(set) var string = ""
    public var isAtEnd:Bool {
        return string == ""
    }
    public private(set) var tokens: [Token] = []
    public var lineNumber = 1
    
    public typealias Rule = (pattern: String, emit: (String) -> Token?)
    public var rules: [Rule] = []
    
    public private(set) var errors: [AssemblerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public required init(withString string: String) {
        self.string = string
    }
    
    public func peek(_ ahead: Int = 0) -> String? {
        if ahead >= 0 && ahead < string.count {
           return String(Array(string)[ahead])
        }
        return nil
    }
    
    @discardableResult public func advance() -> String? {
        guard let character = peek() else { return nil }
        string.remove(at: string.startIndex)
        return String(character)
    }
    
    public func match(pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "^\(pattern)", options: []) else {
            return nil
        }
        guard let match = regex.firstMatch(in: string, options: [], range: NSRange(string.startIndex..., in: string)) else {
            return nil
        }
        let matchedString = String(string[Range(match.range, in: string)!])
        string = String(string[matchedString.endIndex...])
        return matchedString
    }
    
    public func match(characterSet: CharacterSet) -> String? {
        var result = ""
        while let c = peek() {
            if !c.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
                break
            }
            result += advance()!
        }
        if result == "" {
            return nil
        }
        return result
    }
    
    @discardableResult public func advanceToNewline() -> String? {
        return match(characterSet: CharacterSet.newlines.inverted)
    }
    
    public func scanTokens() {
        errors = []
        while !isAtEnd {
            do {
                try scanToken()
            } catch let error as AssemblerError {
                errors.append(error)
                advanceToNewline() // recover by skipping to the next line
            } catch {
                // This catch block should be unreachable because scanToken()
                // only throws AssemblerError. Regardless, we need it to satisfy
                // the compiler.
                errors.append(AssemblerError(line: lineNumber, format: "unrecoverable error: %@", error.localizedDescription))
                return
            }
        }
        tokens.append(TokenEOF(lineNumber: lineNumber, lexeme: ""))
    }
    
    public func scanToken() throws {
        for rule in rules {
            if let lexeme = match(pattern: rule.pattern) {
                if let token = rule.emit(lexeme) {
                    tokens.append(token)
                }
                return
            }
        }
        
        throw unexpectedCharacterError(peek()!)
    }
    
    func unexpectedCharacterError(_ character: String) -> AssemblerError {
        return AssemblerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}
