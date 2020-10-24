//
//  CrackleToTurtleMachineCodeCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox
import Darwin // for fputs

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
    public var programDebugInfo: SnapDebugInfo? = nil
    private var currentSourceAnchor: SourceAnchor? = nil
    private var currentSymbols: SymbolTable? = nil
    
    let labelMaker = LabelMaker(prefix: ".LL")
    
    public var doAtEpilogue: (CrackleToTurtleMachineCodeCompiler) throws -> Void = {_ in}
    
    public init(assembler: AssemblerBackEnd) {
        self.assembler = assembler
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
    
    private func setUV(_ value: Int) throws {
        try assembler.li(.U, (value>>8) & 0xff)
        try assembler.li(.V, value & 0xff)
    }
    
    public func compile(ir: [CrackleInstruction], base: Int = 0x0000) throws {
        patcherActions = []
        assembler.begin()
        try insertProgramPrologue()
        try compileProgramBody(ir)
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
        
        if nil == NSClassFromString("XCTest") {
            fputs("instruction words used: \(assembler.programCounter)\n", stderr)
        }
        
        if assembler.programCounter > 32767 {
            fputs("WARNING: generated code exceeds 32768 instruction memory words: \(assembler.programCounter) words used\n", stderr)
        }
        
        programDebugInfo?.generateMappingToProgramCounter(base: base)
    }
    
    // Inserts prologue code into the program, presumably at the beginning.
    // Insert a NOP at the beginning of every program because correct operation
    // of the hardware reset cycle requires this.
    // Likewise, correct operation of a program written in Snap requires some
    // initialization to be performed before anything else occurs.
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
    
    private func compileProgramBody(_ ir: [CrackleInstruction]) throws {
        for i in 0..<ir.count {
            currentSourceAnchor = programDebugInfo?.lookupSourceAnchor(crackleInstructionIndex: i)
            currentSymbols = programDebugInfo?.lookupSymbols(crackleInstructionIndex: i)
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
        case .pop: try pop()
        case .pop16: try pop16()
        case .subi16(let c, let a, let b): try subi16(c, a, b)
        case .addi16(let c, let a, let b): try addi16(c, a, b)
        case .muli16(let c, let a, let b): try muli16(c, a, b)
        case .storeImmediate(let address, let value): try storeImmediate(address, value)
        case .storeImmediate16(let address, let value): try storeImmediate16(address, value)
        case .storeImmediateBytes(let address, let bytes): try storeImmediateBytes(address, bytes)
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
        case .jz(let label, let test): try jz(label, test)
        case .copyWordZeroExtend(let b, let a): try copyWordZeroExtend(b, a)
        case .copyWords(let dst, let src, let count): try copyWords(dst, src, count)
        case .copyWordsIndirectSource(let dst, let srcPtr, let count): try copyWordsIndirectSource(dst, srcPtr, count)
        case .copyWordsIndirectDestination(let dstPtr, let src, let count): try copyWordsIndirectDestination(dstPtr, src, count)
        case .copyWordsIndirectDestinationIndirectSource(let dstPtr, let srcPtr, let count): try copyWordsIndirectDestinationIndirectSource(dstPtr, srcPtr, count)
        case .copyLabel(let dst, let label): try copyLabel(dst, label)
        }
        let instructionsEnd = assembler.instructions.count
        if instructionsBegin < instructionsEnd {
            for i in instructionsBegin..<instructionsEnd {
                programDebugInfo?.bind(assemblyInstructionIndex: i, crackleInstruction: instruction)
                programDebugInfo?.bind(assemblyInstructionIndex: i, sourceAnchor: currentSourceAnchor)
                programDebugInfo?.bind(assemblyInstructionIndex: i, symbols: currentSymbols)
            }
        }
    }
    
    // Inserts epilogue code into the program, presumably at the end.
    func insertProgramEpilogue() throws {
        assembler.hlt()
        try doAtEpilogue(self)
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
    
    private func subi16(_ c: Int, _ a: Int, _ imm: Int) throws {
        try setUV(a+1)
        try assembler.mov(.A, .M)
        try assembler.li(.B, imm & 0xff)
        try setUV(c+1)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        
        try setUV(a+0)
        try assembler.mov(.A, .M)
        try assembler.li(.B, (imm >> 8) & 0xff)
        try setUV(c+0)
        try assembler.sbc(.NONE)
        try assembler.sbc(.M)
    }
    
    private func addi16(_ c: Int, _ a: Int, _ imm: Int) throws {
        try setUV(a+1)
        try assembler.mov(.A, .M)
        try assembler.li(.B, imm & 0xff)
        try setUV(c+1)
        try assembler.add(.NONE)
        try assembler.add(.M)
        
        try setUV(a+0)
        try assembler.mov(.A, .M)
        try assembler.li(.B, (imm >> 8) & 0xff)
        try setUV(c+0)
        try assembler.adc(.NONE)
        try assembler.adc(.M)
    }
    
    private func muli16(_ resultAddress: Int, _ multiplicandAddress: Int, _ imm: Int) throws {
        // Copy the multiplier to a scratch location because we modify it in
        // the loop.
        let multiplierAddress = allocateScratchMemory(2)
        try assembler.li(.A, (imm >> 8) & 0xff)
        try setUV(multiplierAddress+0)
        try assembler.mov(.M, .A)
        try assembler.li(.A, imm & 0xff)
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
    
    public func pop16() throws {
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.A, .B)
        try popInMemoryStackIntoRegisterB()
    }
    
    public func storeImmediate(_ address: Int, _ value: Int) throws {
        try setUV(address)
        try assembler.li(.M, value & 0xff)
    }
    
    public func storeImmediate16(_ address: Int, _ value: Int) throws {
        try setUV(address+0)
        try assembler.li(.M, (value>>8) & 0xff)
        assembler.inuv()
        try assembler.li(.M, value & 0xff)
    }
    
    public func storeImmediateBytes(_ address: Int, _ bytes: [UInt8]) throws {
        guard !bytes.isEmpty else {
            return
        }
        try setUV(address)
        for i in 0..<bytes.count {
            let value = Int(bytes[i])
            try assembler.li(.M, value)
            if i != bytes.count-1 {
                assembler.inuv()
            }
        }
    }
    
    public func label(_ name: String) throws {
        guard labelTable[name] == nil else {
            throw CompilerError(sourceAnchor: currentSourceAnchor, message: "label redefines existing symbol: `\(name)'")
        }
        labelTable[name] = assembler.programCounter
    }
    
    public func jmp(_ label: String) throws {
        try setAddressToLabel(label)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    public func jalr(_ label: String) throws {
        try setAddressToLabel(label)
        assembler.jalr()
        assembler.nop()
        assembler.nop()
    }
    
    public func indirectJalr(_ address: Int) throws {
        try setUV(address)
        try assembler.mov(.X, .M)
        assembler.inuv()
        try assembler.mov(.Y, .M)
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
    
    private func pushReturnAddress() throws { // TODO: need unit test for pushReturnAddress
        try assembler.mov(.A, .H)
        try pushAToStack()
        try assembler.mov(.A, .G)
        try pushAToStack()
    }
    
    private func leafRet() throws { // TODO: need unit test for leafRet
        try assembler.mov(.X, .G)
        try assembler.mov(.Y, .H)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    public func ret() throws { // TODO: need unit test for ret
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
    
    public func peekPeripheral() throws { // TODO: need unit test for peekPeripheral
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.D, .B)
        try pop16()
        try assembler.mov(.X, .A)
        try assembler.mov(.Y, .B)
        try assembler.mov(.A, .P)
        try pushAToStack()
    }
    
    public func pokePeripheral() throws { // TODO: need unit test for pokePeripheral
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
        
    private func add(_ c: Int, _ a: Int, _ b: Int) throws {
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
    
    private func add16(_ c: Int, _ a: Int, _ b: Int) throws {
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
    
    private func sub(_ c: Int, _ a: Int, _ b: Int) throws {
        try setupALUOperandsAndDestinationAddress(c, a, b)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
    }
    
    private func sub16(_ c: Int, _ a: Int, _ b: Int) throws {
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
    
    private func mul(_ resultAddress: Int, _ multiplicandAddress: Int, _ originalMultiplierAddress: Int) throws {
        let loopHead = labelMaker.next()
        let loopTail = labelMaker.next()
        
        // Reset the result to zero since we accumulate in it over the loop.
        try setUV(resultAddress)
        try assembler.li(.M, 0)
        
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
    
    private func mul16(_ resultAddress: Int, _ multiplicandAddress: Int, _ originalMultiplierAddress: Int) throws {
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
    
    private func div(_ counter: Int, _ originalA: Int, _ b: Int) throws {
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
    
    private func div16(_ counterAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
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
    
    private func mod(_ resultAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
        let counterAddress = allocateScratchMemory(1)
        
        // Copy `a' to a scratch location because we modify it in the loop.
        try setUV(addressOfOriginalA)
        try assembler.mov(.A, .M)
        try setUV(resultAddress)
        try assembler.mov(.M, .A)
        
        try div_modifyingA(counterAddress, resultAddress, addressOfB)
    }
    
    private func mod16(_ resultAddress: Int, _ addressOfOriginalA: Int, _ addressOfB: Int) throws {
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
    
    private func lt16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
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
    
    private func gt16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
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
    
    private func le16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
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
    
    private func ge16(_ addressOfC: Int, _ addressOfA: Int, _ addressOfB: Int) throws {
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
    
    private func jz(_ label: String, _ test: Int) throws {
        try jei(label, test, 0)
    }
    
    private func jei(_ label: String, _ addressOfTestValue: Int, _ valueToTestAgainst: Int) throws {
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
        if count == 0 { // TODO: need unit test for case where count is zero
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
        if count == 0 { // TODO: need unit test for case where count is zero
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
        if count == 0 { // TODO: need unit test for case where count is zero
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
    
    private func copyLabel(_ dst: Int, _ label: String) throws {
        try setUV(dst)
        patcherActions.append((index: assembler.programCounter,
                               sourceAnchor: currentSourceAnchor,
                               symbol: label,
                               shift: 8))
        try assembler.li(.M, 0xff)
        assembler.inuv()
        patcherActions.append((index: assembler.programCounter,
                               sourceAnchor: currentSourceAnchor,
                               symbol: label,
                               shift: 0))
        try assembler.li(.M, 0xff)
    }
}
