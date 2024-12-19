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
    public let block: Block
    
    public init(sourceAnchor: SourceAnchor? = nil,
                name: String,
                block: Block,
                id: ID = ID()) {
        self.name = name
        self.block = block
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Module {
        Module(sourceAnchor: sourceAnchor,
               name: name,
               block: block,
               id: id)
    }
    
    public func withBlock(_ block: Block) -> Module {
        Module(sourceAnchor: sourceAnchor,
               name: name,
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
        guard block == rhs.block else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(block)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let childDesc = block.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: true)
        let fullDesc = "\(indent)module \"\(name)\" {\n\(childDesc)\n\(indent)}"
        return fullDesc
    }
}
