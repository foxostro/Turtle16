//
//  YertleToTurtleMachineCodeCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

// Takes some YertleInstruction and generates corresponding machine code.
// For speed, we use the A and B registers as the top of the stack.
// (see also ExpressionSubCompiler)
public class YertleToTurtleMachineCodeCompiler: NSObject {
    // Programs written in Snap store the stack pointer in data RAM at
    // addresses 0x0000 and 0x0001. This is initialized on launch to 0xffff.
    public static let kStackPointerAddressHi: UInt16 = 0x0000
    public static let kStackPointerAddressLo: UInt16 = 0x0001
    public static let kStackPointerInitialValue: Int = 0x0000
    
    public let symbols: SymbolTable
    public private(set) var instructions: [Instruction] = []
    private var patcherActions: [Patcher.Action] = []
    
    let kScratchHi = 0
    let kScratchLo = 2
    let kStackPointerHiHi = Int((YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi & 0xff00) >> 8)
    let kStackPointerHiLo = Int( YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi & 0x00ff)
    let kStackPointerLoHi = Int((YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo & 0xff00) >> 8)
    let kStackPointerLoLo = Int( YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo & 0x00ff)
    let kStackPointerInitialValueHi: Int = (kStackPointerInitialValue & 0xff00) >> 8
    let kStackPointerInitialValueLo: Int =  kStackPointerInitialValue & 0x00ff
    let assembler: AssemblerBackEnd
    var stackDepth = 0
    
    public init(assembler: AssemblerBackEnd, symbols: SymbolTable = SymbolTable()) {
        self.assembler = assembler
        self.symbols = symbols
    }
    
    public func compile(ir: [YertleInstruction], base: Int) throws {
        patcherActions = []
        assembler.begin()
        try insertProgramPrologue()
        for instruction in ir {
            switch instruction {
            case .push(let value): try push(value)
            case .pop: try pop()
            case .eq:  try eq()
            case .ne:  try ne()
            case .lt:  try lt()
            case .gt:  try gt()
            case .le:  try le()
            case .ge:  try ge()
            case .add: try add()
            case .sub: try sub()
            case .mul: try mul()
            case .div: try div()
            case .mod: try mod()
            case .load(let address): try load(from: address)
            case .store(let address): try store(to: address)
            case .label(let token): try label(token: token)
            case .jmp(let token): try jmp(to: token)
            case .je(let token): try je(to: token)
            }
        }
        insertProgramEpilogue()
        assembler.end()
        let resolver: (TokenIdentifier) throws -> Int = {[weak self] (identifier: TokenIdentifier) in
            let symbol = try self!.symbols.resolve(identifierToken: identifier)
            switch symbol {
            case .label(let value):
                return value
            default:
                throw CompilerError(line: identifier.lineNumber, message: "cannot resolve a label with the symbol `\(identifier.lexeme)' of type `\(String(describing: symbol))'")
            }
        }
        let patcher = Patcher(inputInstructions: assembler.instructions,
                              resolver: resolver,
                              actions: patcherActions,
                              base: base)
        instructions = try patcher.patch()
    }
    
    // Inserts prologue code into the program, presumably at the beginning.
    // Insert a NOP at the beginning of every program because correct operation
    // of the hardware reset cycle requires this.
    // Likewise, correct operation of a program written in Snap requires some
    // inititalization to be performed before anything else occurs.
    func insertProgramPrologue() throws {
        assembler.nop()
        try assembler.li(.X, kStackPointerHiHi)
        try assembler.li(.Y, kStackPointerHiLo)
        try assembler.li(.M, kStackPointerInitialValueHi)
        try assembler.li(.X, kStackPointerLoHi)
        try assembler.li(.Y, kStackPointerLoLo)
        try assembler.li(.M, kStackPointerInitialValueLo)
    }
    
    // Inserts epilogue code into the program, presumably at the end.
    func insertProgramEpilogue() {
        assembler.hlt()
    }
    
    private func push(_ value: Int) throws {
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
    
    private func pushToStackInMemory(_ value: Int) throws {
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
    
    private func decrementStackPointer() throws {
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
    
    private func pop() throws {
        if stackDepth == 0 {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: cannot pop when stack is empty")
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
    
    private func popInMemoryStackIntoRegisterB() throws {
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
    
    private func eq() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during EQ")
        }
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.A, 1)
        assembler.je()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        assert(assembler.programCounter == jumpTarget)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    private func ne() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during NE")
        }
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.A, 1)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        assert(assembler.programCounter == jumpTarget)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    private func lt() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during LT")
        }
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.A, 1)
        assembler.jl()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        assert(assembler.programCounter == jumpTarget)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    private func gt() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during GT")
        }
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.A, 1)
        assembler.jg()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        assert(assembler.programCounter == jumpTarget)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    private func le() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during LE")
        }
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.A, 1)
        assembler.jle()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        assert(assembler.programCounter == jumpTarget)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    private func ge() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during GE")
        }
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.A, 1)
        assembler.jge()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        assert(assembler.programCounter == jumpTarget)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    private func add() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during ADD")
        }
        try assembler.add(.NONE)
        try assembler.add(.A)
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        stackDepth -= 1
    }
    
    private func sub() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during SUB")
        }
        try assembler.sub(.NONE)
        try assembler.sub(.A)
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        stackDepth -= 1
    }
    
    private func mul() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during MUL")
        }
        
        // A is the Multiplicand, B is the Multiplier
        let multiplierAddress = kScratchLo
        let multiplicandAddress = kScratchLo+1
        let resultAddress = kScratchLo+2
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, multiplierAddress)
        try assembler.mov(.M, .B)
        try assembler.li(.V, multiplicandAddress)
        try assembler.mov(.M, .A)
        try assembler.li(.V, resultAddress)
        try assembler.li(.M, 0)
        
        let loopHead = assembler.programCounter
        let loopTail = loopHead + 26
        
        // If the multiplier is equal to zero then bail because we're done.
        try assembler.li(.X, (loopTail & 0xff00) >> 8)
        try assembler.li(.Y,  loopTail & 0x00ff)
        try assembler.li(.V, multiplierAddress)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.je()
        assembler.nop()
        assembler.nop()
        
        // Add the multiplicand to the result.
        try assembler.li(.V, multiplicandAddress)
        try assembler.mov(.B, .M)
        try assembler.li(.V, resultAddress)
        try assembler.mov(.A, .M)
        try assembler.add(.NONE)
        try assembler.add(.M)
        
        // Decrement the multiplier.
        try assembler.li(.V, multiplierAddress)
        try assembler.mov(.A, .M)
        try assembler.dea(.NONE)
        try assembler.dea(.M)

        // Jump back to the beginning of the loop
        try assembler.li(.X, (loopHead & 0xff00) >> 8)
        try assembler.li(.Y,  loopHead & 0x00ff)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        assert(assembler.programCounter == loopTail)
        
        // Load the result into A.
        try assembler.li(.V, resultAddress)
        try assembler.mov(.A, .M)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        stackDepth -= 1
    }
    
    private func div() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during DIV")
        }
        
        // A is the Dividend, B is the Divisor
        let a = kScratchLo+0
        let b = kScratchLo+1
        let counter = kScratchLo+2
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, a)
        try assembler.mov(.M, .A)
        try assembler.li(.V, b)
        try assembler.mov(.M, .B)
        try assembler.li(.V, counter)
        try assembler.li(.M, 0)
        
        let loopHead = assembler.programCounter + 11
        let loopTail = loopHead + 28
        
        // if b == 0 then bail because it's division by zero
        try assembler.li(.X, (loopTail & 0xff00) >> 8)
        try assembler.li(.Y,  loopTail & 0x00ff)
        try assembler.li(.V, b)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.je()
        assembler.nop()
        assembler.nop()
        
        // while a >= b
        assert(assembler.programCounter == loopHead)
        try assembler.li(.X, (loopTail & 0xff00) >> 8)
        try assembler.li(.Y,  loopTail & 0x00ff)
        try assembler.li(.V, a)
        try assembler.mov(.A, .M)
        try assembler.li(.V, b)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jl()
        assembler.nop()
        assembler.nop()
        
        // a = a - b
        try assembler.li(.V, b)
        try assembler.mov(.B, .M)
        try assembler.li(.V, a)
        try assembler.mov(.A, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        
        // c += 1
        try assembler.li(.V, counter)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 1)
        try assembler.add(.NONE)
        try assembler.add(.M)

        // loop
        try assembler.li(.X, (loopHead & 0xff00) >> 8)
        try assembler.li(.Y,  loopHead & 0x00ff)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        assert(assembler.programCounter == loopTail)
        
        // Return the result in the A register.
        try assembler.li(.V, counter)
        try assembler.mov(.A, .M)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        stackDepth -= 1
    }
    
    private func mod() throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during MOD")
        }
        
        // A is the Dividend, B is the Divisor
        let a = kScratchLo+0
        let b = kScratchLo+1
        let counter = kScratchLo+2
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, a)
        try assembler.mov(.M, .A)
        try assembler.li(.V, b)
        try assembler.mov(.M, .B)
        try assembler.li(.V, counter)
        try assembler.li(.M, 0)
        
        let loopHead = assembler.programCounter + 11
        let loopTail = loopHead + 28
        
        // if b == 0 then bail because it's division by zero
        try assembler.li(.X, (loopTail & 0xff00) >> 8)
        try assembler.li(.Y,  loopTail & 0x00ff)
        try assembler.li(.V, b)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.je()
        assembler.nop()
        assembler.nop()
        
        // while a >= b
        assert(assembler.programCounter == loopHead)
        try assembler.li(.X, (loopTail & 0xff00) >> 8)
        try assembler.li(.Y,  loopTail & 0x00ff)
        try assembler.li(.V, a)
        try assembler.mov(.A, .M)
        try assembler.li(.V, b)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jl()
        assembler.nop()
        assembler.nop()
        
        // a = a - b
        try assembler.li(.V, b)
        try assembler.mov(.B, .M)
        try assembler.li(.V, a)
        try assembler.mov(.A, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        
        // c += 1
        try assembler.li(.V, counter)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 1)
        try assembler.add(.NONE)
        try assembler.add(.M)

        // loop
        try assembler.li(.X, (loopHead & 0xff00) >> 8)
        try assembler.li(.Y,  loopHead & 0x00ff)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        assert(assembler.programCounter == loopTail)
        
        // Return the result in the A register.
        try assembler.li(.V, a)
        try assembler.mov(.A, .M)
        
        if stackDepth > 2 {
            try popInMemoryStackIntoRegisterB()
        }
        stackDepth -= 1
    }
    
    private func load(from address: Int) throws {
        if stackDepth == 0 {
            try assembler.li(.U, (address & 0xff00) >> 8)
            try assembler.li(.V,  address & 0x00ff)
            try assembler.mov(.A, .M)
        } else if stackDepth == 1 {
            try assembler.mov(.B, .A)
            try assembler.li(.U, (address & 0xff00) >> 8)
            try assembler.li(.V,  address & 0x00ff)
            try assembler.mov(.A, .M)
        } else {
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
            
            // Finally, load the value from RAM and push into A.
            try assembler.li(.U, (address & 0xff00) >> 8)
            try assembler.li(.V,  address & 0x00ff)
            try assembler.mov(.A, .M)
        }
        stackDepth += 1
    }
    
    private func store(to address: Int) throws {
        guard stackDepth > 0 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during STORE")
        }
        
        try assembler.li(.U, (address & 0xff00) >> 8)
        try assembler.li(.V,  address & 0x00ff)
        try assembler.mov(.M, .A)
        
        try assembler.mov(.A, .B)
        
        if stackDepth > 1 {
            try popInMemoryStackIntoRegisterB()
        }
        
        stackDepth -= 1
    }
    
    private func label(token: TokenIdentifier) throws {
        let name = token.lexeme
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: token.lineNumber,
                                format: "label redefines existing symbol: `%@'",
                                token.lexeme)
        }
        symbols.bindLabel(identifier: name, value: assembler.programCounter)
    }
    
    private func jmp(to token: TokenIdentifier) throws {
        try setAddressToLabel(token)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    private func je(to token: TokenIdentifier) throws {
        guard stackDepth >= 2 else {
            throw CompilerError(message: "YertleToTurtleMachineCodeCompiler: stack underflow during JE")
        }
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(token)
        assembler.je()
        assembler.nop()
        assembler.nop()
        
        try pop()
        try pop()
    }
    
    func setAddressToLabel(_ name: TokenIdentifier) throws {
        patcherActions.append((index: assembler.programCounter,
                               symbol: name,
                               shift: 8))
        try assembler.li(.X, 0xff)
        patcherActions.append((index: assembler.programCounter,
                               symbol: name,
                               shift: 0))
        try assembler.li(.Y, 0xff)
    }
}
