//
//  ParameterNumber.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 7/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class ParameterNumber: Parameter {
    public let value: Int
    
    public convenience init(value: Int) {
        self.init(sourceAnchor: nil, value: value)
    }
    
    public init(sourceAnchor: SourceAnchor?, value: Int) {
        self.value = value
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ParameterNumber else { return false }
        guard value == rhs.value else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(value)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
