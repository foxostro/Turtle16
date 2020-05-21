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
    public let parameters: ParameterListNode // TODO: Should `parameters' be in `children' instead?
    public var destination: RegisterName {
        return (parameters.parameters.first as! TokenRegister).literal
    }
    
    public required init(instruction: Token, parameters: ParameterListNode) {
        self.instruction = instruction
        self.parameters = parameters
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? InstructionNode else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard instruction == rhs.instruction else { return false }
        guard parameters == rhs.parameters else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(instruction)
        hasher.combine(parameters)
        return hasher.finalize()
    }
}
