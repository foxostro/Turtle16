//
//  SnapToTurtle16Compiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public struct TurtleProgram {
    public let testNames: [String]
    public let symbolsOfTopLevelScope: Env
    public let syntaxTree: AbstractSyntaxTreeNode
    public let tackProgram: TackProgram
    public let assembly: TopLevel
    public let instructions: [UInt16]
}

/// Compile a Snap program to Turtle16 machine code
public struct SnapToTurtle16Compiler {
    public typealias Options = SnapCompilerFrontEnd.Options

    private let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()

    public init() {}

    public func compile(
        program text: String,
        base: Int = 0,
        url: URL? = nil,
        options: Options = Options()
    ) throws -> TurtleProgram {
        let frontEnd = SnapCompilerFrontEnd(
            options: options,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        let tackProgram = try frontEnd.compile(program: text, base: base, url: url)
        let (instructions, assembly) = try tackProgram.machineCode()
        return TurtleProgram(
            testNames: frontEnd.testNames,
            symbolsOfTopLevelScope: frontEnd.symbolsOfTopLevelScope,
            syntaxTree: frontEnd.syntaxTree,
            tackProgram: tackProgram,
            assembly: assembly,
            instructions: instructions
        )
    }

    public func collectTestNames(
        program text: String,
        url: URL? = nil,
        options: Options = Options()
    ) throws -> [String] {
        let frontEnd = SnapCompilerFrontEnd(
            options: options,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        let testNames = try frontEnd.collectTestNames(
            program: text,
            url: url
        )
        return testNames
    }
}

private extension TackProgram {
    func machineCode() throws -> ([UInt16], TopLevel) {
        var assembly: TopLevel!
        let instructions = try assemble()
            .registerAllocation()
            .map {
                assembly = $0
                return $0
            }
            .lowerAssembly()
            .machineCode()
        return (instructions, assembly)
    }

    func assemble() throws -> TopLevel {
        try TackToTurtle16Compiler().visit(TopLevel(children: [ast])) as! TopLevel
    }
}

private extension TopLevel {
    func map(_ block: (TopLevel) -> TopLevel) -> TopLevel {
        block(self)
    }

    func registerAllocation() throws -> TopLevel {
        try RegisterAllocatorDriver().compile(topLevel: self)
    }

    func lowerAssembly() throws -> TopLevel {
        let topLevel0 = try SnapSubcompilerSubroutine().visit(self) as! TopLevel

        // The hardware requires us to place a NOP at the first instruction.
        let topLevel1: TopLevel =
            if topLevel0.children
                .first != InstructionNode(instruction: kNOP) {
                topLevel0.inserting(
                    children: [
                        InstructionNode(instruction: kNOP)
                    ],
                    at: 0
                )
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
