//
//  ParameterSlashed.swift
//  TurtleCore
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public class ParameterSlashed: Parameter {
    public let child: Parameter
    
    public convenience init(_ child: Parameter) {
        self.init(sourceAnchor: nil, child: child)
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                child: Parameter,
                id: ID = ID()) {
        self.child = child.withSourceAnchor(sourceAnchor) as! Parameter
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ParameterSlashed {
        ParameterSlashed(sourceAnchor: sourceAnchor,
                         child: child,
                         id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard child == rhs.child else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(child)
    }
    
    public override var description: String {
        "/\(child)"
    }
}

