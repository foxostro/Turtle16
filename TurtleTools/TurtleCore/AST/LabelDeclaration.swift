//
//  LabelDeclaration.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public final class LabelDeclaration: AbstractSyntaxTreeNode {
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
    
    public func withIdentifier(_ identifier: String) -> LabelDeclaration {
        LabelDeclaration(sourceAnchor: sourceAnchor,
                         identifier: identifier,
                         id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard identifier == rhs.identifier else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(identifier)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let name = String(describing: type(of: self))
        return "\(indent)\(name)(\(identifier))"
    }
}
