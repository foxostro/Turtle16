//
//  SchematicLevelCPUModelTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

extension SchematicLevelCPUModel {
    func run(stepLimit: UInt) {
        var counter = 0
        while !isHalted {
//            let oldPC = outputIF.pc
            step()
//            print("outputIF.pc: \(oldPC) -> \(outputIF.pc)")
//            print("outputIF.ins: \(outputIF.ins.asBinaryString())")
//            print("outputID.stall: \(outputID.stall)")
//            let j: Bool = outputEX.j == 0
//            print("j: \(j)")
//            print("registers: " + stageID.registerFile.map({ (value) -> String in
//                String(value, radix: 16, uppercase: false)
//            }).joined(separator: ", "))
//            print("---")
            counter = counter + 1
            if counter > stepLimit {
                XCTFail()
                break
            }
        }
//        print("counter: \(counter)")
    }
}

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
    
    func testHlt() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0000100000000000] // HLT
        cpu.reset()
        XCTAssertFalse(cpu.isHalted)
        cpu.step() // PC
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
        cpu.instructions = [
            0b0001001100100001 // LOAD r3, 1(r1)
        ]
        cpu.reset()
        cpu.setRegister(1, 0xfffe)
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(3))
        XCTAssertEqual(0xffff, observedLoadAddr)
    }
    
    func testStore() {
        var observedStoreAddr: UInt16? = nil
        var observedStoreVal: UInt16? = nil
        let cpu = SchematicLevelCPUModel()
        cpu.store = {(value: UInt16, addr: UInt16) in
            if observedStoreVal != nil {
                XCTFail()
            }
            observedStoreVal = value
            
            if observedStoreAddr != nil {
                XCTFail()
            }
            observedStoreAddr = addr
        }
        cpu.instructions = [
            0b0001111100101111 // STORE r3, -1(r1) -- 0bkkkkkiiiaaabbbii
        ]
        
        cpu.reset()
        cpu.setRegister(1, 0x0000)
        cpu.setRegister(3, 0xabcd)
        
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        
        XCTAssertEqual(observedStoreAddr, 0xffff)
        XCTAssertEqual(observedStoreVal,  0xabcd)
    }
    
    func testLi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0010001100001101] // LI r3, 0xd
        cpu.reset()
        cpu.step() // PC
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
        cpu.step() // PC
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
        cpu.step() // PC
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
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
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
        cpu.step() // PC
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
        cpu.step() // PC
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
        cpu.step() // PC
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
        cpu.step() // PC
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
        cpu.step() // PC
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
        cpu.step() // PC
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
    
    func testSub() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0100000000101000] // SUB r0, r1, r2
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 10)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(8, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testSub_underflow() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0100000000101000] // SUB r0, r1, r2
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xffff, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(1, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testAnd() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0100100000101000] // AND r0, r1, r2
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0xabcd)
        cpu.setRegister(2, 0xf0f0)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xa0c0, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testOr() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0101000000101000] // OR r0, r1, r2
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0xabcd)
        cpu.setRegister(2, 0xf0f0)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xfbfd, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testXor() {
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
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(cpu.getRegister(0), 0x0000)
        XCTAssertEqual(cpu.getRegister(1), 0x1111)
        XCTAssertEqual(cpu.getRegister(2), 0x2222)
        XCTAssertEqual(cpu.getRegister(3), 0x3333)
        XCTAssertEqual(cpu.getRegister(4), 0x4444)
        XCTAssertEqual(cpu.getRegister(5), 0x5555)
        XCTAssertEqual(cpu.getRegister(6), 0x6666)
        XCTAssertEqual(cpu.getRegister(7), 0x7777)
    }
    
    func testNot() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0110000000101000] // NOT r0, r1
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0b1010101010101010)
        cpu.setRegister(2, 0b0101010101010101)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0b0101010101010101, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testCmpi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0110100000100001] // CMPI r1, #1
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0)) // CMPI does not store the result
        XCTAssertEqual(1, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testAddi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0111000000100010] // ADDI r0, r1, #2
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xffff)
        cpu.reset()
        cpu.step() // PC
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
    
    func testSubi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b0111100000100001] // SUBI r0, r1, #1
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xffff, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(1, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testAndi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b1000000000101111] // ANDI r0, r1, #15
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xffff)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0x000f, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testOri() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b1000100000101111] // ORI r0, r1, #15
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xfff0)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xffff, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testXori() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b1001000000101010] // XORI r0, r1, #10
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xfffc)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0xfff6, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(0, cpu.z)
    }
    
    func testAdc_carry_is_set() {
        // r0 = r1 + r2 + Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b1111000000101000] // ADC r0, r1, r2
        cpu.carry = 1
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 1)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step() // PC
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
    
    func testAdc_carry_is_unset() {
        // r0 = r1 + r2 + Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b1111000000101000] // ADC r0, r1, r2
        cpu.carry = 0
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0)
        cpu.setRegister(2, 0)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(1, cpu.z)
    }
    
    func testsSbc_carry_is_set() {
        // r0 = r1 - r2 - Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b1111100000101000] // SBC r0, r1, r2
        cpu.carry = 1
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step() // PC
        cpu.step() // IF
        cpu.step() // ID
        cpu.step() // EX
        cpu.step() // MEM
        cpu.step() // WB
        XCTAssertEqual(0, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.carry)
        XCTAssertEqual(0, cpu.ovf)
        XCTAssertEqual(1, cpu.z)
    }
    
    func testSbc_carry_is_unset() {
        // r0 = r1 - r2 - Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [0b1111100000101000] // SBC r0, r1, r2
        cpu.carry = 0
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step() // PC
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
    
    func testJmp_forward() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1010001111111111, // JMP #1023 -- pc := pc + 1023
        ]
        cpu.reset()
        XCTAssertEqual(0, cpu.pc)
        cpu.step() // PC
        XCTAssertEqual(1, cpu.pc)
        cpu.step() // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step() // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step() // EX
        XCTAssertEqual(1026, cpu.pc)
        cpu.step() // MEM
        XCTAssertEqual(1027, cpu.pc)
        cpu.step() // WB
        XCTAssertEqual(1028, cpu.pc)
    }
    
    func testJmp_backward() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1010011111111110, // JMP #-2 -- pc := pc - 2
        ]
        cpu.reset()
        XCTAssertEqual(0, cpu.pc)
        cpu.step() // PC
        XCTAssertEqual(1, cpu.pc)
        cpu.step() // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step() // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step() // EX
        XCTAssertEqual(1, cpu.pc)
        cpu.step() // MEM
        XCTAssertEqual(2, cpu.pc)
        cpu.step() // WB
        XCTAssertEqual(3, cpu.pc)
    }
    
    func testJmp_stallsPipelineToAvoidNeedForDelaySlots() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1010001111111111, // JMP #1023 -- pc := pc + 1023
            0b0010000000001101  // LI r0, #0xd
        ]
        cpu.reset()
        XCTAssertEqual(0, cpu.pc)
        cpu.step() // PC
        XCTAssertEqual(1, cpu.pc)
        cpu.step() // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step() // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step() // EX
        XCTAssertEqual(1026, cpu.pc)
        cpu.step() // MEM
        XCTAssertEqual(1027, cpu.pc)
        cpu.step() // WB
        XCTAssertEqual(1028, cpu.pc)
        cpu.step()
        XCTAssertEqual(1029, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }
    
    func testJr_ImmIsZero() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1010100000100000, // JR r1, #0 -- pc := r1 + 0
            0b0010000000001101  // LI r0, #0xd
        ]
        cpu.reset()
        cpu.setRegister(1, 1026)
        XCTAssertEqual(0, cpu.pc)
        cpu.step() // PC
        XCTAssertEqual(1, cpu.pc)
        cpu.step() // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step() // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step() // EX
        XCTAssertEqual(1026, cpu.pc)
        cpu.step() // MEM
        XCTAssertEqual(1027, cpu.pc)
        cpu.step() // WB
        XCTAssertEqual(1028, cpu.pc)
        cpu.step()
        XCTAssertEqual(1029, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }
    
    func testJr_ImmIsPositive() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1010100000101111, // JR r1, #15 -- pc := r1 + 15
            0b0010000000001101  // LI r0, #0xd
        ]
        cpu.reset()
        cpu.setRegister(1, 1000)
        XCTAssertEqual(0, cpu.pc)
        cpu.step() // PC
        XCTAssertEqual(1, cpu.pc)
        cpu.step() // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step() // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step() // EX
        XCTAssertEqual(1015, cpu.pc)
        cpu.step() // MEM
        XCTAssertEqual(1016, cpu.pc)
        cpu.step() // WB
        XCTAssertEqual(1017, cpu.pc)
        cpu.step()
        XCTAssertEqual(1018, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }
    
    func testJr_ImmIsNegative() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1010100000111111, // JR r1, #-1 -- pc := r1 - 1
            0b0010000000001101  // LI r0, #0xd
        ]
        cpu.reset()
        cpu.setRegister(1, 1000)
        XCTAssertEqual(0, cpu.pc)
        cpu.step() // PC
        XCTAssertEqual(1, cpu.pc)
        cpu.step() // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step() // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step() // EX
        XCTAssertEqual(999, cpu.pc)
        cpu.step() // MEM
        XCTAssertEqual(1000, cpu.pc)
        cpu.step() // WB
        XCTAssertEqual(1001, cpu.pc)
        cpu.step()
        XCTAssertEqual(1002, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }
    
    func testJalr() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1011011100100000 // JALR r7, r1, #0 -- r7 := pc + 1 ; pc := r1 + 0
        ]
        cpu.reset()
        cpu.setRegister(1, 1000)
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1000, cpu.pc)
        cpu.step()
        XCTAssertEqual(1001, cpu.pc)
        cpu.step() // The JALR instruction writes back to register file now.
        XCTAssertEqual(1002, cpu.pc)
        XCTAssertEqual(3, cpu.getRegister(7))
        cpu.step()
        XCTAssertEqual(1003, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }
    
    func testJalr_andThenReturn() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1011011100100000, // JALR r7, r1, #0 -- r7 := pc + 1 ; pc := r1 + 0
            0b0000100000000000, // HLT
            0b0000000000000010, // NOP
            0b0010011000001101, // LI r6, #13
            0b1010100011111111, // JR r7, #-1 -- pc := r7 - 1
            0b0000100000000000  // HLT
        ]
        cpu.reset()
        cpu.setRegister(1, 4)
        
        // PC    IF    ID     EX     MEM    WB
        // JALR  -     -      -      -      -
        cpu.step()
        XCTAssertEqual(cpu.pc, 1)
        
        // PC    IF    ID     EX     MEM    WB
        // HLT   JALR  -      -      -      -
        cpu.step()
        XCTAssertEqual(cpu.pc, 2)
        XCTAssertEqual(cpu.outputIF.ins, 0b1011011100100000)
       
        // PC    PC    IF     ID     EX     MEM    WB
        // NOP   HLT   JALR   -      -      -      -
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputIF.ins, 0b0000100000000000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000011100100000)
        
        // PC    IF    ID     EX     MEM    WB
        // LI    NOP   NOP    JALR   -      -
        cpu.step()
        XCTAssertEqual(cpu.pc, 4)
        XCTAssertEqual(cpu.outputIF.ins, 0b0000000000000000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000000000)
        
        // PC    IF    ID     EX     MEM    WB
        // JR    LI    NOP    NOP    JALR   -
        cpu.step()
        XCTAssertEqual(cpu.pc, 5)
        XCTAssertEqual(cpu.outputIF.ins, 0b0010011000001101)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000000000)
        
        // PC    IF    ID     EX     MEM    WB
        // HLT   JR    LI     NOP    NOP    JALR
        XCTAssertNotEqual(cpu.getRegister(7), 3)
        cpu.step()
        XCTAssertEqual(cpu.getRegister(7), 3)
        XCTAssertEqual(cpu.pc, 6)
        XCTAssertEqual(cpu.outputIF.ins, 0b1010100011111111)
        XCTAssertEqual(cpu.outputID.ins, 0b0000011000001101)
        
        // PC    IF    ID     EX     MEM    WB
        // -     HLT   JR     LI     NOP    NOP
        cpu.step()
        XCTAssertEqual(cpu.pc, 7)
        XCTAssertEqual(cpu.outputIF.ins, 0b0000100000000000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000011111111)
        
        // PC    IF    ID     EX     MEM    WB
        // HLT   NOP   NOP    JR     LI     NOP
        cpu.step()
        XCTAssertEqual(cpu.pc, 2)
        XCTAssertEqual(cpu.outputIF.ins, 0b0000000000000000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000000000)
        
        // PC    IF    ID     EX     MEM    WB
        // NOP   HLT   NOP    NOP    JR     LI
        XCTAssertNotEqual(cpu.getRegister(6), 13)
        cpu.step()
        XCTAssertEqual(cpu.getRegister(6), 13)
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputIF.ins, 0b0000100000000000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000000000)
        
        // PC    IF    ID     EX     MEM    WB
        // LI    NOP   HLT    NOP    NOP    JR
        cpu.step()
        XCTAssertEqual(cpu.pc, 4)
        XCTAssertEqual(cpu.outputIF.ins, 0b0000000000000010)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000000000)
        XCTAssertEqual(cpu.getRegister(6), 13)
        
        // PC    IF    ID     EX     MEM    WB
        // JR    LI    NOP    HLT    NOP    NOP
        cpu.step()
        XCTAssertEqual(cpu.pc, 5)
        XCTAssertEqual(cpu.outputIF.ins, 0b0010011000001101)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000000010)
        XCTAssertTrue(cpu.isHalted)
    }
    
    func testBeq_takeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1100001111111111 // BEQ #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
    }
    
    func testBeq_dontTakeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1100001111111111 // BEQ #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
    }
    
    func testBne_takeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1100101111111111 // BNE #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
    }
    
    func testBne_dontTakeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1100101111111111 // BNE #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
    }
    
    func testBlt_takeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1101001111111111 // BLT #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
    }
    
    func testBlt_dontTakeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1101001111111111 // BLT #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
    }
    
    func testBge_takeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1101101111111111 // BGE #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
    }
    
    func testBge_dontTakeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1101101111111111 // BGE #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
    }
    
    func testBltu_takeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1110001111111111 // BLTU #1023
        ]
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
    }
    
    func testBltu_dontTakeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1110001111111111 // BLTU #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
    }
    
    func testBgeu_takeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1110101111111111 // BGEU #1023
        ]
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
        
        cpu.reset()
        cpu.carry = 0
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()
        XCTAssertEqual(1028, cpu.pc)
    }
    
    func testBgeu_dontTakeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b1110101111111111 // BGEU #1023
        ]
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 0
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 0
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
        
        cpu.reset()
        cpu.carry = 1
        cpu.ovf = 1
        cpu.z = 1
        XCTAssertEqual(0, cpu.pc)
        cpu.step()
        XCTAssertEqual(1, cpu.pc)
        cpu.step()
        XCTAssertEqual(2, cpu.pc)
        cpu.step()
        XCTAssertEqual(3, cpu.pc)
        cpu.step()
        XCTAssertEqual(4, cpu.pc)
    }
    
    func testDemonstrateHazard_RAW() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b0010000100000000, // LI r1, #0
            0b0011100000101000  // ADD r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 1)
        cpu.setRegister(2, 1)
        cpu.reset()
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     -     -     -      -
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0)
        XCTAssertEqual(cpu.outputID.ins, 0)
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // ADD   LI    -     -     -      -
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0b0010000100000000)
        XCTAssertEqual(cpu.outputID.ins, 0)
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     ADD   LI    -     -      -
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0b0011100000101000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000100000000)
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     ADD   ADD   LI    -      -  (parameters of ADD are resolved here)
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0b0011100000101000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000101000)
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     ADD   ADD   -     LI     -  (stalling)
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0b0011100000101000)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000101000)
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     ADD   -     -      LI (result of LI is stored here)
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000000101000)
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     -     ADD   -      -
        cpu.step()
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     -     -     ADD    -
        cpu.step()
        XCTAssertEqual(cpu.outputMEM.selC, 0)
        XCTAssertTrue(cpu.outputMEM.ctl & ~UInt(1<<DecoderGenerator.WBEN) != 0)
        XCTAssertEqual(cpu.outputMEM.y, 1)
        
        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     -     -     -      ADD (result of ADD is stored here)
        cpu.step()
        XCTAssertEqual(cpu.getRegister(0), 1)
        XCTAssertEqual(cpu.getRegister(1), 0)
        XCTAssertEqual(cpu.getRegister(2), 1)
    }
    
    func testDemonstrateHazard_Flags() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b0011000000101000, // CMP r1, r2
            0b1100001111111111  // BEQ #1023
        ]
        cpu.reset()
        cpu.setRegister(1, 1)
        cpu.setRegister(2, 1)
        cpu.carry = 0
        cpu.ovf = 0
        cpu.z = 0
        //            PC    IF    ID    EX    MEM    WB
        cpu.step() // BEQ   CMP   -     -     -      -
        cpu.step() // -     BEQ   CMP   -     -      -
        cpu.step() // -     -     BEQ   CMP   -      - (stalling, flags are updated at the end of the cycle)
        cpu.step() // -     -     BEQ   -     CMP    -
        XCTAssertEqual(cpu.outputID.ctl_EX, ID.nopControlWord)
    }
    
    func testDemonstrateHazard_MemoryLoad() {
        let cpu = SchematicLevelCPUModel()
        cpu.load = {(addr: UInt16) in
            return 1
        }
        cpu.instructions = [
            0b0001000011100000, // LOAD r0, r7
            0b0011101000000100  // ADD r2, r0, r1
        ]
        cpu.reset()
        
        // ADD depends on LOAD. The pipeline must stall until the LOAD retires.
        
        // PC    IF    ID      EX      MEM     WB
        // LOAD  -      -       -       -       -
        cpu.step()
        XCTAssertEqual(cpu.pc, 1)
        XCTAssertEqual(cpu.outputIF.ins, 0)
        XCTAssertEqual(cpu.outputID.ins, 0)
        
        // PC    IF    ID      EX      MEM     WB
        // ADD   LOAD  -       -       -       -
        cpu.step()
        XCTAssertEqual(cpu.pc, 2)
        XCTAssertEqual(cpu.outputIF.ins, 0b0001000011100000)
        XCTAssertEqual(cpu.outputID.ins, 0)
        
        // PC    IF    ID      EX      MEM     WB
        // -     ADD   LOAD    -       -       -
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputIF.ins, 0b0011101000000100)
        XCTAssertEqual(cpu.outputID.ins, 0b0000000011100000)
        
        // PC    IF    ID      EX      MEM     WB
        // -     ADD   ADD     LOAD    -       - (stall)
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputID.stall, 1)
        XCTAssertEqual(cpu.outputIF.ins, 0b0011101000000100)
        XCTAssertEqual(cpu.outputID.ins, 0b0000001000000100)
        
        // PC    IF    ID      EX      MEM     WB
        // -     ADD     ADD     NOP     LOAD    - (stall)
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputID.stall, 1)
        XCTAssertEqual(cpu.outputIF.ins, 0b0011101000000100)
        XCTAssertEqual(cpu.outputID.ins, 0b0000001000000100)
        XCTAssertEqual(cpu.outputID.ctl_EX, ID.nopControlWord)
        
        // PC    IF    ID      EX      MEM     WB
        // -     -     ADD     NOP     NOP     LOAD
        XCTAssertEqual(cpu.getRegister(0), 0)
        cpu.step()
        XCTAssertEqual(cpu.getRegister(0), 1)
        XCTAssertEqual(cpu.pc, 4)
        XCTAssertEqual(cpu.outputID.stall, 0)
        XCTAssertEqual(cpu.outputID.a, 1)
        XCTAssertEqual(cpu.outputID.b, 0)
        
        // PC    IF    ID      EX      MEM     WB
        // -     -     -       ADD     NOP     NOP
        cpu.step()
        XCTAssertEqual(cpu.outputEX.selC, 2)
        
        // PC    IF    ID      EX      MEM     WB
        // -     -     -       -       ADD     NOP
        cpu.step()
        XCTAssertEqual(cpu.getRegister(2), 0)
        
        // PC    IF    ID      EX      MEM     WB
        // -     -     -       -       -       ADD
        cpu.step()
        XCTAssertEqual(cpu.getRegister(2), 1)
    }
    
    func testCountdownLoop() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b0010011100000101, // LI r7, #5
            0b0111111111100001, // SUBI r7, r7, #1
            0b1100111111111101, // BNZ #-3
            0b0000100000000000, // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 30)
        XCTAssertEqual(cpu.getRegister(7), 0)
    }
    
    func testLoop() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b0010011100000000, // LI r7, #0
            0b0111011111100001, // ADDI r7, r7, #1
            0b0110100011101001, // CMPI r7, #1
            0b1101011111111100, // BLT #-4
            0b0000100000000000, // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 59)
        XCTAssertEqual(cpu.getRegister(7), 9)
    }
    
    func testFibonacci() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b0010000000000000, // LI r0, #0
            0b0010000100000001, // LI r1, #1
            0b0010011100000000, // LI r7, #0
            0b0011101000000100, // ADD r2, r0, r1
            0b0111000000100000, // ADDI r0, r1, #0
            0b0111011111100001, // ADDI r7, r7, #1
            0b0111000101000000, // ADDI r1, r2, #0
            0b0110100011101001, // CMPI r7, #9
            0b1101011111111001, // BLT #-7
            0b0000100000000000, // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 89)
        XCTAssertEqual(cpu.getRegister(2), 55)
    }
    
    func testFibonacci_avoid_storeOp_dependencies() {
        // Write the fibonacci program in a way that avoids depending on the
        // storeOperand of a previous instruction. This means replacing LI
        // instructions with a combination of XOR and ADDI. Doing this avoids
        // stalls and saves a couple of cycles.
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b0101100000000000, // XOR r0, r0, r0
            0b0101100100100100, // XOR r1, r1, r1
            0b0111000100100001, // ADDI r1, r1, #1
            0b0101111111111100, // XOR r7, r7, r7
            0b0011101000000100, // ADD r2, r0, r1
            0b0111000000100000, // ADDI r0, r1, #0
            0b0111011111100001, // ADDI r7, r7, #1
            0b0111000101000000, // ADDI r1, r2, #0
            0b0110100011101001, // CMPI r7, #9
            0b1101011111111001, // BLT #-7
            0b0000100000000000, // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 87)
        XCTAssertEqual(cpu.getRegister(2), 55)
    }
}
