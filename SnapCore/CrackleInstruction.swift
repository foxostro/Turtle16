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
    case pushsp // push the value of stack pointer (before instruction executes) to the stack
    case pop // pop the stack
    case pop16 // pop a sixteen-bit value from the stack
    case popn(Int) // pop the specified number of words from the stack
    case eq  // pop two from the stack, (A==B)?1:0, push the result
    case eq16  // pop two 16-bit values from the stack, (A==B)?1:0, push the result in one word
    case ne  // pop two from the stack, (A!=B)?1:0, push the result
    case ne16  // pop two 16-bit values from the stack, (A!=B)?1:0, push the result in one word
    case lt  // pop two from the stack, (A<B)?1:0, push the result
    case lt16  // pop two 16-bit values from the stack, (A<B)?1:0, push the result in one word
    case gt  // pop two from the stack, (A>B)?1:0, push the result
    case gt16 // pop two 16-bit values from the stack, (A>B)?1:0, push the result in one word
    case le  // pop two from the stack, (A<=B)?1:0, push the result
    case le16 // pop two 16-bit values from the stack, (A<=B)?1:0, push the result in one word
    case ge  // pop two from the stack, (A>=B)?1:0, push the result
    case ge16 // pop two 16-bit values from the stack, (A>=B)?1:0, push the result in one word
    case add // pop two from the stack, A+B, push the result
    case add16 // pop two 16-bit values from the stack, A+B, push the result in two words
    case sub // pop two from the stack, A-B, push the result
    case sub16 // pop two 16-bit values from the stack, A-B, push the result in two words
    case mul // pop two from the stack, A*B, push the result
    case mul16 // pop two 16-bit values from the stack, A*B, push the result in two words
    case div // pop two from the stack, A/B, push the result
    case div16 // pop two 16-bit values from the stack, A/B, push the result in two words
    case mod // pop two from the stack, A%B, push the result
    case mod16 // pop two 16-bit values from the stack, A%B, push the result in two words
    case load(Int) // load from the specified address, push to the stack
    case load16(Int) // load a 16-bit value from the specified address, push to the stack in two words
    case store(Int) // peek at the stack top and store that value to the specified address
    case store16(Int) // peek at the top two bytes of the stack and store that 16-bit value to the specified address
    case loadIndirect // Pop a sixteen-bit address from the stack. Load the eight-bit value at that address and push it to the stack.
    case loadIndirect16 // Pop a sixteen-bit address from the stack. Load the sixteen-bit value at that address and push it to the stack.
    case loadIndirectN(Int) // Pop a sixteen-bit address from the stack. Load the N words in memory at that address and push them to the stack as a unit.
    case storeIndirect // Pop a sixteen-bit address from the stack. Peek at the eight-bit value on the top of the stack. Store that eight-bit value at the specified address.
    case storeIndirect16 // Pop a sixteen-bit address from the stack. Peek at the sixteen-bit value on the top of the stack. Store that sixteen-bit value at the specified address.
    case storeIndirectN(Int) // Pop a sixteen-bit address from the stack. Peek at the top N words on the stack and store them linearly in memory, starting at the specified address.
    case label(String) // declares a label
    case jmp(String) // unconditional jump, no change to the stack
    case je(String) // pop two from the stack, jump if they are equal
    case jalr(String) // unconditional jump-and-link, e.g., for a function call. Inserts code at the link point to clear the stack save for whatever value was in the A register.
    case enter // push fp in two bytes ; fp <- sp
    case leave // sp <- fp ; fp <- pop two bytes from the stack
    case pushReturnAddress // push the link register (two bytes) to the stack
    case ret // pop the two byte return address and jump to that address
    case leafRet // Jump back to the address in the link register to return from the function
    case hlt // Halt the machine. This is useful for debugging.
    case peekPeripheral
    case pokePeripheral
    case dup
    case dup16
    
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
    case tac_gt(Int, Int, Int)
    case tac_le(Int, Int, Int)
    case tac_ge(Int, Int, Int)
    
    public var description: String {
        switch self {
        case .push(let value):
            return String(format: "PUSH 0x%02x", value)
        case .push16(let value):
            return String(format: "PUSH16 0x%04x", value)
        case .pushsp:
            return String(format: "PUSH-SP")
        case .pop:
            return "POP"
        case .popn(let count):
            return "POPN \(count)"
        case .pop16:
            return "POP16"
        case .eq:
            return "EQ"
        case .eq16:
            return "EQ16"
        case .ne:
            return "NE"
        case .ne16:
            return "NE16"
        case .lt:
            return "LT"
        case .lt16:
            return "LT16"
        case .gt:
            return "GT"
        case .gt16:
            return "GT16"
        case .le:
            return "LE"
        case .le16:
            return "LE16"
        case .ge:
            return "GE"
        case .ge16:
            return "GE16"
        case .add:
            return "ADD"
        case .add16:
            return "ADD16"
        case .sub:
            return "SUB"
        case .sub16:
            return "SUB16"
        case .mul:
            return "MUL"
        case .mul16:
            return "MUL16"
        case .div:
            return "DIV"
        case .div16:
            return "DIV16"
        case .mod:
            return "MOD"
        case .mod16:
            return "MOD16"
        case .load(let address):
            return String(format: "LOAD 0x%04x", address)
        case .load16(let address):
            return String(format: "LOAD16 0x%04x", address)
        case .store(let address):
            return String(format: "STORE 0x%04x", address)
        case .store16(let address):
            return String(format: "STORE16 0x%04x", address)
        case .loadIndirect:
            return "LOAD-INDIRECT"
        case .loadIndirect16:
            return "LOAD-INDIRECT16"
        case .loadIndirectN(let count):
            return "LOAD-INDIRECTN \(count)"
        case .storeIndirect:
            return "STORE-INDIRECT"
        case .storeIndirect16:
            return "STORE-INDIRECT16"
        case .storeIndirectN(let count):
            return "STORE-INDIRECTN \(count)"
        case .label(let name):
            return "\(name):"
        case .jmp(let label):
            return "JMP \(label)"
        case .je(let label):
            return "JE \(label)"
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
        case .dup:
            return "DUP"
        case .dup16:
            return "DUP16"
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
        case .tac_gt(let c, let a, let b):
            return String(format: "GT 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_le(let c, let a, let b):
            return String(format: "LE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        case .tac_ge(let c, let a, let b):
            return String(format: "GE 0x%04x, 0x%04x, 0x%04x", c, a, b)
        }
    }
    
    public static func makeListing(instructions: [CrackleInstruction]) -> String {
        return instructions.map{ $0.description }.joined(separator: "\n") + "\n"
    }
}
