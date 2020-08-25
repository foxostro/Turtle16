//
//  CrackleToTurtleMachineCodeCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

// Generates machine code for given IR code.
public class CrackleToTurtleMachineCodeCompiler: NSObject {
    // Programs written in Snap use a push down stack, and store the stack
    // pointer in data RAM at addresses 0x0000 and 0x0001.
    // This is initialized on launch to 0x0000.
    public static let kStackPointerAddressHi: UInt16 = 0x0000
    public static let kStackPointerAddressLo: UInt16 = 0x0001
    public static let kStackPointerInitialValue: Int = 0x0000
    let kStackPointerAddressHi: Int = Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi)
    let kStackPointerAddressLo: Int = Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressLo)
    let kStackPointerHiHi = Int((CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi & 0xff00) >> 8)
    let kStackPointerHiLo = Int( CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi & 0x00ff)
    let kStackPointerLoHi = Int((CrackleToTurtleMachineCodeCompiler.kStackPointerAddressLo & 0xff00) >> 8)
    let kStackPointerLoLo = Int( CrackleToTurtleMachineCodeCompiler.kStackPointerAddressLo & 0x00ff)
    let kStackPointerInitialValueHi: Int = (kStackPointerInitialValue & 0xff00) >> 8
    let kStackPointerInitialValueLo: Int =  kStackPointerInitialValue & 0x00ff
    
    // Programs written in Snap store the frame pointer in data RAM at
    // addresses 0x0002 and 0x0003. This is initialized on launch to 0x0000.
    public static let kFramePointerAddressHi: UInt16 = 0x0002
    public static let kFramePointerAddressLo: UInt16 = 0x0003
    public static let kFramePointerInitialValue: Int = 0x0000
    let kFramePointerAddressHi: Int = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    let kFramePointerAddressLo: Int = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    let kFramePointerHiHi = Int((CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi & 0xff00) >> 8)
    let kFramePointerHiLo = Int( CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi & 0x00ff)
    let kFramePointerLoHi = Int((CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo & 0xff00) >> 8)
    let kFramePointerLoLo = Int( CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo & 0x00ff)
    let kFramePointerInitialValueHi: Int = (kFramePointerInitialValue & 0xff00) >> 8
    let kFramePointerInitialValueLo: Int =  kFramePointerInitialValue & 0x00ff
    
    private var beginningOfScratchMemory = 0x0004
    private var scratchPointer: Int
    
    let assembler: AssemblerBackEnd
    var patcherActions: [Patcher.Action] = []
    
    public private(set) var labelTable: [String:Int] = [:]
    public private(set) var instructions: [Instruction] = []
    private var mapAssemblyInstructionToSource: [Int:SourceAnchor?] = [:]
    public private(set) var mapProgramCounterToSource: [Int:SourceAnchor?] = [:]
    private var mapAssemblyInstructionToCrackleInstruction: [Int:CrackleInstruction] = [:]
    public private(set) var mapProgramCounterToCrackleInstruction: [Int:CrackleInstruction] = [:]
    private var currentSourceAnchor: SourceAnchor? = nil
    
    let labelMaker = LabelMaker(prefix: ".LL")
    
    public var injectCode: (CrackleToTurtleMachineCodeCompiler) throws -> Void = {_ in}
    
    public init(assembler: AssemblerBackEnd) {
        self.assembler = assembler
        scratchPointer = beginningOfScratchMemory
    }
    
    private func allocateScratchMemory(_ numWords: Int) -> Int {
        let result = scratchPointer
        scratchPointer += numWords
        return result
    }
    
    private func setUV(_ value: Int) throws {
        try assembler.li(.U, (value>>8) & 0xff)
        try assembler.li(.V, value & 0xff)
    }
    
    private func setXY(_ value: Int) throws {
        try assembler.li(.X, (value>>8) & 0xff)
        try assembler.li(.Y, value & 0xff)
    }
    
    public func compile(ir: [CrackleInstruction],
                        mapCrackleInstructionToSource: [Int:SourceAnchor?] = [:],
                        base: Int = 0x0000) throws {
        patcherActions = []
        assembler.begin()
        try insertProgramPrologue()
        try compileProgramBody(ir, mapCrackleInstructionToSource)
        try insertProgramEpilogue()
        assembler.end()
        let resolver: (SourceAnchor?, String) throws -> Int = {[weak self] (sourceAnchor: SourceAnchor?, identifier: String) in
            if let address = self!.labelTable[identifier] {
                return address
            } else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "cannot resolve label `\(identifier)'")
            }
        }
        let patcher = Patcher(inputInstructions: assembler.instructions,
                              resolver: resolver,
                              actions: patcherActions,
                              base: base)
        instructions = try patcher.patch()
        
        for (instructionIndex, sourceAnchor) in mapAssemblyInstructionToSource {
            mapProgramCounterToSource[instructionIndex+base] = sourceAnchor
        }
        
        for (instructionIndex, crackleInstruction) in mapAssemblyInstructionToCrackleInstruction {
            mapProgramCounterToCrackleInstruction[instructionIndex+base] = crackleInstruction
        }
    }
    
    // Inserts prologue code into the program, presumably at the beginning.
    // Insert a NOP at the beginning of every program because correct operation
    // of the hardware reset cycle requires this.
    // Likewise, correct operation of a program written in Snap requires some
    // inititalization to be performed before anything else occurs.
    func insertProgramPrologue() throws {
        assembler.nop()
        try setUV(0)
        try assembler.li(.M, kStackPointerInitialValueHi)
        assembler.inuv()
        try assembler.li(.M, kStackPointerInitialValueLo)
        assembler.inuv()
        try assembler.li(.M, kFramePointerInitialValueHi)
        assembler.inuv()
        try assembler.li(.M, kFramePointerInitialValueLo)
    }
    
    private func compileProgramBody(_ ir: [CrackleInstruction], _ mapCrackleInstructionToSource: [Int : SourceAnchor?]) throws {
        for i in 0..<ir.count {
            currentSourceAnchor = mapCrackleInstructionToSource[i] ?? nil
            let instruction = ir[i]
            try compileSingleCrackleInstruction(instruction)
        }
    }
    
    private func compileSingleCrackleInstruction(_ instruction: CrackleInstruction) throws {
        scratchPointer = beginningOfScratchMemory
        let instructionsBegin = assembler.instructions.count
        switch instruction {
        case .push(let value): try push(value)
        case .push16(let value): try push16(value)
        case .pushsp: try pushsp()
        case .pop: try pop()
        case .pop16: try pop16()
        case .popn(let count): try popn(count)
        case .eq:  try eq()
        case .eq16:  try eq16()
        case .ne:  try ne()
        case .ne16:  try ne16()
        case .lt:  try lt()
        case .lt16:  try lt16()
        case .gt:  try gt()
        case .gt16:  try gt16()
        case .le:  try le()
        case .le16:  try le16()
        case .ge:  try ge()
        case .ge16:  try ge16()
        case .add: try add()
        case .add16: try add16()
        case .sub: try sub()
        case .sub16: try sub16()
        case .mul: try mul()
        case .mul16: try mul16()
        case .div: try div()
        case .div16: try div16()
        case .mod: try mod()
        case .mod16: try mod16()
        case .load(let address): try load(from: address)
        case .load16(let address): try load16(from: address)
        case .store(let address): try store(to: address)
        case .storeImmediate(let address, let value): try storeImmediate(address, value)
        case .store16(let address): try store16(to: address)
        case .storeImmediate16(let address, let value): try storeImmediate16(address, value)
        case .loadIndirect: try loadIndirect()
        case .loadIndirect16: try loadIndirect16()
        case .loadIndirectN(let count): try loadIndirectN(count)
        case .storeIndirect: try storeIndirect()
        case .storeIndirect16: try storeIndirect16()
        case .storeIndirectN(let count): try storeIndirectN(count)
        case .label(let name): try label(name)
        case .jmp(let label): try jmp(label)
        case .je(let label): try je(label)
        case .jalr(let label): try jalr(label)
        case .enter: try enter()
        case .leave: try leave()
        case .pushReturnAddress: try pushReturnAddress()
        case .leafRet: try leafRet()
        case .ret: try ret()
        case .hlt: hlt()
        case .peekPeripheral: try peekPeripheral()
        case .pokePeripheral: try pokePeripheral()
        case .dup: try dup()
        case .dup16: try dup16()
        case .tac_add(let c, let a, let b): try tac_add(c, a, b)
        case .tac_add16(let c, let a, let b): try tac_add16(c, a, b)
        case .tac_sub(let c, let a, let b): try tac_sub(c, a, b)
        case .tac_sub16(let c, let a, let b): try tac_sub16(c, a, b)
        case .tac_mul(let c, let a, let b): try tac_mul(c, a, b)
        case .tac_mul16(let c, let a, let b): try tac_mul16(c, a, b)
        case .tac_div(let c, let a, let b): try tac_div(c, a, b)
        case .tac_div16(let c, let a, let b): try tac_div16(c, a, b)
        case .tac_mod(let c, let a, let b): try tac_mod(c, a, b)
        case .tac_mod16(let c, let a, let b): try tac_mod16(c, a, b)
        case .tac_eq(let c, let a, let b): try tac_eq(c, a, b)
        case .tac_eq16(let c, let a, let b): try tac_eq16(c, a, b)
        case .tac_ne(let c, let a, let b): try tac_ne(c, a, b)
        case .tac_ne16(let c, let a, let b): try tac_ne16(c, a, b)
        case .tac_lt(let c, let a, let b): try tac_lt(c, a, b)
        case .tac_lt16(let c, let a, let b): try tac_lt16(c, a, b)
        case .tac_gt(let c, let a, let b): try tac_gt(c, a, b)
        case .tac_gt16(let c, let a, let b): try tac_gt16(c, a, b)
        case .tac_le(let c, let a, let b): try tac_le(c, a, b)
        case .tac_le16(let c, let a, let b): try tac_le16(c, a, b)
        case .tac_ge(let c, let a, let b): try tac_ge(c, a, b)
        case .tac_ge16(let c, let a, let b): try tac_ge16(c, a, b)
        case .tac_jz(let label, let test): try tac_jz(label, test)
        case .copyWordZeroExtend(let b, let a): try copyWordZeroExtend(b, a)
        case .copyWords(let dst, let src, let count): try copyWords(dst, src, count)
        case .copyWordsIndirectSource(let dst, let srcPtr, let count): try copyWordsIndirectSource(dst, srcPtr, count)
        case .copyWordsIndirectDestination(let dstPtr, let src, let count): try copyWordsIndirectDestination(dstPtr, src, count)
        case .copyWordsIndirectDestinationIndirectSource(let dstPtr, let srcPtr, let count): try copyWordsIndirectDestinationIndirectSource(dstPtr, srcPtr, count)
        }
        let instructionsEnd = assembler.instructions.count
        if instructionsBegin < instructionsEnd {
            for i in instructionsBegin..<instructionsEnd {
                mapAssemblyInstructionToSource[i] = currentSourceAnchor
                mapAssemblyInstructionToCrackleInstruction[i] = instruction
            }
        }
    }
    
    // Inserts epilogue code into the program, presumably at the end.
    func insertProgramEpilogue() throws {
        assembler.hlt()
        try injectCode(self)
    }
    
    public func push(_ value: Int) throws {
        try decrementStackPointer()
        try loadStackPointerIntoUVandXY()
        
        // Write the new value to the top of the stack.
        try assembler.li(.M, value)
    }
    
    public func push16(_ value: Int) throws {
        let hi = (value>>8) & 0xff
        let lo =  value & 0xff
        try push(lo)
        try push(hi)
    }
    
    public func pushsp() throws {
        // Load the 16-bit stack pointer into AB and then push to the stack.
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.B, .M)
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.A, .M)
        try pushAToStack()
        try assembler.mov(.A, .B)
        try pushAToStack()
    }
    
    private func loadStackPointerIntoUVandXY() throws {
        // Load the 16-bit stack pointer into XY.
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.X, .M)
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.Y, .M)
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
    }
    
    private func decrementStackPointer() throws {
        // First, save A in a well-known scratch location.
        let scratch = allocateScratchMemory(1)
        try setUV(scratch)
        try assembler.mov(.M, .A)
        
        // Decrement the low byte of the 16-bit stack pointer.
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.A, .M)
        try assembler.dea(.NONE)
        try assembler.dea(.A)
        try assembler.mov(.M, .A)
        
        // While we have it in A, stash a copy of the low byte to Y.
        // This prevents the need for another memory load below.
        try assembler.mov(.Y, .A)
        
        // Decrement the high byte of the 16-bit stack pointer, but only if the
        // above decrement set the carry flag.
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.A, .M)
        try assembler.dca(.NONE)
        try assembler.dca(.A)
        try assembler.mov(.M, .A)
        
        // While we have it in A, stash a copy of the high byte to X.
        // This prevents the need for another memory load below.
        try assembler.mov(.X, .A)
        
        // Restore A
        // (We saved this to a well-known scratch location earlier.)
        try setUV(scratch)
        try assembler.mov(.A, .M)
    }
    
    private func pop() throws {
        try popInMemoryStackIntoRegisterB()
    }
    
    private func popn(_ count: Int) throws {
        // This can probably be optimized.
        for _ in 0..<count {
            try pop()
        }
    }
    
    private func pushAToStack() throws {
        try decrementStackPointer()
        try loadStackPointerIntoUVandXY()
        
        // Write the new value to the top of the stack.
        try assembler.mov(.M, .A)
    }
    
    private func popInMemoryStackIntoRegisterB() throws {
        try loadStackPointerIntoUVandXY()
        
        // Load the top of the stack into B.
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        try assembler.mov(.B, .M)
        
        // Increment the stack pointer.
        assembler.inxy()
        
        // Write the modified stack pointer back to memory.
        try storeXYToStackPointer()
    }
    
    private func storeXYToStackPointer() throws {
        // Write the modified stack pointer back to memory.
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.M, .X)
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.M, .Y)
    }
    
    private func popTwoDecrementStackPointerAndLeaveInUVandXY() throws {
        try pop16()
        try decrementStackPointer()
        try loadStackPointerIntoUVandXY()
    }
    
    public func pop16() throws {
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.A, .B)
        try popInMemoryStackIntoRegisterB()
    }
    
    public func eq() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try setXY(jumpTarget)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.je()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    public func eq16() throws {
        try eq16(valueOnPass: 1, valueOnFail: 0)
    }
    
    private func eq16(valueOnPass: Int, valueOnFail: Int) throws {
        let a = allocateScratchMemory(2)
        let b = allocateScratchMemory(2)
        let c = allocateScratchMemory(1)
        
        try pop16()
        try setUV(a+1)
        try assembler.mov(.M, .A)
        try setUV(a+0)
        try assembler.mov(.M, .B)
        
        try pop16()
        try setUV(b+1)
        try assembler.mov(.M, .A)
        try setUV(b+0)
        try assembler.mov(.M, .B)
        
        try eq16(c, a, b, valueOnPass, valueOnFail)
        
        try load(from: c)
    }
    
    private func eq16(_ c: Int, _ a: Int, _ b: Int, _ valueOnPass: Int, _ valueOnFail: Int) throws {
        let label_fail_test = labelMaker.next()
        let label_tail = labelMaker.next()
        
        try setUV(b+1)
        try assembler.mov(.A, .M)
        try setUV(a+1)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        
        try setAddressToLabel(label_fail_test)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        try setUV(b+0)
        try assembler.mov(.A, .M)
        try setUV(a+0)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        
        try setAddressToLabel(label_fail_test)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        try setUV(c)
        try assembler.li(.M, valueOnPass)
        try jmp(label_tail)
        
        try label(label_fail_test)
        try setUV(c)
        try assembler.li(.M, valueOnFail)
        
        try label(label_tail)
    }
    
    public func ne() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try setXY(jumpTarget)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    public func ne16() throws {
        try eq16(valueOnPass: 0, valueOnFail: 1)
    }
    
    public func lt() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try setXY(jumpTarget)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jl()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    public func lt16() throws {
        let addressOfA = allocateScratchMemory(2)
        let addressOfB = allocateScratchMemory(2)
        let addressOfC = allocateScratchMemory(1)

        // Pop `b' and store in scratch memory.
        try pop16()
        try setUV(addressOfB+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop `a' and store in scratch memory.
        try pop16()
        try setUV(addressOfA+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfA+1)
        try assembler.mov(.M, .B)
        
        try tac_lt16(addressOfC, addressOfB, addressOfA)
        
        try load(from: addressOfC)
    }
    
    public func gt() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try setXY(jumpTarget)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jg()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    public func gt16() throws {
        let addressOfA = allocateScratchMemory(2)
        let addressOfB = allocateScratchMemory(2)
        let addressOfC = allocateScratchMemory(1)

        // Pop `a' and store in scratch memory.
        try pop16()
        try setUV(addressOfA+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfA+1)
        try assembler.mov(.M, .B)

        // Pop `b' and store in scratch memory.
        try pop16()
        try setUV(addressOfB+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfB+1)
        try assembler.mov(.M, .B)
        
        try tac_gt16(addressOfC, addressOfA, addressOfB)
        
        try load(from: addressOfC)
    }
    
    public func le() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try setXY(jumpTarget)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jle()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    public func le16() throws {
        let addressOfA = allocateScratchMemory(2)
        let addressOfB = allocateScratchMemory(2)
        let addressOfC = allocateScratchMemory(1)

        // Pop `b' and store in scratch memory.
        try pop16()
        try setUV(addressOfB+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop `a' and store in scratch memory.
        try pop16()
        try setUV(addressOfA+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfA+1)
        try assembler.mov(.M, .B)

        try tac_le16(addressOfC, addressOfB, addressOfA)
        
        try load(from: addressOfC)
    }
    
    public func ge() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try setXY(jumpTarget)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jge()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    public func ge16() throws {
        let addressOfA = allocateScratchMemory(2)
        let addressOfB = allocateScratchMemory(2)
        let addressOfC = allocateScratchMemory(1)

        // Pop `b' and store in scratch memory.
        try pop16()
        try setUV(addressOfB+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop `a' and store in scratch memory.
        try pop16()
        try setUV(addressOfA+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfA+1)
        try assembler.mov(.M, .B)

        try tac_ge16(addressOfC, addressOfA, addressOfB)
        
        try load(from: addressOfC)
    }
    
    public func add() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        try assembler.add(.NONE)
        try assembler.add(.M)
    }
    
    public func add16() throws {
        let a = allocateScratchMemory(2)
        let b = allocateScratchMemory(2)
        let c = allocateScratchMemory(2)
        
        try pop16()
        try setUV(b+1)
        try assembler.mov(.M, .B)
        try setUV(b+0)
        try assembler.mov(.M, .A)
        
        try pop16()
        try setUV(a+1)
        try assembler.mov(.M, .B)
        try setUV(a+0)
        try assembler.mov(.M, .A)
        
        try tac_add16(c, a, b)
        
        try setUV(c+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try setUV(c+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func sub() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        try assembler.sub(.NONE)
        try assembler.sub(.M)
    }
    
    public func sub16() throws {
        let a = allocateScratchMemory(2)
        let b = allocateScratchMemory(2)
        let c = allocateScratchMemory(2)
        
        try pop16()
        try setUV(b+1)
        try assembler.mov(.M, .B)
        try setUV(b+0)
        try assembler.mov(.M, .A)
        
        try pop16()
        try setUV(a+1)
        try assembler.mov(.M, .B)
        try setUV(a+0)
        try assembler.mov(.M, .A)
        
        try tac_sub16(c, b, a)
        
        try setUV(c+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try setUV(c+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func mul() throws {
        try pop16()
        
        // A is the Multiplicand, B is the Multiplier
        let multiplierAddress = allocateScratchMemory(1)
        let multiplicandAddress = allocateScratchMemory(1)
        let resultAddress = allocateScratchMemory(1)
        
        try setUV(multiplierAddress)
        try assembler.mov(.M, .B)
        try setUV(multiplicandAddress)
        try assembler.mov(.M, .A)
        try setUV(resultAddress)
        try assembler.li(.M, 0)
        
        try tac_mul(resultAddress, multiplicandAddress, multiplierAddress)
        
        // Load the result into A.
        try assembler.li(.V, resultAddress)
        try assembler.mov(.A, .M)
        
        try pushAToStack()
    }
    
    public func mul16() throws {
        let multiplicandAddress = allocateScratchMemory(2)
        let multiplierAddress = allocateScratchMemory(2)
        let resultAddress = allocateScratchMemory(2)
        
        // Pop the multiplicand and store in scratch memory.
        try pop16()
        try setUV(multiplicandAddress+0)
        try assembler.mov(.M, .A)
        try setUV(multiplicandAddress+1)
        try assembler.mov(.M, .B)
        
        // Pop the multiplier and store in scratch memory.
        try pop16()
        try setUV(multiplierAddress+0)
        try assembler.mov(.M, .A)
        try setUV(multiplierAddress+1)
        try assembler.mov(.M, .B)
        
        try tac_mul16(resultAddress, multiplicandAddress, multiplierAddress)
        
        // Push the result onto the stack.
        // First the low byte
        try setUV(resultAddress+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        // Then the high byte
        try setUV(resultAddress+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func div() throws {
        try pop16()
        
        let dividend = allocateScratchMemory(1)
        let divisor = allocateScratchMemory(1)
        let counter = allocateScratchMemory(1)
        
        // A is the Dividend, B is the Divisor
        try setUV(dividend)
        try assembler.mov(.M, .A)
        try setUV(divisor)
        try assembler.mov(.M, .B)
        
        try div_modifyingA(counter, dividend, divisor)
        
        // Return the result in the A register.
        try setUV(counter)
        try assembler.mov(.A, .M)
        
        try pushAToStack()
    }
    
    public func div16() throws {
        let addressOfB = allocateScratchMemory(2)
        let addressOfA = allocateScratchMemory(2)
        let counterAddress = allocateScratchMemory(2)

        // Pop the divisor and store in scratch memory.
        // `b' is the Divisor
        try pop16()
        try setUV(addressOfB+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop the dividend and store in scratch memory.
        // `a' is the Dividend
        try pop16()
        try setUV(addressOfA+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfA+1)
        try assembler.mov(.M, .B)

        try div16_modifyingA(counterAddress, addressOfA, addressOfB)

        // Push the result to the stack. First the low byte, then the high byte.
        try setUV(counterAddress+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        try setUV(counterAddress+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func mod() throws {
        try pop16()
        
        let dividend = allocateScratchMemory(1)
        let divisor = allocateScratchMemory(1)
        let counter = allocateScratchMemory(1)
        
        // A is the Dividend, B is the Divisor
        try setUV(dividend)
        try assembler.mov(.M, .A)
        try setUV(divisor)
        try assembler.mov(.M, .B)
        
        try div_modifyingA(counter, dividend, divisor)
        
        // Return the result in the A register.
        try setUV(dividend)
        try assembler.mov(.A, .M)
        
        try pushAToStack()
    }
    
    public func mod16() throws {
        let addressOfB = allocateScratchMemory(2)
        let addressOfA = allocateScratchMemory(2)
        let counterAddress = allocateScratchMemory(2)

        // Pop the divisor and store in scratch memory.
        // `b' is the Divisor
        try pop16()
        try setUV(addressOfB+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop the dividend and store in scratch memory.
        // `a' is the Dividend
        try pop16()
        try setUV(addressOfA+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfA+1)
        try assembler.mov(.M, .B)

        try div16_modifyingA(counterAddress, addressOfA, addressOfB)

        // Push the result to the stack. First the low byte, then the high byte.
        try setUV(addressOfA+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        try setUV(addressOfA+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func load(from address: Int) throws {
        try decrementStackPointer()
        
        // Load the value from RAM to A.
        try setUV(address)
        try assembler.mov(.A, .M)
        
        try loadStackPointerIntoUVandXY()
        
        // Write A (the value we loaded) to the new top of the stack.
        try assembler.mov(.M, .A)
    }
    
    public func load16(from address: Int) throws {
        try setUV(address+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try setUV(address+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func store(to address: Int) throws {
        try loadStackPointerIntoUVandXY()
        
        // Copy the stop of the stack into A.
        try assembler.mov(.A, .M)
        
        // Now write A into the specified address.
        try setUV(address)
        try assembler.mov(.M, .A)
    }
    
    public func storeImmediate(_ address: Int, _ value: Int) throws {
        try setUV(address)
        try assembler.li(.M, value & 0xff)
    }
    
    public func store16(to address: Int) throws {
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        try setUV(address+0)
        try assembler.mov(.M, .A)
        
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        assembler.inuv()
        try assembler.mov(.A, .M)
        try setUV(address+1)
        try assembler.mov(.M, .A)
    }
    
    public func storeImmediate16(_ address: Int, _ value: Int) throws {
        try setUV(address+0)
        try assembler.li(.M, (value>>8) & 0xff)
        try setUV(address+1)
        try assembler.li(.M, value & 0xff)
    }
    
    public func label(_ name: String) throws {
        guard labelTable[name] == nil else {
            throw CompilerError(sourceAnchor: currentSourceAnchor, message: "label redefines existing symbol: `\(name)'")
        }
        labelTable[name] = assembler.programCounter
    }
    
    public func loadIndirect() throws {
        try pop16()
        try assembler.mov(.U, .A)
        try assembler.mov(.V, .B)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func loadIndirect16() throws {
        try pop16()
        
        let a = allocateScratchMemory(2)
        
        // Stash the address in scratch memory.
        try setUV(a+0)
        try assembler.mov(.M, .A)
        try setUV(a+1)
        try assembler.mov(.M, .B)
        
        // Load the low word and push to the stack.
        try assembler.mov(.U, .A)
        try assembler.mov(.V, .B)
        assembler.inuv()
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        // Retrieve the address from scratch memory.
        try setUV(a+0)
        try assembler.mov(.X, .M)
        try setUV(a+1)
        try assembler.mov(.Y, .M)
        
        // Load the high word and push to the stack.
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    public func loadIndirectN(_ count: Int) throws {
        try pop16()
        
        // Stash the source address in scratch memory
        let sourceAddress = allocateScratchMemory(2)
        try setUV(sourceAddress+0)
        try assembler.mov(.M, .A)
        try setUV(sourceAddress+1)
        try assembler.mov(.M, .B)
        
        // Stash the stack pointer in scratch memory
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.A, .M)
        let stashedStackPointerAddress = allocateScratchMemory(2)
        try setUV(stashedStackPointerAddress+0)
        try assembler.mov(.M, .A)
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.A, .M)
        try setUV(stashedStackPointerAddress+1)
        try assembler.mov(.M, .A)
        
        // Stash the count in scratch memory.
        let stashedCountAddress = allocateScratchMemory(2)
        try setUV(stashedCountAddress+0)
        try assembler.li(.M, (count>>8) & 0xff)
        try setUV(stashedCountAddress+1)
        try assembler.li(.M, count & 0xff)
        
        // Perform a 16-bit subtraction to subtract the count from SP.
        try setUV(stashedStackPointerAddress+1)
        try assembler.mov(.A, .M)
        try setUV(stashedCountAddress+1)
        try assembler.mov(.B, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        
        try setUV(stashedStackPointerAddress+0)
        try assembler.mov(.A, .M)
        try setUV(stashedCountAddress+0)
        try assembler.mov(.B, .M)
        try assembler.sbc(.NONE)
        try assembler.sbc(.M)
        
        // Store the updated stack pointer back to memory.
        try setUV(stashedCountAddress+0)
        try assembler.mov(.A, .M)
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.M, .A)
        
        try setUV(stashedCountAddress+1)
        try assembler.mov(.A, .M)
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.M, .A)
        
        // Copy bytes from the source address to the destination address on the stack.
        for i in 0..<count {
            // Load a byte from the source address into A.
            try setUV(sourceAddress+0)
            try assembler.mov(.X, .M)
            try setUV(sourceAddress+1)
            try assembler.mov(.Y, .M)
            try assembler.mov(.U, .X)
            try assembler.mov(.V, .Y)
            try assembler.mov(.A, .M)
            
            // Store A to the destination address
            try setUV(stashedCountAddress+0)
            try assembler.mov(.X, .M)
            try setUV(stashedCountAddress+1)
            try assembler.mov(.Y, .M)
            try assembler.mov(.U, .X)
            try assembler.mov(.V, .Y)
            try assembler.mov(.M, .A)
            
            if i < count - 1 {
                // Increment and write back the source address
                try setUV(sourceAddress+0)
                try assembler.mov(.X, .M)
                try setUV(sourceAddress+1)
                try assembler.mov(.Y, .M)
                try assembler.mov(.U, .X)
                try assembler.mov(.V, .Y)
                assembler.inxy()
                try setUV(sourceAddress+0)
                try assembler.mov(.M, .X)
                try setUV(sourceAddress+1)
                try assembler.mov(.M, .Y)
                
                // Increment and write back the destination address
                try setUV(stashedCountAddress+0)
                try assembler.mov(.X, .M)
                try setUV(stashedCountAddress+1)
                try assembler.mov(.Y, .M)
                try assembler.mov(.U, .X)
                try assembler.mov(.V, .Y)
                assembler.inxy()
                try setUV(stashedCountAddress+0)
                try assembler.mov(.M, .X)
                try setUV(stashedCountAddress+1)
                try assembler.mov(.M, .Y)
            }
        }
    }
    
    public func storeIndirect() throws {
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        let stashedDestinationAddress = allocateScratchMemory(2)
        try setUV(stashedDestinationAddress+0)
        try assembler.mov(.M, .A)
        try setUV(stashedDestinationAddress+1)
        try assembler.mov(.M, .B)
        
        // Copy the top of the stack into A.
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        
        // Restore the stashed destination address to UV and XY.
        try setUV(stashedDestinationAddress+0)
        try assembler.mov(.X, .M)
        try setUV(stashedDestinationAddress+1)
        try assembler.mov(.Y, .M)
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        
        // Store A to the destination address.
        try assembler.mov(.M, .A)
    }
    
    public func storeIndirect16() throws {
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        let stashedDestinationAddress = allocateScratchMemory(2)
        try setUV(stashedDestinationAddress+0)
        try assembler.mov(.M, .A)
        try setUV(stashedDestinationAddress+1)
        try assembler.mov(.M, .B)
        
        // Copy the two bytes at the top of the stack into A and B
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        assembler.inuv()
        try assembler.mov(.B, .M)
        
        // Restore the stashed destination address to UV and XY.
        try setUV(stashedDestinationAddress+0)
        try assembler.mov(.X, .M)
        try setUV(stashedDestinationAddress+1)
        try assembler.mov(.Y, .M)
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        
        // Store A and B to the destination address.
        try assembler.mov(.M, .A)
        assembler.inuv()
        try assembler.mov(.M, .B)
    }
    
    public func storeIndirectN(_ count: Int) throws {
        // TODO: storeIndirectN can probably be optimized. For example, use the BLT instructions and the ALU.
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        let stashedDestinationAddress = allocateScratchMemory(2)
        try setUV(stashedDestinationAddress+0)
        try assembler.mov(.M, .A)
        try setUV(stashedDestinationAddress+1)
        try assembler.mov(.M, .B)
        
        for i in 0..<count {
            // Copy the i-th word on the stack to A.
            try loadStackPointerIntoUVandXY()
            for _ in 0..<i {
                assembler.inuv()
            }
            try assembler.mov(.A, .M)
            
            // Restore the stashed destination address to UV and XY.
            try setUV(stashedDestinationAddress+0)
            try assembler.mov(.X, .M)
            try setUV(stashedDestinationAddress+1)
            try assembler.mov(.Y, .M)
            try assembler.mov(.U, .X)
            try assembler.mov(.V, .Y)
            
            // Offset to get the destination of the i-th word
            for _ in 0..<i {
                assembler.inuv()
            }
            
            // Store the i-th word
            try assembler.mov(.M, .A)
        }
    }
    
    public func jmp(_ label: String) throws {
        try setAddressToLabel(label)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    public func je(_ label: String) throws {
        try pop16()
        
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(label)
        assembler.je()
        assembler.nop()
        assembler.nop()
    }
    
    public func jalr(_ label: String) throws {
        try setAddressToLabel(label)
        assembler.jalr()
        assembler.nop()
        assembler.nop()
    }
    
    func setAddressToLabel(_ name: String) throws {
        patcherActions.append((index: assembler.programCounter,
                               sourceAnchor: currentSourceAnchor,
                               symbol: name,
                               shift: 8))
        try assembler.li(.X, 0xff)
        patcherActions.append((index: assembler.programCounter,
                               sourceAnchor: currentSourceAnchor,
                               symbol: name,
                               shift: 0))
        try assembler.li(.Y, 0xff)
    }
    
    public func enter() throws {
        // push fp in two bytes ; fp <- sp
        
        try setUV(kFramePointerAddressLo)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try setUV(kFramePointerAddressHi)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.X, .M)
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.Y, .M)

        try setUV(kFramePointerAddressHi)
        try assembler.mov(.M, .X)
        try setUV(kFramePointerAddressLo)
        try assembler.mov(.M, .Y)
    }
    
    public func leave() throws {
        // sp <- fp ; fp <- pop two bytes from the stack
        
        try setUV(kFramePointerAddressHi)
        try assembler.mov(.X, .M)
        try setUV(kFramePointerAddressLo)
        try assembler.mov(.Y, .M)
        
        try setUV(kStackPointerAddressHi)
        try assembler.mov(.M, .X)
        try setUV(kStackPointerAddressLo)
        try assembler.mov(.M, .Y)
        
        try popInMemoryStackIntoRegisterB()
        try setUV(kFramePointerAddressHi)
        try assembler.mov(.M, .B)
        
        try popInMemoryStackIntoRegisterB()
        try setUV(kFramePointerAddressLo)
        try assembler.mov(.M, .B)
    }
    
    private func pushReturnAddress() throws {
        try assembler.mov(.A, .H)
        try pushAToStack()
        try assembler.mov(.A, .G)
        try pushAToStack()
    }
    
    private func leafRet() throws {
        try assembler.mov(.X, .G)
        try assembler.mov(.Y, .H)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    public func ret() throws {
        let addressOfReturnAddressHi = allocateScratchMemory(1)
        
        try popInMemoryStackIntoRegisterB()
        try setUV(addressOfReturnAddressHi)
        try assembler.mov(.M, .B)
        
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.Y, .B)
        
        try setUV(addressOfReturnAddressHi)
        try assembler.mov(.X, .M)
        
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    public func hlt() {
        assembler.hlt()
    }
    
    public func peekPeripheral() throws {
        try pop16()
        try assembler.mov(.U, .A)
        try assembler.mov(.V, .B)
        try assembler.mov(.A, .P)
        try pushAToStack()
    }
    
    public func pokePeripheral() throws {
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.D, .B)
        
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        let stashedDestinationAddress = allocateScratchMemory(2)
        try setUV(stashedDestinationAddress+0)
        try assembler.mov(.M, .A)
        try setUV(stashedDestinationAddress+1)
        try assembler.mov(.M, .B)
        
        // Copy the top of the stack into A.
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        
        // Restore the stashed destination address to XY.
        try setUV(stashedDestinationAddress+0)
        try assembler.mov(.X, .M)
        try setUV(stashedDestinationAddress+1)
        try assembler.mov(.Y, .M)
        
        // Store A to the destination address on the peripheral bus.
        try assembler.mov(.P, .A)
    }
    
    public func dup() throws {
        let scratch = allocateScratchMemory(1)
        try store(to: scratch)
        try load(from: scratch)
    }
    
    public func dup16() throws {
        let scratch = allocateScratchMemory(2)
        try store16(to: scratch)
        try load16(from: scratch)
    }
        
    private func tac_add(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        try assembler.add(.NONE)
        try assembler.add(.M)
    }
        
    private func setupALUOperandsAndDestinationAddress(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(b)
        try assembler.mov(.B, .M)
        try setUV(a)
        try assembler.mov(.A, .M)
        try setUV(c)
    }
    
    private func tac_add16(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a+1)
        try assembler.mov(.A, .M)
        try setUV(b+1)
        try assembler.mov(.B, .M)
        try setUV(c+1)
        try assembler.add(.NONE)
        try assembler.add(.M)
        
        try setUV(a+0)
        try assembler.mov(.A, .M)
        try setUV(b+0)
        try assembler.mov(.B, .M)
        try setUV(c+0)
        try assembler.adc(.NONE)
        try assembler.adc(.M)
    }
    
    private func tac_sub(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
    }
    
    private func tac_sub16(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a+1)
        try assembler.mov(.A, .M)
        try setUV(b+1)
        try assembler.mov(.B, .M)
        try setUV(c+1)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        
        try setUV(a+0)
        try assembler.mov(.A, .M)
        try setUV(b+0)
        try assembler.mov(.B, .M)
        try setUV(c+0)
        try assembler.sbc(.NONE)
        try assembler.sbc(.M)
    }
    
    private func tac_mul(_ resultAddress: Int, _ multiplicandAddress: Int, _ originalMultiplierAddress: Int) throws {
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // Copy the multiplier to a scratch location because we modify it in
        // the loop.
        let multiplierAddress = allocateScratchMemory(1)
        try setUV(originalMultiplierAddress)
        try assembler.mov(.A, .M)
        try setUV(multiplierAddress)
        try assembler.mov(.M, .A)
        
        try label(loopHead)
        
        // If the multiplier is equal to zero then bail because we're done.
        try setAddressToLabel(loopTail)
        try setUV(multiplierAddress)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.je()
        assembler.nop()
        assembler.nop()
        
        // Add the multiplicand to the result.
        try setUV(multiplicandAddress)
        try assembler.mov(.B, .M)
        try setUV(resultAddress)
        try assembler.mov(.A, .M)
        try assembler.add(.NONE)
        try assembler.add(.M)
        
        // Decrement the multiplier.
        try setUV(multiplierAddress)
        try assembler.mov(.A, .M)
        try assembler.dea(.NONE)
        try assembler.dea(.M)
        
        try jmp(loopHead) // Jump back to the beginning of the loop
        try label(loopTail)
    }
    
    private func tac_mul16(_ resultAddress: Int, _ multiplicandAddress: Int, _ originalMultiplierAddress: Int) throws {
        // Copy the multiplier to a scratch location because we modify it in
        // the loop.
        let multiplierAddress = allocateScratchMemory(2)
        try setUV(originalMultiplierAddress+0)
        try assembler.mov(.A, .M)
        try setUV(multiplierAddress+0)
        try assembler.mov(.M, .A)
        try setUV(originalMultiplierAddress+1)
        try assembler.mov(.A, .M)
        try setUV(multiplierAddress+1)
        try assembler.mov(.M, .A)
        
        // Initialize the result to zero.
        try setUV(resultAddress+0)
        try assembler.li(.M, 0)
        try setUV(resultAddress+1)
        try assembler.li(.M, 0)
        
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        let notDone = labelMaker.next()
        
        try label(loopHead)
        
        // If the multiplier is equal to zero then bail because we're done.
        try setAddressToLabel(notDone)
        try setUV(multiplierAddress+1)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try setUV(multiplierAddress+0)
        try assembler.mov(.A, .M)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try setAddressToLabel(loopTail)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        try label(notDone)
        
        // Add the multiplicand to the result.
        try setUV(multiplicandAddress+1)
        try assembler.mov(.B, .M)
        try setUV(resultAddress+1)
        try assembler.mov(.A, .M)
        try assembler.add(.NONE)
        try assembler.add(.M)
        try setUV(multiplicandAddress+0)
        try assembler.mov(.B, .M)
        try setUV(resultAddress+0)
        try assembler.mov(.A, .M)
        try assembler.adc(.NONE)
        try assembler.adc(.M)
        
        // Decrement the multiplier.
        try setUV(multiplierAddress+1)
        try assembler.mov(.A, .M)
        try assembler.dea(.NONE)
        try assembler.dea(.M)
        try setUV(multiplierAddress+0)
        try assembler.mov(.A, .M)
        try assembler.dca(.NONE)
        try assembler.dca(.M)
        
        // Jump back to the beginning of the loop
        try jmp(loopHead)
        try label(loopTail)
    }
    
    private func tac_div(_ counter: Int, _ originalA: Int, _ b: Int) throws {
        // Copy `a' to a scratch location because we modify it in the loop.
        let a = allocateScratchMemory(1)
        try setUV(originalA)
        try assembler.mov(.A, .M)
        try setUV(a)
        try assembler.mov(.M, .A)
        
        try div_modifyingA(counter, a, b)
    }
    
    private func div_modifyingA(_ counter: Int, _ a: Int, _ b: Int) throws {
        // Reset the counter
        try setUV(counter)
        try assembler.li(.M, 0)
        
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // if b == 0 then bail because it's division by zero
        try setAddressToLabel(loopHead)
        try setUV(b)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try setUV(a)
        try assembler.li(.M, 0)
        try jmp(loopTail)
        
        // while a >= b
        try label(loopHead)
        try setAddressToLabel(loopTail)
        try setUV(a)
        try assembler.mov(.A, .M)
        try setUV(b)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jl()
        assembler.nop()
        assembler.nop()
        
        // a = a - b
        try setUV(b)
        try assembler.mov(.B, .M)
        try setUV(a)
        try assembler.mov(.A, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        
        // c += 1
        try setUV(counter)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 1)
        try assembler.add(.NONE)
        try assembler.add(.M)
        
        // loop
        try jmp(loopHead)
        try label(loopTail)
    }
    
    private func tac_div16(_ counterAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
        // Copy the dividend `a' to a scratch location because we modify it in
        // the loop.
        let addressOfA = allocateScratchMemory(2)
        try setUV(addressOfOriginalA+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfOriginalA+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+1)
        try assembler.mov(.M, .A)
        
        try div16_modifyingA(counterAddress, addressOfA, addressOfB)
    }
    
    private func div16_modifyingA(_ counterAddress: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        // Initialize the counter to zero.
        // `c' is the counter
        try setUV(counterAddress+0)
        try assembler.li(.M, 0)
        try setUV(counterAddress+1)
        try assembler.li(.M, 0)
        
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // if b == 0 then bail because it's division by zero
        try setAddressToLabel(loopHead)
        try setUV(addressOfB+1)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try setUV(addressOfB+0)
        try assembler.mov(.A, .M)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try setUV(addressOfA+0)
        try assembler.li(.M, 0)
        try setUV(addressOfA+1)
        try assembler.li(.M, 0)
        try jmp(loopTail)
        
        // while a >= b
        try label(loopHead)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+1)
        try assembler.mov(.B, .M)
        
        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+0)
        try assembler.mov(.B, .M)
        
        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)
        
        try setAddressToLabel(loopTail)
        assembler.jnc()
        assembler.nop()
        assembler.nop()
        
        // a = a - b
        try setUV(addressOfB+1)
        try assembler.mov(.B, .M)
        try setUV(addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        try setUV(addressOfB+0)
        try assembler.mov(.B, .M)
        try setUV(addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.sbc(.NONE)
        try assembler.sbc(.M)
        
        // c += 1
        try setUV(counterAddress+0)
        try assembler.mov(.X, .M)
        try setUV(counterAddress+1)
        try assembler.mov(.Y, .M)
        assembler.inxy()
        try setUV(counterAddress+0)
        try assembler.mov(.M, .X)
        try setUV(counterAddress+1)
        try assembler.mov(.M, .Y)
        
        // loop
        try jmp(loopHead)
        try label(loopTail)
    }
    
    private func tac_mod(_ resultAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
        let counterAddress = allocateScratchMemory(1)
        
        // Copy `a' to a scratch location because we modify it in the loop.
        try setUV(addressOfOriginalA)
        try assembler.mov(.A, .M)
        try setUV(resultAddress)
        try assembler.mov(.M, .A)
        
        try div_modifyingA(counterAddress, resultAddress, addressOfB)
    }
    
    private func tac_mod16(_ resultAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
        let counterAddress = allocateScratchMemory(2)
        
        // Copy the dividend `a' to a scratch location because we modify it in
        // the loop.
        try setUV(addressOfOriginalA+0)
        try assembler.mov(.A, .M)
        try setUV(resultAddress+0)
        try assembler.mov(.M, .A)
        try setUV(addressOfOriginalA+1)
        try assembler.mov(.A, .M)
        try setUV(resultAddress+1)
        try assembler.mov(.M, .A)
        
        try div16_modifyingA(counterAddress, resultAddress, addressOfB)
    }
    
    public func tac_eq(_ c: Int, _ a: Int, _ b: Int) throws {
        try tac_comparison("JE", c, a, b)
    }
    
    public func tac_ne(_ c: Int, _ a: Int, _ b: Int) throws {
        try tac_comparison("JNE", c, a, b)
    }
    
    public func tac_lt(_ c: Int, _ a: Int, _ b: Int) throws {
        try tac_comparison("JL", c, a, b)
    }
    
    public func tac_gt(_ c: Int, _ a: Int, _ b: Int) throws {
        try tac_comparison("JG", c, a, b)
    }
    
    public func tac_le(_ c: Int, _ a: Int, _ b: Int) throws {
        try tac_comparison("JLE", c, a, b)
    }
    
    public func tac_ge(_ c: Int, _ a: Int, _ b: Int) throws {
        try tac_comparison("JGE", c, a, b)
    }
    
    private func tac_comparison(_ comparison: String, _ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a)
        try assembler.mov(.A, .M)
        
        try setUV(b)
        try assembler.mov(.B, .M)
        
        try setUV(c)
        
        let tail = labelMaker.next()
        try setAddressToLabel(tail)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        try assembler.instruction(mnemonic: comparison, immediate: 0)
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        try label(tail)
    }
    
    private func tac_eq16(_ c: Int, _ a: Int, _ b: Int) throws {
        try eq16(c, a, b, 1, 0)
    }
    
    private func tac_ne16(_ c: Int, _ a: Int, _ b: Int) throws {
        try eq16(c, a, b, 0, 1)
    }
    
    private func tac_lt16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        let labelFailEqualityTest = labelMaker.next()
        let labelTail = labelMaker.next()
        
        // Compare low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+1)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // Compare high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+0)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // The two operands are equal so return false.
        try assembler.li(.A, 0)
        try jmp(labelTail)
        
        try label(labelFailEqualityTest)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+1)
        try assembler.mov(.B, .M)
        
        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+0)
        try assembler.mov(.B, .M)
        
        try setAddressToLabel(labelTail)
        
        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)
        
        // A <- (carry_flag) ? 1 : 0
        try assembler.li(.A, 1)
        assembler.jc()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        try label(labelTail)
        
        // Store the value in the A register to the result, in `c'.
        try setUV(addressOfC)
        try assembler.mov(.M, .A)
    }
    
    private func tac_gt16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        let labelFailEqualityTest = labelMaker.next()
        let labelTail = labelMaker.next()
        let labelThen = labelMaker.next()
        
        // Compare low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+1)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // Compare high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+0)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // The two operands are equal so return true.
        try jmp(labelThen)
        
        try label(labelFailEqualityTest)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+1)
        try assembler.mov(.B, .M)
        
        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+0)
        try assembler.mov(.B, .M)
        
        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)
        
        // A <- (carry_flag) ? 0 : 1
        try setAddressToLabel(labelThen)
        assembler.jnc()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 1)
        try setAddressToLabel(labelTail)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        try label(labelThen)
        try assembler.li(.A, 0)
        try label(labelTail)
        
        // Store the value in the A register to the result, in `c'.
        try setUV(addressOfC)
        try assembler.mov(.M, .A)
    }
    
    private func tac_le16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+1)
        try assembler.mov(.B, .M)
        
        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfA+0)
        try assembler.mov(.B, .M)
        
        let labelThen = labelMaker.next()
        try setAddressToLabel(labelThen)
        
        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)
        
        // A <- (carry_flag==active) ? 1 : 0
        try assembler.li(.A, 1)
        assembler.jc()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        try label(labelThen)
        
        try setUV(addressOfC)
        try assembler.mov(.M, .A)
    }
    
    private func tac_ge16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+1)
        try assembler.mov(.B, .M)
        
        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        try assembler.mov(.A, .M)
        try setUV(addressOfB+0)
        try assembler.mov(.B, .M)
        
        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)
        
        // A <- (carry_flag) ? 0 : 1
        let labelTail = labelMaker.next()
        let labelThen = labelMaker.next()
        try setAddressToLabel(labelThen)
        assembler.jc()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        try setAddressToLabel(labelTail)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        try label(labelThen)
        try assembler.li(.A, 1)
        try label(labelTail)
        
        try setUV(addressOfC)
        try assembler.mov(.M, .A)
    }
    
    private func tac_jz(_ label: String, _ test: Int) throws {
        try tac_jei(label, test, 0)
    }
    
    private func tac_jei(_ label: String, _ addressOfTestValue: Int, _ valueToTestAgainst: Int) throws {
        try setUV(addressOfTestValue)
        try assembler.mov(.A, .M)
        try assembler.li(.B, valueToTestAgainst)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(label)
        assembler.je()
        assembler.nop()
        assembler.nop()
    }
    
    private func copyWordZeroExtend(_ dst: Int, _ src: Int) throws {
        try setUV(src)
        try assembler.mov(.X, .M)
        
        try setUV(dst)
        try assembler.li(.M, 0)
        
        assembler.inuv()
        try assembler.mov(.M, .X)
    }
    
    private func copyWords(_ dst: Int, _ src: Int, _ count: Int) throws {
        for i in 0..<count {
            try setUV(src + i)
            try assembler.mov(.A, .M)
            try setUV(dst + i)
            try assembler.mov(.M, .A)
        }
    }
    
    private func copyWordsIndirectSource(_ dst: Int, _ srcPtr: Int, _ count: Int) throws {
        if count == 0 {
            return
        }
        
        try setUV(srcPtr)
        try assembler.mov(.X, .M)
        assembler.inuv()
        try assembler.mov(.Y, .M)
        
        for i in 0..<count {
            try assembler.mov(.U, .X)
            try assembler.mov(.V, .Y)
            try assembler.mov(.A, .M)
            try setUV(dst + i)
            try assembler.mov(.M, .A)
            if i != count-1 {
                assembler.inxy()
            }
        }
    }
    
    private func copyWordsIndirectDestination(_ dstPtr: Int, _ src: Int, _ count: Int) throws {
        if count == 0 {
            return
        }
        
        try setUV(dstPtr)
        try assembler.mov(.X, .M)
        assembler.inuv()
        try assembler.mov(.Y, .M)
        
        for i in 0..<count {
            try setUV(src + i)
            try assembler.mov(.A, .M)
            try assembler.mov(.U, .X)
            try assembler.mov(.V, .Y)
            try assembler.mov(.M, .A)
            if i != count-1 {
                assembler.inxy()
            }
        }
    }
    
    private func copyWordsIndirectDestinationIndirectSource(_ originalDstPtr: Int, _ originalSrcPtr: Int, _ count: Int) throws {
        if count == 0 {
            return
        }
        
        // Copy the destination address to scratch memory.
        let dstPtr = allocateScratchMemory(2)
        try setUV(originalDstPtr)
        try assembler.mov(.X, .M)
        assembler.inuv()
        try assembler.mov(.Y, .M)
        try setUV(dstPtr)
        try assembler.mov(.M, .X)
        assembler.inuv()
        try assembler.mov(.M, .Y)
        
        // Copy the source address to scratch memory.
        let srcPtr = allocateScratchMemory(2)
        try setUV(originalSrcPtr)
        try assembler.mov(.X, .M)
        assembler.inuv()
        try assembler.mov(.Y, .M)
        try setUV(srcPtr)
        try assembler.mov(.M, .X)
        assembler.inuv()
        try assembler.mov(.M, .Y)
        
        // Copy the bytes.
        for i in 0..<count {
            try setUV(srcPtr)
            try assembler.mov(.X, .M)
            assembler.inuv()
            try assembler.mov(.Y, .M)
            try assembler.mov(.U, .X)
            try assembler.mov(.V, .Y)
            try assembler.mov(.A, .M)
            
            try setUV(dstPtr)
            try assembler.mov(.X, .M)
            assembler.inuv()
            try assembler.mov(.Y, .M)
            try assembler.mov(.U, .X)
            try assembler.mov(.V, .Y)
            try assembler.mov(.M, .A)
            
            // Increment the pointers in-place.
            if i != count-1 {
                try setUV(srcPtr)
                try assembler.mov(.X, .M)
                assembler.inuv()
                try assembler.mov(.Y, .M)
                assembler.inxy()
                try assembler.mov(.M, .Y)
                try setUV(srcPtr)
                try assembler.mov(.M, .X)
                
                try setUV(dstPtr)
                try assembler.mov(.X, .M)
                assembler.inuv()
                try assembler.mov(.Y, .M)
                assembler.inxy()
                try assembler.mov(.M, .Y)
                try setUV(dstPtr)
                try assembler.mov(.M, .X)
            }
        }
    }
}
