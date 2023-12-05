//
//  RegisterSpiller.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public class RegisterSpiller: NSObject {
    public enum SpillError : Error {
        case missingLeadingEnter
        case missingSpillSlot
        case outOfTemporaries
        
        public var description: String {
            switch self {
            case .missingLeadingEnter:
                return "missing leading enter"
                
            case .missingSpillSlot:
                return "missing spill slot"
                
            case .outOfTemporaries:
                return "out of temporaries"
            }
        }
    }
    
    public static func spill(spilledIntervals: [LiveInterval], temporaries temporaries0: [Int], nodes nodes0: [AbstractSyntaxTreeNode]) -> Result<[AbstractSyntaxTreeNode], SpillError> {
        guard spilledIntervals.count > 0 else {
            // If there are no spilled intervals then we can return early.
            return .success(nodes0)
        }
        
        let fp = ParameterIdentifier("fp")
        let ra = ParameterIdentifier("ra")
        
        // Reserve memory for spills by updating the leading ENTER instruction.
        var nodes1 = nodes0
        var spillSlotOffset = 0
        if spilledIntervals.count > 0 {
            guard let oldEnter = nodes1.first as? InstructionNode, oldEnter.instruction == kENTER else {
                return .failure(.missingLeadingEnter)
            }
            
            let oldSizeOnEnter = (oldEnter.parameters.first as? ParameterNumber)?.value ?? 0
            spillSlotOffset += oldSizeOnEnter
            let maxSpillSlot = spilledIntervals.compactMap({ $0.spillSlot }).max() ?? 0
            let updatedSizeOnEnter = oldSizeOnEnter + maxSpillSlot + 1
            
            nodes1[0] = InstructionNode(sourceAnchor: oldEnter.sourceAnchor,
                                        instruction: oldEnter.instruction,
                                        parameter: ParameterNumber(updatedSizeOnEnter))
        }
        
        // Rewrite nodes to replace spilled virtual registers with a reserved
        // spill register. Insert code to load and store the reserved spill
        // registers before and after the instruction, respectively.
        var nodes2: [AbstractSyntaxTreeNode] = []
        for i in 0..<nodes1.count {
            var currentInstruction = nodes1[i]
            var temporaries = temporaries0
            var prefix: [AbstractSyntaxTreeNode] = []
            var postfix: [AbstractSyntaxTreeNode] = []
            
            // For each interval which is active at this point in the program.
            let active: [LiveInterval] = spilledIntervals.filter { $0.range.contains(i) }
            for spilledInterval in active {
                // cannot spill an interval without a spill slot
                guard let spillSlot = spilledInterval.spillSlot else {
                    return .failure(.missingSpillSlot)
                }
                
                let mustLoad = RegisterUtils.getSourceRegisters(currentInstruction).contains(spilledInterval.virtualRegisterName)
                let mustStore = RegisterUtils.getDestinationRegisters(currentInstruction).contains(spilledInterval.virtualRegisterName)
                
                // If we must replace a source operand with a reserved spill
                // register then we need to rewrite the instruction and insert
                // a load instruction above.
                if mustLoad {
                    // If the client hasn't provided enough reserved spill
                    // registers then we must fail right here.
                    guard let temporary = temporaries.first else {
                        return .failure(.outOfTemporaries)
                    }
                    let tempReg = ParameterIdentifier("r\(temporary)")
                    _ = temporaries.removeFirst()
                    currentInstruction = RegisterUtils.rewrite(node: currentInstruction, from: spilledInterval.virtualRegisterName, to: tempReg.value)
                    let offset = -(spillSlotOffset + spillSlot + 1)
                    let spillLoadCode: [AbstractSyntaxTreeNode]
                    if offset > 15 || offset < -16 {
                        spillLoadCode = [
                            InstructionNode(instruction: kLI, parameters: [ra, ParameterNumber(offset & 0x00ff)]),
                            InstructionNode(instruction: kLUI, parameters: [ra, ParameterNumber((offset & 0xff) >> 8)]),
                            InstructionNode(instruction: kADD, parameters: [ra, ra, fp]),
                            InstructionNode(instruction: kLOAD, parameters: [tempReg, ra]),
                        ]
                    } else {
                        spillLoadCode = [
                            InstructionNode(instruction: kLOAD, parameters: [tempReg, fp, ParameterNumber(offset)])
                        ]
                    }
                    prefix = prefix + spillLoadCode
                }
                
                // If we must replace a destination with a reserved spill
                // register then we need to rewrite the instruction and insert
                // a store instruction below.
                if mustStore {
                    // If the client hasn't provided enough reserved spill
                    // registers then we must fail right here.
                    guard let temporary = temporaries0.first else {
                        return .failure(.outOfTemporaries)
                    }
                    let tempReg = ParameterIdentifier("r\(temporary)")
                    currentInstruction = RegisterUtils.rewrite(node: currentInstruction, from: spilledInterval.virtualRegisterName, to: tempReg.value)
                    let offset = -(spillSlotOffset + spillSlot + 1)
                    let spillStoreCode: [AbstractSyntaxTreeNode]
                    if offset > 15 || offset < -16 {
                        spillStoreCode = [
                            InstructionNode(instruction: kLI, parameters: [ra, ParameterNumber(offset & 0x00ff)]),
                            InstructionNode(instruction: kLUI, parameters: [ra, ParameterNumber((offset & 0xff) >> 8)]),
                            InstructionNode(instruction: kADD, parameters: [ra, ra, fp]),
                            InstructionNode(instruction: kSTORE, parameters: [tempReg, ra]),
                        ]
                    } else {
                        spillStoreCode = [
                            InstructionNode(instruction: kSTORE, parameters: [tempReg, fp, ParameterNumber(offset)])
                        ]
                    }
                    postfix = spillStoreCode + postfix
                }
            }
            
            nodes2 += prefix + [currentInstruction] + postfix
        }
        
        return .success(nodes2)
    }
}
