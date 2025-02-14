//
//  CompilerPassWithDeclScan.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/18/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CompilerPassWithDeclScan: CompilerPass {
    let staticStorageFrame: Frame
    let memoryLayoutStrategy: MemoryLayoutStrategy
    var modules: [String : Module] = [:]
    
    public var rvalueContext: RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
    }
    
    public var lvalueContext: LvalueExpressionTypeChecker {
        LvalueExpressionTypeChecker(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
    }
    
    public var typeContext: TypeContextTypeChecker {
        TypeContextTypeChecker(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
    }
    
    public init(
        symbols: SymbolTable? = nil,
        staticStorageFrame: Frame = Frame(),
        memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) {
        self.staticStorageFrame = staticStorageFrame
        self.memoryLayoutStrategy = memoryLayoutStrategy
        super.init(symbols)
    }
    
    public override func run(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let node1 = try preProcess(node0)
        let node2 = try super.run(node1)
        let node3 = try postProcess(node2)
        return node3
    }
    
    /// Transformation to apply to the program AST before the compiler pass runs
    public func preProcess(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        try node0?.clearSymbols(staticStorageFrame)
    }
    
    /// Transformation to apply to the program AST after the compiler pass runs
    public func postProcess(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        node0
    }
    
    func scan(block: Block) throws {
        for child in block.children {
            try scan(genericNode: child)
        }
    }
    
    func scan(genericNode: AbstractSyntaxTreeNode) throws {
        switch genericNode {
        case let node as Seq:
            try scan(seq: node)
        case let node as FunctionDeclaration:
            try scan(func: node)
        case let node as StructDeclaration:
            try scan(struct: node)
        case let node as Typealias:
            try scan(typealias: node)
        case let node as TraitDeclaration:
            try scan(trait: node)
        case let node as Impl:
            try scan(impl: node)
        case let node as ImplFor:
            try scan(implFor: node)
        case let node as Module:
            try scan(module: node)
        case let node as Import:
            try scan(import: node)
        case let node as LabelDeclaration:
            try scan(label: node)
        default:
            break
        }
    }
    
    func scan(seq: Seq) throws {
        for child in seq.children {
            try scan(genericNode: child)
        }
    }
    
    func scan(func node: FunctionDeclaration) throws {
        try FunctionScanner(
            memoryLayoutStrategy: memoryLayoutStrategy,
            symbols: symbols!,
            enclosingImplId: nil)
        .scan(func: node)
    }
    
    func scan(struct node: StructDeclaration) throws {
        try StructScanner(
            symbols: symbols!,
            memoryLayoutStrategy: memoryLayoutStrategy)
        .compile(node)
    }
    
    func scan(typealias node: Typealias) throws {
        try TypealiasScanner(symbols!).compile(node)
    }
    
    func scan(trait node: TraitDeclaration) throws {
        try TraitScanner(
            memoryLayoutStrategy: memoryLayoutStrategy,
            symbols: symbols!)
        .scan(trait: node)
    }
    
    func scan(impl node: Impl) throws {
        try ImplScanner(
            memoryLayoutStrategy: memoryLayoutStrategy,
            symbols: symbols!)
        .scan(impl: node)
    }
    
    func scan(implFor node: ImplFor) throws {
        try ImplForScanner(
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy,
            symbols: symbols!)
        .scan(implFor: node)
    }
    
    func scan(module module0: Module) throws {
        let name = module0.name
        let block0 = module0.block
        block0.symbols.breadcrumb = .module(name: name, useGlobalNamespace: module0.useGlobalNamespace)
        let blockOrSeq = try visit(block: block0)
        let block1: Block = switch blockOrSeq {
        case let block as Block:
            block
            
        default:
            block0.withChildren([blockOrSeq!])
        }
        let module1 = module0.withBlock(block1)
        
        guard modules[name] == nil else {
            let message = if let existing = modules[name]?.sourceAnchor {
                "module duplicates existing module \"\(name)\" declared at \(existing)"
            }
            else {
                "module duplicates existing module \"\(name)\""
            }
            throw CompilerError(sourceAnchor: module1.sourceAnchor, message: message)
        }
        modules[name] = module1
    }
    
    func scan(import node: Import) throws {
        let sourceAnchor = node.sourceAnchor
        let name = node.moduleName
        
        guard let symbols, symbols.parent == nil else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "declaration is only valid at file scope")
        }
        
        guard !symbols.modulesAlreadyImported.contains(name) else { return }
        
        guard let src = modules[name]?.block.symbols else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "failed to get symbols for module `\(name)'")
        }
        
        if node.intoGlobalNamespace {
            try src.export(
                to: symbols,
                moduleName: name,
                sourceAnchor: sourceAnchor)
        }
        else {
            let moduleSym = SymbolTable()
            let module = SymbolType.structType(StructType(
                name: name,
                symbols: moduleSym,
                associatedModuleName: name))
            
            try src.export(
                to: moduleSym,
                moduleName: name,
                sourceAnchor: sourceAnchor)
            
            guard !symbols.exists(identifier: name) else {
                throw CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "import of module `\(name)' redefines existing symbol of the same name")
            }
            
            guard !symbols.existsAsType(identifier: name) else {
                throw CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "import of module `\(name)' redefines existing type of the same name")
            }
            
            symbols.bind(identifier: name,
                         symbolType: module,
                         visibility: .privateVisibility)
        }
        
        symbols.modulesAlreadyImported.insert(name)
    }
    
    func scan(block: Block, clause: Match.Clause, in match: Match) throws {
        let symbols = clause.block.symbols
        let clauseType = try typeContext.check(expression: clause.valueType)
        symbols.bind(identifier: clause.valueIdentifier.identifier,
                     symbol: Symbol(type: clauseType))
        try scan(block: clause.block)
    }
    
    func scan(label: LabelDeclaration) throws {
        symbols!.bind(identifier: label.identifier, symbol: Symbol(type: .label))
    }
    
    public override func willVisit(block node: Block) throws {
        try super.willVisit(block: node)
        try scan(block: node)
    }
    
    public override func willVisit(func node: FunctionDeclaration) throws {
        assert(node.symbols.frameLookupMode.isSet)
        try super.willVisit(func: node)
    }
    
    public override func visit(module: Module) throws -> AbstractSyntaxTreeNode? {
        modules[module.name]
    }
    
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(varDecl: node0) as! VarDeclaration
        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
        .compile(node1)
        return node1
    }
    
    public override func willVisit(block: Block, clause: Match.Clause, in match: Match) throws {
        try super.willVisit(block: block, clause: clause, in: match)
        try scan(block: block, clause: clause, in: match)
    }
}

fileprivate extension SymbolTable {
    func export(to dst: SymbolTable,
                moduleName: String,
                sourceAnchor: SourceAnchor?) throws {
        
        for (identifier, symbol) in symbolTable {
            if symbol.visibility == .publicVisibility {
                guard !dst.exists(identifier: identifier) else {
                    throw CompilerError(
                        sourceAnchor: sourceAnchor,
                        message: "import of module `\(moduleName)' redefines existing symbol: `\(identifier)'")
                }
                
                guard !dst.existsAsType(identifier: identifier) else {
                    throw CompilerError(
                        sourceAnchor: sourceAnchor,
                        message: "import of module `\(moduleName)' redefines existing type: `\(identifier)'")
                }
                
                dst.bind(
                    identifier: identifier,
                    symbol: Symbol(
                        type: symbol.type,
                        offset: symbol.offset,
                        storage: symbol.storage,
                        visibility: .privateVisibility))
            }
        }
        
        for (identifier, record) in typeTable {
            if record.visibility == .publicVisibility {
                guard !dst.existsAsType(identifier: identifier) else {
                    throw CompilerError(
                        sourceAnchor: sourceAnchor,
                        message: "import of module `\(moduleName)' redefines existing type: `\(identifier)'")
                }
                                
                dst.bind(
                    identifier: identifier,
                    symbolType: record.symbolType,
                    visibility: .privateVisibility)
            }
        }
    }
}
