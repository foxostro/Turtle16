//
//  DebugConsoleCommandLineLexer.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class DebugConsoleCommandLineLexer: Lexer {
    public required init(_ string: String, _ url: URL? = nil) {
        super.init(string, url)
        self.rules = [
            makeNewlineRule(),
            makeCommaRule(),
            makeColonRule(),
            makeForwardSlashRule(),
            makeQuotedStringRule(),
            makeIdentifierRule(),
            makeDecimalNumberRule(),
            makeHexadecimalNumberWithDollarSigilRule(),
            makeHexadecimalNumberRule(),
            makeBinaryNumberRule(),
            makeQuotedCharacterRule(),
            makeWhitespaceRule(),
        ]
    }
}
