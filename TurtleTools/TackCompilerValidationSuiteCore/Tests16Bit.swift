//
//  Tests16Bit.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
import SnapCore

func testTackADDW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<Int16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<Int16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<Int16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int16, b: Int16) in a &+ b },
                    ins: { .addw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackSUBW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<Int16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<Int16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<Int16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int16, b: Int16) in a &- b },
                    ins: { .subw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackMULW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<Int16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<Int16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<Int16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int16, b: Int16) in a &* b },
                    ins: { .mulw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackDIVW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<Int16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<Int16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<Int16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int16, b: Int16) in
                        ((b == 0) || (a == Int16.min && b == -1)) ? nil : a / b
                    },
                    ins: { .divw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackDIVUW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16, b: UInt16) in
                        b == 0 ? nil : a / b
                    },
                    ins: { .divuw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackMODW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16, b: UInt16) in
                        b == 0 ? nil : a % b
                    },
                    ins: { .modw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackLSLW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16, b: UInt16) in
                        (a << b) & 0xffff
                    },
                    ins: { .lslw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackLSRW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16, b: UInt16) in
                        (a >> b) & 0xffff
                    },
                    ins: { .lsrw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackANDW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16, b: UInt16) in a & b },
                    ins: { .andw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackORW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16, b: UInt16) in a | b },
                    ins: { .orw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackXORW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations3 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16, b: UInt16) in a ^ b },
                    ins: { .xorw($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackNEGW(progress: Progress, jobCount: Int) async throws {
    for registers in Word16Configuration<UInt16>.combinations2 {
        try await runTestInBatches(
            Word16Configuration<UInt16>.self,
            registers: registers,
            testFunction: { regs, range in
                try testUnaryOp(
                    Word16Configuration<UInt16>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt16) in ~a },
                    ins: { .negw($0, $1) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}
