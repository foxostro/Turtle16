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
        let expected = TypeOf(Identifier("U"))
        let actual = solver.inferTypeArgument(concreteArgument: Identifier("U"),
                                              genericArgument: Identifier("T"),
                                              solvingFor: Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testFailToInferTypeArgumentFromExpressionViaIdentifier() {
        let solver = GenericFunctionTypeArgumentSolver()
        let actual = solver.inferTypeArgument(concreteArgument: Identifier("U"),
                                              genericArgument: Identifier("V"),
                                              solvingFor: Identifier("T"))
        XCTAssertNil(actual)
    }
    
    func testInferTypeArgumentFromExpressionViaConstType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = TypeOf(ConstType(Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Identifier("U"),
                                              genericArgument: ConstType(Identifier("T")),
                                              solvingFor: Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentFromExpressionViaMutableType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = TypeOf(MutableType(Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Identifier("U"),
                                              genericArgument: MutableType(Identifier("T")),
                                              solvingFor: Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentFromExpressionViaPointerType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = TypeOf(PointerType(Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Identifier("U"),
                                              genericArgument: PointerType(Identifier("T")),
                                              solvingFor: Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentFromExpressionViaDynamicArrayType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = TypeOf(DynamicArrayType(Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Identifier("U"),
                                              genericArgument: DynamicArrayType(Identifier("T")),
                                              solvingFor: Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testInferTypeArgumentFromExpressionViaArrayType() {
        let solver = GenericFunctionTypeArgumentSolver()
        let expected = TypeOf(ArrayType(count: Identifier("V"), elementType: Identifier("U")))
        let actual = solver.inferTypeArgument(concreteArgument: Identifier("U"),
                                              genericArgument: ArrayType(count: Identifier("V"), elementType: Identifier("T")),
                                              solvingFor: Identifier("T"))
        XCTAssertEqual(actual, expected)
    }
    
    func testCannotInferTypeArgumentFromCallExpressionWithIncorrectNumberOfArguments() {
        let symbols = SymbolTable()
        let call = Call(callee: Identifier("foo"), arguments: [])
        let functionType = FunctionType(name: "foo",
                                                   returnType: Identifier("T"),
                                                   arguments: [Identifier("T")])
        let template = FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a"],
                                           typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(LiteralInt(0))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        XCTAssertThrowsError(try solver.inferTypeArguments(call: call,
                                                           genericFunctionType: generic,
                                                           symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "failed to infer the type arguments of the generic function `func foo[T](a: T) -> T' in a call expression")
        }
    }
    
    func testCannotInferTypeArgumentFromCallExpressionWithNoArguments() {
        let symbols = SymbolTable()
        let call = Call(callee: Identifier("foo"), arguments: [])
        let functionType = FunctionType(name: "foo",
                                                   returnType: Identifier("T"),
                                                   arguments: [])
        let template = FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: [],
                                           typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(LiteralInt(0))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        XCTAssertThrowsError(try solver.inferTypeArguments(call: call,
                                                           genericFunctionType: generic,
                                                           symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "failed to infer the type arguments of the generic function `func foo[T]() -> T' in a call expression")
        }
    }
    
    func testInferOneTypeArgument() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "U", symbol: Symbol(type: .constBool))
        
        let call = Call(callee: Identifier("foo"), arguments: [Identifier("U")])
        let functionType = FunctionType(name: "foo",
                                                   returnType: Identifier("T"),
                                                   arguments: [Identifier("T")])
        let template = FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: [],
                                           typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
                                           body: Block(children: [
                                            Return(LiteralInt(0))
                                           ]),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        let actual = try solver.inferTypeArguments(call: call,
                                                   genericFunctionType: generic,
                                                   symbols: symbols)
        let expected: [SymbolType] = [.bool]
        XCTAssertEqual(actual, expected)
    }
    
    func testInferDifferentSubstitutionsOnEachArgumentButTheEvaluatedTypesAreIdentical() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "U", symbol: Symbol(type: .constBool))
        symbols.bind(identifier: "V", symbol: Symbol(type: .constBool))
        
        let call = Call(callee: Identifier("foo"),
                                   arguments: [
                                    Identifier("U"),
                                    Identifier("V")
                                   ])
        let functionType = FunctionType(name: "foo",
                                                   returnType: PrimitiveType(.void),
                                                   arguments: [
                                                    Identifier("T"),
                                                    Identifier("T")
                                                   ])
        let template = FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a", "b"],
                                           typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        let actual = try solver.inferTypeArguments(call: call,
                                                   genericFunctionType: generic,
                                                   symbols: symbols)
        let expected: [SymbolType] = [.bool]
        XCTAssertEqual(actual, expected)
    }
        
    func testFailWhenInferDifferentSubstitutionsOnEachArgument() throws {
        // TODO: What if the fully qualified types of `U' and `V' are the same? Need to actually resolve the types to get this right.
        let symbols = SymbolTable()
        symbols.bind(identifier: "U", symbol: Symbol(type: .constBool))
        symbols.bind(identifier: "V", symbol: Symbol(type: .arithmeticType(.immutableInt(.u16))))
        
        let call = Call(callee: Identifier("foo"),
                                   arguments: [
                                    Identifier("U"),
                                    Identifier("V")
                                   ])
        let functionType = FunctionType(name: "foo",
                                                   returnType: PrimitiveType(.void),
                                                   arguments: [
                                                    Identifier("T"),
                                                    Identifier("T")
                                                   ])
        let template = FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: functionType,
                                           argumentNames: ["a", "b"],
                                           typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
                                           body: Block(),
                                           visibility: .privateVisibility,
                                           symbols: SymbolTable())
        let generic = GenericFunctionType(template: template)
        let solver = GenericFunctionTypeArgumentSolver()
        XCTAssertThrowsError(try solver.inferTypeArguments(call: call,
                                                           genericFunctionType: generic,
                                                           symbols: symbols)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "failed to infer the type arguments of the generic function `func foo[T](a: T, b: T) -> void' in a call expression")
        }
    }
}
