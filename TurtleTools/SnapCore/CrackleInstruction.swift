//
//  CrackleInstruction.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

// An instruction in the "Crackle" intermediate language.
// This is basically a three-address code IR with a somewhat low-level focus.
// Instructions entirely revolve around memory-to-memory operations because
// the underlying hardware has too few registers to use those directly at this
// level. (That is, they are always all in use up by code which implements
// the Crackle instructions.)
public enum CrackleInstruction: Equatable, Hashable {
    case nop // no operation
    case push(Int) // push the specified word-sized value to the stack
    case push16(Int) // push the specified sixteen-bit double-word-sized value to the stack
    case pop // pop the stack
    case pop16 // pop a sixteen-bit value from the stack
    case subi16(Int, Int, Int) // (c, a, imm) -- computes c = a - imm
    case addi16(Int, Int, Int) // (c, a, imm) -- computes c = a + imm
    case muli16(Int, Int, Int) // (c, a, imm) -- computes c = a * imm
    case storeImmediate(Int, Int)
    case storeImmediate16(Int, Int)
    case storeImmediateBytes(Int, [UInt8]) // (dst, bytes) -- stores the given bytes sequentially in memory at the destination
    case storeImmediateBytesIndirect(Int, [UInt8]) // (dstPtr, bytes) -- stores the given bytes sequentially in memory at the destination. The destination address is located in memory at the address given by `dstPtr'.
    case label(String) // declares a label
    case jmp(String) // unconditional jump, no change to the stack
    case jalr(String) // unconditional jump-and-link, e.g., for a function call. Inserts code at the link point to clear the stack save for whatever value was in the A register.
    case indirectJalr(Int) // unconditional jump-and-link, e.g., for a function call. Inserts code at the link point to clear the stack save for whatever value was in the A register. The jump target is located in RAM at the specified address.
    case enter // push fp in two bytes ; fp <- sp
    case leave // sp <- fp ; fp <- pop two bytes from the stack
    case pushReturnAddress // push the link register (two bytes) to the stack
    case ret // pop the two byte return address and jump to that address
    case leafRet // Jump back to the address in the link register to return from the function
    case hlt // Halt the machine. This is useful for debugging.
    case peekPeripheral
    case pokePeripheral
    
    case add(Int, Int, Int)
    case add16(Int, Int, Int)
    case sub(Int, Int, Int)
    case sub16(Int, Int, Int)
    case mul(Int, Int, Int)
    case mul16(Int, Int, Int)
    case div(Int, Int, Int)
    case div16(Int, Int, Int)
    case mod(Int, Int, Int)
    case mod16(Int, Int, Int)
    case eq(Int, Int, Int)
    case eq16(Int, Int, Int)
    case ne(Int, Int, Int)
    case ne16(Int, Int, Int)
    case lt(Int, Int, Int)
    case lt16(Int, Int, Int)
    case gt(Int, Int, Int)
    case gt16(Int, Int, Int)
    case le(Int, Int, Int)
    case le16(Int, Int, Int)
    case ge(Int, Int, Int)
    case ge16(Int, Int, Int)
    case and(Int, Int, Int)
    case and16(Int, Int, Int)
    case or(Int, Int, Int)
    case or16(Int, Int, Int)
    case xor(Int, Int, Int)
    case xor16(Int, Int, Int)
    case lsl(Int, Int, Int)
    case lsl16(Int, Int, Int)
    case lsr(Int, Int, Int)
    case lsr16(Int, Int, Int)
    case neg(Int, Int)
    case neg16(Int, Int)
    case not(Int, Int)
    
    case jz(String, Int) // (label, test) -- Branch if the word in memory at the address given by `test' is zero
    case jnz(String, Int) // (label, test) -- Branch if the word in memory at the address given by `test' is non-zero
    
    case copyWordZeroExtend(Int, Int) // copies an 8-bit word at the specified source address to a 16-bit slot at the specified destination address, filling the high bits with zero
    
    case copyWords(Int, Int, Int) // (dst, src, N) -- copies N words starting at the specified source address to the destination address.
    
    case copyWordsIndirectSource(Int, Int, Int) // (dst, srcPtr, N) -- copies N words starting at the source address to the destination address. The source address is located in memory at the address given by `srcPtr'.
    
    case copyWordsIndirectDestination(Int, Int, Int) // (dstPtr, src, N) -- copies N words starting at the source address to the destination address. The destination address is located in memory at the address given by `dstPtr'.
    
    case copyWordsIndirectDestinationIndirectSource(Int, Int, Int) // (dstPtr, srcPtr, N) -- copies N words starting at the source address to the destination address. The destination address is located in memory at the address given by `dstPtr'. The source address is located in memory at the address given by `srcPtr'.
    
    case copyLabel(Int, String) // (dst, label) -- copies the two-byte address of the given label to the destination
    
    public var description: String {
        switch self {
        case .nop:
            return "NOP"
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
        case .muli16(let c, let a, let imm):
            return String(format: "MULI16 0x%04x, 0x%04x, 0x%04x", c, a, imm)
        case .storeImmediate(let address, let value):
            return String(format: "STORE-IMMEDIATE 0x%04x, 0x%02x", address, value)
        case .storeImmediate16(let address, let value):
            return String(format: "STORE-IMMEDIATE16 0x%04x, 0x%04x", address, value)
        case .storeImmediateBytes(let address, let bytes):
            if let unicodeScalars = String(bytes: bytes, encoding: .utf8)?.unicodeScalars {
                let string = unicodeScalars.map({$0.escaped(asASCII: true)}).joined()
                return String(format: "STORE-IMMEDIATE-BYTES 0x%04x, \"\(string)\"", address)
            } else {
                return String(format: "STORE-IMMEDIATE-BYTES 0x%04x, [%@]",
                              address,
                              bytes.map({String(format: "0x%02x", $0)}).joined(separator: ", "))
            }
        case .storeImmediateBytesIndirect(let dstPtr, let bytes):
            if let unicodeScalars = String(bytes: bytes, encoding: .utf8)?.unicodeScalars {
                let string = unicodeScalars.map({$0.escaped(asASCII: true)}).joined()
                return String(format: "STORE-IMMEDIATE-BYTES-INDIRECT 0x%04x, \"\(string)\"", dstPtr)
            } else {
                return String(format: "STORE-IMMEDIATE-BYTES-INDIRECT 0x%04x, [%@]",
                              dstPtr,
                              bytes.map({String(format: "0x%02x", $0)}).joined(separator: ", "))
            }
        case .label(let name):
            return "\(name):"
        case .jmp(let label):
            return "JMP \(label)"
        case .jalr(let label):
            return "JALR \(label)"
        case .indirectJalr(let address):
            return String(format: "INDIRECT-JALR 0x%04x", address)
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
        case .add(let c, let a, let b):
            return String(format: "ADD 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .add16(let c, let a, let b):
            return String(format: "ADD16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .sub(let c, let a, let b):
            return String(format: "SUB 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .sub16(let c, let a, let b):
            return String(format: "SUB16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .mul(let c, let a, let b):
            return String(format: "MUL 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .mul16(let c, let a, let b):
            return String(format: "MUL16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .div(let c, let a, let b):
            return String(format: "DIV 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .div16(let c, let a, let b):
            return String(format: "DIV16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .mod(let c, let a, let b):
            return String(format: "MOD 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .mod16(let c, let a, let b):
            return String(format: "MOD16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .eq(let c, let a, let b):
            return String(format: "EQ 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .eq16(let c, let a, let b):
            return String(format: "EQ16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .ne(let c, let a, let b):
            return String(format: "NE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .ne16(let c, let a, let b):
            return String(format: "NE16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .lt(let c, let a, let b):
            return String(format: "LT 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .lt16(let c, let a, let b):
            return String(format: "LT16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .gt(let c, let a, let b):
            return String(format: "GT 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .gt16(let c, let a, let b):
            return String(format: "GT16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .le(let c, let a, let b):
            return String(format: "LE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .le16(let c, let a, let b):
            return String(format: "LE16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .ge(let c, let a, let b):
            return String(format: "GE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .ge16(let c, let a, let b):
            return String(format: "GE16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .and(let c, let a, let b):
            return String(format: "AND 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .and16(let c, let a, let b):
            return String(format: "AND16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .or(let c, let a, let b):
            return String(format: "OR 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .or16(let c, let a, let b):
            return String(format: "OR16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .xor(let c, let a, let b):
            return String(format: "XOR 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .xor16(let c, let a, let b):
            return String(format: "XOR16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .lsl(let c, let a, let b):
            return String(format: "LSL 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .lsl16(let c, let a, let b):
            return String(format: "LSL16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .lsr(let c, let a, let b):
            return String(format: "LSR 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .lsr16(let c, let a, let b):
            return String(format: "LSR16 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .neg(let c, let a):
            return String(format: "NEG 0x%04x, 0x%04x", c, a)
        case .neg16(let c, let a):
            return String(format: "NEG16 0x%04x, 0x%04x", c, a)
        case .not(let c, let a):
            return String(format: "NOT 0x%04x, 0x%04x", c, a)
        case .jz(let label, let test):
            return String(format: "JZ %@, 0x%04x", label, test)
        case .jnz(let label, let test):
            return String(format: "JNZ %@, 0x%04x", label, test)
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
        case .copyLabel(let dst, let label):
            return String(format: "COPY-LABEL 0x%04x, %@", dst, label)
        }
    }
}
