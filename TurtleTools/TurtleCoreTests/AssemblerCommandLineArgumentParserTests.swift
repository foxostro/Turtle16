//
//  AssemblerCommandLineArgumentParserTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 2/2/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore
import XCTest

final class AssemblerCommandLineArgumentParserTests: XCTestCase {
    func testPrintUsageBecauseNoArguments() {
        let parser = AssemblerCommandLineArgumentParser(args: [])
        XCTAssertThrowsError(try parser.parse()) {
            XCTAssertEqual(
                $0 as! AssemblerCommandLineParserError,
                AssemblerCommandLineParserError.unexpectedEndOfInput
            )
        }
    }

    func testPrintUsageBecauseNotEnoughArguments() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap"])
        XCTAssertThrowsError(try parser.parse()) {
            XCTAssertEqual(
                $0 as! AssemblerCommandLineParserError,
                AssemblerCommandLineParserError.unexpectedEndOfInput
            )
        }
    }

    func testParsePrintHelpOption() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap", "-h"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.printHelp])
    }

    func testParseUnknownOption() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap", "-foo"])
        XCTAssertThrowsError(try parser.parse()) {
            XCTAssertEqual($0 as! AssemblerCommandLineParserError, .unknownOption("-foo"))
        }
    }

    func testParseOutputFilename() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap", "-o", "foo"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.outputFileName("foo")])
    }

    func testParseMultipleOptions() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap", "-q", "-o", "foo"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.quiet, .outputFileName("foo")])
    }

    func testParseInputFilename() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap", "foo"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.inputFileName("foo")])
    }

    func testParseMultipleInputFilenames() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap", "foo", "bar"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.inputFileName("foo"), .inputFileName("bar")])
    }

    func testParseInputFilenamesAndOptions() {
        let parser = AssemblerCommandLineArgumentParser(args: ["snap", "-o", "foo", "bar", "baz"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(
            parser.options,
            [.outputFileName("foo"), .inputFileName("bar"), .inputFileName("baz")]
        )
    }
}
