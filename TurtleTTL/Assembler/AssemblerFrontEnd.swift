//
//  AssemblerFrontEnd.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerFrontEnd: NSObject {
    public func compile(_ text: String) throws -> [Instruction] {
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        if tokenizer.hasError {
            throw tokenizer.errors.first!
        }
        
        let parser = AssemblerParser(tokens: tokenizer.tokens)
        parser.parse()
        if parser.hasError {
            throw parser.errors.first!
        }
        let ast = parser.syntaxTree!
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let codeGenerator = CodeGenerator(microcodeGenerator: microcodeGenerator)
        
        let compiler = AssemblerCodeGenPass(codeGenerator: codeGenerator)
        compiler.compile(ast)
        if compiler.hasError {
            throw compiler.errors.first!
        }
        return compiler.instructions
    }
}
