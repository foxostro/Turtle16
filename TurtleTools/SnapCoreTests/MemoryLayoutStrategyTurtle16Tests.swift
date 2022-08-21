//
//  MemoryLayoutStrategyTurtle16Tests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class MemoryLayoutStrategyTurtle16Tests: XCTestCase {
    func makeStrategy() -> MemoryLayoutStrategy {
        return MemoryLayoutStrategyTurtle16()
    }
    
    func testSizeOfVoid() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .void), 0)
    }
    
    func testSizeOfU8() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .arithmeticType(.mutableInt(.u8))), 1)
    }
    
    func testSizeOfU16() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .arithmeticType(.mutableInt(.u16))), 1)
    }
    
    func testSizeOfPointer() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .pointer(.void)), 1)
    }
    
    func testSizeOfDynamicArray() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .dynamicArray(elementType: .void)), 2)
    }
    
    func testSizeOfArray() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .array(count: 10, elementType: .arithmeticType(.mutableInt(.u8)))), 10)
    }
    
    func testSizeOfArrayWithIndeterminateSize() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .array(count: nil, elementType: .arithmeticType(.mutableInt(.u8)))), 0)
    }
    
    func testSizeOfUnion() throws {
        let typ: SymbolType = .unionType(UnionType([.arithmeticType(.mutableInt(.u16))]))
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: typ), 2)
    }
    
    func testSizeOfStruct() throws {
        let typ: SymbolType = .structType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage)),
            ("count", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1, storage: .automaticStorage))
        ])))
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: typ), 2)
    }
}
