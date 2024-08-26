//
//  Block.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Block: AbstractSyntaxTreeNode {
    public let symbols: SymbolTable
    public let children: [AbstractSyntaxTreeNode]
    public let id: ID
    
    public init(sourceAnchor: SourceAnchor? = nil,
                symbols: SymbolTable = SymbolTable(),
                children: [AbstractSyntaxTreeNode] = [],
                id: ID = ID()) {
        self.symbols = symbols
        symbols.associatedNodeId = id
        self.children = children
        self.id = id
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Block {
        Block(sourceAnchor: sourceAnchor,
              symbols: symbols,
              children: children,
              id: id)
    }
    
    public func withSymbols(_ symbols: SymbolTable) -> Block {
        Block(sourceAnchor: sourceAnchor,
              symbols: symbols,
              children: children,
              id: id)
    }
    
    public func withChildren(_ children: [AbstractSyntaxTreeNode]) -> Block {
        Block(sourceAnchor: sourceAnchor,
              symbols: symbols,
              children: children,
              id: id)
    }
    
    public func withNewId() -> Block {
        Block(sourceAnchor: sourceAnchor,
              symbols: symbols,
              children: children,
              id: ID())
    }
    
    public func clone() -> Block {
        class BlockCloner: CompilerPass {
            public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
                let block1 = try super.visit(block: block0) as! Block
                let block2 = block1.withNewId()
                return block2
            }
        }
        
        return try! BlockCloner().run(self) as! Block
    }
    
    public func inserting(children toInsert: [AbstractSyntaxTreeNode], at index: Int) -> Block {
        var children1 = children
        children1.insert(contentsOf: toInsert, at: index)
        return withChildren(children1)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Block else { return false }
//        guard symbols == rhs.symbols else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
//        hasher.combine(symbols)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let typeDesc = String(describing: type(of: self))
        let parentStr = if let parent = symbols.parent {
                "\(parent)"
            }
            else {
                "nil"
            }
        let selfDesc = "(symbols=\(symbols); parent=\(parentStr); id=\(id.uuidString))"
        let childDesc = makeChildDescriptions(depth: depth + 1)
        let fullDesc = "\(indent)\(typeDesc)\(selfDesc)\(childDesc)"
        return fullDesc
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        if children.isEmpty {
            " (empty)"
        } else {
            "\n" + children
                .map {
                    $0.makeIndentedDescription(
                        depth: depth,
                        wantsLeadingWhitespace: true)
                }
                .joined(separator: "\n")
        }
    }
}
