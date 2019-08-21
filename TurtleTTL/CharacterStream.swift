//
//  CharacterStream.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class CharacterStream: NSObject {
    public private(set) var characters: [Character]
    public var isAtEnd:Bool {
        return characters.count == 0
    }
    
    public required init(withString string: String) {
        characters = Array<Character>(string)
    }
    
    public func peek(_ ahead: Int = 0) -> Character? {
        if ahead >= 0 && ahead < characters.count {
           return characters[ahead]
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
    
    @discardableResult public func advance() -> Character? {
        let character = peek()
        if character != nil {
            characters.removeFirst()
        }
        return character
    }
    
    @discardableResult public func advance(count: Int) -> String {
        var result = ""
        for _ in 1...count {
            guard let c = advance() else { break }
            result += String(c)
        }
        return result
    }
}
