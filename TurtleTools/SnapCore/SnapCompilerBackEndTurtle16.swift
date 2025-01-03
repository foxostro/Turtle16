//
//  SnapCompilerBackEndTurtle16.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/8/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public class SnapCompilerBackEndTurtle16: NSObject {
    public private(set) var assembly: Result<TopLevel, Error>! = nil
    private let globalEnvironment: GlobalEnvironment
    
    public init(globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
    }
    
    public func compile(tackProgram: TackProgram) -> Result<[UInt16], Error> {
        let result = compileTackToAssembly(tackProgram)
            .flatMap(registerAllocation)
            .flatMap(compileToLowerAssembly)
            .flatMap(compileAssemblyToMachineCode)
        return result
    }
    
    func compileTackToAssembly(_ tackProgram: TackProgram) -> Result<TopLevel, Error> {
        Result {
            try TackToTurtle16Compiler().visit(TopLevel(children: [
                tackProgram.ast
            ])) as! TopLevel
        }
    }
    
    func registerAllocation(_ input: TopLevel) -> Result<TopLevel, Error> {
        Result {
            try RegisterAllocatorDriver().compile(topLevel: input)
        }
    }
    
    func compileToLowerAssembly(_ input: TopLevel) -> Result<TopLevel, Error> {
        self.assembly = Result {
            //try SnapASTTransformerFlattenSeq().compile(
            var topLevel = try SnapSubcompilerSubroutine().visit(input) as! TopLevel
            
            // The hardware requires us to place a NOP at the first instruction.
            if topLevel.children.first != InstructionNode(instruction: kNOP) {
                topLevel = TopLevel(children: [InstructionNode(instruction: kNOP)] + topLevel.children)
            }
            
            return topLevel
        }
        return self.assembly
    }
    
    func compileAssemblyToMachineCode(_ topLevel: TopLevel) -> Result<[UInt16], Error> {
        let compiler = AssemblerCompiler()
        compiler.compile(topLevel)
        if let error = compiler.errors.first {
            return .failure(error)
        }
        return .success(compiler.instructions)
    }
}
