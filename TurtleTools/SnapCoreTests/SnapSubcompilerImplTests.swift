//
//  SnapSubcompilerImplTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerImplTests: XCTestCase {
    func testExample() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        
        func makeImpl() throws {
            let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
                Expression.PointerType(Expression.Identifier("Foo"))
            ])))
            let foo = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                       members: [bar],
                                       visibility: .privateVisibility)
            try SnapSubcompilerTraitDeclaration(globalEnvironment: globalEnvironment).compile(foo)
        }
        try makeImpl()
        
        XCTAssertFalse(globalEnvironment.functionsToCompile.isEmpty)
        guard !globalEnvironment.functionsToCompile.isEmpty else {
            return
        }
        
        let methodType = globalEnvironment.functionsToCompile.removeFirst()
        
        func makeExpectedMethodType(_ globalEnvironment: GlobalEnvironment) -> FunctionType {
            let argTypeExpr = Expression.PointerType(Expression.Identifier("__Foo_object"))
            let argType = try! RvalueExpressionTypeChecker(symbols: globalEnvironment.globalSymbols, globalEnvironment: globalEnvironment).check(expression: argTypeExpr)
            let expectedMethodType = FunctionType(name: "bar",
                                                  mangledName: "____Foo_object_bar",
                                                  returnType: .arithmeticType(.mutableInt(.u8)),
                                                  arguments: [argType])
            return expectedMethodType
        }
        let expectedMethodType = makeExpectedMethodType(globalEnvironment)
        
        XCTAssertEqual(methodType, expectedMethodType)
    }
    
    func testRedefinesExistingSymbol() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let foo = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar, bar],
                                   visibility: .privateVisibility)
        XCTAssertThrowsError(try SnapSubcompilerTraitDeclaration(globalEnvironment: globalEnvironment).compile(foo)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `bar'")
        }
    }
}
