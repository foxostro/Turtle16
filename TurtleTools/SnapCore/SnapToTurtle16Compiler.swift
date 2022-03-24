//
//  SnapToTurtle16Compiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore
import Turtle16SimulatorCore

public class SnapToTurtle16Compiler: NSObject {
    public var isUsingStandardLibrary = false
    public let options: SnapCompilerOptions
    public var shouldRunSpecificTest: String? = nil
    public var shouldEnableOptimizations = true
    public private(set) var testNames: [String] = []
    public private(set) var tack: Result<AbstractSyntaxTreeNode?, Error>! = nil
    public private(set) var assembly: Result<TopLevel, Error>! = nil
    public private(set) var instructions: [UInt16] = []
    public var sandboxAccessManager: SandboxAccessManager? = nil
    public let globalSymbols = SymbolTable()
    public private(set) var symbolTableRoot: SymbolTable? = nil
    public let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    
    private var injectedModules: [String : String] = [:]
    
    public func injectModule(name: String, sourceCode: String) {
        injectedModules[name] = sourceCode
    }
    
    public init(options: SnapCompilerOptions = SnapCompilerOptions()) {
        self.options = options
    }
    
    public func compile(program text: String, base: Int = 0, url: URL? = nil) {
        instructions = []
        errors = []
        
        let result = lex(text, url)
            .flatMap(parse)
            .flatMap(contract)
            .flatMap(compileSnapToTack)
            .flatMap(compileTackToAssembly)
            .flatMap(registerAllocation)
            .flatMap(compileToLowerAssembly)
            .flatMap(compileAssemblyToMachineCode)
        
        switch result {
        case .success(let instructions):
            self.instructions = instructions
            
        case .failure(let error as CompilerError):
            self.errors = [error]
            
        case .failure(let error):
            fatalError("unknown error: \(error)")
        }
    }
    
    func lex(_ text: String, _ url: URL?) -> Result<[Token], Error> {
        let lexer = SnapLexer(text, url)
        lexer.scanTokens()
        if let error = lexer.errors.first {
            return .failure(error)
        }
        return .success(lexer.tokens)
    }
    
    func parse(_ tokens: [Token]) -> Result<AbstractSyntaxTreeNode?, Error> {
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        if let error = parser.errors.first {
            return .failure(error)
        }
        return .success(parser.syntaxTree)
    }
    
    func contract(_ syntaxTree: AbstractSyntaxTreeNode?) -> Result<AbstractSyntaxTreeNode?, Error> {
        let contractionStep = SnapAbstractSyntaxTreeCompiler(shouldRunSpecificTest: shouldRunSpecificTest,
                                                             injectModules: Array(injectedModules),
                                                             isUsingStandardLibrary: isUsingStandardLibrary,
                                                             sandboxAccessManager: sandboxAccessManager,
                                                             globalEnvironment: globalEnvironment)
        contractionStep.compile(syntaxTree)
        let ast = contractionStep.ast
        let testNames = contractionStep.testNames
        if let error = contractionStep.errors.first {
            return .failure(error)
        }
        self.symbolTableRoot = ast.symbols
        self.testNames = testNames
        return .success(ast)
    }
    
    func compileSnapToTack(_ ast: AbstractSyntaxTreeNode?) -> Result<AbstractSyntaxTreeNode?, Error> {
        let compiler = SnapToTackCompiler(symbols: globalSymbols, globalEnvironment: globalEnvironment, options: options)
        self.tack = Result(catching: {
            try compiler.compile(ast)
        })
        return self.tack
    }
    
    func compileTackToAssembly(_ input: AbstractSyntaxTreeNode?) -> Result<TopLevel, Error> {
        let compiler = TackToTurtle16Compiler(globalSymbols)
        return Result(catching: {
            try compiler.compile(TopLevel(children: [
                input ?? Seq()
            ])) as! TopLevel
        })
    }
    
    func registerAllocation(_ input: TopLevel) -> Result<TopLevel, Error> {
        return Result(catching: {
            try RegisterAllocatorDriver().compile(topLevel: input)
        })
    }
    
    func compileToLowerAssembly(_ input: TopLevel) -> Result<TopLevel, Error> {
        self.assembly = Result(catching: {
            //try SnapASTTransformerFlattenSeq().compile(
            var topLevel = try SnapSubcompilerSubroutine().compile(input) as! TopLevel
            
            // The hardware requires us to place a NOP at the first instruction.
            if topLevel.children.first != InstructionNode(instruction: kNOP) {
                topLevel = TopLevel(children: [InstructionNode(instruction: kNOP)] + topLevel.children) 
            }
            
            return topLevel
        })
        return self.assembly
    }
    
    func compileAssemblyToMachineCode(_ topLevel: TopLevel) -> Result<[UInt16], Error> {
        let compiler = AssemblerCompiler()
        compiler.compile(topLevel)
        if let error = compiler.errors.first {
            return .failure(error)
        }
        return .success(compiler.instructions)
    }
}
