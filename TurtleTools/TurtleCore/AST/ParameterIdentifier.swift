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
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ParameterIdentifier else { return false }
        guard value == rhs.value else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(value)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override var description: String {
        return "\(value)"
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        return "\(indent)\(value)"
    }
}
