//
//  CompilerPassTestDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassTestDeclarationTests: XCTestCase {
    func testTestDeclarationMustBeAtFileScope() {
        let original = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            FunctionDeclaration(
                identifier: Identifier("puts"),
                functionType: FunctionType(
                    name: "puts",
                    returnType: PrimitiveType(.void),
                    arguments: [DynamicArrayType(PrimitiveType(.u8))]
                ),
                argumentNames: ["s"],
                body: Block(children: [])
            ),
            TestDeclaration(
                name: "bar",
                body: Block(children: [
                    TestDeclaration(
                        name: "baz",
                        body: Block(children: [
                            Assignment(
                                lexpr: Identifier("foo"),
                                rexpr: LiteralInt(42)
                            )
                        ])
                    )
                ])
            )
        ])
        .reconnect(parent: nil)

        let transformer = CompilerPassTestDeclaration(shouldRunSpecificTest: "bar")
        XCTAssertThrowsError(try transformer.visit(original)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "declaration is only valid at file scope")
        }
    }

    func testTestDeclarationsMustHaveUniqueName() {
        let original = Block(children: [
            FunctionDeclaration(
                identifier: Identifier("puts"),
                functionType: FunctionType(
                    name: "puts",
                    returnType: PrimitiveType(.void),
                    arguments: [DynamicArrayType(PrimitiveType(.u8))]
                ),
                argumentNames: ["s"],
                body: Block(children: [])
            ),
            TestDeclaration(name: "bar", body: Block(children: [])),
            TestDeclaration(name: "bar", body: Block(children: []))
        ])
        .reconnect(parent: nil)

        let transformer = CompilerPassTestDeclaration()
        XCTAssertThrowsError(try transformer.visit(original)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "test \"bar\" already exists")
        }
    }

    func testTestsDisappearWhenNotBuildingForTesting() {
        let input = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            TestDeclaration(name: "bar", body: Block(children: []))
        ])
        let expected = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            )
        ])

        let transformer = CompilerPassTestDeclaration(shouldRunSpecificTest: nil)
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.visit(input))

        XCTAssertEqual(actual, expected)
    }

    func testCallMainFunctionWhenNotBuildingForTesting() {
        let input = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            TestDeclaration(name: "bar", body: Block(children: [])),
            FunctionDeclaration(
                identifier: Identifier("main"),
                functionType: FunctionType(
                    name: "main",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [])
            )
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            FunctionDeclaration(
                identifier: Identifier("main"),
                functionType: FunctionType(
                    name: "main",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [])
            ),
            Call(callee: Identifier("main"), arguments: [])
        ])
        .reconnect(parent: nil)

        let transformer = CompilerPassTestDeclaration(shouldRunSpecificTest: nil)
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.visit(input))

        XCTAssertEqual(actual, expected)
    }

    func testTheTestRunnerContainsTheTestBody() {
        let input = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            TestDeclaration(
                name: "bar",
                body: Block(children: [
                    Assignment(
                        lexpr: Identifier("foo"),
                        rexpr: LiteralInt(42)
                    )
                ])
            )
        ])
        let expected = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            FunctionDeclaration(
                identifier: Identifier("__testMain"),
                functionType: FunctionType(
                    name: "__testMain",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [
                    Block(children: [
                        Assignment(
                            lexpr: Identifier("foo"),
                            rexpr: LiteralInt(42)
                        )
                    ]),
                    Call(callee: Identifier("__puts"), arguments: [LiteralString("passed\n")])
                ])
            ),
            Call(callee: Identifier("__testMain"), arguments: [])
        ])

        let transformer = CompilerPassTestDeclaration(shouldRunSpecificTest: "bar")
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.visit(input))

        XCTAssertEqual(actual, expected)
    }

    func testTheTestRunnerContainsTheTestBodyOfSpecificTest() {
        let input = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            TestDeclaration(
                name: "bar",
                body: Block(children: [
                    Assignment(
                        lexpr: Identifier("foo"),
                        rexpr: LiteralInt(42)
                    )
                ])
            ),
            TestDeclaration(
                name: "baz",
                body: Block(children: [
                    Assignment(
                        lexpr: Identifier("foo"),
                        rexpr: LiteralInt(41)
                    )
                ])
            )
        ])
        let expected = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            FunctionDeclaration(
                identifier: Identifier("__testMain"),
                functionType: FunctionType(
                    name: "__testMain",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [
                    Block(children: [
                        Assignment(
                            lexpr: Identifier("foo"),
                            rexpr: LiteralInt(42)
                        )
                    ]),
                    Call(callee: Identifier("__puts"), arguments: [LiteralString("passed\n")])
                ])
            ),
            Call(callee: Identifier("__testMain"), arguments: [])
        ])

        let transformer = CompilerPassTestDeclaration(shouldRunSpecificTest: "bar")
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.visit(input))

        XCTAssertEqual(actual, expected)
    }

    func testDuringTestingCallTestMainNotActualMain() {
        let input = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            TestDeclaration(
                name: "bar",
                body: Block(children: [
                    Assignment(
                        lexpr: Identifier("foo"),
                        rexpr: LiteralInt(42)
                    )
                ])
            ),
            TestDeclaration(
                name: "baz",
                body: Block(children: [
                    Assignment(
                        lexpr: Identifier("foo"),
                        rexpr: LiteralInt(41)
                    )
                ])
            ),
            FunctionDeclaration(
                identifier: Identifier("main"),
                functionType: FunctionType(
                    name: "main",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [])
            )
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            VarDeclaration(
                identifier: Identifier("foo"),
                explicitType: nil,
                expression: LiteralInt(1),
                storage: .staticStorage(offset: nil),
                isMutable: true
            ),
            FunctionDeclaration(
                identifier: Identifier("main"),
                functionType: FunctionType(
                    name: "main",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [])
            ),
            FunctionDeclaration(
                identifier: Identifier("__testMain"),
                functionType: FunctionType(
                    name: "__testMain",
                    returnType: PrimitiveType(.void),
                    arguments: []
                ),
                argumentNames: [],
                body: Block(children: [
                    Block(children: [
                        Assignment(
                            lexpr: Identifier("foo"),
                            rexpr: LiteralInt(42)
                        )
                    ]),
                    Call(callee: Identifier("__puts"), arguments: [LiteralString("passed\n")])
                ])
            ),
            Call(callee: Identifier("__testMain"), arguments: [])
        ])
        .reconnect(parent: nil)

        let transformer = CompilerPassTestDeclaration(shouldRunSpecificTest: "bar")
        var actual: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(actual = try transformer.visit(input))

        XCTAssertEqual(actual, expected)
    }
}
