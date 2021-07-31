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
    
    public init(sourceAnchor: SourceAnchor? = nil,
                symbols: SymbolTable = SymbolTable(),
                children: [AbstractSyntaxTreeNode] = []) {
        self.symbols = symbols
        self.children = children
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Block else { return false }
        guard symbols == rhs.symbols else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(symbols)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let parentStr: String
        if let parent = symbols.parent {
            parentStr = "\(parent)"
        } else {
            parentStr = "nil"
        }
        
        return String(format: "%@%@%@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)) + "(symbols=\(symbols); parent=\(parentStr))",
                      makeChildDescriptions(depth: depth + 1))
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        let result: String
        if children.isEmpty {
            result = " (empty)"
        } else {
            result = "\n" + children.map({$0.makeIndentedDescription(depth: depth, wantsLeadingWhitespace: true)}).joined(separator: "\n")
        }
        return result
    }
}
