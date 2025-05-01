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
        while i >= 0 && result == nil {
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
        while i >= 0 && result == nil {
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
        let result: Int
        if word > (Word.max >> 1) {
            result = -Int(~word + 1)
        }
        else {
            result = Int(word)
        }
        return result
    }

    public func intToWord(_ value: Int) -> Word {
        assert(value >= Int16.min && value <= Int16.max)
        let result: Word
        if value < 0 {
            result = Word(0) &- Word(-value)
        }
        else {
            result = Word(value)
        }
        return result
    }

    public func uint8ToInt(_ u8: UInt8) -> Int {
        let result: Int
        if u8 > (UInt8.max >> 1) {
            result = -Int(~u8 + 1)
        }
        else {
            result = Int(u8)
        }
        return result
    }

    public func intToUInt8(_ value: Int) -> UInt8 {
        assert(value >= Int8.min && value <= Int8.max)
        let result: UInt8
        if value < 0 {
            result = UInt8(0) &- UInt8(-value)
        }
        else {
            result = UInt8(value)
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
        case .sp, .fp:
            // We should have set fp and sp in init() so this ought never fail.
            return globalRegisters[reg]!

        case .ra, .p(_), .w(_), .b(_), .o(_):
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
        case .sp, .fp:
            globalRegisters[reg] = value

        case .ra, .p(_), .w(_), .b(_), .o(_):
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
        let address: UInt
        if signedOffset >= 0 {
            address = base &+ UInt(signedOffset)
        }
        else {
            address = base &- UInt(-signedOffset)
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
        let address: UInt
        if signedOffset >= 0 {
            address = base &+ UInt(signedOffset)
        }
        else {
            address = base &- UInt(-signedOffset)
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
            if pc < program.instructions.count && breakPoints[Int(pc)] && !shouldStepOver {
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
        case .call(let target):
            try call(target)
        case .callptr(let target):
            try callptr(target)
        case .enter(let numberOfWords):
            try enter(numberOfWords)
        case .leave:
            try leave()
        case .ret:
            try ret()
        case .jmp(let target):
            try jmp(target)
        case .la(let dst, let label):
            try la(dst, label)
        case .ststr(let address, let str):
            try ststr(address, str)
        case .memcpy(let dst, let src, let count):
            try memcpy(dst, src, count)
        case .alloca(let dst, let count):
            try alloca(dst, count)
        case .free(let count):
            try free(count)
        case .inlineAssembly(let asm):
            try inlineAssembly(asm)
        case .syscall(let n, let ptr):
            try syscall(n, ptr)

        case .bz(let test, let target):
            try bz(test, target)
        case .bnz(let test, let target):
            try bnz(test, target)
        case .eqo(let dst, let left, let right):
            try eqo(dst, left, right)
        case .neo(let dst, let left, let right):
            try neo(dst, left, right)
        case .not(let dst, let src):
            try not(dst, src)
        case .lio(let dst, let imm):
            try lio(dst, imm)
        case .lo(let dst, let address, let offset):
            try lo(dst, address, offset)
        case .so(let src, let address, let offset):
            try so(src, address, offset)

        case .eqp(let dst, let left, let right):
            try eqp(dst, left, right)
        case .nep(let dst, let left, let right):
            try nep(dst, left, right)
        case .lip(let dst, let imm):
            try lip(dst, imm)
        case .addip(let dst, let left, let right):
            try addip(dst, left, right)
        case .subip(let dst, let left, let right):
            try subip(dst, left, right)
        case .addpw(let dst, let left, let right):
            try addpw(dst, left, right)
        case .lp(let dst, let address, let offset):
            try lp(dst, address, offset)
        case .sp(let src, let address, let offset):
            try sp(src, address, offset)

        case .lw(let dst, let address, let offset):
            try lw(dst, address, offset)
        case .sw(let src, let address, let offset):
            try sw(src, address, offset)
        case .bzw(let test, let target):
            try bzw(test, target)
        case .andiw(let dst, let left, let right):
            try andiw(dst, left, right)
        case .addiw(let dst, let left, let right):
            try addiw(dst, left, right)
        case .subiw(let dst, let left, let right):
            try subiw(dst, left, right)
        case .muliw(let dst, let left, let right):
            try muliw(dst, left, right)
        case .liw(let dst, let imm):
            try liw(dst, imm)
        case .liuw(let dst, let imm):
            try liuw(dst, imm)
        case .andw(let dst, let left, let right):
            try andw(dst, left, right)
        case .orw(let dst, let left, let right):
            try orw(dst, left, right)
        case .xorw(let dst, let left, let right):
            try xorw(dst, left, right)
        case .negw(let dst, let src):
            try negw(dst, src)
        case .addw(let dst, let left, let right):
            try addw(dst, left, right)
        case .subw(let dst, let left, let right):
            try subw(dst, left, right)
        case .mulw(let dst, let left, let right):
            try mulw(dst, left, right)
        case .divw(let dst, let left, let right):
            try divw(dst, left, right)
        case .divuw(let dst, let left, let right):
            try divuw(dst, left, right)
        case .modw(let dst, let left, let right):
            try mod16(dst, left, right)
        case .lslw(let dst, let left, let right):
            try lslw(dst, left, right)
        case .lsrw(let dst, let left, let right):
            try lsrw(dst, left, right)
        case .eqw(let dst, let left, let right):
            try eqw(dst, left, right)
        case .new(let dst, let left, let right):
            try new(dst, left, right)
        case .ltw(let dst, let left, let right):
            try ltw(dst, left, right)
        case .gew(let dst, let left, let right):
            try gew(dst, left, right)
        case .lew(let dst, let left, let right):
            try lew(dst, left, right)
        case .gtw(let dst, let left, let right):
            try gtw(dst, left, right)
        case .ltuw(let dst, let left, let right):
            try ltuw(dst, left, right)
        case .geuw(let dst, let left, let right):
            try geuw(dst, left, right)
        case .leuw(let dst, let left, let right):
            try leuw(dst, left, right)
        case .gtuw(let dst, let left, let right):
            try gtuw(dst, left, right)

        case .lb(let dst, let address, let offset):
            try lb(dst, address, offset)
        case .sb(let src, let address, let offset):
            try sb(src, address, offset)
        case .lib(let dst, let imm):
            try li8(dst, imm)
        case .liub(let dst, let imm):
            try liu8(dst, imm)
        case .andb(let dst, let left, let right):
            try and8(dst, left, right)
        case .orb(let dst, let left, let right):
            try or8(dst, left, right)
        case .xorb(let dst, let left, let right):
            try xor8(dst, left, right)
        case .negb(let dst, let src):
            try neg8(dst, src)
        case .addb(let dst, let left, let right):
            try add8(dst, left, right)
        case .subb(let dst, let left, let right):
            try sub8(dst, left, right)
        case .mulb(let dst, let left, let right):
            try mul8(dst, left, right)
        case .divb(let dst, let left, let right):
            try divb(dst, left, right)
        case .divub(let dst, let left, let right):
            try divub(dst, left, right)
        case .modb(let dst, let left, let right):
            try mod8(dst, left, right)
        case .lslb(let dst, let left, let right):
            try lsl8(dst, left, right)
        case .lsrb(let dst, let left, let right):
            try lsr8(dst, left, right)
        case .eqb(let dst, let left, let right):
            try eq8(dst, left, right)
        case .neb(let dst, let left, let right):
            try ne8(dst, left, right)
        case .ltb(let dst, let left, let right):
            try lt8(dst, left, right)
        case .geb(let dst, let left, let right):
            try ge8(dst, left, right)
        case .leb(let dst, let left, let right):
            try le8(dst, left, right)
        case .gtb(let dst, let left, let right):
            try gt8(dst, left, right)
        case .ltub(let dst, let left, let right):
            try ltu8(dst, left, right)
        case .geub(let dst, let left, let right):
            try geu8(dst, left, right)
        case .leub(let dst, let left, let right):
            try leu8(dst, left, right)
        case .gtub(let dst, let left, let right):
            try gtu8(dst, left, right)
        case .movsbw(let dst, let src):
            try movsbw(dst, src)
        case .movswb(let dst, let src):
            try movswb(dst, src)
        case .movzwb(let dst, let src):
            try movzwb(dst, src)
        case .movzbw(let dst, let src):
            try movzbw(dst, src)
        case .bitcast(let dst, let src):
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

    let kSizeOfSavedRegisters: UInt = 7  // TODO: The size of this register save-area needs to be machine-specific. Different targets will need different sizes.

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
        guard imm_ >= Int16.min && imm_ <= Int16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToWord(imm_)
        setRegister(dst, w: imm)
    }

    private func lip(_ dst: RegisterPointer, _ imm: Int) throws {
        guard imm >= 0 && imm <= UInt16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(dst, p: UInt(imm))
    }

    private func liuw(_ dst: Register16, _ imm: Int) throws {
        guard imm >= 0 && imm <= UInt16.max else {
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
        let right = UInt(try getRegister(w: rightRegister))
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
        let numerator = wordToInt(try getRegister(w: numerator_))
        let denominator = wordToInt(try getRegister(w: denominator_))
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
        let left = wordToInt(signExtend16(try getRegister(w: leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(w: rightRegister)))
        let result = (left < right)
        setRegister(dst, o: result)
    }

    private func gew(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = wordToInt(signExtend16(try getRegister(w: leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(w: rightRegister)))
        let result = (left >= right)
        setRegister(dst, o: result)
    }

    private func lew(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = wordToInt(signExtend16(try getRegister(w: leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(w: rightRegister)))
        let result = (left <= right)
        setRegister(dst, o: result)
    }

    private func gtw(
        _ dst: RegisterBoolean,
        _ leftRegister: Register16,
        _ rightRegister: Register16
    ) throws {
        let left = wordToInt(signExtend16(try getRegister(w: leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(w: rightRegister)))
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
        guard imm_ >= Int8.min && imm_ <= Int8.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToUInt8(imm_)
        setRegister(dst, b: imm)
    }

    private func liu8(_ dst: Register8, _ imm: Int) throws {
        guard imm >= 0 && imm <= UInt8.max else {
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
        let numerator = uint8ToInt(try getRegister(b: leftRegister))
        let denominator = uint8ToInt(try getRegister(b: rightRegister))
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
        let left = wordToInt(signExtend8(Word(try getRegister(b: leftRegister))))
        let right = wordToInt(signExtend8(Word(try getRegister(b: rightRegister))))
        let result = (left < right)
        setRegister(dst, o: result)
    }

    private func ge8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = wordToInt(signExtend8(Word(try getRegister(b: leftRegister))))
        let right = wordToInt(signExtend8(Word(try getRegister(b: rightRegister))))
        let result = (left >= right)
        setRegister(dst, o: result)
    }

    private func le8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = wordToInt(signExtend8(Word(try getRegister(b: leftRegister))))
        let right = wordToInt(signExtend8(Word(try getRegister(b: rightRegister))))
        let result = (left <= right)
        setRegister(dst, o: result)
    }

    private func gt8(
        _ dst: RegisterBoolean,
        _ leftRegister: Register8,
        _ rightRegister: Register8
    ) throws {
        let left = wordToInt(signExtend8(Word(try getRegister(b: leftRegister))))
        let right = wordToInt(signExtend8(Word(try getRegister(b: rightRegister))))
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
        setRegister(dst, try getRegister(src))
    }

    private func inlineAssembly(_ asm: String) throws {
        switch asm {
        case "HLT":
            hlt()

        case "SYSCALL":
            try addip(.p(0), .fp, 8)  // syscall number
            try addip(.p(1), .fp, 7)  // pointer to argument struct
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
        let n = loadp(address: try getRegister(p: n_))
        let ptr = loadp(address: try getRegister(p: ptr_))

        switch Syscall(rawValue: Int(n)) {
        case .invalid, .none:
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
        let result: UInt
        if right >= 0 {
            result = left &+ UInt(right)
        }
        else {
            result = left &- UInt(-right)
        }
        setRegister(dst, p: result)
    }

    private func subip(_ dst: RegisterPointer, _ left_: RegisterPointer, _ right: Int) throws {
        let left = try getRegister(p: left_)
        let result: UInt
        if right >= 0 {
            result = left &- UInt(right)
        }
        else {
            result = left &+ UInt(-right)
        }
        setRegister(dst, p: result)
    }
}
