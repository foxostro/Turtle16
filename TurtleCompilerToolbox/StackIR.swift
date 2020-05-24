//
//  StackIR.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public enum StackIR: Equatable {
    case push(Int), pop, pop2, add, sub, mul, div, mod
}
