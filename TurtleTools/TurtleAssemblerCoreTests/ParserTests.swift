//
//  ParserTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleAssemblerCore
import XCTest

class ParserTests: XCTestCase {
    func testParseNothingToYieldNothing() {
        let parser = Parser()
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
        XCTAssertTrue(type(of: ast) == AbstractSyntaxTreeNode.self)
    }

    func testParseEOFToYieldNothing() {
        let parser = Parser()
        parser.tokens = [TokenEOF(lineNumber: 1)]
        parser.productions = [
            Parser.Production(symbol: TokenEOF.self, generator: { _ in [] })
        ]
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
        XCTAssertTrue(type(of: ast) == AbstractSyntaxTreeNode.self)
    }

    func testParseEmptyLineToYieldNothing() {
        let parser = Parser()
        parser.tokens = [TokenNewline(lineNumber: 1, lexeme: "\n"), TokenEOF(lineNumber: 2)]
        parser.productions = [
            Parser.Production(symbol: TokenEOF.self, generator: { _ in [] }),
            Parser.Production(symbol: TokenNewline.self, generator: { _ in [] })
        ]
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
        XCTAssertTrue(type(of: ast) == AbstractSyntaxTreeNode.self)
    }
}
