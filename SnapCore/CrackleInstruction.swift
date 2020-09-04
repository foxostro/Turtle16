//
//  CrackleInstruction.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Defines a stack-based intermediate language.
public enum CrackleInstruction: Equatable {
    case push(Int) // push the specified word-sized value to the stack
    case push16(Int) // push the specified sixteen-bit double-word-sized value to the stack
    case pop // pop the stack
    case pop16 // pop a sixteen-bit value from the stack
    case subi16(Int, Int, Int) // (c, a, imm) -- computes c = a - imm
    case addi16(Int, Int, Int) // (c, a, imm) -- computes c = a + imm
    case load(Int) // load from the specified address, push to the stack
    case load16(Int) // load a 16-bit value from the specified address, push to the stack in two words
    case storeImmediate(Int, Int)
    case storeImmediate16(Int, Int)
    case loadIndirectN(Int) // Pop a sixteen-bit address from the stack. Load the N words in memory at that address and push them to the stack as a unit.
    case label(String) // declares a label
    case jmp(String) // unconditional jump, no change to the stack
    case jalr(String) // unconditional jump-and-link, e.g., for a function call. Inserts code at the link point to clear the stack save for whatever value was in the A register.
    case enter // push fp in two bytes ; fp <- sp
    case leave // sp <- fp ; fp <- pop two bytes from the stack
    case pushReturnAddress // push the link register (two bytes) to the stack
    case ret // pop the two byte return address and jump to that address
    case leafRet // Jump back to the address in the link register to return from the function
    case hlt // Halt the machine. This is useful for debugging.
    case peekPeripheral
    case pokePeripheral
    
    case tac_add(Int, Int, Int)
    case tac_add16(Int, Int, Int)
    case tac_sub(Int, Int, Int)
    case tac_sub16(Int, Int, Int)
    case tac_mul(Int, Int, Int)
    case tac_mul16(Int, Int, Int)
    case tac_div(Int, Int, Int)
    case tac_div16(Int, Int, Int)
    case tac_mod(Int, Int, Int)
    case tac_mod16(Int, Int, Int)
    case tac_eq(Int, Int, Int)
    case tac_eq16(Int, Int, Int)
    case tac_ne(Int, Int, Int)
    case tac_ne16(Int, Int, Int)
    case tac_lt(Int, Int, Int)
    case tac_lt16(Int, Int, Int)
    case tac_gt(Int, Int, Int)
    case tac_gt16(Int, Int, Int)
    case tac_le(Int, Int, Int)
    case tac_le16(Int, Int, Int)
    case tac_ge(Int, Int, Int)
    case tac_ge16(Int, Int, Int)
    
    case tac_jz(String, Int) // (label, test) -- Branch if the word in memory at the address given by `test' is zero
    
    case copyWordZeroExtend(Int, Int) // copies an 8-bit word at the specified source address to a 16-bit slot at the specified destination address, filling the high bits with zero
    
    case copyWords(Int, Int, Int) // (dst, src, N) -- copies N words starting at the specified source address to the destination address.
    
    case copyWordsIndirectSource(Int, Int, Int) // (dst, srcPtr, N) -- copies N words starting at the source address to the destination address. The source address is located in memory at the address given by `srcPtr'.
    
    case copyWordsIndirectDestination(Int, Int, Int) // (dstPtr, src, N) -- copies N words starting at the source address to the destination address. The destination address is located in memory at the address given by `dstPtr'.
    
    case copyWordsIndirectDestinationIndirectSource(Int, Int, Int) // (dstPtr, srcPtr, N) -- copies N words starting at the source address to the destination address. The destination address is located in memory at the address given by `dstPtr'. The source address is located in memory at the address given by `srcPtr'.
    
    public var description: String {
        switch self {
        case .push(let value):
            return String(format: "PUSH 0x%02x", value)
        case .push16(let value):
            return String(format: "PUSH16 0x%04x", value)
        case .pop:
            return "POP"
        case .pop16:
            return "POP16"
        case .subi16(let c, let a, let imm):
            return String(format: "SUBI16 0x%04x, 0x%04x, 0x%04x", c, a, imm)
        case .addi16(let c, let a, let imm):
            return String(format: "ADDI16 0x%04x, 0x%04x, 0x%04x", c, a, imm)
        case .load(let address):
            return String(format: "LOAD 0x%04x", address)
        case .load16(let address):
            return String(format: "LOAD16 0x%04x", address)
        case .storeImmediate(let address, let value):
            return String(format: "STORE-IMMEDIATE 0x%04x, 0x%02x", address, value)
        case .storeImmediate16(let address, let value):
            return String(format: "STORE-IMMEDIATE16 0x%04x, 0x%04x", address, value)
        case .loadIndirectN(let count):
            return "LOAD-INDIRECTN \(count)"
        case .label(let name):
            return "\(name):"
        case .jmp(let label):
            return "JMP \(label)"
        case .jalr(let label):
            return "JALR \(label)"
        case .enter:
            return "ENTER"
        case .leave:
            return "LEAVE"
        case .pushReturnAddress:
            return "PUSH-RETURN-ADDRESS"
        case .ret:
            return "RET"
        case .leafRet:
            return "LEAF-RET"
        case .hlt:
            return "HLT"
        case .peekPeripheral:
            return "PEEK-PERIPHERAL"
        case .pokePeripheral:
            return "POKE-PERIPHERAL"
        case .tac_add(let c, let a, let b):
            return String(format: "ADD 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_add16(let c, let a, let b):
            return String(format: "ADD16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_sub(let c, let a, let b):
            return String(format: "SUB 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_sub16(let c, let a, let b):
            return String(format: "SUB16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_mul(let c, let a, let b):
            return String(format: "MUL 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_mul16(let c, let a, let b):
            return String(format: "MUL16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_div(let c, let a, let b):
            return String(format: "DIV 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_div16(let c, let a, let b):
            return String(format: "DIV16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_mod(let c, let a, let b):
            return String(format: "MOD 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_mod16(let c, let a, let b):
            return String(format: "MOD16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_eq(let c, let a, let b):
            return String(format: "EQ 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_eq16(let c, let a, let b):
            return String(format: "EQ16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_ne(let c, let a, let b):
            return String(format: "NE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_ne16(let c, let a, let b):
            return String(format: "NE16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_lt(let c, let a, let b):
            return String(format: "LT 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_lt16(let c, let a, let b):
            return String(format: "LT16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_gt(let c, let a, let b):
            return String(format: "GT 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_gt16(let c, let a, let b):
            return String(format: "GT16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_le(let c, let a, let b):
            return String(format: "LE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_le16(let c, let a, let b):
            return String(format: "LE16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_ge(let c, let a, let b):
            return String(format: "GE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_ge16(let c, let a, let b):
            return String(format: "GE16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_jz(let label, let test):
            return String(format: "JZ %@, 0x%04x", label, test)
        case .copyWordZeroExtend(let b, let a):
            return String(format: "COPY-ZX 0x%04x, 0x%04x", b, a)
        case .copyWords(let dst, let src, let numberOfWords):
            return String(format: "COPY 0x%04x, 0x%04x, %d", dst, src, numberOfWords)
        case .copyWordsIndirectSource(let dst, let src, let numberOfWords):
            return String(format: "COPY-IS 0x%04x, 0x%04x, %d", dst, src, numberOfWords)
        case .copyWordsIndirectDestination(let dstPtr, let src, let numberOfWords):
            return String(format: "COPY-ID 0x%04x, 0x%04x, %d", dstPtr, src, numberOfWords)
        case .copyWordsIndirectDestinationIndirectSource(let dstPtr, let src, let numberOfWords):
            return String(format: "COPY-IDIS 0x%04x, 0x%04x, %d", dstPtr, src, numberOfWords)
        }
    }
    
    public static func makeListing(instructions: [CrackleInstruction]) -> String {
        return instructions.map{ $0.description }.joined(separator: "\n") + "\n"
    }
}
