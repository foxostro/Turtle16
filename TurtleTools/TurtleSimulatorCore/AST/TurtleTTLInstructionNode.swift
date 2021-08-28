//
//  TurtleTTLInstructionNode.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

public class TurtleTTLInstructionNode: AbstractSyntaxTreeNode {
    public let instruction: String
    public let parameters: [Parameter]
    public var destination: RegisterName {
        return (parameters.first as! ParameterRegister).value
    }
    
    public required init(sourceAnchor: SourceAnchor? = nil, instruction: String, parameters: [Parameter] = []) {
        self.instruction = instruction
        self.parameters = parameters
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? TurtleTTLInstructionNode else { return false }
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
