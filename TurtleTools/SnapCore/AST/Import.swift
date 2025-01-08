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
    public let intoGlobalNamespace: Bool
    
    public init(sourceAnchor: SourceAnchor? = nil,
                moduleName: String,
                intoGlobalNamespace: Bool = false,
                id: ID = ID()) {
        self.moduleName = moduleName
        self.intoGlobalNamespace = intoGlobalNamespace
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Import {
        Import(sourceAnchor: sourceAnchor,
               moduleName: moduleName,
               intoGlobalNamespace: intoGlobalNamespace,
               id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Import else { return false }
        guard moduleName == rhs.moduleName else { return false }
        guard intoGlobalNamespace == rhs.intoGlobalNamespace else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(moduleName)
        hasher.combine(intoGlobalNamespace)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let selfDesc = String(describing: type(of: self))
        let globalLbl = intoGlobalNamespace ? " [GLOBAL]" : ""
        let result = "\(indent)\(selfDesc)(\(moduleName))\(globalLbl)"
        return result
    }
}
