//
//  ParameterListNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 10/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class ParameterListNode: AbstractSyntaxTreeNode {
    let parameters: [Any]
    
    public required init(parameters: [Any]) {
        self.parameters = parameters
        super.init(children: [])
    }
        
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? ParameterListNode {
            return self == rhs
        }
        return false
    }
}

public func ==(lhs: ParameterListNode, rhs: ParameterListNode) -> Bool {
    if type(of: lhs) != type(of: rhs) {
        return false
    }
    
    if lhs.parameters.count != rhs.parameters.count {
        return false
    }
    
    for i in 0..<lhs.parameters.count {
        if type(of: lhs.parameters[i]) != type(of: rhs.parameters[i]) {
            return false
        }
            
        // Try to compare as RegisterName
        let a = lhs.parameters[i] as? RegisterName
        let b = rhs.parameters[i] as? RegisterName
        if a != nil && b != nil && a != b {
            return false
        }

        // Try to compare as NSObject
        let c = lhs.parameters[i] as? NSObject
        let d = rhs.parameters[i] as? NSObject
        if c != nil && d != nil && c != d {
            return false
        }
    }
    
    return true
}
