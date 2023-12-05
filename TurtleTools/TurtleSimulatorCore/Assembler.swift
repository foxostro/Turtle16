//
//  Assembler.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 6/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class Assembler: NSObject {
    public var instructions: [UInt16] = []
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    public func compile(_ text: String) {
        instructions = []
        errors = []
        
        // Lexer pass
        let lexer = AssemblerLexer(text)
        lexer.scanTokens()
        if lexer.hasError {
            errors = lexer.errors
            return
        }
        
        // Compile to an abstract syntax tree
        let parser = AssemblerParser(tokens: lexer.tokens, lineMapper: lexer.lineMapper)
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        let syntaxTree = parser.syntaxTree!
        
        // Compile the AST to machine code
        let compiler = AssemblerCompiler()
        compiler.compile(syntaxTree)
        if compiler.hasError {
            errors = compiler.errors
            return
        }
        instructions = compiler.instructions
    }
}
