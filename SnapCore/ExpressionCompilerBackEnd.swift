//
//  ExpressionCompilerBackEnd.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Takes some StackIR and generates corresponding machine code.
// For speed, we use the A and B registers as the top of the stack.
// (see also ExpressionCompilerFrontEnd)
public class ExpressionCompilerBackEnd: NSObject {
    let kScratchHi = 0
    let kScratchLo = 2
    let kStackPointerHiHi = Int((SnapCodeGenerator.kStackPointerAddressHi & 0xff00) >> 8)
    let kStackPointerHiLo = Int( SnapCodeGenerator.kStackPointerAddressHi & 0x00ff)
    let kStackPointerLoHi = Int((SnapCodeGenerator.kStackPointerAddressLo & 0xff00) >> 8)
    let kStackPointerLoLo = Int( SnapCodeGenerator.kStackPointerAddressLo & 0x00ff)
    let assembler: AssemblerBackEnd
    var stackDepth = 0
    
    public init(assembler: AssemblerBackEnd) {
        self.assembler = assembler
    }
    
    public func compile(ir: [StackIR]) throws {
        for instruction in ir {
            switch instruction {
            case .push(let value): try push(value)
            case .pop: try pop()
            case .add: try add()
            default:
                throw CompilerError(message: "ExpressionCompilerBackEnd: unsupported instruction `\(instruction)\'")
            }
        }
    }
    
    fileprivate func push(_ value: Int) throws {
        if stackDepth == 0 {
            try assembler.li(.A, value)
        } else if stackDepth == 1 {
            try assembler.mov(.B, .A)
            try assembler.li(.A, value)
        } else {
            try pushToStackInMemory(value)
        }
        stackDepth += 1
    }
    
    fileprivate func pushToStackInMemory(_ value: Int) throws {
        try decrementStackPointer()
        
        // Load the 16-bit stack pointer into UV.
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.X, .M)
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.Y, .M)
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        
        // Store B to the top of the in-memory stack.
        try assembler.mov(.M, .B)
        
        // Move A into B
        try assembler.mov(.B, .A)
        
        // Finally, move the new value to push into A.
        try assembler.li(.A, value)
    }
    
    fileprivate func decrementStackPointer() throws {
        // Save A in a well-known scratch location.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo)
        try assembler.mov(.M, .A)
        
        // Decrement the low byte of the 16-bit stack pointer.
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.A, .M)
        try assembler.dea(.NONE)
        try assembler.dea(.A)
        try assembler.mov(.M, .A)
        
        // Decrement the high byte of the 16-bit stack pointer, but only if the
        // above decrement set the carry flag.
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.A, .M)
        try assembler.dca(.NONE)
        try assembler.dca(.A)
        try assembler.mov(.M, .A)
        
        // Restore A
        // (We saved this to a well-known scratch location earlier.)
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo)
        try assembler.mov(.A, .M)
    }
    
    fileprivate func pop() throws {
        if stackDepth == 0 {
            throw CompilerError(message: "ExpressionCompilerBackEnd: cannot pop when stack is empty")
        } else if stackDepth == 1 {
            try assembler.li(.A, 0) // Clear A. This is not actually necessary.
        } else if stackDepth == 2 {
            try assembler.mov(.A, .B)
            try assembler.li(.B, 0) // Clear B. This is not actually necessary.
        } else {
            try assembler.mov(.A, .B)
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    fileprivate func popInMemoryStackIntoRegisterB() throws {
        // Load the 16-bit stack pointer into XY.
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.X, .M)
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.Y, .M)
        
        // Shift the top of the in-memory stack into B.
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        try assembler.mov(.B, .M)
        
        // Increment the stack pointer.
        assembler.inxy()
        
        // Write the modified stack pointer back to memory.
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.M, .X)
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.M, .Y)
    }
    
    fileprivate func add() throws {
        if stackDepth < 2 {
            throw CompilerError(message: "ExpressionCompilerBackEnd: stack underflow during ADD")
        } else if stackDepth == 2 {
            try assembler.add(.NONE)
            try assembler.add(.A)
        } else {
            try assembler.add(.NONE)
            try assembler.add(.A)
            try popInMemoryStackIntoRegisterB()
        }
    }
}
