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
    
    public init(sourceAnchor: SourceAnchor? = nil,
                offset: ParameterNumber,
                identifier: ParameterIdentifier,
                id: ID = ID()) {
        self.offset = offset.withSourceAnchor(sourceAnchor)
        self.identifier = identifier.withSourceAnchor(sourceAnchor)
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ParameterAddress {
        ParameterAddress(sourceAnchor: sourceAnchor,
                         offset: offset,
                         identifier: identifier,
                         id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard offset == rhs.offset else { return false }
        guard identifier == rhs.identifier else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(offset)
        hasher.combine(identifier)
    }
    
    public override var description: String {
        return "\(offset)(\(identifier))"
    }
}

