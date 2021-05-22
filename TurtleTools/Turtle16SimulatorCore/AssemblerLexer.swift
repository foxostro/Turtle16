//
//  AssemblerLexer.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 5/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class AssemblerLexer: Lexer {
    public required init(_ string: String, _ url: URL? = nil) {
        super.init(string, url)
        self.rules = [
            makeNewlineRule(),
            makeCommentRule(),
            makeCommaRule(),
            makeColonRule(),
            makeParenLeftRule(),
            makeParenRightRule(),
            makeQuotedStringRule(),
            makeIdentifierRule(),
            makeDecimalNumberRule(),
            makeHexadecimalNumberWithDollarSigilRule(),
            makeHexadecimalNumberRule(),
            makeBinaryNumberRule(),
            makeQuotedCharacterRule(),
            makeWhitespaceRule()
        ]
    }
}
 
