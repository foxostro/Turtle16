//
//  SymbolTablesReconnectorTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class SymbolTablesReconnectorTests: XCTestCase {
    func testBlock() throws {
        let table1 = Env()
        let table2 = Env()
        let input = Block(
            symbols: table1,
            children: [
                Block(symbols: table2, children: [])
            ]
        )
        SymbolTablesReconnector().reconnect(input)
        XCTAssertEqual(table2.parent, table1)
        XCTAssertEqual(table1.parent, nil)
    }

    func testFunctionDeclaration_IncreasesStackFrame() throws {
        let table1 = Env()
        let table2 = Env()

        let input = Block(
            symbols: table1,
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.u8),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(children: []),
                    symbols: table2
                )
            ]
        )
        SymbolTablesReconnector().reconnect(input)

        XCTAssertEqual(table2.parent, table1)
        XCTAssertEqual(table1.parent, nil)

        XCTAssertEqual(table1.frameLookupMode, .inherit)
        XCTAssertTrue(table2.frameLookupMode.isSet)
    }

    func testFunctionDeclaration_Body() throws {
        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
            argumentNames: [],
            body: Block(children: [])
        )
        SymbolTablesReconnector().reconnect(input)

        XCTAssertEqual(input.symbols, input.body.symbols.parent)
    }
}
