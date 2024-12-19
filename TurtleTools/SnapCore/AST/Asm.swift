//
//  Asm.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/10/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Asm: AbstractSyntaxTreeNode {
    public let assemblyCode: String
    
    public init(sourceAnchor: SourceAnchor? = nil, assemblyCode: String, id: ID = ID()) {
        self.assemblyCode = assemblyCode
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Asm {
        Asm(sourceAnchor: sourceAnchor,
            assemblyCode: assemblyCode,
            id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Asm else { return false }
        guard assemblyCode == rhs.assemblyCode else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(assemblyCode)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let leadingWhitespace = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let selfDesc = String(describing: type(of: self))
        let indentedAssemblyCode: String
        if assemblyCode == "" {
            indentedAssemblyCode = " (empty)"
        }
        else {
            indentedAssemblyCode = "\n" + assemblyCode.split(separator: "\n").map({ makeIndent(depth: depth + 1) + $0 }).joined()
        }
        let result = "\(leadingWhitespace)\(selfDesc):\(indentedAssemblyCode)"
        return result
    }
}
