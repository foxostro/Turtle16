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
}
