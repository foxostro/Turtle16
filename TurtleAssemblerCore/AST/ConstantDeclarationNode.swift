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
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ConstantDeclarationNode else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard identifier == rhs.identifier else { return false }
        guard number == rhs.number else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(number)
        return hasher.finalize()
    }
}
