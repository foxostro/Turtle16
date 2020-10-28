//
//  CrackleBasicBlock.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CrackleBasicBlock: NSObject {
    public var instructions: [CrackleInstruction] = []
    public var mapCrackleInstructionToSource: [SourceAnchor?] = []
    public var mapCrackleInstructionToSymbols: [SymbolTable?] = []
    
    public func copy() -> CrackleBasicBlock {
        let theCopy = CrackleBasicBlock()
        theCopy.instructions = instructions
        theCopy.mapCrackleInstructionToSource = mapCrackleInstructionToSource
        theCopy.mapCrackleInstructionToSymbols = mapCrackleInstructionToSymbols
        return theCopy
    }
    
    public static func ==(lhs: CrackleBasicBlock, rhs: CrackleBasicBlock) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    open override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? CrackleBasicBlock else {
            return false
        }
        guard instructions == rhs.instructions else {
            return false
        }
        guard mapCrackleInstructionToSource == rhs.mapCrackleInstructionToSource else {
            return false
        }
        guard mapCrackleInstructionToSymbols == rhs.mapCrackleInstructionToSymbols else {
            return false
        }
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(instructions)
        hasher.combine(mapCrackleInstructionToSource)
        hasher.combine(mapCrackleInstructionToSymbols)
        return hasher.finalize()
    }
}
