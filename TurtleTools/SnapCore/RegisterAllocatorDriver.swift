//
//  RegisterAllocatorDriver.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/23/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import Turtle16SimulatorCore

// Rewrites the program to use physical register names instead of virtual.
// Inserts code to load and store values when a register must spill.
public class RegisterAllocatorDriver: NSObject {
    let kNumberOfFreelyAllocatableRegisters: Int
    
    public init(numRegisters: Int = 5  /* a default value appropriate to Turtle16 */) {
        kNumberOfFreelyAllocatableRegisters = numRegisters
    }
    
    public func compile(topLevel topLevel0: TopLevel) throws -> TopLevel {
        let children1 = try compile(children: topLevel0.children)
        let topLevel1 = TopLevel(sourceAnchor: topLevel0.sourceAnchor, children: children1)
        let children2 = try iterateSubroutineNodes(topLevel1.children) { subroutine in
            Subroutine(sourceAnchor: subroutine.sourceAnchor,
                       children: try compile(children: subroutine.children))
        }
        let topLevel2 = TopLevel(sourceAnchor: topLevel1.sourceAnchor, children: children2)
        return topLevel2
    }
    
    func iterateSubroutineNodes(_ nodes: [AbstractSyntaxTreeNode], _ block: (Subroutine) throws -> Subroutine) throws -> [AbstractSyntaxTreeNode] {
        var children : [AbstractSyntaxTreeNode] = []
        for child in nodes {
            let result: AbstractSyntaxTreeNode
            
            switch child {
            case let subroutineNode as Subroutine:
                result = try block(subroutineNode)
            default:
                result = child
            }
            
            children.append(result)
        }
        return children
    }
    
    public func compile(children children0: [AbstractSyntaxTreeNode]) throws -> [AbstractSyntaxTreeNode] {
        var registerPool = Array(0..<kNumberOfFreelyAllocatableRegisters)
        var temporaries: [Int] = []
        var children: [AbstractSyntaxTreeNode] = children0
        var allocations: [LiveInterval]
        var done = false
        
        repeat {
            let numRegisters = (registerPool.last ?? -1) + 1
            allocations = allocateRegisters(numRegisters, determineLiveIntervals(children))
            let spilledIntervals = allocations.filter { $0.physicalRegisterName == nil }
            let spillResult = RegisterSpiller.spill(spilledIntervals: spilledIntervals,
                                                    temporaries: temporaries,
                                                    nodes: children)
            switch spillResult {
            case .success(let r):
                children = r
                done = true
                
            case .failure(.outOfTemporaries):
                guard !registerPool.isEmpty else {
                    throw CompilerError(sourceAnchor: children0.first?.sourceAnchor,
                                        message: "Register allocation failed: insufficient physical registers")
                }
                temporaries.append(registerPool.removeLast())
                
            case .failure(let e):
                throw CompilerError(sourceAnchor: children0.first?.sourceAnchor,
                                    message: "Register allocation failed: \(e.description)")
            }
        } while(!done)

        children = compile(children: children, liveIntervals: allocations)
        return children
    }
    
    func determineLiveIntervals(_ nodes: [AbstractSyntaxTreeNode]) -> [LiveInterval] {
        return RegisterLiveIntervalCalculator().determineLiveIntervals(nodes)
    }
    
    func allocateRegisters(_ numRegisters: Int, _ liveIntervals: [LiveInterval]) -> [LiveInterval] {
        return LinearScanRegisterAllocator.allocate(numRegisters: numRegisters, liveIntervals: liveIntervals)
    }

    func compile(children: [AbstractSyntaxTreeNode], liveIntervals: [LiveInterval]) -> [AbstractSyntaxTreeNode] {
        let children = iterateInstructionNodes(children) { index, instructionNode in
            return compile(index, instructionNode, liveIntervals)
        }
        return children
    }
    
    func iterateInstructionNodes(_ nodes: [AbstractSyntaxTreeNode], _ block: (Int, InstructionNode) -> InstructionNode) -> [AbstractSyntaxTreeNode] {
        var children : [AbstractSyntaxTreeNode] = []
        for child in nodes {
            let result: AbstractSyntaxTreeNode
            
            switch child {
            case let instructionNode as InstructionNode:
                result = block(children.count, instructionNode)
            default:
                result = child
            }
            
            children.append(result)
        }
        return children
    }
    
    func compile(_ index: Int, _ node: InstructionNode, _ liveIntervals: [LiveInterval]) -> InstructionNode {
        // TODO: rewrite in terms of RegisterUtils.rewrite()
        switch node.instruction {
        case kLOAD, kSTORE, kLI, kLIU, kLUI, kCMP, kADD, kSUB, kAND, kOR, kXOR, kNOT, kCMPI, kADDI, kSUBI, kANDI, kORI, kXORI, kJR, kJALR, kADC, kSBC, kCALLPTR:
            return InstructionNode(sourceAnchor: node.sourceAnchor,
                                   instruction: node.instruction,
                                   parameters: node.parameters.map { rewriteRegisterIdentifier($0, index, liveIntervals) })
            
        case kLA:
            var parameters = node.parameters
            parameters[0] = rewriteRegisterIdentifier(parameters[0], index, liveIntervals)
            return InstructionNode(sourceAnchor: node.sourceAnchor,
                                   instruction: node.instruction,
                                   parameters: parameters)
            
        default:
            return node
        }
    }
    
    func rewriteRegisterIdentifier(_ param: Parameter, _ index: Int, _ liveIntervals: [LiveInterval]) -> Parameter {
        guard let ident = param as? ParameterIdentifier,
              let rewritten = lookup(ident.value, index, liveIntervals) else {
            return param
        }
        return ParameterIdentifier(sourceAnchor: param.sourceAnchor, value: rewritten)
    }
    
    func lookup(_ virtualRegisterName: String, _ index: Int, _ liveIntervals: [LiveInterval]) -> String? {
        return liveIntervals.first(where: {
            ($0.virtualRegisterName == virtualRegisterName) && $0.range.contains(index)
        })?.physicalRegisterName
    }
}
