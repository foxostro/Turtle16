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
    case push(Int) // push the specified value to the stack
    case pop // pop the stack
    case eq  // pop two from the stack, (A==B)?1:0, push the result
    case ne  // pop two from the stack, (A!=B)?1:0, push the result
    case lt  // pop two from the stack, (A<B)?1:0, push the result
    case gt  // pop two from the stack, (A>B)?1:0, push the result
    case le  // pop two from the stack, (A<=B)?1:0, push the result
    case ge  // pop two from the stack, (A>=B)?1:0, push the result
    case add // pop two from the stack, A+B, push the result
    case sub // pop two from the stack, A-B, push the result
    case mul // pop two from the stack, A*B, push the result
    case div // pop two from the stack, A/B, push the result
    case mod // pop two from the stack, A%B, push the result
    case load(Int) // load from the specified address, push to the stack
    case store(Int) // pop the stack and store to the specified address
    case label(TokenIdentifier) // declares a label
    case jmp(TokenIdentifier) // unconditional jump, no change to the stack
    case je(TokenIdentifier) // pop two from the stack, jump if they are equal
    
    public var description: String {
        switch self {
        case .push(let value):
            return "PUSH \(value)"
        case .pop:
            return "POP"
        case .eq:
            return "EQ"
        case .ne:
            return "NE"
        case .lt:
            return "LT"
        case .gt:
            return "GT"
        case .le:
            return "LE"
        case .ge:
            return "GE"
        case .add:
            return "ADD"
        case .sub:
            return "SUB"
        case .mul:
            return "MUL"
        case .div:
            return "DIV"
        case .mod:
            return "MOD"
        case .load(let address):
            return String(format: "LOAD 0x%04x", address)
        case .store(let address):
            return String(format: "STORE 0x%04x", address)
        case .label(let token):
            return "\(token.lexeme):"
        case .jmp(let token):
            return "JMP \(token.lexeme)"
        case .je(let token):
            return "JE \(token.lexeme)"
        }
    }
    
    public static func makeListing(instructions: [YertleInstruction]) -> String {
        return instructions.map{ $0.description }.joined(separator: "\n") + "\n"
    }
}
