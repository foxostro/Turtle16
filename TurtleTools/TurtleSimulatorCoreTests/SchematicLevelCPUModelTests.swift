//
//  SchematicLevelCPUModelTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

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

final class SchematicLevelCPUModelTests: XCTestCase {
    func testStartsInResetState() {
        let cpu = SchematicLevelCPUModel()
        XCTAssertTrue(cpu.isResetting)
    }

    func testExitsResetStateAfterSomeTime() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00001000_00000000,  // HLT
        ]
        cpu.reset()
        XCTAssertFalse(cpu.isResetting)
        XCTAssertFalse(cpu.isHalted)
    }

    func testSetAndGetMemoryAccessClosures() {
        let cpu = SchematicLevelCPUModel()
        var count = 0
        let load: (MemoryAddress) -> UInt16 = { (addr: MemoryAddress) in
            count += 1
            return 0  // do nothing
        }
        let store: (UInt16, MemoryAddress) -> Void = { (value: UInt16, addr: MemoryAddress) in
            count += 1
        }
        cpu.load = load
        cpu.store = store
        _ = cpu.load(MemoryAddress(0))
        cpu.store(0, MemoryAddress(0))
        XCTAssertEqual(count, 2)
    }

    func testNoStoresOrLoadsDuringReset() {
        let cpu = SchematicLevelCPUModel()
        cpu.load = { (addr: MemoryAddress) in
            XCTFail()
            return 0  // do nothing
        }
        cpu.store = { (value: UInt16, addr: MemoryAddress) in
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
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00000000_00000000,  // NOP
            0b00000000_00000000,  // NOP
            0b00000000_00000000,  // NOP
            0b00000000_00000000,  // NOP
            0b00000000_00000000,  // NOP
        ]
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
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00001000_00000000,  // HLT
        ]
        cpu.reset()
        XCTAssertFalse(cpu.isHalted)
        cpu.step()  // -
        XCTAssertFalse(cpu.isHalted)
        cpu.step()  // IF
        XCTAssertFalse(cpu.isHalted)
        cpu.step()  // ID
        XCTAssertFalse(cpu.isHalted)
        cpu.step()  // EX
        XCTAssertTrue(cpu.isHalted)
    }

    func testLoad() {
        var observedLoadAddr: UInt16? = nil
        let cpu = SchematicLevelCPUModel()
        cpu.load = { (addr: MemoryAddress) in
            if observedLoadAddr != nil {
                XCTFail()
            }
            observedLoadAddr = UInt16(addr.value)
            return 0xabcd
        }
        cpu.store = { (value: UInt16, addr: MemoryAddress) in
            XCTFail()
        }
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00010011_00100001,  // LOAD r3, 1(r1)
        ]
        cpu.reset()
        cpu.setRegister(1, 0xfffe)
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(3))
        XCTAssertEqual(0xffff, observedLoadAddr)
    }

    func testStore() {
        var observedStoreAddr: MemoryAddress? = nil
        var observedStoreVal: UInt16? = nil
        let cpu = SchematicLevelCPUModel()
        cpu.store = { (value: UInt16, addr: MemoryAddress) in
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
            0b00000000_00000000,  // NOP
            0b00011111_00101111,  // STORE r3, r1, -1 -- 0bkkkkkiiiaaabbbii
        ]

        cpu.reset()
        cpu.setRegister(1, 0x0000)
        cpu.setRegister(3, 0xabcd)

        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM

        XCTAssertEqual(observedStoreAddr?.value, 0xffff)
        XCTAssertEqual(observedStoreVal, 0xabcd)
    }

    func testLi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00100011_00001101,  // LI r3, 0xd
        ]
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xd, cpu.getRegister(3))
    }

    func testLi_signExtended() {
        let cpu = SchematicLevelCPUModel()
        // The immediate value embedded in the instruction is 128. The high bit
        // is set so this is sign-extended to 65408.
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00100011_10000000,  // LI r3, 65408
        ]
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(65408, cpu.getRegister(3))
    }

    func testLui() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00101011_11001101,  // LUI r3, 0xcd
        ]
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xcd00, cpu.getRegister(3))
    }

    func testCmp_equal() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00110000_00101000,  // CMP r1, r2
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        XCTAssertEqual(0xabcd, cpu.getRegister(0))  // CMP does not store the result
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(1, cpu.z)
    }

    func testCmp_notEqual() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00110000_00101000,  // CMP r1, r2
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0))  // CMP does not store the result
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testCmp_lessThan() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00110000_00101000,  // CMP r1, r2
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 1)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0))  // CMP does not store the result
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testCmp_greaterThanOrEqualTo() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00110000_00101000,  // CMP r1, r2
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0))  // CMP does not store the result
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAdd() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00111000_00101000,  // ADD r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(3, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAdd_signedOverflow() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00111000_00101000,  // ADD r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0x7fff)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0x8001, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(1, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAdd_unsignedOverflow() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00111000_00101000,  // ADD r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0xffff)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(1, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testSub() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01000000_00101000,  // SUB r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 10)
        cpu.setRegister(2, 2)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(8, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testSub_underflow_unsigned() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01000000_00101000,  // SUB r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xffff, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testSub_underflow_signed() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01000000_00101000,  // SUB r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0x8000)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0x7fff, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(1, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAnd() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01001000_00101000,  // AND r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0xabcd)
        cpu.setRegister(2, 0xf0f0)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xa0c0, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testOr() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01010000_00101000,  // OR r0, r1, r2
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0xabcd)
        cpu.setRegister(2, 0xf0f0)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xfbfd, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testXor() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01011000_00000000,  // XOR r0, r0, r0
        ]
        cpu.reset()
        cpu.setRegister(0, 0xcafe)
        cpu.setRegister(1, 0x1111)
        cpu.setRegister(2, 0x2222)
        cpu.setRegister(3, 0x3333)
        cpu.setRegister(4, 0x4444)
        cpu.setRegister(5, 0x5555)
        cpu.setRegister(6, 0x6666)
        cpu.setRegister(7, 0x7777)
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
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
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01100000_00101000,  // NOT r0, r1
        ]
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0b10101010_10101010)
        cpu.setRegister(2, 0b01010101_01010101)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0b01010101_01010101, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testCmpi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01101000_00100001,  // CMPI r1, 1
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 2)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xabcd, cpu.getRegister(0))  // CMPI does not store the result
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAddi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01110000_00100010,  // ADDI r0, r1, 2
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xffff)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(1, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testSubi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b01111000_00100001,  // SUBI r0, r1, 1
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xffff, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAndi() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10000000_00101111,  // ANDI r0, r1, 15
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xffff)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0x000f, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testOri() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10001000_00101111,  // ORI r0, r1, 15
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xfff0)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xffff, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testXori() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10010000_00101010,  // XORI r0, r1, 10
        ]
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, 0xfffc)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0xfff6, cpu.getRegister(0))
        XCTAssertEqual(1, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAdc_carry_is_set() {
        // r0 = r1 + r2 + Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11110000_00101000,  // ADC r0, r1, r2
        ]
        cpu.c = 1
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 1)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(3, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testAdc_carry_is_unset() {
        // r0 = r1 + r2 + Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11110000_00101000,  // ADC r0, r1, r2
        ]
        cpu.c = 0
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 0)
        cpu.setRegister(2, 0)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(0, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(1, cpu.z)
    }

    func testsSbc_carry_is_set() {
        // r0 = r1 - r2 - Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11111000_00101000,  // SBC r0, r1, r2
        ]
        cpu.c = 1
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(0, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(1, cpu.z)
    }

    func testSbc_carry_is_unset() {
        // r0 = r1 - r2 - Cf
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11111000_00101000,  // SBC r0, r1, r2
        ]
        cpu.c = 0
        cpu.setRegister(0, 0)
        cpu.setRegister(1, 2)
        cpu.setRegister(2, 1)
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB
        XCTAssertEqual(1, cpu.getRegister(0))
        XCTAssertEqual(0, cpu.n)
        XCTAssertEqual(1, cpu.c)
        XCTAssertEqual(0, cpu.v)
        XCTAssertEqual(0, cpu.z)
    }

    func testJmp_forward() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10100011_11111111,  // JMP 1023 -- pc := pc + 1023
        ]
        cpu.reset()
        XCTAssertEqual(0, cpu.pc)
        cpu.step()  // -
        XCTAssertEqual(1, cpu.pc)
        cpu.step()  // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step()  // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step()  // EX
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()  // MEM
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()  // WB
        XCTAssertEqual(1028, cpu.pc)
    }

    func testJmpForwardLikeAnExpensiveNop() {
        // A JMP instruction with an offset of -1 is effectively an expensive
        // NOP. Take the offset of -1 and add to it the static offset of 2 to
        // get the final offset of the next instruction: +1. So, the JMP will
        // branch to the instruction immediately following the JMP.
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10100111_11111111,  // JMP -1
            0b01110000_00000001,  // ADDI r0, r0, 1
            0b01110000_00000001,  // ADDI r0, r0, 1
            0b01110000_00000001,  // ADDI r0, r0, 1
            0b00000000_00000000,  // NOP (allow CPU a cycle to write back result of ADDI)
            0b00001000_00000000,  // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 11)
        XCTAssertEqual(cpu.getRegister(0), 3)
    }

    func testJmpForever() {
        // A JMP instruction with an offset of -2 will effectively loop forever.
        // Take the offset of -2 and add to it the static offset of 2 to get the
        // final offset of the next instruction: +0. So, the JMP will branch to
        // itself and execute again.
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10100111_11111110,  // JMP -2
        ]
        cpu.reset()
        cpu.step()
        cpu.step()
        cpu.step()
        cpu.step()
        XCTAssertEqual(cpu.pc, 1)
    }

    func testJmp_backward() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10100111_11111110,  // JMP -2 -- pc := pc - 2
        ]
        cpu.reset()
        XCTAssertEqual(0, cpu.pc)
        cpu.step()  // -
        XCTAssertEqual(1, cpu.pc)
        cpu.step()  // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step()  // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step()  // EX
        XCTAssertEqual(1, cpu.pc)
        cpu.step()  // MEM
        XCTAssertEqual(2, cpu.pc)
        cpu.step()  // WB
        XCTAssertEqual(3, cpu.pc)
    }

    func testJmp_stallsPipelineToAvoidNeedForDelaySlots() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10100011_11111111,  // JMP 1023 -- pc := pc + 1023
            0b00100000_00001101,  // LI r0, 0xd
        ]
        cpu.reset()
        XCTAssertEqual(0, cpu.pc)
        cpu.step()  // -
        XCTAssertEqual(1, cpu.pc)
        cpu.step()  // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step()  // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step()  // EX
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()  // MEM
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()  // WB
        XCTAssertEqual(1028, cpu.pc)
        cpu.step()
        XCTAssertEqual(1029, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }

    func testJr_ImmIsZero() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10101000_00100000,  // JR r1, 0 -- pc := r1 + 0
            0b00100000_00001101,  // LI r0, 0xd
        ]
        cpu.reset()
        cpu.setRegister(1, 1026)
        XCTAssertEqual(0, cpu.pc)
        cpu.step()  // -
        XCTAssertEqual(1, cpu.pc)
        cpu.step()  // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step()  // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step()  // EX
        XCTAssertEqual(1026, cpu.pc)
        cpu.step()  // MEM
        XCTAssertEqual(1027, cpu.pc)
        cpu.step()  // WB
        XCTAssertEqual(1028, cpu.pc)
        cpu.step()
        XCTAssertEqual(1029, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }

    func testJr_ImmIsPositive() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10101000_00101111,  // JR r1, 15 -- pc := r1 + 15
            0b00100000_00001101,  // LI r0, 0xd
        ]
        cpu.reset()
        cpu.setRegister(1, 1000)
        XCTAssertEqual(0, cpu.pc)
        cpu.step()  // -
        XCTAssertEqual(1, cpu.pc)
        cpu.step()  // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step()  // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step()  // EX
        XCTAssertEqual(1015, cpu.pc)
        cpu.step()  // MEM
        XCTAssertEqual(1016, cpu.pc)
        cpu.step()  // WB
        XCTAssertEqual(1017, cpu.pc)
        cpu.step()
        XCTAssertEqual(1018, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }

    func testJr_ImmIsNegative() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10101000_00111111,  // JR r1, -1 -- pc := r1 - 1
            0b00100000_00001101,  // LI r0, 0xd
        ]
        cpu.reset()
        cpu.setRegister(1, 1000)
        XCTAssertEqual(0, cpu.pc)
        cpu.step()  // -
        XCTAssertEqual(1, cpu.pc)
        cpu.step()  // IF
        XCTAssertEqual(2, cpu.pc)
        cpu.step()  // ID
        XCTAssertEqual(3, cpu.pc)
        cpu.step()  // EX
        XCTAssertEqual(999, cpu.pc)
        cpu.step()  // MEM
        XCTAssertEqual(1000, cpu.pc)
        cpu.step()  // WB
        XCTAssertEqual(1001, cpu.pc)
        cpu.step()
        XCTAssertEqual(1002, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }

    func testJalr() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10110111_00100000,  // JALR r7, r1, 0 -- r7 := pc + 1 ; pc := r1 + 0
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
        cpu.step()  // The JALR instruction writes back to register file now.
        XCTAssertEqual(1002, cpu.pc)
        XCTAssertEqual(3, cpu.getRegister(7))
        cpu.step()
        XCTAssertEqual(1003, cpu.pc)
        XCTAssertEqual(0, cpu.getRegister(0))
    }

    func testJalr_andThenReturn() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b10110111_00100000,  // JALR r7, r1, 0 -- r7 := pc + 1 ; pc := r1 + 0
            0b00001000_00000000,  // HLT
            0b00000000_00000010,  // NOP
            0b00100110_00001101,  // LI r6, 13
            0b10101000_11111111,  // JR r7, -1 -- pc := r7 - 1
            0b00001000_00000000,  // HLT
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
        XCTAssertEqual(cpu.outputIF.ins, 0b10110111_00100000)

        // PC    PC    IF     ID     EX     MEM    WB
        // NOP   HLT   JALR   -      -      -      -
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputIF.ins, 0b00001000_00000000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000111_00100000)

        // PC    IF    ID     EX     MEM    WB
        // LI    NOP   NOP    JALR   -      -
        cpu.step()
        XCTAssertEqual(cpu.pc, 4)
        XCTAssertEqual(cpu.outputIF.ins, 0b00000000_00000000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00000000)

        // PC    IF    ID     EX     MEM    WB
        // JR    LI    NOP    NOP    JALR   -
        cpu.step()
        XCTAssertEqual(cpu.pc, 5)
        XCTAssertEqual(cpu.outputIF.ins, 0b00100110_00001101)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00000000)

        // PC    IF    ID     EX     MEM    WB
        // HLT   JR    LI     NOP    NOP    JALR
        XCTAssertNotEqual(cpu.getRegister(7), 3)
        cpu.step()
        XCTAssertEqual(cpu.getRegister(7), 3)
        XCTAssertEqual(cpu.pc, 6)
        XCTAssertEqual(cpu.outputIF.ins, 0b10101000_11111111)
        XCTAssertEqual(cpu.outputID.ins, 0b00000110_00001101)

        // PC    IF    ID     EX     MEM    WB
        // -     HLT   JR     LI     NOP    NOP
        cpu.step()
        XCTAssertEqual(cpu.pc, 7)
        XCTAssertEqual(cpu.outputIF.ins, 0b00001000_00000000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_11111111)

        // PC    IF    ID     EX     MEM    WB
        // HLT   NOP   NOP    JR     LI     NOP
        cpu.step()
        XCTAssertEqual(cpu.pc, 2)
        XCTAssertEqual(cpu.outputIF.ins, 0b00000000_00000000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00000000)

        // PC    IF    ID     EX     MEM    WB
        // NOP   HLT   NOP    NOP    JR     LI
        XCTAssertNotEqual(cpu.getRegister(6), 13)
        cpu.step()
        XCTAssertEqual(cpu.getRegister(6), 13)
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputIF.ins, 0b00001000_00000000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00000000)

        // PC    IF    ID     EX     MEM    WB
        // LI    NOP   HLT    NOP    NOP    JR
        cpu.step()
        XCTAssertEqual(cpu.pc, 4)
        XCTAssertEqual(cpu.outputIF.ins, 0b00000000_00000010)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00000000)
        XCTAssertEqual(cpu.getRegister(6), 13)

        // PC    IF    ID     EX     MEM    WB
        // JR    LI    NOP    HLT    NOP    NOP
        cpu.step()
        XCTAssertEqual(cpu.pc, 5)
        XCTAssertEqual(cpu.outputIF.ins, 0b00100110_00001101)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00000010)
        XCTAssertTrue(cpu.isHalted)
    }

    func testBeq() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11000011_11111111,  // BEQ 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.z = z
                        cpu.v = v

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        if z == 1 {
                            XCTAssertEqual(1026, cpu.pc)
                        } else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    }  // v
                }  // z
            }  // c
        }  // n
    }

    func testBne_takeTheJump() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11001011_11111111,  // BNE 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        if z == 0 {
                            XCTAssertEqual(1026, cpu.pc)
                        } else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    }  // v
                }  // z
            }  // c
        }  // n
    }

    func testBlt() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11010011_11111111,  // BLT 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BLT should jump on N!=V
                        if (n == 0 && v == 1) || (n == 1 && v == 0) {
                            XCTAssertEqual(1026, cpu.pc)
                        } else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    }  // v
                }  // z
            }  // c
        }  // n
    }

    func testBgt() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11011011_11111111,  // BGT 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BGT jumps on (Z==0) && (N==V)
                        if z == 0 && ((n == 0 && v == 0) || (n == 1 && v == 1)) {
                            XCTAssertEqual(1026, cpu.pc)
                        } else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    }  // v
                }  // z
            }  // c
        }  // n
    }

    func testBltu() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11100011_11111111,  // BLTU 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BLTU jumps on C==0
                        if c == 0 {
                            XCTAssertEqual(1026, cpu.pc)
                        } else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    }  // v
                }  // z
            }  // c
        }  // n
    }

    func testBgtu() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b11101011_11111111,  // BGTU 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BGTU jumps on C==1 && Z==0
                        if c == 1 && z == 0 {
                            XCTAssertEqual(1026, cpu.pc)
                        } else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    }  // v
                }  // z
            }  // c
        }  // n
    }

    func testDemonstrateHazard_RAW() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00100001_00000000,  // LI r1, 0
            0b00111000_00101000,  // ADD r0, r1, r2
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
        XCTAssertEqual(cpu.outputIF.ins, 0b00100001_00000000)
        XCTAssertEqual(cpu.outputID.ins, 0)

        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     ADD   LI    -     -      -
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0b00111000_00101000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000001_00000000)

        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     ADD   ADD   LI    -      -  (parameters of ADD are resolved here)
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0b00111000_00101000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00101000)

        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     ADD   ADD   -     LI     -  (stalling)
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0b00111000_00101000)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00101000)

        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     ADD   -     -      LI (result of LI is stored here)
        cpu.step()
        XCTAssertEqual(cpu.outputIF.ins, 0)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_00101000)

        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     -     ADD   -      -
        cpu.step()

        // Pre:
        // PC    IF    ID    EX    MEM    WB
        // -     -     -     -     ADD    -
        cpu.step()
        XCTAssertEqual(cpu.outputMEM.selC, 0)
        XCTAssertTrue(cpu.outputMEM.ctl & ~UInt(1 << DecoderGenerator.WBEN) != 0)
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
            0b00000000_00000000,  // NOP
            0b00110000_00101000,  // CMP r1, r2
            0b11000011_11111111,  // BEQ 1023
        ]
        cpu.reset()
        cpu.setRegister(1, 1)
        cpu.setRegister(2, 1)
        cpu.n = 0
        cpu.c = 0
        cpu.v = 0
        cpu.z = 0
        //            PC    IF    ID    EX    MEM    WB
        cpu.step()  // BEQ   CMP   -     -     -      -
        cpu.step()  // -     BEQ   CMP   -     -      -
        cpu.step()  // -     -     BEQ   CMP   -      - (stalling, flags are updated at the end of the cycle)
        cpu.step()  // -     -     BEQ   -     CMP    -
        XCTAssertEqual(cpu.outputID.ctl_EX, ID.nopControlWord)
    }

    func testDemonstrateHazard_MemoryLoad() {
        let cpu = SchematicLevelCPUModel()
        cpu.load = { (addr: MemoryAddress) in
            1
        }
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00010000_11100000,  // LOAD r0, r7
            0b00111010_00000100,  // ADD r2, r0, r1
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
        XCTAssertEqual(cpu.outputIF.ins, 0b00010000_11100000)
        XCTAssertEqual(cpu.outputID.ins, 0)

        // PC    IF    ID      EX      MEM     WB
        // -     ADD   LOAD    -       -       -
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputIF.ins, 0b00111010_00000100)
        XCTAssertEqual(cpu.outputID.ins, 0b00000000_11100000)

        // PC    IF    ID      EX      MEM     WB
        // -     ADD   ADD     LOAD    -       - (stall)
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputID.stall, 1)
        XCTAssertEqual(cpu.outputIF.ins, 0b00111010_00000100)
        XCTAssertEqual(cpu.outputID.ins, 0b00000010_00000100)

        // PC    IF    ID      EX      MEM     WB
        // -     ADD     ADD     NOP     LOAD    - (stall)
        cpu.step()
        XCTAssertEqual(cpu.pc, 3)
        XCTAssertEqual(cpu.outputID.stall, 1)
        XCTAssertEqual(cpu.outputIF.ins, 0b00111010_00000100)
        XCTAssertEqual(cpu.outputID.ins, 0b00000010_00000100)
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
            0b00000000_00000000,  // NOP
            0b00100111_00000101,  // LI r7, 5
            0b01111111_11100001,  // SUBI r7, r7, 1
            0b11001111_11111101,  // BNZ -3
            0b00001000_00000000,  // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 30)
        XCTAssertEqual(cpu.getRegister(7), 0)
    }

    func testLoop() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00100111_00000000,  // LI r7, 0
            0b01110111_11100001,  // ADDI r7, r7, 1
            0b01101000_11101001,  // CMPI r7, 1
            0b11010111_11111100,  // BLT -4
            0b00001000_00000000,  // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 59)
        XCTAssertEqual(cpu.getRegister(7), 9)
    }

    func testFibonacci() {
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00100000_00000000,  // LI r0, 0
            0b00100001_00000001,  // LI r1, 1
            0b00100111_00000000,  // LI r7, 0
            0b00111010_00000100,  // ADD r2, r0, r1
            0b01110000_00100000,  // ADDI r0, r1, 0
            0b01110111_11100001,  // ADDI r7, r7, 1
            0b01110001_01000000,  // ADDI r1, r2, 0
            0b01101000_11101001,  // CMPI r7, 9
            0b11010111_11111001,  // BLT -7
            0b00001000_00000000,  // HLT
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
            0b00000000_00000000,  // NOP
            0b01011000_00000000,  // XOR r0, r0, r0
            0b01011001_00100100,  // XOR r1, r1, r1
            0b01110001_00100001,  // ADDI r1, r1, 1
            0b01011111_11111100,  // XOR r7, r7, r7
            0b00111010_00000100,  // ADD r2, r0, r1
            0b01110000_00100000,  // ADDI r0, r1, 0
            0b01110111_11100001,  // ADDI r7, r7, 1
            0b01110001_01000000,  // ADDI r1, r2, 0
            0b01101000_11101001,  // CMPI r7, 9
            0b11010111_11111001,  // BLT -7
            0b00001000_00000000,  // HLT
        ]
        cpu.reset()
        cpu.run(stepLimit: 87)
        XCTAssertEqual(cpu.getRegister(2), 55)
    }

    func testFixedBugInHazardControlStallingOnStoreOp_LI() {
        // There is a bug in the hazard control unit in Rev A where an
        // instruction will be incorrectly determined to introduce a RAW hazard
        // in the StoreOp case. The issue is that the hazard control unit would
        // always assume the instruction's A and B bit fields are used to
        // indicate register indices, but this is only sometimes true
        // For example, ALU instructions which use an immediate operand, such as
        // ADDI will reuse the bits of the B field to specify an immediate
        // value. Likewise, the LI instruction will reuse the bits of the A and
        // B fields to specify an immediate value.
        //
        // This test ensures that the issue has been fixed in Rev B and later.
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00100000_00000000,  // LI r0, 0
            0b00000000_00000000,  // NOP
            0b00100111_00000000,  // LI r7, 0
        ]
        cpu.reset()
        cpu.step()
        cpu.step()
        cpu.step()
        cpu.step()
        XCTAssertFalse(cpu.isStalling)
    }

    func testFixedBugInHazardControlStallingOnStoreOp_ADDI() {
        // See comment in testDemonstrateBugInHazardControlStallingOnStoreOp_LI
        // for detailed description of this hardware bug.
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00100000_00000000,  // LI r0, 0
            0b00000000_00000000,  // NOP
            0b01110000_00100000,  // ADDI r0, r1, 0
        ]
        cpu.reset()
        cpu.step()
        cpu.step()
        cpu.step()
        cpu.step()
        XCTAssertFalse(cpu.isStalling)
    }

    func testEquality_Equal() throws {
        let cpu1 = SchematicLevelCPUModel()
        cpu1.instructions = [0x000, 0x0800]
        cpu1.reset()
        cpu1.run()

        let cpu2 = SchematicLevelCPUModel()
        cpu2.instructions = [0x000, 0x0800]
        cpu2.reset()
        cpu2.run()

        XCTAssertEqual(cpu1, cpu2)
        XCTAssertEqual(cpu1.hash, cpu2.hash)
    }

    func testEquality_NotEqual() throws {
        let cpu1 = SchematicLevelCPUModel()
        cpu1.instructions = [0x000, 0x0800]
        cpu1.reset()
        cpu1.run()

        let cpu2 = SchematicLevelCPUModel()
        cpu2.instructions = [0x000, 0x000, 0x0800]
        cpu2.reset()
        cpu2.run()

        XCTAssertNotEqual(cpu1, cpu2)
        XCTAssertNotEqual(cpu1.hash, cpu2.hash)
    }

    func testEncodeDecodeRoundTrip() throws {
        let cpu1 = SchematicLevelCPUModel()
        cpu1.instructions = [0x000, 0x0800]
        cpu1.reset()
        cpu1.run()
        var data: Data! = nil
        XCTAssertNoThrow(
            data = try NSKeyedArchiver.archivedData(
                withRootObject: cpu1,
                requiringSecureCoding: true
            )
        )
        if data == nil {
            XCTFail()
            return
        }
        var cpu2: SchematicLevelCPUModel! = nil
        XCTAssertNoThrow(cpu2 = try SchematicLevelCPUModel.decode(from: data))
        XCTAssertEqual(cpu1, cpu2)
    }

    func testCmp_SpotChecksForSignedLessThanComparison() {
        // BLT jumps on N!=V
        assertComparisonWorksAsExpectedForSpotChecks({ $0 < $1 }) {
            (n: UInt, c: UInt, z: UInt, v: UInt) in
            (n == 0 && v == 1) || (n == 1 && v == 0)
        }
    }

    func testCmp_SpotChecksForSignedGreaterThanComparison() {
        // BGT jumps on (Z==0) && (N==V)
        assertComparisonWorksAsExpectedForSpotChecks({ $0 > $1 }) {
            (n: UInt, c: UInt, z: UInt, v: UInt) in
            z == 0 && ((n == 0 && v == 0) || (n == 1 && v == 1))
        }
    }

    fileprivate func assertComparisonWorksAsExpectedForSpotChecks(
        _ cond: (_ r1: Int16, _ r2: Int16) -> Bool,
        _ impl: (_ n: UInt, _ c: UInt, _ z: UInt, _ v: UInt) -> Bool
    ) {
        // This test is non-deterministic by design. It spot checks a small,
        // randomly chosen subset of the configuration space. The hope is that
        // this will always complete quickly and will evnetually trigger a
        // failure if there is an issue with some permutation of the parameters.
        let cpu = SchematicLevelCPUModel()
        cpu.instructions = [
            0b00000000_00000000,  // NOP
            0b00110000_00101000,  // CMP r1, r2
        ]

        let N = 100
        let parameterSpace = [Int16](Int16.min...Int16.max)
        let r1s = parameterSpace.shuffled()[0..<N]
        let r2s = parameterSpace.shuffled()[0..<N]

        for r1 in r1s {
            for r2 in r2s {
                guard doesCompareAsExpected(cpu, r1, r2, cond, impl) else {
                    print(
                        "r1=\(r1) ; r2=\(r2)  ==>  n=\(cpu.n) ; c=\(cpu.c) ; z=\(cpu.z) ; v=\(cpu.v)"
                    )
                    XCTFail()
                    return
                }
            }
        }
    }

    fileprivate func doesCompareAsExpected(
        _ cpu: SchematicLevelCPUModel,
        _ r1: Int16,
        _ r2: Int16,
        _ cond: (_ r1: Int16, _ r2: Int16) -> Bool,
        _ impl: (_ n: UInt, _ c: UInt, _ z: UInt, _ v: UInt) -> Bool
    ) -> Bool {
        cpu.setRegister(0, 0xabcd)
        cpu.setRegister(1, UInt16(bitPattern: r1))
        cpu.setRegister(2, UInt16(bitPattern: r2))
        cpu.reset()
        cpu.step()  // -
        cpu.step()  // IF
        cpu.step()  // ID
        cpu.step()  // EX
        cpu.step()  // MEM
        cpu.step()  // WB

        let evaluatedCondition: Bool = impl(cpu.n, cpu.c, cpu.z, cpu.v)
        if cond(r1, r2) {
            guard evaluatedCondition else {
                return false
            }
        } else {
            guard !evaluatedCondition else {
                return false
            }
        }

        return true
    }
}
