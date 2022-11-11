//
//  TackVirtualMachine.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/6/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public enum TackVirtualMachineError: Error {
    case undefinedLabel(String)
    case undefinedRegister(TackInstruction.Register)
    case invalidArgument
    case underflowRegisterStack
    case divideByZero
    case inlineAssemblyNotSupported
}

public class TackVirtualMachine: NSObject {
    public typealias Register = TackInstruction.Register
    public typealias Word = UInt16
    
    public let kMemoryMappedSerialOutputPort: Word = 0x0001
    public let kPageSize = 4096
    
    public let program: TackProgram
    public var pc: Word = 0
    public var nextPc: Word = 0
    public var isHalted = false
    private var globalRegisters: [Register : Word] = [:]
    private var registers: [[Register : Word]] = [[:]]
    private var memoryPages: [Int : [Word]] = [:]
    public var onSerialOutput: (Word) -> Void = {_ in}
    
    public init(_ program: TackProgram) {
        self.program = program
        super.init()
        setRegister(.sp, 0)
        setRegister(.fp, 0)
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
        case .vr:
            guard let value = registers[registers.count-1][reg] else {
                throw TackVirtualMachineError.undefinedRegister(reg)
            }
            return value
            
        default:
            guard let value = globalRegisters[reg] else {
                throw TackVirtualMachineError.undefinedRegister(reg)
            }
            return value
        }
    }
    
    public func setRegister(_ reg: Register, _ value: Word) {
        switch reg {
        case .vr:
            registers[registers.count-1][reg] = value
            
        default:
            globalRegisters[reg] = value
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
        while !isHalted {
            try step()
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
        case .bz(let test, let target):
            try bz(test, target)
        case .bnz(let test, let target):
            try bnz(test, target)
        case .load(let dst, let address, let offset):
            try load(dst, address, offset)
        case .store(let src, let address, let offset):
            try store(src, address, offset)
        case .ststr(let address, let str):
            try ststr(address, str)
        case .memcpy(let dst, let src, let count):
            try memcpy(dst, src, count)
        case .alloca(let dst, let count):
            try alloca(dst, count)
        case .free(let count):
            try free(count)
        case .not(let dst, let src):
            try not(dst, src)
        case .andi16(let dst, let left, let right):
            try andi16(dst, left, right)
        case .addi16(let dst, let left, let right):
            try addi16(dst, left, right)
        case .subi16(let dst, let left, let right):
            try subi16(dst, left, right)
        case .muli16(let dst, let left, let right):
            try muli16(dst, left, right)
        case .li16(let dst, let imm):
            try li16(dst, imm)
        case .liu16(let dst, let imm):
            try liu16(dst, imm)
        case .and16(let dst, let left, let right):
            try and16(dst, left, right)
        case .or16(let dst, let left, let right):
            try or16(dst, left, right)
        case .xor16(let dst, let left, let right):
            try xor16(dst, left, right)
        case .neg16(let dst, let src):
            try neg16(dst, src)
        case .add16(let dst, let left, let right):
            try add16(dst, left, right)
        case .sub16(let dst, let left, let right):
            try sub16(dst, left, right)
        case .mul16(let dst, let left, let right):
            try mul16(dst, left, right)
        case .div16(let dst, let left, let right):
            try div16(dst, left, right)
        case .mod16(let dst, let left, let right):
            try mod16(dst, left, right)
        case .lsl16(let dst, let left, let right):
            try lsl16(dst, left, right)
        case .lsr16(let dst, let left, let right):
            try lsr16(dst, left, right)
        case .eq16(let dst, let left, let right):
            try eq16(dst, left, right)
        case .ne16(let dst, let left, let right):
            try ne16(dst, left, right)
        case .lt16(let dst, let left, let right):
            try lt16(dst, left, right)
        case .ge16(let dst, let left, let right):
            try ge16(dst, left, right)
        case .le16(let dst, let left, let right):
            try le16(dst, left, right)
        case .gt16(let dst, let left, let right):
            try gt16(dst, left, right)
        case .ltu16(let dst, let left, let right):
            try ltu16(dst, left, right)
        case .geu16(let dst, let left, let right):
            try geu16(dst, left, right)
        case .leu16(let dst, let left, let right):
            try leu16(dst, left, right)
        case .gtu16(let dst, let left, let right):
            try gtu16(dst, left, right)
        case .li8(let dst, let imm):
            try li8(dst, imm)
        case .liu8(let dst, let imm):
            try liu8(dst, imm)
        case .and8(let dst, let left, let right):
            try and8(dst, left, right)
        case .or8(let dst, let left, let right):
            try or8(dst, left, right)
        case .xor8(let dst, let left, let right):
            try xor8(dst, left, right)
        case .neg8(let dst, let src):
            try neg8(dst, src)
        case .add8(let dst, let left, let right):
            try add8(dst, left, right)
        case .sub8(let dst, let left, let right):
            try sub8(dst, left, right)
        case .mul8(let dst, let left, let right):
            try mul8(dst, left, right)
        case .div8(let dst, let left, let right):
            try div8(dst, left, right)
        case .mod8(let dst, let left, let right):
            try mod8(dst, left, right)
        case .lsl8(let dst, let left, let right):
            try lsl8(dst, left, right)
        case .lsr8(let dst, let left, let right):
            try lsr8(dst, left, right)
        case .eq8(let dst, let left, let right):
            try eq8(dst, left, right)
        case .ne8(let dst, let left, let right):
            try ne8(dst, left, right)
        case .lt8(let dst, let left, let right):
            try lt8(dst, left, right)
        case .ge8(let dst, let left, let right):
            try ge8(dst, left, right)
        case .le8(let dst, let left, let right):
            try le8(dst, left, right)
        case .gt8(let dst, let left, let right):
            try gt8(dst, left, right)
        case .ltu8(let dst, let left, let right):
            try ltu8(dst, left, right)
        case .geu8(let dst, let left, let right):
            try geu8(dst, left, right)
        case .leu8(let dst, let left, let right):
            try leu8(dst, left, right)
        case .gtu8(let dst, let left, let right):
            try gtu8(dst, left, right)
        case .sxt8(let dst, let src):
            try sxt8(dst, src)
        case .inlineAssembly(let asm):
            try inlineAssembly(asm)
        }
        
        pc = nextPc
        
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
    
    private func callptr(_ target: Register) throws {
        let destination = try getRegister(target)
        setRegister(.ra, nextPc)
        nextPc = destination
    }
    
    private func enter(_ numberOfWords: Int) throws {
        guard numberOfWords >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        
        try pushRegisters()
        let fp = try getRegister(.fp)
        var sp = try getRegister(.sp)
        sp = sp &- 1
        store(value: fp, address: sp)
        setRegister(.fp, sp)
        sp = sp &- Word(numberOfWords)
        setRegister(.sp, sp)
    }
    
    private func leave() throws {
        let fp = try getRegister(.fp)
        let stashedFp = load(address: fp)
        setRegister(.fp, stashedFp)
        setRegister(.sp, fp &+ 1)
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
    
    private func la(_ dst: Register, _ label: String) throws {
        guard let value = program.labels[label] else {
            throw TackVirtualMachineError.undefinedLabel(label)
        }
        setRegister(dst, Word(value))
    }
    
    private func bz(_ test: Register, _ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        if try getRegister(test) == 0 {
            nextPc = Word(destination)
        }
    }
    
    private func bnz(_ test: Register, _ target: String) throws {
        guard let destination = program.labels[target] else {
            throw TackVirtualMachineError.undefinedLabel(target)
        }
        if try getRegister(test) != 0 {
            nextPc = Word(destination)
        }
    }
    
    private func load(_ dst: Register, _ address: Register, _ signedOffset: Int) throws {
        let offset = intToWord(signedOffset)
        let addressToAccess = try getRegister(address) &+ offset
        let value = load(address: addressToAccess)
        setRegister(dst, value)
    }
    
    private func store(_ src: Register, _ address: Register, _ signedOffset: Int) throws {
        let offset = intToWord(signedOffset)
        let addressToAccess = try getRegister(address) &+ offset
        let value = try getRegister(src)
        store(value: value, address: addressToAccess)
    }
    
    private func ststr(_ addressRegister: Register, _ str: String) throws {
        var address = try getRegister(addressRegister)
        for character in str.utf8 {
            store(value: Word(character), address: address)
            address = address &+ 1
        }
    }
    
    private func memcpy(_ dstRegister: Register, _ srcRegister: Register, _ count: Int) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        
        var dst = try getRegister(dstRegister)
        var src = try getRegister(srcRegister)
        for _ in 0..<count {
            let word = load(address: src)
            store(value: word, address: dst)
            src = src &+ 1
            dst = dst &+ 1
        }
    }
    
    private func alloca(_ dst: Register, _ count: Int) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        
        var sp = try getRegister(.sp)
        sp = sp &- Word(count)
        setRegister(.sp, sp)
        setRegister(dst, sp)
    }
    
    private func free(_ count: Int) throws {
        guard count >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        
        var sp = try getRegister(.sp)
        sp = sp &+ Word(count)
        setRegister(.sp, sp)
    }
    
    private func not(_ dst: Register, _ src: Register) throws {
        var r = try getRegister(src)
        r = ~r & 1
        setRegister(dst, r)
    }
    
    private func andi16(_ dst: Register, _ left: Register, _ right: Int) throws {
        guard right >= 0 else {
            throw TackVirtualMachineError.invalidArgument
        }
        var r = try getRegister(left)
        r = r & Word(right)
        setRegister(dst, r)
    }
    
    private func addi16(_ dst: Register, _ left: Register, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(left)
        r = signExtend16(r &+ right)
        setRegister(dst, r)
    }
    
    private func subi16(_ dst: Register, _ left: Register, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(left)
        r = signExtend16(r &- right)
        setRegister(dst, r)
    }
    
    private func muli16(_ dst: Register, _ left: Register, _ right_: Int) throws {
        let right = signExtend16(intToWord(right_))
        var r = try getRegister(left)
        r = signExtend16(r &* right)
        setRegister(dst, r)
    }
    
    private func li16(_ dst: Register, _ imm_: Int) throws {
        guard imm_ >= Int16.min && imm_ <= Int16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToWord(imm_)
        setRegister(dst, imm)
    }
    
    private func liu16(_ dst: Register, _ imm: Int) throws {
        guard imm >= 0 && imm <= UInt16.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(dst, Word(imm))
    }
    
    private func and16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = left & right
        setRegister(dst, result)
    }
    
    private func or16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = left | right
        setRegister(dst, result)
    }
    
    private func xor16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = left ^ right
        setRegister(dst, result)
    }
    
    private func neg16(_ dst: Register, _ srcRegister: Register) throws {
        let src = try getRegister(srcRegister)
        let result = (~src) & 0xffff
        setRegister(dst, result)
    }
    
    private func add16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = signExtend16(left &+ right)
        setRegister(dst, result)
    }
    
    private func sub16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = signExtend16(left &- right)
        setRegister(dst, result)
    }
    
    private func mul16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = signExtend16(left &* right)
        setRegister(dst, result)
    }
    
    private func div16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend16(left / right)
        setRegister(dst, result)
    }
    
    private func mod16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend16(left % right)
        setRegister(dst, result)
    }
    
    private func lsl16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = (left << right) & 0xffff
        setRegister(dst, result)
    }
    
    private func lsr16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = (left >> right) & 0xffff
        setRegister(dst, result)
    }
    
    private func eq16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = signExtend16(try getRegister(leftRegister))
        let right = signExtend16(try getRegister(rightRegister))
        let result = (left == right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func ne16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = signExtend16(try getRegister(leftRegister))
        let right = signExtend16(try getRegister(rightRegister))
        let result = (left != right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func lt16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend16(try getRegister(leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(rightRegister)))
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func ge16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend16(try getRegister(leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(rightRegister)))
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func le16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend16(try getRegister(leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(rightRegister)))
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func gt16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend16(try getRegister(leftRegister)))
        let right = wordToInt(signExtend16(try getRegister(rightRegister)))
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func ltu16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister) & 0xffff
        let right = try getRegister(rightRegister) & 0xffff
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func geu16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister) & 0xffff
        let right = try getRegister(rightRegister) & 0xffff
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func leu16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister) & 0xffff
        let right = try getRegister(rightRegister) & 0xffff
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func gtu16(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister) & 0xffff
        let right = try getRegister(rightRegister) & 0xffff
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func li8(_ dst: Register, _ imm_: Int) throws {
        guard imm_ >= Int8.min && imm_ <= Int8.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        let imm = intToWord(imm_)
        setRegister(dst, imm)
    }
    
    private func liu8(_ dst: Register, _ imm: Int) throws {
        guard imm >= 0 && imm <= UInt8.max else {
            throw TackVirtualMachineError.invalidArgument
        }
        setRegister(dst, Word(imm))
    }
    
    private func and8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = (left & right) & 0xff
        setRegister(dst, result)
    }
    
    private func or8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = (left | right) & 0xff
        setRegister(dst, result)
    }
    
    private func xor8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = (left ^ right) & 0xff
        setRegister(dst, result)
    }
    
    private func neg8(_ dst: Register, _ srcRegister: Register) throws {
        let src = try getRegister(srcRegister)
        let result = (~src) & 0xff
        setRegister(dst, result)
    }
    
    private func add8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = signExtend8(left &+ right)
        setRegister(dst, result)
    }
    
    private func sub8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = signExtend8(left &- right)
        setRegister(dst, result)
    }
    
    private func mul8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        let result = signExtend8(left &* right)
        setRegister(dst, result)
    }
    
    private func div8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend8(left / right)
        setRegister(dst, result)
    }
    
    private func mod8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister)
        let right = try getRegister(rightRegister)
        guard right != 0 else {
            throw TackVirtualMachineError.divideByZero
        }
        let result = signExtend8(left % right)
        setRegister(dst, result)
    }
    
    private func lsl8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister) & 0xff
        let right = try getRegister(rightRegister) & 0xff
        let result = (left << right) & 0xff
        setRegister(dst, result)
    }
    
    private func lsr8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = try getRegister(leftRegister) & 0xff
        let right = try getRegister(rightRegister) & 0xff
        let result = (left >> right) & 0xff
        setRegister(dst, result)
    }
    
    private func eq8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend8(try getRegister(leftRegister)))
        let right = wordToInt(signExtend8(try getRegister(rightRegister)))
        let result = (left == right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func ne8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend8(try getRegister(leftRegister)))
        let right = wordToInt(signExtend8(try getRegister(rightRegister)))
        let result = (left != right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func lt8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend8(try getRegister(leftRegister)))
        let right = wordToInt(signExtend8(try getRegister(rightRegister)))
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func ge8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend8(try getRegister(leftRegister)))
        let right = wordToInt(signExtend8(try getRegister(rightRegister)))
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func le8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend8(try getRegister(leftRegister)))
        let right = wordToInt(signExtend8(try getRegister(rightRegister)))
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func gt8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = wordToInt(signExtend8(try getRegister(leftRegister)))
        let right = wordToInt(signExtend8(try getRegister(rightRegister)))
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func ltu8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = signExtend8(try getRegister(leftRegister))
        let right = signExtend8(try getRegister(rightRegister))
        let result = (left < right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func geu8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = signExtend8(try getRegister(leftRegister))
        let right = signExtend8(try getRegister(rightRegister))
        let result = (left >= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func leu8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = signExtend8(try getRegister(leftRegister))
        let right = signExtend8(try getRegister(rightRegister))
        let result = (left <= right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func gtu8(_ dst: Register, _ leftRegister: Register, _ rightRegister: Register) throws {
        let left = signExtend8(try getRegister(leftRegister))
        let right = signExtend8(try getRegister(rightRegister))
        let result = (left > right) ? Word(1) : Word(0)
        setRegister(dst, result)
    }
    
    private func sxt8(_ dst: Register, _ srcRegister: Register) throws {
        let src = try getRegister(srcRegister)
        let result = signExtend8(src)
        setRegister(dst, result)
    }
    
    private func inlineAssembly(_ asm: String) throws {
        throw TackVirtualMachineError.inlineAssemblyNotSupported
    }
}
