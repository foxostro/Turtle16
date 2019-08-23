//
//  TokenType.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public enum TokenType {
    case eof
    case newline
    case comma
    case colon
    case number
    case register
    case nop
    case cmp
    case hlt
    case jmp
    case jc
    case add
    case li
    case mov
    case identifier
}
