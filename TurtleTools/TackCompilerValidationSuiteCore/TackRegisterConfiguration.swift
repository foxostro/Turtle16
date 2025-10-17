//
//  TackRegisterConfiguration.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
import SnapCore

typealias Pointer = TackInstruction.RegisterPointer

/// Protocol for abstracting register width-specific operations in exhaustive tests
protocol TackRegisterConfiguration: Sendable {
    associatedtype RegisterType: Sendable
    associatedtype ValueType: FixedWidthInteger & Sendable

    static var combinations2: [[RegisterType]] { get }
    static var combinations3: [[RegisterType]] { get }

    static func load(
        _ reg: RegisterType, _ ptr: Pointer, _ offset: Int
    ) -> TackInstruction

    static func store(
        _ reg: RegisterType, _ ptr: Pointer, _ offset: Int
    ) -> TackInstruction
}

extension TackRegisterConfiguration {
    static var rangeSize: Int {
        Int(ValueType.max) - Int(ValueType.min) + 1
    }

    static var binaryOpTotalIterations: Int {
        // We only slice the A range, not the B range, and so we define a test iteration as
        // encompassing invocations of the test function to test the full B range.
        combinations3.count * rangeSize
    }

    static var unaryOpTotalIterations: Int {
        combinations2.count * rangeSize
    }
}

/// Configuration for 8-bit register operations
struct Byte8Configuration<T: FixedWidthInteger & Sendable>: TackRegisterConfiguration {
    typealias RegisterType = TackInstruction.Register8
    typealias ValueType = T

    static var combinations2: [[RegisterType]] {
        [
            [.b(0), .b(1)],
            [.b(0), .b(0)],
        ]
    }

    static var combinations3: [[RegisterType]] {
        [
            [.b(0), .b(1), .b(2)],
            [.b(0), .b(1), .b(0)],
            [.b(0), .b(1), .b(1)]
        ]
    }

    static func load(
        _ reg: RegisterType,
        _ ptr: Pointer,
        _ offset: Int
    ) -> TackInstruction {
        .lb(reg, ptr, offset)
    }

    static func store(
        _ reg: RegisterType,
        _ ptr: Pointer,
        _ offset: Int
    ) -> TackInstruction {
        .sb(reg, ptr, offset)
    }
}

/// Configuration for 16-bit register operations
struct Word16Configuration<T: FixedWidthInteger & Sendable>: TackRegisterConfiguration {
    typealias RegisterType = TackInstruction.Register16
    typealias ValueType = T

    static var combinations2: [[RegisterType]] {
        [
            [.w(0), .w(1)],
            [.w(0), .w(0)]
        ]
    }

    static var combinations3: [[RegisterType]] {
        [
            [.w(0), .w(1), .w(2)],
            [.w(0), .w(1), .w(0)],
            [.w(0), .w(1), .w(1)]
        ]
    }

    static func load(
        _ reg: RegisterType,
        _ ptr: Pointer,
        _ offset: Int
    ) -> TackInstruction {
        .lw(reg, ptr, offset)
    }

    static func store(
        _ reg: RegisterType,
        _ ptr: Pointer,
        _ offset: Int
    ) -> TackInstruction {
        .sw(reg, ptr, offset)
    }
}
