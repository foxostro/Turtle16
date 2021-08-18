//
//  ParameterList.swift
//  TurtleCore
//
//  Created by Andrew Fox on 10/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class ParameterList: AbstractSyntaxTreeNode {
    public let elements: [Parameter]
    
    public convenience init(parameters: [Parameter]) {
        self.init(sourceAnchor: nil, parameters: parameters)
    }
    
    public required init(sourceAnchor: SourceAnchor?, parameters: [Parameter]) {
        self.elements = parameters
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ParameterList else { return false }
        guard elements == rhs.elements else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        for parameter in elements {
            hasher.combine(parameter)
        }
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let param = elements.map {
            $0.makeIndentedDescription(depth: depth+1, wantsLeadingWhitespace: false)
        }.joined(separator: ", ")
        return "\(indent)\(param)"
    }
}
