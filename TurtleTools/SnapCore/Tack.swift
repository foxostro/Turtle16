//
//  Tack.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

// Program are compiled to an intermediate language called Tack
public enum TackInstruction {
    case hlt
    case call
    case callptr
    case enter
    case leave
    case ret
    case jmp
    case not
    case la
    case bz
    case bnz
    case load
    case store
    case ststr
    case memcpy
    case alloca
    case free
    case andi16
    case addi16
    case subi16
    case muli16
    case li16
    case liu16
    case and16
    case or16
    case xor16
    case neg16
    case add16
    case sub16
    case mul16
    case div16
    case mod16
    case lsl16
    case lsr16
    case eq16
    case ne16
    case lt16
    case ge16
    case le16
    case gt16
    case ltu16
    case geu16
    case leu16
    case gtu16
    case li8
    case liu8
    case and8
    case or8
    case xor8
    case neg8
    case add8
    case sub8
    case mul8
    case div8
    case mod8
    case lsl8
    case lsr8
    case eq8
    case ne8
    case lt8
    case ge8
    case le8
    case gt8
    case ltu8
    case geu8
    case leu8
    case gtu8
    case sxt8
    
    public var description: String {
        switch self {
        case .hlt: return "HLT"
        case .call: return "CALL"
        case .callptr: return "CALLPTR"
        case .enter: return "ENTER"
        case .leave: return "LEAVE"
        case .ret: return "RET"
        case .jmp: return "JMP"
        case .not: return "NOT"
        case .la: return "LA"
        case .bz: return "BZ"
        case .bnz: return "BNZ"
        case .load: return "LOAD"
        case .store: return "STORE"
        case .ststr: return "STSTR"
        case .memcpy: return "MEMCPY"
        case .alloca: return "ALLOCA"
        case .free: return "FREE"
        case .andi16: return "ANDI16"
        case .addi16: return "ADDI16"
        case .subi16: return "SUBI16"
        case .muli16: return "MULI16"
        case .li16: return "LI16"
        case .liu16: return "LIU16"
        case .and16: return "AND16"
        case .or16: return "OR16"
        case .xor16: return "XOR16"
        case .neg16: return "NEG16"
        case .add16: return "ADD16"
        case .sub16: return "SUB16"
        case .mul16: return "MUL16"
        case .div16: return "DIV16"
        case .mod16: return "MOD16"
        case .lsl16: return "LSL16"
        case .lsr16: return "LSR16"
        case .eq16: return "EQ16"
        case .ne16: return "NE16"
        case .lt16: return "LT16"
        case .ge16: return "GE16"
        case .le16: return "LE16"
        case .gt16: return "GT16"
        case .ltu16: return "LTU16"
        case .geu16: return "GEU16"
        case .leu16: return "LEU16"
        case .gtu16: return "GTU16"
        case .li8: return "LI8"
        case .liu8: return "LIU8"
        case .and8: return "AND8"
        case .or8: return "OR8"
        case .xor8: return "XOR8"
        case .neg8: return "NEG8"
        case .add8: return "ADD8"
        case .sub8: return "SUB8"
        case .mul8: return "MUL8"
        case .div8: return "DIV8"
        case .mod8: return "MOD8"
        case .lsl8: return "LSL8"
        case .lsr8: return "LSR8"
        case .eq8: return "EQ8"
        case .ne8: return "NE8"
        case .lt8: return "LT8"
        case .ge8: return "GE8"
        case .le8: return "LE8"
        case .gt8: return "GT8"
        case .ltu8: return "LTU8"
        case .geu8: return "GEU8"
        case .leu8: return "LEU8"
        case .gtu8: return "GTU8"
        case .sxt8: return "SXT8"
        }
    }
}

public class TackInstructionNode: AbstractSyntaxTreeNode {
    public let instruction: TackInstruction
    public let parameters: [Parameter]
    
    public convenience init(sourceAnchor: SourceAnchor? = nil,
                            instruction: TackInstruction,
                            parameter: Parameter) {
        self.init(sourceAnchor: sourceAnchor,
                  instruction: instruction,
                  parameters: [parameter])
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                instruction: TackInstruction,
                parameters: [Parameter] = []) {
        self.instruction = instruction
        self.parameters = parameters.map { $0.withSourceAnchor(sourceAnchor) as! Parameter }
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TackInstructionNode {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return TackInstructionNode(sourceAnchor: sourceAnchor,
                                   instruction: instruction,
                                   parameters: parameters)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? TackInstructionNode else { return false }
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
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let param = parameters.map {
            $0.makeIndentedDescription(depth: depth+1, wantsLeadingWhitespace: false)
        }.joined(separator: ", ")
        return "\(indent)\(instruction) \(param)"
    }
}
