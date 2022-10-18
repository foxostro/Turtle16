//
//  GenericFunctionTypeArgumentSolverTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/16/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class GenericFunctionTypeArgumentSolverTests: XCTestCase {
    func testInferTypeArgumentFromExpressionViaIdentifier() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = Expression.TypeOf(Expression.Identifier("U"))
        let actual = solver.inferTypeArgument(concreteArgument: Expression.Identifier("U"),
                                              genericArgument: Expression.Identifier("T"),
                                              solvingFor: Expression.Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testFailToInferTypeArgumentFromExpressionViaIdentifier() {
        let solver = GenericFunctionTypeArgumentSolver()
        let actual = solver.inferTypeArgument(concreteArgument: Expression.Identifier("U"),
                                              genericArgument: Expression.Identifier("V"),
                                              solvingFor: Expression.Identifier("T"))
        XCTAssertNil(actual)
    }
    
    func testInferTypeArgumentFromExpressionViaConstType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = Expression.TypeOf(Expression.ConstType(Expression.Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Expression.Identifier("U"),
                                              genericArgument: Expression.ConstType(Expression.Identifier("T")),
                                              solvingFor: Expression.Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentFromExpressionViaPointerType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = Expression.TypeOf(Expression.PointerType(Expression.Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Expression.Identifier("U"),
                                              genericArgument: Expression.PointerType(Expression.Identifier("T")),
                                              solvingFor: Expression.Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentFromExpressionViaDynamicArrayType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = Expression.TypeOf(Expression.DynamicArrayType(Expression.Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Expression.Identifier("U"),
                                              genericArgument: Expression.DynamicArrayType(Expression.Identifier("T")),
                                              solvingFor: Expression.Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentFromExpressionViaArrayType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = Expression.TypeOf(Expression.ArrayType(count: Expression.Identifier("V"), elementType: Expression.Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Expression.Identifier("U"),
                                              genericArgument: Expression.ArrayType(count: Expression.Identifier("V"), elementType: Expression.Identifier("T")),
                                              solvingFor: Expression.Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testCannotInferTypeArgumentFromCallExpressionWithIncorrectNumberOfArguments() {
        let symbols = SymbolTable()
        let call = Expression.Call(callee: Expression.Identifier("foo"), arguments: [])
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.LiteralInt(0))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = Expression.GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        XCTAssertThrowsError(try solver.inferTypeArguments(call: call,
                                                           genericFunctionType: generic,
                                                           symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "failed to infer the type arguments of the generic function `func foo<T>(a: T) -> T' in a call expression")
        }
    }
    
    func testCannotInferTypeArgumentFromCallExpressionWithNoArguments() {
        let symbols = SymbolTable()
        let call = Expression.Call(callee: Expression.Identifier("foo"), arguments: [])
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: [],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.LiteralInt(0))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = Expression.GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        XCTAssertThrowsError(try solver.inferTypeArguments(call: call,
                                                           genericFunctionType: generic,
                                                           symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "failed to infer the type arguments of the generic function `func foo<T>() -> T' in a call expression")
        }
    }
    
    func testInferOneTypeArgument() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "U", symbol: Symbol(type: .bool(.immutableBool)))
        
        let call = Expression.Call(callee: Expression.Identifier("foo"), arguments: [Expression.Identifier("U")])
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: [],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(Expression.LiteralInt(0))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = Expression.GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        let actual = try solver.inferTypeArguments(call: call,
                                                   genericFunctionType: generic,
                                                   symbols: symbols)
        let expected: [SymbolType] = [.bool(.mutableBool)]
        XCTAssertEqual(actual, expected)
    }
    
    func testInferDifferentSubstitutionsOnEachArgumentButTheEvaluatedTypesAreIdentical() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "U", symbol: Symbol(type: .bool(.immutableBool)))
        symbols.bind(identifier: "V", symbol: Symbol(type: .bool(.immutableBool)))
        
        let call = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [
                                    Expression.Identifier("U"),
                                    Expression.Identifier("V")
                                   ])
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.PrimitiveType(.void),
                                                   arguments: [
                                                    Expression.Identifier("T"),
                                                    Expression.Identifier("T")
                                                   ])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a", "b"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = Expression.GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        let actual = try solver.inferTypeArguments(call: call,
                                                   genericFunctionType: generic,
                                                   symbols: symbols)
        let expected: [SymbolType] = [.bool(.mutableBool)]
        XCTAssertEqual(actual, expected)
    }
        
    func testFailWhenInferDifferentSubstitutionsOnEachArgument() throws {
        // TODO: What if the fully qualified types of `U' and `V' are the same? Need to actually resolve the types to get this right.
        let symbols = SymbolTable()
        symbols.bind(identifier: "U", symbol: Symbol(type: .bool(.immutableBool)))
        symbols.bind(identifier: "V", symbol: Symbol(type: .arithmeticType(.immutableInt(.u16))))
        
        let call = Expression.Call(callee: Expression.Identifier("foo"),
                                   arguments: [
                                    Expression.Identifier("U"),
                                    Expression.Identifier("V")
                                   ])
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.PrimitiveType(.void),
                                                   arguments: [
                                                    Expression.Identifier("T"),
                                                    Expression.Identifier("T")
                                                   ])
        let template = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a", "b"],
                                           typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = Expression.GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        XCTAssertThrowsError(try solver.inferTypeArguments(call: call,
                                                           genericFunctionType: generic,
                                                           symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "failed to infer the type arguments of the generic function `func foo<T>(a: T, b: T) -> void' in a call expression")
        }
    }
}
