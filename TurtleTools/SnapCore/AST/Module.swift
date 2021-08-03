//
//  Module.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Module: AbstractSyntaxTreeNode {
    public let name: String
    public let children: [AbstractSyntaxTreeNode]
    public let symbols: SymbolTable
    
    public init(sourceAnchor: SourceAnchor? = nil,
                name: String,
                children: [AbstractSyntaxTreeNode] = [],
                symbols: SymbolTable = SymbolTable()) {
        self.name = name
        self.children = children
        self.symbols = symbols
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Module else { return false }
        guard name == rhs.name else { return false }
        guard children == rhs.children else { return false }
//        guard symbols == rhs.symbols else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(children)
//        hasher.combine(symbols)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@(\(name))%@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
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
