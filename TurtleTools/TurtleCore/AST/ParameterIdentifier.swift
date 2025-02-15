//
//  ParameterIdentifier.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class ParameterIdentifier: Parameter {
    public let value: String
    
    public convenience init(_ value: String) {
        self.init(value: value)
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                value: String,
                id: ID = ID()) {
        self.value = value
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ParameterIdentifier {
        ParameterIdentifier(sourceAnchor: sourceAnchor,
                            value: value,
                            id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard value == rhs.value else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(value)
    }
    
    public override var description: String {
        "\(value)"
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        return "\(indent)\(value)"
    }
}
