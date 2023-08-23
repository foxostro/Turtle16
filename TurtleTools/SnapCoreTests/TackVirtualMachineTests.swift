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
        XCTAssertThrowsError(try vm.getRegister(.w(.w(0)))) { error in
            XCTAssertEqual(error as? TackVirtualMachineError,
                           TackVirtualMachineError.undefinedRegister(.w(.w(0))))
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
            .la(.w(0), "foo")
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
            .la(.w(0), "foo")
        ], labels: ["foo" : 0xabcd])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(try vm.getRegister(.w(.w(0))), 0xabcd)
    }
    
    func testBZ_WithUndefinedLabel() throws {
        let program = TackProgram(instructions: [
            .bz(.w(0), "foo")
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
            .bz(.w(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 2)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testBZ_TakeTheBranch() throws {
        let program = TackProgram(instructions: [
            .nop,
            .bz(.w(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 0)
        XCTAssertFalse(vm.isHalted)
    }
    
    func testBNZ_WithUndefinedLabel() throws {
        let program = TackProgram(instructions: [
            .bnz(.w(0), "foo")
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
            .bnz(.w(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        try vm.step()
        XCTAssertEqual(vm.pc, 2)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testBNZ_TakeTheBranch() throws {
        let program = TackProgram(instructions: [
            .nop,
            .bnz(.w(0), "foo")
        ], labels: ["foo":0])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
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
            .callptr(.w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1000)
        try vm.step()
        XCTAssertEqual(vm.pc, 1000)
        XCTAssertTrue(vm.isHalted)
    }
    
    func testCALLPTR() throws {
        let program = TackProgram(instructions: [
            .callptr(.w(0)),
            .nop,
            .ret
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 2)
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
        vm.setRegister(.w(.w(0)), 1)
        try vm.step()
        XCTAssertThrowsError(try vm.getRegister(.w(.w(0)))) {
            guard let error = $0 as? TackVirtualMachineError else {
                XCTFail()
                return
            }
            if case .undefinedRegister(let reg) = error {
                XCTAssertEqual(reg, .w(.w(0)))
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
    
    func testLOAD16_ZeroOffset() throws {
        let program = TackProgram(instructions: [
            .lw(.w(1), .w(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.w(.w(1))))
    }
    
    func testLOAD16_NegativeOffset() throws {
        let program = TackProgram(instructions: [
            .lw(.w(1), .w(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbeee)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.w(.w(1))))
    }
    
    func testLOAD16_PositiveOffset() throws {
        let program = TackProgram(instructions: [
            .lw(.w(1), .w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbef0)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.w(.w(1))))
    }
    
    func testSTORE16_ZeroOffset() throws {
        let program = TackProgram(instructions: [
            .sw(.w(1), .w(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0xcafe)
        vm.setRegister(.w(.w(0)), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbeef))
    }
    
    func testSTORE16_NegativeOffset() throws {
        let program = TackProgram(instructions: [
            .sw(.w(1), .w(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0xcafe)
        vm.setRegister(.w(.w(0)), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbeee))
    }
    
    func testSTORE16_PositiveOffset() throws {
        let program = TackProgram(instructions: [
            .sw(.w(1), .w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0xcafe)
        vm.setRegister(.w(.w(0)), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbef0))
    }
    
    func testLOAD8_ZeroOffset() throws {
        let program = TackProgram(instructions: [
            .lb(.b(1), .w(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.b(.b(1))))
    }
    
    func testLOAD8_NegativeOffset() throws {
        let program = TackProgram(instructions: [
            .lb(.b(1), .w(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbeee)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.b(.b(1))))
    }
    
    func testLOAD8_PositiveOffset() throws {
        let program = TackProgram(instructions: [
            .lb(.b(1), .w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xbeef)
        vm.store(value: 0xcafe, address: 0xbef0)
        try vm.step()
        XCTAssertEqual(0xcafe, try vm.getRegister(.b(.b(1))))
    }
    
    func testSTORE8_ZeroOffset() throws {
        let program = TackProgram(instructions: [
            .sb(.b(1), .w(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0xcafe)
        vm.setRegister(.w(.w(0)), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbeef))
    }
    
    func testSTORE8_NegativeOffset() throws {
        let program = TackProgram(instructions: [
            .sb(.b(1), .w(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0xcafe)
        vm.setRegister(.w(.w(0)), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbeee))
    }
    
    func testSTORE8_PositiveOffset() throws {
        let program = TackProgram(instructions: [
            .sb(.b(1), .w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0xcafe)
        vm.setRegister(.w(.w(0)), 0xbeef)
        try vm.step()
        XCTAssertEqual(0xcafe, vm.load(address: 0xbef0))
    }
    
    func testSTSTR() throws {
        let program = TackProgram(instructions: [
            .ststr(.w(0), "abc")
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xbeef)
        try vm.step()
        XCTAssertEqual(Int("a".utf8.first!), Int(vm.load(address: 0xbeef+0)))
        XCTAssertEqual(Int("b".utf8.first!), Int(vm.load(address: 0xbeef+1)))
        XCTAssertEqual(Int("c".utf8.first!), Int(vm.load(address: 0xbeef+2)))
    }
    
    func testMEMCPY_BadCount() throws {
        let program = TackProgram(instructions: [
            .memcpy(.w(1), .w(0), -1)
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
            .memcpy(.w(1), .w(0), 2)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0x1000)
        vm.setRegister(.w(.w(0)), 0x2000)
        vm.store(value: 0xaabb, address: 0x2000)
        vm.store(value: 0xccdd, address: 0x2001)
        try vm.step()
        XCTAssertEqual(0xaabb, vm.load(address: 0x1000))
        XCTAssertEqual(0xccdd, vm.load(address: 0x1001))
    }
    
    func testALLOCA_BadCount() throws {
        let program = TackProgram(instructions: [
            .alloca(.w(0), -1)
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
            .alloca(.w(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        let sp = try vm.getRegister(.sp)
        XCTAssertEqual(sp, try vm.getRegister(.w(.w(0))))
    }
    
    func testALLOCA_NonZero() throws {
        let program = TackProgram(instructions: [
            .alloca(.w(0), 10)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        let sp = try vm.getRegister(.sp)
        let expectedSp = Word(0) &- 10
        XCTAssertEqual(sp, expectedSp)
        XCTAssertEqual(sp, try vm.getRegister(.w(.w(0))))
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
            .not(.w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(1))))
    }
    
    func testNOT_ffff() throws {
        let program = TackProgram(instructions: [
            .not(.w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(1))))
    }
    
    func testANDI16_bad_imm() throws {
        let program = TackProgram(instructions: [
            .andiw(.w(1), .w(0), -1)
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
            .andiw(.w(1), .w(0), 0b1010101010101010)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(0b1010101010101010, try vm.getRegister(.w(.w(1))))
    }
    
    func testADDI16_pos() throws {
        let program = TackProgram(instructions: [
            .addiw(.w(1), .w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(1))))
    }
    
    func testADDI16_neg() throws {
        let program = TackProgram(instructions: [
            .addiw(.w(1), .w(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.w(.w(1))))
    }
    
    func testSUBI16_pos() throws {
        let program = TackProgram(instructions: [
            .subiw(.w(1), .w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.w(.w(1))))
    }
    
    func testSUBI16_neg() throws {
        let program = TackProgram(instructions: [
            .subiw(.w(1), .w(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(1))))
    }
    
    func testMULI16_pos() throws {
        let program = TackProgram(instructions: [
            .mulib(.w(1), .w(0), 2)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 2)
        try vm.step()
        XCTAssertEqual(4, try vm.getRegister(.w(.w(1))))
    }
    
    func testMULI16_neg() throws {
        let program = TackProgram(instructions: [
            .mulib(.w(1), .w(0), -2)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 2)
        try vm.step()
        XCTAssertEqual(Word(0) &- 4, try vm.getRegister(.w(.w(1))))
    }
    
    func testLI16_pos() throws {
        let program = TackProgram(instructions: [
            .liw(.w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(0))))
    }
    
    func testLI16_neg() throws {
        let program = TackProgram(instructions: [
            .liw(.w(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.w(.w(0))))
    }
    
    func testLI16_TooBigPos() throws {
        let program = TackProgram(instructions: [
            .liw(.w(0), 32768)
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
            .liw(.w(0), -32769)
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
            .liuw(.w(0), -1)
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
            .liuw(.w(0), 65536)
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
            .liuw(.w(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(0))))
    }
    
    func testAND16() throws {
        let program = TackProgram(instructions: [
            .andw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xf0f0)
        vm.setRegister(.w(.w(1)), 0xffff)
        try vm.step()
        XCTAssertEqual(0xf0f0, try vm.getRegister(.w(.w(2))))
    }
    
    func testOR16() throws {
        let program = TackProgram(instructions: [
            .orw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xf0f0)
        vm.setRegister(.w(.w(1)), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0xffff, try vm.getRegister(.w(.w(2))))
    }
    
    func testXOR16() throws {
        let program = TackProgram(instructions: [
            .xorw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xf0ff)
        vm.setRegister(.w(.w(1)), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0xfff0, try vm.getRegister(.w(.w(2))))
    }
    
    func testNEG16() throws {
        let program = TackProgram(instructions: [
            .negw(.w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0xf0f0)
        try vm.step()
        XCTAssertEqual(0x0f0f, try vm.getRegister(.w(.w(1))))
    }
    
    func testADD16() throws {
        let program = TackProgram(instructions: [
            .addw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
        vm.setRegister(.w(.w(1)), 1)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.w(.w(2))))
    }
    
    func testSUB16() throws {
        let program = TackProgram(instructions: [
            .subw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 2)
        vm.setRegister(.w(.w(1)), 1)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.w(.w(2))))
    }
    
    func testMUL16() throws {
        let program = TackProgram(instructions: [
            .mulw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 2)
        vm.setRegister(.w(.w(1)), 2)
        try vm.step()
        XCTAssertEqual(4, try vm.getRegister(.w(.w(2))))
    }
    
    func testDIV16() throws {
        let program = TackProgram(instructions: [
            .divw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 2)
        vm.setRegister(.w(.w(1)), 4)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.w(.w(2))))
    }
    
    func testDIV16_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .divw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        vm.setRegister(.w(.w(1)), 1)
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
            .modw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 2)
        vm.setRegister(.w(.w(1)), 3)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testMOD16_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .modw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        vm.setRegister(.w(.w(1)), 1)
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
            .lslw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
        vm.setRegister(.w(.w(1)), 1)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.w(.w(2))))
    }
    
    func testLSL16_overflow() throws {
        let program = TackProgram(instructions: [
            .lslw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
        vm.setRegister(.w(.w(1)), 0x8000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLSR16() throws {
        let program = TackProgram(instructions: [
            .lsrw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
        vm.setRegister(.w(.w(1)), 4)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.w(.w(2))))
    }
    
    func testLSR16_underflow() throws {
        let program = TackProgram(instructions: [
            .lsrw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
        vm.setRegister(.w(.w(1)), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testEQ16_Equal() throws {
        let program = TackProgram(instructions: [
            .eqw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1000)
        vm.setRegister(.w(.w(1)), 1000)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testEQ16_NotEqual() throws {
        let program = TackProgram(instructions: [
            .eqw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1000)
        vm.setRegister(.w(.w(1)), 1001)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testNE16_Equal() throws {
        let program = TackProgram(instructions: [
            .new(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1000)
        vm.setRegister(.w(.w(1)), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testNE16_NotEqual() throws {
        let program = TackProgram(instructions: [
            .new(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1000)
        vm.setRegister(.w(.w(1)), 1001)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLT16_True() throws {
        let program = TackProgram(instructions: [
            .ltw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1000)
        vm.setRegister(.w(.w(1)), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLT16_False() throws {
        let program = TackProgram(instructions: [
            .ltw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), Word(0) &- Word(1000))
        vm.setRegister(.w(.w(1)), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGE16_True() throws {
        let program = TackProgram(instructions: [
            .gew(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 1000)
        vm.setRegister(.w(.w(0)), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGE16_False() throws {
        let program = TackProgram(instructions: [
            .gew(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), Word(0) &- Word(1000))
        vm.setRegister(.w(.w(0)), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLE16_True() throws {
        let program = TackProgram(instructions: [
            .lew(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), Word(0) &- Word(1000))
        vm.setRegister(.w(.w(0)), 1000)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLE16_False() throws {
        let program = TackProgram(instructions: [
            .lew(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 1000)
        vm.setRegister(.w(.w(0)), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGT16_True() throws {
        let program = TackProgram(instructions: [
            .gtw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 1000)
        vm.setRegister(.w(.w(0)), Word(0) &- Word(1000))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGT16_False() throws {
        let program = TackProgram(instructions: [
            .gtw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), Word(0) &- Word(1000))
        vm.setRegister(.w(.w(0)), 1000)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLTU16_True() throws {
        let program = TackProgram(instructions: [
            .ltuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLTU16_False() throws {
        let program = TackProgram(instructions: [
            .ltuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0xffff)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGEU16_True() throws {
        let program = TackProgram(instructions: [
            .geuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0xffff)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGEU16_False() throws {
        let program = TackProgram(instructions: [
            .geuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLEU16_True() throws {
        let program = TackProgram(instructions: [
            .leuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLEU16_False() throws {
        let program = TackProgram(instructions: [
            .leuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0xffff)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGTU16_True() throws {
        let program = TackProgram(instructions: [
            .gtuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0xffff)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGTU16_False() throws {
        let program = TackProgram(instructions: [
            .gtuw(.w(2), .w(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(1)), 0)
        vm.setRegister(.w(.w(0)), 0xffff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLI8_pos() throws {
        let program = TackProgram(instructions: [
            .lib(.b(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.b(.b(0))))
    }
    
    func testLI8_neg() throws {
        let program = TackProgram(instructions: [
            .lib(.b(0), -1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.b(.b(0))))
    }
    
    func testLI8_TooBigPos() throws {
        let program = TackProgram(instructions: [
            .lib(.b(0), 128)
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
            .lib(.b(0), -129)
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
            .liub(.b(0), -1)
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
            .liub(.b(0), 256)
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
            .liub(.b(0), 1)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.b(.b(0))))
    }
    
    func testAND8() throws {
        let program = TackProgram(instructions: [
            .andb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xf0f0)
        vm.setRegister(.b(.b(1)), 0xffff)
        try vm.step()
        XCTAssertEqual(0x00f0, try vm.getRegister(.b(.b(2))))
    }
    
    func testOR8() throws {
        let program = TackProgram(instructions: [
            .orb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xf0f0)
        vm.setRegister(.b(.b(1)), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0x00ff, try vm.getRegister(.b(.b(2))))
    }
    
    func testXOR8() throws {
        let program = TackProgram(instructions: [
            .xorb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xf0ff)
        vm.setRegister(.b(.b(1)), 0x0f0f)
        try vm.step()
        XCTAssertEqual(0x00f0, try vm.getRegister(.b(.b(2))))
    }
    
    func testNEG8() throws {
        let program = TackProgram(instructions: [
            .negb(.b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xf0f0)
        try vm.step()
        XCTAssertEqual(0x000f, try vm.getRegister(.b(.b(1))))
    }
    
    func testADD8() throws {
        let program = TackProgram(instructions: [
            .addb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff01)
        vm.setRegister(.b(.b(1)), 0xff01)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.b(.b(2))))
    }
    
    func testSUB8() throws {
        let program = TackProgram(instructions: [
            .subb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff02)
        vm.setRegister(.b(.b(1)), 0xff01)
        try vm.step()
        XCTAssertEqual(Word(0) &- 1, try vm.getRegister(.b(.b(2))))
    }
    
    func testMUL8() throws {
        let program = TackProgram(instructions: [
            .mulb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff02)
        vm.setRegister(.b(.b(1)), 2)
        try vm.step()
        XCTAssertEqual(4, try vm.getRegister(.b(.b(2))))
    }
    
    func testDIV8() throws {
        let program = TackProgram(instructions: [
            .divb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 2)
        vm.setRegister(.b(.b(1)), 4)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.b(.b(2))))
    }
    
    func testDIV8_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .divb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0)
        vm.setRegister(.b(.b(1)), 1)
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
            .modb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff02)
        vm.setRegister(.b(.b(1)), 0xff03)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.b(.b(2))))
    }
    
    func testMOD8_DivideByZero() throws {
        let program = TackProgram(instructions: [
            .modb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0)
        vm.setRegister(.b(.b(1)), 1)
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
            .lslb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff01)
        vm.setRegister(.b(.b(1)), 0xff01)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.b(.b(2))))
    }
    
    func testLSL8_overflow() throws {
        let program = TackProgram(instructions: [
            .lslb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff01)
        vm.setRegister(.b(.b(1)), 0xff80)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.b(.b(2))))
    }
    
    func testLSR8() throws {
        let program = TackProgram(instructions: [
            .lsrb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff01)
        vm.setRegister(.b(.b(1)), 0xff04)
        try vm.step()
        XCTAssertEqual(2, try vm.getRegister(.b(.b(2))))
    }
    
    func testLSR8_underflow() throws {
        let program = TackProgram(instructions: [
            .lsrb(.b(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff01)
        vm.setRegister(.b(.b(1)), 0xff00)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.b(.b(2))))
    }
    
    func testEQ8_Equal() throws {
        let program = TackProgram(instructions: [
            .eqb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xffff)
        vm.setRegister(.b(.b(1)), 0xf0ff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testEQ8_NotEqual() throws {
        let program = TackProgram(instructions: [
            .eqb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xffff)
        vm.setRegister(.b(.b(1)), 0xf0f0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testNE8_Equal() throws {
        let program = TackProgram(instructions: [
            .neb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff01)
        vm.setRegister(.b(.b(1)), 0xf001)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testNE8_NotEqual() throws {
        let program = TackProgram(instructions: [
            .neb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0xff01)
        vm.setRegister(.b(.b(1)), 0xff00)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLT8_True() throws {
        let program = TackProgram(instructions: [
            .ltb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 127)
        vm.setRegister(.b(.b(1)), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLT8_False() throws {
        let program = TackProgram(instructions: [
            .ltb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), Word(0) &- Word(127))
        vm.setRegister(.b(.b(1)), 127)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGE8_True() throws {
        let program = TackProgram(instructions: [
            .geb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 127)
        vm.setRegister(.b(.b(0)), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGE8_False() throws {
        let program = TackProgram(instructions: [
            .geb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), Word(0) &- Word(127))
        vm.setRegister(.b(.b(0)), 127)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLE8_True() throws {
        let program = TackProgram(instructions: [
            .leb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), Word(0) &- Word(127))
        vm.setRegister(.b(.b(0)), 127)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLE8_False() throws {
        let program = TackProgram(instructions: [
            .leb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 127)
        vm.setRegister(.b(.b(0)), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGT8_True() throws {
        let program = TackProgram(instructions: [
            .gtb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 127)
        vm.setRegister(.b(.b(0)), Word(0) &- Word(127))
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGT8_False() throws {
        let program = TackProgram(instructions: [
            .gtb(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), Word(0) &- Word(127))
        vm.setRegister(.b(.b(0)), 127)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLTU8_True() throws {
        let program = TackProgram(instructions: [
            .ltub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0)
        vm.setRegister(.b(.b(0)), 0xff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLTU8_False() throws {
        let program = TackProgram(instructions: [
            .ltub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0xff)
        vm.setRegister(.b(.b(0)), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGEU8_True() throws {
        let program = TackProgram(instructions: [
            .geub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0xff)
        vm.setRegister(.b(.b(0)), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGEU8_False() throws {
        let program = TackProgram(instructions: [
            .geub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0)
        vm.setRegister(.b(.b(0)), 0xff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testLEU8_True() throws {
        let program = TackProgram(instructions: [
            .leub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0)
        vm.setRegister(.b(.b(0)), 0xff)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testLEU8_False() throws {
        let program = TackProgram(instructions: [
            .leub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0xff)
        vm.setRegister(.b(.b(0)), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testGTU8_True() throws {
        let program = TackProgram(instructions: [
            .gtub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0xff)
        vm.setRegister(.b(.b(0)), 0)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(2))))
    }
    
    func testGTU8_False() throws {
        let program = TackProgram(instructions: [
            .gtub(.w(2), .b(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(1)), 0)
        vm.setRegister(.b(.b(0)), 0xff)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(2))))
    }
    
    func testMOVSWB_Zero() throws {
        let program = TackProgram(instructions: [
            .movswb(.w(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.w(.w(1))))
    }
    
    func testMOVSWB_One() throws {
        let program = TackProgram(instructions: [
            .movswb(.w(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 1)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.w(.w(1))))
    }
    
    func testMOVSWB_NegOne() throws {
        let program = TackProgram(instructions: [
            .movswb(.w(1), .b(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.b(.b(0)), 0x80)
        try vm.step()
        XCTAssertEqual(Word(0) &- 0x80, try vm.getRegister(.w(.w(1))))
    }
    
    func testMOVSBW_Zero() throws {
        let program = TackProgram(instructions: [
            .movsbw(.b(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0)
        try vm.step()
        XCTAssertEqual(0, try vm.getRegister(.b(.b(1))))
    }
    
    func testMOVSBW_One() throws {
        let program = TackProgram(instructions: [
            .movsbw(.b(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 1)
        try vm.step()
        XCTAssertEqual(1, try vm.getRegister(.b(.b(1))))
    }
    
    func testMOVSBW_NegOne() throws {
        let program = TackProgram(instructions: [
            .movsbw(.b(1), .w(0))
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), 0x80)
        try vm.step()
        XCTAssertEqual(Word(0) &- 0x80, try vm.getRegister(.b(.b(1))))
    }
    
    func testSerialOutput() throws {
        let program = TackProgram(instructions: [
            .sw(.w(1), .w(0), 0)
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.setRegister(.w(.w(0)), vm.kMemoryMappedSerialOutputPort)
        vm.setRegister(.w(.w(1)), 65)
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
            .liuw(.w(0), 272),
            .liuw(.w(2), syscallNumber),
            .sw(.w(2), .w(0), 0),
            
            // Write the argument pointer to memory at 273, keep address in vr1.
            .liuw(.w(1), 273),
            .liuw(.w(2), addressOfArgumentStructure),
            .sw(.w(2), .w(1), 0),
            
            // Call the virtual machine
            .syscall(.w(0), // syscall number
                     .w(1)),// pointer to argument structure
            
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
    
    func testSyscall_getc() throws {
        let syscallNumber = TackVirtualMachine.Syscall.getc.rawValue
        let addressOfArgumentStructure = UInt16(274)
        let program = TackProgram(instructions: [
            // Write the syscall number to memory at 272, keep address in vr0.
            .liuw(.w(0), 272),
            .liuw(.w(2), syscallNumber),
            .sw(.w(2), .w(0), 0),
            
            // Write the argument pointer to memory at 273, keep address in vr1.
            // The syscall writes the return value to memory at this address.
            .liuw(.w(1), 273),
            .liuw(.w(2), Int(addressOfArgumentStructure)),
            .sw(.w(2), .w(1), 0),
            
            // Call the virtual machine
            .syscall(.w(0), // syscall number
                     .w(1)),// pointer to argument structure
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        vm.onSerialInput = { 65 }
        try vm.run()
        let result = vm.load(address: addressOfArgumentStructure)
        XCTAssertEqual(result, 65)
    }
    
    func testSyscall_putc() throws {
        let syscallNumber = TackVirtualMachine.Syscall.putc.rawValue
        let addressOfArgumentStructure = UInt16(274)
        let argument = 65
        let program = TackProgram(instructions: [
            // Write the syscall number to memory at 272, keep address in vr0.
            .liuw(.w(0), 272),
            .liuw(.w(2), syscallNumber),
            .sw(.w(2), .w(0), 0),
            
            // Write the argument to memory at 274.
            .liuw(.w(1), Int(addressOfArgumentStructure)),
            .liuw(.w(2), argument),
            .sw(.w(2), .w(1), 0),
            
            // Write the argument pointer to memory at 273, keep address in vr1.
            // The syscall writes the return value to memory at this address.
            .liuw(.w(1), 273),
            .liuw(.w(2), Int(addressOfArgumentStructure)),
            .sw(.w(2), .w(1), 0),
            
            // Call the virtual machine
            .syscall(.w(0), // syscall number
                     .w(1)),// pointer to argument structure
        ], labels: [:])
        let vm = TackVirtualMachine(program)
        var result: Int? = nil
        vm.onSerialOutput = { value in
            result = Int(value)
        }
        try vm.run()
        XCTAssertEqual(result, argument)
    }
}
