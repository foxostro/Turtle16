//
//  CompilerPassExposeImplicitConversionsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/9/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassExposeImplicitConversionsTests: XCTestCase {
    func testInternalCompilerErrorDueToNoSymbols() {
        let input = Return(LiteralBool(true))
        XCTAssertThrowsError(try input.exposeImplicitConversions()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "internal compiler error: no symbols")
        }
    }
    
    func testCompilationFailsBecauseReturnIsInvalidOutsideFunction() {
        let input = Block(children: [ Return(LiteralBool(true)) ]).reconnect(parent: nil)
        XCTAssertThrowsError(try input.exposeImplicitConversions()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "return is invalid outside of a function")
        }
    }
    
    func testUnexpectedNonVoidReturnValueInVoidFunction() {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.void),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return(ExprUtils.makeU8(value: 1))
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try input.exposeImplicitConversions()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "unexpected non-void return value in void function"
            )
        }
    }
    
    func testNonVoidFunctionShouldReturnAValue() {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.u8),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return()
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try input.exposeImplicitConversions()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "non-void function should return a value")
        }
    }
    
    func testVoidFunctionCanOmitTheExpressionFromTheReturnStatement() throws {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.void),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return()
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, input)
    }
    
    func testFunctionReturnValueHasTypeExactlyMatchingFunctionReturnType() throws {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.u8),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return(ExprUtils.makeU8(value: 1))
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, input)
    }
    
    func testIfReturnValueTypeIsNotExactMatchThenItMustBeImplicitlyConvertible() {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.bool),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return(ExprUtils.makeU8(value: 1))
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try input.exposeImplicitConversions()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert return expression of type `u8' to return type `bool'")
        }
    }
    
    func testInsertConversionWhenReturnValueTypeIsImplicitlyConvertibleToTheReturnType() throws {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.u16),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return(ExprUtils.makeU8(value: 1))
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let expected = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.u16),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return(
                                As(
                                    expr: ExprUtils.makeU8(value: 1),
                                    targetType: PrimitiveType(.u16)
                                )
                            )
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, expected)
    }
    
    func testEmptyStructInitializerExpressionPassesThroughUnmodified() throws {
        let input = Block(
            children: [
                StructDeclaration(identifier: Identifier("Foo"), members: []),
                StructInitializer(identifier: Identifier("Foo"), arguments: [])
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, input)
    }
    
    func testStructInitializerArgumentIsUnmodifiedWhereExactlyMatchingTheTypeOfTheField() throws {
        let input = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("Foo"),
                    members: [
                        StructDeclaration.Member(name: "bar", type: PrimitiveType(.bool))
                    ]
                ),
                StructInitializer(
                    identifier: Identifier("Foo"),
                    arguments: [
                        StructInitializer.Argument(name: "bar", expr: ExprUtils.makeBool(value: false))
                    ]
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, input)
    }
    
    func testInsertExplicitConversionWhereStructInitializerArgumentTypeDoesNotExactlyMatch() throws {
        let input = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("Foo"),
                    members: [
                        StructDeclaration.Member(name: "bar", type: PrimitiveType(.i16))
                    ]
                ),
                StructInitializer(
                    identifier: Identifier("Foo"),
                    arguments: [
                        StructInitializer.Argument(name: "bar", expr: ExprUtils.makeU8(value: 0))
                    ]
                )
            ]
        )
            .reconnect(parent: nil)
        
        let expected = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("Foo"),
                    members: [
                        StructDeclaration.Member(name: "bar", type: PrimitiveType(.i16))
                    ]
                ),
                StructInitializer(
                    identifier: Identifier("Foo"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "bar",
                            expr: As(
                                expr: ExprUtils.makeU8(value: 0),
                                targetType: PrimitiveType(.i16)
                            )
                        )
                    ]
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, expected)
    }
    
    // A function value may be implicitly converted to a pointer in assignment.
    func testImplicitConversionOfFunctionToFunctionPointer() throws {
        let fooTyp = FunctionType(
            name: "foo",
            returnType: PrimitiveType(.void),
            arguments: []
        )
        let shared = [
            FunctionDeclaration(
                identifier: Identifier("foo"),
                functionType: fooTyp,
                argumentNames: [],
                body: Block()
            ),
            VarDeclaration(
                identifier: Identifier("bar"),
                explicitType: PointerType(fooTyp),
                expression: nil,
                storage: .staticStorage(offset: nil),
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: Identifier("bar"),
                    rexpr: Identifier("foo")
                )
            ]
        )
            .reconnect(parent: nil)
        
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Identifier("bar"),
                    rexpr: Unary(
                        op: .ampersand,
                        expression: Identifier("foo")
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, expected)
    }
    
    // A struct value may be implicitly converted to a pointer in assignment.
    func testImplicitConversionOfStructValueToPointerInAssignment() throws {
        let shared = [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: []
            ),
            VarDeclaration(
                identifier: Identifier("bar"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            VarDeclaration(
                identifier: Identifier("baz"),
                explicitType: PointerType(Identifier("Foo")),
                expression: nil,
                storage: .staticStorage(offset: nil),
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: Identifier("baz"),
                    rexpr: Identifier("bar")
                )
            ]
        )
            .reconnect(parent: nil)
        
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Identifier("baz"),
                    rexpr: Unary(
                        op: .ampersand,
                        expression: Identifier("bar")
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.exposeImplicitConversions()
        XCTAssertEqual(actual, expected)
    }
}
