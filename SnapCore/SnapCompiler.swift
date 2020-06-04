//
//  SnapCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class SnapCompiler: NSObject {
    public var symbols: SymbolTable = SymbolTable()
    public var ast: AbstractSyntaxTreeNode! = nil
    public var ir: [YertleInstruction] = []
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
        
        // Lexer pass
        let lexer = SnapLexer(withString: text)
        lexer.scanTokens()
        if lexer.hasError {
            errors = lexer.errors
            return
        }
        
        // Compile to an abstract syntac tree
        let parser = SnapParser(tokens: lexer.tokens)
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        ast = parser.syntaxTree
        
        // Compile the AST to IR code
        let snapToYertle = SnapToYertleCompiler()
        snapToYertle.compile(ast: ast)
        if snapToYertle.hasError {
            errors = snapToYertle.errors
            return
        }
        symbols = snapToYertle.symbols
        ir = snapToYertle.instructions
        
        // Compile the IR code to Turtle machine code
        let assembler = makeAssembler()
        let yertleToMachineCode = YertleToTurtleMachineCodeCompiler(assembler: assembler, symbols: symbols)
        do {
            try yertleToMachineCode.compile(ir: ir, base: base)
        } catch let error as CompilerError {
            errors = [error]
            return
        } catch {
            abort()
        }
        instructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: yertleToMachineCode.instructions)
    }
    
    private func makeAssembler() -> AssemblerBackEnd {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        return assembler
    }
}
