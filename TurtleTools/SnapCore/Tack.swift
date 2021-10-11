//
//  Tack.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa

// Program are compiled to an intermediate language called Tack which uses
// InstructionNode, similar to the representation of an assembly program. The
// instruction operands are taken from the following list.
public struct Tack {
    public static let kCALL    = "TACK_CALL"
    public static let kCALLPTR = "TACK_CALLPTR"
    public static let kENTER   = "TACK_ENTER"
    public static let kLEAVE   = "TACK_LEAVE"
    public static let kRET     = "TACK_RET"
    public static let kJMP     = "TACK_JMP"
    public static let kNOT     = "TACK_NOT"
    public static let kLA      = "TACK_LA"
    public static let kBZ      = "TACK_BZ"
    public static let kBNZ     = "TACK_BNZ"
    public static let kLOAD    = "TACK_LOAD"
    public static let kSTORE   = "TACK_STORE"
    public static let kSTSTR   = "TACK_STSTR"
    public static let kMEMCPY  = "TACK_MEMCPY"
    public static let kALLOCA  = "TACK_ALLOCA"
    public static let kFREE    = "TACK_FREE"
    
    public static let kANDI16  = "TACK_ANDI16"
    public static let kADDI16  = "TACK_ADDI16"
    public static let kSUBI16  = "TACK_SUBI16"
    public static let kMULI16  = "TACK_MULI16"
    
    public static let kLI16    = "TACK_LI16"
    public static let kLIU16   = "TACK_LIU16"
    public static let kAND16   = "TACK_AND16"
    public static let kOR16    = "TACK_OR16"
    public static let kXOR16   = "TACK_XOR16"
    public static let kNEG16   = "TACK_NEG16"
    public static let kADD16   = "TACK_ADD16"
    public static let kSUB16   = "TACK_SUB16"
    public static let kMUL16   = "TACK_MUL16"
    public static let kDIV16   = "TACK_DIV16"
    public static let kMOD16   = "TACK_MOD16"
    public static let kLSL16   = "TACK_LSL16"
    public static let kLSR16   = "TACK_LSR16"
    public static let kEQ16    = "TACK_EQ16"
    public static let kNE16    = "TACK_NE16"
    public static let kLT16    = "TACK_LT16"
    public static let kGE16    = "TACK_GE16"
    public static let kLE16    = "TACK_LE16"
    public static let kGT16    = "TACK_GT16"
    
    public static let kLI8     = "TACK_LI8"
    public static let kAND8    = "TACK_AND8"
    public static let kOR8     = "TACK_OR8"
    public static let kXOR8    = "TACK_XOR8"
    public static let kNEG8    = "TACK_NEG8"
    public static let kADD8    = "TACK_ADD8"
    public static let kSUB8    = "TACK_SUB8"
    public static let kMUL8    = "TACK_MUL8"
    public static let kDIV8    = "TACK_DIV8"
    public static let kMOD8    = "TACK_MOD8"
    public static let kLSL8    = "TACK_LSL8"
    public static let kLSR8    = "TACK_LSR8"
    public static let kEQ8     = "TACK_EQ8"
    public static let kNE8     = "TACK_NE8"
    public static let kLT8     = "TACK_LT8"
    public static let kGE8     = "TACK_GE8"
    public static let kLE8     = "TACK_LE8"
    public static let kGT8     = "TACK_GT8"
}
