//
//  StructMemberFunctionCallMatcherTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class StructMemberFunctionCallMatcherTests: XCTestCase {
    func testExample() throws {
        let symbols = Env()
        let fooSymbols = Env()
        let fooType = SymbolType.structType(StructTypeInfo(name: "Foo", fields: fooSymbols))
        let fnType = FunctionTypeInfo(name: "bar", mangledName: "bar", returnType: .void, arguments: [
            .constPointer(fooType.correspondingConstType)
        ])
        fooSymbols.bind(identifier: "bar", symbol: Symbol(type: .function(fnType)))
        symbols.bind(identifier: "Foo", symbolType: fooType)
        symbols.bind(identifier: "foo", symbol: Symbol(type: fooType, offset: 0x1000, qualifier: .staticStorage))
        
        let expr = Call(callee: Get(expr: Identifier("foo"), member: Identifier("bar")), arguments: [])
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let matcher = StructMemberFunctionCallMatcher(call: expr, typeChecker: typeChecker)
        guard let match = try matcher.match() else {
            XCTFail("failed to find a match")
            return
        }
        
        XCTAssertEqual(match.getExpr,  Get(expr: Identifier("foo"), member: Identifier("bar")))
        XCTAssertEqual(match.fnType, fnType)
    }
}
