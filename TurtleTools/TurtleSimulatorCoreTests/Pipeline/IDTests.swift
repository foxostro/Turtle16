//
//  IDTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

class IDTests: XCTestCase {
    func testWriteBackSixteenBits() throws {
        let id = ID()
        id.registerFile[0] = 0xcdcd
        id.writeBack(input: ID.WriteBackInput(c: 0xabcd,
                                              wrh: 0,
                                              wrl: 0,
                                              wben: 0,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xabcd)
    }
    
    func testWriteBackButDisabled() throws {
        let id = ID()
        id.registerFile[0] = 0xcdcd
        id.writeBack(input: ID.WriteBackInput(c: 0xabcd,
                                              wrh: 0,
                                              wrl: 0,
                                              wben: 1,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xcdcd)
    }
    
    func testWriteBackUpperHalf() throws {
        let id = ID()
        id.registerFile[0] = 0xcdcd
        id.writeBack(input: ID.WriteBackInput(c: 0xabcd,
                                              wrh: 0,
                                              wrl: 0,
                                              wben: 1,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xcdcd)
    }
    
    func testWriteBackLower() throws {
        let id = ID()
        id.registerFile[0] = 0xccdd
        id.writeBack(input: ID.WriteBackInput(c: 0xaabb,
                                              wrh: 1,
                                              wrl: 0,
                                              wben: 0,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xccbb)
    }
    
    func testWriteBackUpper() throws {
        let id = ID()
        id.registerFile[0] = 0xccdd
        id.writeBack(input: ID.WriteBackInput(c: 0xaabb,
                                              wrh: 0,
                                              wrl: 1,
                                              wben: 0,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xaadd)
    }
    
    func testPassThroughLowerElevenBitsOfInstruction() throws {
        let id = ID()
        let output = id.step(input: ID.Input(ins: 0xffff))
        XCTAssertEqual(output.ins, 0x07ff)
    }
    
    func testOutputNopDuringResetRegardlessOfInstructionWord() throws {
        let id = ID()
        let rst = 0
        let index = UInt(rst << 8) | UInt(0b11111)
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(index)] = ID.nopControlWord
        id.decoder = decoder
        let output = id.step(input: ID.Input(ins: 0xffff, rst: 0))
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testDecodeControlWordForNOP() throws {
        let id = ID()
        let index = UInt(0)
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(index)] = ID.nopControlWord
        id.decoder = decoder
        let output = id.step(input: ID.Input(ins: 0))
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testReadRegisterA() throws {
        let id = ID()
        id.registerFile[7] = 0xabcd
        let output = id.step(input: ID.Input(ins: 0b0000000011100000))
        XCTAssertEqual(output.a, 0xabcd)
    }
    
    func testReadRegisterB() throws {
        let id = ID()
        id.registerFile[7] = 0xabcd
        let output = id.step(input: ID.Input(ins: 0b0000000000011100))
        XCTAssertEqual(output.b, 0xabcd)
    }
    
    func testDecodeHaltInstruction() throws {
        let id = ID()
        let hltOpcode: UInt = 1
        let entry: UInt = hltOpcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = 1
        id.decoder = decoder
        let ins: UInt16 = UInt16(hltOpcode << 11)
        let output = id.step(input: ID.Input(ins: ins))
        XCTAssertEqual(output.ctl_EX & 1, 1) // HLT control line is active
    }
    
    func testFlushOnJump() throws {
        let id = ID()
        let hltOpcode: UInt = 1
        let entry: UInt = hltOpcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = 1
        id.decoder = decoder
        let ins: UInt16 = UInt16(hltOpcode << 11)
        let output = id.step(input: ID.Input(ins: ins, j: 0))
        XCTAssertEqual(output.stall, 0)
        XCTAssertEqual(output.ctl_EX, ID.nopControlWord) // no active control lines
    }
    
    func testOperandForwarding_Forward_Y_EX_Instead_Of_rA() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b0000100011100000
        
        // The instruction in EX wants to write Y_EX back to the register file in r7. (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b11100000000
        let ctl_EX: UInt = ~UInt((1<<DecoderGenerator.WBEN) | (1<<DecoderGenerator.WriteBackSrcFlag))
        
        let output = id.step(input: ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0xabcd))
        
        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(output.a, 0xabcd) // The A operand comes from Y_EX instead of register file port A.
        XCTAssertEqual(output.ctl_EX, ID.nopControlWord)
    }
    
    func testStallOnRAWHazard_A_and_EX_In_StoreOp_Case() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b0000100011100000
        
        // The instruction in EX wants to write storeOP_EX back to the register file in r7. (WriteBackSrcFlag=1)
        let ins_EX: UInt = 0b11100000000
        let ctl_EX: UInt = ~UInt(1<<DecoderGenerator.WBEN)
        
        let output = id.step(input: ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0))
        
        XCTAssertEqual(output.stall, 1) // The CPU must stall.
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testOperandForwarding_Forward_Y_MEM_Instead_Of_rA() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b0000100011100000
        
        // The instruction in MEM wants to write Y_MEM back to the register file in r7. (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt((1<<DecoderGenerator.WBEN) | (1<<DecoderGenerator.WriteBackSrcFlag))
        
        let output = id.step(input: ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0xabcd))
        
        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(output.a, 0xabcd) // The A operand comes from Y_MEM instead of register file port A.
        XCTAssertEqual(output.ctl_EX, ID.nopControlWord)
    }
    
    func testStallOnRAWHazard_A_and_MEM_In_StoreOp_Case() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A
        let ins_ID: UInt16 = 0b0000100011100000
        
        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7. (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1<<DecoderGenerator.WBEN)
        
        let output = id.step(input: ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0))
        
        XCTAssertEqual(output.stall, 1) // The CPU must stall.
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testOperandForwarding_Forward_Y_EX_Instead_Of_rB() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b0000100000011100
        
        // The instruction in EX wants to write Y_EX back to the register file in r7. (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b11100000000
        let ctl_EX: UInt = ~UInt((1<<DecoderGenerator.WBEN) | (1<<DecoderGenerator.WriteBackSrcFlag))
        
        let output = id.step(input: ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0xabcd))
        
        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(output.b, 0xabcd) // The B operand comes from Y_EX instead of register file port B.
        XCTAssertEqual(output.ctl_EX, ID.nopControlWord)
    }
    
    func testStallOnRAWHazard_B_and_EX_In_StoreOp_Case() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b0000100000011100
        
        // The instruction in EX wants to write storeOP_EX back to the register file in r7. (WriteBackSrcFlag=1)
        let ins_EX: UInt = 0b11100000000
        let ctl_EX: UInt = ~UInt(1<<DecoderGenerator.WBEN)
        
        let output = id.step(input: ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0))
        
        XCTAssertEqual(output.stall, 1) // The CPU must stall.
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testOperandForwarding_Forward_Y_MEM_Instead_Of_rB() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b0000100000011100
        
        // The instruction in MEM wants to write Y_MEM back to the register file in r7. (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt((1<<DecoderGenerator.WBEN) | (1<<DecoderGenerator.WriteBackSrcFlag))
        
        let output = id.step(input: ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0xabcd))
        
        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(output.b, 0xabcd) // The B operand comes from Y_MEM instead of register file port B.
        XCTAssertEqual(output.ctl_EX, ID.nopControlWord)
    }
    
    func testStallOnRAWHazard_B_and_MEM_In_StoreOp_Case() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port B
        let ins_ID: UInt16 = 0b0000100000011100
        
        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7. (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1<<DecoderGenerator.WBEN)
        
        let output = id.step(input: ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0))
        
        XCTAssertEqual(output.stall, 1) // The CPU must stall.
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testOperandForwarding_Forward_Y_EX_Instead_Of_rA_and_rB() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b0000100011111100
        
        // The instruction in EX wants to write Y_EX back to the register file in r7. (WriteBackSrcFlag=0)
        let ins_EX: UInt = 0b11100000000
        let ctl_EX: UInt = ~UInt((1<<DecoderGenerator.WBEN) | (1<<DecoderGenerator.WriteBackSrcFlag))
        
        let output = id.step(input: ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0xabcd))
        
        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(output.a, 0xabcd) // The A operand comes from Y_EX instead of register file port A.
        XCTAssertEqual(output.b, 0xabcd) // The B operand comes from Y_EX instead of register file port B.
        XCTAssertEqual(output.ctl_EX, ID.nopControlWord)
    }
    
    func testStallOnRAWHazard_A_and_B_and_EX_In_StoreOp_Case() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b0000100011111100
        
        // The instruction in EX wants to write storeOP_EX back to the register file in r7. (WriteBackSrcFlag=1)
        let ins_EX: UInt = 0b11100000000
        let ctl_EX: UInt = ~UInt(1<<DecoderGenerator.WBEN)
        
        let output = id.step(input: ID.Input(ins: ins_ID, ins_EX: ins_EX, ctl_EX: ctl_EX, y_EX: 0))
        
        XCTAssertEqual(output.stall, 1) // The CPU must stall.
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testOperandForwarding_Forward_Y_MEM_Instead_Of_rA_and_rB() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b0000100011111100
        
        // The instruction in MEM wants to write Y_MEM back to the register file in r7. (WriteBackSrcFlag=0)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt((1<<DecoderGenerator.WBEN) | (1<<DecoderGenerator.WriteBackSrcFlag))
        
        let output = id.step(input: ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0xabcd))
        
        XCTAssertEqual(output.stall, 0) // No need to stall on this RAW hazard.
        XCTAssertEqual(output.a, 0xabcd) // The A operand comes from Y_MEM instead of register file port A.
        XCTAssertEqual(output.b, 0xabcd) // The B operand comes from Y_MEM instead of register file port B.
        XCTAssertEqual(output.ctl_EX, ID.nopControlWord)
    }
    
    func testStallOnRAWHazard_A_and_B_and_MEM_In_StoreOp_Case() throws {
        let id = ID()
        let opcode: UInt = 1
        let entry: UInt = opcode
        let decoder = OpcodeDecoderROM()
        decoder.opcodeDecodeROM[Int(entry)] = ID.nopControlWord
        id.decoder = decoder
        
        // The instruction in ID want to read r7 on port A and on port B
        let ins_ID: UInt16 = 0b0000100011111100
        
        // The instruction in MEM wants to write storeOP_MEM back to the register file in r7. (WriteBackSrcFlag=1)
        let selC_MEM: UInt = 0b111
        let ctl_MEM: UInt = ~UInt(1<<DecoderGenerator.WBEN)
        
        let output = id.step(input: ID.Input(ins: ins_ID, selC_MEM: selC_MEM, ctl_MEM: ctl_MEM, y_MEM: 0))
        
        XCTAssertEqual(output.stall, 1) // The CPU must stall.
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testStallOnFlagsHazard() throws {
        let id = ID()
        let beq: UInt16 = 24
        let input = ID.Input(ins: beq<<11, ctl_EX: 0b111111111111111011111)
        let output = id.step(input: input)
        XCTAssertEqual(output.stall, 1)
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testEquality_Equal() throws {
        let stageID1 = ID()
        stageID1.associatedPC = 1
        
        let stageID2 = ID()
        stageID2.associatedPC = 1
        
        XCTAssertEqual(stageID1, stageID2)
        XCTAssertEqual(stageID1.hash, stageID2.hash)
    }
    
    func testEquality_NotEqual() throws {
        let stageID1 = ID()
        stageID1.associatedPC = 1
        
        let stageID2 = ID()
        stageID2.associatedPC = 2
        
        XCTAssertNotEqual(stageID1, stageID2)
        XCTAssertNotEqual(stageID1.hash, stageID2.hash)
    }
    
    func testEncodeDecodeRoundTrip() throws {
        let stageID1 = ID()
        stageID1.associatedPC = 1
        
        var data: Data! = nil
        XCTAssertNoThrow(data = try NSKeyedArchiver.archivedData(withRootObject: stageID1, requiringSecureCoding: true))
        if data == nil {
            XCTFail()
            return
        }
        var stageID2: ID! = nil
        XCTAssertNoThrow(stageID2 = try ID.decode(from: data))
        XCTAssertEqual(stageID1, stageID2)
    }
}
