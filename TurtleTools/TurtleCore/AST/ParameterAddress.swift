//
//  ParameterAddress.swift
//  TurtleCore
//
//  Created by Andrew Fox on 5/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public class ParameterAddress: Parameter {
    public let offset: ParameterNumber
    public let identifier: ParameterIdentifier
    
    public convenience init(offset: ParameterNumber, identifier: ParameterIdentifier) {
        self.init(sourceAnchor: nil, offset: offset, identifier: identifier)
    }
    
    public init(sourceAnchor: SourceAnchor?, offset: ParameterNumber, identifier: ParameterIdentifier) {
        self.offset = offset
        self.identifier = identifier
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ParameterAddress else { return false }
        guard offset == rhs.offset else { return false }
        guard identifier == rhs.identifier else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(offset)
        hasher.combine(identifier)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
