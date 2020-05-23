//
//  ExpressionCompilerBackEnd.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Takes some StackIR and generates corresponding machine code.
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
            case .push(let value):
                try push(value)
                
            default:
                abort()
            }
        }
    }
    
    func push(_ value: Int) throws {
        // For speed, we use the A and B registers as the top of the stack.
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
        // TODO: This only does an 8-bit subtract; need to do 16-bit.
        
        // Save A in a well-known scratch location.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo)
        try assembler.mov(.M, .A)
        
        // Write the new stack pointer high byte back to memory.
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.li(.M, 0xff)
        
        // Load the low byte of the 16-bit stack pointer into A.
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.A, .M)
        
        // Decrement the low byte of the stack pointer in A.
        try assembler.dea(.NONE)
        try assembler.dea(.A)
        
        // Write the new stack pointer low byte to memory.
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.M, .A)
        
        // Restore A
        // (We saved this to a well-known scratch location earlier.)
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo)
        try assembler.mov(.A, .M)
    }
}
