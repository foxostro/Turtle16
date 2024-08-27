//
//  CompilerPassImport.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/19/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiler pass inserts corresponding modules into the AST for each import statement
public class CompilerPassImport: CompilerPass {
    fileprivate var modulesAlreadySeen = Set<String>()
    fileprivate let moduleSourceCache: [String : String]
    fileprivate let globalEnvironment: GlobalEnvironment
    fileprivate let runtimeSupport: String?
    fileprivate var pendingInsertions: [Module] = []
    
    public init(symbols: SymbolTable? = nil,
                injectModules: [(String, String)] = [],
                globalEnvironment: GlobalEnvironment,
                runtimeSupport: String? = nil) {
        
        var moduleSourceCache: [String : String] = [:]
        for pair in injectModules {
            moduleSourceCache[pair.0] = pair.1
        }
        self.moduleSourceCache = moduleSourceCache
        self.globalEnvironment = globalEnvironment
        self.runtimeSupport = runtimeSupport
        
        super.init(symbols)
    }
    
    public override func run(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.run(node0)
        guard let block = node1 as? Block else {
            return node1
        }
        let node2 = block.inserting(children: pendingInsertions, at: 0)
        return node2
    }
    
    public override func visit(import node0: Import) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(import: node0) as! Import
        let moduleName = node1.moduleName
        if !modulesAlreadySeen.contains(moduleName) {
            let (moduleSource, moduleURL) = try read(
                sourceAnchor: node0.sourceAnchor,
                moduleName: moduleName)
            let module0 = try parse(
                moduleName: moduleName,
                text: moduleSource,
                url: moduleURL)
            let module1 = module0.reconnect(parent: nil)
            let module2 = (runtimeSupport == moduleName)
                ? module1
                : module1.withImplicitImport(moduleName: runtimeSupport)! as! Module
            let module3 = try visit(module: module2) as! Module
            pendingInsertions.append(module3)
            modulesAlreadySeen.insert(moduleName)
        }
        return node0
    }
    
    fileprivate func read(sourceAnchor: SourceAnchor?, moduleName: String) throws -> (String, URL) {
        guard moduleName != "" else {
            throw CompilerError(sourceAnchor: sourceAnchor, message: "no such module `\(moduleName)'")
        }
        
        // Try retrieving the module from the manually injected modules first.
        // If it's here then do not try to read from file.
        if let sourceCode = moduleSourceCache[moduleName] {
            return (sourceCode, URL.init(string: moduleName)!)
        }
        
        // Try retrieving the module from file.
        if let sourceAnchor,
           let url = URL.init(
            string: moduleName.appending(".snap"),
            relativeTo: sourceAnchor.url?.deletingLastPathComponent()),
           FileManager.default.fileExists(atPath: url.path) {
            
            do {
                let text = try String(contentsOf: url, encoding: String.Encoding.utf8)
                return (text, url)
            } catch {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "failed to read module `\(moduleName)' from file `\(url)'")
            }
        }
        else if let url = Bundle(for: type(of: self)).url(forResource: moduleName, withExtension: "snap") { // Try retrieving the module from bundle resources.
            do {
                let text = try String(contentsOf: url)
                return (text, url)
            } catch {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "failed to read module `\(moduleName)' from file `\(url)'")
            }
        }
        
        throw CompilerError(sourceAnchor: sourceAnchor, message: "no such module `\(moduleName)'")
    }
}

public func parse(moduleName: String, text: String, url: URL) throws -> Module {
    let topLevel = try parse(text: text, url: url)
    let module = Module(
        sourceAnchor: topLevel.sourceAnchor,
        name: moduleName,
        block: Block(
            sourceAnchor: topLevel.sourceAnchor,
            symbols: SymbolTable(),
            children: topLevel.children))
    return module
}

public func parse(text: String, url: URL) throws -> TopLevel {
    let filename = url.lastPathComponent
    
    // Lexer pass
    let lexer = SnapLexer(text, url)
    lexer.scanTokens()
    if lexer.hasError {
        throw CompilerError.makeOmnibusError(fileName: filename, errors: lexer.errors)
    }
    
    // Compile to a parser syntax tree
    let parser = SnapParser(tokens: lexer.tokens)
    parser.parse()
    if parser.hasError {
        throw CompilerError.makeOmnibusError(fileName: filename, errors: parser.errors)
    }
    
    // TODO: Perhaps SnapParser should always produce an AST with Module at the top-level instead of TopLevel
    let topLevel = parser.syntaxTree!
    return topLevel
}

extension AbstractSyntaxTreeNode {
    // Insert module nodes into the AST for any modules that are imported
    // injectModules -- A list of module name and module source code which overrides modules found on the file system.
    public func importPass(
        injectModules: [(String, String)],
        runtimeSupport: String? = nil,
        globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        
        let result = try CompilerPassImport(
            injectModules: injectModules,
            globalEnvironment: globalEnvironment,
            runtimeSupport: runtimeSupport).run(self)
        return result
    }
}
