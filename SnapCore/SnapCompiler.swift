//
//  SnapCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public protocol SandboxAccessManager {
    func requestAccess(url: URL?)
}

public class SnapCompiler: NSObject {
    public var isUsingStandardLibrary = false
    public var shouldRunSpecificTest: String? = nil
    public private(set) var testNames: [String] = []
    public var ast: TopLevel! = nil
    public var ir: [CrackleInstruction] = []
    public var instructions: [Instruction] = []
    public let programDebugInfo = SnapDebugInfo()
    public var sandboxAccessManager: SandboxAccessManager? = nil
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    private var injectedModules: [String : String] = [:]
    
    public func injectModule(name: String, sourceCode: String) {
        injectedModules[name] = sourceCode
    }
    
    public func compile(_ text: String, _ url: URL? = nil) {
        return compile(program: text, base: 0x0000, url: url)
    }
    
    public func compile(program text: String, base: Int, url: URL? = nil) {
        instructions = []
        errors = []
        
        // Lexer pass
        let lexer = SnapLexer(text, url)
        lexer.scanTokens()
        programDebugInfo.lineMapper = lexer.lineMapper
        if lexer.hasError {
            errors = lexer.errors
            return
        }
        
        // Compile to an abstract syntax tree
        let parser = SnapParser(tokens: lexer.tokens)
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        ast = parser.syntaxTree
        
        // Compile the AST to IR code
        let snapToCrackleCompiler = SnapToCrackleCompiler()
        for (name, sourceCode) in injectedModules {
            snapToCrackleCompiler.injectModule(name: name, sourceCode: sourceCode)
        }
        snapToCrackleCompiler.programDebugInfo = programDebugInfo
        snapToCrackleCompiler.isUsingStandardLibrary = isUsingStandardLibrary
        snapToCrackleCompiler.shouldRunSpecificTest = shouldRunSpecificTest
        snapToCrackleCompiler.sandboxAccessManager = sandboxAccessManager
        snapToCrackleCompiler.compile(ast: ast)
        if snapToCrackleCompiler.hasError {
            errors = snapToCrackleCompiler.errors
            return
        }
        ir = snapToCrackleCompiler.instructions
        testNames = snapToCrackleCompiler.testNames
        
        // Compile the IR code to Turtle machine code
        let assembler = makeAssembler()
        let irToMachineCode = CrackleToTurtleMachineCodeCompiler(assembler: assembler)
        irToMachineCode.programDebugInfo = programDebugInfo
        do {
            try irToMachineCode.compile(ir: ir, base: base)
        } catch let error as CompilerError {
            errors = [error]
            return
        } catch {
            abort()
        }
        instructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: irToMachineCode.instructions)
    }
    
    private func makeAssembler() -> AssemblerBackEnd {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        return assembler
    }
}
