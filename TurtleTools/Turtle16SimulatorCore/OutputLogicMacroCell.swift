//
//  OutputLogicMacroCell.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// Models one Output Logic Macro Cell (OLMC) in a GAL22V10.
// The hardware OLMCs have different numbers of product terms. That constraint
// is not validated here. This simulation will accept any number of terms.
public class OutputLogicMacroCell: NSObject {
    public let outputEnableProductTermFuseMap: ProductTermFuseMap
    public let productTermFuseMaps: [ProductTermFuseMap]
    public let s0: UInt
    public let s1: UInt
    var prevResult: UInt = 0
    var prevClock: UInt = 0
    public private(set) var flipFlopState: UInt
    
    // The feedback bit for a registered output is the inverted flip flop state.
    // The feedback bit for a combinatorial output is the current state of the pin.
    public var feedback: UInt {
        return (s1 == 0) ? ((~flipFlopState)&1) : prevResult
    }
    
    public struct Input {
        let inputs: [UInt]
        let feedback: [UInt]
        let ar: UInt
        let sp: UInt
        
        public init(inputs: [UInt], feedback: [UInt] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], ar: UInt = 0, sp: UInt = 0) {
            assert(inputs.count == 24)
            assert(feedback.count == 10)
            self.inputs = inputs.map({ (val) -> UInt in val & 1 })
            self.feedback = feedback.map({ (val) -> UInt in val & 1 })
            self.ar = ar & 1
            self.sp = sp & 1
        }
    }
    
    public init(oe: ProductTermFuseMap,
                productTermFuseMaps: [ProductTermFuseMap],
                s0: UInt,
                s1: UInt) {
        self.outputEnableProductTermFuseMap = oe
        self.productTermFuseMaps = productTermFuseMaps
        self.s0 = s0 & 1
        self.s1 = s1 & 1
        self.flipFlopState = 1 // I would have expected to need to reset this to zero but I have to reset to 1 to match behavior of real hardware. I'm not sure what's going on there.
    }
    
    public func step(_ input: Input) -> UInt? {
        let isRisingEdgeOfClock = (prevClock == 0 && input.inputs[1] != 0)
        prevClock = input.inputs[1]
        
        let sumTerm: UInt = evaluateSumTerm(input)
        
        if input.ar == 1 {
            flipFlopState = 0
        } else if isRisingEdgeOfClock {
            if input.sp == 1 {
                flipFlopState = 1
            } else {
                flipFlopState = sumTerm
            }
        }
        
        let result: UInt
        switch (s1, s0) {
        case (0, 0): result = (~flipFlopState) & 1
        case (0, 1): result = ( flipFlopState) & 1
        case (1, 0): result = (~sumTerm) & 1
        case (1, 1): result = ( sumTerm) & 1
        default: abort()
        }
        
        prevResult = result
        
        let oe = outputEnableProductTermFuseMap.evaluate(input.inputs).reduce(1, { (x, y) -> UInt in
            x & y
        })
        if oe == 0 {
            return nil
        }
        
        return result
    }
    
    fileprivate func configureCombinatorialInputs(_ input: Input) -> [UInt] {
        // This doesn't really support the dynamic I/O configuration of the
        // GAL very well, but that's not an issue right now.
        
        if s1 == 0 {
            var modified = input.inputs
            modified[23] = input.feedback[0] & 1
            modified[22] = input.feedback[1] & 1
            modified[21] = input.feedback[2] & 1
            modified[20] = input.feedback[3] & 1
            modified[19] = input.feedback[4] & 1
            modified[18] = input.feedback[5] & 1
            modified[17] = input.feedback[6] & 1
            modified[16] = input.feedback[7] & 1
            modified[15] = input.feedback[8] & 1
            modified[14] = input.feedback[9] & 1
            return modified
        }
        
        return input.inputs
    }
    
    public func evaluateSumTerm(_ input: Input) -> UInt {
        return productTermFuseMaps.map({ (productTermFuseMap: ProductTermFuseMap) -> [UInt] in
            productTermFuseMap.evaluate(configureCombinatorialInputs(input))
        }).map({ (productTerm) -> UInt in
            productTerm.reduce(1, { (x, y) -> UInt in
                x & y
            })
        }).reduce(0, { (x, y) -> UInt in
            x | y
        })
    }
}
