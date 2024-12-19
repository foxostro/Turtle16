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
    
    fileprivate class BlockRewriter: CompilerPass {
        let globalEnvironment: GlobalEnvironment
        
        init(_ globalEnvironment: GlobalEnvironment) {
            self.globalEnvironment = globalEnvironment
        }
        
        public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
            let block1 = try super.visit(block: block0) as! Block
            let block2 = globalEnvironment.enableVtableHack
                ? insertVtableDeclarations(block1)
                : block1
            return block2
        }
        
        func insertVtableDeclarations(_ block0: Block) -> Block {
            let pendingInsertions = block0.symbols.pendingInsertions
            
            var children = block0.children
            
            for (traitName, toInsert) in pendingInsertions {
                assert(toInsert.tags.contains(.vtable))
                
                let indexOfTraitDecl = children.firstIndex {
                    let traitDecl = $0 as? TraitDeclaration
                    return traitDecl?.name == traitName
                }
                let insertionIndex = if let indexOfTraitDecl {
                    children.index(after: indexOfTraitDecl)
                }
                else {
                    children.startIndex
                }
                
                if insertionIndex < children.count,
                   let existingSeq = children[insertionIndex] as? Seq,
                   existingSeq.tags.contains(.vtable) {
                    
                    children[insertionIndex] = existingSeq
                        .appending(children: toInsert.children)
                        .removeDuplicateVtableDeclarations()
                }
                else {
                    children.insert(toInsert, at: insertionIndex)
                }
            }
            
            let block1 = block0.withChildren(children)
            block1.symbols.pendingInsertions.removeAll()
            return block1
        }
    }
    
    public convenience init(_ env: GlobalEnvironment = GlobalEnvironment()) {
        self.init(globalEnvironment: env)
    }
    
    public init(symbols: SymbolTable? = nil, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
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
        try node0?.clearSymbols(globalEnvironment)
    }
    
    /// Transformation to apply to the program AST after the compiler pass runs
    public func postProcess(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        try BlockRewriter(globalEnvironment).run(node0)
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
            globalEnvironment: globalEnvironment,
            symbols: symbols!,
            enclosingImplId: nil)
        .scan(func: node)
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
    
    func scan(module module0: Module) throws {
        let block0 = module0.block
        let blockOrSeq = try visit(block: block0)
        let block1: Block = switch blockOrSeq {
        case let block as Block:
            block
            
        default:
            block0.withChildren([blockOrSeq!])
        }
        let module1 = module0.withBlock(block1)
        
        guard modules[module1.name] == nil else {
            let message = if let existing = modules[module1.name]?.sourceAnchor {
                "module duplicates existing module \"\(module1.name)\" declared at \(existing)"
            }
            else {
                "module duplicates existing module \"\(module1.name)\""
            }
            throw CompilerError(sourceAnchor: module1.sourceAnchor, message: message)
        }
        modules[module1.name] = module1
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
                guard !symbols.exists(identifier: identifier) else {
                    throw CompilerError(
                        sourceAnchor: sourceAnchor,
                        message: "import of module `\(name)' redefines existing symbol: `\(identifier)'")
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
            globalEnvironment: globalEnvironment)
        .compile(node1)
        return node1
    }
    
    public override func willVisit(block: Block, clause: Match.Clause, in match: Match) throws {
        try super.willVisit(block: block, clause: clause, in: match)
        try scan(block: block, clause: clause, in: match)
    }
}
