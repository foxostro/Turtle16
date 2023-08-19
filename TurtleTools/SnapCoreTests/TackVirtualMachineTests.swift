//
//  TackVirtualMachineTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/6/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

final class TackVirtualMachineTests: XCTestCase {
    public typealias Word = TackVirtualMachine.Word
    fileprivate let kSizeOfSavedRegisters: Word = 7
    
    func testGetRegister_InvalidRegister_LocalRegister() throws {
        let program = TackProgram(instructions: [])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.getRegister(.vr(0))) { error in
            XCTAssertEqual(error as? TackVirtualMachineError,
                           TackVirtualMachineError.undefinedRegister(.vr(0)))
        }
    }
    
    func testRunEmptyProgram() throws {
        let program = TackProgram(instructions: [], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.run()
        XCTAssertEqual(vm.pc, 0)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testRunNOP() throws {
        let program = TackProgram(instructions: [.nop, .nop], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.run()
        XCTAssertEqual(vm.pc, 2)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testRunHLT() throws {
        let program = TackProgram(instructions: [.hlt, .nop], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.run()
        XCTAssertEqual(vm.pc, 0)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testRunJMP() throws {
        let program = TackProgram(instructions: [
            .nop,
            .jmp("foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 0)
        XCTAssertFalse(vm.isHalted)
    }
    
    func testJumpToUndefinedLabel() throws {
        let program = TackProgram(instructions: [
            .jmp("foo")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedLabel(let target) = error {
                XCTAssertEqual(target, "foo")
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLA_WithUndefinedLabel() throws {
        let program = TackProgram(instructions: [
            .la(.vr(0), "foo")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedLabel(let target) = error {
                XCTAssertEqual(target, "foo")
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLA() throws {
        let program = TackProgram(instructions: [
            .la(.vr(0), "foo")
        ], labels: ["foo" : 0xabcd])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(try vm.getRegister(.vr(0)), 0xabcd)
    }
    
    func testBZ_WithUndefinedLabel() throws {
        let program = TackProgram(instructions: [
            .bz(.vr(0), "foo")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedLabel(let target) = error {
                XCTAssertEqual(target, "foo")
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testBZ_DoNotTakeTheBranch() throws {
        let program = TackProgram(instructions: [
            .nop,
            .bz(.vr(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 2)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testBZ_TakeTheBranch() throws {
        let program = TackProgram(instructions: [
            .nop,
            .bz(.vr(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 0)
        XCTAssertFalse(vm.isHalted)
    }
    
    func testBNZ_WithUndefinedLabel() throws {
        let program = TackProgram(instructions: [
            .bnz(.vr(0), "foo")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedLabel(let target) = error {
                XCTAssertEqual(target, "foo")
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testBNZ_DoNotTakeTheBranch() throws {
        let program = TackProgram(instructions: [
            .nop,
            .bnz(.vr(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 2)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testBNZ_TakeTheBranch() throws {
        let program = TackProgram(instructions: [
            .nop,
            .bnz(.vr(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 0)
        XCTAssertFalse(vm.isHalted)
    }
    
    func testCALL_WithUndefinedLabel() throws {
        let program = TackProgram(instructions: [
            .call("foo")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedLabel(let target) = error {
                XCTAssertEqual(target, "foo")
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testCALL() throws {
        let program = TackProgram(instructions: [
            .call("foo"),
            .nop,
            .ret
        ], labels: ["foo":2])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(vm.pc, 2)
        XCTAssertEqual(try vm.getRegister(.ra), 1)
    }
    
    func testRET_WithUndefinedReturnAddress() throws {
        let program = TackProgram(instructions: [
            .ret
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedRegister(let reg) = error {
                XCTAssertEqual(reg, .ra)
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testRET() throws {
        let program = TackProgram(instructions: [
            .call("foo"),
            .nop,
            .ret
        ], labels: ["foo":2])
        let vm = TackVirtualMachine(program)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 1)
    }
    
    func testCALLPTR_OutOfBounds() throws {
        let program = TackProgram(instructions: [
            .callptr(.vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1000)
        try vm.step()
        XCTAssertEqual(vm.pc, 1000)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testCALLPTR() throws {
        let program = TackProgram(instructions: [
            .callptr(.vr(0)),
            .nop,
            .ret
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        try vm.step()
        XCTAssertEqual(vm.pc, 2)
        XCTAssertEqual(try vm.getRegister(.ra), 1)
    }
    
    func testENTER_InvalidArgument() throws {
        let program = TackProgram(instructions: [
            .enter(-1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // good
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testENTER_PushesNewRegisterSet() throws {
        let program = TackProgram(instructions: [
            .enter(0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        try vm.step()
        XCTAssertThrowsError(try vm.getRegister(.vr(0))) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedRegister(let reg) = error {
                XCTAssertEqual(reg, .vr(0))
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testENTER_PushesNewRegisterSet_PushesReturnAddressToo() throws {
        let program = TackProgram(instructions: [
            .enter(0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.ra, 1)
        try vm.step()
        XCTAssertThrowsError(try vm.getRegister(.ra)) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedRegister(let reg) = error {
                XCTAssertEqual(reg, .ra)
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testENTER_SetupNewStackFrame() throws {
        let program = TackProgram(instructions: [
            .enter(0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        let a = vm.load(address: Word(0) &- kSizeOfSavedRegisters)
        XCTAssertEqual(a, 0)
        let expectedSp = Word(0) &- kSizeOfSavedRegisters
        XCTAssertEqual(expectedSp, try vm.getRegister(.sp))
    }
    
    func testENTER_AllocateStorageWithinStackFrame() throws {
        let size = 10
        let program = TackProgram(instructions: [
            .enter(size)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        let a = vm.load(address: Word(0) &- kSizeOfSavedRegisters)
        XCTAssertEqual(a, 0)
        let expectedSp = Word(0) &- kSizeOfSavedRegisters &- Word(size)
        XCTAssertEqual(expectedSp, try vm.getRegister(.sp))
    }
    
    func testLEAVE_UnderflowRegisterStack() throws {
        let program = TackProgram(instructions: [
            .leave,
            .leave
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .underflowRegisterStack = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLEAVE() throws {
        let program = TackProgram(instructions: [
            .enter(0),
            .leave
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.fp))
        XCTAssertEqual(0, try vm.getRegister(.sp))
    }
    
    func testLOAD_ZeroOffset() throws {
        let program = TackProgram(instructions: [
            .load(.vr(1), .vr(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.vr(1)))
    }
    
    func testLOAD_NegativeOffset() throws {
        let program = TackProgram(instructions: [
            .load(.vr(1), .vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbeee)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.vr(1)))
    }
    
    func testLOAD_PositiveOffset() throws {
        let program = TackProgram(instructions: [
            .load(.vr(1), .vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbef0)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.vr(1)))
    }
    
    func testSTORE_ZeroOffset() throws {
        let program = TackProgram(instructions: [
            .store(.vr(1), .vr(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xcafe)
        vm.setRegister(.vr(0), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbeef))
    }
    
    func testSTORE_NegativeOffset() throws {
        let program = TackProgram(instructions: [
            .store(.vr(1), .vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xcafe)
        vm.setRegister(.vr(0), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbeee))
    }
    
    func testSTORE_PositiveOffset() throws {
        let program = TackProgram(instructions: [
            .store(.vr(1), .vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xcafe)
        vm.setRegister(.vr(0), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbef0))
    }
    
    func testSTSTR() throws {
        let program = TackProgram(instructions: [
            .ststr(.vr(0), "abc")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xbeef)
        try vm.step()
        XCTAssertEqual(Int("a".utf8.first!), Int(vm.load(address: 0xbeef+0)))
        XCTAssertEqual(Int("b".utf8.first!), Int(vm.load(address: 0xbeef+1)))
        XCTAssertEqual(Int("c".utf8.first!), Int(vm.load(address: 0xbeef+2)))
    }
    
    func testMEMCPY_BadCount() throws {
        let program = TackProgram(instructions: [
            .memcpy(.vr(1), .vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testMEMCPY() throws {
        let program = TackProgram(instructions: [
            .memcpy(.vr(1), .vr(0), 2)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0x1000)
        vm.setRegister(.vr(0), 0x2000)
        vm.store(value: 0xaabb, address: 0x2000)
        vm.store(value: 0xccdd, address: 0x2001)
        try vm.step()
        XCTAssertEqual(0xaabb, vm.load(address: 0x1000))
        XCTAssertEqual(0xccdd, vm.load(address: 0x1001))
    }
    
    func testALLOCA_BadCount() throws {
        let program = TackProgram(instructions: [
            .alloca(.vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testALLOCA_Zero() throws {
        let program = TackProgram(instructions: [
            .alloca(.vr(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        let sp = try vm.getRegister(.sp)
        XCTAssertEqual(sp, try vm.getRegister(.vr(0)))
    }
    
    func testALLOCA_NonZero() throws {
        let program = TackProgram(instructions: [
            .alloca(.vr(0), 10)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        let sp = try vm.getRegister(.sp)
        let expectedSp = Word(0) &- 10
        XCTAssertEqual(sp, expectedSp)
        XCTAssertEqual(sp, try vm.getRegister(.vr(0)))
    }
    
    func testFREE_BadCount() throws {
        let program = TackProgram(instructions: [
            .free(-1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testFREE() throws {
        let count: Int = 10
        let program = TackProgram(instructions: [
            .free(count)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        
        var sp = try vm.getRegister(.sp)
        sp = sp &- Word(count)
        vm.setRegister(.sp, sp)
        
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.sp))
    }
    
    func testNOT_0() throws {
        let program = TackProgram(instructions: [
            .not(.vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(1)))
    }
    
    func testNOT_ffff() throws {
        let program = TackProgram(instructions: [
            .not(.vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(1)))
    }
    
    func testANDI16_bad_imm() throws {
        let program = TackProgram(instructions: [
            .andi16(.vr(1), .vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testANDI16() throws {
        let program = TackProgram(instructions: [
            .andi16(.vr(1), .vr(0), 0b1010101010101010)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(0b1010101010101010, try vm.getRegister(.vr(1)))
    }
    
    func testADDI16_pos() throws {
        let program = TackProgram(instructions: [
            .addi16(.vr(1), .vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(1)))
    }
    
    func testADDI16_neg() throws {
        let program = TackProgram(instructions: [
            .addi16(.vr(1), .vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.vr(1)))
    }
    
    func testSUBI16_pos() throws {
        let program = TackProgram(instructions: [
            .subi16(.vr(1), .vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.vr(1)))
    }
    
    func testSUBI16_neg() throws {
        let program = TackProgram(instructions: [
            .subi16(.vr(1), .vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(1)))
    }
    
    func testMULI16_pos() throws {
        let program = TackProgram(instructions: [
            .muli16(.vr(1), .vr(0), 2)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        try vm.step()
        XCTAssertEqual(4, try vm.getRegister(.vr(1)))
    }
    
    func testMULI16_neg() throws {
        let program = TackProgram(instructions: [
            .muli16(.vr(1), .vr(0), -2)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        try vm.step()
        XCTAssertEqual(Word(0) &- 4, try vm.getRegister(.vr(1)))
    }
    
    func testLI16_pos() throws {
        let program = TackProgram(instructions: [
            .li16(.vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(0)))
    }
    
    func testLI16_neg() throws {
        let program = TackProgram(instructions: [
            .li16(.vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.vr(0)))
    }
    
    func testLI16_TooBigPos() throws {
        let program = TackProgram(instructions: [
            .li16(.vr(0), 32768)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLI16_TooBigNeg() throws {
        let program = TackProgram(instructions: [
            .li16(.vr(0), -32769)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLIU16_CannotAcceptNegativeValues() throws {
        let program = TackProgram(instructions: [
            .liu16(.vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLIU16_TooBigPos() throws {
        let program = TackProgram(instructions: [
            .liu16(.vr(0), 65536)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLIU16() throws {
        let program = TackProgram(instructions: [
            .liu16(.vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(0)))
    }
    
    func testAND16() throws {
        let program = TackProgram(instructions: [
            .and16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0f0)
        vm.setRegister(.vr(1), 0xffff)
        try vm.step()
        XCTAssertEqual(0xf0f0, try vm.getRegister(.vr(2)))
    }
    
    func testOR16() throws {
        let program = TackProgram(instructions: [
            .or16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0f0)
        vm.setRegister(.vr(1), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0xffff, try vm.getRegister(.vr(2)))
    }
    
    func testXOR16() throws {
        let program = TackProgram(instructions: [
            .xor16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0ff)
        vm.setRegister(.vr(1), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0xfff0, try vm.getRegister(.vr(2)))
    }
    
    func testNEG16() throws {
        let program = TackProgram(instructions: [
            .neg16(.vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0f0)
        try vm.step()
        XCTAssertEqual(0x0f0f, try vm.getRegister(.vr(1)))
    }
    
    func testADD16() throws {
        let program = TackProgram(instructions: [
            .add16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        vm.setRegister(.vr(1), 1)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testSUB16() throws {
        let program = TackProgram(instructions: [
            .sub16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        vm.setRegister(.vr(1), 1)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.vr(2)))
    }
    
    func testMUL16() throws {
        let program = TackProgram(instructions: [
            .mul16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        vm.setRegister(.vr(1), 2)
        try vm.step()
        XCTAssertEqual(4, try vm.getRegister(.vr(2)))
    }
    
    func testDIV16() throws {
        let program = TackProgram(instructions: [
            .div16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        vm.setRegister(.vr(1), 4)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testDIV16_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .div16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        vm.setRegister(.vr(1), 1)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .divideByZero = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testMOD16() throws {
        let program = TackProgram(instructions: [
            .mod16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        vm.setRegister(.vr(1), 3)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testMOD16_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .mod16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        vm.setRegister(.vr(1), 1)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .divideByZero = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLSL16() throws {
        let program = TackProgram(instructions: [
            .lsl16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        vm.setRegister(.vr(1), 1)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testLSL16_overflow() throws {
        let program = TackProgram(instructions: [
            .lsl16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        vm.setRegister(.vr(1), 0x8000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLSR16() throws {
        let program = TackProgram(instructions: [
            .lsr16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        vm.setRegister(.vr(1), 4)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testLSR16_underflow() throws {
        let program = TackProgram(instructions: [
            .lsr16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        vm.setRegister(.vr(1), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testEQ16_Equal() throws {
        let program = TackProgram(instructions: [
            .eq16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1000)
        vm.setRegister(.vr(1), 1000)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testEQ16_NotEqual() throws {
        let program = TackProgram(instructions: [
            .eq16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1000)
        vm.setRegister(.vr(1), 1001)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testNE16_Equal() throws {
        let program = TackProgram(instructions: [
            .ne16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1000)
        vm.setRegister(.vr(1), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testNE16_NotEqual() throws {
        let program = TackProgram(instructions: [
            .ne16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1000)
        vm.setRegister(.vr(1), 1001)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLT16_True() throws {
        let program = TackProgram(instructions: [
            .lt16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1000)
        vm.setRegister(.vr(1), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLT16_False() throws {
        let program = TackProgram(instructions: [
            .lt16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), Word(0) &- Word(1000))
        vm.setRegister(.vr(1), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGE16_True() throws {
        let program = TackProgram(instructions: [
            .ge16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 1000)
        vm.setRegister(.vr(0), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGE16_False() throws {
        let program = TackProgram(instructions: [
            .ge16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), Word(0) &- Word(1000))
        vm.setRegister(.vr(0), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLE16_True() throws {
        let program = TackProgram(instructions: [
            .le16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), Word(0) &- Word(1000))
        vm.setRegister(.vr(0), 1000)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLE16_False() throws {
        let program = TackProgram(instructions: [
            .le16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 1000)
        vm.setRegister(.vr(0), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGT16_True() throws {
        let program = TackProgram(instructions: [
            .gt16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 1000)
        vm.setRegister(.vr(0), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGT16_False() throws {
        let program = TackProgram(instructions: [
            .gt16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), Word(0) &- Word(1000))
        vm.setRegister(.vr(0), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLTU16_True() throws {
        let program = TackProgram(instructions: [
            .ltu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLTU16_False() throws {
        let program = TackProgram(instructions: [
            .ltu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xffff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGEU16_True() throws {
        let program = TackProgram(instructions: [
            .geu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xffff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGEU16_False() throws {
        let program = TackProgram(instructions: [
            .geu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLEU16_True() throws {
        let program = TackProgram(instructions: [
            .leu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLEU16_False() throws {
        let program = TackProgram(instructions: [
            .leu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xffff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGTU16_True() throws {
        let program = TackProgram(instructions: [
            .gtu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xffff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGTU16_False() throws {
        let program = TackProgram(instructions: [
            .gtu16(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLI8_pos() throws {
        let program = TackProgram(instructions: [
            .li8(.vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(0)))
    }
    
    func testLI8_neg() throws {
        let program = TackProgram(instructions: [
            .li8(.vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.vr(0)))
    }
    
    func testLI8_TooBigPos() throws {
        let program = TackProgram(instructions: [
            .li8(.vr(0), 128)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLI8_TooBigNeg() throws {
        let program = TackProgram(instructions: [
            .li8(.vr(0), -129)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLIU8_CannotAcceptNegativeValues() throws {
        let program = TackProgram(instructions: [
            .liu8(.vr(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLIU8_TooBigPos() throws {
        let program = TackProgram(instructions: [
            .liu8(.vr(0), 256)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .invalidArgument = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLIU8() throws {
        let program = TackProgram(instructions: [
            .liu8(.vr(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(0)))
    }
    
    func testAND8() throws {
        let program = TackProgram(instructions: [
            .and8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0f0)
        vm.setRegister(.vr(1), 0xffff)
        try vm.step()
        XCTAssertEqual(0x00f0, try vm.getRegister(.vr(2)))
    }
    
    func testOR8() throws {
        let program = TackProgram(instructions: [
            .or8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0f0)
        vm.setRegister(.vr(1), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0x00ff, try vm.getRegister(.vr(2)))
    }
    
    func testXOR8() throws {
        let program = TackProgram(instructions: [
            .xor8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0ff)
        vm.setRegister(.vr(1), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0x00f0, try vm.getRegister(.vr(2)))
    }
    
    func testNEG8() throws {
        let program = TackProgram(instructions: [
            .neg8(.vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xf0f0)
        try vm.step()
        XCTAssertEqual(0x000f, try vm.getRegister(.vr(1)))
    }
    
    func testADD8() throws {
        let program = TackProgram(instructions: [
            .add8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff01)
        vm.setRegister(.vr(1), 0xff01)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testSUB8() throws {
        let program = TackProgram(instructions: [
            .sub8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff02)
        vm.setRegister(.vr(1), 0xff01)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.vr(2)))
    }
    
    func testMUL8() throws {
        let program = TackProgram(instructions: [
            .mul8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff02)
        vm.setRegister(.vr(1), 2)
        try vm.step()
        XCTAssertEqual(4, try vm.getRegister(.vr(2)))
    }
    
    func testDIV8() throws {
        let program = TackProgram(instructions: [
            .div8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 2)
        vm.setRegister(.vr(1), 4)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testDIV8_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .div8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        vm.setRegister(.vr(1), 1)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .divideByZero = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testMOD8() throws {
        let program = TackProgram(instructions: [
            .mod8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff02)
        vm.setRegister(.vr(1), 0xff03)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testMOD8_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .mod8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        vm.setRegister(.vr(1), 1)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .divideByZero = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testLSL8() throws {
        let program = TackProgram(instructions: [
            .lsl8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff01)
        vm.setRegister(.vr(1), 0xff01)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testLSL8_overflow() throws {
        let program = TackProgram(instructions: [
            .lsl8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff01)
        vm.setRegister(.vr(1), 0xff80)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLSR8() throws {
        let program = TackProgram(instructions: [
            .lsr8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff01)
        vm.setRegister(.vr(1), 0xff04)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.vr(2)))
    }
    
    func testLSR8_underflow() throws {
        let program = TackProgram(instructions: [
            .lsr8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff01)
        vm.setRegister(.vr(1), 0xff00)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testEQ8_Equal() throws {
        let program = TackProgram(instructions: [
            .eq8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xffff)
        vm.setRegister(.vr(1), 0xf0ff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testEQ8_NotEqual() throws {
        let program = TackProgram(instructions: [
            .eq8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xffff)
        vm.setRegister(.vr(1), 0xf0f0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testNE8_Equal() throws {
        let program = TackProgram(instructions: [
            .ne8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff01)
        vm.setRegister(.vr(1), 0xf001)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testNE8_NotEqual() throws {
        let program = TackProgram(instructions: [
            .ne8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0xff01)
        vm.setRegister(.vr(1), 0xff00)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLT8_True() throws {
        let program = TackProgram(instructions: [
            .lt8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 127)
        vm.setRegister(.vr(1), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLT8_False() throws {
        let program = TackProgram(instructions: [
            .lt8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), Word(0) &- Word(127))
        vm.setRegister(.vr(1), 127)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGE8_True() throws {
        let program = TackProgram(instructions: [
            .ge8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 127)
        vm.setRegister(.vr(0), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGE8_False() throws {
        let program = TackProgram(instructions: [
            .ge8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), Word(0) &- Word(127))
        vm.setRegister(.vr(0), 127)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLE8_True() throws {
        let program = TackProgram(instructions: [
            .le8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), Word(0) &- Word(127))
        vm.setRegister(.vr(0), 127)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLE8_False() throws {
        let program = TackProgram(instructions: [
            .le8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 127)
        vm.setRegister(.vr(0), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGT8_True() throws {
        let program = TackProgram(instructions: [
            .gt8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 127)
        vm.setRegister(.vr(0), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGT8_False() throws {
        let program = TackProgram(instructions: [
            .gt8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), Word(0) &- Word(127))
        vm.setRegister(.vr(0), 127)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLTU8_True() throws {
        let program = TackProgram(instructions: [
            .ltu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLTU8_False() throws {
        let program = TackProgram(instructions: [
            .ltu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGEU8_True() throws {
        let program = TackProgram(instructions: [
            .geu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGEU8_False() throws {
        let program = TackProgram(instructions: [
            .geu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testLEU8_True() throws {
        let program = TackProgram(instructions: [
            .leu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testLEU8_False() throws {
        let program = TackProgram(instructions: [
            .leu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testGTU8_True() throws {
        let program = TackProgram(instructions: [
            .gtu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0xff)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(2)))
    }
    
    func testGTU8_False() throws {
        let program = TackProgram(instructions: [
            .gtu8(.vr(2), .vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(1), 0)
        vm.setRegister(.vr(0), 0xff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(2)))
    }
    
    func testSXT8_Zero() throws {
        let program = TackProgram(instructions: [
            .sxt8(.vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.vr(1)))
    }
    
    func testSXT8_One() throws {
        let program = TackProgram(instructions: [
            .sxt8(.vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 1)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.vr(1)))
    }
    
    func testSXT8_NegOne() throws {
        let program = TackProgram(instructions: [
            .sxt8(.vr(1), .vr(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), 0x80)
        try vm.step()
        XCTAssertEqual(Word(0) &- 0x80, try vm.getRegister(.vr(1)))
    }
    
    func testSerialOutput() throws {
        let program = TackProgram(instructions: [
            .store(.vr(1), .vr(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.vr(0), vm.kMemoryMappedSerialOutputPort)
        vm.setRegister(.vr(1), 65)
        var output: Word? = nil
        vm.onSerialOutput = { output = $0 }
        try vm.step()
        XCTAssertEqual(output, 65)
    }
    
    func testInlineAssemblyIsNotSupported() throws {
        let program = TackProgram(instructions: [
            .inlineAssembly("")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        XCTAssertThrowsError(try vm.step()) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .inlineAssemblyNotSupported = error {
                // nothing to do
            }
            else {
                XCTFail("unexpected error: \($0)")
            }
        }
    }
    
    func testInlineAssembly_HLTisSpecial() throws {
        let program = TackProgram(instructions: [
            .inlineAssembly("HLT"),
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertTrue(vm.isHalted)
    }
    
    func testInlineAssembly_BREAKisSpecial() throws {
        let program = TackProgram(instructions: [
            .inlineAssembly("BREAK"),
            .nop
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.run()
        XCTAssertTrue(vm.pc == 1)
        XCTAssertFalse(vm.isHalted)
    }
    
    func testBreakPoint() throws {
        let program = TackProgram(instructions: [
            .nop,
            .nop
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setBreakPoint(pc: 1, value: true)
        try vm.run()
        XCTAssertTrue(vm.pc == 1)
        XCTAssertFalse(vm.isHalted)
        try vm.run()
        XCTAssertTrue(vm.pc == 2)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testSyscall_Invalid() throws {
        let syscallNumber = TackVirtualMachine.Syscall.invalid.rawValue
        let addressOfArgumentStructure = 0
        let program = TackProgram(instructions: [
            // Write the syscall number to memory at 272, keep address in vr0.
            .liu16(.vr(0), 272),
            .liu16(.vr(2), syscallNumber),
            .store(.vr(2), .vr(0), 0),
            
            // Write the argument pointer to memory at 273, keep address in vr1.
            .liu16(.vr(1), 273),
            .liu16(.vr(2), addressOfArgumentStructure),
            .store(.vr(2), .vr(1), 0),
            
            // Call the virtual machine
            .syscall(.vr(0), // syscall number
                     .vr(1)),// pointer to argument structure
            
            .hlt
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.run()
        
        // The program will run until it hits the breakpoint, at which point
        // the virtual machine will stop running and return.
        // This is not the same as the machine's halt state.
        XCTAssertTrue(vm.isBreakPoint(pc: vm.pc))
        XCTAssertFalse(vm.isHalted)
    }
}
