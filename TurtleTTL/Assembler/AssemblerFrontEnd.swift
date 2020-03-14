//
//  AssemblerFrontEnd.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerFrontEnd: NSObject {
    public var instructions: [Instruction] = []
    
    public private(set) var errors: [AssemblerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public func compile(_ text: String) {
        return compile(program: text, base: 0x0000)
    }
    
    public func compile(program text: String, base: Int) {
        instructions = []
        errors = []
        
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        if tokenizer.hasError {
            errors = tokenizer.errors
            return
        }
        
        let parser = AssemblerParser(tokens: tokenizer.tokens)
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        let ast = parser.syntaxTree!
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let codeGenerator = CodeGenerator(microcodeGenerator: microcodeGenerator)
        
        let compiler = AssemblerCodeGenPass(codeGenerator: codeGenerator)
        compiler.compile(ast: ast, base: base)
        if compiler.hasError {
            errors = compiler.errors
            return
        }
        
        let formatter = InstructionFormatter(microcodeGenerator: microcodeGenerator)
        
        for instruction in compiler.instructions {
            instructions.append(formatter.makeInstructionWithDisassembly(instruction: instruction))
        }
    }
    
    public func makeOmnibusError(fileName: String?, errors: [AssemblerError]) -> AssemblerError {
        var message = ""
        
        for error in errors {
            if fileName != nil {
                message += fileName! + ":"
            }
            if let lineNumber = error.line {
                message += String(lineNumber) + ": "
            }
            message += String(format: "error: %@\n", error.message)
        }
        
        if errors.count == 1 {
            message += String(format: "1 error generated\n")
        } else {
            message += String(format: "%d errors generated\n", errors.count)
        }
        
        return AssemblerError(message: message)
    }
}
