//
//  MangledFunctionNameMapTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/7/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class MangledFunctionNameMapTests: XCTestCase {
    func testNext() {
        let map = MangledFunctionNameMap()
        XCTAssertEqual(map.nextUID(mangledName: "foo"), 0)
        XCTAssertEqual(map.nextUID(mangledName: "bar"), 1)
        XCTAssertEqual(map.nextUID(mangledName: "baz"), 2)
    }
    
    func testLookup() {
        let map = MangledFunctionNameMap()
        let foo = map.nextUID(mangledName: "foo")
        let bar = map.nextUID(mangledName: "bar")
        let baz = map.nextUID(mangledName: "baz")
        XCTAssertEqual(map.lookup(uid: foo), "foo")
        XCTAssertEqual(map.lookup(uid: bar), "bar")
        XCTAssertEqual(map.lookup(uid: baz), "baz")
    }
}
