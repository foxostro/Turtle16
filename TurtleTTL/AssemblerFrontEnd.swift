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
        let tokenizer = AssemblerScanner(withString: text)
        try tokenizer.scanTokens()
        
        let parser = AssemblerParser(tokens: tokenizer.tokens)
        let ast = try parser.parse()
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let codeGenerator = CodeGenerator(microcodeGenerator: microcodeGenerator)
        
        let declarationsPass = AssemblerDeclarationPass()
        try declarationsPass.doDeclarations(ast)
        let symbols = declarationsPass.symbols
        
        let codeGenPass = AssemblerCodeGenPass(codeGenerator: codeGenerator, symbols: symbols)
        let instructions = try codeGenPass.compile(ast)
        
        return instructions
    }
}
