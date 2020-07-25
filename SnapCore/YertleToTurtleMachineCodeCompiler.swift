//
//  YertleToTurtleMachineCodeCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

// Generates machine code for given IR code.
public class YertleToTurtleMachineCodeCompiler: NSObject {
    // Programs written in Snap use a push down stack, and store the stack
    // pointer in data RAM at addresses 0x0000 and 0x0001.
    // This is initialized on launch to 0x0000.
    public static let kStackPointerAddressHi: UInt16 = 0x0000
    public static let kStackPointerAddressLo: UInt16 = 0x0001
    public static let kStackPointerInitialValue: Int = 0x0000
    let kStackPointerHiHi = Int((YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi & 0xff00) >> 8)
    let kStackPointerHiLo = Int( YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi & 0x00ff)
    let kStackPointerLoHi = Int((YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo & 0xff00) >> 8)
    let kStackPointerLoLo = Int( YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo & 0x00ff)
    let kStackPointerInitialValueHi: Int = (kStackPointerInitialValue & 0xff00) >> 8
    let kStackPointerInitialValueLo: Int =  kStackPointerInitialValue & 0x00ff
    
    // Programs written in Snap store the frame pointer in data RAM at
    // addresses 0x0002 and 0x0003. This is initialized on launch to 0x0000.
    public static let kFramePointerAddressHi: UInt16 = 0x0002
    public static let kFramePointerAddressLo: UInt16 = 0x0003
    public static let kFramePointerInitialValue: Int = 0x0000
    let kFramePointerHiHi = Int((YertleToTurtleMachineCodeCompiler.kFramePointerAddressHi & 0xff00) >> 8)
    let kFramePointerHiLo = Int( YertleToTurtleMachineCodeCompiler.kFramePointerAddressHi & 0x00ff)
    let kFramePointerLoHi = Int((YertleToTurtleMachineCodeCompiler.kFramePointerAddressLo & 0xff00) >> 8)
    let kFramePointerLoLo = Int( YertleToTurtleMachineCodeCompiler.kFramePointerAddressLo & 0x00ff)
    let kFramePointerInitialValueHi: Int = (kFramePointerInitialValue & 0xff00) >> 8
    let kFramePointerInitialValueLo: Int =  kFramePointerInitialValue & 0x00ff
    
    let kScratchHi = 0
    let kScratchLo = 4
    
    let assembler: AssemblerBackEnd
    var patcherActions: [Patcher.Action] = []
    
    public private(set) var labelTable: [String:Int] = [:]
    public private(set) var instructions: [Instruction] = []
    
    public init(assembler: AssemblerBackEnd) {
        self.assembler = assembler
    }
    
    public func compile(ir: [YertleInstruction], base: Int) throws {
        patcherActions = []
        assembler.begin()
        try insertProgramPrologue()
        for instruction in ir {
            switch instruction {
            case .push(let value): try push(value)
            case .push16(let value): try push16(value)
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
            case .store16(let address): try store16(to: address)
            case .loadIndirect: try loadIndirect()
            case .loadIndirect16: try loadIndirect16()
            case .storeIndirect: try storeIndirect()
            case .storeIndirect16: try storeIndirect16()
            case .label(let token): try label(token: token)
            case .jmp(let token): try jmp(to: token)
            case .je(let token): try je(to: token)
            case .jalr(let token): try jalr(to: token)
            case .enter: try enter()
            case .leave: try leave()
            case .pushReturnAddress: try pushReturnAddress()
            case .leafRet: try leafRet()
            case .ret: try ret()
            case .hlt: assembler.hlt()
            case .peekPeripheral: try peekPeripheral()
            case .pokePeripheral: try pokePeripheral()
            }
        }
        insertProgramEpilogue()
        assembler.end()
        let resolver: (TokenIdentifier) throws -> Int = {[weak self] (identifier: TokenIdentifier) in
            if let address = self!.labelTable[identifier.lexeme] {
                return address
            } else {
                throw CompilerError(line: identifier.lineNumber, message: "cannot resolve label `\(identifier.lexeme)'")
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
        try assembler.li(.U, 0)
        try assembler.li(.V, 0)
        try assembler.li(.M, kStackPointerInitialValueHi)
        assembler.inuv()
        try assembler.li(.M, kStackPointerInitialValueLo)
        assembler.inuv()
        try assembler.li(.M, kFramePointerInitialValueHi)
        assembler.inuv()
        try assembler.li(.M, kFramePointerInitialValueLo)
    }
    
    // Inserts epilogue code into the program, presumably at the end.
    func insertProgramEpilogue() {
        assembler.hlt()
    }
    
    private func push(_ value: Int) throws {
        try decrementStackPointer()
        try loadStackPointerIntoUVandXY()
        
        // Write the new value to the top of the stack.
        try assembler.li(.M, value)
    }
    
    private func push16(_ value: Int) throws {
        let hi = (value>>8) & 0xff
        let lo =  value & 0xff
        try push(lo)
        try push(hi)
    }
    
    private func loadStackPointerIntoUVandXY() throws {
        // Load the 16-bit stack pointer into XY.
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.X, .M)
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.Y, .M)
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
    }
    
    private func decrementStackPointer() throws {
        // First, save A in a well-known scratch location.
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
        
        // While we have it in A, stash a copy of the low byte to Y.
        // This prevents the need for another memory load below.
        try assembler.mov(.Y, .A)
        
        // Decrement the high byte of the 16-bit stack pointer, but only if the
        // above decrement set the carry flag.
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.A, .M)
        try assembler.dca(.NONE)
        try assembler.dca(.A)
        try assembler.mov(.M, .A)
        
        // While we have it in A, stash a copy of the high byte to X.
        // This prevents the need for another memory load below.
        try assembler.mov(.X, .A)
        
        // Restore A
        // (We saved this to a well-known scratch location earlier.)
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo)
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
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.M, .X)
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.M, .Y)
    }
    
    private func popTwoDecrementStackPointerAndLeaveInUVandXY() throws {
        try pop16()
        try decrementStackPointer()
        try loadStackPointerIntoUVandXY()
    }
    
    private func pop16() throws {
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.A, .B)
        try popInMemoryStackIntoRegisterB()
    }
    
    private func eq() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.je()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
     private var tempLabelCounter = 0
    
    // The generated program will need unique, temporary labels.
    private func makeTempLabel() -> TokenIdentifier {
        let label = ".LL\(tempLabelCounter)"
        tempLabelCounter += 1
        return TokenIdentifier(lineNumber: -1, lexeme: label)
    }
    
    private func eq16() throws {
        try eq16(valueOnPass: 1, valueOnFail: 0)
    }
    
    private func eq16(valueOnPass: Int, valueOnFail: Int) throws {
        let label_fail_test = makeTempLabel()
        let label_tail = makeTempLabel()
        
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.M, .B)
        
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.M, .B)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        
        try setAddressToLabel(label_fail_test)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        
        try setAddressToLabel(label_fail_test)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        try push(valueOnPass)
        try jmp(to: label_tail)
        
        try label(token: label_fail_test)
        try push(valueOnFail)
        
        try label(token: label_tail)
    }
    
    private func ne() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    private func ne16() throws {
        try eq16(valueOnPass: 0, valueOnFail: 1)
    }
    
    private func lt() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jl()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    private func lt16() throws {
        let labelFailEqualityTest = makeTempLabel()
        let labelTail = makeTempLabel()
        
        let addressOfA = kScratchLo+0
        let addressOfB = kScratchLo+2

        // Pop `b' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop `a' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.M, .B)
        
        // Compare low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // Compare high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // The two operands are equal so return false.
        try assembler.li(.A, 0)
        try jmp(to: labelTail)
        
        try label(token: labelFailEqualityTest)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)

        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)

        // Load the high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
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
        try label(token: labelTail)
        
        try pushAToStack()
    }
    
    private func gt() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jg()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    private func gt16() throws {
        let labelFailEqualityTest = makeTempLabel()
        let labelTail = makeTempLabel()
        let labelThen = makeTempLabel()
        
        let addressOfA = kScratchLo+0
        let addressOfB = kScratchLo+2

        // Pop `a' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.M, .B)

        // Pop `b' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.M, .B)
        
        // Compare low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // Compare high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(labelFailEqualityTest)
        assembler.jne()
        assembler.nop()
        assembler.nop()
        
        // The two operands are equal so return true.
        try jmp(to: labelThen)
        
        try label(token: labelFailEqualityTest)
        
        // Load the low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)

        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)

        // Load the high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
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
        try label(token: labelThen)
        try assembler.li(.A, 0)
        try label(token: labelTail)
        
        try pushAToStack()
    }
    
    private func le() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jle()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    private func le16() throws {
        let addressOfA = kScratchLo+0
        let addressOfB = kScratchLo+2

        // Pop `b' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop `a' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.M, .B)

        // Load the low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)

        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)

        // Load the high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)
        
        let labelThen = makeTempLabel()
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
        try label(token: labelThen)
        try pushAToStack()
    }
    
    private func ge() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        let jumpTarget = assembler.programCounter + 9
        try assembler.li(.X, (jumpTarget & 0xff00) >> 8)
        try assembler.li(.Y,  jumpTarget & 0x00ff)
        assembler.cmp()
        assembler.cmp()
        try assembler.li(.M, 1)
        assembler.jge()
        assembler.nop()
        assembler.nop()
        try assembler.li(.M, 0)
        assert(assembler.programCounter == jumpTarget)
    }
    
    private func ge16() throws {
        let addressOfA = kScratchLo+0
        let addressOfB = kScratchLo+2

        // Pop `b' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop `a' and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.M, .B)

        // Load the low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)

        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)

        // Load the high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)

        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)
        
        // A <- (carry_flag) ? 0 : 1
        let labelTail = makeTempLabel()
        let labelThen = makeTempLabel()
        try setAddressToLabel(labelThen)
        assembler.jc()
        assembler.nop()
        assembler.nop()
        try assembler.li(.A, 0)
        try setAddressToLabel(labelTail)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        try label(token: labelThen)
        try assembler.li(.A, 1)
        try label(token: labelTail)
        
        try pushAToStack()
    }
    
    private func add() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        try assembler.add(.NONE)
        try assembler.add(.M)
    }
    
    private func add16() throws {
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.M, .B)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.M, .A)
        
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.M, .B)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.M, .A)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.B, .M)
        try assembler.add(.NONE)
        try assembler.add(.M)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.B, .M)
        try assembler.adc(.NONE)
        try assembler.adc(.M)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func sub() throws {
        try popTwoDecrementStackPointerAndLeaveInUVandXY()
        
        try assembler.sub(.NONE)
        try assembler.sub(.M)
    }
    
    private func sub16() throws {
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.M, .B)
        
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.M, .B)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.B, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.B, .M)
        try assembler.sbc(.NONE)
        try assembler.sbc(.M)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func mul() throws {
        try pop16()
        
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
        
        try pushAToStack()
    }
    
    private func mul16() throws {
        let multiplicandAddress = kScratchLo+0
        let multiplierAddress = kScratchLo+2
        let resultAddress = kScratchLo+4
        
        // Pop the multiplicand and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, multiplicandAddress+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, multiplicandAddress+1)
        try assembler.mov(.M, .B)
        
        // Pop the multiplier and store in scratch memory.
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, multiplierAddress+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, multiplierAddress+1)
        try assembler.mov(.M, .B)
        
        // Initialize the result to zero.
        try assembler.li(.V, resultAddress+0)
        try assembler.li(.M, 0)
        try assembler.li(.V, resultAddress+1)
        try assembler.li(.M, 0)
        
        let loopHead = makeTempLabel()
        let loopTail = makeTempLabel()
        let notDone = makeTempLabel()
        
        try label(token: loopHead)
        
        // If the multiplier is equal to zero then bail because we're done.
        try setAddressToLabel(notDone)
        try assembler.li(.V, multiplierAddress+1)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try assembler.li(.V, multiplierAddress+0)
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
        try label(token: notDone)
        
        // Add the multiplicand to the result.
        try assembler.li(.V, multiplicandAddress+1)
        try assembler.mov(.B, .M)
        try assembler.li(.V, resultAddress+1)
        try assembler.mov(.A, .M)
        try assembler.add(.NONE)
        try assembler.add(.M)
        try assembler.li(.V, multiplicandAddress+0)
        try assembler.mov(.B, .M)
        try assembler.li(.V, resultAddress+0)
        try assembler.mov(.A, .M)
        try assembler.adc(.NONE)
        try assembler.adc(.M)
        
        // Decrement the multiplier.
        try assembler.li(.V, multiplierAddress+1)
        try assembler.mov(.A, .M)
        try assembler.dea(.NONE)
        try assembler.dea(.M)
        try assembler.li(.V, multiplierAddress+0)
        try assembler.mov(.A, .M)
        try assembler.dca(.NONE)
        try assembler.dca(.M)

        // Jump back to the beginning of the loop
        try setAddressToLabel(loopHead)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        try label(token: loopTail)
        
        // Push the result onto the stack.
        // First the low byte
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, resultAddress+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        // Then the high byte
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, resultAddress+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func div() throws {
        try pop16()
        
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
        
        try pushAToStack()
    }
    
    private func div16() throws {
        let addressOfB = kScratchLo+0
        let addressOfA = kScratchLo+2
        let counterAddress = kScratchLo+4

        // Pop the divisor and store in scratch memory.
        // `b' is the Divisor
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop the dividend and store in scratch memory.
        // `a' is the Dividend
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.M, .B)

        // Initialize the counter to zero.
        // `c' is the counter
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, counterAddress+0)
        try assembler.li(.M, 0)
        try assembler.li(.V, counterAddress+1)
        try assembler.li(.M, 0)

        let loopHead = makeTempLabel()
        let loopTail = makeTempLabel()

        // if b == 0 then bail because it's division by zero
        try setAddressToLabel(loopHead)
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try assembler.li(.V, addressOfB+0)
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

        // while a >= b
        try label(token: loopHead)

        // Load the low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)

        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)

        // Load the high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)

        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)

        try setAddressToLabel(loopTail)
        assembler.jnc()
        assembler.nop()
        assembler.nop()

        // a = a - b
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.sbc(.NONE)
        try assembler.sbc(.M)

        // c += 1
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, counterAddress+0)
        try assembler.mov(.X, .M)
        try assembler.li(.V, counterAddress+1)
        try assembler.mov(.Y, .M)
        assembler.inxy()
        try assembler.li(.V, counterAddress+0)
        try assembler.mov(.M, .X)
        try assembler.li(.V, counterAddress+1)
        try assembler.mov(.M, .Y)

        // loop
        try setAddressToLabel(loopHead)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        try label(token: loopTail)

        // Push the result to the stack. First the low byte, then the high byte.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, counterAddress+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, counterAddress+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func mod() throws {
        try pop16()
        
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
        
        try pushAToStack()
    }
    
    private func mod16() throws {
        let addressOfB = kScratchLo+0
        let addressOfA = kScratchLo+2
        let counterAddress = kScratchLo+4

        // Pop the divisor and store in scratch memory.
        // `b' is the Divisor
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.M, .B)

        // Pop the dividend and store in scratch memory.
        // `a' is the Dividend
        try pop16()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.M, .B)

        // Initialize the counter to zero.
        // `c' is the counter
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, counterAddress+0)
        try assembler.li(.M, 0)
        try assembler.li(.V, counterAddress+1)
        try assembler.li(.M, 0)

        let loopHead = makeTempLabel()
        let loopTail = makeTempLabel()

        // if b == 0 then bail because it's division by zero
        try setAddressToLabel(loopHead)
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.A, .M)
        try assembler.li(.B, 0)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.A, .M)
        assembler.cmp()
        assembler.cmp()
        assembler.nop()
        assembler.jne()
        assembler.nop()
        assembler.nop()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.li(.M, 0)
        try assembler.li(.V, addressOfA+1)
        try assembler.li(.M, 0)
        try setAddressToLabel(loopTail)
        assembler.jmp()
        assembler.nop()
        assembler.nop()

        // while a >= b
        try label(token: loopHead)

        // Load the low bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)

        // Compare the low bytes.
        try assembler.sub(.NONE)
        try assembler.sub(.NONE)

        // Load the high bytes of `a' and `b' into the A and B registers.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)

        // Compare the high bytes.
        try assembler.sbc(.NONE)
        try assembler.sbc(.NONE)

        try setAddressToLabel(loopTail)
        assembler.jnc()
        assembler.nop()
        assembler.nop()

        // a = a - b
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfB+1)
        try assembler.mov(.B, .M)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try assembler.sub(.NONE)
        try assembler.sub(.M)
        try assembler.li(.V, addressOfB+0)
        try assembler.mov(.B, .M)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try assembler.sbc(.NONE)
        try assembler.sbc(.M)

        // c += 1
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, counterAddress+0)
        try assembler.mov(.X, .M)
        try assembler.li(.V, counterAddress+1)
        try assembler.mov(.Y, .M)
        assembler.inxy()
        try assembler.li(.V, counterAddress+0)
        try assembler.mov(.M, .X)
        try assembler.li(.V, counterAddress+1)
        try assembler.mov(.M, .Y)

        // loop
        try setAddressToLabel(loopHead)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
        try label(token: loopTail)

        // The result is in `a'. Push it to the stack.
        // First the low byte, then the high byte.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+1)
        try assembler.mov(.A, .M)
        try pushAToStack()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, addressOfA+0)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func load(from address: Int) throws {
        try decrementStackPointer()
        
        // Load the value from RAM to A.
        try assembler.li(.U, (address & 0xff00) >> 8)
        try assembler.li(.V,  address & 0x00ff)
        try assembler.mov(.A, .M)
        
        try loadStackPointerIntoUVandXY()
        
        // Write A (the value we loaded) to the new top of the stack.
        try assembler.mov(.M, .A)
    }
    
    private func load16(from address: Int) throws {
        try assembler.li(.U, ((address+1) & 0xff00) >> 8)
        try assembler.li(.V,  (address+1) & 0x00ff)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try assembler.li(.U, ((address+0) & 0xff00) >> 8)
        try assembler.li(.V,  (address+0) & 0x00ff)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func store(to address: Int) throws {
        try loadStackPointerIntoUVandXY()
        
        // Copy the stop of the stack into A.
        try assembler.mov(.A, .M)
        
        // Now write A into the specified address.
        try assembler.li(.U, (address & 0xff00) >> 8)
        try assembler.li(.V,  address & 0x00ff)
        try assembler.mov(.M, .A)
    }
    
    private func store16(to address: Int) throws {
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        try assembler.li(.U, ((address+0) & 0xff00) >> 8)
        try assembler.li(.V,  (address+0) & 0x00ff)
        try assembler.mov(.M, .A)
        
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        assembler.inuv()
        try assembler.mov(.A, .M)
        try assembler.li(.U, ((address+1) & 0xff00) >> 8)
        try assembler.li(.V,  (address+1) & 0x00ff)
        try assembler.mov(.M, .A)
    }
    
    private func label(token: TokenIdentifier) throws {
        let name = token.lexeme
        guard labelTable[name] == nil else {
            throw CompilerError(line: token.lineNumber,
                                format: "label redefines existing symbol: `%@'",
                                token.lexeme)
        }
        labelTable[name] = assembler.programCounter
    }
    
    private func loadIndirect() throws {
        try pop16()
        try assembler.mov(.U, .A)
        try assembler.mov(.V, .B)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func loadIndirect16() throws {
        try pop16()
        
        // Stash the address in scratch memory.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.M, .B)
        
        // Load the low word and push to the stack.
        try assembler.mov(.U, .A)
        try assembler.mov(.V, .B)
        assembler.inuv()
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        // Retrieve the address from scratch memory.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+2)
        try assembler.mov(.X, .M)
        try assembler.li(.V, kScratchLo+3)
        try assembler.mov(.Y, .M)
        
        // Load the high word and push to the stack.
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        try assembler.mov(.A, .M)
        try pushAToStack()
    }
    
    private func storeIndirect() throws {
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.M, .B)
        
        // Copy the top of the stack into A.
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        
        // Restore the stashed destination address to UV and XY.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.X, .M)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.Y, .M)
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        
        // Store A to the destination address.
        try assembler.mov(.M, .A)
    }
    
    private func storeIndirect16() throws {
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.M, .B)
        
        // Copy the two bytes at the top of the stack into A and B
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        assembler.inuv()
        try assembler.mov(.B, .M)
        
        // Restore the stashed destination address to UV and XY.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.X, .M)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.Y, .M)
        try assembler.mov(.U, .X)
        try assembler.mov(.V, .Y)
        
        // Store A and B to the destination address.
        try assembler.mov(.M, .A)
        assembler.inuv()
        try assembler.mov(.M, .B)
    }
    
    private func jmp(to token: TokenIdentifier) throws {
        try setAddressToLabel(token)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    private func je(to token: TokenIdentifier) throws {
        try pop16()
        
        assembler.cmp()
        assembler.cmp()
        try setAddressToLabel(token)
        assembler.je()
        assembler.nop()
        assembler.nop()
    }
    
    private func jalr(to token: TokenIdentifier) throws {
        try setAddressToLabel(token)
        assembler.jalr()
        assembler.nop()
        assembler.nop()
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
    
    private func enter() throws {
        // push fp in two bytes ; fp <- sp
        
        try assembler.li(.U, kFramePointerLoHi)
        try assembler.li(.V, kFramePointerLoLo)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try assembler.li(.U, kFramePointerHiHi)
        try assembler.li(.V, kFramePointerHiLo)
        try assembler.mov(.A, .M)
        try pushAToStack()
        
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.X, .M)
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.Y, .M)

        try assembler.li(.U, kFramePointerHiHi)
        try assembler.li(.V, kFramePointerHiLo)
        try assembler.mov(.M, .X)
        try assembler.li(.U, kFramePointerLoHi)
        try assembler.li(.V, kFramePointerLoLo)
        try assembler.mov(.M, .Y)
    }
    
    private func leave() throws {
        // sp <- fp ; fp <- pop two bytes from the stack
        
        try assembler.li(.U, kFramePointerHiHi)
        try assembler.li(.V, kFramePointerHiLo)
        try assembler.mov(.X, .M)
        try assembler.li(.U, kFramePointerLoHi)
        try assembler.li(.V, kFramePointerLoLo)
        try assembler.mov(.Y, .M)
        
        try assembler.li(.U, kStackPointerHiHi)
        try assembler.li(.V, kStackPointerHiLo)
        try assembler.mov(.M, .X)
        try assembler.li(.U, kStackPointerLoHi)
        try assembler.li(.V, kStackPointerLoLo)
        try assembler.mov(.M, .Y)
        
        try popInMemoryStackIntoRegisterB()
        try assembler.li(.U, kFramePointerHiHi)
        try assembler.li(.V, kFramePointerHiLo)
        try assembler.mov(.M, .B)
        
        try popInMemoryStackIntoRegisterB()
        try assembler.li(.U, kFramePointerLoHi)
        try assembler.li(.V, kFramePointerLoLo)
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
    
    private func ret() throws {
        try popInMemoryStackIntoRegisterB()
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo)
        try assembler.mov(.M, .B)
        
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.Y, .B)
        
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo)
        try assembler.mov(.X, .M)
        
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    private func peekPeripheral() throws {
        try pop16()
        try assembler.mov(.U, .A)
        try assembler.mov(.V, .B)
        try assembler.mov(.A, .P)
        try pushAToStack()
    }
    
    private func pokePeripheral() throws {
        try popInMemoryStackIntoRegisterB()
        try assembler.mov(.D, .B)
        
        try pop16()
        
        // Stash the destination address in a well-known scratch location.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.M, .A)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.M, .B)
        
        // Copy the top of the stack into A.
        try loadStackPointerIntoUVandXY()
        try assembler.mov(.A, .M)
        
        // Restore the stashed destination address to XY.
        try assembler.li(.U, kScratchHi)
        try assembler.li(.V, kScratchLo+0)
        try assembler.mov(.X, .M)
        try assembler.li(.V, kScratchLo+1)
        try assembler.mov(.Y, .M)
        
        // Store A to the destination address on the peripheral bus.
        try assembler.mov(.P, .A)
    }
}
