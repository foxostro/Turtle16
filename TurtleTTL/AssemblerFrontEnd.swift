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
        try tokenizer.scanTokens()
        
        let parser = AssemblerParser(tokens: tokenizer.tokens)
        let ast = try parser.parse()
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let codeGenerator = CodeGenerator(microcodeGenerator: microcodeGenerator)
        
        let compiler = AssemblerCodeGenPass(codeGenerator: codeGenerator)
        let instructions = try compiler.compile(ast)
        
        return instructions
    }
}
