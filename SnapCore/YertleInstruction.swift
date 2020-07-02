//
//  YertleInstruction.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Defines a stack-based intermediate representation, "Yertle" for the
// Snap compiler. The intermediate language has no textual representation.
// It's nothing more than a list of these instructions.
public enum YertleInstruction: Equatable {
    case push(Int) // push the specified word-sized value to the stack
    case push16(Int) // push the specified sixteen-bit double-word-sized value to the stack
    case pop // pop the stack
    case pop16 // pop a sixteen-bit value from the stack
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
    case storeIndirect // Pop a sixteen-bit address from the stack. Peek at the eight-bit value on the top of the stack. Store that eight-bit value at the specified address.
    case storeIndirect16 // Pop a sixteen-bit address from the stack. Peek at the sixteen-bit value on the top of the stack. Store that sixteen-bit value at the specified address.
    case label(TokenIdentifier) // declares a label
    case jmp(TokenIdentifier) // unconditional jump, no change to the stack
    case je(TokenIdentifier) // pop two from the stack, jump if they are equal
    case jalr(TokenIdentifier) // unconditional jump-and-link, e.g., for a function call. Inserts code at the link point to clear the stack save for whatever value was in the A register.
    case enter // push fp in two bytes ; fp <- sp
    case leave // sp <- fp ; fp <- pop two bytes from the stack
    case pushReturnAddress // push the link register (two bytes) to the stack
    case ret // pop the two byte return address and jump to that address
    case leafRet // Jump back to the address in the link register to return from the function
    case hlt // Halt the machine. This is useful for debugging.
    
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
        case .storeIndirect:
            return "STORE-INDIRECT"
        case .storeIndirect16:
            return "STORE-INDIRECT16"
        case .label(let token):
            return "\(token.lexeme):"
        case .jmp(let token):
            return "JMP \(token.lexeme)"
        case .je(let token):
            return "JE \(token.lexeme)"
        case .jalr(let token):
            return "JALR \(token.lexeme)"
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
        }
    }
    
    public static func makeListing(instructions: [YertleInstruction]) -> String {
        return instructions.map{ $0.description }.joined(separator: "\n") + "\n"
    }
}
