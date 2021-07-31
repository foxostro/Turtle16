//
//  SnapASTTransformerSymbolTablesTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerSymbolTablesTests: XCTestCase {
    func testExample() throws {
        let actual = try? SnapASTTransformerSymbolTables().transform(CommentNode(string: ""))
        let expected = CommentNode(string: "")
        XCTAssertEqual(actual, expected)
    }
    
    func testBlock() throws {
        let table1 = SymbolTable()
        let table2 = SymbolTable()
        let input = Block(symbols: table1, children: [
            Block(symbols: table2, children: [
            ])
        ])
        XCTAssertNoThrow(try SnapASTTransformerSymbolTables().transform(input))
        XCTAssertEqual(table2.parent, table1)
        XCTAssertEqual(table1.parent, nil)
    }
    
    func testFunctionDeclaration_IncreasesStackFrame() throws {
        let table1 = SymbolTable()
        let table2 = SymbolTable()
        
        let input = Block(symbols: table1, children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                            functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                            argumentNames: [],
                                            body: Block(children: []),
                                            symbols: table2)
        ])
        XCTAssertNoThrow(try SnapASTTransformerSymbolTables().transform(input))
        
        XCTAssertEqual(table2.parent, table1)
        XCTAssertEqual(table1.parent, nil)
        
        XCTAssertEqual(table2.stackFrameIndex, table1.stackFrameIndex+1)
    }
    
    func testFunctionDeclaration_Body() throws {
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: []))
        var result: FunctionDeclaration? = nil
        XCTAssertNoThrow(result = try? SnapASTTransformerSymbolTables().transform(input) as? FunctionDeclaration)
        
        XCTAssertEqual(result?.symbols, result?.body.symbols)
    }
}
