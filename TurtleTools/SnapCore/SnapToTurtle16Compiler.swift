//
//  SnapToTurtle16Compiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Convenience class that puts together a Snap front end and Turtle16 back end.
// This always compiles a Snap program to Turtle16 machine code.
public class SnapToTurtle16Compiler: NSObject {
    public typealias Options = SnapCompilerFrontEnd.Options
    
    public let options: Options
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public private(set) var testNames: [String] = []
    public private(set) var symbolsOfTopLevelScope: SymbolTable? = nil
    public private(set) var syntaxTree: AbstractSyntaxTreeNode! = nil
    public private(set) var tack: Result<TackProgram, Error>! = nil
    public private(set) var assembly: Result<TopLevel, Error>! = nil
    public private(set) var instructions: [UInt16] = []
    public private(set) var errors: [CompilerError] = []
    
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public init(options: Options = Options(),
                memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16()) {
        self.options = options
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(program text: String, base: Int = 0, url: URL? = nil) {
        instructions = []
        errors = []
        
        let frontEnd = SnapCompilerFrontEnd(options: options, memoryLayoutStrategy: memoryLayoutStrategy)
        tack = frontEnd.compile(program: text, base: base, url: url)
        testNames = frontEnd.testNames
        syntaxTree = frontEnd.syntaxTree
        symbolsOfTopLevelScope = frontEnd.symbolsOfTopLevelScope
        
        let backEnd = SnapCompilerBackEndTurtle16()
        let result = tack.flatMap { backEnd.compile(tackProgram: $0) }
        assembly = backEnd.assembly
        
        switch result {
        case .success(let ins):
            instructions = ins
            
        case .failure(let error as CompilerError):
            errors = [error]
            
        case .failure(let error):
            fatalError("unknown error: \(error)")
        }
    }
}
