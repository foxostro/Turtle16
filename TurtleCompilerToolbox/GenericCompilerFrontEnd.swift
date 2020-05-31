//
//  GenericCompilerFrontEnd.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

open class GenericCompilerFrontEnd: NSObject {
    public let lexerFactory: (String)->Lexer
    public let parserFactory: ([Token])->Parser
    public let codeGeneratorFactory: (AssemblerBackEnd)->CodeGenerator
    
    public var instructions: [Instruction] = []
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public init(lexerFactory: @escaping (String)->Lexer,
                parserFactory: @escaping ([Token])->Parser,
                codeGeneratorFactory: @escaping (AssemblerBackEnd)->CodeGenerator) {
        self.lexerFactory = lexerFactory
        self.parserFactory = parserFactory
        self.codeGeneratorFactory = codeGeneratorFactory
    }
    
    public func compile(_ text: String) {
        return compile(program: text, base: 0x0000)
    }
    
    public func compile(program text: String, base: Int) {
        instructions = []
        errors = []
        
        let lexer = lexerFactory(text)
        lexer.scanTokens()
        if lexer.hasError {
            errors = lexer.errors
            return
        }
        
        let parser = parserFactory(lexer.tokens)
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        let ast = parser.syntaxTree!
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        
        let codeGenerator = codeGeneratorFactory(assembler)
        codeGenerator.compile(ast: ast, base: base)
        if codeGenerator.hasError {
            errors = codeGenerator.errors
            return
        }
        
        instructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: codeGenerator.instructions)
    }
}
