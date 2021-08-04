//
//  SnapSubcompilerTopLevel.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerTopLevel: NSObject {
    public private(set) var symbols: SymbolTable? = nil
    
    public init(_ symbols: SymbolTable? = nil) {
        self.symbols = symbols
    }
    
    public func compile(_ root: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        guard let topLevel = root as? TopLevel else {
            return root
        }
        let blockSymbols = CompilerIntrinsicSymbolBinder().bindCompilerIntrinsics(symbols: SymbolTable())
        let result = Block(sourceAnchor: topLevel.sourceAnchor,
                           symbols: blockSymbols,
                           children: topLevel.children)
        return result
    }
}
