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

class StructMemberFunctionCallMatcherTests: XCTestCase {
    func testExample() throws {
        let globalSymbols = SymbolTable()
        let fooSymbols = SymbolTable()
        let fooType = SymbolType.structType(StructType(name: "Foo", symbols: fooSymbols))
        let fnType = FunctionType(name: "bar", mangledName: "bar", returnType: .void, arguments: [
            .constPointer(fooType.correspondingConstType)
        ])
        fooSymbols.bind(identifier: "bar", symbol: Symbol(type: .function(fnType)))
        globalSymbols.bind(identifier: "Foo", symbolType: fooType)
        globalSymbols.bind(identifier: "foo", symbol: Symbol(type: fooType, offset: 0x1000, storage: .staticStorage))
        
        let expr = Expression.Call(callee: Expression.Get(expr: Expression.Identifier("foo"), member: Expression.Identifier("bar")), arguments: [])
        let typeChecker = RvalueExpressionTypeChecker(symbols: globalSymbols)
        let matcher = StructMemberFunctionCallMatcher(call: expr, typeChecker: typeChecker)
        guard let match = try matcher.match() else {
            XCTFail("failed to find a match")
            return
        }
        
        XCTAssertEqual(match.getExpr,  Expression.Get(expr: Expression.Identifier("foo"), member: Expression.Identifier("bar")))
        XCTAssertEqual(match.fnType, fnType)
    }
}
