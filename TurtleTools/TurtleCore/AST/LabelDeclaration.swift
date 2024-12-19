//
//  LabelDeclaration.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class LabelDeclaration: AbstractSyntaxTreeNode {
    public let identifier: String
    
    public convenience init(sourceAnchor: SourceAnchor? = nil, _ ident: ParameterIdentifier) {
        self.init(sourceAnchor: sourceAnchor, identifier: ident.value)
    }
    
    public required init(sourceAnchor: SourceAnchor? = nil,
                         identifier: String,
                         id: ID = ID()) {
        self.identifier = identifier
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> LabelDeclaration {
        LabelDeclaration(sourceAnchor: sourceAnchor,
                         identifier: identifier,
                         id: id)
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
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let name = String(describing: type(of: self))
        return "\(indent)\(name)(\(identifier))"
    }
}
