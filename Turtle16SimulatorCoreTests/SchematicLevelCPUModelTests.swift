//
//  SchematicLevelCPUModelTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class SchematicLevelCPUModelTests: XCTestCase {
    func testStartsInResetState() {
        let cpu = SchematicLevelCPUModel()
        XCTAssertTrue(cpu.isResetting)
    }
    
    func testExitsResetStateAfterSomeTime() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0000100000000000] // HLT
        cpu.reset()
        XCTAssertFalse(cpu.isResetting)
        XCTAssertFalse(cpu.isHalted)
    }
    
    func testNoStoresOrLoadsDuringReset() {
        let cpu = SchematicLevelCPUModel()
        cpu.load = {(addr: UInt16) in
            XCTFail()
            return 0 // do nothing
        }
        cpu.store = {(value: UInt16, addr: UInt16) in
            XCTFail()
        }
        cpu.reset()
    }
    
    func testProgramCounterIsZeroAfterReset() {
        let cpu = SchematicLevelCPUModel()
        cpu.reset()
        XCTAssertEqual(cpu.pc, 0)
    }
    
    func testStepAfterResetIncrementsProgramCounter1() {
        let cpu = SchematicLevelCPUModel()
        cpu.reset()
        cpu.step()
        XCTAssertEqual(cpu.pc, 1)
    }
    
    func testStepAfterResetIncrementsProgramCounter2() {
        let cpu = SchematicLevelCPUModel()
        cpu.reset()
        cpu.step()
        cpu.step()
        XCTAssertEqual(cpu.pc, 2)
    }
    
    func testReadAndWriteRegistersThroughCPUInterface() {
        let cpu = SchematicLevelCPUModel()
        cpu.setRegister(0, 0xcafe)
        XCTAssertEqual(cpu.getRegister(0), 0xcafe)
    }
    
    func testExecutingNOPHasNoEffectOnRegisters() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0000000000000000, // NOP
                            0b0000000000000000, // NOP
                            0b0000000000000000, // NOP
                            0b0000000000000000, // NOP
                            0b0000000000000000, // NOP
                            0b0000000000000000] // NOP
        cpu.reset()
        cpu.setRegister(0, 0xcafe)
        cpu.setRegister(1, 0x1111)
        cpu.setRegister(2, 0x2222)
        cpu.setRegister(3, 0x3333)
        cpu.setRegister(4, 0x4444)
        cpu.setRegister(5, 0x5555)
        cpu.setRegister(6, 0x6666)
        cpu.setRegister(7, 0x7777)
        cpu.step()
        cpu.step()
        cpu.step()
        cpu.step()
        cpu.step()
        XCTAssertEqual(cpu.getRegister(0), 0xcafe)
        XCTAssertEqual(cpu.getRegister(1), 0x1111)
        XCTAssertEqual(cpu.getRegister(2), 0x2222)
        XCTAssertEqual(cpu.getRegister(3), 0x3333)
        XCTAssertEqual(cpu.getRegister(4), 0x4444)
        XCTAssertEqual(cpu.getRegister(5), 0x5555)
        XCTAssertEqual(cpu.getRegister(6), 0x6666)
        XCTAssertEqual(cpu.getRegister(7), 0x7777)
    }
    
    func testClearRegisterToZeroWithXOR() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0101100000000000] // XOR r0, r0, r0
        cpu.reset()
        cpu.setRegister(0, 0xcafe)
        cpu.setRegister(1, 0x1111)
        cpu.setRegister(2, 0x2222)
        cpu.setRegister(3, 0x3333)
        cpu.setRegister(4, 0x4444)
        cpu.setRegister(5, 0x5555)
        cpu.setRegister(6, 0x6666)
        cpu.setRegister(7, 0x7777)
        cpu.step()
        cpu.step()
        cpu.step()
        cpu.step()
        cpu.step()
        XCTAssertEqual(cpu.getRegister(0), 0x0000)
        XCTAssertEqual(cpu.getRegister(1), 0x1111)
        XCTAssertEqual(cpu.getRegister(2), 0x2222)
        XCTAssertEqual(cpu.getRegister(3), 0x3333)
        XCTAssertEqual(cpu.getRegister(4), 0x4444)
        XCTAssertEqual(cpu.getRegister(5), 0x5555)
        XCTAssertEqual(cpu.getRegister(6), 0x6666)
        XCTAssertEqual(cpu.getRegister(7), 0x7777)
    }
    
    func testHlt() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0000100000000000] // HLT
        cpu.reset()
        XCTAssertFalse(cpu.isHalted)
        cpu.step() // IF
        XCTAssertFalse(cpu.isHalted)
        cpu.step() // ID
        XCTAssertFalse(cpu.isHalted)
        cpu.step() // EX
        XCTAssertTrue(cpu.isHalted)
    }
    
    func testLoad() {
        var observedLoadAddr: UInt16? = nil
        let cpu = SchematicLevelCPUModel()
        cpu.load = {(addr: UInt16) in
            if observedLoadAddr != nil {
                XCTFail()
            }
            observedLoadAddr = addr
            return 0xabcd
        }
        cpu.store = {(value: UInt16, addr: UInt16) in
            XCTFail()
        }
        cpu.instructions = [0b0001001100100001] // LOAD r3, 1(r1)
        cpu.reset()
        cpu.setRegister(1, 0xfffe)
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(3))
        XCTAssertEqual(0xffff, observedLoadAddr)
    }
    
    func testLi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0010001100001101] // LI r3, 0xd
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xd, cpu.getRegister(3))
    }
    
    func testLi_signExtended() {
        let cpu = SchematicLevelCPUModel()
        // The immediate value embedded in the instruction is 128. The high bit
        // is set so this is sign-extended to 65408.
        cpu.instructions = [0b0010001110000000] // LI r3, 65408
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(65408, cpu.getRegister(3))
    }
    
    func testLui() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0010101111001101] // LUI r3, 0xcd
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xcd00, cpu.getRegister(3))
    }
    
    func testCmp_equal() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0011000000101000] // CMP r1, r2
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0)) // CMP does not store the result
        XCTAssertEqual(1, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(1, cpu.z)
    }
    
    func testCmp_notEqual() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0011000000101000] // CMP r1, r2
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0)) // CMP does not store the result
        XCTAssertEqual(1, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testCmp_lessThan() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0011000000101000] // CMP r1, r2
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 1)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0)) // CMP does not store the result
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(1, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testCmp_greaterThanOrEqualTo() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0011000000101000] // CMP r1, r2
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0)) // CMP does not store the result
        XCTAssertEqual(1, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testAdd() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0011100000101000] // ADD r0, r1, r2
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(3, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testAdd_signedOverflow() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0011100000101000] // ADD r0, r1, r2
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0x7fff)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0x8001, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(1, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testAdd_unsignedOverflow() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0011100000101000] // ADD r0, r1, r2
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0xffff)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(1, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
}
