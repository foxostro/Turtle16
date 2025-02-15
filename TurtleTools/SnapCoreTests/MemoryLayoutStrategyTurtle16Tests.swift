//
//  MemoryLayoutStrategyTurtle16Tests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

final class MemoryLayoutStrategyTurtle16Tests: XCTestCase {
    func testSizeOfVoid() throws {
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: .void), 0)
    }
    
    func testSizeOfU8() throws {
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: .u8), 1)
    }
    
    func testSizeOfU16() throws {
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: .u16), 1)
    }
    
    func testSizeOfPointer() throws {
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: .pointer(.void)), 1)
    }
    
    func testSizeOfDynamicArray() throws {
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: .dynamicArray(elementType: .void)), 2)
    }
    
    func testSizeOfArray() throws {
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: .array(count: 10, elementType: .u8)), 10)
    }
    
    func testSizeOfArrayWithIndeterminateSize() throws {
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: .array(count: nil, elementType: .u8)), 0)
    }
    
    func testSizeOfUnion() throws {
        let typ: SymbolType = .unionType(UnionTypeInfo([.u16]))
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: typ), 2)
    }
    
    func testSizeOfStruct() throws {
        let typ: SymbolType = .structType(StructTypeInfo(name: "Slice", symbols: Env(tuples: [
            ("base", Symbol(type: .u16, offset: 0, storage: .automaticStorage)),
            ("count", Symbol(type: .u16, offset: 1, storage: .automaticStorage))
        ])))
        let strategy = MemoryLayoutStrategyTurtle16()
        XCTAssertEqual(strategy.sizeof(type: typ), 2)
    }
}
