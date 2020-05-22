//
//  LabelDeclarationNode.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class LabelDeclarationNode: AbstractSyntaxTreeNode {
    public let identifier: TokenIdentifier
    
    public required init(identifier: TokenIdentifier) {
        self.identifier = identifier
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? LabelDeclarationNode else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard identifier == rhs.identifier else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
