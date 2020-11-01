//
//  CrackleToPopCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

// Compiles a program in the Crackle IR language to the Pop IR language.
public class CrackleToPopCompiler: NSObject {
    let kStackPointerAddressHi: Int = Int(SnapCompilerMetrics.kStackPointerAddressHi)
    let kStackPointerAddressLo: Int = Int(SnapCompilerMetrics.kStackPointerAddressLo)
    let kStackPointerHiHi = Int((SnapCompilerMetrics.kStackPointerAddressHi & 0xff00) >> 8)
    let kStackPointerHiLo = Int( SnapCompilerMetrics.kStackPointerAddressHi & 0x00ff)
    let kStackPointerLoHi = Int((SnapCompilerMetrics.kStackPointerAddressLo & 0xff00) >> 8)
    let kStackPointerLoLo = Int( SnapCompilerMetrics.kStackPointerAddressLo & 0x00ff)
    let kStackPointerInitialValueHi: Int = (SnapCompilerMetrics.kStackPointerInitialValue & 0xff00) >> 8
    let kStackPointerInitialValueLo: Int =  SnapCompilerMetrics.kStackPointerInitialValue & 0x00ff
    
    let kFramePointerAddressHi: Int = Int(SnapCompilerMetrics.kFramePointerAddressHi)
    let kFramePointerAddressLo: Int = Int(SnapCompilerMetrics.kFramePointerAddressLo)
    let kFramePointerHiHi = Int((SnapCompilerMetrics.kFramePointerAddressHi & 0xff00) >> 8)
    let kFramePointerHiLo = Int( SnapCompilerMetrics.kFramePointerAddressHi & 0x00ff)
    let kFramePointerLoHi = Int((SnapCompilerMetrics.kFramePointerAddressLo & 0xff00) >> 8)
    let kFramePointerLoLo = Int( SnapCompilerMetrics.kFramePointerAddressLo & 0x00ff)
    let kFramePointerInitialValueHi: Int = (SnapCompilerMetrics.kFramePointerInitialValue & 0xff00) >> 8
    let kFramePointerInitialValueLo: Int =  SnapCompilerMetrics.kFramePointerInitialValue & 0x00ff
    
    private var beginningOfScratchMemory = 0x0004
    private var scratchPointer: Int
    
    public private(set) var instructions: [PopInstruction] = []
    public var programDebugInfo: SnapDebugInfo? = nil
    private var currentSourceAnchor: SourceAnchor? = nil
    private var currentSymbols: SymbolTable? = nil
    
    let labelMaker = LabelMaker(prefix: ".LL")
    
    public var doAtEpilogue: (CrackleToPopCompiler) throws -> Void = {_ in}
    
    public override init() {
        scratchPointer = beginningOfScratchMemory
    }
    
    public func injectCode(_ ir: [CrackleInstruction]) throws {
        currentSourceAnchor = nil
        currentSymbols = nil
        for instruction in ir {
            try compileSingleCrackleInstruction(instruction)
        }
    }
    
    private func allocateScratchMemory(_ numWords: Int) -> Int {
        let result = scratchPointer
        scratchPointer += numWords
        return result
    }
    
    private func emit(_ instruction: PopInstruction) {
        instructions.append(instruction)
    }
    
    private func setUV(_ value: Int) throws {
        if ((value>>8) & 0xff) == (value & 0xff) {
            emit(.li(.UV, value & 0xff))
        } else {
            emit(.li(.U, (value>>8) & 0xff))
            emit(.li(.V, value & 0xff))
        }
    }
    
    public func compile(ir: [CrackleInstruction]) throws {
        try insertProgramPrologue()
        try compileProgramBody(ir)
        try insertProgramEpilogue()
    }
    
    // Inserts prologue code into the program, presumably at the beginning.
    // Insert a NOP at the beginning of every program because correct operation
    // of the hardware reset cycle requires this.
    // Likewise, correct operation of a program written in Snap requires some
    // initialization to be performed before anything else occurs.
    func insertProgramPrologue() throws {
        emit(.li(.UV, 0xff))
        emit(.blti(.M, 0))
        emit(.blti(.M, 0))
        emit(.blti(.M, 0))
        emit(.blti(.M, 0))
    }
    
    private func compileProgramBody(_ ir: [CrackleInstruction]) throws {
        for i in 0..<ir.count {
            let currentCrackleInstruction = ir[i]
            currentSourceAnchor = programDebugInfo?.lookupSourceAnchor(crackleInstructionIndex: i)
            currentSymbols = programDebugInfo?.lookupSymbols(crackleInstructionIndex: i)
            let instructionsBegin = instructions.count
            try compileSingleCrackleInstruction(currentCrackleInstruction)
            let instructionsEnd = instructions.count
            if instructionsBegin < instructionsEnd {
                for i in instructionsBegin..<instructionsEnd {
                    programDebugInfo?.bind(popInstructionIndex: i, crackleInstruction: currentCrackleInstruction)
                    programDebugInfo?.bind(popInstructionIndex: i, sourceAnchor: currentSourceAnchor)
                    programDebugInfo?.bind(popInstructionIndex: i, symbols: currentSymbols)
                }
            }
        }
    }
    
    private func compileSingleCrackleInstruction(_ instruction: CrackleInstruction) throws {
        scratchPointer = beginningOfScratchMemory
        switch instruction {
        case .nop: nop()
        case .push(let value): try push(value)
        case .push16(let value): try push16(value)
        case .pop: try pop()
        case .pop16: try pop16()
        case .subi16(let c, let a, let b): try subi16(c, a, b)
        case .addi16(let c, let a, let b): try addi16(c, a, b)
        case .muli16(let c, let a, let b): try muli16(c, a, b)
        case .storeImmediate(let address, let value): try storeImmediate(address, value)
        case .storeImmediate16(let address, let value): try storeImmediate16(address, value)
        case .storeImmediateBytes(let address, let bytes): try storeImmediateBytes(address, bytes)
        case .storeImmediateBytesIndirect(let dstPtr, let bytes): try storeImmediateBytesIndirect(dstPtr, bytes)
        case .label(let name): try label(name)
        case .jmp(let label): try jmp(label)
        case .jalr(let label): try jalr(label)
        case .indirectJalr(let address): try indirectJalr(address)
        case .enter: try enter()
        case .leave: try leave()
        case .pushReturnAddress: try pushReturnAddress()
        case .leafRet: try leafRet()
        case .ret: try ret()
        case .hlt: hlt()
        case .peekPeripheral: try peekPeripheral()
        case .pokePeripheral: try pokePeripheral()
        case .add(let c, let a, let b): try add(c, a, b)
        case .add16(let c, let a, let b): try add16(c, a, b)
        case .sub(let c, let a, let b): try sub(c, a, b)
        case .sub16(let c, let a, let b): try sub16(c, a, b)
        case .mul(let c, let a, let b): try mul(c, a, b)
        case .mul16(let c, let a, let b): try mul16(c, a, b)
        case .div(let c, let a, let b): try div(c, a, b)
        case .div16(let c, let a, let b): try div16(c, a, b)
        case .mod(let c, let a, let b): try mod(c, a, b)
        case .mod16(let c, let a, let b): try mod16(c, a, b)
        case .eq(let c, let a, let b): try eq(c, a, b)
        case .eq16(let c, let a, let b): try eq16(c, a, b)
        case .ne(let c, let a, let b): try ne(c, a, b)
        case .ne16(let c, let a, let b): try ne16(c, a, b)
        case .lt(let c, let a, let b): try lt(c, a, b)
        case .lt16(let c, let a, let b): try lt16(c, a, b)
        case .gt(let c, let a, let b): try gt(c, a, b)
        case .gt16(let c, let a, let b): try gt16(c, a, b)
        case .le(let c, let a, let b): try le(c, a, b)
        case .le16(let c, let a, let b): try le16(c, a, b)
        case .ge(let c, let a, let b): try ge(c, a, b)
        case .ge16(let c, let a, let b): try ge16(c, a, b)
        case .and(let c, let a, let b): try and(c, a, b)
        case .and16(let c, let a, let b): try and16(c, a, b)
        case .or(let c, let a, let b): try or(c, a, b)
        case .or16(let c, let a, let b): try or16(c, a, b)
        case .xor(let c, let a, let b): try xor(c, a, b)
        case .xor16(let c, let a, let b): try xor16(c, a, b)
        case .lsl(let c, let a, let b): try lsl(c, a, b)
        case .lsl16(let c, let a, let b): try lsl16(c, a, b)
        case .lsr(let c, let a, let b): try lsr(c, a, b)
        case .lsr16(let c, let a, let b): try lsr16(c, a, b)
        case .neg(let c, let a): try neg(c, a)
        case .neg16(let c, let a): try neg16(c, a)
        case .not(let c, let a): try not(c, a)
        case .jz(let label, let test): try jz(label, test)
        case .jnz(let label, let test): try jnz(label, test)
        case .copyWordZeroExtend(let b, let a): try copyWordZeroExtend(b, a)
        case .copyWords(let dst, let src, let count): try copyWords(dst, src, count)
        case .copyWordsIndirectSource(let dst, let srcPtr, let count): try copyWordsIndirectSource(dst, srcPtr, count)
        case .copyWordsIndirectDestination(let dstPtr, let src, let count): try copyWordsIndirectDestination(dstPtr, src, count)
        case .copyWordsIndirectDestinationIndirectSource(let dstPtr, let srcPtr, let count): try copyWordsIndirectDestinationIndirectSource(dstPtr, srcPtr, count)
        case .copyLabel(let dst, let label): try copyLabel(dst, label)
        }
    }
    
    // Inserts epilogue code into the program, presumably at the end.
    func insertProgramEpilogue() throws {
        currentSourceAnchor = nil
        
        let instructionsBegin = instructions.count
        
        emit(.hlt)
        try generateProcedureCopyWordsWithLoop()
        try generateProcedureEnter()
        try generateProcedureLeave()
        try generateProcedurePushToStack()
        try generateProcedurePop()
        try generateProcedurePokePeripheral()
        try generateProcedureRet()
        try doAtEpilogue(self)
        
        let instructionsEnd = instructions.count
        if instructionsBegin < instructionsEnd {
            for i in instructionsBegin..<instructionsEnd {
                programDebugInfo?.bind(popInstructionIndex: i, crackleInstruction: nil)
                programDebugInfo?.bind(popInstructionIndex: i, sourceAnchor: currentSourceAnchor)
                programDebugInfo?.bind(popInstructionIndex: i, symbols: currentSymbols)
            }
        }
    }
    
    public func nop() {}
    
    public func push(_ value: Int) throws {
        try decrementStackPointer()
        try loadStackPointerIntoUVandXY()
        emit(.li(.M, value)) // Write the new value to the top of the stack.
    }
    
    public func push16(_ value: Int) throws {
        let hi = (value>>8) & 0xff
        let lo =  value & 0xff
        try push(lo)
        try push(hi)
    }
    
    private func loadStackPointerIntoUVandXY() throws {
        // Load the 16-bit stack pointer into XY.
        try setUV(kStackPointerAddressHi)
        emit(.mov(.X, .M))
        try setUV(kStackPointerAddressLo)
        emit(.mov(.Y, .M))
        emit(.mov(.U, .X))
        emit(.mov(.V, .Y))
    }
    
    private func decrementStackPointer() throws {
        // First, save A in a well-known scratch location.
        let scratch = allocateScratchMemory(1)
        try setUV(scratch)
        emit(.mov(.M, .A))
        
        // Decrement the low byte of the 16-bit stack pointer.
        try setUV(kStackPointerAddressLo)
        emit(.mov(.A, .M))
        emit(.dea(.A))
        emit(.mov(.M, .A))
        
        // While we have it in A, stash a copy of the low byte to Y.
        // This prevents the need for another memory load below.
        emit(.mov(.Y, .A))
        
        // Decrement the high byte of the 16-bit stack pointer, but only if the
        // above decrement set the carry flag.
        try setUV(kStackPointerAddressHi)
        emit(.mov(.A, .M))
        emit(.dca(.A))
        emit(.mov(.M, .A)) // TODO: Can I remove this instruction and make the above DCA write the result to M directly?
        
        // While we have it in A, stash a copy of the high byte to X.
        // This prevents the need for another memory load below.
        emit(.mov(.X, .A))
        
        // Restore A
        // (We saved this to a well-known scratch location earlier.)
        try setUV(scratch)
        emit(.mov(.A, .M))
    }
    
    private func pop() throws {
        try jalr(kProcPop)
    }
    
    private func subi16(_ c: Int, _ a: Int, _ imm: Int) throws {
        try setUV(a+1)
        emit(.mov(.A, .M))
        emit(.li(.B, imm & 0xff))
        try setUV(c+1)
        emit(.sub(.M))
        
        try setUV(a+0)
        emit(.mov(.A, .M))
        emit(.li(.B, (imm >> 8) & 0xff))
        try setUV(c+0)
        emit(.sbc(.M))
    }
    
    private func addi16(_ c: Int, _ a: Int, _ imm: Int) throws {
        try setUV(a+1)
        emit(.mov(.A, .M))
        emit(.li(.B, imm & 0xff))
        try setUV(c+1)
        emit(.add(.M))
        
        try setUV(a+0)
        emit(.mov(.A, .M))
        emit(.li(.B, (imm >> 8) & 0xff))
        try setUV(c+0)
        emit(.adc(.M))
    }
    
    private func muli16(_ resultAddress: Int, _ multiplicandAddress: Int, _ imm: Int) throws {
        // Copy the multiplier to a scratch location because we modify it in
        // the loop.
        let multiplierAddress = allocateScratchMemory(2)
        emit(.li(.A, (imm >> 8) & 0xff))
        try setUV(multiplierAddress+0)
        emit(.mov(.M, .A))
        emit(.li(.A, imm & 0xff))
        try setUV(multiplierAddress+1)
        emit(.mov(.M, .A))
        
        // Initialize the result to zero.
        try setUV(resultAddress+0)
        emit(.li(.M, 0))
        try setUV(resultAddress+1)
        emit(.li(.M, 0))
        
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        let notDone = labelMaker.next()
        
        try label(loopHead)
        
        // If the multiplier is equal to zero then bail because we're done.
        try setUV(multiplierAddress+1)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.jne(notDone))
        try setUV(multiplierAddress+0)
        emit(.mov(.A, .M))
        emit(.cmp)
        emit(.jne(notDone))
        emit(.jmp(loopTail))
        try label(notDone)
        
        // Add the multiplicand to the result.
        try setUV(multiplicandAddress+1)
        emit(.mov(.B, .M))
        try setUV(resultAddress+1)
        emit(.mov(.A, .M))
        emit(.add(.M))
        try setUV(multiplicandAddress+0)
        emit(.mov(.B, .M))
        try setUV(resultAddress+0)
        emit(.mov(.A, .M))
        emit(.adc(.M))
        
        // Decrement the multiplier.
        try setUV(multiplierAddress+1)
        emit(.mov(.A, .M))
        emit(.dea(.M))
        try setUV(multiplierAddress+0)
        emit(.mov(.A, .M))
        emit(.dca(.M))
        
        // Jump back to the beginning of the loop
        try jmp(loopHead)
        try label(loopTail)
    }
    
    private func pushAToStack() throws {
        try decrementStackPointer()
        try loadStackPointerIntoUVandXY()
        
        // Write the new value to the top of the stack.
        emit(.mov(.M, .A))
    }
    
    private func popInMemoryStackIntoRegisterB() throws {
        try loadStackPointerIntoUVandXY()
        
        // Load the top of the stack into B.
        emit(.mov(.U, .X))
        emit(.mov(.V, .Y))
        emit(.mov(.B, .M))
        
        // Increment the stack pointer.
        emit(.inxy)
        
        // Write the modified stack pointer back to memory.
        try storeXYToStackPointer()
    }
    
    private func storeXYToStackPointer() throws {
        // Write the modified stack pointer back to memory.
        try setUV(kStackPointerAddressHi)
        emit(.mov(.M, .X))
        try setUV(kStackPointerAddressLo)
        emit(.mov(.M, .Y))
    }
    
    public func pop16() throws {
        try popInMemoryStackIntoRegisterB()
        emit(.mov(.A, .B))
        try popInMemoryStackIntoRegisterB()
    }
    
    public func storeImmediate(_ address: Int, _ value: Int) throws {
        try setUV(address)
        emit(.li(.M, value & 0xff))
    }
    
    public func storeImmediate16(_ address: Int, _ value: Int) throws {
        try storeImmediateBytes(address, [
            UInt8((value>>8) & 0xff),
            UInt8(value & 0xff)
        ])
    }
    
    public func storeImmediateBytes(_ address: Int, _ bytes: [UInt8]) throws {
        guard !bytes.isEmpty else {
            return
        }
        try setUV(address-1)
        for i in 0..<bytes.count {
            let value = Int(bytes[i])
            emit(.blti(.M, value))
        }
    }
    
    public func storeImmediateBytesIndirect(_ dstPtr: Int, _ bytes: [UInt8]) throws {
        try setUV(dstPtr)
        emit(.mov(.X, .M))
        emit(.inuv)
        emit(.mov(.Y, .M))
        emit(.mov(.U, .X))
        emit(.mov(.V, .Y))
        for i in 0..<bytes.count {
            emit(.li(.M, Int(bytes[i])))
            emit(.inuv)
        }
    }
    
    public func label(_ name: String) throws {
        emit(.label(name))
    }
    
    public func jmp(_ label: String) throws {
        emit(.jmp(label))
    }
    
    fileprivate var isJalrPermitted = true
    
    public func jalr(_ label: String) throws {
        assert(isJalrPermitted)
        emit(.jalr(label))
    }
    
    public func indirectJalr(_ address: Int) throws {
        assert(isJalrPermitted)
        try setUV(address)
        emit(.mov(.X, .M))
        emit(.inuv)
        emit(.mov(.Y, .M))
        emit(.explicitJalr)
    }
    
    public func enter() throws {
        // push fp in two bytes ; fp <- sp
        try jalr(kProcEnter)
    }
    
    public func leave() throws {
        // sp <- fp ; fp <- pop two bytes from the stack
        try jalr(kProcLeave)
    }
    
    private func pushReturnAddress() throws {
        let tempValueToPush = allocateScratchMemory(2)
        assert(tempValueToPush == 0x0004)
        try setUV(tempValueToPush+0)
        emit(.mov(.M, .G))
        emit(.inuv)
        emit(.mov(.M, .H))
        try jalr(kProcPushToStack)
    }
    
    private func leafRet() throws {
        emit(.mov(.X, .G))
        emit(.mov(.Y, .H))
        emit(.explicitJmp)
    }
    
    public func ret() throws {
        try jmp(kProcRet)
    }
    
    public func hlt() {
        emit(.hlt)
    }
    
    public func peekPeripheral() throws { // TODO: need unit test for peekPeripheral
        try popInMemoryStackIntoRegisterB()
        emit(.mov(.D, .B))
        try pop16()
        emit(.mov(.X, .A))
        emit(.mov(.Y, .B))
        emit(.mov(.A, .P))
        try pushAToStack()
    }
    
    public func pokePeripheral() throws {
        try jalr(kProcPokePeripheral)
    }
    
    private func add(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        emit(.add(.M))
    }
    
    private func setupALUOperandsAndDestinationAddress(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(b)
        emit(.mov(.B, .M))
        try setUV(a)
        emit(.mov(.A, .M))
        try setUV(c)
    }
    
    private func add16(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a+1)
        emit(.mov(.A, .M))
        try setUV(b+1)
        emit(.mov(.B, .M))
        try setUV(c+1)
        emit(.add(.M))
        
        try setUV(a+0)
        emit(.mov(.A, .M))
        try setUV(b+0)
        emit(.mov(.B, .M))
        try setUV(c+0)
        emit(.adc(.M))
    }
    
    private func sub(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        emit(.sub(.M))
    }
    
    private func sub16(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a+1)
        emit(.mov(.A, .M))
        try setUV(b+1)
        emit(.mov(.B, .M))
        try setUV(c+1)
        emit(.sub(.M))
        
        try setUV(a+0)
        emit(.mov(.A, .M))
        try setUV(b+0)
        emit(.mov(.B, .M))
        try setUV(c+0)
        emit(.sbc(.M))
    }
    
    private func mul(_ resultAddress: Int, _ multiplicandAddress: Int, _ originalMultiplierAddress: Int) throws {
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // Reset the result to zero since we accumulate in it over the loop.
        try setUV(resultAddress)
        emit(.li(.M, 0))
        
        // Copy the multiplier to a scratch location because we modify it in
        // the loop.
        let multiplierAddress = allocateScratchMemory(1)
        try setUV(originalMultiplierAddress)
        emit(.mov(.A, .M))
        try setUV(multiplierAddress)
        emit(.mov(.M, .A))
        
        try label(loopHead)
        
        // If the multiplier is equal to zero then bail because we're done.
        try setUV(multiplierAddress)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.je(loopTail))
        
        // Add the multiplicand to the result.
        try setUV(multiplicandAddress)
        emit(.mov(.B, .M))
        try setUV(resultAddress)
        emit(.mov(.A, .M))
        emit(.add(.M))
        
        // Decrement the multiplier.
        try setUV(multiplierAddress)
        emit(.mov(.A, .M))
        emit(.dea(.M))
        
        try jmp(loopHead) // Jump back to the beginning of the loop
        try label(loopTail)
    }
    
    private func mul16(_ resultAddress: Int, _ multiplicandAddress: Int, _ originalMultiplierAddress: Int) throws {
        // Copy the multiplier to a scratch location because we modify it in
        // the loop.
        let multiplierAddress = allocateScratchMemory(2)
        try setUV(originalMultiplierAddress+0)
        emit(.mov(.A, .M))
        try setUV(multiplierAddress+0)
        emit(.mov(.M, .A))
        try setUV(originalMultiplierAddress+1)
        emit(.mov(.A, .M))
        try setUV(multiplierAddress+1)
        emit(.mov(.M, .A))
        
        // Initialize the result to zero.
        try setUV(resultAddress+0)
        emit(.li(.M, 0))
        try setUV(resultAddress+1)
        emit(.li(.M, 0))
        
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        let notDone = labelMaker.next()
        
        try label(loopHead)
        
        // If the multiplier is equal to zero then bail because we're done.
        try setUV(multiplierAddress+1)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.jne(notDone))
        try setUV(multiplierAddress+0)
        emit(.mov(.A, .M))
        emit(.cmp)
        emit(.jne(notDone))
        emit(.jmp(loopTail))
        try label(notDone)
        
        // Add the multiplicand to the result.
        try setUV(multiplicandAddress+1)
        emit(.mov(.B, .M))
        try setUV(resultAddress+1)
        emit(.mov(.A, .M))
        emit(.add(.M))
        try setUV(multiplicandAddress+0)
        emit(.mov(.B, .M))
        try setUV(resultAddress+0)
        emit(.mov(.A, .M))
        emit(.adc(.M))
        
        // Decrement the multiplier.
        try setUV(multiplierAddress+1)
        emit(.mov(.A, .M))
        emit(.dea(.M))
        try setUV(multiplierAddress+0)
        emit(.mov(.A, .M))
        emit(.dca(.M))
        
        // Jump back to the beginning of the loop
        try jmp(loopHead)
        try label(loopTail)
    }
    
    private func div(_ counter: Int, _ originalA: Int, _ b: Int) throws {
        // Copy `a' to a scratch location because we modify it in the loop.
        let a = allocateScratchMemory(1)
        try setUV(originalA)
        emit(.mov(.A, .M))
        try setUV(a)
        emit(.mov(.M, .A))
        
        try div_modifyingA(counter, a, b)
    }
    
    private func div_modifyingA(_ counter: Int, _ a: Int, _ b: Int) throws {
        // Reset the counter
        try setUV(counter)
        emit(.li(.M, 0))
        
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // if b == 0 then bail because it's division by zero
        try setUV(b)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.jne(loopHead))
        try setUV(a)
        emit(.li(.M, 0))
        try jmp(loopTail)
        
        // while a >= b
        try label(loopHead)
        try setUV(a)
        emit(.mov(.A, .M))
        try setUV(b)
        emit(.mov(.B, .M))
        emit(.cmp)
        emit(.jl(loopTail))
        
        // a = a - b
        try setUV(b)
        emit(.mov(.B, .M))
        try setUV(a)
        emit(.mov(.A, .M))
        emit(.sub(.M))
        
        // c += 1
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.li(.B, 1))
        emit(.add(.M))
        
        // loop
        try jmp(loopHead)
        try label(loopTail)
    }
    
    private func div16(_ counterAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
        // Copy the dividend `a' to a scratch location because we modify it in
        // the loop.
        let addressOfA = allocateScratchMemory(2)
        try setUV(addressOfOriginalA+0)
        emit(.mov(.A, .M))
        try setUV(addressOfA+0)
        emit(.mov(.M, .A))
        try setUV(addressOfOriginalA+1)
        emit(.mov(.A, .M))
        try setUV(addressOfA+1)
        emit(.mov(.M, .A))
        
        try div16_modifyingA(counterAddress, addressOfA, addressOfB)
    }
    
    private func div16_modifyingA(_ counterAddress: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        // Initialize the counter to zero.
        // `c' is the counter
        try setUV(counterAddress+0)
        emit(.li(.M, 0))
        try setUV(counterAddress+1)
        emit(.li(.M, 0))
        
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // if b == 0 then bail because it's division by zero
        try setUV(addressOfB+1)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.jne(loopHead))
        try setUV(addressOfB+0)
        emit(.mov(.A, .M))
        emit(.cmp)
        emit(.jne(loopHead))
        try setUV(addressOfA+0)
        emit(.li(.M, 0))
        try setUV(addressOfA+1)
        emit(.li(.M, 0))
        try jmp(loopTail)
        
        // while a >= b
        try label(loopHead)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        emit(.mov(.A, .M))
        try setUV(addressOfB+1)
        emit(.mov(.B, .M))
        
        // Compare the low bytes.
        emit(.sub(.NONE))
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        emit(.mov(.A, .M))
        try setUV(addressOfB+0)
        emit(.mov(.B, .M))
        
        // Compare the high bytes.
        emit(.sbc(.NONE))
        
        emit(.jnc(loopTail))
        
        // a = a - b
        try setUV(addressOfB+1)
        emit(.mov(.B, .M))
        try setUV(addressOfA+1)
        emit(.mov(.A, .M))
        emit(.sub(.M))
        try setUV(addressOfB+0)
        emit(.mov(.B, .M))
        try setUV(addressOfA+0)
        emit(.mov(.A, .M))
        emit(.sbc(.M))
        
        // c += 1
        try setUV(counterAddress+0)
        emit(.mov(.X, .M))
        try setUV(counterAddress+1)
        emit(.mov(.Y, .M))
        emit(.inxy)
        try setUV(counterAddress+0)
        emit(.mov(.M, .X))
        try setUV(counterAddress+1)
        emit(.mov(.M, .Y))
        
        // loop
        try jmp(loopHead)
        try label(loopTail)
    }
    
    private func mod(_ resultAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
        let counterAddress = allocateScratchMemory(1)
        
        // Copy `a' to a scratch location because we modify it in the loop.
        try setUV(addressOfOriginalA)
        emit(.mov(.A, .M))
        try setUV(resultAddress)
        emit(.mov(.M, .A))
        
        try div_modifyingA(counterAddress, resultAddress, addressOfB)
    }
    
    private func mod16(_ resultAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
        let counterAddress = allocateScratchMemory(2)
        
        // Copy the dividend `a' to a scratch location because we modify it in
        // the loop.
        try setUV(addressOfOriginalA+0)
        emit(.mov(.A, .M))
        try setUV(resultAddress+0)
        emit(.mov(.M, .A))
        try setUV(addressOfOriginalA+1)
        emit(.mov(.A, .M))
        try setUV(resultAddress+1)
        emit(.mov(.M, .A))
        
        try div16_modifyingA(counterAddress, resultAddress, addressOfB)
    }
    
    public func eq(_ c: Int, _ a: Int, _ b: Int) throws {
        try comparison("JE", c, a, b)
    }
    
    public func ne(_ c: Int, _ a: Int, _ b: Int) throws {
        try comparison("JNE", c, a, b)
    }
    
    public func lt(_ c: Int, _ a: Int, _ b: Int) throws {
        try comparison("JL", c, a, b)
    }
    
    public func gt(_ c: Int, _ a: Int, _ b: Int) throws {
        try comparison("JG", c, a, b)
    }
    
    public func le(_ c: Int, _ a: Int, _ b: Int) throws {
        try comparison("JLE", c, a, b)
    }
    
    public func ge(_ c: Int, _ a: Int, _ b: Int) throws {
        try comparison("JGE", c, a, b)
    }
    
    private func comparison(_ comparison: String, _ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a)
        emit(.mov(.A, .M))
        
        try setUV(b)
        emit(.mov(.B, .M))
        
        try setUV(c)
        
        let tail = labelMaker.next()
        emit(.cmp)
        emit(.li(.M, 1))
        
        switch comparison {
        case "JE":
            emit(.je(tail))
        case "JNE":
            emit(.jne(tail))
        case "JL":
            emit(.jl(tail))
        case "JG":
            emit(.jg(tail))
        case "JLE":
            emit(.jle(tail))
        case "JGE":
            emit(.jge(tail))
        default:
            abort()
        }
        
        emit(.li(.M, 0))
        try label(tail)
    }
    
    private func eq16(_ c: Int, _ a: Int, _ b: Int) throws {
        try eq16(c, a, b, 1, 0)
    }
    
    private func ne16(_ c: Int, _ a: Int, _ b: Int) throws {
        try eq16(c, a, b, 0, 1)
    }
    
    private func eq16(_ c: Int, _ a: Int, _ b: Int, _ valueOnPass: Int, _ valueOnFail: Int) throws {
        let label_fail_test = labelMaker.next()
        let label_tail = labelMaker.next()
        
        try setUV(b+1)
        emit(.mov(.A, .M))
        try setUV(a+1)
        emit(.mov(.B, .M))
        emit(.cmp)
        
        emit(.jne(label_fail_test))
        
        try setUV(b+0)
        emit(.mov(.A, .M))
        try setUV(a+0)
        emit(.mov(.B, .M))
        emit(.cmp)
        
        emit(.jne(label_fail_test))
        
        try setUV(c)
        emit(.li(.M, valueOnPass))
        try jmp(label_tail)
        
        try label(label_fail_test)
        try setUV(c)
        emit(.li(.M, valueOnFail))
        
        try label(label_tail)
    }
    
    private func lt16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        let labelFailEqualityTest = labelMaker.next()
        let labelTail = labelMaker.next()
        
        // Compare low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+1)
        emit(.mov(.A, .M))
        try setUV(addressOfA+1)
        emit(.mov(.B, .M))
        emit(.cmp)
        emit(.jne(labelFailEqualityTest))
        
        // Compare high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+0)
        emit(.mov(.A, .M))
        try setUV(addressOfA+0)
        emit(.mov(.B, .M))
        emit(.cmp)
        emit(.jne(labelFailEqualityTest))
        
        // The two operands are equal so return false.
        emit(.li(.A, 0))
        try jmp(labelTail)
        
        try label(labelFailEqualityTest)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+1)
        emit(.mov(.A, .M))
        try setUV(addressOfA+1)
        emit(.mov(.B, .M))
        
        // Compare the low bytes.
        emit(.sub(.NONE))
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+0)
        emit(.mov(.A, .M))
        try setUV(addressOfA+0)
        emit(.mov(.B, .M))
        
        // Compare the high bytes.
        emit(.sbc(.NONE))
        
        // A <- (carry_flag) ? 1 : 0
        emit(.li(.A, 1))
        emit(.jc(labelTail))
        emit(.li(.A, 0))
        try label(labelTail)
        
        // Store the value in the A register to the result, in `c'.
        try setUV(addressOfC)
        emit(.mov(.M, .A))
    }
    
    private func gt16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        let labelFailEqualityTest = labelMaker.next()
        let labelTail = labelMaker.next()
        let labelThen = labelMaker.next()
        
        // Compare low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        emit(.mov(.A, .M))
        try setUV(addressOfB+1)
        emit(.mov(.B, .M))
        emit(.cmp)
        emit(.jne(labelFailEqualityTest))
        
        // Compare high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        emit(.mov(.A, .M))
        try setUV(addressOfB+0)
        emit(.mov(.B, .M))
        emit(.cmp)
        emit(.jne(labelFailEqualityTest))
        
        // The two operands are equal so return true.
        try jmp(labelThen)
        
        try label(labelFailEqualityTest)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        emit(.mov(.A, .M))
        try setUV(addressOfB+1)
        emit(.mov(.B, .M))
        
        // Compare the low bytes.
        emit(.sub(.NONE))
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        emit(.mov(.A, .M))
        try setUV(addressOfB+0)
        emit(.mov(.B, .M))
        
        // Compare the high bytes.
        emit(.sbc(.NONE))
        
        // A <- (carry_flag) ? 0 : 1
        emit(.jnc(labelThen))
        emit(.li(.A, 1))
        emit(.jmp(labelTail))
        try label(labelThen)
        emit(.li(.A, 0))
        try label(labelTail)
        
        // Store the value in the A register to the result, in `c'.
        try setUV(addressOfC)
        emit(.mov(.M, .A))
    }
    
    private func le16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+1)
        emit(.mov(.A, .M))
        try setUV(addressOfA+1)
        emit(.mov(.B, .M))
        
        // Compare the low bytes.
        emit(.sub(.NONE))
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfB+0)
        emit(.mov(.A, .M))
        try setUV(addressOfA+0)
        emit(.mov(.B, .M))
        
        let labelThen = labelMaker.next()
        
        // Compare the high bytes.
        emit(.sbc(.NONE))
        
        // A <- (carry_flag==active) ? 1 : 0
        emit(.li(.A, 1))
        emit(.jc(labelThen))
        emit(.li(.A, 0))
        try label(labelThen)
        
        try setUV(addressOfC)
        emit(.mov(.M, .A))
    }
    
    private func ge16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
        // Load the low bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+1)
        emit(.mov(.A, .M))
        try setUV(addressOfB+1)
        emit(.mov(.B, .M))
        
        // Compare the low bytes.
        emit(.sub(.NONE))
        
        // Load the high bytes of `a' and `b' into the A and B registers.
        try setUV(addressOfA+0)
        emit(.mov(.A, .M))
        try setUV(addressOfB+0)
        emit(.mov(.B, .M))
        
        // Compare the high bytes.
        emit(.sbc(.NONE))
        
        // A <- (carry_flag) ? 0 : 1
        let labelTail = labelMaker.next()
        let labelThen = labelMaker.next()
        emit(.jc(labelThen))
        emit(.li(.A, 0))
        emit(.jmp(labelTail))
        try label(labelThen)
        emit(.li(.A, 1))
        try label(labelTail)
        
        try setUV(addressOfC)
        emit(.mov(.M, .A))
    }
    
    private func jz(_ label: String, _ test: Int) throws {
        try jei(label, test, 0)
    }
    
    private func jnz(_ label: String, _ test: Int) throws {
        try jei(label, test, 1)
    }
    
    private func jei(_ label: String, _ addressOfTestValue: Int, _ valueToTestAgainst: Int) throws {
        try setUV(addressOfTestValue)
        emit(.mov(.A, .M))
        emit(.li(.B, valueToTestAgainst))
        emit(.cmp)
        emit(.je(label))
    }
    
    private func copyWordZeroExtend(_ dst: Int, _ src: Int) throws {
        try setUV(src)
        emit(.mov(.X, .M))
        
        try setUV(dst)
        emit(.li(.M, 0))
        
        emit(.inuv)
        emit(.mov(.M, .X))
    }
    
    private func copyWords(_ dst: Int, _ src: Int, _ numberOfBytesToCopy: Int) throws {
        switch numberOfBytesToCopy {
        case 0:
            return
        case 1..<6:
            for i in 0..<numberOfBytesToCopy {
                try setUV(src + i)
                emit(.mov(.A, .M))
                try setUV(dst + i)
                emit(.mov(.M, .A))
            }
        default:
            let tempDstPointer = allocateScratchMemory(2)
            let tempSrcPointer = allocateScratchMemory(2)
            let tempLimitPointer = allocateScratchMemory(2)
            
            // Initialize the destination pointer
            try storeImmediate16(tempDstPointer, dst)
            
            // Initialize the source pointer
            try storeImmediate16(tempSrcPointer, src)
            
            // Initialize the limit pointer
            try storeImmediate16(tempLimitPointer, src + numberOfBytesToCopy)
            
            try copyWordsWithLoop(tempDstPointer, tempSrcPointer, tempLimitPointer)
        }
    }
    
    private func copyWordsIndirectSource(_ dst: Int, _ srcPtr: Int, _ numberOfBytesToCopy: Int) throws {
        switch numberOfBytesToCopy {
        case 0:
            return
        case 1..<5:
            try setUV(srcPtr)
            emit(.mov(.X, .M))
            emit(.inuv)
            emit(.mov(.Y, .M))
            
            for i in 0..<numberOfBytesToCopy {
                emit(.mov(.U, .X))
                emit(.mov(.V, .Y))
                emit(.mov(.A, .M))
                try setUV(dst + i)
                emit(.mov(.M, .A))
                if i != numberOfBytesToCopy-1 {
                    emit(.inxy)
                }
            }
        default:
            let tempDstPointer = allocateScratchMemory(2)
            let tempSrcPointer = allocateScratchMemory(2)
            let tempLimitPointer = allocateScratchMemory(2)
            
            // Initialize the destination pointer
            try storeImmediate16(tempDstPointer, dst)
            
            // Initialize the source pointer
            try setUV(srcPtr + 0)
            emit(.mov(.A, .M))
            try setUV(tempSrcPointer + 0)
            emit(.mov(.M, .A))
            
            try setUV(srcPtr + 1)
            emit(.mov(.A, .M))
            try setUV(tempSrcPointer + 1)
            emit(.mov(.M, .A))
            
            // Initialize the limit pointer
            try addi16(tempLimitPointer, tempSrcPointer, numberOfBytesToCopy)
            
            try copyWordsWithLoop(tempDstPointer, tempSrcPointer, tempLimitPointer)
        }
    }
    
    private func copyWordsIndirectDestination(_ dstPtr: Int, _ src: Int, _ numberOfBytesToCopy: Int) throws {
        switch numberOfBytesToCopy {
        case 0:
            return
        case 1..<5:
            try setUV(dstPtr)
            emit(.mov(.X, .M))
            emit(.inuv)
            emit(.mov(.Y, .M))
            
            for i in 0..<numberOfBytesToCopy {
                try setUV(src + i)
                emit(.mov(.A, .M))
                emit(.mov(.U, .X))
                emit(.mov(.V, .Y))
                emit(.mov(.M, .A))
                if i != numberOfBytesToCopy-1 {
                    emit(.inxy)
                }
            }
        default:
            let tempDstPointer = allocateScratchMemory(2)
            let tempSrcPointer = allocateScratchMemory(2)
            let tempLimitPointer = allocateScratchMemory(2)
            
            // Initialize the destination pointer
            try setUV(dstPtr + 0)
            emit(.mov(.A, .M))
            try setUV(tempDstPointer + 0)
            emit(.mov(.M, .A))
            
            try setUV(dstPtr + 1)
            emit(.mov(.A, .M))
            try setUV(tempDstPointer + 1)
            emit(.mov(.M, .A))
            
            // Initialize the source pointer
            try storeImmediate16(tempSrcPointer, src)
            
            // Initialize the limit pointer
            try addi16(tempLimitPointer, tempSrcPointer, numberOfBytesToCopy)
            
            try copyWordsWithLoop(tempDstPointer, tempSrcPointer, tempLimitPointer)
        }
    }
    
    private func copyWordsIndirectDestinationIndirectSource(_ originalDstPtr: Int, _ originalSrcPtr: Int, _ count: Int) throws {
        if count == 0 { // TODO: need unit test for case where count is zero
            return
        }
        
        // Copy the destination address to scratch memory.
        let dstPtr = allocateScratchMemory(2)
        try setUV(originalDstPtr)
        emit(.mov(.X, .M))
        emit(.inuv)
        emit(.mov(.Y, .M))
        try setUV(dstPtr)
        emit(.mov(.M, .X))
        emit(.inuv)
        emit(.mov(.M, .Y))
        
        // Copy the source address to scratch memory.
        let srcPtr = allocateScratchMemory(2)
        try setUV(originalSrcPtr)
        emit(.mov(.X, .M))
        emit(.inuv)
        emit(.mov(.Y, .M))
        try setUV(srcPtr)
        emit(.mov(.M, .X))
        emit(.inuv)
        emit(.mov(.M, .Y))
        
        // Copy the bytes.
        for i in 0..<count {
            try setUV(srcPtr)
            emit(.mov(.X, .M))
            emit(.inuv)
            emit(.mov(.Y, .M))
            emit(.mov(.U, .X))
            emit(.mov(.V, .Y))
            emit(.mov(.A, .M))
            
            try setUV(dstPtr)
            emit(.mov(.X, .M))
            emit(.inuv)
            emit(.mov(.Y, .M))
            emit(.mov(.U, .X))
            emit(.mov(.V, .Y))
            emit(.mov(.M, .A))
            
            // Increment the pointers in-place.
            if i != count-1 {
                try setUV(srcPtr)
                emit(.mov(.X, .M))
                emit(.inuv)
                emit(.mov(.Y, .M))
                emit(.inxy)
                emit(.mov(.M, .Y))
                try setUV(srcPtr)
                emit(.mov(.M, .X))
                
                try setUV(dstPtr)
                emit(.mov(.X, .M))
                emit(.inuv)
                emit(.mov(.Y, .M))
                emit(.inxy)
                emit(.mov(.M, .Y))
                try setUV(dstPtr)
                emit(.mov(.M, .X))
            }
        }
    }
    
    private func copyLabel(_ dst: Int, _ label: String) throws {
        emit(.copyLabel(dst, label))
    }
    
    fileprivate let kProcCopyWordsWithLoop = "__crackle_proc_copyWordsWithLoop"
    
    fileprivate func copyWordsWithLoop(_ tempDstPointer: Int, _ tempSrcPointer: Int, _ tempLimitPointer: Int) throws {
        assert(tempDstPointer == 0x0004)
        assert(tempSrcPointer == 0x0006)
        assert(tempLimitPointer == 0x0008)
        try jalr(kProcCopyWordsWithLoop)
    }
    
    fileprivate func generateProcedureCopyWordsWithLoop() throws {
        isJalrPermitted = false
        defer { isJalrPermitted = true }
        
        scratchPointer = beginningOfScratchMemory
        let tempDstPointer = allocateScratchMemory(2)
        let tempSrcPointer = allocateScratchMemory(2)
        let tempLimitPointer = allocateScratchMemory(2)
        
        assert(tempDstPointer == 0x0004)
        assert(tempSrcPointer == 0x0006)
        assert(tempLimitPointer == 0x0008)
        
        let loopHead = kProcCopyWordsWithLoop
        try label(loopHead)
        
        // Copy one byte from the source to the destination.
        try setUV(tempSrcPointer)
        emit(.mov(.X, .M))
        emit(.inuv)
        emit(.mov(.Y, .M))
        emit(.mov(.U, .X))
        emit(.mov(.V, .Y))
        emit(.mov(.A, .M))
        
        try setUV(tempDstPointer)
        emit(.mov(.X, .M))
        emit(.inuv)
        emit(.mov(.Y, .M))
        emit(.mov(.U, .X))
        emit(.mov(.V, .Y))
        emit(.mov(.M, .A))
        
        // Compute the source and destination addresses.
        try addi16(tempDstPointer, tempDstPointer, 1)
        try addi16(tempSrcPointer, tempSrcPointer, 1)
        
        // if srcPointer != srcLimit then loop
        try setUV(tempLimitPointer+0)
        emit(.mov(.A, .M))
        try setUV(tempSrcPointer+0)
        emit(.mov(.B, .M))
        emit(.cmp)
        
        emit(.jne(loopHead))
        
        try setUV(tempLimitPointer+1)
        emit(.mov(.A, .M))
        try setUV(tempSrcPointer+1)
        emit(.mov(.B, .M))
        emit(.cmp)
        
        emit(.jne(loopHead))
        
        try leafRet()
    }
    
    fileprivate let kProcEnter = "__crackle_proc_enter"
    
    fileprivate func generateProcedureEnter() throws {
        isJalrPermitted = false
        defer { isJalrPermitted = true }
        
        // push fp in two bytes ; fp <- sp
        try label(kProcEnter)
        
        try setUV(kFramePointerAddressLo)
        emit(.mov(.A, .M))
        try pushAToStack()
        
        try setUV(kFramePointerAddressHi)
        emit(.mov(.A, .M))
        try pushAToStack()
        
        try setUV(kStackPointerAddressHi)
        emit(.mov(.X, .M))
        try setUV(kStackPointerAddressLo)
        emit(.mov(.Y, .M))

        try setUV(kFramePointerAddressHi)
        emit(.mov(.M, .X))
        try setUV(kFramePointerAddressLo)
        emit(.mov(.M, .Y))
        
        try leafRet()
    }
    
    fileprivate let kProcLeave = "__crackle_proc_leave"
    
    fileprivate func generateProcedureLeave() throws {
        isJalrPermitted = false
        defer { isJalrPermitted = true }
        
        try label(kProcLeave)
        
        try setUV(kFramePointerAddressHi)
        emit(.mov(.X, .M))
        try setUV(kFramePointerAddressLo)
        emit(.mov(.Y, .M))
        
        try setUV(kStackPointerAddressHi)
        emit(.mov(.M, .X))
        try setUV(kStackPointerAddressLo)
        emit(.mov(.M, .Y))
        
        try popInMemoryStackIntoRegisterB()
        try setUV(kFramePointerAddressHi)
        emit(.mov(.M, .B))
        
        try popInMemoryStackIntoRegisterB()
        try setUV(kFramePointerAddressLo)
        emit(.mov(.M, .B))
        
        try leafRet()
    }
    
    fileprivate let kProcPushToStack = "__crackle_proc_pushToStack"
    
    fileprivate func generateProcedurePushToStack() throws {
        isJalrPermitted = false
        defer { isJalrPermitted = true }
        
        scratchPointer = beginningOfScratchMemory
        let tempSrcPointer = allocateScratchMemory(2)
        assert(tempSrcPointer == 0x0004)
        
        try label(kProcPushToStack)
        
        try setUV(tempSrcPointer+1)
        emit(.mov(.A, .M))
        try pushAToStack()
        
        try setUV(tempSrcPointer+0)
        emit(.mov(.A, .M))
        try pushAToStack()
        
        try leafRet()
    }
    
    fileprivate let kProcPop = "__crackle_proc_pop"
    
    fileprivate func generateProcedurePop() throws {
        isJalrPermitted = false
        defer { isJalrPermitted = true }
        
        try label(kProcPop)
        
        try popInMemoryStackIntoRegisterB()
        
        try leafRet()
    }
    
    fileprivate let kProcPokePeripheral = "__crackle_proc_poke_peripheral"
    
    fileprivate func generateProcedurePokePeripheral() throws {
        isJalrPermitted = false
        defer { isJalrPermitted = true }
        
        try label(kProcPokePeripheral)
        
        try popInMemoryStackIntoRegisterB()
        emit(.mov(.D, .B))
        
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        let stashedDestinationAddress = allocateScratchMemory(2)
        try setUV(stashedDestinationAddress+0)
        emit(.mov(.M, .A))
        try setUV(stashedDestinationAddress+1)
        emit(.mov(.M, .B))
        
        // Copy the top of the stack into A.
        try loadStackPointerIntoUVandXY()
        emit(.mov(.A, .M))
        
        // Restore the stashed destination address to XY.
        try setUV(stashedDestinationAddress+0)
        emit(.mov(.X, .M))
        try setUV(stashedDestinationAddress+1)
        emit(.mov(.Y, .M))
        
        // Store A to the destination address on the peripheral bus.
        emit(.mov(.P, .A))
        
        try leafRet()
    }
    
    fileprivate let kProcRet = "__crackle_proc_poke_ret"
    
    fileprivate func generateProcedureRet() throws {
        try label(kProcRet)
        
        scratchPointer = beginningOfScratchMemory
        let addressOfReturnAddressHi = allocateScratchMemory(1)
        
        try popInMemoryStackIntoRegisterB()
        try setUV(addressOfReturnAddressHi)
        emit(.mov(.M, .B))
        
        try popInMemoryStackIntoRegisterB()
        emit(.mov(.Y, .B))
        
        try setUV(addressOfReturnAddressHi)
        emit(.mov(.X, .M))
        
        emit(.explicitJmp)
    }
    
    private func and(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        emit(.and(.M))
    }
    
    private func and16(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a+1)
        emit(.mov(.A, .M))
        try setUV(b+1)
        emit(.mov(.B, .M))
        try setUV(c+1)
        emit(.and(.M))
        
        try setUV(a+0)
        emit(.mov(.A, .M))
        try setUV(b+0)
        emit(.mov(.B, .M))
        try setUV(c+0)
        emit(.and(.M))
    }
    
    private func or(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        emit(.or(.M))
    }
    
    private func or16(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a+1)
        emit(.mov(.A, .M))
        try setUV(b+1)
        emit(.mov(.B, .M))
        try setUV(c+1)
        emit(.or(.M))
        
        try setUV(a+0)
        emit(.mov(.A, .M))
        try setUV(b+0)
        emit(.mov(.B, .M))
        try setUV(c+0)
        emit(.or(.M))
    }
    
    private func xor(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        emit(.xor(.M))
    }
    
    private func xor16(_ c: Int, _ a: Int, _ b: Int) throws {
        try setUV(a+1)
        emit(.mov(.A, .M))
        try setUV(b+1)
        emit(.mov(.B, .M))
        try setUV(c+1)
        emit(.xor(.M))
        
        try setUV(a+0)
        emit(.mov(.A, .M))
        try setUV(b+0)
        emit(.mov(.B, .M))
        try setUV(c+0)
        emit(.xor(.M))
    }
    
    private func lsl(_ resultAddress: Int, _ leftOperand: Int, _ rightOperand: Int) throws {
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // Initialize the result
        try setUV(leftOperand)
        emit(.mov(.A, .M))
        try setUV(resultAddress)
        emit(.mov(.M, .A))
        
        // Copy the right operand to a scratch location because we modify it in
        // the loop.
        let counter = allocateScratchMemory(1)
        try setUV(rightOperand)
        emit(.mov(.A, .M))
        try setUV(counter)
        emit(.mov(.M, .A))
        
        try label(loopHead)
        
        // If the counter is equal to zero then bail because we're done.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.je(loopTail))
        
        // Shift the result left by one.
        try setUV(resultAddress)
        emit(.mov(.A, .M))
        try setUV(resultAddress)
        emit(.lsl(.M))
        
        // Decrement the counter.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.dea(.M))
        
        try jmp(loopHead) // Jump back to the beginning of the loop
        try label(loopTail)
    }
    
    private func lsl16(_ resultAddress: Int, _ leftOperand: Int, _ rightOperand: Int) throws {
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // Initialize the result
        try setUV(leftOperand+0)
        emit(.mov(.A, .M))
        try setUV(resultAddress+0)
        emit(.mov(.M, .A))
        try setUV(leftOperand+1)
        emit(.mov(.A, .M))
        try setUV(resultAddress+1)
        emit(.mov(.M, .A))
        
        // Copy the right operand to a scratch location because we modify it in
        // the loop. Discard the upper byte because we can shift by, at most,
        // sixteen.
        let counter = allocateScratchMemory(1)
        try setUV(rightOperand+1)
        emit(.mov(.A, .M))
        try setUV(counter)
        emit(.mov(.M, .A))
        
        try label(loopHead)
        
        // If the counter is equal to zero then bail because we're done.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.je(loopTail))
        
        try add16(resultAddress, resultAddress, resultAddress)
        
        // Decrement the counter.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.dea(.M))
        
        try jmp(loopHead) // Jump back to the beginning of the loop
        try label(loopTail)
    }
    
    private func lsr(_ resultAddress: Int, _ leftOperand: Int, _ rightOperand: Int) throws {
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        let two = allocateScratchMemory(1)
        try setUV(two)
        emit(.li(.M, 2))
        
        // Initialize the result
        try setUV(leftOperand)
        emit(.mov(.A, .M))
        try setUV(resultAddress)
        emit(.mov(.M, .A))
        
        // Copy the right operand to a scratch location because we modify it in
        // the loop.
        let counter = allocateScratchMemory(1)
        try setUV(rightOperand)
        emit(.mov(.A, .M))
        try setUV(counter)
        emit(.mov(.M, .A))
        
        try label(loopHead)
        
        // If the counter is equal to zero then bail because we're done.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.je(loopTail))
        
        try div(resultAddress, resultAddress, two)
        
        // Decrement the counter.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.dea(.M))
        
        try jmp(loopHead) // Jump back to the beginning of the loop
        try label(loopTail)
    }
    
    private func lsr16(_ resultAddress: Int, _ leftOperand: Int, _ rightOperand: Int) throws {
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        let two = allocateScratchMemory(2)
        try setUV(two)
        emit(.li(.M, 0))
        emit(.inuv)
        emit(.li(.M, 2))
        
        // Initialize the result
        try setUV(leftOperand+0)
        emit(.mov(.A, .M))
        try setUV(resultAddress+0)
        emit(.mov(.M, .A))
        try setUV(leftOperand+1)
        emit(.mov(.A, .M))
        try setUV(resultAddress+1)
        emit(.mov(.M, .A))
        
        // Copy the right operand to a scratch location because we modify it in
        // the loop. Discard the upper byte because we can shift by, at most,
        // sixteen.
        let counter = allocateScratchMemory(1)
        try setUV(rightOperand+1)
        emit(.mov(.A, .M))
        try setUV(counter)
        emit(.mov(.M, .A))
        
        try label(loopHead)
        
        // If the counter is equal to zero then bail because we're done.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.li(.B, 0))
        emit(.cmp)
        emit(.je(loopTail))
        
        try div16(resultAddress, resultAddress, two)
        
        // Decrement the counter.
        try setUV(counter)
        emit(.mov(.A, .M))
        emit(.dea(.M))
        
        try jmp(loopHead) // Jump back to the beginning of the loop
        try label(loopTail)
    }
    
    private func neg(_ result: Int, _ value: Int) throws {
        try setUV(value)
        emit(.mov(.A, .M))
        try setUV(result)
        emit(.neg(.M))
    }
    
    private func neg16(_ result: Int, _ value: Int) throws {
        try setUV(value+1)
        emit(.mov(.A, .M))
        try setUV(result+1)
        emit(.neg(.M))
        
        try setUV(value+0)
        emit(.mov(.A, .M))
        try setUV(result+0)
        emit(.neg(.M))
    }
    
    private func not(_ result: Int, _ value: Int) throws {
        try setUV(value)
        emit(.mov(.A, .M))
        try setUV(result)
        emit(.neg(.A))
        emit(.li(.B, 0b00000001))
        emit(.and(.M))
    }
}
