//
//  AssemblerFrontEnd.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerFrontEnd: NSObject {
    let backend: AssemblerBackEnd
    
    public override init() {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        backend = AssemblerBackEnd(codeGenerator: CodeGenerator(microcodeGenerator: microcodeGenerator))
    }
    
    public func compile(_ text: String) throws -> [Instruction] {
        let tokenizer = AssemblerScanner(withString: text)
        try tokenizer.scanTokens()
        let parser = AssemblerParser(backend: backend, tokens: tokenizer.tokens)
        backend.begin()
        try parser.parse()
        try backend.end()
        return backend.instructions
    }
    
    public func resolveSymbol(_ name: String) throws -> Int {
        return try backend.resolveSymbol(name)
    }
}
