//
//  GenericFunctionPartialEvaluator.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/8/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class GenericFunctionPartialEvaluator: CompilerPass {
    public let map: [String : Expression]
    
    public init(symbols: SymbolTable?, map: [String : Expression]) {
        self.map = map
        super.init(symbols)
    }
    
    public override func visit(identifier node0: Expression.Identifier) -> Expression? {
        map[node0.identifier] ?? node0
    }
    
}
