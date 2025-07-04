//
//  CompilerPassWithDeclScanTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/18/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassWithDeclScanTests: XCTestCase {
    func parse(_ text: String) throws -> TopLevel {
        try SnapCore.parse(text: text, url: URL(fileURLWithPath: testName))
    }

    func testInit() {
        let _ = CompilerPassWithDeclScan()
    }

    func testPassesProgramThroughUnmodified() throws {
        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(CommentNode(string: "foo"))
        XCTAssertEqual(result, CommentNode(string: "foo"))
    }

    func testFunctionDeclaration() throws {
        let symbols = Env()
        let originalFunctionDeclaration = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(
                name: "foo",
                returnType: PrimitiveType(.void),
                arguments: []
            ),
            argumentNames: [],
            body: Block(children: [])
        )
        let input = Block(
            symbols: symbols,
            children: [
                originalFunctionDeclaration
            ]
        )
        .reconnect(parent: nil)

        let expectedRewrittenFunctionDeclaration =
            originalFunctionDeclaration
            .withBody(
                Block(children: [
                    Return()
                ])
            )
        let expectedFunctionType = FunctionTypeInfo(
            name: "foo",
            mangledName: "foo",
            returnType: .void,
            arguments: [],
            ast: expectedRewrittenFunctionDeclaration
        )
        let expected = Symbol(
            type: .function(expectedFunctionType),
            storage: .automaticStorage(offset: 0)
        )

        let compiler = CompilerPassWithDeclScan()
        _ = try compiler.visit(input)
        let actual = try symbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }

    func testStructDeclaration() throws {
        let symbols = Env()
        let input = Block(
            symbols: symbols,
            children: [
                StructDeclaration(identifier: Identifier("None"), members: [])
            ]
        )

        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(input)
        XCTAssertEqual(result, input)

        let expectedStructSymbols = Env()
        expectedStructSymbols.frameLookupMode = .set(Frame())
        expectedStructSymbols.breadcrumb = .structType("None")
        let expectedType: SymbolType = .structType(
            StructTypeInfo(name: "None", fields: expectedStructSymbols)
        )
        let actualType = try symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }

    func testTypealias() throws {
        let symbols = Env()
        let input = Block(
            symbols: symbols,
            children: [
                Typealias(lexpr: Identifier("Foo"), rexpr: PrimitiveType(.u8))
            ]
        )

        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(input)
        XCTAssertEqual(result, input)

        let expectedType: SymbolType = .u8
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }

    func testTraitDeclaration() throws {
        let symbols = Env()

        let input = Block(
            symbols: symbols,
            children: [
                TraitDeclaration(identifier: Identifier("Foo"), members: [])
            ]
        )

        let compiler = CompilerPassWithDeclScan()
        _ = try compiler.run(input)

        let expectedSymbols = Env()
        expectedSymbols.frameLookupMode = .set(Frame())
        expectedSymbols.breadcrumb = .traitType("Foo")
        let expectedType: SymbolType = .traitType(
            TraitTypeInfo(
                name: "Foo",
                nameOfTraitObjectType: "__Foo_object",
                nameOfVtableType: "__Foo_vtable",
                symbols: expectedSymbols
            )
        )
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expectedType, actualType)
    }

    func testImportingAModuleCausesItToExportPublicSymbols() throws {
        let symbols = Env()
        let ast0 = Block(
            symbols: symbols,
            children: [
                Import(moduleName: "Foo")
            ]
        )
        let ast1 = try ast0.importPass(injectModules: [
            ("Foo", "public struct None {}\n")
        ])

        let compiler = CompilerPassWithDeclScan()
        let ast2 = try compiler.run(ast1)

        XCTAssertEqual(ast2, ast1)
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        let foo = try symbols.resolveType(identifier: "Foo").maybeUnwrapStructType()
        XCTAssertNoThrow(try foo?.symbols.resolveType(identifier: "None"))
    }

    func testCompileImplForTrait() throws {

        let symbols = Env()

        func compileSerialTrait() throws {
            let bar = TraitDeclaration.Member(
                name: "puts",
                type: PointerType(
                    FunctionType(
                        name: nil,
                        returnType: PrimitiveType(.void),
                        arguments: [
                            PointerType(Identifier("Serial")),
                            DynamicArrayType(PrimitiveType(.u8))
                        ]
                    )
                )
            )
            let traitDecl = TraitDeclaration(
                identifier: Identifier("Serial"),
                members: [bar],
                visibility: .privateVisibility
            )
            try TraitScanner(symbols: symbols).scan(trait: traitDecl)
        }

        func compileSerialFake() throws {
            let fake = StructDeclaration(identifier: Identifier("SerialFake"), members: [])
            let compiler = StructScanner(
                symbols: symbols,
                memoryLayoutStrategy: MemoryLayoutStrategyNull()
            )
            try compiler.compile(fake)
        }

        try compileSerialTrait()
        try compileSerialFake()

        let ast = Block(
            symbols: symbols,
            children: [
                ImplFor(
                    typeArguments: [],
                    traitTypeExpr: Identifier("Serial"),
                    structTypeExpr: Identifier("SerialFake"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("puts"),
                            functionType: FunctionType(
                                name: "puts",
                                returnType: PrimitiveType(.void),
                                arguments: [
                                    PointerType(Identifier("Serial")),
                                    DynamicArrayType(PrimitiveType(.u8))
                                ]
                            ),
                            argumentNames: ["self", "s"],
                            body: Block()
                        )
                    ]
                )
            ]
        )
        .reconnect(parent: nil)

        _ = try CompilerPassWithDeclScan().visit(ast)

        // Let's examine, for correctness, the vtable symbol
        let nameOfVtableInstance = "__Serial_SerialFake_vtable_instance"
        let vtableInstance = try symbols.resolve(identifier: nameOfVtableInstance)
        let vtableStructType = vtableInstance.type.unwrapStructType()
        XCTAssertEqual(vtableStructType.name, "__Serial_vtable")
        XCTAssertEqual(vtableStructType.symbols.exists(identifier: "puts"), true)
        let putsSymbol = try vtableStructType.symbols.resolve(identifier: "puts")
        XCTAssertEqual(
            putsSymbol.type,
            .pointer(
                .function(
                    FunctionTypeInfo(
                        returnType: .void,
                        arguments: [.pointer(.void), .dynamicArray(elementType: .u8)]
                    )
                )
            )
        )
        XCTAssertEqual(putsSymbol.storage, .automaticStorage(offset: 0))
    }

    func testScanMatchClause() throws {
        let input = try parse(
            """
            let foo: bool | u16 = true
            match foo {
                (bar: bool) -> { let qux = false }
                else -> { let quux = false }
            }
            """
        )
        .replaceTopLevelWithBlock()
        .reconnect(parent: nil)

        let children = (input as! Block).children
        let match = children.last as! Match
        let clauseSymbols = match.clauses.first!.block.symbols
        let elseSymbols = match.elseClause!.symbols

        _ = try CompilerPassWithDeclScan().run(input)

        XCTAssertNoThrow(try elseSymbols.resolve(identifier: "quux"))
        XCTAssertNoThrow(try clauseSymbols.resolve(identifier: "qux"))
        XCTAssertNoThrow(try clauseSymbols.resolve(identifier: "bar"))
    }

    var moduleFoo: Module {
        Module(
            name: "Foo",
            block: Block(children: [
                FunctionDeclaration(
                    identifier: Identifier("bar"),
                    functionType: FunctionType(
                        name: "bar",
                        returnType: PrimitiveType(.void),
                        arguments: []
                    ),
                    argumentNames: [],
                    typeArguments: [],
                    body: Block(),
                    visibility: .publicVisibility
                )
            ])
        )
    }

    func testScanImport() throws {
        let input = try parse("import Foo")
            .replaceTopLevelWithBlock()
            .inserting(module: moduleFoo)

        _ = try CompilerPassWithDeclScan().run(input)

        XCTAssertNoThrow(try input.symbols.resolveType(identifier: "Foo"))
    }

    func testScanImport_DoesNotPolluteGlobalNamespace() throws {
        let input = try parse("import Foo")
            .replaceTopLevelWithBlock()
            .inserting(module: moduleFoo)

        _ = try CompilerPassWithDeclScan().run(input)

        XCTAssertThrowsError(try input.symbols.resolve(identifier: "bar")) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "use of unresolved identifier: `bar'")
        }
    }

    func testScanImport_InvalidRedeclaration() throws {
        let input = try parse(
            """
            typealias Foo = u16
            import Foo
            Foo.bar()
            """
        )
        .replaceTopLevelWithBlock()
        .inserting(module: moduleFoo)

        XCTAssertThrowsError(try CompilerPassWithDeclScan().run(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "import of module `Foo' redefines existing type of the same name"
            )
        }
    }

    func testScanImport_MangledNameIncludesModuleName() throws {
        let input = try parse(
            """
            import Foo
            """
        )
        .replaceTopLevelWithBlock()
        .inserting(module: moduleFoo)

        _ = try CompilerPassWithDeclScan().run(input)

        guard
            let Foo =
                try input
                .symbols
                .resolveType(identifier: "Foo")
                .maybeUnwrapStructType(),
            let bar =
                try Foo
                .symbols
                .resolveTypeOfIdentifier(
                    sourceAnchor: nil,
                    identifier: "bar"
                )
                .maybeUnwrapFunctionType()
        else {
            XCTFail()
            return
        }

        XCTAssertEqual(bar.mangledName, "Foo::bar")
    }
}

extension AbstractSyntaxTreeNode {
    fileprivate func inserting(module: Module) -> Block {
        (self as! Block)
            .inserting(children: [module], at: 0)
            .reconnect(parent: nil)
    }
}
