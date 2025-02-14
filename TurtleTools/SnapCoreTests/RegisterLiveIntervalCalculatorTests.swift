//
//  RegisterLiveIntervalCalculatorTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore
import SnapCore

final class RegisterLiveIntervalCalculatorTests: XCTestCase {
    func testEmpty() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = []
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertTrue(liveRanges.isEmpty)
    }
    
    func testIntervalsAreInIncreasingOrder() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr2")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr0", physicalRegisterName: nil),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr1", physicalRegisterName: nil),
            LiveInterval(range: 2..<3, virtualRegisterName: "vr2", physicalRegisterName: nil)
        ])
    }
    
    func testIntervalsAreInIncreasingOrder_TieBreaker() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr0", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr1", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr2", physicalRegisterName: nil)
        ])
    }
    
    func testIntervalLengthLongerThanOne() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [
            LiveInterval(range: 0..<3, virtualRegisterName: "vr0", physicalRegisterName: nil),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr1", physicalRegisterName: nil)
        ])
    }
    
    func testOnlyConsiderRegisterNameIdentifierInLA() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kLA, parameters: [
                ParameterIdentifier("vr0"),
                ParameterIdentifier("foo")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr0", physicalRegisterName: nil)
        ])
    }
    
    func testIgnoreLabelIdentifierInJMP() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kJMP, parameters: [
                ParameterIdentifier("foo")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [])
    }
    
    func testIgnoreLabelIdentifierInBEQ() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kBEQ, parameters: [
                ParameterIdentifier("foo")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [])
    }
    
    func testIgnoreLabelIdentifierInBNE() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kBNE, parameters: [
                ParameterIdentifier("foo")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [])
    }
    
    func testIgnoreLabelIdentifierInBLT() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kBLT, parameters: [
                ParameterIdentifier("foo")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [])
    }
    
    func testIgnoreLabelIdentifierInBGT() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kBGT, parameters: [
                ParameterIdentifier("foo")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [])
    }
    
    func testIgnoreTheLabelNodeIdentifier() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0"),
                ParameterIdentifier("vr0")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [
            LiveInterval(range: 1..<2, virtualRegisterName: "vr0", physicalRegisterName: nil)
        ])
    }
    
    func testSomeVirtualRegisterNamesAlwaysMapToCorrespondingPhysicalNames() throws {
        let obj = RegisterLiveIntervalCalculator()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("fp"),
                ParameterIdentifier("sp"),
                ParameterIdentifier("ra")
            ])
        ]
        let liveRanges = obj.determineLiveIntervals(input)
        XCTAssertEqual(liveRanges, [
            LiveInterval(range: 0..<1, virtualRegisterName: "ra", physicalRegisterName: "ra"),
            LiveInterval(range: 0..<1, virtualRegisterName: "sp", physicalRegisterName: "sp"),
            LiveInterval(range: 0..<1, virtualRegisterName: "fp", physicalRegisterName: "fp")
        ])
    }
}
