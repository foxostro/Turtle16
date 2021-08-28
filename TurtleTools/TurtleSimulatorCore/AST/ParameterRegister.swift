//
//  ParameterRegister.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 7/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class ParameterRegister: Parameter {
    public let value: RegisterName
    
    public convenience init(_ value: RegisterName) {
        self.init(value: value)
    }
    
    public init(sourceAnchor: SourceAnchor? = nil, value: RegisterName) {
        self.value = value
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ParameterRegister {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return ParameterRegister(sourceAnchor: sourceAnchor, value: value)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ParameterRegister else { return false }
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
