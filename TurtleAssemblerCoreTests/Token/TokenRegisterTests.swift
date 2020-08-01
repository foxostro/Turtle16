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
        XCTAssertEqual(TokenRegister(sourceAnchor: nil, literal: .A).description,
                       "<TokenRegister: sourceAnchor=nil, lexeme=\"\", literal=A>")
    }
    
    func testTokenRegisterEquality() {
        let a = TokenRegister(sourceAnchor: nil, literal: .X)
        let b = TokenRegister(sourceAnchor: nil, literal: .X)
        XCTAssertEqual(a, b)
    }
    
    func testTokenRegisterIsNotEqualToSomeOtherNSObject() {
        let token = TokenRegister(sourceAnchor: nil, literal: .A)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenRegistersNotEqualToTokenWithDifferentLiteral() {
        let a = TokenRegister(sourceAnchor: nil, literal: .A)
        let b = TokenRegister(sourceAnchor: nil, literal: .B)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenRegisterIsNotEqualToTokenOfDifferentType() {
        let a = TokenRegister(sourceAnchor: nil, literal: .A)
        let b = TokenEOF(sourceAnchor: nil)
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenRegister(sourceAnchor: nil, literal: .X).hashValue,
                       TokenRegister(sourceAnchor: nil, literal: .X).hashValue)
    }
}
