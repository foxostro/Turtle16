//
//  LabelDeclaration.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class LabelDeclaration: AbstractSyntaxTreeNode {
    public let identifier: String
    
    public convenience init(identifier: String) {
        self.init(sourceAnchor: nil, identifier: identifier)
    }
    
    public required init(sourceAnchor: SourceAnchor?, identifier: String) {
        self.identifier = identifier
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? LabelDeclaration else { return false }
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
