//
//  SnapSubcompilerImport.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//
import TurtleCore

public class SnapSubcompilerImport: NSObject {
    public let symbols: SymbolTable
    public let globalEnvironment: GlobalEnvironment
    public let sandboxAccessManager: SandboxAccessManager?
    public let runtimeSupport: String?
    var injectedModules: [String : String] = [:]
    
    public init(symbols: SymbolTable,
                globalEnvironment: GlobalEnvironment,
                sandboxAccessManager: SandboxAccessManager? = nil,
                runtimeSupport: String? = nil) {
        self.symbols = symbols
        self.globalEnvironment = globalEnvironment
        self.sandboxAccessManager = sandboxAccessManager
        self.runtimeSupport = runtimeSupport
    }
    
    public func injectModule(name: String, sourceCode: String) {
        injectedModules[name] = sourceCode
    }
    
    public func compile(_ node: Import) throws {
        guard symbols.parent == nil else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "declaration is only valid at file scope")
        }
        
        try compileModuleForImport(import: node)
        try exportPublicSymbolsFromModule(sourceAnchor: node.sourceAnchor, name: node.moduleName)
    }
    
    func compileModuleForImport(import node: Import) throws {
        if globalEnvironment.hasModule(node.moduleName) {
            return
        }
        
        let isUsingStandardLibrary = (node.moduleName != kStandardLibraryModuleName) && (runtimeSupport == nil)
        let moduleData = try readModuleFromFile(sourceAnchor: node.sourceAnchor, moduleName: node.moduleName)
        let topLevel = try parse(url: moduleData.1, text: moduleData.0)
        let compiler = SnapToCoreCompiler(
            isUsingStandardLibrary: isUsingStandardLibrary,
            runtimeSupport: (node.moduleName == runtimeSupport) ? nil : runtimeSupport,
            sandboxAccessManager: sandboxAccessManager,
            globalEnvironment: globalEnvironment)
        compiler.compile(topLevel)
        if compiler.hasError {
            let fileName = topLevel.sourceAnchor?.url?.lastPathComponent
            throw CompilerError.makeOmnibusError(fileName: fileName, errors: compiler.errors)
        }
        globalEnvironment.modules[node.moduleName] = compiler.ast
    }
    
    private func readModuleFromFile(sourceAnchor: SourceAnchor?, moduleName: String) throws -> (String, URL) {
        guard moduleName != "" else {
            throw CompilerError(sourceAnchor: sourceAnchor, message: "no such module `\(moduleName)'")
        }
        
        // Try retrieving the module from the manually injected modules first.
        // If it's here then do not try to read from file.
        if let sourceCode = injectedModules[moduleName] {
            return (sourceCode, URL.init(string: moduleName)!)
        }
        
        // Try retrieving the module from file.
        if let sourceAnchor = sourceAnchor, let url = URL.init(string: moduleName.appending(".snap"), relativeTo: sourceAnchor.url?.deletingLastPathComponent()),
           FileManager.default.fileExists(atPath: url.path) {
            sandboxAccessManager?.requestAccess(url: sourceAnchor.url?.deletingLastPathComponent())
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
    
    func parse(url: URL?, text: String) throws -> TopLevel {
        let filename = url?.lastPathComponent
        
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
        
        return parser.syntaxTree!
    }
    
    // Copy symbols from the module to the parent scope.
    private func exportPublicSymbolsFromModule(sourceAnchor: SourceAnchor?, name: String) throws {
        if symbols.modulesAlreadyImported.contains(name) {
            return
        }
        
        guard let src = globalEnvironment.modules[name]?.symbols else {
            throw CompilerError(sourceAnchor: sourceAnchor, message: "failed to get symbols for module `\(name)'")
        }
        
        for (identifier, symbol) in src.symbolTable {
            if symbol.visibility == .publicVisibility {
                guard symbols.existsAndCannotBeShadowed(identifier: identifier) == false else {
                    throw CompilerError(sourceAnchor: sourceAnchor, message: "import of module `\(name)' redefines existing symbol: `\(identifier)'")
                }
                symbols.bind(identifier: identifier,
                             symbol: Symbol(type: symbol.type,
                                            offset: symbol.offset,
                                            storage: symbol.storage,
                                            visibility: .privateVisibility))
            }
        }
        
        for (identifier, record) in src.typeTable {
            if record.visibility == .publicVisibility {
                guard symbols.existsAsType(identifier: identifier) == false else {
                    throw CompilerError(sourceAnchor: sourceAnchor, message: "import of module `\(name)' redefines existing type: `\(identifier)'")
                }
                symbols.bind(identifier: identifier,
                             symbolType: record.symbolType,
                             visibility: .privateVisibility)
            }
        }
        
        symbols.modulesAlreadyImported.insert(name)
    }
}
