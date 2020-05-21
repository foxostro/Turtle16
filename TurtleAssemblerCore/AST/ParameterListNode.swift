//
//  ParameterListNode.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 10/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class ParameterListNode: AbstractSyntaxTreeNode {
    public let parameters: [Any]
    
    public required init(parameters: [Any]) {
        self.parameters = parameters
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ParameterListNode else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard parameters.count == rhs.parameters.count else { return false }
        
        for i in 0..<parameters.count {
            if type(of: parameters[i]) != type(of: rhs.parameters[i]) {
                return false
            }
                
            // Try to compare as RegisterName
            let a = parameters[i] as? RegisterName
            let b = rhs.parameters[i] as? RegisterName
            if a != nil && b != nil && a != b {
                return false
            }

            // Try to compare as NSObject
            let c = parameters[i] as? NSObject
            let d = rhs.parameters[i] as? NSObject
            if c != nil && d != nil && c != d {
                return false
            }
        }
        
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        
        for parameter in parameters {
            if let a = parameter as? RegisterName {
                hasher.combine(a)
            } else {
                let a = parameter as! NSObject
                hasher.combine(a)
            }
        }
        
        return hasher.finalize()
    }
}
