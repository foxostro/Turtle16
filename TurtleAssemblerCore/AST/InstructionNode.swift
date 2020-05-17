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
    public let instruction: Token
    public let parameters: ParameterListNode
    public var destination: RegisterName {
        return (parameters.parameters.first as! TokenRegister).literal
    }
    
    public required init(instruction: Token, parameters: ParameterListNode) {
        self.instruction = instruction
        self.parameters = parameters
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? InstructionNode else { return false }
        return parameters == rhs.parameters
    }
}
