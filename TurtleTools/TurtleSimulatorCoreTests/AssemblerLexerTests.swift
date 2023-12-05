//
//  AssemblerLexerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 5/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class AssemblerLexerTests: XCTestCase {
    func testTokenizeComment1() {
        let text = "// comment"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: lineMapper.anchor(10, 10))])
    }
    
    func testTokenizeComment2() {
        let text = "# comment"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: lineMapper.anchor(9, 9))])
    }
    
    func testTokenizeCommentFollowedByNewline() {
        let text = "# comment\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [
                        TokenNewline(sourceAnchor: lineMapper.anchor(9, 10)),
                        TokenEOF(sourceAnchor: lineMapper.anchor(10, 10))
                        ])
    }
    
    func testTokenizeAddressExpression() {
        let text = "JR 1(r1)"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [
                        TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 2)),
                        TokenNumber(sourceAnchor: lineMapper.anchor(3, 4), literal: 1),
                        TokenParenLeft(sourceAnchor: lineMapper.anchor(4, 5)),
                        TokenIdentifier(sourceAnchor: lineMapper.anchor(5, 7)),
                        TokenParenRight(sourceAnchor: lineMapper.anchor(7, 8)),
                        TokenEOF(sourceAnchor: lineMapper.anchor(8, 8))
                        ])
    }
}
