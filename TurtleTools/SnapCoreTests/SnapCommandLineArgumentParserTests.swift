//
//  SnapCommandLineArgumentParserTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

final class SnapCommandLineArgumentParserTests: XCTestCase {
    func testPrintUsageBecauseNoArguments() {
        let parser = SnapCommandLineArgumentParser(args: [])
        XCTAssertThrowsError(try parser.parse()) {
            XCTAssertEqual($0 as! SnapCommandLineParserError, SnapCommandLineParserError.unexpectedEndOfInput)
        }
    }
    
    func testPrintUsageBecauseNotEnoughArguments() {
        let parser = SnapCommandLineArgumentParser(args: ["snap"])
        XCTAssertThrowsError(try parser.parse()) {
            XCTAssertEqual($0 as! SnapCommandLineParserError, SnapCommandLineParserError.unexpectedEndOfInput)
        }
    }
    
    func testParsePrintHelpOption() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-h"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.printHelp])
    }
    
    func testParseUnknownOption() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-foo"])
        XCTAssertThrowsError(try parser.parse()) {
            XCTAssertEqual($0 as! SnapCommandLineParserError, .unknownOption("-foo"))
        }
    }
    
    func testParseOutputFilename() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-o", "foo"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.outputFileName("foo")])
    }
    
    func testParseAssemblyOutputOption() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-S"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.S])
    }
    
    func testParseSyntaxTreeDumpOption() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-ast-dump"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.astDump])
    }
    
    func testParseIROutputOption() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-ir"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.ir])
    }
    
    func testParseMultipleOptions() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-ir", "-o", "foo"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.ir, .outputFileName("foo")])
    }
    
    func testParseInputFilename() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "foo"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.inputFileName("foo")])
    }
    
    func testParseMultipleInputFilenames() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "foo", "bar"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.inputFileName("foo"), .inputFileName("bar")])
    }
    
    func testParseInputFilenamesAndOptions() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "-o", "foo", "bar", "baz"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.outputFileName("foo"), .inputFileName("bar"), .inputFileName("baz")])
    }
    
    func testTestVerb() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "test", "-t", "foo", "bar"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.test, .chooseSpecificTest("foo"), .inputFileName("bar")])
    }
    
    func testRunVerb() {
        let parser = SnapCommandLineArgumentParser(args: ["snap", "run", "foo"])
        XCTAssertNoThrow(try parser.parse())
        XCTAssertEqual(parser.options, [.run, .inputFileName("foo")])
    }
}
