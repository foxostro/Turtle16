//
//  Import.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class Import: AbstractSyntaxTreeNode {
    public let moduleName: String
    
    public convenience init(moduleName: String) {
        self.init(sourceAnchor: nil, moduleName: moduleName)
    }
    
    public init(sourceAnchor: SourceAnchor?, moduleName: String) {
        self.moduleName = moduleName
        super.init(sourceAnchor: sourceAnchor)
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
        return String(format: "%@%@(%@)",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      moduleName)
    }
}
