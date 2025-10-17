//
//  PatternMatcher.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation

/// Provides glob-style pattern matching for test filter strings
///
/// Supports two wildcards:
/// - `*`: Matches zero or more characters
/// - `?`: Matches exactly one character
///
/// Examples:
/// - `tack*W` matches all 16-bit tests (tackADDW, tackSUBW, etc.)
/// - `tack*B` matches all 8-bit tests (tackADDB, tackSUBB, etc.)
/// - `*ADD*` matches all ADD operations (tackADDB, tackADDW)
/// - `tackADD?` matches tackADDB or tackADDW
///
/// Patterns without wildcards perform exact string matching (case-sensitive).
enum PatternMatcher {
    /// Tests whether a given text matches a glob-style pattern
    ///
    /// - Parameters:
    ///   - text: The string to test
    ///   - pattern: The glob pattern with optional `*` and `?` wildcards
    /// - Returns: `true` if the text matches the pattern, `false` otherwise
    static func matches(text: String, pattern: String) -> Bool {
        matchesImpl(
            text: Array(text),
            textIndex: 0,
            pattern: Array(pattern),
            patternIndex: 0
        )
    }

    /// Recursive implementation of glob pattern matching
    ///
    /// This uses a backtracking algorithm to handle `*` wildcards:
    /// - For each `*`, try matching zero characters, then one, then two, etc.
    /// - For `?`, consume exactly one character
    /// - For literal characters, must match exactly
    ///
    /// - Parameters:
    ///   - text: Array of characters in the text being matched
    ///   - textIndex: Current position in the text
    ///   - pattern: Array of characters in the pattern
    ///   - patternIndex: Current position in the pattern
    /// - Returns: `true` if the remaining text matches the remaining pattern
    private static func matchesImpl(
        text: [Character],
        textIndex: Int,
        pattern: [Character],
        patternIndex: Int
    ) -> Bool {
        // Base case: reached end of both text and pattern
        if patternIndex == pattern.count, textIndex == text.count {
            return true
        }

        // Pattern exhausted but text remains
        if patternIndex == pattern.count {
            return false
        }

        // Get current pattern character
        let patternChar = pattern[patternIndex]

        // Handle star wildcard: matches zero or more characters
        if patternChar == "*" {
            // Try matching zero characters (skip the star)
            if matchesImpl(
                text: text,
                textIndex: textIndex,
                pattern: pattern,
                patternIndex: patternIndex + 1
            ) {
                return true
            }

            // Try matching one or more characters
            // Consume each character from text and retry
            var currentTextIndex = textIndex
            while currentTextIndex < text.count {
                currentTextIndex += 1
                if matchesImpl(
                    text: text,
                    textIndex: currentTextIndex,
                    pattern: pattern,
                    patternIndex: patternIndex + 1
                ) {
                    return true
                }
            }

            return false
        }

        // Text exhausted but pattern remains (and it's not a star)
        if textIndex == text.count {
            return false
        }

        // Handle question mark wildcard: matches exactly one character
        if patternChar == "?" {
            return matchesImpl(
                text: text,
                textIndex: textIndex + 1,
                pattern: pattern,
                patternIndex: patternIndex + 1
            )
        }

        // Handle literal character: must match exactly
        if text[textIndex] == patternChar {
            return matchesImpl(
                text: text,
                textIndex: textIndex + 1,
                pattern: pattern,
                patternIndex: patternIndex + 1
            )
        }

        // No match
        return false
    }
}
