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
        XCTAssertEqual(TokenRegister(literal: .A).description,
                       "<TokenRegister: sourceAnchor=nil, lexeme=\"\", literal=A>")
    }
    
    func testTokenRegisterEquality() {
        let a = TokenRegister(literal: .X)
        let b = TokenRegister(literal: .X)
        XCTAssertEqual(a, b)
    }
    
    func testTokenRegisterIsNotEqualToSomeOtherNSObject() {
        let token = TokenRegister(literal: .A)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenRegistersNotEqualToTokenWithDifferentLiteral() {
        let a = TokenRegister(literal: .A)
        let b = TokenRegister(literal: .B)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenRegisterIsNotEqualToTokenOfDifferentType() {
        let a = TokenRegister(literal: .A)
        let b = TokenEOF()
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenRegister(literal: .X).hashValue,
                       TokenRegister(literal: .X).hashValue)
    }
}
