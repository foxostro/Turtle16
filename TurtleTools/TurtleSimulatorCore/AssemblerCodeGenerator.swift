//
//  AssemblerCodeGenerator.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 5/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public final class AssemblerCodeGenerator {
    public typealias Register = AssemblerSingleInstructionCodeGenerator.Register
    public var instructions: [UInt16] = []
    public var symbols: [String: Int] = [:]
    public var sourceAnchor: SourceAnchor? {
        set(value) {
            gen.sourceAnchor = value
        }
        get {
            gen.sourceAnchor
        }
    }
    let gen = AssemblerSingleInstructionCodeGenerator()
    public private(set) var isAssembling = false

    public struct PatcherAction {
        public let index: Int
        public let sourceAnchor: SourceAnchor?
        public let identifier: String
        public let lowerLimit: Int
        public let upperLimit: Int
        public let mask: UInt16
        public let shift: Int
        public let offset: Int
    }
    public private(set) var patcherActions: [PatcherAction] = []

    public init() {}

    public func begin() {
        isAssembling = true
    }

    public func end() throws {
        isAssembling = false
        for action in patcherActions {
            assert(action.shift >= 0)
            guard let value = symbols[action.identifier] else {
                throw CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "use of unresolved identifier: `\(action.identifier)'"
                )
            }
            let offset: Int = value - action.index + action.offset
            if offset > action.upperLimit {
                throw CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "offset exceeds positive limit of \(action.upperLimit): `\(offset)'"
                )
            }
            if offset < action.lowerLimit {
                throw CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "offset exceeds negative limit of \(action.lowerLimit): `\(offset)'"
                )
            }
            let twosComplementOffset: UInt16 = UInt16(UInt(bitPattern: offset) & 0xffff)
            let finalOffset = UInt16((twosComplementOffset & action.mask) >> action.shift)
            let ins = UInt16(instructions[action.index]) | finalOffset
            instructions[action.index] = ins
        }
    }

    public func nop() {
        assert(isAssembling)
        instructions.append(gen.nop())
    }

    public func hlt() {
        assert(isAssembling)
        instructions.append(gen.hlt())
    }

    public func load(_ destination: Register, _ source: Register, _ offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.load(destination, source, offset))
    }

    public func store(_ val: Register, _ addr: Register, _ offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.store(val, addr, offset))
    }

    public func li(_ destination: Register, _ value: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.li(destination, value))
    }

    public func lui(_ destination: Register, _ value: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.lui(destination, value))
    }

    public func cmp(_ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.cmp(left, right))
    }

    public func add(_ dst: Register, _ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.add(dst, left, right))
    }

    public func sub(_ dst: Register, _ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.sub(dst, left, right))
    }

    public func and(_ dst: Register, _ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.and(dst, left, right))
    }

    public func or(_ dst: Register, _ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.or(dst, left, right))
    }

    public func xor(_ dst: Register, _ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.xor(dst, left, right))
    }

    public func cmpi(_ left: Register, _ right: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.cmpi(left, right))
    }

    public func addi(_ dst: Register, _ left: Register, _ right: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.addi(dst, left, right))
    }

    public func subi(_ dst: Register, _ left: Register, _ right: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.subi(dst, left, right))
    }

    public func andi(_ dst: Register, _ left: Register, _ right: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.andi(dst, left, right))
    }

    public func ori(_ dst: Register, _ left: Register, _ right: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.ori(dst, left, right))
    }

    public func xori(_ dst: Register, _ left: Register, _ right: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.xori(dst, left, right))
    }

    public func not(_ dst: Register, _ left: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.not(dst, left))
    }

    public func jmp(offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.jmp(offset))
    }

    public func jr(_ destination: Register, _ offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.jr(destination, offset))
    }

    public func jalr(_ link: Register, _ destination: Register, _ offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.jalr(link, destination, offset))
    }

    public func beq(offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.beq(offset))
    }

    public func bne(offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.bne(offset))
    }

    public func blt(offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.blt(offset))
    }

    public func bgt(offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.bgt(offset))
    }

    public func bltu(offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.bltu(offset))
    }

    public func bgtu(offset: Int) throws {
        assert(isAssembling)
        instructions.append(try gen.bgtu(offset))
    }

    public func adc(_ dst: Register, _ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.adc(dst, left, right))
    }

    public func sbc(_ dst: Register, _ left: Register, _ right: Register) throws {
        assert(isAssembling)
        instructions.append(try gen.sbc(dst, left, right))
    }

    public func label(_ name: String) throws {
        guard symbols[name] == nil else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "label redefines existing symbol: `\(name)'"
            )
        }
        symbols[name] = instructions.count
    }

    fileprivate func branch(_ name: String, _ doBranch: (Int) throws -> UInt16) throws {
        assert(isAssembling)
        let kBranchPipelineOffset = -2
        let offset: Int
        if let value = symbols[name] {
            offset = value - instructions.count + kBranchPipelineOffset
        }
        else {
            offset = 0
            let action = PatcherAction(
                index: instructions.count,
                sourceAnchor: sourceAnchor,
                identifier: name,
                lowerLimit: -1024,
                upperLimit: 1023,
                mask: 0x07ff,
                shift: 0,
                offset: kBranchPipelineOffset
            )
            patcherActions.append(action)
        }
        instructions.append(try doBranch(offset))
    }

    public func jmp(_ name: String) throws {
        try branch(name, { try self.gen.jmp($0) })
    }

    public func beq(_ name: String) throws {
        try branch(name, { try self.gen.beq($0) })
    }

    public func bne(_ name: String) throws {
        try branch(name, { try self.gen.bne($0) })
    }

    public func blt(_ name: String) throws {
        try branch(name, { try self.gen.blt($0) })
    }

    public func bgt(_ name: String) throws {
        try branch(name, { try self.gen.bgt($0) })
    }

    public func bltu(_ name: String) throws {
        try branch(name, { try self.gen.bltu($0) })
    }

    public func bgtu(_ name: String) throws {
        try branch(name, { try self.gen.bgtu($0) })
    }

    public func la(_ destination: Register, _ name: String) throws {
        assert(isAssembling)
        let lo: Int
        let hi: Int
        if let value = symbols[name] {
            lo = value & 0x00ff
            hi = (value & 0xff00) >> 8
        }
        else {
            lo = 0
            hi = 0
            patcherActions += [
                PatcherAction(
                    index: instructions.count + 0,
                    sourceAnchor: sourceAnchor,
                    identifier: name,
                    lowerLimit: 0,
                    upperLimit: 0xffff,
                    mask: 0x00ff,
                    shift: 0,
                    offset: instructions.count + 0
                ),
                PatcherAction(
                    index: instructions.count + 1,
                    sourceAnchor: sourceAnchor,
                    identifier: name,
                    lowerLimit: 0,
                    upperLimit: 0xffff,
                    mask: 0xff00,
                    shift: 8,
                    offset: instructions.count + 1
                )
            ]
        }
        instructions.append(try gen.li(destination, lo))
        instructions.append(try gen.lui(destination, hi))
    }
}
