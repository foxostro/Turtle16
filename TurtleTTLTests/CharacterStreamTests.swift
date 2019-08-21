//
//  CharacterStreamTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class CharacterStreamTests: XCTestCase {
    func testInitWithEmptyString() {
        let input = CharacterStream(withString: "")
        XCTAssertEqual(input.characters, [])
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testInitWithOneCharacter() {
        let input = CharacterStream(withString: "a")
        XCTAssertEqual(input.characters, ["a"])
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekEmptyString() {
        let input = CharacterStream(withString: "")
        XCTAssertEqual(input.peek(), nil)
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testPeekCharacter() {
        let input = CharacterStream(withString: "a")
        XCTAssertEqual(input.peek(), "a")
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekAheadAFewCharacters() {
        let input = CharacterStream(withString: "abcd")
        XCTAssertEqual(input.peek(2), "c")
    }
    
    func testAdvanceEmptyString() {
        let input = CharacterStream(withString: "")
        XCTAssertTrue(input.isAtEnd)
        XCTAssertEqual(input.advance(), nil)
    }
    
    func testAdvanceCharacter() {
        let input = CharacterStream(withString: "a")
        XCTAssertFalse(input.isAtEnd)
        XCTAssertEqual(input.advance(), "a")
        XCTAssertTrue(input.isAtEnd)
    }
}
