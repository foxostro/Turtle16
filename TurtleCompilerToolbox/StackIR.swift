//
//  StackIR.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public enum StackIR: Equatable {
    case push(Int) // push the specified value to the stack
    case pop // pop the stack
    case add // pop two from the stack, A+B, push the result
    case sub // pop two from the stack, A-B, push the result
    case mul // pop two from the stack, A*B, push the result
    case div // pop two from the stack, A/B, push the result
    case mod // pop two from the stack, A%B, push the result
    case load(Int) // load from the specified address, push to the stack
}
