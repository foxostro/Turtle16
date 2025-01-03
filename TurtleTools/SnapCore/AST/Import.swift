//
//  Import.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Import: AbstractSyntaxTreeNode {
    public let moduleName: String
    
    public init(sourceAnchor: SourceAnchor? = nil,
                moduleName: String,
                id: ID = ID()) {
        self.moduleName = moduleName
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Import {
        Import(sourceAnchor: sourceAnchor,
               moduleName: moduleName,
               id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Import else { return false }
        guard moduleName == rhs.moduleName else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(moduleName)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        String(format: "%@%@(%@)",
               wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
               String(describing: type(of: self)),
               moduleName)
    }
}
