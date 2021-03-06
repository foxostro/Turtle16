//
//  CodeGenerator.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public protocol CodeGenerator {
    var hasError: Bool { get }
    var errors: [CompilerError] { get }
    var instructions: [Instruction] { get }
    
    func compile(ast root: TopLevel, base: Int)
}
