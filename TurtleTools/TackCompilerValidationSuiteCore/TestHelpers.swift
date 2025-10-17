//
//  TestHelpers.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
import SnapCore

func testBinaryOp<Config: TackRegisterConfiguration>(
    _: Config.Type,
    registers: [Config.RegisterType],
    aRange aRange0: ClosedRange<Int>,
    expected expectedResultFn: (Config.ValueType, Config.ValueType) -> Config.ValueType?,
    ins: (_ c: Config.RegisterType, _ a: Config.RegisterType, _ b: Config.RegisterType)
        -> TackInstruction
) throws {
    let aRange = aRange0.converted(to: Config.ValueType.self)!
    let a = registers[0]
    let b = registers[1]
    let c = registers[2]
    let addressA: UInt = 0x1000
    let addressB: UInt = 0x1001
    let addressResult: UInt = 0x1002
    let pa: Pointer = .p(0)
    let pb: Pointer = .p(1)
    let pc: Pointer = .p(2)
    let vm = TackVirtualMachine(
        TackProgram(
            instructions: [
                .lip(pa, Int(addressA)),
                .lip(pb, Int(addressB)),
                .lip(pc, Int(addressResult)),
                Config.load(a, pa, 0),
                Config.load(b, pb, 0),
                ins(c, a, b),
                Config.store(c, pc, 0)
            ],
            labels: [:]
        )
    )

    for aVal in aRange {
        for bVal in Config.ValueType.min...Config.ValueType.max {
            guard let expectedResult = expectedResultFn(aVal, bVal) else {
                continue
            }
            vm.store(aVal, address: addressA)
            vm.store(bVal, address: addressB)

            vm.pc = 0
            vm.isHalted = false
            do {
                try vm.run()
                let actual: Config.ValueType = vm.load(address: addressResult)
                try testAssert(
                    actual == expectedResult,
                    "Expected \(expectedResult), got \(actual) for inputs \(aVal), \(bVal)"
                )
            }
            catch {
                if let vmError = error as? TackVirtualMachineError,
                   vmError == TackVirtualMachineError.divideByZero {
                    throw TestFailure(
                        "TackVirtualMachineError.divideByZero indicates a problem with the test"
                    )
                }
                else {
                    throw error
                }
            }
        }
    }
}

func testUnaryOp<Config: TackRegisterConfiguration>(
    _: Config.Type,
    registers: [Config.RegisterType],
    aRange aRange0: ClosedRange<Int>,
    expected expectedResultFn: (Config.ValueType) -> Config.ValueType?,
    ins: (_ c: Config.RegisterType, _ a: Config.RegisterType) -> TackInstruction
) throws {
    let aRange = aRange0.converted(to: Config.ValueType.self)!
    let a = registers[0]
    let c = registers[1]
    let addressA: UInt = 0x1000
    let addressResult: UInt = 0x1001
    let pa: Pointer = .p(0)
    let pc: Pointer = .p(1)
    let vm = TackVirtualMachine(
        TackProgram(
            instructions: [
                .lip(pa, Int(addressA)),
                .lip(pc, Int(addressResult)),
                Config.load(a, pa, 0),
                ins(c, a),
                Config.store(c, pc, 0)
            ],
            labels: [:]
        )
    )

    for aVal in aRange {
        guard let expectedResult = expectedResultFn(aVal) else {
            continue
        }
        vm.store(aVal, address: addressA)

        vm.pc = 0
        vm.isHalted = false
        do {
            try vm.run()
            let actual: Config.ValueType = vm.load(address: addressResult)
            try testAssert(
                actual == expectedResult,
                "Expected \(expectedResult), got \(actual) for input \(aVal)"
            )
        }
        catch {
            throw error
        }
    }
}

extension TackVirtualMachine {
    func store<T: FixedWidthInteger>(_ value: T, address: UInt) {
        switch value {
        case let val as UInt8:
            store(b: val, address: address)
        case let val as Int8:
            store(b: UInt8(bitPattern: val), address: address)
        case let val as UInt16:
            store(w: val, address: address)
        case let val as Int16:
            store(w: UInt16(bitPattern: val), address: address)
        default:
            fatalError("Unsupported type: \(T.self)")
        }
    }

    func load<T: FixedWidthInteger>(address: UInt) -> T {
        switch T.self {
        case is UInt8.Type:
            loadb(address: address) as! T
        case is Int8.Type:
            Int8(bitPattern: loadb(address: address)) as! T
        case is UInt16.Type:
            loadw(address: address) as! T
        case is Int16.Type:
            Int16(bitPattern: loadw(address: address)) as! T
        default:
            fatalError("Unsupported type: \(T.self)")
        }
    }
}
