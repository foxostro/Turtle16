//
//  FlagsTest.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class FlagsTest: XCTestCase {
    func testInitDefault() {
        let flags = Flags()
        XCTAssertEqual(flags.carryFlag, 0)
        XCTAssertEqual(flags.equalFlag, 0)
    }
    
    func testInitParameterized() {
        let flags = Flags(1, 1)
        XCTAssertEqual(flags.carryFlag, 1)
        XCTAssertEqual(flags.equalFlag, 1)
    }
    
    func testInitParameterizedByValue() {
        let flags00 = Flags(value: UInt8(0b00000000))
        XCTAssertEqual(flags00.carryFlag, 0)
        XCTAssertEqual(flags00.equalFlag, 0)
        
        let flags01 = Flags(value: UInt8(0b00000010))
        XCTAssertEqual(flags01.carryFlag, 0)
        XCTAssertEqual(flags01.equalFlag, 1)
        
        let flags10 = Flags(value: UInt8(0b00000001))
        XCTAssertEqual(flags10.carryFlag, 1)
        XCTAssertEqual(flags10.equalFlag, 0)
        
        let flags11 = Flags(value: UInt8(0b00000011))
        XCTAssertEqual(flags11.carryFlag, 1)
        XCTAssertEqual(flags11.equalFlag, 1)
    }
    
    func testValue() {
        XCTAssertEqual(Flags(0, 0).value, UInt8(0b00000000))
        XCTAssertEqual(Flags(0, 1).value, UInt8(0b00000010))
        XCTAssertEqual(Flags(1, 0).value, UInt8(0b00000001))
        XCTAssertEqual(Flags(1, 1).value, UInt8(0b00000011))
    }
    
    func testEquality_Equal() {
        let flags1 = Flags()
        let flags2 = Flags()
        XCTAssertEqual(flags1, flags2)
    }
    
    func testEquality_Unequal_carryFlag() {
        let flags1 = Flags(0, 0)
        let flags2 = Flags(1, 0)
        XCTAssertNotEqual(flags1, flags2)
    }
    
    func testEquality_Unequal_equalFlag() {
        let flags1 = Flags(0, 0)
        let flags2 = Flags(0, 1)
        XCTAssertNotEqual(flags1, flags2)
    }
    
    func testEquality_Unequal_DifferentObjects() {
        XCTAssertNotEqual(Flags(), NSString())
    }
    
    func testHash() {
        XCTAssertEqual(Flags().hashValue, Flags().hashValue)
        XCTAssertEqual(Flags(0, 0).hashValue, Flags(0, 0).hashValue)
        XCTAssertEqual(Flags(0, 1).hashValue, Flags(0, 1).hashValue)
        XCTAssertEqual(Flags(1, 0).hashValue, Flags(1, 0).hashValue)
        XCTAssertEqual(Flags(1, 1).hashValue, Flags(1, 1).hashValue)
    }
    
    func testDescription() {
        XCTAssertEqual(Flags(0, 0).description, "{carryFlag: 0, equalFlag: 0}")
        XCTAssertEqual(Flags(0, 1).description, "{carryFlag: 0, equalFlag: 1}")
        XCTAssertEqual(Flags(1, 0).description, "{carryFlag: 1, equalFlag: 0}")
        XCTAssertEqual(Flags(1, 1).description, "{carryFlag: 1, equalFlag: 1}")
    }
}
