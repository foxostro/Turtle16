//
//  ConstantDeclaration.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class ConstantDeclaration: AbstractSyntaxTreeNode {
    public let identifier: String
    public let value: Int
    
    public required init(sourceAnchor: SourceAnchor? = nil, identifier: String, value: Int) {
        self.identifier = identifier
        self.value = value
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ConstantDeclaration {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return ConstantDeclaration(sourceAnchor: sourceAnchor,
                                   identifier: identifier,
                                   value: value)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ConstantDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard value == rhs.value else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(value)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
