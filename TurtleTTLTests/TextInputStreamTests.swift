//
//  TextInputStreamTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TextInputStreamTests: XCTestCase {
    func testInitWithEmptyString() {
        let input = TextInputStream(withString: "")
        XCTAssertEqual(input.string, "")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testInitWithOneCharacter() {
        let input = TextInputStream(withString: "a")
        XCTAssertEqual(input.string, "a")
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekEmptyString() {
        let input = TextInputStream(withString: "")
        XCTAssertEqual(input.peek(), nil)
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testPeekCharacter() {
        let input = TextInputStream(withString: "a")
        XCTAssertEqual(input.peek(), "a")
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekAheadAFewCharacters() {
        let input = TextInputStream(withString: "abcd")
        XCTAssertEqual(input.peek(2), "c")
    }
    
    func testAdvanceEmptyString() {
        let input = TextInputStream(withString: "")
        XCTAssertTrue(input.isAtEnd)
        XCTAssertEqual(input.advance(), nil)
    }
    
    func testAdvanceCharacter() {
        let input = TextInputStream(withString: "a")
        XCTAssertFalse(input.isAtEnd)
        XCTAssertEqual(input.advance(), "a")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testAdvanceMultipleCharacter() {
        let input = TextInputStream(withString: "ab")
        XCTAssertFalse(input.isAtEnd)
        XCTAssertEqual(input.advance(count: 3), "ab")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testMatchEmptyString() {
        let input = TextInputStream(withString: "ab")
        XCTAssertEqual(input.match(""), "")
    }
    
    func testMatchCharacter() {
        let input = TextInputStream(withString: "ab")
        XCTAssertEqual(input.match("a"), "a")
        XCTAssertEqual(input.match("b"), "b")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testMatchString() {
        let input = TextInputStream(withString: "ab")
        XCTAssertEqual(input.match("ab"), "ab")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testMatchWhitespaceButNoneIsThere() {
        let input = TextInputStream(withString: "\n")
        XCTAssertEqual(input.match(characterSet: .whitespaces), nil)
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testMatchWhitespace() {
        let input = TextInputStream(withString: "  \t\n")
        XCTAssertEqual(input.match(characterSet: .whitespaces), "  \t")
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testAdvanceToNewlineWithEmptyString() {
        let input = TextInputStream(withString: "")
        input.advanceToNewline()
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testAdvanceToNewline() {
        let input = TextInputStream(withString: "abcd\n")
        input.advanceToNewline()
        XCTAssertEqual(input.peek(), "\n")
    }
}
