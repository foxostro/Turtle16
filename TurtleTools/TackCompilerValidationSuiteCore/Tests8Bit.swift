//
//  Tests8Bit.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
import SnapCore

func testTackADDB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<Int8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<Int8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<Int8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int8, b: Int8) in a &+ b },
                    ins: { .addb($0, $1, $2) }
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackSUBB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<Int8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<Int8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<Int8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int8, b: Int8) in a &- b },
                    ins: { .subb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackMULB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<Int8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<Int8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<Int8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int8, b: Int8) in a &* b },
                    ins: { .mulb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackDIVB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<Int8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<Int8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<Int8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: Int8, b: Int8) in
                        ((b == 0) || (a == Int8.min && b == -1)) ? nil : a / b
                    },
                    ins: { .divb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackDIVUB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8, b: UInt8) in
                        b == 0 ? nil : a / b
                    },
                    ins: { .divub($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackMODB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8, b: UInt8) in
                        b == 0 ? nil : a % b
                    },
                    ins: { .modb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackLSLB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8, b: UInt8) in
                        (a << b) & 0xff
                    },
                    ins: { .lslb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackLSRB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8, b: UInt8) in
                        (a >> b) & 0xff
                    },
                    ins: { .lsrb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackANDB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8, b: UInt8) in a & b },
                    ins: { .andb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackORB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8, b: UInt8) in a | b },
                    ins: { .orb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackXORB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations3 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testBinaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8, b: UInt8) in a ^ b },
                    ins: { .xorb($0, $1, $2) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}

func testTackNEGB(progress: Progress, jobCount: Int) async throws {
    for registers in Byte8Configuration<UInt8>.combinations2 {
        try await runTestInBatches(
            Byte8Configuration<UInt8>.self,
            registers: registers,
            testFunction: { regs, range in
                try testUnaryOp(
                    Byte8Configuration<UInt8>.self,
                    registers: regs,
                    aRange: range,
                    expected: { (a: UInt8) in ~a },
                    ins: { .negb($0, $1) },
                )
            },
            progress: progress,
            jobCount: jobCount
        )
    }
}
