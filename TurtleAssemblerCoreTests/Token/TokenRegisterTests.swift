//
//  TokenRegisterTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox

class TokenRegisterTests: XCTestCase {
    func testTokenRegisterDescription() {
        XCTAssertEqual(TokenRegister(lineNumber: 1, lexeme: "A", literal: .A).description, "<TokenRegister: lineNumber=1, lexeme=\"A\", literal=A>")
    }
    
    func testTokenRegisterEquality() {
        let a = TokenRegister(lineNumber: 1, lexeme: "X", literal: .X)
        let b = TokenRegister(lineNumber: 1, lexeme: "X", literal: .X)
        XCTAssertEqual(a, b)
    }
    
    func testTokenRegisterIsNotEqualToSomeOtherNSObject() {
        let token = TokenRegister(lineNumber: 42, lexeme: "A", literal: .A)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenRegisterIsNotEqualToTokenWithDifferentLineNumber() {
        let a = TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
        let b = TokenRegister(lineNumber: 2, lexeme: "A", literal: .A)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenRegisterIsNotEqualToTokenWithDifferentLexeme() {
        let a = TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
        let b = TokenRegister(lineNumber: 1, lexeme: "B", literal: .A)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenRegistersNotEqualToTokenWithDifferentLiteral() {
        let a = TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
        let b = TokenRegister(lineNumber: 1, lexeme: "A", literal: .B)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenRegisterIsNotEqualToTokenOfDifferentType() {
        let a = TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
        let b = TokenEOF(lineNumber: 1)
        XCTAssertNotEqual(a, b)
    }
}
