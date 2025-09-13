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

extension VarDeclaration {
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
            visibility: .privateVisibility
        )
    }
}

final class CompilerPassDecomposeExpressionsTests: XCTestCase {
    var symbols: Env!
    var staticStorageFrame: Frame!
    var memoryLayoutStrategy: (any MemoryLayoutStrategy)!
    var typeContext: TypeContextTypeChecker!
    
    public override func setUp() {
        symbols = Env()
        staticStorageFrame = Frame()
        memoryLayoutStrategy = MemoryLayoutStrategyNull()
        typeContext = TypeContextTypeChecker(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
    }
    
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
        let tempDecl = try? VarDeclaration(
            identifier: TempRef(i),
            explicitType: explicitType,
            expression: expr,
            isMutable: false
        )
            .inferExplicitType(typeContext)
            .breakOutInitialAssignment()
        guard let tempDecl else {
            fatalError("""
            ** Malformed Unit Test! **
            
            We expect the call to `inferExplicitType()` to throw in cases where
            it would be necessary to consult the environment to determine the
            type of the expression. In this case, the unit test should make sure
            to specify `explicitType`.
            """)
        }
        return Eseq(seq: tempDecl, expr: TempRef(i))
    }

    private let a = Identifier("a")
    private let b = Identifier("b")
    private let bar = Identifier("bar")
    private let baz = Identifier("baz")
    private let bool = PrimitiveType(.bool)
    private let count = Identifier("count")
    private let foo = Identifier("foo")
    private let Foo = Identifier("Foo")
    private let i = Identifier("i")
    private let MyStruct1 = Identifier("MyStruct1")
    private let MyStruct2 = Identifier("MyStruct2")
    private let pointee = Identifier("pointee")
    private let ptr = Identifier("ptr")
    private let u8 = PrimitiveType(.u8)
    private let u16 = PrimitiveType(.u16)

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
        let input = Block(
            children: [
                Assert(condition: LiteralBool(true), message: "")
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralBool(true))
        let expected = Block(
            children: [
                Assert(condition: temp0, message: "")
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testGotoIfFalseStatement() throws {
        let input = Block(
            children: [
                GotoIfFalse(condition: LiteralBool(true), target: "")
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralBool(true))
        let expected = Block(
            children: [
                GotoIfFalse(condition: temp0, target: "")
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testLiteralIntExpression() throws {
        let input = Block(children: [
            LiteralInt(1000)
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, input)
    }

    func testLiteralBoolExpression() throws {
        let input = Block(children: [
            LiteralBool(true)
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, input)
    }

    func testLiteralStringExpression() throws {
        let input = Block(children: [
            LiteralString("")
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, input)
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

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, input)
    }
    
    func testLiteralArrayExpression_MoreThanZeroElements() throws {
        let arrTyp = ArrayType(
            count: LiteralInt(1),
            elementType: PrimitiveType(.u16)
        )
        let shared = [
            VarDeclaration(
                identifier: foo,
                explicitType: arrTyp,
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
        ]
        let input = Block(
            children: shared + [
                InitialAssignment(
                    lexpr: foo,
                    rexpr: LiteralArray(
                        arrayType: arrTyp,
                        elements: [
                            LiteralInt(10)
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let expected = Block(children: shared + [
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: TempRef(0),
                        explicitType: ConstType(
                            PointerType(
                                ArrayType(
                                    count: LiteralInt(1),
                                    elementType: ConstType(u16)
                                )
                            )
                        ),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    ),
                    InitialAssignment(
                        lexpr: TempRef(0),
                        rexpr: AddressOf(foo)
                    ),
                    InitialAssignment(
                        lexpr: Get(
                            expr: Temp(
                                i: 2,
                                expr: AddressOf(
                                    Subscript(
                                        subscriptable: TempRef(0),
                                        argument: Temp(i: 1, expr: LiteralInt(0))
                                    )
                                ),
                                explicitType: ConstType(PointerType(ConstType(u16)))
                            ),
                            member: pointee
                        ),
                        rexpr: Temp(i: 3, expr: LiteralInt(10))
                    )
                ]),
                expr: Get(
                    expr: TempRef(0),
                    member: pointee
                )
            )
        ])

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testTypeCastExpression() throws {
        let input = Block(children: [
            As(expr: LiteralInt(1000), targetType: u16)
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let expected = Block(children: [
            As(expr: temp0, targetType: u16)
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
        let expected = Block(children: [
            Bitcast(expr: temp0, targetType: u16)
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // Decomposing a bare identifier yields the identifier itself again.
    // If the identifier is for a non-escaping variable of a primitive type then
    // the hope is that this allows it to be mapped directly to a Tack register
    // in a later compilation step. For other variables, which must be
    // materialized in memory, the identifier will eventually be replaced with
    // code to compute the address and access memory.
    func testIdentifierExpression() throws {
        let shared = [
            VarDeclaration(identifier: a, explicitType: bool)
        ]
        let input = Block(children: shared + [a]).reconnect(parent: nil)
        
        let expected = Block(children: shared + [a]).reconnect(parent: nil)
        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // Applying a unary operator to an identifier yields the same expression
    // again too. This is because the identifier cannot be extracted in any way
    // without introducing another identifier, leaving us in the same position.
    func testUnaryExpression_NegateAnIdentifier() throws {
        let shared = [
            VarDeclaration(identifier: a, explicitType: u16)
        ]
        let input = Block(
            children: shared + [
                Unary(op: .minus, expression: a)
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: a, explicitType: ConstType(u16))
        let expected = Block(
            children: shared + [
                Unary(op: .minus, expression: temp0)
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // We cannot further decompose an addressOf operator on a bare identifier.
    // The reason for this is the same as the reasons relating to the negation
    // operator.
    func testUnaryExpression_AddressOfIdentifier() throws {
        let input = Block(children: [
            VarDeclaration(identifier: a, explicitType: u16),
            AddressOf(a)
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, input)
    }
    
    // Applying a unary operator to most other expressions causes the object of
    // the expression to be extracted to a temporary value.
    func testUnaryExpression_NegateAnExpression() throws {
        let input = Block(
            children: [
                Unary(op: .minus, expression: LiteralInt(1000))
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let expected = Block(
            children: [
                Unary(op: .minus, expression: temp0)
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // Expressions of the form `AddressOf(Get(obj, member))` cannot be further
    // decomposed. The expression for the object can possibly be decomposed via
    // a pointer, of course; but, once made irreducible, we can't do anything
    // with the rest of the expression.
    // The AddressOf operator wants to get the address of that field in memory,
    // not the value of the field. The Get expression cannot be further
    // decomposed without changing this meaning. For example, if we were to
    // extract the value of the Get expression to a temporary variable then the
    // AddressOf operator would be getting the address of the temporary, not of
    // the desired field.
    func testUnaryExpression_AddressOfGet() throws {
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
            VarDeclaration(identifier: a, explicitType: PointerType(Foo))
        ]
        let input = Block(children: shared + [
            AddressOf(Get(expr: a, member: bar))
        ])
        .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                AddressOf(
                    Get(
                        expr: Temp(
                            i: 0,
                            expr: a,
                            explicitType: ConstType(PointerType(Foo))
                        ),
                        member: bar
                    )
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    // In expressions of the form `Get(object, member)`, where the object is a
    // bare identifier then the expression is irreducible.
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
            VarDeclaration(identifier: a, explicitType: PointerType(Foo))
        ]
        let input = Block(
            children: shared + [
                Get(expr: a, member: bar)
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                Get(
                    expr: Temp(
                        i: 0,
                        expr: a,
                        explicitType: ConstType(PointerType(Foo))
                    ),
                    member: bar
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // Expressions which chain or nest Get expressions may be decomposed by
    // extracting each object expression to a new temporary value via a pointer
    // to the object. In each case where the object is already known to be of a
    // non-primitive type, (i.e., struct) the object must be materialized in
    // memory so that it has a memory address. We can apply the AddressOf
    // operator to take the pointer without any problems.
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
                explicitType: PointerType(MyStruct2),
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Get(expr: AddressOf(Get(expr: foo, member: bar)), member: baz)
            ]
        )
        .reconnect(parent: nil)
        
        let temp0 = Temp(i: 0, expr: foo, explicitType: ConstType(PointerType(MyStruct2)))
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(Get(expr: temp0, member: bar)),
            explicitType: ConstType(PointerType(MyStruct1))
        )
        let expected = Block(
            children: shared + [
                Get(expr: temp1, member: baz)
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // For a Call expression applied to a function identifier, extract each
    // argument to a new temporary value of an appropriate type matching the
    // function parameter type.
    func testCallExpression() throws {
        let shared = [
            FunctionDeclaration(
                identifier: foo,
                functionType: FunctionType(
                    name: "foo",
                    returnType: u16,
                    arguments: [u16]
                ),
                argumentNames: ["bar"],
                body: Block()
            )
        ]
        let input = Block(children: shared + [
            Call(
                callee: foo,
                arguments: [LiteralInt(1000)]
            )
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let expected = Block(children: shared + [
            Call(callee: foo, arguments: [temp0])
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // For a Call expression applied to a function pointer, extract each
    // argument to a new temporary value of an appropriate type matching the
    // function parameter type. Extract the function pointer expression to a
    // new temporary pointer value, and call through the temporary pointer.
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
            ),
            VarDeclaration(identifier: ptr, expression: AddressOf(foo))
        ]
        let input = Block(
            children: shared + [
                Call(callee: ptr, arguments: [LiteralInt(1000)])
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let temp1 = Temp(
            i: 1,
            expr: ptr,
            explicitType: ConstType(
                PointerType(
                    FunctionType(
                        name: nil,
                        returnType: u16,
                        arguments: [u16]
                    )
                )
            )
        )
        let expected = Block(
            children: shared + [
                Call(callee: temp1, arguments: [temp0])
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinaryExpression() throws {
        let shared = [
            VarDeclaration(identifier: a, explicitType: u16),
            VarDeclaration(identifier: b, explicitType: u16)
        ]
        let input = Block(children: shared + [
            Binary(op: .plus, left: LiteralInt(1000), right: LiteralInt(2000))
        ])
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let temp1 = Temp(i: 1, expr: LiteralInt(2000))
        let expected = Block(children: shared + [
            Binary(op: .plus, left: temp0, right: temp1)
        ])
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // For an assignment where the left-hand side is a bare identifier, we need
    // only extract the right-hand side to a new temporary value. The assignment
    // itself will be lowered in a subsequent compiler pass which would take
    // into consideration how to compute the address of the variable, if it has
    // an address. We defer that work here.
    func testAssignmentExpression_RightHandSideIsLiteralValue() throws {
        let shared = [
            VarDeclaration(identifier: foo, explicitType: u16, isMutable: true)
        ]
        let input = Block(
            children: shared + [
                Assignment(lexpr: foo, rexpr: LiteralInt(1000))
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(1000))
        let expected = Block(
            children: shared + [
                Assignment(lexpr: foo, rexpr: temp0)
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // For the case of an assignment where the right-hand side is a bare
    // identifier of some primitive type is basically the same as the above case
    // where the right-hand side is a literal integer value. Extract the
    // right-hand side to a temporary value and otherwise leave the assignment
    // expression to be lowered in a subsequent compiler pass.
    func testAssignmentExpression_RightHandSideIsIdentifierOfPrimitiveType() throws {
        let shared = [
            VarDeclaration(identifier: bar, explicitType: u16),
            VarDeclaration(identifier: foo, explicitType: u16, isMutable: true)
        ]
        let input = Block(
            children: shared + [
                Assignment(lexpr: foo, rexpr: bar)
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(
            i: 0,
            expr: bar,
            explicitType: ConstType(u16)
        )
        let expected = Block(
            children: shared + [
                Assignment(lexpr: foo, rexpr: temp0)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    // For the case where the left-hand side is an identifier of a non-primitive
    // object, we know the object must be materialized in memory. Extract a
    // pointer to the object and dereference it at the site of the assignment
    // expression. Ditto the right-hand side.
    //
    // This pattern will basically be lowered to a memcpy in a later pass:
    //    Assignment(
    //        lexpr: Get(expr: _, member: pointee),
    //        rexpr: Get(expr: _, member: pointee)
    //    )
    func testAssignmentExpression_LeftHandSideIsNonPrimitiveObject() throws {
        let shared = [
            StructDeclaration(identifier: Foo, members: []),
            VarDeclaration(identifier: foo, explicitType: Foo, isMutable: true),
            VarDeclaration(identifier: bar, explicitType: Foo, isMutable: true)
        ]
        let input = Block(
            children: shared + [
                Assignment(lexpr: foo, rexpr: bar)
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(
            i: 0,
            expr: AddressOf(foo),
            explicitType: ConstType(PointerType(Foo))
        )
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(bar),
            explicitType: ConstType(PointerType(Foo))
        )
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: temp0, member: pointee),
                    rexpr: Get(expr: temp1, member: pointee)
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    // For the case of an assignment where the left-hand side is a Get
    // expression then we know that Get expression's object must be materialized
    // in memory. We can extract the object to a new temporary value via a
    // pointer. We can extract the Get expression to a new temporary pointer as
    // well, and we refer to it on the left-hand side through a dereference.
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
            VarDeclaration(identifier: foo, explicitType: PointerType(Foo), isMutable: true)
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: foo, member: bar),
                    rexpr: LiteralInt(1000)
                )
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(
            i: 0,
            expr: foo,
            explicitType: ConstType(PointerType(Foo))
        )
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(Get(expr: temp0, member: bar)),
            explicitType: ConstType(PointerType(u16))
        )
        let temp2 = Temp(i: 2, expr: LiteralInt(1000))
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: temp1, member: pointee),
                    rexpr: temp2
                )
            ]
        )
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
                explicitType: PointerType(MyStruct2),
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(
                        expr: AddressOf(Get(expr: foo, member: bar)),
                        member: baz
                    ),
                    rexpr: LiteralInt(1000)
                )
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(
            i: 0,
            expr: foo,
            explicitType: ConstType(PointerType(MyStruct2))
        )
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(Get(expr: temp0, member: bar)),
            explicitType: ConstType(PointerType(MyStruct1))
        )
        let temp2 = Temp(
            i: 2,
            expr: AddressOf(Get(expr: temp1, member: baz)),
            explicitType: ConstType(PointerType(u16))
        )
        let temp3 = Temp(i: 3, expr: LiteralInt(1000))
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: temp2, member: pointee),
                    rexpr: temp3
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testAssignmentExpression_RightHandSideIsArrayLiteralValue() throws {
        let arrType = ArrayType(
            count: LiteralInt(3),
            elementType: u16
        )
        let shared = [
            VarDeclaration(
                identifier: foo,
                explicitType: ArrayType(
                    count: LiteralInt(3),
                    elementType: u16
                ),
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: foo,
                    rexpr: LiteralArray(
                        arrayType: arrType,
                        elements: [
                            LiteralInt(1000),
                            LiteralInt(2000),
                            LiteralInt(3000)
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                Eseq(
                    seq: Seq(
                        children: [
                            VarDeclaration(
                                identifier: TempRef(0),
                                explicitType: ConstType(PointerType(arrType))
                            ),
                            InitialAssignment(
                                lexpr: TempRef(0),
                                rexpr: AddressOf(foo)
                            ),
                            InitialAssignment(
                                lexpr: Get(
                                    expr: Temp(
                                        i: 2,
                                        expr: AddressOf(
                                            Subscript(
                                                subscriptable: TempRef(0),
                                                argument: Temp(i: 1, expr: LiteralInt(0))
                                            )
                                        ),
                                        explicitType: ConstType(PointerType(u16))
                                    ),
                                    member: pointee
                                ),
                                rexpr: Temp(i: 3, expr: LiteralInt(1000))
                            ),
                            InitialAssignment(
                                lexpr: Get(
                                    expr: Temp(
                                        i: 5,
                                        expr: AddressOf(
                                            Subscript(
                                                subscriptable: TempRef(0),
                                                argument: Temp(i: 4, expr: LiteralInt(1))
                                            )
                                        ),
                                        explicitType: ConstType(PointerType(u16))
                                    ),
                                    member: pointee
                                ),
                                rexpr: Temp(i: 6, expr: LiteralInt(2000))
                            ),
                            InitialAssignment(
                                lexpr: Get(
                                    expr: Temp(
                                        i: 8,
                                        expr: AddressOf(
                                            Subscript(
                                                subscriptable: TempRef(0),
                                                argument: Temp(i: 7, expr: LiteralInt(2))
                                            )
                                        ),
                                        explicitType: ConstType(PointerType(u16))
                                    ),
                                    member: pointee
                                ),
                                rexpr: Temp(i: 9, expr: LiteralInt(3000))
                            )
                        ]
                    ),
                    expr: Get(expr: TempRef(0), member: pointee)
                )
            ]
        )
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
        let input = Block(
            children: shared + [
                StructInitializer(
                    identifier: Foo,
                    arguments: []
                )
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: TempRef(0),
                            explicitType: Foo
                        )
                    ]),
                    expr: TempRef(0)
                )
            ]
        )
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
        let input = Block(
            children: shared + [
                StructInitializer(
                    identifier: Foo,
                    arguments: [
                        StructInitializer.Argument(
                            name: "bar",
                            expr: LiteralBool(false)
                        )
                    ]
                )
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: TempRef(0),
                            explicitType: Foo
                        ),
                        VarDeclaration(
                            identifier: TempRef(1),
                            explicitType: ConstType(PointerType(ConstType(Foo)))
                        ),
                        InitialAssignment(
                            lexpr: TempRef(1),
                            rexpr: AddressOf(TempRef(0))
                        ),
                        InitialAssignment(
                            lexpr: Get(
                                expr: Temp(
                                    i: 2,
                                    expr: AddressOf(Get(expr: TempRef(1), member: bar)),
                                    explicitType: ConstType(PointerType(ConstType(bool)))
                                ),
                                member: pointee
                            ),
                            rexpr: Temp(i: 3, expr: LiteralBool(false))
                        )
                    ]),
                    expr: TempRef(0)
                )
            ]
        )
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
        let input = Block(
            children: shared + [
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
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: TempRef(0),
                            explicitType: Foo
                        ),
                        VarDeclaration(
                            identifier: TempRef(1),
                            explicitType: ConstType(PointerType(ConstType(Foo)))
                        ),
                        InitialAssignment(
                            lexpr: TempRef(1),
                            rexpr: AddressOf(TempRef(0))
                        ),
                        InitialAssignment(
                            lexpr: Get(
                                expr: Temp(
                                    i: 2,
                                    expr: AddressOf(Get(expr: TempRef(1), member: foo)),
                                    explicitType: ConstType(PointerType(ConstType(bool)))
                                ),
                                member: pointee
                            ),
                            rexpr: Temp(i: 3, expr: LiteralBool(false))
                        ),
                        InitialAssignment(
                            lexpr: Get(
                                expr: Temp(
                                    i: 4,
                                    expr: AddressOf(Get(expr: TempRef(1), member: bar)),
                                    explicitType: ConstType(PointerType(ConstType(bool)))
                                ),
                                member: pointee
                            ),
                            rexpr: Temp(i: 5, expr: LiteralBool(true))
                        )
                    ]),
                    expr: TempRef(0)
                )
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testArraySubscriptExpression() throws {
        let shared = [
            VarDeclaration(
                identifier: foo,
                explicitType: ArrayType(
                    count: LiteralInt(1),
                    elementType: u16
                ),
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Subscript(
                    subscriptable: foo,
                    argument: LiteralInt(0)
                )
            ]
        )
            .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(0))
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(foo),
            explicitType: ConstType(
                PointerType(
                    ArrayType(
                        count: LiteralInt(1),
                        elementType: u16
                    )
                )
            )
        )
        let expected = Block(
            children: shared + [
                Subscript(
                    subscriptable: Get(
                        expr: temp1,
                        member: pointee
                    ),
                    argument: temp0
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testAssignmentExpression_LeftHandSideIsArraySubscript() throws {
        let shared = [
            VarDeclaration(
                identifier: foo,
                explicitType: ArrayType(
                    count: LiteralInt(1),
                    elementType: u16
                ),
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: Subscript(
                        subscriptable: foo,
                        argument: LiteralInt(0)
                    ),
                    rexpr: LiteralInt(1000)
                )
            ]
        )
        .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(0))
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(foo),
            explicitType: ConstType(
                PointerType(
                    ArrayType(
                        count: LiteralInt(1),
                        elementType: u16
                    )
                )
            )
        )
        let temp2 = Temp(
            i: 2,
            expr: AddressOf(
                Subscript(
                    subscriptable: Get(expr: temp1, member: pointee),
                    argument: temp0
                )
            ),
            explicitType: ConstType(PointerType(u16))
        )
        let temp3 = Temp(i: 3, expr: LiteralInt(1000))
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: temp2, member: pointee),
                    rexpr: temp3
                )
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testAssignmentExpression_RightHandSideIsArraySubscript() throws {
        let shared = [
            VarDeclaration(identifier: foo, explicitType: u16, isMutable: true),
            VarDeclaration(
                identifier: bar,
                explicitType: ArrayType(
                    count: LiteralInt(1),
                    elementType: u16
                )
            )
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: foo,
                    rexpr: Subscript(
                        subscriptable: bar,
                        argument: LiteralInt(0)
                    )
                )
            ]
        )
            .reconnect(parent: nil)

        let temp0 = Temp(i: 0, expr: LiteralInt(0))
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(bar),
            explicitType: ConstType(
                PointerType(
                    ArrayType(
                        count: LiteralInt(1),
                        elementType: ConstType(u16)
                    )
                )
            )
        )
        let temp2 = Temp(
            i: 2,
            expr: Subscript(
                subscriptable: Get(expr: temp1, member: pointee),
                argument: temp0
            ),
            explicitType: ConstType(u16)
        )
        let expected = Block(
            children: shared + [
                Assignment(lexpr: foo, rexpr: temp2)
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_RightHandSideIsStructInitializer_ZeroMembers() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: []
            ),
            VarDeclaration(identifier: a, explicitType: Foo)
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: a,
                    rexpr: StructInitializer(
                        identifier: Foo,
                        arguments: []
                    )
                )
            ]
        )
            .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                Eseq(
                    seq: Seq(
                        children: [
                            VarDeclaration(
                                identifier: TempRef(0),
                                explicitType: ConstType(PointerType(ConstType(Foo)))
                            ),
                            InitialAssignment(
                                lexpr: TempRef(0),
                                rexpr: AddressOf(a)
                            )
                        ]
                    ),
                    expr: Get(expr: TempRef(0), member: pointee)
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_RightHandSideIsStructInitializer() throws {
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: bar.identifier,
                        type: bool
                    )
                ]
            ),
            VarDeclaration(identifier: a, explicitType: Foo)
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: a,
                    rexpr: StructInitializer(
                        identifier: Foo,
                        arguments: [
                            StructInitializer.Argument(
                                name: bar.identifier,
                                expr: LiteralBool(false)
                            )
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                Eseq(
                    seq: Seq(
                        children: [
                            VarDeclaration(
                                identifier: TempRef(0),
                                explicitType: ConstType(PointerType(ConstType(Foo)))
                            ),
                            InitialAssignment(
                                lexpr: TempRef(0),
                                rexpr: AddressOf(a)
                            ),
                            InitialAssignment(
                                lexpr: Get(
                                    expr: Temp(
                                        i: 1,
                                        expr: AddressOf(Get(expr: TempRef(0), member: bar)),
                                        explicitType: ConstType(PointerType(ConstType(bool)))
                                    ),
                                    member: pointee
                                ),
                                rexpr: Temp(i: 2, expr: LiteralBool(false))
                            )
                        ]
                    ),
                    expr: Get(expr: TempRef(0), member: pointee)
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignmentExpression_RightHandSideIsLiteralString() throws {
        let str = "Hello, World!"
        let arrType = ArrayType(
            count: LiteralInt(str.utf8.count),
            elementType: PrimitiveType(.u8)
        )
        let shared = [
            StructDeclaration(
                identifier: Foo,
                members: [
                    StructDeclaration.Member(
                        name: bar.identifier,
                        type: arrType
                    )
                ]
            ),
            VarDeclaration(identifier: a, explicitType: Foo, isMutable: true)
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: AddressOf(a), member: bar),
                    rexpr: LiteralString(str)
                )
            ]
        )
            .reconnect(parent: nil)
        
        let temp0 = Temp(
            i: 0,
            expr: AddressOf(a),
            explicitType: ConstType(PointerType(Foo))
        )
        let temp1 = Temp(
            i: 1,
            expr: AddressOf(Get(expr: temp0, member: bar)),
            explicitType: ConstType(PointerType(arrType))
        )
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: temp1, member: pointee),
                    rexpr: LiteralString(str)
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testSubscriptArgumentOfLiteralRangeMustBePreserved() throws {
        let shared = [
            StructDeclaration(
                identifier: Identifier("Range"),
                members: [
                    StructDeclaration.Member(
                        name: "begin",
                        type: PrimitiveType(.u16)
                    ),
                    StructDeclaration.Member(
                        name: "limit",
                        type: PrimitiveType(.u16)
                    )
                ]
            ),
            VarDeclaration(
                identifier: foo,
                explicitType: PointerType(
                    ArrayType(
                        count: LiteralInt(10),
                        elementType: PrimitiveType(.u8)
                    )
                )
            )
        ]
        let input = Block(
            children: shared + [
                Subscript(
                    subscriptable: Get(expr: foo, member: pointee),
                    argument: StructInitializer(
                        identifier: Identifier("Range"),
                        arguments: [
                            StructInitializer.Argument(
                                name: "begin",
                                expr: LiteralInt(0)
                            ),
                            StructInitializer.Argument(
                                name: "limit",
                                expr: LiteralInt(5)
                            )
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let expected = Block(
            children: shared + [
                Subscript(
                    subscriptable: Get(
                        expr: Temp(
                            i: 0,
                            expr: foo,
                            explicitType: ConstType(
                                PointerType(
                                    ArrayType(
                                        count: LiteralInt(10),
                                        elementType: PrimitiveType(.u8)
                                    )
                                )
                            )
                        ),
                        member: pointee
                    ),
                    argument: StructInitializer(
                        identifier: Identifier("Range"),
                        arguments: [
                            StructInitializer.Argument(
                                name: "begin",
                                expr: LiteralInt(0)
                            ),
                            StructInitializer.Argument(
                                name: "limit",
                                expr: LiteralInt(5)
                            )
                        ]
                    )
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    func testExtractArrayConversionByValueBecauseItHasNoLvalue() throws {
        let arrType = ArrayType(
            count: LiteralInt(0),
            elementType: u16
        )
        let shared = [
            VarDeclaration(
                identifier: foo,
                explicitType: arrType,
                isMutable: true
            )
        ]
        let input = Block(
            children: shared + [
                Assignment(
                    lexpr: foo,
                    rexpr: As(
                        expr: LiteralArray(
                            arrayType: ArrayType(
                                count: LiteralInt(0),
                                elementType: u8
                            ),
                            elements: []
                        ),
                        targetType: arrType
                    )
                )
            ]
        )
            .reconnect(parent: nil)
        
        let temp0 = Temp(
            i: 0,
            expr: AddressOf(foo),
            explicitType: ConstType(PointerType(arrType))
        )
        let temp1 = Temp(
            i: 1,
            expr: LiteralArray(
                arrayType: ArrayType(
                    count: LiteralInt(0),
                    elementType: u8
                ),
                elements: []
            ),
            explicitType: ConstType(
                ArrayType(
                    count: LiteralInt(0),
                    elementType: u8
                )
            )
        )
        let temp2 = Temp(
            i: 2,
            expr: As(expr: temp1, targetType: arrType),
            explicitType: ConstType(arrType)
        )
        let expected = Block(
            children: shared + [
                Assignment(
                    lexpr: Get(expr: temp0, member: pointee),
                    rexpr: temp2
                )
            ]
        )
            .reconnect(parent: nil)

        let actual = try input.decomposeExpressions()
        XCTAssertEqual(actual, expected)
    }
    
    // Ignore Get expressions where the object has a dynamic array type.
    // This is a special case escape hatch which will be removed after we add a
    // new compiler pass to erase dynamic arrays.
    func testIgnoreGetExpressionAppliedToDynamicArrayType() throws {
        let shared = [
            VarDeclaration(identifier: foo, explicitType: DynamicArrayType(u16))
        ]
        let input = Block(
            children: shared + [
                Get(expr: foo, member: count)
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.decomposeExpressions()
        let expected = input
        XCTAssertEqual(actual, expected)
    }
}
