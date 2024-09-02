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
        let node1 = try node0?.clearSymbols(globalEnvironment)
        let node2 = try super.run(node1)
        return node2
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
    
    func scan(block: Block, clause: Match.Clause, in match: Match) throws {
        let symbols = clause.block.symbols
        let clauseType = try TypeContextTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment).check(expression: clause.valueType)
        symbols.bind(identifier: clause.valueIdentifier.identifier,
                     symbol: Symbol(type: clauseType))
        try scan(block: clause.block)
    }
    
    public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
        try willVisit(block: block0)
        let block1 = block0.withChildren(try block0.children.compactMap {
            try visit($0)
        })
        let block2 = try consumeScopePrologue(block1)
        didVisit(block: block0)
        return block2
    }
    
    private func consumeScopePrologue(_ block1: Block) throws -> Block {
        guard let symbols else { return block1 }
        let index = block1.children.firstIndex {
            ($0 as? Seq)?.tags.contains(.scopePrologue) ?? false
        }
        let block2: Block
        if let index {
            var children = block1.children
            let scopePrologue0 = children[index] as! Seq
            let scopePrologue1 = scopePrologue0.appending(children: symbols.scopePrologue.children)
            children[index] = scopePrologue1
            block2 = block1.withChildren(children)
        }
        else {
            block2 = block1.inserting(seq: symbols.scopePrologue, at: 0)
        }
        symbols.scopePrologue = symbols.scopePrologue.withChildren([])
        return block2
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
    
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(varDecl: node0) as! VarDeclaration
        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
        .compile(node1)
        return node1
    }
    
    public override func willVisit(block: Block, clause: Match.Clause, in match: Match) throws {
        try super.willVisit(block: block, clause: clause, in: match)
        try scan(block: block, clause: clause, in: match)
    }
}

