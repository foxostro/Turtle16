//
//  PatternMatcherTests.swift
//  TackCompilerValidationSuiteCoreTests
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
@testable import TackCompilerValidationSuiteCore
import Testing

/// Unit tests for the glob-style pattern matching functionality
struct PatternMatcherTests {
    // MARK: - Exact Match Tests (Backward Compatibility)

    @Test func exactMatchWithNoWildcards() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tackADDB"))
    }

    @Test func exactMatchCaseSensitive() {
        #expect(!PatternMatcher.matches(text: "tackADDB", pattern: "tackaddb"))
        #expect(!PatternMatcher.matches(text: "tackaddb", pattern: "tackADDB"))
    }

    @Test func exactMatchDifferentStrings() {
        #expect(!PatternMatcher.matches(text: "tackADDB", pattern: "tackSUBB"))
    }

    @Test func exactMatchEmptyStrings() {
        #expect(PatternMatcher.matches(text: "", pattern: ""))
    }

    @Test func exactMatchEmptyPattern() {
        #expect(!PatternMatcher.matches(text: "tackADDB", pattern: ""))
    }

    @Test func exactMatchEmptyText() {
        #expect(!PatternMatcher.matches(text: "", pattern: "tackADDB"))
    }

    // MARK: - Star Wildcard Tests

    @Test func starMatchesAnything() {
        #expect(PatternMatcher.matches(text: "anything", pattern: "*"))
    }

    @Test func starMatchesEmptyString() {
        #expect(PatternMatcher.matches(text: "", pattern: "*"))
    }

    @Test func starAtBeginning() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "*ADDB"))
        #expect(PatternMatcher.matches(text: "ADDB", pattern: "*ADDB"))
    }

    @Test func starAtEnd() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack*"))
        #expect(PatternMatcher.matches(text: "tack", pattern: "tack*"))
    }

    @Test func starInMiddle() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack*B"))
        #expect(PatternMatcher.matches(text: "tackB", pattern: "tack*B"))
    }

    @Test func multipleStars() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "*ADD*"))
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "*ck*DD*"))
    }

    @Test func starDoesNotMatchPartial() {
        #expect(!PatternMatcher.matches(text: "tackADD", pattern: "*ADDB"))
        #expect(!PatternMatcher.matches(text: "ADDB", pattern: "tack*"))
    }

    // MARK: - Question Mark Wildcard Tests

    @Test func questionMatchesSingleChar() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tackADD?"))
        #expect(PatternMatcher.matches(text: "tackADDW", pattern: "tackADD?"))
    }

    @Test func questionDoesNotMatchEmpty() {
        #expect(!PatternMatcher.matches(text: "tackADD", pattern: "tackADD?"))
    }

    @Test func questionDoesNotMatchMultiple() {
        #expect(!PatternMatcher.matches(text: "tackADDBB", pattern: "tackADD?"))
    }

    @Test func multipleQuestions() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack????"))
        #expect(PatternMatcher.matches(text: "test", pattern: "????"))
    }

    @Test func questionInMiddle() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack?DDB"))
        #expect(!PatternMatcher.matches(text: "tackDDB", pattern: "tack?DDB"))
    }

    // MARK: - Combined Wildcard Tests

    @Test func starAndQuestionCombined() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack*?"))
        #expect(PatternMatcher.matches(text: "tackB", pattern: "tack*?"))
    }

    @Test func complexPattern() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "t*k?DD?"))
        #expect(PatternMatcher.matches(text: "taskXDDY", pattern: "t*k?DD?"))
    }

    // MARK: - Real Test Name Patterns

    @Test func matchAll16BitTests() {
        // Pattern for all 16-bit tests
        #expect(PatternMatcher.matches(text: "tackADDW", pattern: "tack*W"))
        #expect(PatternMatcher.matches(text: "tackSUBW", pattern: "tack*W"))
        #expect(PatternMatcher.matches(text: "tackMULW", pattern: "tack*W"))
        #expect(!PatternMatcher.matches(text: "tackADDB", pattern: "tack*W"))
    }

    @Test func matchAll8BitTests() {
        // Pattern for all 8-bit tests
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack*B"))
        #expect(PatternMatcher.matches(text: "tackSUBB", pattern: "tack*B"))
        #expect(PatternMatcher.matches(text: "tackMULB", pattern: "tack*B"))
        #expect(!PatternMatcher.matches(text: "tackADDW", pattern: "tack*B"))
    }

    @Test func matchAllADDOperations() {
        // Pattern for all ADD operations (both 8-bit and 16-bit)
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "*ADD*"))
        #expect(PatternMatcher.matches(text: "tackADDW", pattern: "*ADD*"))
        #expect(!PatternMatcher.matches(text: "tackSUBB", pattern: "*ADD*"))
    }

    @Test func matchOperationWithSize() {
        // Pattern: tackADD{B or W}
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tackADD?"))
        #expect(PatternMatcher.matches(text: "tackADDW", pattern: "tackADD?"))
        #expect(!PatternMatcher.matches(text: "tackADDWW", pattern: "tackADD?"))
        #expect(!PatternMatcher.matches(text: "tackADD", pattern: "tackADD?"))
    }

    @Test func matchAllTackTests() {
        // Pattern for any test starting with "tack"
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack*"))
        #expect(PatternMatcher.matches(text: "tackSUBW", pattern: "tack*"))
        #expect(!PatternMatcher.matches(text: "otherTest", pattern: "tack*"))
    }

    // MARK: - Edge Cases

    @Test func patternWithOnlyStar() {
        #expect(PatternMatcher.matches(text: "anything", pattern: "*"))
        #expect(PatternMatcher.matches(text: "", pattern: "*"))
    }

    @Test func patternWithMultipleConsecutiveStars() {
        // Multiple stars should behave like a single star
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "tack**B"))
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "***"))
    }

    @Test func patternWithOnlyQuestions() {
        #expect(PatternMatcher.matches(text: "test", pattern: "????"))
        #expect(!PatternMatcher.matches(text: "test", pattern: "???"))
        #expect(!PatternMatcher.matches(text: "test", pattern: "?????"))
    }

    @Test func textShorterThanPattern() {
        #expect(!PatternMatcher.matches(text: "hi", pattern: "hello"))
    }

    @Test func textLongerThanPattern() {
        #expect(!PatternMatcher.matches(text: "hello", pattern: "hi"))
    }

    @Test func specialCharacters() {
        // Test that special regex characters are treated literally
        #expect(PatternMatcher.matches(text: "test.file", pattern: "test.file"))
        #expect(PatternMatcher.matches(text: "test[0]", pattern: "test[0]"))
        #expect(!PatternMatcher.matches(text: "test_file", pattern: "test.file"))
    }

    @Test func unicodeCharacters() {
        #expect(PatternMatcher.matches(text: "test🔥file", pattern: "test*file"))
        #expect(PatternMatcher.matches(text: "🔥", pattern: "?"))
    }

    // MARK: - Performance Edge Cases

    @Test func longString() {
        let longText = String(repeating: "a", count: 1000)
        let pattern = String(repeating: "a", count: 1000)
        #expect(PatternMatcher.matches(text: longText, pattern: pattern))
    }

    @Test func longStringWithWildcard() {
        let longText = String(repeating: "a", count: 1000) + "b"
        #expect(PatternMatcher.matches(text: longText, pattern: "*b"))
    }

    @Test func manyWildcards() {
        #expect(PatternMatcher.matches(text: "tackADDB", pattern: "*t*a*c*k*A*D*D*B*"))
    }
}
