//
//  TestRunner.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import ArgumentParser
import Foundation
import Logging

// MARK: - Terminal Utilities

/// Get the width of the terminal in columns
private func getTerminalWidth() -> Int {
    var w = winsize()
    if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
        return Int(w.ws_col)
    }
    return 80 // Default fallback width
}

/// Print with carriage return and proper line clearing
/// - Parameters:
///   - message: The message to print
///   - terminator: The line terminator (default: newline)
private func printClearLine(_ message: String, terminator: String = "\n") {
    let termWidth = getTerminalWidth()
    let messageLength = message.count

    // Calculate how many spaces we need to clear the rest of the line
    let paddingNeeded = max(0, termWidth - messageLength - 1)
    let padding = String(repeating: " ", count: paddingNeeded)

    print("\r\(message)\(padding)", terminator: terminator)
}

struct TestCase: Sendable {
    let name: String
    let test: @Sendable (Progress, Int) async throws -> Void
    let totalIterations: Int

    init(
        name: String,
        test: @escaping @Sendable (Progress, Int) async throws -> Void,
        totalIterations: Int
    ) {
        self.name = name
        self.test = test
        self.totalIterations = totalIterations
    }
}

let eightBitTests: [TestCase] = [
    TestCase(
        name: "tackADDB",
        test: testTackADDB,
        totalIterations: Byte8Configuration<Int8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackSUBB",
        test: testTackSUBB,
        totalIterations: Byte8Configuration<Int8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackMULB",
        test: testTackMULB,
        totalIterations: Byte8Configuration<Int8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackDIVB",
        test: testTackDIVB,
        totalIterations: Byte8Configuration<Int8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackDIVUB",
        test: testTackDIVUB,
        totalIterations: Byte8Configuration<UInt8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackMODB",
        test: testTackMODB,
        totalIterations: Byte8Configuration<UInt8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackLSLB",
        test: testTackLSLB,
        totalIterations: Byte8Configuration<UInt8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackLSRB",
        test: testTackLSRB,
        totalIterations: Byte8Configuration<UInt8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackANDB",
        test: testTackANDB,
        totalIterations: Byte8Configuration<UInt8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackORB",
        test: testTackORB,
        totalIterations: Byte8Configuration<UInt8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackXORB",
        test: testTackXORB,
        totalIterations: Byte8Configuration<UInt8>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackNEGB",
        test: testTackNEGB,
        totalIterations: Byte8Configuration<UInt8>.unaryOpTotalIterations
    ),
]

let sixteenBitTests: [TestCase] = [
    TestCase(
        name: "tackADDW",
        test: testTackADDW,
        totalIterations: Word16Configuration<Int16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackSUBW",
        test: testTackSUBW,
        totalIterations: Word16Configuration<Int16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackMULW",
        test: testTackMULW,
        totalIterations: Word16Configuration<Int16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackDIVW",
        test: testTackDIVW,
        totalIterations: Word16Configuration<Int16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackDIVUW",
        test: testTackDIVUW,
        totalIterations: Word16Configuration<UInt16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackMODW",
        test: testTackMODW,
        totalIterations: Word16Configuration<UInt16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackLSLW",
        test: testTackLSLW,
        totalIterations: Word16Configuration<UInt16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackLSRW",
        test: testTackLSRW,
        totalIterations: Word16Configuration<UInt16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackANDW",
        test: testTackANDW,
        totalIterations: Word16Configuration<UInt16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackORW",
        test: testTackORW,
        totalIterations: Word16Configuration<UInt16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackXORW",
        test: testTackXORW,
        totalIterations: Word16Configuration<UInt16>.binaryOpTotalIterations
    ),
    TestCase(
        name: "tackNEGW",
        test: testTackNEGW,
        totalIterations: Word16Configuration<UInt16>.unaryOpTotalIterations
    ),
]

let allTests: [TestCase] = eightBitTests + sixteenBitTests

struct TestFilterError: Error {
    let notFoundTests: [String]
}

enum TestRunner {
    static func printAvailableTests() {
        print("Available tests (\(allTests.count) total):")
        print()
        print("8-bit tests:")
        for test in eightBitTests {
            print("  \(test.name)")
        }
        print()
        print("16-bit tests:")
        for test in sixteenBitTests {
            print("  \(test.name)")
        }
    }

    static func selectTests(filters: [String], from allTests: [TestCase]) throws -> [TestCase] {
        if filters.isEmpty {
            return allTests
        }

        var selectedTests: [TestCase] = []
        var notFoundTests: [String] = []

        for filter in filters {
            // Find all tests matching the filter pattern
            let matchedTests = allTests.filter { test in
                PatternMatcher.matches(text: test.name, pattern: filter)
            }

            if matchedTests.isEmpty {
                notFoundTests.append(filter)
            }
            else {
                selectedTests.append(contentsOf: matchedTests)
            }
        }

        if !notFoundTests.isEmpty {
            throw TestFilterError(notFoundTests: notFoundTests)
        }

        return selectedTests
    }

    static func runTests(testFilters: [String], jobCount: Int = 0) async throws {
        let tests: [TestCase]

        do {
            tests = try selectTests(filters: testFilters, from: allTests)
        }
        catch let error as TestFilterError {
            let notFoundTests = error.notFoundTests

            // Log error to stderr
            TestLogger.logger.error("Test(s) not found", metadata: [
                "not_found": "\(notFoundTests.joined(separator: ", "))"
            ])

            // Display error to user on stdout
            if notFoundTests.count == 1 {
                print("Error: Test '\(notFoundTests[0])' not found")
            }
            else {
                print("Error: Tests not found: \(notFoundTests.joined(separator: ", "))")
            }
            print()
            printAvailableTests()
            throw ExitCode.failure
        }

        if tests.count == allTests.count {
            print("Running \(tests.count) exhaustive Tack instruction tests...")
            print("(This will take a significant amount of time)")
        }
        else if tests.count == 1 {
            print("Running test: \(tests[0].name)")
        }
        else {
            print("Running \(tests.count) tests: \(tests.map(\.name).joined(separator: ", "))")
        }
        print()

        var passedCount = 0

        for (index, testCase) in tests.enumerated() {
            let testNumber = index + 1
            let prefix =
                if tests.count > 1 {
                    "[\(testNumber)/\(tests.count)] "
                }
                else {
                    ""
                }

            let startTime = Date()

            // Calculate total iterations
            let numJobs = jobCount > 0 ? jobCount : ProcessInfo.processInfo.processorCount

            // Create a single Progress instance shared across all tasks
            let progress = Progress(totalUnitCount: Int64(testCase.totalIterations))

            TestLogger.logger.debug("Starting test", metadata: [
                "test": "\(testCase.name)",
                "total_iterations": "\(testCase.totalIterations)",
                "job_count": "\(numJobs)",
                "progress_total": "\(progress.totalUnitCount)"
            ])

            // Spinner task: Animate progress in foreground
            let spinnerTask = Task {
                let spinner = ProgressSpinner()
                var iterationCount = 0
                let spinnerDelay = 10 // Show spinner after 1 second (10 iterations at 0.1s each)

                while !Task.isCancelled {
                    iterationCount += 1
                    let elapsed = Date().timeIntervalSince(startTime)

                    if iterationCount <= spinnerDelay {
                        printClearLine("\(prefix)Running \(testCase.name)...", terminator: "")
                    }
                    else {
                        let fractionComplete = progress.fractionCompleted
                        let percentComplete = fractionComplete * 100.0
                        let percentCompleteStr = String(format: "%.2f", percentComplete)

                        let estimatedTotal = elapsed / fractionComplete
                        let remaining = estimatedTotal - elapsed
                        let remainingFormatted = formatTime(remaining)

                        let message =
                            "\(prefix)Running \(testCase.name)... " +
                            "\(spinner.currentFrame) \(percentCompleteStr)% " +
                            "(\(remainingFormatted) remaining)"
                        printClearLine(message, terminator: "")
                    }

                    fflush(stdout)
                    spinner.advance()
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1s = 10 FPS
                }
            }

            do {
                // Run test with specified number of concurrent jobs
                try await testCase.test(progress, numJobs)

                // Cancel spinner animation now that tests are done
                spinnerTask.cancel()

                let elapsed = Date().timeIntervalSince(startTime)
                let elapsedFormatted = formatTime(elapsed)
                // Clear spinner and show success with elapsed time
                printClearLine("\(prefix)Running \(testCase.name)... ✓ PASSED (\(elapsedFormatted))"
                )
                passedCount += 1
            }
            catch let error as TestFailure {
                let elapsed = Date().timeIntervalSince(startTime)
                let elapsedFormatted = formatTime(elapsed)

                // Log error to stderr
                TestLogger.logger.error("Test failed", metadata: [
                    "test": "\(testCase.name)",
                    "message": "\(error.message)",
                    "location": "\(error.file):\(error.line)",
                    "elapsed": "\(elapsedFormatted)"
                ])

                // Display error to user on stdout
                printClearLine("\(prefix)Running \(testCase.name)... ✗ FAILED (\(elapsedFormatted))"
                )
                print()
                print("Test failed: \(testCase.name)")
                print("Error: \(error.message)")
                print("Location: \(error.file):\(error.line)")
                throw ExitCode.failure
            }
            catch {
                let elapsed = Date().timeIntervalSince(startTime)
                let elapsedFormatted = formatTime(elapsed)

                // Log error to stderr
                TestLogger.logger.error("Unexpected test failure", metadata: [
                    "test": "\(testCase.name)",
                    "error": "\(error)",
                    "elapsed": "\(elapsedFormatted)"
                ])

                // Display error to user on stdout
                printClearLine("\(prefix)Running \(testCase.name)... ✗ FAILED (\(elapsedFormatted))"
                )
                print()
                print("Test failed: \(testCase.name)")
                print("Unexpected error: \(error)")
                throw ExitCode.failure
            }
        }

        print()
        print("========================================")
        print("All tests passed! (\(passedCount)/\(tests.count))")
        print("========================================")
    }
}
