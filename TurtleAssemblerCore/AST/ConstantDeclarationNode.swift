//
//  ConstantDeclarationNode.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class ConstantDeclarationNode: AbstractSyntaxTreeNode {
    public let identifier: TokenIdentifier
    public let number: TokenNumber
    
    public required init(identifier: TokenIdentifier, number: TokenNumber) {
        self.identifier = identifier
        self.number = number
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? ConstantDeclarationNode else { return false }
        guard identifier == rhs.identifier else { return false }
        guard number == rhs.number else { return false }
        return true
    }
}
