//
//  TextInputStream.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class TextInputStream: NSObject {
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
    
    public func match(_ string: String) -> String? {
        if (peek(count: string.count) == string) {
            return advance(count: string.count)
        }
        return nil
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
    
    public func advanceToNewline() {
        while let next = peek() {
            if next == "\n" {
                return
            }
            advance()
        }
    }
}
