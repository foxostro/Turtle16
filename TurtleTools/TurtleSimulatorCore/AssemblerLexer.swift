//
//  AssemblerLexer.swift
//  TurtleSimulatorCore
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
            makeBackslashNewlineRule(),
            makeNewlineRule(),
            makeCommentRule(),
            makeCommaRule(),
            makeColonRule(),
            makeParenLeftRule(),
            makeParenRightRule(),
            makeQuotedStringRule(),
            Rule(pattern: "\\.?[_a-zA-Z][\\-_a-zA-Z0-9]*\\b") {
                TokenIdentifier(sourceAnchor: $0)
            },
            makeDecimalNumberRule(),
            makeHexadecimalNumberWithDollarSigilRule(),
            makeHexadecimalNumberRule(),
            makeBinaryNumberRule(),
            makeQuotedCharacterRule(),
            makeWhitespaceRule()
        ]
    }
}
