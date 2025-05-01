//
//  TypeContextTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/7/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import XCTest

final class TypeContextTypeCheckerTests: XCTestCase {
    func testTypeOfAnIdentifierNamingAStruct() {
        let expr = Identifier("foo")
        let typ = StructTypeInfo(name: "foo", fields: Env())
        let symbols = Env(typeDict: ["foo": .structType(typ)])
        let typeChecker = TypeContextTypeChecker(symbols: symbols)
        var result: SymbolType? = nil
        XCTAssertNoThrow(result = try typeChecker.check(expression: expr))
        XCTAssertEqual(result, .structType(typ))
    }
}
