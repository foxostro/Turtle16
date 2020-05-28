//
//  SymbolTableTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class SymbolTableTests: XCTestCase {
    func testSetGet() {
        let symbols = SymbolTable()
        symbols["foo"] = .constant(0xffff)
        XCTAssertEqual(symbols["foo"], .constant(0xffff))
    }
    
    func testUseOfUnresolvedIdentifier() {
        let symbols = SymbolTable()
        let identifier = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertThrowsError(try symbols.resolve(identifier: identifier)) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of unresolved identifier: `foo'")
        }
    }
}
