//
//  Import.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Directive to import symbols from the specified module
public final class Import: AbstractSyntaxTreeNode {
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
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard moduleName == rhs.moduleName else { return false }
        guard intoGlobalNamespace == rhs.intoGlobalNamespace else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(moduleName)
        hasher.combine(intoGlobalNamespace)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let selfDesc = String(describing: type(of: self))
        let globalLbl = intoGlobalNamespace ? " [GLOBAL]" : ""
        let result = "\(indent)\(selfDesc)(\(moduleName))\(globalLbl)"
        return result
    }
}
