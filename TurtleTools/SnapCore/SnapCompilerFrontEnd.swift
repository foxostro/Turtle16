//
//  SnapCompilerFrontEnd.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/7/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public final class SnapCompilerFrontEnd {
    public struct Options {
        public let isBoundsCheckEnabled: Bool
        public let isUsingStandardLibrary: Bool
        public let runtimeSupport: String?
        public let shouldRunSpecificTest: String?
        public let injectedModules: [String: String]

        public init(
            isBoundsCheckEnabled: Bool = false,
            isUsingStandardLibrary: Bool = false,
            runtimeSupport: String? = nil,
            shouldRunSpecificTest: String? = nil,
            injectedModules: [String: String] = [:]
        ) {
            self.isBoundsCheckEnabled = isBoundsCheckEnabled
            self.isUsingStandardLibrary = isUsingStandardLibrary
            self.runtimeSupport = runtimeSupport
            self.shouldRunSpecificTest = shouldRunSpecificTest
            self.injectedModules = injectedModules
        }
    }

    let options: Options
    let memoryLayoutStrategy: MemoryLayoutStrategy

    public private(set) var testNames: [String] = []
    public private(set) var syntaxTree: AbstractSyntaxTreeNode!
    public private(set) var symbolsOfTopLevelScope: Env!

    public var sandboxAccessManager: SandboxAccessManager?

    public init(
        options: Options = Options(),
        memoryLayoutStrategy: MemoryLayoutStrategy
    ) {
        self.options = options
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }

    public func collectTestNames(
        program text: String,
        url: URL? = nil
    ) throws -> [String] {
        let tokens = try lex(text, url)
        let syntaxTree = try parse(tokens)
        let (_, testNames) = try syntaxTree.snapToCore(
            shouldRunSpecificTest: options.shouldRunSpecificTest,
            injectModules: Array(options.injectedModules),
            isUsingStandardLibrary: options.isUsingStandardLibrary,
            runtimeSupport: options.runtimeSupport,
            sandboxAccessManager: sandboxAccessManager
        )
        return testNames
    }

    public func compile(
        program text: String,
        base _: Int = 0,
        url: URL? = nil
    ) throws -> TackProgram {
        let tokens = try lex(text, url)
        let ast0 = try parse(tokens)
        let (ast1, testNames) = try ast0.snapToCore(
            shouldRunSpecificTest: options.shouldRunSpecificTest,
            injectModules: Array(options.injectedModules),
            isUsingStandardLibrary: options.isUsingStandardLibrary,
            runtimeSupport: options.runtimeSupport,
            sandboxAccessManager: sandboxAccessManager,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        let tackProgram = try ast1.coreToTack(
            memoryLayoutStrategy: memoryLayoutStrategy,
            options: options
        )

        syntaxTree = ast0
        symbolsOfTopLevelScope = ast1.symbols
        self.testNames = testNames

        return tackProgram
    }

    private func lex(_ text: String, _ url: URL?) throws -> [Token] {
        let lexer = SnapLexer(text, url)
        lexer.scanTokens()
        if let error = lexer.errors.first {
            throw error
        }
        return lexer.tokens
    }

    private func parse(_ tokens: [Token]) throws -> TopLevel {
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        if let error = parser.errors.first {
            throw error
        }
        syntaxTree = parser.syntaxTree
        return parser.syntaxTree!
    }
}
