//
//  XCTestCaseExtensions.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 1/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import XCTest

public extension XCTestCase {
    var testName: String {
        let regex = try! NSRegularExpression(pattern: #"\[\w+\s+(?<testName>\w+)\]"#)
        if let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) {
            let nsRange = match.range(withName: "testName")
            if let range = Range(nsRange, in: name) {
                return "\(name[range])"
            }
        }
        return ""
    }
}
