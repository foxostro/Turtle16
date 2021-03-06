//
//  CrackleDeadCodeEliminationOptimizationPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CrackleDeadCodeEliminationOptimizationPass: NSObject {
    public var unoptimizedProgram = CrackleBasicBlock()
    public var optimizedProgram = CrackleBasicBlock()
    public enum MemoryState { case dirty, clean }
    public var memory = Array<MemoryState>.init(repeating: .clean, count: 65536)
    public var prev = Array<MemoryState>.init(repeating: .clean, count: 65536)
    
    public func optimize() {
        optimizedProgram = unoptimizedProgram.copy()
        optimizedProgram.instructions = unoptimizedProgram.instructions.reversed().map({ rewrite($0) }).reversed()
    }
    
    public func rewrite(_ instruction: CrackleInstruction) -> CrackleInstruction {
        updateStateOfMemory(instruction)
        
        switch instruction {
        case .storeImmediate(let c, _),
             .add(let c, _, _),
             .sub(let c, _, _),
             .mul(let c, _, _),
             .div(let c, _, _),
             .mod(let c, _, _),
             .and(let c, _, _),
             .or(let c, _, _),
             .xor(let c, _, _),
             .lsl(let c, _, _),
             .lsr(let c, _, _),
             .eq(let c, _, _),
             .ne(let c, _, _),
             .lt(let c, _, _),
             .gt(let c, _, _),
             .le(let c, _, _),
             .ge(let c, _, _),
             .neg(let c, _),
             .not(let c, _):
            if allBytesWerePreviouslyDirty(c, 1) {
                return .nop
            } else {
                return instruction
            }
            
        case .subi16(let c, _, _),
             .addi16(let c, _, _),
             .muli16(let c, _, _),
             .storeImmediate16(let c, _),
             .eq16(let c, _, _),
             .ne16(let c, _, _),
             .lt16(let c, _, _),
             .gt16(let c, _, _),
             .le16(let c, _, _),
             .ge16(let c, _, _),
             .add16(let c, _, _),
             .sub16(let c, _, _),
             .mul16(let c, _, _),
             .div16(let c, _, _),
             .mod16(let c, _, _),
             .and16(let c, _, _),
             .or16(let c, _, _),
             .xor16(let c, _, _),
             .lsl16(let c, _, _),
             .lsr16(let c, _, _),
             .neg16(let c, _),
             .copyWordZeroExtend(let c, _),
             .copyLabel(let c, _):
            if allBytesWerePreviouslyDirty(c, 2) {
                return .nop
            } else {
                return instruction
            }
            
        case .storeImmediateBytes(let address, let bytes):
            if allBytesWerePreviouslyDirty(address, bytes.count) {
                return .nop
            } else {
                return instruction
            }
            
        case .copyWords(let dst, _, let n):
            if allBytesWerePreviouslyDirty(dst, n) {
                return .nop
            } else {
                return instruction
            }
            
        default:
            break
        }
        
        return instruction
    }
    
    public func updateStateOfMemory(_ instruction: CrackleInstruction) {
        prev = memory
        
        switch instruction {
        case .subi16(let c, let a, _),
             .addi16(let c, let a, _),
             .muli16(let c, let a, _):
            memory[c+0] = .dirty
            memory[c+1] = .dirty
            memory[a+0] = .clean
            memory[a+1] = .clean
        
        case .storeImmediate(let address, _):
            memory[address] = .dirty
            
        case .storeImmediate16(let address, _):
            memory[address+0] = .dirty
            memory[address+1] = .dirty
            
        case .storeImmediateBytes(let address, let bytes):
            for i in 0..<bytes.count {
                memory[address+i] = .dirty
            }
            
        case .storeImmediateBytesIndirect:
            cleanAllMemory()
            
        case .add(let c, let a, let b),
             .sub(let c, let a, let b),
             .mul(let c, let a, let b),
             .div(let c, let a, let b),
             .mod(let c, let a, let b),
             .and(let c, let a, let b),
             .or(let c, let a, let b),
             .xor(let c, let a, let b),
             .lsl(let c, let a, let b),
             .lsr(let c, let a, let b),
             .eq(let c, let a, let b),
             .ne(let c, let a, let b),
             .lt(let c, let a, let b),
             .gt(let c, let a, let b),
             .le(let c, let a, let b),
             .ge(let c, let a, let b):
            memory[c] = .dirty
            memory[a] = .clean
            memory[b] = .clean
            
        case .eq16(let c, let a, let b),
             .ne16(let c, let a, let b),
             .lt16(let c, let a, let b),
             .gt16(let c, let a, let b),
             .le16(let c, let a, let b),
             .ge16(let c, let a, let b):
            memory[c+0] = .dirty
            memory[a+0] = .clean
            memory[a+1] = .clean
            memory[b+0] = .clean
            memory[b+1] = .clean
            
        case .add16(let c, let a, let b),
             .sub16(let c, let a, let b),
             .mul16(let c, let a, let b),
             .div16(let c, let a, let b),
             .mod16(let c, let a, let b),
             .and16(let c, let a, let b),
             .or16(let c, let a, let b),
             .xor16(let c, let a, let b),
             .lsl16(let c, let a, let b),
             .lsr16(let c, let a, let b):
            memory[c+0] = .dirty
            memory[c+1] = .dirty
            memory[a+0] = .clean
            memory[a+1] = .clean
            memory[b+0] = .clean
            memory[b+1] = .clean
            
        case .neg(let c, let a),
             .not(let c, let a):
            memory[c] = .dirty
            memory[a] = .clean
            
        case .neg16(let c, let a),
             .copyWordZeroExtend(let c, let a):
            memory[c+0] = .dirty
            memory[c+1] = .dirty
            memory[a+0] = .clean
            memory[a+1] = .clean
            
        case .copyWords(let dst, let src, let n):
            for i in 0..<n {
                memory[dst+i] = .dirty
            }
            for i in 0..<n {
                memory[src+i] = .clean
            }
            
        case .copyLabel(let address, _):
            memory[address+0] = .dirty
            memory[address+1] = .dirty
            
        case .copyWordsIndirectSource,
             .copyWordsIndirectDestination,
             .copyWordsIndirectDestinationIndirectSource,
             .push,
             .push16,
             .pop,
             .pop16,
             .enter,
             .leave,
             .pushReturnAddress,
             .peekPeripheral,
             .pokePeripheral,
             .indirectJalr:
            cleanAllMemory()
            
        case .jz(_, let a),
             .jnz(_, let a):
            memory[a+0] = .clean
            memory[a+1] = .clean
            
        case .label,
             .nop,
             .jmp,
             .jalr,
             .ret,
             .leafRet,
             .hlt:
            break
        }
    }
    
    func allBytesWerePreviouslyDirty(_ address: Int, _ length: Int) -> Bool {
        for i in 0..<length {
            if case .clean = prev[address+i] {
                return false
            }
        }
        return true
    }
    
    func atLeastOneByteWasPreviouslyDirty(_ address: Int, _ length: Int) -> Bool {
        for i in 0..<length {
            if case .dirty = prev[address+i] {
                return true
            }
        }
        return false
    }
    
    fileprivate func cleanAllMemory() {
        memory = Array<MemoryState>.init(repeating: .clean, count: 65536)
    }
}
