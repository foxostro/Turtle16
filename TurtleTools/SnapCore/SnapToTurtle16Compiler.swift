//
//  SnapToTurtle16Compiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compile a Snap program to Turtle16 machine code
public class SnapToTurtle16Compiler: NSObject {
    public typealias Options = SnapCompilerFrontEnd.Options
    
    private let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()
    
    public func compile(
        program text: String,
        base: Int = 0,
        url: URL? = nil,
        options: Options = Options()
    ) throws -> TurtleProgram {
        let frontEnd = SnapCompilerFrontEnd(
            options: options,
            memoryLayoutStrategy: memoryLayoutStrategy)
        let tackProgram = try frontEnd.compile(program: text, base: base, url: url)
        let (instructions, assembly) = try tackProgram.machineCode()
        return TurtleProgram(
            testNames: frontEnd.testNames,
            symbolsOfTopLevelScope: frontEnd.symbolsOfTopLevelScope,
            syntaxTree: frontEnd.syntaxTree,
            tackProgram: tackProgram,
            assembly: assembly,
            instructions: instructions)
    }
    
    public func collectTestNames(
        program text: String,
        url: URL? = nil,
        options: Options = Options()
    ) throws -> [String] {
        let frontEnd = SnapCompilerFrontEnd(
            options: options,
            memoryLayoutStrategy: memoryLayoutStrategy)
        let testNames = try frontEnd.collectTestNames(
            program: text,
            url: url)
        return testNames
    }
}

public struct TurtleProgram {
    public let testNames: [String]
    public let symbolsOfTopLevelScope: SymbolTable
    public let syntaxTree: AbstractSyntaxTreeNode
    public let tackProgram: TackProgram
    public let assembly: TopLevel
    public let instructions: [UInt16]
}
