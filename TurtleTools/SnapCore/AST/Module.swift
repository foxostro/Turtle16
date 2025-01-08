//
//  Module.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/19/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Module: AbstractSyntaxTreeNode {
    public let name: String
    public let useGlobalNamespace: Bool
    public let block: Block
    
    public init(sourceAnchor: SourceAnchor? = nil,
                name: String,
                useGlobalNamespace: Bool = false,
                block: Block,
                id: ID = ID()) {
        self.name = name
        self.useGlobalNamespace = useGlobalNamespace
        self.block = block
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Module {
        Module(sourceAnchor: sourceAnchor,
               name: name,
               useGlobalNamespace: useGlobalNamespace,
               block: block,
               id: id)
    }
    
    public func withUseGlobalNamespace(_ useGlobalNamespace: Bool) -> Module {
        Module(sourceAnchor: sourceAnchor,
               name: name,
               useGlobalNamespace: useGlobalNamespace,
               block: block,
               id: id)
    }
    
    public func withBlock(_ block: Block) -> Module {
        Module(sourceAnchor: sourceAnchor,
               name: name,
               useGlobalNamespace: useGlobalNamespace,
               block: block,
               id: id)
    }
    
    public func inserting(children toInsert: [AbstractSyntaxTreeNode], at index: Int) -> Module {
        withBlock(block.inserting(children: toInsert, at: 0))
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Module else { return false }
        guard name == rhs.name else { return false }
        guard useGlobalNamespace == rhs.useGlobalNamespace else { return false }
        guard block == rhs.block else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(useGlobalNamespace)
        hasher.combine(block)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        let childDesc = block.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: true)
        let fullDesc = """
            \(indent0)Module(\(name))
            \(indent1)useGlobalNamespace: \(useGlobalNamespace)
            \(childDesc)
            \(indent0)\n
            """
        return fullDesc
    }
}
