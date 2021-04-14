//
//  ParameterIdentifier.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class ParameterIdentifier: Parameter {
    public let value: String
    
    public convenience init(value: String) {
        self.init(sourceAnchor: nil, value: value)
    }
    
    public init(sourceAnchor: SourceAnchor?, value: String) {
        self.value = value
        super.init(sourceAnchor: sourceAnchor)
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
}
