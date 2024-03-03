//
//  SnapCompilerFrontEnd.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/7/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class SnapCompilerFrontEnd: NSObject {
    public struct Options {
        public let isBoundsCheckEnabled: Bool
        public let isUsingStandardLibrary: Bool
        public let runtimeSupport: String?
        public let shouldRunSpecificTest: String?
        public let injectedModules: [String : String]
        
        public init(isBoundsCheckEnabled: Bool = false,
                    isUsingStandardLibrary: Bool = false,
                    runtimeSupport: String? = nil,
                    shouldRunSpecificTest: String? = nil,
                    injectedModules: [String : String] = [:]) {
            self.isBoundsCheckEnabled = isBoundsCheckEnabled
            self.isUsingStandardLibrary = isUsingStandardLibrary
            self.runtimeSupport = runtimeSupport
            self.shouldRunSpecificTest = shouldRunSpecificTest
            self.injectedModules = injectedModules
        }
    }
    
    public let options: Options
    public let globalEnvironment: GlobalEnvironment
    
    public private(set) var testNames: [String] = []
    public private(set) var syntaxTree: AbstractSyntaxTreeNode! = nil
    public private(set) var symbolsOfTopLevelScope: SymbolTable? = nil
    
    public var sandboxAccessManager: SandboxAccessManager? = nil
    
    public init(options: Options = Options(),
                globalEnvironment: GlobalEnvironment) {
        self.options = options
        self.globalEnvironment = globalEnvironment
    }
    
    public func compile(program text: String,
                        base: Int = 0,
                        url: URL? = nil) -> Result<TackProgram, Error> {
        
        let result = lex(text, url)
            .flatMap(parse)
            .flatMap(contract)
            .flatMap(compileSnapToTack)
        
        return result
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
        self.syntaxTree = parser.syntaxTree
        return .success(parser.syntaxTree)
    }
    
    func contract(_ syntaxTree: AbstractSyntaxTreeNode?) -> Result<AbstractSyntaxTreeNode?, Error> {
        let contractionStep = SnapAbstractSyntaxTreeCompiler(
            shouldRunSpecificTest: options.shouldRunSpecificTest,
            injectModules: Array(options.injectedModules),
            isUsingStandardLibrary: options.isUsingStandardLibrary,
            runtimeSupport: options.runtimeSupport,
            sandboxAccessManager: sandboxAccessManager,
            globalEnvironment: globalEnvironment)
        contractionStep.compile(syntaxTree)
        let ast = contractionStep.ast
        let testNames = contractionStep.testNames
        if let error = contractionStep.errors.first {
            return .failure(error)
        }
        self.symbolsOfTopLevelScope = ast.symbols
        self.testNames = testNames
        return .success(ast)
    }
    
    func compileSnapToTack(_ ast: AbstractSyntaxTreeNode?) -> Result<TackProgram, Error> {
        let compiler = SnapASTToTackASTCompiler(symbols: globalEnvironment.globalSymbols,
                                          globalEnvironment: globalEnvironment,
                                          options: options)
        let tack = Result(catching: {
            let tackAst = try compiler.compileWithEpilog(ast) ?? Seq()
            let tackProgram = try TackFlattener().compile(tackAst)
            return tackProgram
        })
        
        return tack
    }
}
