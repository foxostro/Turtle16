//
//  TraitScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class TraitScannerTests: XCTestCase {

    func testCompileTraitAddsToTypeTable_Empty() throws {
        let ast = TraitDeclaration(identifier: Identifier("Foo"), members: [])

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)

        let expectedSymbols = Env()
        expectedSymbols.frameLookupMode = .set(Frame())
        expectedSymbols.breadcrumb = .traitType("Foo")
        let expected: SymbolType = .traitType(
            TraitTypeInfo(
                name: "Foo",
                nameOfTraitObjectType: "__Foo_object",
                nameOfVtableType: "__Foo_vtable",
                symbols: expectedSymbols
            )
        )
        let actual = try scanner.symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }

    func testCompileTraitAddsToTypeTable_HasMethod() throws {
        let bar = TraitDeclaration.Member(
            name: "bar",
            type: PointerType(
                FunctionType(
                    name: nil,
                    returnType: PrimitiveType(.u8),
                    arguments: [
                        PointerType(Identifier("Foo"))
                    ]
                )
            )
        )
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [bar],
            visibility: .privateVisibility
        )

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)

        let memoryLayoutStrategy = MemoryLayoutStrategyNull()
        let members = Env()
        let expected: SymbolType = .traitType(
            TraitTypeInfo(
                name: "Foo",
                nameOfTraitObjectType: "__Foo_object",
                nameOfVtableType: "__Foo_vtable",
                symbols: members
            )
        )
        members.breadcrumb = .traitType("Foo")
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        let memberType: SymbolType = .pointer(
            .function(FunctionTypeInfo(returnType: .u8, arguments: [.pointer(expected)]))
        )
        let sizeOfMemoryType = memoryLayoutStrategy.sizeof(type: memberType)
        let offset = frame.allocate(size: sizeOfMemoryType)
        let symbol = Symbol(type: memberType, storage: .automaticStorage(offset: offset))
        frame.add(identifier: "bar", symbol: symbol)
        members.bind(identifier: "bar", symbol: symbol)
        members.parent = nil

        let actual = try scanner.symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }

    func testCompileTraitAddsVtableType_Empty() throws {
        let ast = TraitDeclaration(identifier: Identifier("Foo"), members: [])

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)

        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }

    func testCompileTraitAddsVtableType_HasMethod() throws {
        let bar = TraitDeclaration.Member(
            name: "bar",
            type: PointerType(
                FunctionType(
                    name: nil,
                    returnType: PrimitiveType(.u8),
                    arguments: [
                        PointerType(Identifier("Foo"))
                    ]
                )
            )
        )
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [bar],
            visibility: .privateVisibility
        )

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)

        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }

    func testCompileTraitAddsVtableType_HasConstMethod() throws {
        let bar = TraitDeclaration.Member(
            name: "bar",
            type: PointerType(
                FunctionType(
                    name: nil,
                    returnType: PrimitiveType(.u8),
                    arguments: [
                        PointerType(ConstType(Identifier("Foo")))
                    ]
                )
            )
        )
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [bar],
            visibility: .privateVisibility
        )

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)

        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }

    func testCompileTraitAddsTraitObjectType_VoidReturn() throws {
        let bar = TraitDeclaration.Member(
            name: "bar",
            type: PointerType(
                FunctionType(
                    name: nil,
                    returnType: PrimitiveType(.void),
                    arguments: [
                        PointerType(Identifier("Foo"))
                    ]
                )
            )
        )
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [bar],
            visibility: .privateVisibility
        )

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)

        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType.unwrapTraitType().nameOfTraitObjectType)
    }

    func testCompileTraitAddsTraitObjectType() throws {
        let bar = TraitDeclaration.Member(
            name: "bar",
            type: PointerType(
                FunctionType(
                    name: nil,
                    returnType: PrimitiveType(.u8),
                    arguments: [
                        PointerType(Identifier("Foo"))
                    ]
                )
            )
        )
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [bar],
            visibility: .privateVisibility
        )

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)

        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType.unwrapTraitType().nameOfTraitObjectType)
    }

    func testCompileTraitAddsToTypeTable_EmptyGenericTrait() throws {
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            members: []
        )

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        let actual = try scanner.symbols.resolveType(identifier: "Foo")

        let expected = SymbolType.genericTraitType(GenericTraitTypeInfo(template: ast))
        XCTAssertEqual(expected, actual)
    }

    /// Verify that TraitScanner will throw an error in the case where a type
    /// with the same name as our desired vtable type already exists, and
    /// doesn't exactly match the type TraitScanner had intended to bind.
    func testVtableTypeAlreadyExistsAndDoesntMatchTheTypeWeWantedToBind() throws {
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: PointerType(
                        FunctionType(
                            name: nil,
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        )
                    )
                )
            ],
            visibility: .privateVisibility
        )

        // Ensure the vtable type name is already taken before scanning.
        let scanner = TraitScanner(
            symbols: Env(typeDict: [
                "__Foo_vtable": .void
            ])
        )

        XCTAssertThrowsError(try scanner.scan(trait: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "struct declaration redefines existing type: `__Foo_vtable'"
            )
        }
    }

    /// Verify that TraitScanner will NOT throw an error in the case where a
    /// type with the same name as our desired vtable type already exists, and
    /// it DOES match the type TraitScanner had intended to bind.
    func testVtableTypeAlreadyExistsAndDefinitelyMatchesTheTypeWeWantedToBind() throws {
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: PointerType(
                        FunctionType(
                            name: nil,
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        )
                    )
                )
            ],
            visibility: .privateVisibility
        )

        // Ensure the vtable type name is already taken before scanning.
        let scanner = TraitScanner(
            symbols: Env(typeDict: [
                "__Foo_vtable": .structType(
                    StructTypeInfo(
                        name: "__Foo_vtable",
                        fields: Env()
                    )
                )
            ])
        )

        XCTAssertNoThrow(try scanner.scan(trait: ast))
    }

    /// Verify that TraitScanner will throw an error in the case where a type
    /// with the same name as our desired trait-object type already exists, and
    /// doesn't match the type TraitScanner had intended to bind.
    func testTraitObjectTypeAlreadyExistsAndDoesntMatchTheTypeWeWantedToBind() throws {
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: PointerType(
                        FunctionType(
                            name: nil,
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        )
                    )
                )
            ],
            visibility: .privateVisibility
        )

        // Ensure the trait-object type name is already taken before scanning.
        let scanner = TraitScanner(
            symbols: Env(typeDict: [
                "__Foo_object": .void
            ])
        )

        XCTAssertThrowsError(try scanner.scan(trait: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "struct declaration redefines existing type: `__Foo_object'"
            )
        }
    }

    /// Verify that TraitScanner will NOT throw an error in the case where a
    /// type with the same name as our desired trait-object type already exists, and
    /// it DOES match the type TraitScanner had intended to bind.
    func testTraitObjectTypeAlreadyExistsAndDefinitelyMatchesTheTypeWeWantedToBind() throws {
        let ast = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: PointerType(
                        FunctionType(
                            name: nil,
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        )
                    )
                )
            ],
            visibility: .privateVisibility
        )

        // Ensure the trait-object type name is already taken before scanning.
        let scanner = TraitScanner(
            symbols: Env(typeDict: [
                "__Foo_object": .structType(
                    StructTypeInfo(
                        name: "__Foo_object",
                        fields: Env(),
                        associatedTraitType: "Foo"
                    )
                )
            ])
        )

        XCTAssertNoThrow(try scanner.scan(trait: ast))
    }

    /// The first parameter of every trait method must be an appropriate "self"
    /// parameter. This test is for the case where there are no parameters.
    func testEveryMethodMustHaveAppropriateSelfParameter_1() throws {
        let trait = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: PointerType(
                        FunctionType(
                            name: nil,
                            returnType: PrimitiveType(.void),
                            arguments: []
                        )
                    )
                )
            ],
            visibility: .privateVisibility
        )

        let scanner = TraitScanner()

        XCTAssertThrowsError(try scanner.scan(trait: trait)) {
            guard let error = $0 as? CompilerError else {
                XCTFail()
                return
            }
            XCTAssertEqual(
                error.message,
                "every method on a trait must have, as its first parameter, an appropriate `self' parameter"
            )
        }
    }

    /// The first parameter of every trait method must be an appropriate "self"
    /// parameter. This test is for the case where there are no parameters.
    func testEveryMethodMustHaveAppropriateSelfParameter_2() throws {
        let trait = TraitDeclaration(
            identifier: Identifier("Foo"),
            members: [
                TraitDeclaration.Member(
                    name: "bar",
                    type: PointerType(
                        FunctionType(
                            name: nil,
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(PrimitiveType(.u16))
                            ]
                        )
                    )
                )
            ],
            visibility: .privateVisibility
        )

        let scanner = TraitScanner()

        XCTAssertThrowsError(try scanner.scan(trait: trait)) {
            guard let error = $0 as? CompilerError else {
                XCTFail()
                return
            }
            XCTAssertEqual(
                error.message,
                "every method on a trait must have, as its first parameter, an appropriate `self' parameter: the `self' parameter must have a type that is a pointer to the trait type"
            )
        }
    }

}
