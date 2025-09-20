//
//  TackVirtualMachine.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/6/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public enum TackVirtualMachineError: Error, Equatable {
    case undefinedLabel(String)
    case undefinedRegister(TackInstruction.Register)
    case invalidArgument
    case underflowRegisterStack
    case divideByZero
    case inlineAssemblyNotSupported
}

public final class TackVirtualMachine {
    public typealias Register = TackInstruction.Register
    public typealias RegisterPointer = TackInstruction.RegisterPointer
    public typealias RegisterBoolean = TackInstruction.RegisterBoolean
    public typealias Register16 = TackInstruction.Register16
    public typealias Register8 = TackInstruction.Register8
    public typealias Word = UInt16

    public let kMemoryMappedSerialOutputPort: UInt = 0x0001
    public let kPageSize: UInt = 4096

    public let program: TackProgram
    public var pc: UInt = 0
    public var nextPc: UInt = 0
    public var isHalted = false
    private var globalRegisters: [Register: UInt] = [:]
    public var registers: [[Register: UInt]] = [[:]]
    private var memoryPages: [UInt: [UInt]] = [:]
    private var breakPoints: [Bool]
    public var onSerialOutput: (UInt8) -> Void = { _ in }
    public var onSerialInput: () -> UInt8 = { 0 }

    public enum Syscall: Int {
        case invalid
        case getc
        case putc
    }

    public var backtrace: [UInt] {
        var result: [UInt] = []
        for currentRegisterSet in registers {
            guard let registerRA = currentRegisterSet[.ra] else {
                break
            }
            result.append(registerRA)
        }
        result.append(pc)
        return result
    }

    public var symbols: Env? {
        var result: Env? = nil
        var i = Int(pc)
        while i >= 0, result == nil {
            if i < program.symbols.count {
                result = program.symbols[i]
            }
            i = i - 1
        }
        return result
    }

    public func findSourceAnchor(pc pc_: UInt) -> SourceAnchor? {
        var result: SourceAnchor? = nil
        var i = Int(pc_)
        while i >= 0, result == nil {
            if i < program.sourceAnchor.count {
                result = program.sourceAnchor[i]
            }
            i = i - 1
        }
        return result
    }

    public init(_ program: TackProgram) {
        self.program = program
        breakPoints = [Bool](repeating: false, count: program.instructions.count)
        setRegister(.sp, p: 0)
        setRegister(.fp, p: 0)
    }

    public func setBreakPoint(pc: UInt, value: Bool) {
        assert(pc >= 0 && pc < program.instructions.count)
        breakPoints[Int(pc)] = value
    }

    public func isBreakPoint(pc: UInt) -> Bool {
        assert(pc >= 0 && pc < program.instructions.count)
        return breakPoints[Int(pc)]
    }

    public func wordToInt(_ word: Word) -> Int {
        let result: Int =
            if word > (Word.max >> 1) {
                -Int(~word + 1)
            }
            else {
                Int(word)
            }
        return result
    }

    public func intToWord(_ value: Int) -> Word {
        assert(value >= Int16.min && value <= Int16.max)
        let result =
            if value < 0 {
                Word(0) &- Word(-value)
            }
            else {
                Word(value)
            }
        return result
    }

    public func uint8ToInt(_ u8: UInt8) -> Int {
        let result: Int =
            if u8 > (UInt8.max >> 1) {
                -Int(~u8 + 1)
            }
            else {
                Int(u8)
            }
        return result
    }

    public func intToUInt8(_ value: Int) -> UInt8 {
        assert(value >= Int8.min && value <= Int8.max)
        let result =
            if value < 0 {
                UInt8(0) &- UInt8(-value)
            }
            else {
                UInt8(value)
            }
        return result
    }

    public func signExtend8(_ value: Word) -> Word {
        var result = value
        result = result & 0x00ff
        result = result ^ 0x80
        result = result &- 0x80
        return result
    }

    public func signExtend16(_ value: Word) -> Word {
        var result = value
        result = result & 0xffff
        result = result ^ 0x8000
        result = result &- 0x8000
        return result
    }

    public func getRegister(p reg: RegisterPointer) throws -> UInt {
        let val = try getRegister(.p(reg))
        return val
    }

    public func getRegister(w reg: Register16) throws -> UInt16 {
        let val = try getRegister(.w(reg))
        return UInt16(val & 0xffff)
    }

    public func getRegister(b reg: Register8) throws -> UInt8 {
        let val = try getRegister(.b(reg))
        return UInt8(val & 0xff)
    }

    public func getRegister(o reg: RegisterBoolean) throws -> Bool {
        let val = try getRegister(.o(reg))
        return val != 0
    }

    public func getRegister(_ reg: Register) throws -> UInt {
        switch reg {
        case .sp,
             .fp:
            // We should have set fp and sp in init() so this ought never fail.
            return globalRegisters[reg]!

        case .ra,
             .p(_),
             .w(_),
             .b(_),
             .o:
            guard let value = registers[registers.count - 1][reg] else {
                throw TackVirtualMachineError.undefinedRegister(reg)
            }
            return value
        }
    }

    public func setRegister(_ reg: RegisterPointer, p value: UInt) {
        setRegister(.p(reg), value)
    }

    public func setRegister(_ reg: Register16, w value: UInt16) {
        setRegister(.w(reg), UInt(value))
    }

    public func setRegister(_ reg: Register8, b value: UInt8) {
        setRegister(.b(reg), UInt(value))
    }

    public func setRegister(_ reg: RegisterBoolean, o value: Bool) {
        setRegister(.o(reg), value ? 1 : 0)
    }

    public func setRegister(_ reg: Register, _ value: UInt) {
        switch reg {
        case .sp,
             .fp:
            globalRegisters[reg] = value

        case .ra,
             .p(_),
             .w(_),
             .b(_),
             .o:
            registers[registers.count - 1][reg] = value
        }
    }

    public func pushRegisters() throws {
        registers.append([:])
    }

    public func popRegisters() throws {
        guard !registers.isEmpty else {
            throw TackVirtualMachineError.underflowRegisterStack
        }
        registers.removeLast()
    }

    public func loadp(address: UInt) -> UInt {
        let val = load(address: address)
        return val
    }

    public func loadw(address: UInt) -> UInt16 {
        let val = load(address: address)
        return UInt16(val & 0xffff)
    }

    public func loadb(address: UInt) -> UInt8 {
        let val = load(address: address)
        return UInt8(val & 0xff)
    }

    public func loado(address: UInt) -> Bool {
        let val = load(address: address)
        return val != 0
    }

    public func load(address base: UInt, signedOffset: Int = 0) -> UInt {
        let address: UInt =
            if signedOffset >= 0 {
                base &+ UInt(signedOffset)
            }
            else {
                base &- UInt(-signedOffset)
            }
        let pageMask: UInt = kPageSize - 1
        let pageIndex: UInt = address & ~pageMask
        let pageOffset: UInt = address & pageMask
        if memoryPages[pageIndex] == nil {
            memoryPages[pageIndex] = [UInt](repeating: 0, count: Int(kPageSize))
        }
        let result = memoryPages[pageIndex]![Int(pageOffset)]
        return result
    }

    public func store(p val: UInt, address: UInt) {
        store(value: val, address: address)
    }

    public func store(w val: UInt16, address: UInt) {
        store(value: UInt(val), address: address)
    }

    public func store(b val: UInt8, address: UInt) {
        store(value: UInt(val), address: address)
    }

    public func store(o val: Bool, address: UInt) {
        store(value: val ? 1 : 0, address: address)
    }

    public func store(value: UInt, address base: UInt, signedOffset: Int = 0) {
        let address: UInt =
            if signedOffset >= 0 {
                base &+ UInt(signedOffset)
            }
            else {
                base &- UInt(-signedOffset)
            }
        if address == kMemoryMappedSerialOutputPort {
            let octet = UInt8(value & 0xff)
            onSerialOutput(octet)
        }
        else {
            let pageMask: UInt = kPageSize - 1
            let pageIndex: UInt = address & ~pageMask
            let pageOffset: UInt = address & pageMask
            if memoryPages[pageIndex] == nil {
                memoryPages[pageIndex] = [UInt](repeating: 0, count: Int(kPageSize))
            }
            memoryPages[pageIndex]![Int(pageOffset)] = value
        }
    }

    public func run() throws {
        var shouldStepOver = true
        while !isHalted {
            if pc < program.instructions.count, breakPoints[Int(pc)], !shouldStepOver {
                return
            }

            try step()
            shouldStepOver = false
        }
    }

    public func step() throws {
        guard pc < program.instructions.count else {
            isHalted = true
            return
        }

        nextPc = pc + 1
        let ins = program.instructions[Int(pc)]

        switch ins {
        case .nop:
            nop()
        case .hlt:
            hlt()
        case let .call(target):
            try call(target)
        case let .callptr(target):
            try callptr(target)
        case let .enter(numberOfWords):
            try enter(numberOfWords)
        case .leave:
            try leave()
        case .ret:
            try ret()
        case let .jmp(target):
            try jmp(target)
        case let .la(dst, label):
            try la(dst, label)
        case let .ststr(address, str):
            try ststr(address, str)
        case let .memcpy(dst, src, count):
            try memcpy(dst, src, count)
        case let .alloca(dst, count):
            try alloca(dst, count)
        case let .free(count):
            try free(count)
        case let .inlineAssembly(asm):
            try inlineAssembly(asm)
        case let .syscall(n, ptr):
            try syscall(n, ptr)
        case let .bz(test, target):
            try bz(test, target)
        case let .bnz(test, target):
            try bnz(test, target)
        case let .eqo(dst, left, right):
            try eqo(dst, left, right)
        case let .neo(dst, left, right):
            try neo(dst, left, right)
        case let .not(dst, src):
            try not(dst, src)
        case let .lio(dst, imm):
            try lio(dst, imm)
        case let .lo(dst, address, offset):
            try lo(dst, address, offset)
        case let .so(src, address, offset):
            try so(src, address, offset)
        case let .eqp(dst, left, right):
            try eqp(dst, left, right)
        case let .nep(dst, left, right):
            try nep(dst, left, right)
        case let .lip(dst, imm):
            try lip(dst, imm)
        case let .addip(dst, left, right):
            try addip(dst, left, right)
        case let .subip(dst, left, right):
            try subip(dst, left, right)
        case let .addpw(dst, left, right):
            try addpw(dst, left, right)
        case let .lp(dst, address, offset):
            try lp(dst, address, offset)
        case let .sp(src, address, offset):
            try sp(src, address, offset)
        case let .lw(dst, address, offset):
            try lw(dst, address, offset)
        case let .sw(src, address, offset):
            try sw(src, address, offset)
        case let .bzw(test, target):
            try bzw(test, target)
        case let .andiw(dst, left, right):
            try andiw(dst, left, right)
        case let .addiw(dst, left, right):
            try addiw(dst, left, right)
        case let .subiw(dst, left, right):
            try subiw(dst, left, right)
        case let .muliw(dst, left, right):
            try muliw(dst, left, right)
        case let .liw(dst, imm):
            try liw(dst, imm)
        case let .liuw(dst, imm):
            try liuw(dst, imm)
        case let .andw(dst, left, right):
            try andw(dst, left, right)
        case let .orw(dst, left, right):
            try orw(dst, left, right)
        case let .xorw(dst, left, right):
            try xorw(dst, left, right)
        case let .negw(dst, src):
            try negw(dst, src)
        case let .addw(dst, left, right):
            try addw(dst, left, right)
        case let .subw(dst, left, right):
            try subw(dst, left, right)
        case let .mulw(dst, left, right):
            try mulw(dst, left, right)
        case let .divw(dst, left, right):
            try divw(dst, left, right)
        case let .divuw(dst, left, right):
            try divuw(dst, left, right)
        case let .modw(dst, left, right):
            try mod16(dst, left, right)
        case let .lslw(dst, left, right):
            try lslw(dst, left, right)
        case let .lsrw(dst, left, right):
            try lsrw(dst, left, right)
        case let .eqw(dst, left, right):
            try eqw(dst, left, right)
        case let .new(dst, left, right):
            try new(dst, left, right)
        case let .ltw(dst, left, right):
            try ltw(dst, left, right)
        case let .gew(dst, left, right):
            try gew(dst, left, right)
        case let .lew(dst, left, right):
            try lew(dst, left, right)
        case let .gtw(dst, left, right):
            try gtw(dst, left, right)
        case let .ltuw(dst, left, right):
            try ltuw(dst, left, right)
        case let .geuw(dst, left, right):
            try geuw(dst, left, right)
        case let .leuw(dst, left, right):
            try leuw(dst, left, right)
        case let .gtuw(dst, left, right):
            try gtuw(dst, left, right)
        case let .lb(dst, address, offset):
            try lb(dst, address, offset)
        case let .sb(src, address, offset):
            try sb(src, address, offset)
        case let .lib(dst, imm):
            try li8(dst, imm)
        case let .liub(dst, imm):
            try liu8(dst, imm)
        case let .andb(dst, left, right):
            try and8(dst, left, right)
        case let .orb(dst, left, right):
            try or8(dst, left, right)
        case let .xorb(dst, left, right):
            try xor8(dst, left, right)
        case let .negb(dst, src):
            try neg8(dst, src)
        case let .addb(dst, left, right):
            try add8(dst, left, right)
        case let .subb(dst, left, right):
            try sub8(dst, left, right)
        case let .mulb(dst, left, right):
            try mul8(dst, left, right)
        case let .divb(dst, left, right):
            try divb(dst, left, right)
        case let .divub(dst, left, right):
            try divub(dst, left, right)
        case let .modb(dst, left, right):
            try mod8(dst, left, right)
        case let .lslb(dst, left, right):
            try lsl8(dst, left, right)
        case let .lsrb(dst, left, right):
            try lsr8(dst, left, right)
        case let .eqb(dst, left, right):
            try eq8(dst, left, right)
        case let .neb(dst, left, right):
            try ne8(dst, left, right)
        case let .ltb(dst, left, right):
            try lt8(dst, left, right)
        case let .geb(dst, left, right):
            try ge8(dst, left, right)
        case let .leb(dst, left, right):
            try le8(dst, left, right)
        case let .gtb(dst, left, right):
            try gt8(dst, left, right)
        case let .ltub(dst, left, right):
            try ltu8(dst, left, right)
        case let .geub(dst, left, right):
            try geu8(dst, left, right)
        case let .leub(dst, left, right):
            try leu8(dst, left, right)
        case let .gtub(dst, left, right):
            try gtu8(dst, left, right)
        case let .movsbw(dst, src):
            try movsbw(dst, src)
        case let .movswb(dst, src):
            try movswb(dst, src)
        case let .movzwb(dst, src):
            try movzwb(dst, src)
        case let .movzbw(dst, src):
            try movzbw(dst, src)
        case let .movp(dst, src):
            try bitcast(.p(dst), .p(src))
        case let .movw(dst, src):
            try bitcast(.w(dst), .w(src))
        case let .movb(dst, src):
            try bitcast(.b(dst), .b(src))
        case let .movo(dst, src):
            try bitcast(.o(dst), .o(src))
        case let .bitcast(dst, src):
            try bitcast(dst, src)
        }

        if !isHalted {
            pc = nextPc
        }

        if pc >= program.instructions.count {
            isHalted = true
        }
    }

    private func nop() {
        // nothing to do
    }

    private func hlt() {
        isHalted = true
    }

    private func call(_ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        setRegister(.ra, p: nextPc)
        nextPc = UInt(destination)
    }

    private func callptr(_ target: RegisterPointer) throws {
        let destination = try getRegister(p: target)
        setRegister(.ra, p: nextPc)
        nextPc = destination
    }

    let kSizeOfSavedRegisters: UInt =
        7 // TODO: The size of this register save-area needs to be machine-specific. Different targets will need different sizes.

    private func enter(_ numberOfWords: Int) throws {
        guard numberOfWords >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }

        try pushRegisters()
        let fp = try getRegister(p: .fp)
        var sp = try getRegister(p: .sp)
        sp = sp &- kSizeOfSavedRegisters
        store(p: fp, address: sp)
        setRegister(.fp, p: sp)
        sp = sp &- UInt(numberOfWords)
        setRegister(.sp, p: sp)
    }

    private func leave() throws {
        let fp = try getRegister(p: .fp)
        var sp = fp
        setRegister(.fp, p: loadp(address: sp))
        sp = sp &+ kSizeOfSavedRegisters
        setRegister(.sp, p: sp)
        try popRegisters()
    }

    private func ret() throws {
        nextPc = try getRegister(p: .ra)
    }

    private func jmp(_ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        nextPc = UInt(destination)
    }

    private func la(_ dst: RegisterPointer, _ label: String) throws {
        guard let value = program.labels[label] else {
            throw TackVirtualMachineError.undefinedLabel(label)
        }
        setRegister(dst, p: UInt(value))
    }

    private func bz(_ test: RegisterBoolean, _ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        if try getRegister(o: test) == false {
            nextPc = UInt(destination)
        }
    }

    private func bzw(_ test: Register16, _ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        if try getRegister(w: test) == 0 {
            nextPc = UInt(destination)
        }
    }

    private func bnz(_ test: RegisterBoolean, _ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        if try getRegister(o: test) == true {
            nextPc = UInt(destination)
        }
    }

    private func lp(_ dst: RegisterPointer, _ address: RegisterPointer, _ signedOffset: Int) throws
    {
        let base = try getRegister(.p(address))
        let value = load(address: base, signedOffset: signedOffset)
        setRegister(.p(dst), value)
    }

    private func lw(_ dst: Register16, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let base = try getRegister(.p(address))
        let value = load(address: base, signedOffset: signedOffset)
        setRegister(.w(dst), value)
    }

    private func lb(_ dst: Register8, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let base = try getRegister(.p(address))
        let value = load(address: base, signedOffset: signedOffset)
        setRegister(.b(dst), value)
    }

    private func lo(_ dst: RegisterBoolean, _ address: RegisterPointer, _ signedOffset: Int) throws
    {
        let base = try getRegister(.p(address))
        let value = load(address: base, signedOffset: signedOffset)
        setRegister(.o(dst), value)
    }

    private func sp(_ src: RegisterPointer, _ address: RegisterPointer, _ signedOffset: Int) throws
    {
        let addressToAccess = try getRegister(.p(address))
        let value = try getRegister(.p(src))
        store(value: value, address: addressToAccess, signedOffset: signedOffset)
    }

    private func sw(_ src: Register16, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let addressToAccess = try getRegister(.p(address))
        let value = try getRegister(.w(src))
        store(value: value, address: addressToAccess, signedOffset: signedOffset)
    }

    private func sb(_ src: Register8, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let addressToAccess = try getRegister(.p(address))
        let value = try getRegister(.b(src))
        store(value: value, address: addressToAccess, signedOffset: signedOffset)
    }

    private func so(_ src: RegisterBoolean, _ address: RegisterPointer, _ signedOffset: Int) throws
    {
        let addressToAccess = try getRegister(.p(address))
        let value = try getRegister(.o(src))
        store(value: value, address: addressToAccess, signedOffset: signedOffset)
    }

    private func ststr(_ addressRegister: RegisterPointer, _ str: String) throws {
        var address = try getRegister(p: addressRegister)
        for character in str.utf8 {
            store(b: character, address: address)
            address = address &+ 1
        }
    }

    private func memcpy(
        _ dstRegister: RegisterPointer,
        _ srcRegister: RegisterPointer,
        _ count: Int
    ) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }

        var dst = try getRegister(p: dstRegister)
        var src = try getRegister(p: srcRegister)
        for _ in 0..<count {
            let word = load(address: src)
            store(value: word, address: dst)
            src = src &+ 1
            dst = dst &+ 1
        }
    }

    private func alloca(_ dst: RegisterPointer, _ count: Int) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }

        var sp = try getRegister(p: .sp)
        sp = sp &- UInt(count)
        setRegister(.sp, p: sp)
        setRegister(dst, p: sp)
    }

    private func free(_ count: Int) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }

        var sp = try getRegister(p: .sp)
        sp = sp &+ UInt(count)
        setRegister(.sp, p: sp)
    }

    private func not(_ dst: RegisterBoolean, _ src: RegisterBoolean) throws {
        var r = try getRegister(o: src)
        r = !r
        setRegister(dst, o: r)
    }

    private func andiw(_ dst: Register16, _ left: Register16, _ right: Int) throws {
        guard right >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        var r = try getRegister(w: left)
        r = r & Word(right)
        setRegister(dst, w: r)
    }

    private func addiw(_ dst: Register16, _ left: Register16, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(w: left)
        r = signExtend16(r &+ right)
        setRegister(dst, w: r)
    }

    private func subiw(_ dst: Register16, _ left: Register16, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(w: left)
        r = signExtend16(r &- right)
        setRegister(dst, w: r)
    }

    private func muliw(_ dst: Register16, _ left: Register16, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(w: left)
        r = signExtend16(r &* right)
        setRegister(dst, w: r)
    }

    private func lio(_ dst: RegisterBoolean, _ imm: Bool) throws {
        setRegister(dst, o: imm)
    }

    private func liw(_ dst: Register16, _ imm_: Int) throws {
        guard imm_ >= Int16.min, imm_ <= Int16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToWord(imm_)
        setRegister(dst, w: imm)
    }

    private func lip(_ dst: RegisterPointer, _ imm: Int) throws {
        guard imm >= 0, imm <= UInt16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(dst, p: UInt(imm))
    }

    private func liuw(_ dst: Register16, _ imm: Int) throws {
        guard imm >= 0, imm <= UInt16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(dst, w: UInt16(imm))
    }

    private func andw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = left & right
        setRegister(dst, w: result)
    }

    private func orw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = left | right
        setRegister(dst, w: result)
    }

    private func xorw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = left ^ right
        setRegister(dst, w: result)
    }

    private func negw(_ dst: Register16, _ srcRegister: Register16) throws {
        let src = try getRegister(w: srcRegister)
        let result = ~src
        setRegister(dst, w: result)
    }

    private func addpw(
        _ dst: RegisterPointer,
        _ leftRegister: RegisterPointer,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(p: leftRegister)
        let right = try UInt(getRegister(w: rightRegister))
        let result = left &+ right
        setRegister(dst, p: result)
    }

    private func addw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = signExtend16(left &+ right)
        setRegister(dst, w: result)
    }

    private func subw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = signExtend16(left &- right)
        setRegister(dst, w: result)
    }

    private func mulw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = signExtend16(left &* right)
        setRegister(dst, w: result)
    }

    private func divw(
        _ result_: Register16,
        _ numerator_: Register16,
        _ denominator_: Register16
    ) throws {
        let numerator = try wordToInt(getRegister(w: numerator_))
        let denominator = try wordToInt(getRegister(w: denominator_))
        guard denominator != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = intToWord(numerator / denominator)
        setRegister(result_, w: result)
    }

    private func divuw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend16(left / right)
        setRegister(dst, w: result)
    }

    private func mod16(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend16(left % right)
        setRegister(dst, w: result)
    }

    private func lslw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left << right)
        setRegister(dst, w: result)
    }

    private func lsrw(
        _ dst: Register16,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left >> right)
        setRegister(dst, w: result)
    }

    private func eqp(
        _ dst: RegisterBoolean,
        _ leftRegister: RegisterPointer,
        _ rightRegister: RegisterPointer
    ) throws {
        let left = try getRegister(p: leftRegister)
        let right = try getRegister(p: rightRegister)
        let result = (left == right)
        setRegister(dst, o: result)
    }

    private func nep(
        _ dst: RegisterBoolean,
        _ leftRegister: RegisterPointer,
        _ rightRegister: RegisterPointer
    ) throws {
        let left = try getRegister(p: leftRegister)
        let right = try getRegister(p: rightRegister)
        let result = (left != right)
        setRegister(dst, o: result)
    }

    private func eqo(
        _ dst: RegisterBoolean,
        _ leftRegister: RegisterBoolean,
        _ rightRegister: RegisterBoolean
    ) throws {
        let left = try getRegister(o: leftRegister)
        let right = try getRegister(o: rightRegister)
        let result = (left == right)
        setRegister(dst, o: result)
    }

    private func neo(
        _ dst: RegisterBoolean,
        _ leftRegister: RegisterBoolean,
        _ rightRegister: RegisterBoolean
    ) throws {
        let left = try getRegister(o: leftRegister)
        let right = try getRegister(o: rightRegister)
        let result = (left != right)
        setRegister(dst, o: result)
    }

    private func eqw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left == right)
        setRegister(dst, o: result)
    }

    private func new(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left != right)
        setRegister(dst, o: result)
    }

    private func ltw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try wordToInt(signExtend16(getRegister(w: leftRegister)))
        let right = try wordToInt(signExtend16(getRegister(w: rightRegister)))
        let result = (left < right)
        setRegister(dst, o: result)
    }

    private func gew(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try wordToInt(signExtend16(getRegister(w: leftRegister)))
        let right = try wordToInt(signExtend16(getRegister(w: rightRegister)))
        let result = (left >= right)
        setRegister(dst, o: result)
    }

    private func lew(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try wordToInt(signExtend16(getRegister(w: leftRegister)))
        let right = try wordToInt(signExtend16(getRegister(w: rightRegister)))
        let result = (left <= right)
        setRegister(dst, o: result)
    }

    private func gtw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try wordToInt(signExtend16(getRegister(w: leftRegister)))
        let right = try wordToInt(signExtend16(getRegister(w: rightRegister)))
        let result = (left > right)
        setRegister(dst, o: result)
    }

    private func ltuw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left < right)
        setRegister(dst, o: result)
    }

    private func geuw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left >= right)
        setRegister(dst, o: result)
    }

    private func leuw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left <= right)
        setRegister(dst, o: result)
    }

    private func gtuw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = try getRegister(w: leftRegister)
        let right = try getRegister(w: rightRegister)
        let result = (left > right)
        setRegister(dst, o: result)
    }

    private func li8(_ dst: Register8, _ imm_: Int) throws {
        guard imm_ >= Int8.min, imm_ <= Int8.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToUInt8(imm_)
        setRegister(dst, b: imm)
    }

    private func liu8(_ dst: Register8, _ imm: Int) throws {
        guard imm >= 0, imm <= UInt8.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(dst, b: UInt8(imm))
    }

    private func and8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = UInt8((left & right) & 0xff)
        setRegister(dst, b: result)
    }

    private func or8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws
    {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = UInt8((left | right) & 0xff)
        setRegister(dst, b: result)
    }

    private func xor8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = UInt8((left ^ right) & 0xff)
        setRegister(dst, b: result)
    }

    private func neg8(_ dst: Register8, _ srcRegister: Register8) throws {
        let src = try getRegister(b: srcRegister)
        let result = UInt8((~src) & 0xff)
        setRegister(dst, b: result)
    }

    private func add8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left &+ right)
        setRegister(dst, b: result)
    }

    private func sub8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left &- right)
        setRegister(dst, b: result)
    }

    private func mul8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left &* right)
        setRegister(dst, b: result)
    }

    private func divb(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let numerator = try uint8ToInt(getRegister(b: leftRegister))
        let denominator = try uint8ToInt(getRegister(b: rightRegister))
        guard denominator != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = intToUInt8(numerator / denominator)
        setRegister(dst, b: result)
    }

    private func divub(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = (left / right)
        setRegister(dst, b: result)
    }

    private func mod8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = (left % right)
        setRegister(dst, b: result)
    }

    private func lsl8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister) & 0xff
        let right = try getRegister(b: rightRegister) & 0xff
        let result = (left << right) & 0xff
        setRegister(dst, b: result)
    }

    private func lsr8(
        _ dst: Register8,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister) & 0xff
        let right = try getRegister(b: rightRegister) & 0xff
        let result = (left >> right) & 0xff
        setRegister(dst, b: result)
    }

    private func eq8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left == right)
        setRegister(dst, o: result)
    }

    private func ne8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left != right)
        setRegister(dst, o: result)
    }

    private func lt8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try wordToInt(signExtend8(Word(getRegister(b: leftRegister))))
        let right = try wordToInt(signExtend8(Word(getRegister(b: rightRegister))))
        let result = (left < right)
        setRegister(dst, o: result)
    }

    private func ge8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try wordToInt(signExtend8(Word(getRegister(b: leftRegister))))
        let right = try wordToInt(signExtend8(Word(getRegister(b: rightRegister))))
        let result = (left >= right)
        setRegister(dst, o: result)
    }

    private func le8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try wordToInt(signExtend8(Word(getRegister(b: leftRegister))))
        let right = try wordToInt(signExtend8(Word(getRegister(b: rightRegister))))
        let result = (left <= right)
        setRegister(dst, o: result)
    }

    private func gt8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try wordToInt(signExtend8(Word(getRegister(b: leftRegister))))
        let right = try wordToInt(signExtend8(Word(getRegister(b: rightRegister))))
        let result = (left > right)
        setRegister(dst, o: result)
    }

    private func ltu8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left < right)
        setRegister(dst, o: result)
    }

    private func geu8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left >= right)
        setRegister(dst, o: result)
    }

    private func leu8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left <= right)
        setRegister(dst, o: result)
    }

    private func gtu8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = try getRegister(b: leftRegister)
        let right = try getRegister(b: rightRegister)
        let result = (left > right)
        setRegister(dst, o: result)
    }

    private func movsbw(_ dst: Register8, _ srcRegister: Register16) throws {
        let src = try getRegister(w: srcRegister)
        let result = UInt8(src & 0xff)
        setRegister(dst, b: result)
    }

    private func movswb(_ dst: Register16, _ srcRegister: Register8) throws {
        let src = try getRegister(b: srcRegister)
        let result = signExtend8(UInt16(src))
        setRegister(dst, w: result)
    }

    private func movzwb(_ dst: Register16, _ srcRegister: Register8) throws {
        let src = try getRegister(b: srcRegister)
        let result = UInt16(src)
        setRegister(dst, w: result)
    }

    private func movzbw(_ dst: Register8, _ srcRegister: Register16) throws {
        let src = try getRegister(w: srcRegister)
        let result = UInt8(src & 0x00ff)
        setRegister(dst, b: result)
    }

    private func bitcast(_ dst: Register, _ src: Register) throws {
        try setRegister(dst, getRegister(src))
    }

    private func inlineAssembly(_ asm: String) throws {
        switch asm {
        case "HLT":
            hlt()

        case "SYSCALL":
            try addip(.p(0), .fp, 8) // syscall number
            try addip(.p(1), .fp, 7) // pointer to argument struct
            try syscall(.p(0), .p(1))

        case "BREAK":
            if nextPc < breakPoints.count {
                breakPoints[Int(nextPc)] = true
            }

        default:
            throw TackVirtualMachineError.inlineAssemblyNotSupported
        }
    }

    private func syscall(_ n_: RegisterPointer, _ ptr_: RegisterPointer) throws {
        let n = try loadp(address: getRegister(p: n_))
        let ptr = try loadp(address: getRegister(p: ptr_))

        switch Syscall(rawValue: Int(n)) {
        case .invalid,
             .none:
            try breakPoint()

        case .getc:
            getc(ptr)

        case .putc:
            putc(ptr)
        }
    }

    private func breakPoint() throws {
        try inlineAssembly("BREAK")
    }

    private func getc(_ ptr: UInt) {
        let octet = onSerialInput()
        store(b: octet, address: ptr)
    }

    private func putc(_ ptr: UInt) {
        let octet = loadb(address: ptr)
        onSerialOutput(octet)
    }

    private func addip(_ dst: RegisterPointer, _ left_: RegisterPointer, _ right: Int) throws {
        let left = try getRegister(p: left_)
        let result: UInt =
            if right >= 0 {
                left &+ UInt(right)
            }
            else {
                left &- UInt(-right)
            }
        setRegister(dst, p: result)
    }

    private func subip(_ dst: RegisterPointer, _ left_: RegisterPointer, _ right: Int) throws {
        let left = try getRegister(p: left_)
        let result: UInt =
            if right >= 0 {
                left &- UInt(right)
            }
            else {
                left &+ UInt(-right)
            }
        setRegister(dst, p: result)
    }
}
