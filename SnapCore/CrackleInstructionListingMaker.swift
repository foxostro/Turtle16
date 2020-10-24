//
//  CrackleInstructionListingMaker.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CrackleInstructionListingMaker: NSObject {
    public static func makeListing(instructions: [CrackleInstruction], programDebugInfo: SnapDebugInfo?) -> String {
        var previousSourceContext: SourceAnchor? = nil
        var result = ""
        for i in 0..<instructions.count {
            let sourceContext = programDebugInfo?.lookupSourceAnchor(crackleInstructionIndex: i)?.split().first
            if (sourceContext != nil) && ((previousSourceContext == nil) || previousSourceContext!.context != sourceContext!.context) {
                if (previousSourceContext != nil) {
                    result += "\n"
                }
                result += sourceContext!.text.split(separator: "\n").map({"# " + $0}).joined(separator: "\n")
                result += "\n"
            }
            result += instructions[i].description
            if i != instructions.count-1 {
                result += "\n"
            }
            previousSourceContext = sourceContext
        }
        return result
    }
}
