//
//  AssemblyListingMaker.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class AssemblyListingMaker: NSObject {
    public static func makeListing(_ base: Int, _ instructions: [Instruction], _ programDebugInfo: SnapDebugInfo?) -> String {
        var previousSourceAnchor: SourceAnchor? = nil
        var previousCrackleInstruction: CrackleInstruction? = nil
        var result: String = ""
        let formattedInstructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: instructions)
        for i in 0..<formattedInstructions.count {
            let instruction = formattedInstructions[i]
            let pc = base+i
            if let sourceAnchor = programDebugInfo?.lookupSourceAnchor(pc: pc) {
                if previousSourceAnchor != sourceAnchor {
                    result += "\n# " + String(repeating: "#", count: 78)
                    let commentedSource = sourceAnchor.text.split(separator: "\n").map({"# \($0)"}).joined(separator: "\n")
                    result += "\n\(commentedSource)\n"
                }
                previousSourceAnchor = sourceAnchor
            } else if previousSourceAnchor != nil {
                result += "\n# " + String(repeating: "#", count: 78) + "\n"
                previousSourceAnchor = nil
            }
            if let crackleInstruction = programDebugInfo?.lookupCrackleInstruction(pc: pc) {
                if previousCrackleInstruction != crackleInstruction {
                    result += "\n# \(crackleInstruction.description)\n"
                }
                previousCrackleInstruction = crackleInstruction
            }
            result += (instruction.disassembly ?? instruction.description)
            if i != formattedInstructions.count-1 {
                result += "\n"
            }
        }
        return result
    }
}
