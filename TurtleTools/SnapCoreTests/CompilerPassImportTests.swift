//
//  CompilerPassImportTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/19/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassImportTests: XCTestCase {
    func testEmptyModuleName() throws {
        let input = Block(children: [
            Import(moduleName: "")
        ])
        let compiler = CompilerPassImport(
            injectModules: [],
            runtimeSupport: nil
        )
        XCTAssertThrowsError(try compiler.run(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "no such module `'")
        }
    }

    func testNoSuchModule() throws {
        let compiler = CompilerPassImport(
            injectModules: [],
            runtimeSupport: nil
        )
        let input = Import(moduleName: "fake")
        XCTAssertThrowsError(try compiler.run(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "no such module `fake'")
        }
    }

    func testInjectEmptyModule() throws {
        let expected = Block(children: [
            Module(name: "Foo", block: Block()),
            Import(moduleName: "Foo")
        ])
        let compiler = CompilerPassImport(
            injectModules: [("Foo", "")],
            runtimeSupport: nil
        )
        let input = Block(
            children: [
                Import(moduleName: "Foo")
            ],
            id: expected.id
        )
        let output = try compiler.run(input)
        XCTAssertEqual(output, expected)
    }

    func testImportFromBundleResource() throws {
        let symbols = Env()
        let compiler = CompilerPassImport()
        let input = Block(
            symbols: symbols,
            children: [
                Import(moduleName: kStandardLibraryModuleName)
            ]
        )

        let actual = try compiler.run(input)

        guard let block = actual as? Block else {
            XCTFail("expected a Block")
            return
        }

        guard let module = block.children.first as? Module else {
            XCTFail("expected a Module")
            return
        }

        guard kStandardLibraryModuleName == module.name else {
            XCTFail("expected the module to be named \"\(kStandardLibraryModuleName)\"")
            return
        }

        guard !module.block.children.isEmpty else {
            XCTFail("expected the module to have a non-zero number of children")
            return
        }
    }

    func testImportModuleThatsAlreadyBeenImportedBefore() throws {
        let expected = Block(children: [
            Module(name: "Foo", block: Block()),
            Import(moduleName: "Foo"),
            Import(moduleName: "Foo")
        ])
        let compiler = CompilerPassImport(
            injectModules: [("Foo", "")],
            runtimeSupport: nil
        )
        let input = Block(
            children: [
                Import(moduleName: "Foo"),
                Import(moduleName: "Foo")
            ],
            id: expected.id
        )
        let output = try compiler.run(input)
        XCTAssertEqual(output, expected)
    }

    func testModuleImportsAModuleToo() throws {
        let expected = Block(children: [
            Module(name: "Bar", block: Block()),
            Module(
                name: "Foo",
                block: Block(children: [
                    Import(moduleName: "Bar")
                ])
            ),
            Import(moduleName: "Foo")
        ])
        let compiler = CompilerPassImport(
            injectModules: [
                ("Foo", "import Bar\n"),
                ("Bar", "")
            ],
            runtimeSupport: nil
        )
        let input = Block(
            children: [
                Import(moduleName: "Foo")
            ],
            id: expected.id
        )
        let output = try compiler.run(input)?.eraseSourceAnchors()
        XCTAssertEqual(expected, output)
    }
}
