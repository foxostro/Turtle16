//
//  TestRunnerTests.swift
//  TackCompilerValidationSuiteCoreTests
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
@testable import TackCompilerValidationSuiteCore
import Testing

/// Unit tests for the `TestRunner.selectTests()` function
struct TestRunnerTests {
    // MARK: - Test Data Fixtures

    /// Sample test cases for testing filter functionality
    static let sampleTests: [TestCase] = [
        TestCase(
            name: "testAlpha",
            test: { _, _ in },
            totalIterations: 100
        ),
        TestCase(
            name: "testBeta",
            test: { _, _ in },
            totalIterations: 200
        ),
        TestCase(
            name: "testGamma",
            test: { _, _ in },
            totalIterations: 300
        ),
        TestCase(
            name: "testDelta",
            test: { _, _ in },
            totalIterations: 400
        ),
    ]

    // MARK: - Empty Filters Tests

    @Test func emptyFiltersReturnsAllTests() throws {
        let result = try TestRunner.selectTests(filters: [], from: Self.sampleTests)
        #expect(result.count == 4)
        #expect(result.map(\.name) == ["testAlpha", "testBeta", "testGamma", "testDelta"])
    }

    @Test func emptyFiltersPreservesTestOrder() throws {
        let result = try TestRunner.selectTests(filters: [], from: Self.sampleTests)
        #expect(result[0].name == "testAlpha")
        #expect(result[1].name == "testBeta")
        #expect(result[2].name == "testGamma")
        #expect(result[3].name == "testDelta")
    }

    @Test func emptyFiltersWithEmptyTestList() throws {
        let result = try TestRunner.selectTests(filters: [], from: [])
        #expect(result.isEmpty)
    }

    // MARK: - Single Filter Tests

    @Test func singleFilterMatchesFirstTest() throws {
        let result = try TestRunner.selectTests(filters: ["testAlpha"], from: Self.sampleTests)
        #expect(result.count == 1)
        #expect(result[0].name == "testAlpha")
    }

    @Test func singleFilterMatchesMiddleTest() throws {
        let result = try TestRunner.selectTests(filters: ["testBeta"], from: Self.sampleTests)
        #expect(result.count == 1)
        #expect(result[0].name == "testBeta")
    }

    @Test func singleFilterMatchesLastTest() throws {
        let result = try TestRunner.selectTests(filters: ["testDelta"], from: Self.sampleTests)
        #expect(result.count == 1)
        #expect(result[0].name == "testDelta")
    }

    @Test func singleFilterNotFound() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["nonexistent"], from: Self.sampleTests)
        }
    }

    @Test func singleFilterNotFoundContainsCorrectError() throws {
        do {
            _ = try TestRunner.selectTests(filters: ["nonexistent"], from: Self.sampleTests)
            Issue.record("Expected TestFilterError to be thrown")
        } catch let error as TestFilterError {
            #expect(error.notFoundTests == ["nonexistent"])
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    // MARK: - Multiple Filters Tests

    @Test func multipleFiltersAllMatch() throws {
        let result = try TestRunner.selectTests(
            filters: ["testAlpha", "testGamma"],
            from: Self.sampleTests
        )
        #expect(result.count == 2)
        #expect(result[0].name == "testAlpha")
        #expect(result[1].name == "testGamma")
    }

    @Test func multipleFiltersPreserveFilterOrder() throws {
        let result = try TestRunner.selectTests(
            filters: ["testDelta", "testBeta", "testAlpha"],
            from: Self.sampleTests
        )
        #expect(result.count == 3)
        #expect(result[0].name == "testDelta")
        #expect(result[1].name == "testBeta")
        #expect(result[2].name == "testAlpha")
    }

    @Test func multipleFiltersReverseOrder() throws {
        let result = try TestRunner.selectTests(
            filters: ["testDelta", "testGamma", "testBeta", "testAlpha"],
            from: Self.sampleTests
        )
        #expect(result.count == 4)
        #expect(result[0].name == "testDelta")
        #expect(result[1].name == "testGamma")
        #expect(result[2].name == "testBeta")
        #expect(result[3].name == "testAlpha")
    }

    @Test func multipleFiltersOneNotFound() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(
                filters: ["testAlpha", "nonexistent", "testBeta"],
                from: Self.sampleTests
            )
        }
    }

    @Test func multipleFiltersOneNotFoundContainsCorrectError() throws {
        do {
            _ = try TestRunner.selectTests(
                filters: ["testAlpha", "nonexistent", "testBeta"],
                from: Self.sampleTests
            )
            Issue.record("Expected TestFilterError to be thrown")
        } catch let error as TestFilterError {
            #expect(error.notFoundTests == ["nonexistent"])
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test func multipleFiltersMultipleNotFound() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(
                filters: ["invalid1", "testAlpha", "invalid2"],
                from: Self.sampleTests
            )
        }
    }

    @Test func multipleFiltersMultipleNotFoundContainsAllErrors() throws {
        do {
            _ = try TestRunner.selectTests(
                filters: ["invalid1", "testAlpha", "invalid2"],
                from: Self.sampleTests
            )
            Issue.record("Expected TestFilterError to be thrown")
        } catch let error as TestFilterError {
            #expect(error.notFoundTests.count == 2)
            #expect(error.notFoundTests.contains("invalid1"))
            #expect(error.notFoundTests.contains("invalid2"))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test func multipleFiltersAllNotFound() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(
                filters: ["invalid1", "invalid2", "invalid3"],
                from: Self.sampleTests
            )
        }
    }

    @Test func multipleFiltersAllNotFoundContainsAllErrors() throws {
        do {
            _ = try TestRunner.selectTests(
                filters: ["invalid1", "invalid2", "invalid3"],
                from: Self.sampleTests
            )
            Issue.record("Expected TestFilterError to be thrown")
        } catch let error as TestFilterError {
            #expect(error.notFoundTests == ["invalid1", "invalid2", "invalid3"])
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    // MARK: - Duplicate Filters Tests

    @Test func duplicateFiltersSameTest() throws {
        let result = try TestRunner.selectTests(
            filters: ["testAlpha", "testAlpha"],
            from: Self.sampleTests
        )
        // Duplicates are allowed and should return the same test multiple times
        #expect(result.count == 2)
        #expect(result[0].name == "testAlpha")
        #expect(result[1].name == "testAlpha")
    }

    @Test func duplicateFiltersMultipleTests() throws {
        let result = try TestRunner.selectTests(
            filters: ["testAlpha", "testBeta", "testAlpha", "testBeta"],
            from: Self.sampleTests
        )
        #expect(result.count == 4)
        #expect(result[0].name == "testAlpha")
        #expect(result[1].name == "testBeta")
        #expect(result[2].name == "testAlpha")
        #expect(result[3].name == "testBeta")
    }

    // MARK: - Case Sensitivity Tests

    @Test func filtersAreCaseSensitive() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["TESTALPHA"], from: Self.sampleTests)
        }
    }

    @Test func filtersAreCaseSensitiveLowerCase() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["testalpha"], from: Self.sampleTests)
        }
    }

    // MARK: - Whitespace Tests

    @Test func filtersDoNotTrimWhitespace() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: [" testAlpha"], from: Self.sampleTests)
        }
    }

    @Test func filtersDoNotTrimTrailingWhitespace() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["testAlpha "], from: Self.sampleTests)
        }
    }

    @Test func filtersDoNotTrimSurroundingWhitespace() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: [" testAlpha "], from: Self.sampleTests)
        }
    }

    // MARK: - Empty String Filter Tests

    @Test func emptyStringFilterNotFound() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: [""], from: Self.sampleTests)
        }
    }

    @Test func mixedEmptyAndValidFilters() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(
                filters: ["testAlpha", "", "testBeta"],
                from: Self.sampleTests
            )
        }
    }

    // MARK: - Real Test Data Tests (Integration-style)

    @Test func selectsFromRealEightBitTests() throws {
        let result = try TestRunner.selectTests(filters: ["tackADDB"], from: eightBitTests)
        #expect(result.count == 1)
        #expect(result[0].name == "tackADDB")
    }

    @Test func selectsMultipleRealEightBitTests() throws {
        let result = try TestRunner.selectTests(
            filters: ["tackADDB", "tackSUBB", "tackMULB"],
            from: eightBitTests
        )
        #expect(result.count == 3)
        #expect(result[0].name == "tackADDB")
        #expect(result[1].name == "tackSUBB")
        #expect(result[2].name == "tackMULB")
    }

    @Test func selectsFromRealSixteenBitTests() throws {
        let result = try TestRunner.selectTests(filters: ["tackADDW"], from: sixteenBitTests)
        #expect(result.count == 1)
        #expect(result[0].name == "tackADDW")
    }

    @Test func selectsFromRealAllTests() throws {
        let result = try TestRunner.selectTests(filters: ["tackADDB", "tackADDW"], from: allTests)
        #expect(result.count == 2)
        #expect(result[0].name == "tackADDB")
        #expect(result[1].name == "tackADDW")
    }

    @Test func invalidTestNameFromRealTests() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["tackINVALID"], from: allTests)
        }
    }

    @Test func emptyFiltersReturnsAllRealTests() throws {
        let result = try TestRunner.selectTests(filters: [], from: allTests)
        #expect(result.count == allTests.count)
        #expect(result.count == 24) // 12 8-bit + 12 16-bit tests
    }

    // MARK: - Edge Cases

    @Test func singleTestInListWithMatchingFilter() throws {
        let singleTest = [Self.sampleTests[0]]
        let result = try TestRunner.selectTests(filters: ["testAlpha"], from: singleTest)
        #expect(result.count == 1)
        #expect(result[0].name == "testAlpha")
    }

    @Test func singleTestInListWithNonMatchingFilter() throws {
        let singleTest = [Self.sampleTests[0]]
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["testBeta"], from: singleTest)
        }
    }

    @Test func largeNumberOfFilters() throws {
        let filters = Array(repeating: "testAlpha", count: 1000)
        let result = try TestRunner.selectTests(filters: filters, from: Self.sampleTests)
        #expect(result.count == 1000)
        #expect(result.allSatisfy { $0.name == "testAlpha" })
    }

    // MARK: - Preserve Test Properties

    @Test func preservesTotalIterations() throws {
        let result = try TestRunner.selectTests(filters: ["testAlpha"], from: Self.sampleTests)
        #expect(result[0].totalIterations == 100)
    }

    @Test func preservesMultipleTestProperties() throws {
        let result = try TestRunner.selectTests(
            filters: ["testAlpha", "testBeta", "testGamma"],
            from: Self.sampleTests
        )
        #expect(result[0].totalIterations == 100)
        #expect(result[1].totalIterations == 200)
        #expect(result[2].totalIterations == 300)
    }

    // MARK: - Pattern Matching Tests

    @Test func patternMatchesMultipleTests() throws {
        let result = try TestRunner.selectTests(filters: ["test*"], from: Self.sampleTests)
        #expect(result.count == 4)
        #expect(result.map(\.name) == ["testAlpha", "testBeta", "testGamma", "testDelta"])
    }

    @Test func patternMatchesSubset() throws {
        let result = try TestRunner.selectTests(filters: ["test*ta"], from: Self.sampleTests)
        #expect(result.count == 2)
        #expect(result[0].name == "testBeta")
        #expect(result[1].name == "testDelta")
    }

    @Test func patternMatchesSingleTest() throws {
        let result = try TestRunner.selectTests(filters: ["testAlp*"], from: Self.sampleTests)
        #expect(result.count == 1)
        #expect(result[0].name == "testAlpha")
    }

    @Test func patternMatchesNothing() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["xyz*"], from: Self.sampleTests)
        }
    }

    @Test func patternWithQuestionMark() throws {
        let result = try TestRunner.selectTests(filters: ["testAlph?"], from: Self.sampleTests)
        #expect(result.count == 1)
        #expect(result[0].name == "testAlpha")
    }

    @Test func patternWithMiddleWildcard() throws {
        let result = try TestRunner.selectTests(filters: ["test*ta"], from: Self.sampleTests)
        #expect(result.count == 2)
        #expect(result.map(\.name).contains("testBeta"))
        #expect(result.map(\.name).contains("testDelta"))
    }

    @Test func mixedExactAndPatternFilters() throws {
        let result = try TestRunner.selectTests(
            filters: ["testAlpha", "test*ta"],
            from: Self.sampleTests
        )
        #expect(result.count == 3)
        #expect(result[0].name == "testAlpha")
        #expect(result[1].name == "testBeta")
        #expect(result[2].name == "testDelta")
    }

    @Test func patternMatchesDuplicates() throws {
        let result = try TestRunner.selectTests(
            filters: ["test*", "testAlpha"],
            from: Self.sampleTests
        )
        #expect(result.count == 5) // 4 from pattern + 1 exact
        #expect(result[0].name == "testAlpha")
        #expect(result[4].name == "testAlpha") // Duplicate at end
    }

    // MARK: - Real Test Data Pattern Matching

    @Test func patternMatchesAll16BitTests() throws {
        let result = try TestRunner.selectTests(filters: ["tack*W"], from: allTests)
        #expect(result.count == 12)
        #expect(result.allSatisfy { $0.name.hasSuffix("W") })
    }

    @Test func patternMatchesAll8BitTests() throws {
        let result = try TestRunner.selectTests(filters: ["tack*B"], from: allTests)
        #expect(result.count == 12)
        #expect(result.allSatisfy { $0.name.hasSuffix("B") })
    }

    @Test func patternMatchesAllADDOperations() throws {
        let result = try TestRunner.selectTests(filters: ["*ADD*"], from: allTests)
        #expect(result.count == 2)
        #expect(result[0].name == "tackADDB")
        #expect(result[1].name == "tackADDW")
    }

    @Test func patternMatchesAllSUBOperations() throws {
        let result = try TestRunner.selectTests(filters: ["*SUB*"], from: allTests)
        #expect(result.count == 2)
        #expect(result[0].name == "tackSUBB")
        #expect(result[1].name == "tackSUBW")
    }

    @Test func patternMatchesAllMULOperations() throws {
        let result = try TestRunner.selectTests(filters: ["*MUL*"], from: allTests)
        #expect(result.count == 2)
        #expect(result[0].name == "tackMULB")
        #expect(result[1].name == "tackMULW")
    }

    @Test func patternMatchesOperationWithQuestionMark() throws {
        let result = try TestRunner.selectTests(filters: ["tackADD?"], from: allTests)
        #expect(result.count == 2)
        #expect(result[0].name == "tackADDB")
        #expect(result[1].name == "tackADDW")
    }

    @Test func multiplePatterns16And8Bit() throws {
        let result = try TestRunner.selectTests(
            filters: ["tack*W", "tack*B"],
            from: allTests
        )
        #expect(result.count == 24) // All tests (12 + 12)
    }

    @Test func patternMatchesShiftOperations() throws {
        let result = try TestRunner.selectTests(filters: ["*LSL*", "*LSR*"], from: allTests)
        #expect(result.count == 4)
        #expect(result.map(\.name).contains("tackLSLB"))
        #expect(result.map(\.name).contains("tackLSLW"))
        #expect(result.map(\.name).contains("tackLSRB"))
        #expect(result.map(\.name).contains("tackLSRW"))
    }

    @Test func patternMatchesBitwiseOperations() throws {
        let result = try TestRunner.selectTests(
            filters: ["*AND*", "*OR*", "*XOR*"],
            from: allTests
        )
        // *AND* matches: tackANDB, tackANDW (2)
        // *OR* matches: tackORB, tackORW, tackXORB, tackXORW (4, because XOR contains OR)
        // *XOR* matches: tackXORB, tackXORW (2)
        // Total: 8 (with duplicates from overlapping patterns)
        #expect(result.count == 8)
    }

    @Test func patternCombinedWithExactReal() throws {
        let result = try TestRunner.selectTests(
            filters: ["tack*W", "tackADDB"],
            from: allTests
        )
        #expect(result.count == 13) // 12 16-bit tests + 1 exact match
        #expect(result.first?.name == "tackADDW") // First from pattern
        #expect(result.last?.name == "tackADDB") // Exact match at end
    }

    @Test func patternNoMatchInRealTests() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: ["tack*Z"], from: allTests)
        }
    }

    // MARK: - Pattern Edge Cases

    @Test func starOnlyMatchesEverything() throws {
        let result = try TestRunner.selectTests(filters: ["*"], from: Self.sampleTests)
        #expect(result.count == 4)
    }

    @Test func emptyPatternMatchesNothing() throws {
        #expect(throws: TestFilterError.self) {
            try TestRunner.selectTests(filters: [""], from: Self.sampleTests)
        }
    }

    @Test func patternPreservesOrder() throws {
        let result = try TestRunner.selectTests(
            filters: ["*Delta", "*Beta", "*Alpha"],
            from: Self.sampleTests
        )
        #expect(result[0].name == "testDelta")
        #expect(result[1].name == "testBeta")
        #expect(result[2].name == "testAlpha")
    }
}
