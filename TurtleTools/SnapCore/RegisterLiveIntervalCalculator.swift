//
//  RegisterLiveIntervalCalculator.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import Turtle16SimulatorCore

public class RegisterLiveIntervalCalculator: NSObject {
    public func determineLiveIntervals(_ nodes: [AbstractSyntaxTreeNode]) -> [LiveInterval] {
        var nameToRange: [String : LiveInterval] = [:]
        
        for i in 0..<nodes.count {
            let child = nodes[i]
            for name in RegisterUtils.getReferencedRegisters(child) {
                if let existing = nameToRange[name] {
                    let physicalRegisterName = getPhysicalRegisterName(existing.virtualRegisterName) ?? existing.physicalRegisterName
                    nameToRange[name] = LiveInterval(range: existing.range.startIndex..<(i+1),
                                                     virtualRegisterName: existing.virtualRegisterName,
                                                     physicalRegisterName: physicalRegisterName,
                                                     spillSlot: existing.spillSlot)
                } else {
                    nameToRange[name] = LiveInterval(range: i..<(i+1),
                                                     virtualRegisterName: name,
                                                     physicalRegisterName: getPhysicalRegisterName(name),
                                                     spillSlot: nil)
                }
            }
        }
        
        return nameToRange.values.sorted { a, b in
            if (a.range.startIndex == b.range.startIndex) {
                return getSortName(a.virtualRegisterName) < getSortName(b.virtualRegisterName)
            }
            else {
                return a.range.startIndex < b.range.startIndex
            }
        }
    }
    
    func getSortName(_ virtualRegisterName: String) -> String {
        switch virtualRegisterName {
        case "ra":
            return "r5"
            
        case "sp":
            return "r6"
            
        case "fp":
            return "r7"
            
        default:
            return virtualRegisterName
        }
    }
    
    func getPhysicalRegisterName(_ virtualRegisterName: String) -> String? {
        // The virtual register name may imply a mapping to an explicit physical
        // register which we need to guarantee. The client assumes the
        // responsibility of ensuring these mappings work. For example, using
        // r5, r6, or r7 freely in a program can be dangerous.
        let mapping = [
            "r0" : "r0",
            "r1" : "r1",
            "r2" : "r2",
            "r3" : "r3",
            "r4" : "r4",
            "r5" : "r5",
            "r6" : "r6",
            "r7" : "r7",
            "ra" : "ra",
            "sp" : "sp",
            "fp" : "fp"
        ]
        let result = mapping[virtualRegisterName]
        return result
    }
}
