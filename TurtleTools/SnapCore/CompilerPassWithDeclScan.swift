//
//  CompilerPassWithDeclScan.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/18/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CompilerPassWithDeclScan: CompilerPass {
    let globalEnvironment: GlobalEnvironment
    var modules: [String : Module] = [:]
    
    public convenience init(_ env: GlobalEnvironment = GlobalEnvironment()) {
        self.init(globalEnvironment: env)
    }
    
    public init(symbols: SymbolTable? = nil, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func run(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        try visit(node0)
    }
    
    func scan(block: Block) throws {
        for child in block.children {
            try scan(genericNode: child)
        }
    }
    
    func scan(genericNode: AbstractSyntaxTreeNode) throws {
        switch genericNode {
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
        default:
            break
        }
    }
    
    func scan(func node: FunctionDeclaration) throws {
        try SnapSubcompilerFunctionDeclaration().compile(
            globalEnvironment: globalEnvironment,
            symbols: symbols!,
            node: node)
    }
    
    func scan(struct node: StructDeclaration) throws {
        try SnapSubcompilerStructDeclaration(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
        .compile(node)
    }
    
    func scan(typealias node: Typealias) throws {
        try SnapSubcompilerTypealias(symbols!).compile(node)
    }
    
    func scan(trait node: TraitDeclaration) throws {
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols!)
        .compile(node)
    }
    
    func scan(impl node: Impl) throws {
        try SnapSubcompilerImpl(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
        .compile(node)
    }
    
    func scan(implFor node: ImplFor) throws {
        try SnapSubcompilerImplFor(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
        .compile(node)
    }
    
    func scan(module node0: Module) throws {
        let block0 = node0.block
        let block1 = try visit(block: block0) as! Block
        let node1 = node0.withBlock(block1)
        
        guard modules[node1.name] == nil else {
            let message = if let existing = modules[node1.name]?.sourceAnchor {
                "module duplicates existing module \"\(node1.name)\" declared at \(existing)"
            }
            else {
                "module duplicates existing module \"\(node1.name)\""
            }
            throw CompilerError(sourceAnchor: node1.sourceAnchor, message: message)
        }
        modules[node1.name] = node1
    }
    
    func scan(import node: Import) throws {
        let sourceAnchor = node.sourceAnchor
        let name = node.moduleName
        
        guard let symbols, symbols.parent == nil else {
            throw CompilerError(sourceAnchor: sourceAnchor, message: "declaration is only valid at file scope")
        }
        
        guard !symbols.modulesAlreadyImported.contains(name) else {
            return
        }
        
        guard let src = modules[name]?.block.symbols else {
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
    
    public override func willVisit(block node: Block) throws {
        try super.willVisit(block: node)
        try scan(block: node)
    }
    
    public override func willVisit(func node: FunctionDeclaration) throws {
        assert(node.symbols.frameLookupMode.isSet)
        try super.willVisit(func: node)
    }
    
    public override func visit(module node: Module) throws -> AbstractSyntaxTreeNode? {
        modules[node.name]
    }
}

