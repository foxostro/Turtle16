//
//  HazardControlMockupTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

class HazardControlMockupTests: XCTestCase {
    func makeHazardControl() -> HazardControl {
        HazardControlMockup()
    }

    func testFlushOnJump() throws {
        let hltOpcode: UInt = 1
        let ins = UInt16(hltOpcode << 11)
        let unit = makeHazardControl()
        let output = unit.step(
            input: ID.Input(ins: ins, j: 0),
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )
        XCTAssertEqual(output.flush, 0) // FLUSH is an active-low signal
    }

    func testOperandForwarding_Forward_Y_EX_Instead_Of_rA() throws {
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b00001000_11100000

        // The instruction in EX wants to write Y_EX back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0xabcd)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_ex_to_a,
            0
        ) // The A operand comes from Y_EX instead of register file port A.
    }

    func testStallOnRAWHazard_A_and_EX_In_StoreOp_Case() throws {
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b00001000_11100000

        // The instruction in EX wants to write storeOP_EX back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 1) // The CPU must stall.
    }

    func testOperandForwarding_Forward_Y_MEM_Instead_Of_rA() throws {
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b00001000_11100000

        // The instruction in MEM wants to write Y_MEM back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0xabcd)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_mem_to_a,
            0
        ) // The A operand comes from Y_MEM instead of register file port A.
    }

    func testStallOnRAWHazard_A_and_MEM_In_StoreOp_Case() throws {
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b00001000_11100000

        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 1) // The CPU must stall.
    }

    func testOperandForwarding_Forward_Y_EX_Instead_Of_rB() throws {
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b00001000_00011100

        // The instruction in EX wants to write Y_EX back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0xabcd)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_ex_to_b,
            0
        ) // The A operand comes from Y_EX instead of register file port B.
    }

    func testStallOnRAWHazard_B_and_EX_In_StoreOp_Case() throws {
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b00001000_00011100

        // The instruction in EX wants to write storeOP_EX back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 1) // The CPU must stall.
    }

    func testOperandForwarding_Forward_Y_MEM_Instead_Of_rB() throws {
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b00001000_00011100

        // The instruction in MEM wants to write Y_MEM back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0xabcd)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_mem_to_b,
            0
        ) // The A operand comes from Y_MEM instead of register file port B.
    }

    func testStallOnRAWHazard_B_and_MEM_In_StoreOp_Case() throws {
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b00001000_00011100

        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 1) // The CPU must stall.
    }

    func testOperandForwarding_Forward_Y_EX_Instead_Of_rA_and_rB() throws {
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b00001000_11111100

        // The instruction in EX wants to write Y_EX back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0xabcd)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_ex_to_a,
            0
        ) // The A operand comes from Y_EX instead of register file port A.
        XCTAssertEqual(
            output.fwd_ex_to_b,
            0
        ) // The A operand comes from Y_EX instead of register file port B.
    }

    func testStallOnRAWHazard_A_and_B_and_EX_In_StoreOp_Case() throws {
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b00001000_11111100

        // The instruction in EX wants to write storeOP_EX back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 1) // The CPU must stall.
    }

    func testOperandForwarding_Forward_Y_MEM_Instead_Of_rA_and_rB() throws {
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b00001000_11111100

        // The instruction in MEM wants to write Y_MEM back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0xabcd)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_mem_to_a,
            0
        ) // The A operand comes from Y_MEM instead of register file port A.
        XCTAssertEqual(
            output.fwd_mem_to_b,
            0
        ) // The A operand comes from Y_MEM instead of register file port B.
    }

    func testStallOnRAWHazard_A_and_B_and_MEM_In_StoreOp_Case() throws {
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b00001000_11111100

        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 1) // The CPU must stall.
    }

    func testStallOnFlagsHazard() throws {
        let beq: UInt16 = 24
        let input = ID.Input(ins: beq << 11, ctl_EX: 0b11111_11111111_11011111)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )
        XCTAssertEqual(output.stall, 1)
    }

    func testOperandForwarding_MustNotForwardBoth_YMEM_and_YEX_to_A() throws {
        // There are cases where the result we need is in both Y_MEM and Y_EX.
        // In these cases we need to favor the newer one, which is Y_EX.
        // We must not attempt to forward both values or the bus transceivers
        // might try to drive the bus to conflicting values.

        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b00001000_11100000

        // The instruction in EX wants to write Y_EX back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        // The instruction in MEM wants to write Y_MEM back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(
            ins: ins_ID,
            y_EX: 0xabcd,
            y_MEM: 0x1234,
            ins_EX: ins_EX,
            ctl_EX: ctl_EX,
            selC_MEM: selC_MEM,
            ctl_MEM: ctl_MEM,
            j: 1,
            n: 0,
            c: 0,
            z: 0,
            v: 0
        )

        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_ex_to_a,
            0
        ) // The A operand comes from Y_EX instead of register file port A.
    }

    func testOperandForwarding_MustNotForwardBoth_YMEM_and_YEX_to_B() throws {
        // There are cases where the result we need is in both Y_MEM and Y_EX.
        // In these cases we need to favor the newer one, which is Y_EX.
        // We must not attempt to forward both values or the bus transceivers
        // might try to drive the bus to conflicting values.

        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b00001000_00011100

        // The instruction in EX wants to write Y_EX back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b111_00000000
        let ctl_EX: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        // The instruction in MEM wants to write Y_MEM back to the register file in r7.
        // (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(
            (1 << DecoderGenerator.WBEN) | (1 << DecoderGenerator.WriteBackSrcFlag)
        )

        let input = ID.Input(
            ins: ins_ID,
            y_EX: 0xabcd,
            y_MEM: 0x1234,
            ins_EX: ins_EX,
            ctl_EX: ctl_EX,
            selC_MEM: selC_MEM,
            ctl_MEM: ctl_MEM,
            j: 1,
            n: 0,
            c: 0,
            z: 0,
            v: 0
        )

        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 0
        )

        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(
            output.fwd_ex_to_b,
            0
        ) // The A operand comes from Y_EX instead of register file port B.
    }

    func testAvoidFalseStoreHazardOnLeftOperand() throws {
        // The instruction in ID want to read r7 on port A (left)
        let ins_ID: UInt16 = 0b00001000_11100000

        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 1,
            right_operand_is_unused: 0
        )

        // The CPU must not stall when the instruction doesn't actually use the
        // operands. Since the values are unused, it doesn't matter if they're
        // incorrect.
        XCTAssertEqual(output.stall, 0)
    }

    func testAvoidFalseStoreHazardOnRightOperand() throws {
        // The instruction in ID want to read r7 on port B (right)
        let ins_ID: UInt16 = 0b00001000_00011100

        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7.
        // (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1 << DecoderGenerator.WBEN)

        let input = ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0)
        let unit = makeHazardControl()
        let output = unit.step(
            input: input,
            left_operand_is_unused: 0,
            right_operand_is_unused: 1
        )

        // The CPU must not stall when the instruction doesn't actually use the
        // operands. Since the values are unused, it doesn't matter if they're
        // incorrect.
        XCTAssertEqual(output.stall, 0)
    }
}
