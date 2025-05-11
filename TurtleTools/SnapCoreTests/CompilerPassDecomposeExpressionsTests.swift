//
//  CompilerPassDecomposeExpressionsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/3/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassDecomposeExpressionsTests: XCTestCase {
    private func AddressOf(_ expr: Expression) -> Unary {
        Unary(op: .ampersand, expression: expr)
    }
    
    private func TempRef(_ i: Int) -> Identifier {
        Identifier("__temp\(i)")
    }
    
    private func Temp(
        i: Int,
        seq: [AbstractSyntaxTreeNode] = [],
        expr: Expression
    ) -> Eseq {
        Temp(i: i, seq: seq, expr: expr, explicitType: nil)
    }
    
    private func Temp(
        i: Int,
        seq: [AbstractSyntaxTreeNode] = [],
        explicitType: Expression
    ) -> Eseq {
        Temp(i: i, seq: seq, expr: nil, explicitType: explicitType)
    }
    
    private func Temp(
        i: Int,
        seq: [AbstractSyntaxTreeNode] = [],
        expr: Expression?,
        explicitType: Expression?
    ) -> Eseq {
        Eseq(
            seq: Seq(
                children: [
                    VarDeclaration(
                        identifier: TempRef(i),
                        expression: expr,
                        isMutable: false
                    )
                ] + seq
            ),
            expr: TempRef(i)
        )
    }
    
    private let a = Identifier("a")
    private let b = Identifier("b")
    private let i = Identifier("i")
    private let bar = Identifier("bar")
    private let baz = Identifier("baz")
    private let foo = Identifier("foo")
    private let Foo = Identifier("Foo")
    private let MyStruct1 = Identifier("MyStruct1")
    private let MyStruct2 = Identifier("MyStruct2")
    private let pointee = Identifier("pointee")
    private let ptr = Identifier("ptr")
    private let u16 = PrimitiveType(.u16)
    private let bool = PrimitiveType(.bool)
    
    func testReturnStatement() throws {
        let input = Block(children: [
            Return(LiteralInt(1000))
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let expected = Block(children: [
            Return(temp0)
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testIfStatement() throws {
        let input = Block(children: [
            If(
                condition: LiteralBool(false),
                then: Block()
            )
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralBool(false))
        let expected = Block(children: [
            If(
                condition: temp0,
                then: Block()
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testWhileStatement() throws {
        let input = Block(children: [
            While(
                condition: LiteralBool(false),
                body: Block()
            )
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralBool(false))
        let expected = Block(children: [
            While(
                condition: temp0,
                body: Block()
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testForInStatement() throws {
        let input = Block(children: [
            ForIn(
                identifier: i,
                sequenceExpr: LiteralString(""),
                body: Block()
            )
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralString(""))
        let expected = Block(children: [
            ForIn(
                identifier: i,
                sequenceExpr: temp0,
                body: Block()
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testMatchStatement() throws {
        let input = Block(children: [
            Match(
                expr: LiteralString(""),
                clauses: [],
                elseClause: nil
            )
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralString(""))
        let expected = Block(children: [
            Match(
                expr: temp0,
                clauses: [],
                elseClause: nil
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssertStatement() throws {
        let shared = [
            VarDeclaration(identifier: a, explicitType: bool)
        ]
        let input = Block(children: shared + [
            Assert(condition: a, message: "")
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let temp1 = Temp(i: 1, expr: Get(expr: temp0, member: pointee))
        let expected = Block(children: shared + [
            Assert(condition: temp1, message: "")
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testGotoIfFalseStatement() throws {
        let shared = [
            VarDeclaration(identifier: a, explicitType: bool)
        ]
        let input = Block(children: shared + [
            GotoIfFalse(condition: a, target: "")
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let temp1 = Temp(i: 1, expr: Get(expr: temp0, member: pointee))
        let expected = Block(children: shared + [
            GotoIfFalse(condition: temp1, target: "")
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testLiteralIntExpression() throws {
        let input = Block(children: [
            LiteralInt(1000)
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            Temp(i: 0, expr: LiteralInt(1000))
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testLiteralBoolExpression() throws {
        let input = Block(children: [
            LiteralBool(true)
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            Temp(i: 0, expr: LiteralBool(true))
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testLiteralStringExpression() throws {
        let input = Block(children: [
            LiteralString("")
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            Temp(i: 0, expr: LiteralString(""))
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testLiteralArrayExpression() throws {
        let input = Block(children: [
            LiteralArray(
                arrayType: ArrayType(
                    count: nil,
                    elementType: PrimitiveType(.u8)
                ),
                elements: []
            )
        ])
        .reconnect(parent: nil)

        let arr = LiteralArray(
            arrayType: ArrayType(
                count: nil,
                elementType: PrimitiveType(.u8)
            ),
            elements: []
        )
        let expected = Block(children: [
            Temp(i: 0, expr: arr)
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testTypeCastExpression() throws {
        let input = Block(children: [
            As(expr: LiteralInt(1000), targetType: u16)
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let temp1 = Temp(i: 1, expr: As(expr: temp0, targetType: u16))
        let expected = Block(children: [
            temp1
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testBitCastExpression() throws {
        let input = Block(children: [
            Bitcast(expr: LiteralInt(1000), targetType: u16)
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let temp1 = Temp(i: 1, expr: Bitcast(expr: temp0, targetType: u16))
        let expected = Block(children: [
            temp1
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testTypeTestExpression() throws {
        let input = Block(children: [
            Is(expr: LiteralBool(false), testType: u16)
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            Temp(i: 0, expr: LiteralBool(false))
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testTypeOfExpression() throws {
        let input = Block(children: [
            TypeOf(
                Binary(
                    op: .plus,
                    left: LiteralInt(1),
                    right: LiteralInt(1)
                )
            )
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            PrimitiveType(.arithmeticType(.compTimeInt(2)))
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testSizeOfExpression_GiveAnExpression() throws {
        let input = Block(children: [
            VarDeclaration(identifier: a, explicitType: u16),
            SizeOf(a)
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            VarDeclaration(identifier: a, explicitType: u16),
            LiteralInt(1)
        ])
        .reconnect(parent: nil)
        
        let compiler = CompilerPassDecomposeExpressions(
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()
        )
        let actual = try compiler.run(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSizeOfExpression_NameAType() throws {
        let input = Block(children: [
            SizeOf(u16)
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            LiteralInt(1)
        ])
        .reconnect(parent: nil)

        let compiler = CompilerPassDecomposeExpressions(
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()
        )
        let actual = try compiler.run(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testIdentifierExpression() throws {
        let shared = [
            VarDeclaration(identifier: a, explicitType: bool)
        ]
        let input = Block(children: shared + [
            a
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let temp1 = Temp(i: 1, expr: Get(expr: temp0, member: pointee))
        let expected = Block(children: shared + [
            temp1
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testUnaryExpression_NegateAnIdentifier() throws {
        let shared = [
            VarDeclaration(identifier: a, explicitType: u16)
        ]
        let input = Block(children: shared + [
            Unary(op: .minus, expression: a)
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let temp1 = Temp(i: 1, expr: Get(expr: temp0, member: pointee))
        let temp2 = Temp(i: 2, expr: Unary(op: .minus, expression: temp1))
        let expected = Block(children: shared + [
            temp2
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    // We cannot further decompose an addressOf operator on a bare identifier.
    func testUnaryExpression_AddressOfIdentifier() throws {
        let input = Block(children: [
            VarDeclaration(identifier: a, explicitType: u16),
            AddressOf(a)
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let expected = Block(children: [
            VarDeclaration(identifier: a, explicitType: u16),
            temp0
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    // We cannot further decompose an addressOf operator on a Get expression.
    func testUnaryExpression_AddressOfGet() throws {
        let input = Block(children: [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: bool
                    )
                ]
            ),
            VarDeclaration(identifier: a, explicitType: Foo),
            AddressOf(Get(expr: a, member: bar))
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let temp1 = Temp(i: 1, expr: AddressOf(Get(expr: temp0, member: bar)))
        let expected = Block(children: [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: bool
                    )
                ]
            ),
            VarDeclaration(identifier: a, explicitType: Foo),
            temp1
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testGetFromBareIdentifier() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: bool
                    )
                ]
            ),
            VarDeclaration(identifier: a, explicitType: Foo)
        ]
        let input = Block(children: shared + [
            Get(expr: a, member: bar)
        ])
        .reconnect(parent: nil)
        
        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let temp1 = Temp(i: 1, expr: AddressOf(Get(expr: temp0, member: bar)))
        let temp2 = Temp(i: 2, expr: Get(expr: temp1, member: pointee))
        let expected = Block(children: shared + [
            temp2
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testGetExpressionToDereferenceSomeSimplePointer() throws {
        let shared = [
            VarDeclaration(
                identifier: ptr,
                explicitType: PointerType(u16),
                isMutable: false
            )
        ]
        let input = Block(children: shared + [
            Get(expr: ptr, member: pointee)
        ])
        .reconnect(parent: nil)
        
        // Compute the address of `ptr`
        let temp0 = Temp(i: 0, expr: AddressOf(ptr))
        
        // Get the address of the object that `ptr` points /to/.
        let temp1 = Temp(i: 1, expr: AddressOf(Get(expr: temp0, member: pointee)))
        
        // Fetch the object from memory that `ptr` points /to/ and copy it into
        // a new temporary value.
        let temp2 = Temp(i: 2, expr: Get(expr: temp1, member: pointee))
        
        let expected = Block(children: shared + [temp2]).reconnect(parent: nil)
        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testGetFromGetExpression() throws {
        let shared = [
            StructDeclaration(
                identifier: MyStruct1,
                members: [
                    StructDeclaration.Member(
                        name: "baz",
                        type: u16
                    )
                ]
            ),
            StructDeclaration(
                identifier: MyStruct2,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: MyStruct1
                    )
                ]
            ),
            VarDeclaration(
                identifier: foo,
                explicitType: MyStruct2,
                isMutable: true
            )
        ]
        let input = Block(children: shared + [
            Get(expr: Get(expr: foo, member: bar), member: baz)
        ])
        .reconnect(parent: nil)
        
        // Compute the address of `foo`
        let temp0 = Temp(i: 0, expr: AddressOf(foo))
        
        // Compute the address of `foo.bar`
        let temp1 = Temp(i: 1, expr: AddressOf(Get(expr: temp0, member: bar)))
        
        // Compute the address of `foo.bar.baz`
        let temp2 = Temp(i: 2, expr: AddressOf(Get(expr: temp1, member: baz)))
        
        // Fetch the value stored at the address contained in the pointer.
        let temp3 = Temp(i: 3, expr: Get(expr: temp2, member: pointee))
        
        let expected = Block(children: shared + [temp3]).reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testCallExpression() throws {
        let input = Block(children: [
            FunctionDeclaration(
                identifier: foo,
                functionType: FunctionType(
                    name: "foo",
                    returnType: u16,
                    arguments: [u16]
                ),
                argumentNames: ["bar"],
                body: Block()
            ),
            Call(
                callee: foo,
                arguments: [ LiteralInt(1000) ]
            )
        ])
        .reconnect(parent: nil)
        
        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let temp1 = Temp(i: 1, expr: Call(callee: foo, arguments: [temp0]))
        let expected = Block(children: [
            FunctionDeclaration(
                identifier: foo,
                functionType: FunctionType(
                    name: "foo",
                    returnType: u16,
                    arguments: [u16]
                ),
                argumentNames: ["bar"],
                body: Block()
            ),
            temp1
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testCallExpression_FunctionPointer() throws {
        let shared = [
            FunctionDeclaration(
                identifier: foo,
                functionType: FunctionType(
                    name: foo.identifier,
                    returnType: u16,
                    arguments: [u16]
                ),
                argumentNames: [bar.identifier],
                body: Block()
            )
        ]
        let input = Block(children: shared + [
            VarDeclaration(identifier: ptr, expression: AddressOf(foo)),
            Call(callee: ptr, arguments: [LiteralInt(1000)])
        ])
        .reconnect(parent: nil)
        
        let temp0 = Temp(i: 0, expr: AddressOf(foo))
        let temp1 = Temp(i: 1, expr: AddressOf(ptr))
        let temp2 = Temp(i: 2, expr: Get(expr: temp1, member: pointee))
        let temp3 = Temp(i: 3, expr: LiteralInt(1000))
        let temp4 = Temp(i: 4, expr: Call(callee: temp2, arguments: [temp3]))
        let expected = Block(children: shared + [
            VarDeclaration(identifier: ptr, expression: temp0),
            temp4
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testBinaryExpression() throws {
        let input = Block(children: [
            VarDeclaration(identifier: a, explicitType: u16),
            VarDeclaration(identifier: b, explicitType: u16),
            Binary(
                op: .plus,
                left: a,
                right: b
            )
        ])
        .reconnect(parent: nil)
        
        let temp0 = Temp(i: 0, expr: AddressOf(a))
        let temp1 = Temp(i: 1, expr: Get(expr: temp0, member: pointee))
        let temp2 = Temp(i: 2, expr: AddressOf(b))
        let temp3 = Temp(i: 3, expr: Get(expr: temp2, member: pointee))
        let temp4 = Temp(i: 4, expr: Binary(op: .plus, left: temp1, right: temp3))
        let expected = Block(children: [
            VarDeclaration(identifier: a, explicitType: u16),
            VarDeclaration(identifier: b, explicitType: u16),
            temp4
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_RightHandSideIsLiteralValue() throws {
        let shared = [
            VarDeclaration(identifier: foo, explicitType: u16, isMutable: true),
        ]
        let input = Block(children: shared + [
            Assignment(lexpr: foo, rexpr: LiteralInt(1000))
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(foo))
        let temp1 = Temp(i: 1, expr: LiteralInt(1000))
        let temp2 = Temp(
            i: 2,
            expr: Assignment(
                lexpr: Get(expr: temp0, member: pointee),
                rexpr: temp1
            )
        )
        let expected = Block(children: shared + [
            temp2
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_LeftHandSideIsBareIdentifier() throws {
        let shared = [
            VarDeclaration(identifier: bar, explicitType: u16),
            VarDeclaration(identifier: foo, explicitType: u16, isMutable: true),
        ]
        let input = Block(children: shared + [
            Assignment(lexpr: foo, rexpr: bar)
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(foo))
        let temp1 = Temp(i: 1, expr: AddressOf(bar))
        let temp2 = Temp(
            i: 2,
            expr: Assignment(
                lexpr: Get(expr: temp0, member: pointee),
                rexpr: Get(expr: temp1, member: pointee)
            )
        )
        let expected = Block(children: shared + [
            temp2
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_RightHandSideIsStructType() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: u16
                    )
                ]
            ),
            VarDeclaration(identifier: bar, explicitType: Foo),
            VarDeclaration(identifier: foo, explicitType: Foo, isMutable: true),
        ]
        let input = Block(children: shared + [
            Assignment(lexpr: foo, rexpr: bar)
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: AddressOf(foo))
        let temp1 = Temp(i: 1, expr: AddressOf(bar))
        let temp2 = Temp(
            i: 2,
            expr: Assignment(
                lexpr: Get(expr: temp0, member: pointee),
                rexpr: Get(expr: temp1, member: pointee)
            )
        )
        let expected = Block(children: shared + [
            temp2
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_LeftHandSideIsGetExpression() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: u16
                    )
                ]
            ),
            VarDeclaration(identifier: foo, explicitType: Foo, isMutable: true)
        ]
        let input = Block(children: shared + [
            Assignment(
                lexpr: Get(expr: foo, member: bar),
                rexpr: LiteralInt(1000)
            )
        ])
        .reconnect(parent: nil)
        
        let temp0 = Temp(i: 0, expr: AddressOf(foo))
        let temp1 = Temp(i: 1, expr: AddressOf(Get(expr: temp0, member: bar)))
        let temp2 = Temp(i: 2, expr: LiteralInt(1000))
        let temp3 = Temp(
            i: 3,
            expr: Assignment(
                lexpr: Get(expr: temp1, member: pointee),
                rexpr: temp2
            )
        )
        let expected = Block(children: shared + [
            temp3
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_LeftHandSideIsGetExpressionChain_2Deep() throws {
        let shared = [
            StructDeclaration(
                identifier: MyStruct1,
                members: [
                    StructDeclaration.Member(
                        name: "baz",
                        type: u16
                    )
                ]
            ),
            StructDeclaration(
                identifier: MyStruct2,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: MyStruct1
                    )
                ]
            ),
            VarDeclaration(
                identifier: foo,
                explicitType: MyStruct2,
                isMutable: true
            )
        ]
        let input = Block(children: shared + [
            Assignment(
                lexpr: Get(expr: Get(expr: foo, member: bar), member: baz),
                rexpr: LiteralInt(1000)
            )
        ])
        .reconnect(parent: nil)
        
        let temp0 = Temp(i: 0, expr: AddressOf(foo))
        let temp1 = Temp(i: 1, expr: AddressOf(Get(expr: temp0, member: bar)))
        let temp2 = Temp(i: 2, expr: AddressOf(Get(expr: temp1, member: baz)))
        let temp3 = Temp(i: 3, expr: LiteralInt(1000))
        let temp4 = Temp(
            i: 4,
            expr: Assignment(
                lexpr: Get(expr: temp2, member: pointee),
                rexpr: temp3)
        )
        let expected = Block(children: shared + [
            temp4
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testStructInitializerExpression_ZeroMembers() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: []
            )
        ]
        let input = Block(children: shared + [
            StructInitializer(
                identifier: Foo,
                arguments: []
            )
        ])
        .reconnect(parent: nil)
        
        let expected = Block(children: shared + [
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(identifier: TempRef(0), explicitType: Foo)
                ]),
                expr: TempRef(0)
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testStructInitializerExpression_OneMember() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: bool
                    )
                ]
            )
        ]
        let input = Block(children: shared + [
            StructInitializer(
                identifier: Foo,
                arguments: [
                    StructInitializer.Argument(
                        name: "bar",
                        expr: LiteralBool(false)
                    )
                ]
            )
        ])
        .reconnect(parent: nil)
        
        let temp1 = Temp(i: 1, expr: Unary(op: .ampersand, expression: TempRef(0)))
        let temp2 = Temp(
            i: 2,
            expr: Unary(
                op: .ampersand,
                expression: Get(expr: temp1, member: bar)
            )
        )
        let temp3 = Temp(i: 3, expr: LiteralBool(false))
        let temp4 = Temp(
            i: 4,
            expr: InitialAssignment(
                lexpr: Get(expr: temp2, member: pointee),
                rexpr: temp3
            )
        )
        let expected = Block(children: shared + [
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(identifier: TempRef(0), explicitType: Foo),
                    temp4
                ]),
                expr: TempRef(0)
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testStructInitializerExpression_TwoMembers() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: foo.identifier,
                        type: bool
                    ),
                    StructDeclaration.Member(
                        name: bar.identifier,
                        type: bool
                    )
                ]
            )
        ]
        let input = Block(children: shared + [
            StructInitializer(
                identifier: Foo,
                arguments: [
                    StructInitializer.Argument(
                        name: foo.identifier,
                        expr: LiteralBool(false)
                    ),
                    StructInitializer.Argument(
                        name: bar.identifier,
                        expr: LiteralBool(true)
                    )
                ]
            )
        ])
        .reconnect(parent: nil)
        
        let temp1 = Temp(i: 1, expr: Unary(op: .ampersand, expression: TempRef(0)))
        let temp2 = Temp(
            i: 2,
            expr: Unary(
                op: .ampersand,
                expression: Get(expr: temp1, member: foo)
            )
        )
        let temp3 = Temp(i: 3, expr: LiteralBool(false))
        let temp4 = Temp(
            i: 4,
            expr: InitialAssignment(
                lexpr: Get(expr: temp2, member: pointee),
                rexpr: temp3
            )
        )
        let temp5 = Temp(i: 5, expr: Unary(op: .ampersand, expression: TempRef(0)))
        let temp6 = Temp(
            i: 6,
            expr: Unary(
                op: .ampersand,
                expression: Get(expr: temp5, member: bar)
            )
        )
        let temp7 = Temp(i: 7, expr: LiteralBool(true))
        let temp8 = Temp(
            i: 8,
            expr: InitialAssignment(
                lexpr: Get(expr: temp6, member: pointee),
                rexpr: temp7
            )
        )
        let expected = Block(children: shared + [
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(identifier: TempRef(0), explicitType: Foo),
                    temp4,
                    temp8
                ]),
                expr: TempRef(0)
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
}

private extension VarDeclaration {
    convenience init(
        identifier: Identifier,
        explicitType: Expression? = nil,
        expression: Expression? = nil,
        storage: SymbolStorage = .automaticStorage(offset: nil),
        isMutable: Bool = false
    ) {
        self.init(
            sourceAnchor: nil,
            identifier: identifier,
            explicitType: explicitType,
            expression: expression,
            storage: storage,
            isMutable: isMutable,
            visibility: .privateVisibility)
    }
}
