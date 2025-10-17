//
//  TestFailure.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation

struct TestFailure: Error {
    let message: String
    let file: String
    let line: Int

    init(_ message: String, file: String = #file, line: Int = #line) {
        self.message = message
        self.file = file
        self.line = line
    }
}

func testAssert(
    _ condition: Bool,
    _ message: String = "Assertion failed",
    file: String = #file,
    line: Int = #line
) throws {
    guard condition else {
        throw TestFailure(message, file: file, line: line)
    }
}
