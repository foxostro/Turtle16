//
//  JEDECFuseFileParser.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// Parses a JEDEC fuse map file.
// This parser will ignore the STX and ETX characters at the beginning and end
// of the file. It will also ignore the fuse map checksum and the transmission
// checksum.
public class JEDECFuseFileParser: NSObject {
    let maker: FuseListMaker
    let binaryDigits: CharacterSet = CharacterSet.init(charactersIn: "01")
    let fieldDelimiter = "*"
    let fieldIdentifierF: Character = "F"
    let fieldIdentifierL: Character = "L"
    let fieldIdentifierQ: Character = "Q"
    
    public init(_ maker: FuseListMaker) {
        self.maker = maker
    }
    
    public func parse(_ text: String) {
        let scanner = Scanner(string: text)
        while !scanner.isAtEnd {
            _ = scanner.scanUpToString(fieldDelimiter)
            _ = scanner.scanCharacter()
            if !scanner.isAtEnd {
                let fieldIdentifier = scanner.scanCharacter()
                switch fieldIdentifier {
                case fieldIdentifierQ:
                    if scanner.scanCharacter() == fieldIdentifierF {
                        maker.numberOfFuses = scanner.scanInt()!
                    }
                    
                case fieldIdentifierL:
                    let begin = scanner.scanInt()!
                    _ = scanner.scanCharacters(from: CharacterSet.whitespacesAndNewlines)
                    let bitmap = scanner.scanCharacters(from: binaryDigits)!
                    maker.set(begin: begin, bitmap: bitmap)
                
                default:
                    break // ignore unimplemented
                }
            }
        }
    }
}