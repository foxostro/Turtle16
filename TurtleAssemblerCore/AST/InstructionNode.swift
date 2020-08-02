//
//  InstructionNode.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

public class InstructionNode: AbstractSyntaxTreeNode {
    public let instruction: String
    public let parameters: ParameterList
    public var destination: RegisterName {
        return (parameters.elements.first as! ParameterRegister).value
    }
    
    public convenience init(instruction: String, parameters: ParameterList) {
        self.init(sourceAnchor: nil, instruction: instruction, parameters: parameters)
    }
    
    public required init(sourceAnchor: SourceAnchor?, instruction: String, parameters: ParameterList) {
        self.instruction = instruction
        self.parameters = parameters
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? InstructionNode else { return false }
        guard instruction == rhs.instruction else { return false }
        guard parameters == rhs.parameters else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(instruction)
        hasher.combine(parameters)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
