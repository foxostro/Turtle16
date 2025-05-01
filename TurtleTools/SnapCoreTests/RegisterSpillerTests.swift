//
//  RegisterSpillerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleSimulatorCore
import XCTest

final class RegisterSpillerTests: XCTestCase {
    func testNoSpills1() throws {
        switch RegisterSpiller.spill(spilledIntervals: [], temporaries: [], nodes: []) {
        case .success(let r):
            XCTAssertTrue(r.isEmpty)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testNoSpills2() throws {
        let input = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(0)]),
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: kRET),
        ]
        let expected: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(0)]),
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: kRET),
        ]
        switch RegisterSpiller.spill(spilledIntervals: [], temporaries: [0], nodes: input) {
        case .success(let r):
            XCTAssertEqual(r, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testMissingLeadingEnter() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: nil
            )
        ]
        let nodes = [
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(0)]
            )
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success:
            XCTFail("expected a failure")

        case .failure(let error):
            XCTAssertEqual(error, .missingLeadingEnter)
        }
    }

    func testMissingSpillSlot() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: nil
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(0)]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success:
            XCTFail("expected a failure")

        case .failure(let error):
            XCTAssertEqual(error, .missingSpillSlot)
        }
    }

    func testSpillOneDestinationRegister() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(0)]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(2)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("r4"), ParameterNumber(0)]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testSpillWhenEnterHasNoParameters() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(0)]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("r4"), ParameterNumber(0)]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-1),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testSpillOneDestinationRegisterTwice() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<3,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(0)]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(1)]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(2)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("r4"), ParameterNumber(0)]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("r4"), ParameterNumber(1)]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testSpillTwoDestinationRegisters() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            ),
            LiveInterval(
                range: 2..<3,
                virtualRegisterName: "vr1",
                physicalRegisterName: nil,
                spillSlot: 1
            ),
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(0)]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr1"), ParameterNumber(1)]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(3)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("r4"), ParameterNumber(0)]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("r4"), ParameterNumber(1)]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-3),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testSpillOneSourceRegister() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"), ParameterIdentifier("r1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(2)]),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"), ParameterIdentifier("r1"), ParameterIdentifier("r4"),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testSpillBothSourceAndDestinationRegister() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr0"), ParameterIdentifier("r1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(2)]),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("r1"), ParameterIdentifier("r4"),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testSpillBothSourceAndDestinationRegisterTwice() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<3,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr0"), ParameterIdentifier("r1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr0"), ParameterIdentifier("r2"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(2)]),

            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("r1"), ParameterIdentifier("r4"),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            // Storing and then immediately loading again is inefficient. Rely on the optimizer to clean this up later.
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("r2"), ParameterIdentifier("r4"),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testOutOfTemporaries() throws {
        let spillSlot0 = 0
        let spillSlot1 = 1
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: spillSlot0
            ),
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr1",
                physicalRegisterName: nil,
                spillSlot: spillSlot1
            ),
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(0)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr2"), ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success:
            XCTFail("expected a failure")

        case .failure(let error):
            XCTAssertEqual(error, .outOfTemporaries)
        }
    }

    func testSpillTwoSourceRegisters() throws {
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            ),
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr1",
                physicalRegisterName: nil,
                spillSlot: 1
            ),
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(0)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr2"), ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(2)]),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r3"), ParameterIdentifier("fp"), ParameterNumber(-1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("fp"), ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr2"), ParameterIdentifier("r4"),
                    ParameterIdentifier("r3"),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [3, 4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testOutOfTemporariesWhileSpillingDestinationRegister() throws {
        let spillSlot = 0
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: spillSlot
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(1)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("vr0"), ParameterNumber(0)]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [],
            nodes: nodes
        ) {
        case .success:
            XCTFail("expected a failure")

        case .failure(let error):
            XCTAssertEqual(error, .outOfTemporaries)
        }
    }

    func testSpillOffsetIsVeryLarge_LoadCase() throws {
        let spillOffset = Int(UInt16(bitPattern: -101))
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr0",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(100)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"), ParameterIdentifier("r1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(101)]),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("ra"), ParameterNumber(spillOffset & 0x00ff)]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [ParameterIdentifier("ra"), ParameterNumber((spillOffset & 0xff) >> 8)]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("ra"), ParameterIdentifier("ra"), ParameterIdentifier("fp"),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [ParameterIdentifier("r4"), ParameterIdentifier("ra")]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"), ParameterIdentifier("r1"), ParameterIdentifier("r4"),
                ]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }

    func testSpillOffsetIsVeryLarge_StoreCase() throws {
        let spillOffset = Int(UInt16(bitPattern: -101))
        let spilledIntervals = [
            LiveInterval(
                range: 1..<2,
                virtualRegisterName: "vr2",
                physicalRegisterName: nil,
                spillSlot: 0
            )
        ]
        let nodes = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(100)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr2"), ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            ),
        ]
        let expected = [
            InstructionNode(instruction: kENTER, parameters: [ParameterNumber(101)]),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r4"), ParameterIdentifier("r1"), ParameterIdentifier("r0"),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [ParameterIdentifier("ra"), ParameterNumber(spillOffset & 0x00ff)]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [ParameterIdentifier("ra"), ParameterNumber((spillOffset & 0xff) >> 8)]
            ),
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("ra"), ParameterIdentifier("ra"), ParameterIdentifier("fp"),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [ParameterIdentifier("r4"), ParameterIdentifier("ra")]
            ),
        ]
        switch RegisterSpiller.spill(
            spilledIntervals: spilledIntervals,
            temporaries: [4],
            nodes: nodes
        ) {
        case .success(let result):
            XCTAssertEqual(result, expected)

        case .failure(let error):
            XCTFail("error: \(error)")
        }
    }
}
