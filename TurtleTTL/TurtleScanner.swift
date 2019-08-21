//
//  TurtleScanner.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class TurtleScanner: NSObject {
    public private(set) var string = ""
    public var isAtEnd:Bool {
        return string == ""
    }
    
    public required init(withString string: String) {
        self.string = string
    }
    
    public func peek(_ ahead: Int = 0) -> String? {
        if ahead >= 0 && ahead < string.count {
           return String(Array(string)[ahead])
        } else {
            return nil
        }
    }
    
    public func peek(count: Int) -> String {
        var result = ""
        for i in 0..<count {
            guard let c = peek(i) else { break }
            result += String(c)
        }
        return result
    }
    
    @discardableResult public func advance() -> String? {
        guard let character = peek() else { return nil }
        string.remove(at: string.startIndex)
        return String(character)
    }
    
    @discardableResult public func advance(count: Int) -> String {
        var result = ""
        for _ in 0..<count {
            guard let c = advance() else { break }
            result += String(c)
        }
        return result
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
            if c.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
                result += advance() ?? ""
            } else {
                break
            }
        }
        if result == "" {
            return nil
        } else {
            return result
        }
    }
    
    @discardableResult public func advanceToNewline() -> String? {
        return match(characterSet: CharacterSet.newlines.inverted)
    }
}
