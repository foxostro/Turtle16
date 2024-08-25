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
    
    public init(sourceAnchor: SourceAnchor? = nil, child: Parameter) {
        self.child = child.withSourceAnchor(sourceAnchor) as! Parameter
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ParameterSlashed {
        ParameterSlashed(sourceAnchor: sourceAnchor, child: child)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ParameterSlashed else { return false }
        guard child == rhs.child else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(child)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override var description: String {
        return "/\(child)"
    }
}

