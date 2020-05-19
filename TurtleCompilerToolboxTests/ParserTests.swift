//
//  ParserTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class ParserTests: XCTestCase {
    func testParseNothingToYieldNothing() {
        let parser = ParserBase()
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
        XCTAssertTrue(type(of: ast) == AbstractSyntaxTreeNode.self)
    }
    
    func testParseEOFToYieldNothing() {
        let parser = ParserBase()
        parser.tokens = [TokenEOF(lineNumber: 1)]
        parser.productions = [
            ParserBase.Production(symbol: TokenEOF.self,        generator: { _ in [] }),
        ]
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
        XCTAssertTrue(type(of: ast) == AbstractSyntaxTreeNode.self)
    }
    
    func testParseEmptyLineToYieldNothing() {
        let parser = ParserBase()
        parser.tokens = [TokenNewline(lineNumber: 1, lexeme: "\n"), TokenEOF(lineNumber: 2)]
        parser.productions = [
            ParserBase.Production(symbol: TokenEOF.self,        generator: { _ in [] }),
            ParserBase.Production(symbol: TokenNewline.self,    generator: { _ in [] }),
        ]
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
        XCTAssertTrue(type(of: ast) == AbstractSyntaxTreeNode.self)
    }
}
