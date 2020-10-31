//
//  PopCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

public class PopCompiler: NSObject {
    public let assembler: AssemblerBackEnd
    var patcherActions: [Patcher.Action] = []
    public var labelTable: [String:Int] = [:]
    public private(set) var instructions: [Instruction] = []
    public var programDebugInfo: SnapDebugInfo? = nil
    public var currentSourceAnchor: SourceAnchor? = nil
    
    public convenience override init() {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        self.init(assembler: AssemblerBackEnd(microcodeGenerator: microcodeGenerator))
    }
    
    public required init(assembler: AssemblerBackEnd) {
        self.assembler = assembler
    }
    
    public func compile(pop: [PopInstruction], base: Int = 0x0000) throws {
        patcherActions = []
        assembler.begin()
        try compileProgramBody(pop)
        assembler.end()
        try patch(base)
        programDebugInfo?.generateMappingToProgramCounter(base: base)
        formatInstructions()
    }
    
    fileprivate func compileProgramBody(_ pop: [PopInstruction]) throws {
        for i in 0..<pop.count {
            let currentPopInstruction = pop[i]
            currentSourceAnchor = programDebugInfo?.lookupSourceAnchor(popInstructionIndex: i)
            let currentCrackleInstruction = programDebugInfo?.lookupCrackleInstruction(popInstructionIndex: i)
            let currentSymbols = programDebugInfo?.lookupSymbols(popInstructionIndex: i)
            let assemblyInstructionsBegin = assembler.instructions.count
            try compileSinglePopInstruction(currentPopInstruction)
            let assemblyInstructionsEnd = assembler.instructions.count
            if assemblyInstructionsBegin < assemblyInstructionsEnd {
                for i in assemblyInstructionsBegin..<assemblyInstructionsEnd {
                    programDebugInfo?.bind(assemblyInstructionIndex: i, crackleInstruction: currentCrackleInstruction)
                    programDebugInfo?.bind(assemblyInstructionIndex: i, sourceAnchor: currentSourceAnchor)
                    programDebugInfo?.bind(assemblyInstructionIndex: i, symbols: currentSymbols)
                }
            }
        }
    }
    
    private func compileSinglePopInstruction(_ instruction: PopInstruction) throws {
        switch instruction {
        case .fake:
            fake()
            
        case .nop:
            nop()
            
        case .hlt:
            hlt()
            
        case .inuv:
            inuv()
            
        case .inxy:
            inxy()
            
        case .mov(let dst, let src):
            try mov(dst, src)
            
        case .li(let dst, let immediate):
            try li(dst, immediate)
            
        case .add(let dst):
            try add(dst)
                 
        case .sub(let dst):
            try sub(dst)
            
        case .adc(let dst):
            try adc(dst)
            
        case .sbc(let dst):
            try sbc(dst)
            
        case .dea(let dst):
            try dea(dst)
            
        case .dca(let dst):
            try dca(dst)
            
        case .and(let dst):
            try and(dst)
            
        case .or(let dst):
            try or(dst)
            
        case .xor(let dst):
            try xor(dst)
            
        case .lsl(let dst):
            try lsl(dst)
            
        case .neg(let dst):
            try neg(dst)
            
        case .cmp:
            cmp()
            
        case .label(let name):
            try label(name)
            
        case .lixy(let name):
            try lixy(name)
            
        case .jalr(let name):
            try jalr(name)
            
        case .explicitJalr:
            explicitJalr()
            
        case .jmp(let name):
            try jmp(name)
            
        case .explicitJmp:
            explicitJmp()
            
        case .jc(let name):
            try jc(name)
            
        case .jnc(let name):
            try jnc(name)
            
        case .je(let name):
            try je(name)
            
        case .jne(let name):
            try jne(name)
            
        case .jg(let name):
            try jg(name)
            
        case .jle(let name):
            try jle(name)
            
        case .jl(let name):
            try jl(name)
            
        case .jge(let name):
            try jge(name)
            
        case .blt(let dst, let src):
            try blt(dst, src)
            
        case .blti(let dst, let immediate):
            try blti(dst, immediate)
            
        case .copyLabel(let dst, let name):
            try copyLabel(dst, name)
        }
    }
    
    fileprivate func patch(_ base: Int) throws {
        let resolver: (SourceAnchor?, String) throws -> Int = {[weak self] (sourceAnchor: SourceAnchor?, identifier: String) in
            if let address = self!.labelTable[identifier] {
                return address
            }
            throw CompilerError(sourceAnchor: sourceAnchor, message: "cannot resolve label `\(identifier)'")
        }
        let patcher = Patcher(inputInstructions: assembler.instructions,
                              resolver: resolver,
                              actions: patcherActions,
                              base: base)
        instructions = try patcher.patch()
    }
    
    private func formatInstructions() {
        instructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: instructions)
    }
    
    public func fake() {}
    
    public func nop() {
        assembler.nop()
    }
    
    public func hlt() {
        assembler.hlt()
    }
    
    public func inuv() {
        assembler.inuv()
    }
    
    public func inxy() {
        assembler.inxy()
    }
    
    public func mov(_ dst: RegisterName, _ src: RegisterName) throws {
        try assembler.mov(dst, src)
    }
    
    public func li(_ dst: RegisterName, _ immediate: Int) throws {
        try assembler.li(dst, immediate)
    }
    
    public func add(_ dst: RegisterName) throws {
        try assembler.add(.NONE)
        try assembler.add(dst)
    }
    
    public func sub(_ dst: RegisterName) throws {
        try assembler.sub(.NONE)
        try assembler.sub(dst)
    }
    
    public func adc(_ dst: RegisterName) throws {
        try assembler.adc(.NONE)
        try assembler.adc(dst)
    }
    
    public func sbc(_ dst: RegisterName) throws {
        try assembler.sbc(.NONE)
        try assembler.sbc(dst)
    }
    
    public func dea(_ dst: RegisterName) throws {
        try assembler.dea(.NONE)
        try assembler.dea(dst)
    }
    
    public func dca(_ dst: RegisterName) throws {
        try assembler.dca(.NONE)
        try assembler.dca(dst)
    }
    
    public func and(_ dst: RegisterName) throws {
        try assembler.and(.NONE)
        try assembler.and(dst)
    }
    
    public func or(_ dst: RegisterName) throws {
        try assembler.or(.NONE)
        try assembler.or(dst)
    }
    
    public func xor(_ dst: RegisterName) throws {
        try assembler.xor(.NONE)
        try assembler.xor(dst)
    }
    
    public func lsl(_ dst: RegisterName) throws {
        try assembler.lsl(.NONE)
        try assembler.lsl(dst)
    }
    
    public func neg(_ dst: RegisterName) throws {
        try assembler.neg(.NONE)
        try assembler.neg(dst)
    }
    
    public func cmp() {
        assembler.cmp()
        assembler.cmp()
    }
    
    public func label(_ name: String) throws {
        guard labelTable[name] == nil else {
            throw CompilerError(sourceAnchor: currentSourceAnchor, message: "label redefines existing symbol: `\(name)'")
        }
        labelTable[name] = assembler.programCounter
    }
    
    public func lixy(_ name: String) throws {
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
    
    public func jalr(_ name: String) throws {
        try lixy(name)
        explicitJalr()
    }
    
    public func explicitJalr() {
        assembler.jalr()
        assembler.nop()
        assembler.nop()
    }
    
    public func jmp(_ name: String) throws {
        try lixy(name)
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    public func explicitJmp() {
        assembler.jmp()
        assembler.nop()
        assembler.nop()
    }
    
    public func jc(_ name: String) throws {
        try lixy(name)
        assembler.jc()
        assembler.nop()
        assembler.nop()
    }
    
    public func jnc(_ name: String) throws {
        try lixy(name)
        assembler.jnc()
        assembler.nop()
        assembler.nop()
    }
    
    public func je(_ name: String) throws {
        try lixy(name)
        assembler.je()
        assembler.nop()
        assembler.nop()
    }
    
    public func jne(_ name: String) throws {
        try lixy(name)
        assembler.jne()
        assembler.nop()
        assembler.nop()
    }
    
    public func jg(_ name: String) throws {
        try lixy(name)
        assembler.jg()
        assembler.nop()
        assembler.nop()
    }
    
    public func jle(_ name: String) throws {
        try lixy(name)
        assembler.jle()
        assembler.nop()
        assembler.nop()
    }
    
    public func jl(_ name: String) throws {
        try lixy(name)
        assembler.jl()
        assembler.nop()
        assembler.nop()
    }
    
    public func jge(_ name: String) throws {
        try lixy(name)
        assembler.jge()
        assembler.nop()
        assembler.nop()
    }
    
    public func blt(_ dst: RegisterName, _ src: RegisterName) throws {
        try assembler.blt(dst, src)
    }
    
    public func blti(_ dst: RegisterName, _ value: Int) throws {
        try assembler.blti(dst, value)
    }
    
    public func copyLabel(_ dst: Int, _ name: String) throws {
        try li(.U, (dst>>8) & 0xff)
        try li(.V, dst & 0xff)
        patcherActions.append((index: assembler.programCounter,
                               sourceAnchor: currentSourceAnchor,
                               symbol: name,
                               shift: 8))
        try li(.M, 0xff)
        inuv()
        patcherActions.append((index: assembler.programCounter,
                               sourceAnchor: currentSourceAnchor,
                               symbol: name,
                               shift: 0))
        try li(.M, 0xff)
    }
}
