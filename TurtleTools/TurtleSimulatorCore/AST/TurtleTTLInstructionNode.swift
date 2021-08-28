//
//  TurtleTTLInstructionNode.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

extension InstructionNode {
    var destination: RegisterName {
        (parameters.first as! ParameterRegister).value
    }
}
