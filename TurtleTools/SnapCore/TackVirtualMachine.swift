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

public class TackVirtualMachine: NSObject {
    public typealias Register = TackInstruction.Register
    public typealias RegisterPointer = TackInstruction.RegisterPointer
    public typealias RegisterBoolean = TackInstruction.RegisterPointer
    public typealias Register16 = TackInstruction.Register16
    public typealias Register8 = TackInstruction.Register8
    public typealias Word = UInt16
    
    public let kMemoryMappedSerialOutputPort: Word = 0x0001
    public let kPageSize = 4096
    
    public let program: TackProgram
    public var pc: Word = 0
    public var nextPc: Word = 0
    public var isHalted = false
    private var globalRegisters: [Register : Word] = [:]
    public var registers: [[Register : Word]] = [[:]]
    private var memoryPages: [Int : [Word]] = [:]
    private var breakPoints: [Bool]
    public var onSerialOutput: (Word) -> Void = {_ in}
    public var onSerialInput: () -> Word = { 0 }
    
    public enum Syscall: Int {
        case invalid
        case getc
        case putc
    }
    
    public var backtrace: [Word] {
        var result: [Word] = []
        for currentRegisterSet in registers {
            guard let ra = currentRegisterSet[.ra] else {
                break
            }
            result.append(ra)
        }
        result.append(pc)
        return result
    }
    
    public var symbols: SymbolTable? {
        var result: SymbolTable? = nil
        var i = Int(pc)
        while i >= 0 && result == nil {
            if i < program.symbols.count {
                result = program.symbols[i]
            }
            i = i - 1
            
        }
        return result
    }
    
    public func findSourceAnchor(pc pc_: Word) -> SourceAnchor? {
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
        breakPoints = Array<Bool>(repeating: false, count: program.instructions.count)
        super.init()
        setRegister(.w(.sp), 0)
        setRegister(.w(.fp), 0)
    }
    
    public func setBreakPoint(pc: Word, value: Bool) {
        assert(pc >= 0 && pc < program.instructions.count)
        breakPoints[Int(pc)] = value
    }
    
    public func isBreakPoint(pc: Word) -> Bool {
        assert(pc >= 0 && pc < program.instructions.count)
        return breakPoints[Int(pc)]
    }
    
    public func wordToInt(_ word: Word) -> Int {
        let result: Int
        if word > (Word.max>>1) {
            result = -(Int(Word.max) - Int(word))
        }
        else {
            result = Int(word)
        }
        return result
    }
    
    public func intToWord(_ value: Int) -> Word {
        let result: Word
        if value < 0 {
            result = Word(0) &- Word(-value)
        }
        else {
            result = Word(value)
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
    
    public func getRegister(_ reg: Register) throws -> Word {
        switch reg {
        case .sp, .fp:
            // We should have set fp and sp in init() so this ought never fail.
            return globalRegisters[reg]!
            
        case .ra, .w(_), .b(_):
            guard let value = registers[registers.count-1][reg] else {
                throw TackVirtualMachineError.undefinedRegister(reg)
            }
            return value
        }
    }
    
    public func setRegister(_ reg: Register, _ value: Word) {
        switch reg {
        case .sp, .fp:
            globalRegisters[reg] = value
            
        case .ra, .w(_), .b(_):
            registers[registers.count-1][reg] = value
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
    
    public func load(address address_: Word) -> Word {
        let address = Int(address_)
        let pageMask = kPageSize-1
        let pageIndex = address & ~pageMask
        let pageOffset = address & pageMask
        if memoryPages[pageIndex] == nil {
            memoryPages[pageIndex] = Array<Word>(repeating: 0, count: kPageSize)
        }
        let result = memoryPages[pageIndex]![pageOffset]
        return result
    }
    
    public func store(value: Word, address address_: Word) {
        let address = Int(address_)
        if address == kMemoryMappedSerialOutputPort {
            onSerialOutput(value)
        }
        else {
            let pageMask = kPageSize-1
            let pageIndex = address & ~pageMask
            let pageOffset = address & pageMask
            if memoryPages[pageIndex] == nil {
                memoryPages[pageIndex] = Array<Word>(repeating: 0, count: kPageSize)
            }
            memoryPages[pageIndex]![pageOffset] = value
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
            
        case .lw(let dst, let address, let offset):
            try lw(dst, address, offset)
        case .sw(let src, let address, let offset):
            try sw(src, address, offset)
        case .andiw(let dst, let left, let right):
            try andiw(dst, left, right)
        case .addiw(let dst, let left, let right):
            try addiw(dst, left, right)
        case .subiw(let dst, let left, let right):
            try subiw(dst, left, right)
        case .mulib(let dst, let left, let right):
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
        case .notw(let dst, let src):
            try notw(dst, src)
        case .addw(let dst, let left, let right):
            try addw(dst, left, right)
        case .subw(let dst, let left, let right):
            try subw(dst, left, right)
        case .mulw(let dst, let left, let right):
            try mulw(dst, left, right)
        case .divw(let dst, let left, let right):
            try divw(dst, left, right)
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
            try load8(dst, address, offset)
        case .sb(let src, let address, let offset):
            try store8(src, address, offset)
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
        case .notb(let dst, let src):
            try not8(dst, src)
        case .addb(let dst, let left, let right):
            try add8(dst, left, right)
        case .subb(let dst, let left, let right):
            try sub8(dst, left, right)
        case .mulb(let dst, let left, let right):
            try mul8(dst, left, right)
        case .divb(let dst, let left, let right):
            try div8(dst, left, right)
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
        setRegister(.ra, nextPc)
        nextPc = Word(destination)
    }
    
    private func callptr(_ target: RegisterPointer) throws {
        let destination = try getRegister(.w(target))
        setRegister(.ra, nextPc)
        nextPc = destination
    }
    
    let kSizeOfSavedRegisters: Word = 7 // TODO: The size of this register save-area needs to be machine-specific. Different targets will need different sizes.
    
    private func enter(_ numberOfWords: Int) throws {
        guard numberOfWords >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        
        try pushRegisters()
        let fp = try getRegister(.fp)
        var sp = try getRegister(.sp)
        sp = sp &- kSizeOfSavedRegisters
        store(value: fp, address: sp)
        setRegister(.fp, sp)
        sp = sp &- Word(numberOfWords)
        setRegister(.sp, sp)
    }
    
    private func leave() throws {
        let fp = try getRegister(.fp)
        var sp = fp
        setRegister(.fp, load(address: sp))
        sp = sp &+ kSizeOfSavedRegisters
        setRegister(.sp, sp)
        try popRegisters()
    }
    
    private func ret() throws {
        nextPc = try getRegister(.ra)
    }
    
    private func jmp(_ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        nextPc = Word(destination)
    }
    
    private func la(_ dst: RegisterPointer, _ label: String) throws {
        guard let value = program.labels[label] else {
            throw TackVirtualMachineError.undefinedLabel(label)
        }
        setRegister(.w(dst), Word(value))
    }
    
    private func bz(_ test: RegisterBoolean, _ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        if try getRegister(.w(test)) == 0 {
            nextPc = Word(destination)
        }
    }
    
    private func bnz(_ test: RegisterBoolean, _ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        if try getRegister(.w(test)) != 0 {
            nextPc = Word(destination)
        }
    }
    
    private func lw(_ dst: Register16, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let offset = intToWord(signedOffset)
        let addressToAccess = try getRegister(.w(address)) &+ offset
        let value = load(address: addressToAccess)
        setRegister(.w(dst), value)
    }
    
    private func load8(_ dst: Register8, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let offset = intToWord(signedOffset)
        let addressToAccess = try getRegister(.w(address)) &+ offset
        let value = load(address: addressToAccess)
        setRegister(.b(dst), value)
    }
    
    private func sw(_ src: Register16, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let offset = intToWord(signedOffset)
        let addressToAccess = try getRegister(.w(address)) &+ offset
        let value = try getRegister(.w(src))
        store(value: value, address: addressToAccess)
    }
    
    private func store8(_ src: Register8, _ address: RegisterPointer, _ signedOffset: Int) throws {
        let offset = intToWord(signedOffset)
        let addressToAccess = try getRegister(.w(address)) &+ offset
        let value = try getRegister(.b(src))
        store(value: value, address: addressToAccess)
    }
    
    private func ststr(_ addressRegister: RegisterPointer, _ str: String) throws {
        var address = try getRegister(.w(addressRegister))
        for character in str.utf8 {
            store(value: Word(character), address: address)
            address = address &+ 1
        }
    }
    
    private func memcpy(_ dstRegister: RegisterPointer, _ srcRegister: RegisterPointer, _ count: Int) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        
        var dst = try getRegister(.w(dstRegister))
        var src = try getRegister(.w(srcRegister))
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
        
        var sp = try getRegister(.sp)
        sp = sp &- Word(count)
        setRegister(.sp, sp)
        setRegister(.w(dst), sp)
    }
    
    private func free(_ count: Int) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        
        var sp = try getRegister(.sp)
        sp = sp &+ Word(count)
        setRegister(.sp, sp)
    }
    
    private func notw(_ dst: Register16, _ src: Register16) throws {
        var r = try getRegister(.w(src))
        r = ~r & 1
        setRegister(.w(dst), r)
    }
    
    private func not8(_ dst: Register8, _ src: Register8) throws {
        var r = try getRegister(.b(src))
        r = ~r & 1
        setRegister(.b(dst), r)
    }
    
    private func andiw(_ dst: Register16, _ left: Register16, _ right: Int) throws {
        guard right >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        var r = try getRegister(.w(left))
        r = r & Word(right)
        setRegister(.w(dst), r)
    }
    
    private func addiw(_ dst: Register16, _ left: Register16, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(.w(left))
        r = signExtend16(r &+ right)
        setRegister(.w(dst), r)
    }
    
    private func subiw(_ dst: Register16, _ left: Register16, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(.w(left))
        r = signExtend16(r &- right)
        setRegister(.w(dst), r)
    }
    
    private func muliw(_ dst: Register16, _ left: Register16, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(.w(left))
        r = signExtend16(r &* right)
        setRegister(.w(dst), r)
    }
    
    private func liw(_ dst: Register16, _ imm_: Int) throws {
        guard imm_ >= Int16.min && imm_ <= Int16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToWord(imm_)
        setRegister(.w(dst), imm)
    }
    
    private func liuw(_ dst: Register16, _ imm: Int) throws {
        guard imm >= 0 && imm <= UInt16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(.w(dst), Word(imm))
    }
    
    private func andw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = left & right
        setRegister(.w(dst), result)
    }
    
    private func orw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = left | right
        setRegister(.w(dst), result)
    }
    
    private func xorw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = left ^ right
        setRegister(.w(dst), result)
    }
    
    private func negw(_ dst: Register16, _ srcRegister: Register16) throws {
        let src = try getRegister(.w(srcRegister))
        let result = (~src) & 0xffff
        setRegister(.w(dst), result)
    }
    
    private func addw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = signExtend16(left &+ right)
        setRegister(.w(dst), result)
    }
    
    private func subw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = signExtend16(left &- right)
        setRegister(.w(dst), result)
    }
    
    private func mulw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = signExtend16(left &* right)
        setRegister(.w(dst), result)
    }
    
    private func divw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend16(left / right)
        setRegister(.w(dst), result)
    }
    
    private func mod16(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend16(left % right)
        setRegister(.w(dst), result)
    }
    
    private func lslw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = (left << right) & 0xffff
        setRegister(.w(dst), result)
    }
    
    private func lsrw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister))
        let right = try getRegister(.w(rightRegister))
        let result = (left >> right) & 0xffff
        setRegister(.w(dst), result)
    }
    
    private func eqw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = signExtend16(try getRegister(.w(leftRegister)))
        let right = signExtend16(try getRegister(.w(rightRegister)))
        let result = (left == right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func new(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = signExtend16(try getRegister(.w(leftRegister)))
        let right = signExtend16(try getRegister(.w(rightRegister)))
        let result = (left != right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func ltw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = wordToInt(signExtend16(try getRegister(.w(leftRegister))))
        let right = wordToInt(signExtend16(try getRegister(.w(rightRegister))))
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func gew(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = wordToInt(signExtend16(try getRegister(.w(leftRegister))))
        let right = wordToInt(signExtend16(try getRegister(.w(rightRegister))))
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func lew(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = wordToInt(signExtend16(try getRegister(.w(leftRegister))))
        let right = wordToInt(signExtend16(try getRegister(.w(rightRegister))))
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func gtw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = wordToInt(signExtend16(try getRegister(.w(leftRegister))))
        let right = wordToInt(signExtend16(try getRegister(.w(rightRegister))))
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func ltuw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister)) & 0xffff
        let right = try getRegister(.w(rightRegister)) & 0xffff
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func geuw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister)) & 0xffff
        let right = try getRegister(.w(rightRegister)) & 0xffff
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func leuw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister)) & 0xffff
        let right = try getRegister(.w(rightRegister)) & 0xffff
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func gtuw(_ dst: Register16, _ leftRegister: Register16, _ rightRegister: Register16) throws {
        let left = try getRegister(.w(leftRegister)) & 0xffff
        let right = try getRegister(.w(rightRegister)) & 0xffff
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func li8(_ dst: Register8, _ imm_: Int) throws {
        guard imm_ >= Int8.min && imm_ <= Int8.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToWord(imm_)
        setRegister(.b(dst), imm)
    }
    
    private func liu8(_ dst: Register8, _ imm: Int) throws {
        guard imm >= 0 && imm <= UInt8.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(.b(dst), Word(imm))
    }
    
    private func and8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        let result = (left & right) & 0xff
        setRegister(.b(dst), result)
    }
    
    private func or8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        let result = (left | right) & 0xff
        setRegister(.b(dst), result)
    }
    
    private func xor8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        let result = (left ^ right) & 0xff
        setRegister(.b(dst), result)
    }
    
    private func neg8(_ dst: Register8, _ srcRegister: Register8) throws {
        let src = try getRegister(.b(srcRegister))
        let result = (~src) & 0xff
        setRegister(.b(dst), result)
    }
    
    private func add8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        let result = signExtend8(left &+ right)
        setRegister(.b(dst), result)
    }
    
    private func sub8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        let result = signExtend8(left &- right)
        setRegister(.b(dst), result)
    }
    
    private func mul8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        let result = signExtend8(left &* right)
        setRegister(.b(dst), result)
    }
    
    private func div8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend8(left / right)
        setRegister(.b(dst), result)
    }
    
    private func mod8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister))
        let right = try getRegister(.b(rightRegister))
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend8(left % right)
        setRegister(.b(dst), result)
    }
    
    private func lsl8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister)) & 0xff
        let right = try getRegister(.b(rightRegister)) & 0xff
        let result = (left << right) & 0xff
        setRegister(.b(dst), result)
    }
    
    private func lsr8(_ dst: Register8, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = try getRegister(.b(leftRegister)) & 0xff
        let right = try getRegister(.b(rightRegister)) & 0xff
        let result = (left >> right) & 0xff
        setRegister(.b(dst), result)
    }
    
    private func eq8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = wordToInt(signExtend8(try getRegister(.b(leftRegister))))
        let right = wordToInt(signExtend8(try getRegister(.b(rightRegister))))
        let result = (left == right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func ne8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = wordToInt(signExtend8(try getRegister(.b(leftRegister))))
        let right = wordToInt(signExtend8(try getRegister(.b(rightRegister))))
        let result = (left != right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func lt8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = wordToInt(signExtend8(try getRegister(.b(leftRegister))))
        let right = wordToInt(signExtend8(try getRegister(.b(rightRegister))))
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func ge8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = wordToInt(signExtend8(try getRegister(.b(leftRegister))))
        let right = wordToInt(signExtend8(try getRegister(.b(rightRegister))))
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func le8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = wordToInt(signExtend8(try getRegister(.b(leftRegister))))
        let right = wordToInt(signExtend8(try getRegister(.b(rightRegister))))
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func gt8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = wordToInt(signExtend8(try getRegister(.b(leftRegister))))
        let right = wordToInt(signExtend8(try getRegister(.b(rightRegister))))
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func ltu8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = signExtend8(try getRegister(.b(leftRegister)))
        let right = signExtend8(try getRegister(.b(rightRegister)))
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func geu8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = signExtend8(try getRegister(.b(leftRegister)))
        let right = signExtend8(try getRegister(.b(rightRegister)))
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func leu8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = signExtend8(try getRegister(.b(leftRegister)))
        let right = signExtend8(try getRegister(.b(rightRegister)))
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func gtu8(_ dst: Register16, _ leftRegister: Register8, _ rightRegister: Register8) throws {
        let left = signExtend8(try getRegister(.b(leftRegister)))
        let right = signExtend8(try getRegister(.b(rightRegister)))
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(.w(dst), result)
    }
    
    private func movsbw(_ dst: Register8, _ srcRegister: Register16) throws {
        let src = try getRegister(.w(srcRegister))
        let result = signExtend8(src)
        setRegister(.b(dst), result)
    }
    
    private func movswb(_ dst: Register16, _ srcRegister: Register8) throws {
        let src = try getRegister(.b(srcRegister))
        let result = signExtend8(src)
        setRegister(.w(dst), result)
    }
    
    private func movzwb(_ dst: Register16, _ srcRegister: Register8) throws {
        let src = try getRegister(.b(srcRegister))
        let result = src & 0x00ff
        setRegister(.w(dst), result)
    }
    
    private func movzbw(_ dst: Register8, _ srcRegister: Register16) throws {
        let src = try getRegister(.w(srcRegister))
        let result = src & 0x00ff
        setRegister(.b(dst), result)
    }
    
    private func inlineAssembly(_ asm: String) throws {
        switch asm {
        case "HLT":
            hlt()
        
        case "BREAK":
            if nextPc < breakPoints.count {
                breakPoints[Int(nextPc)] = true
            }
            
        default:
            throw TackVirtualMachineError.inlineAssemblyNotSupported
        }
    }
    
    private func syscall(_ n_: Register16, _ ptr_: RegisterPointer) throws {
        let n = Int(load(address: try getRegister(.w(n_))))
        let ptr = load(address: try getRegister(.w(ptr_)))
        
        switch Syscall(rawValue: n) {
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
    
    private func getc(_ ptr: Word) {
        let value = onSerialInput()
        store(value: value, address: ptr)
    }
    
    private func putc(_ ptr: Word) {
        let value = load(address: ptr)
        onSerialOutput(value)
    }
}
