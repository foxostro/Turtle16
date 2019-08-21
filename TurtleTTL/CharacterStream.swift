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
    
    public func peek(_ index: Int = 0) -> Character? {
        if index >= 0 && index < characters.count {
           return characters[index]
        } else {
            return nil
        }
    }
    
    @discardableResult public func advance() -> Character? {
        let character = peek()
        if character != nil {
            characters.removeFirst()
        }
        return character
    }
}
