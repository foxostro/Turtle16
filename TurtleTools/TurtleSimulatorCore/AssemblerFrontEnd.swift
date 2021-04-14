//
//  AssemblerFrontEnd.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

public class AssemblerFrontEnd: NSObject {
    public var instructions: [Instruction] = []
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public func compile(_ text: String) {
        return compile(program: text, base: 0x0000)
    }
    
    public func compile(program text: String, base: Int) {
        instructions = []
        errors = []
        
        let lexer = AssemblerLexer(text)
        lexer.scanTokens()
        if lexer.hasError {
            errors = lexer.errors
            return
        }
        
        let parser = AssemblerParser(tokens: lexer.tokens)
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        let ast = parser.syntaxTree!
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        
        let codeGenerator = AssemblerCodeGenerator(assemblerBackEnd: assembler)
        codeGenerator.compile(ast: ast, base: base)
        if codeGenerator.hasError {
            errors = codeGenerator.errors
            return
        }
        
        instructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: codeGenerator.instructions)
    }
}
