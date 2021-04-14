//
//  MemoryTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class MemoryTests: XCTestCase {
    func testInitDefault() {
        let memory = Memory()
        XCTAssertEqual(memory.size, 65536)
    }
    
    func testInitWithArray() {
        let memory = Memory([1, 2, 3])
        XCTAssertEqual(memory.size, 3)
        XCTAssertEqual(memory.load(from: 0), 1)
        XCTAssertEqual(memory.load(from: 1), 2)
        XCTAssertEqual(memory.load(from: 2), 3)
    }
    
    func testInitWithAnotherMemory() {
        let memory1 = Memory([1, 2, 3])
        let memory2 = Memory(memory: memory1)
        XCTAssertEqual(memory2.size, 3)
        XCTAssertEqual(memory2.load(from: 0), 1)
        XCTAssertEqual(memory2.load(from: 1), 2)
        XCTAssertEqual(memory2.load(from: 2), 3)
    }
    
    func testInitWithData() {
        let memory1 = Memory(Data([1, 2, 3]))
        XCTAssertEqual(memory1.size, 3)
        XCTAssertEqual(memory1.load(from: 0), 1)
        XCTAssertEqual(memory1.load(from: 1), 2)
        XCTAssertEqual(memory1.load(from: 2), 3)
    }
    
    func testCopy() {
        let memory1 = Memory([1, 2, 3])
        let memory2 = memory1.copy() as! Memory
        XCTAssertEqual(memory2.size, 3)
        XCTAssertEqual(memory2.load(from: 0), 1)
        XCTAssertEqual(memory2.load(from: 1), 2)
        XCTAssertEqual(memory2.load(from: 2), 3)
    }
    
    func testGetData() {
        let memory = Memory([1, 2, 3])
        XCTAssertEqual(memory.data, Data([1, 2, 3]))
    }
    
    func testStore() {
        let memory1 = Memory(Data([1, 2, 3]))
        memory1.store(value: 42, to: 2)
        XCTAssertEqual(memory1.size, 3)
        XCTAssertEqual(memory1.load(from: 0), 1)
        XCTAssertEqual(memory1.load(from: 1), 2)
        XCTAssertEqual(memory1.load(from: 2), 42)
    }
}
