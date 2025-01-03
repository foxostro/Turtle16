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
    
    let options: Options
    let globalEnvironment: GlobalEnvironment
    
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
            .flatMap(desugar)
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
    
    func desugar(_ syntaxTree: AbstractSyntaxTreeNode?) -> Result<AbstractSyntaxTreeNode?, Error> {
        let compiler = SnapToCoreCompiler(
            shouldRunSpecificTest: options.shouldRunSpecificTest,
            injectModules: Array(options.injectedModules),
            isUsingStandardLibrary: options.isUsingStandardLibrary,
            runtimeSupport: options.runtimeSupport,
            sandboxAccessManager: sandboxAccessManager,
            globalEnvironment: globalEnvironment)
        
        return compiler
            .compile(syntaxTree)
            .map { block in
                symbolsOfTopLevelScope = block?.symbols
                testNames = compiler.testNames
                return block
            }
    }
    
    func compileSnapToTack(_ ast: AbstractSyntaxTreeNode?) -> Result<TackProgram, Error> {
        Result {
            let tackAst = try CoreToTackCompiler(
                globalEnvironment: globalEnvironment,
                options: options)
            .run(ast)
            let tackProgram = try TackFlattener().compile(tackAst ?? Seq())
            return tackProgram
        }
    }
}
