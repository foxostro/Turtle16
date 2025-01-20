//
//  SnapCompilerBackEndTurtle16.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/8/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

extension TackProgram {
    func machineCode() throws -> ([UInt16], TopLevel) {
        var assembly: TopLevel!
        let instructions = try self
            .assemble()
            .registerAllocation()
            .map { assembly = $0; return $0 }
            .lowerAssembly()
            .machineCode()
        return (instructions, assembly)
    }
    
    fileprivate func assemble() throws -> TopLevel {
        try TackToTurtle16Compiler().visit(TopLevel(children: [ ast ])) as! TopLevel
    }
}

fileprivate extension TopLevel {
    func map(_ block: (TopLevel) -> TopLevel) -> TopLevel {
        block(self)
    }
    
    func registerAllocation() throws -> TopLevel {
        try RegisterAllocatorDriver().compile(topLevel: self)
    }
    
    func lowerAssembly() throws -> TopLevel {
        let topLevel0 = try SnapSubcompilerSubroutine().visit(self) as! TopLevel
        
        // The hardware requires us to place a NOP at the first instruction.
        let topLevel1: TopLevel = if topLevel0.children.first != InstructionNode(instruction: kNOP) {
            topLevel0.inserting(
                children: [
                    InstructionNode(instruction: kNOP)
                ],
                at: 0)
        }
        else {
            topLevel0
        }
        
        return topLevel1
    }
    
    func machineCode() throws -> [UInt16] {
        let compiler = AssemblerCompiler()
        compiler.compile(self)
        if let error = compiler.errors.first {
            throw error
        }
        return compiler.instructions
    }
}
