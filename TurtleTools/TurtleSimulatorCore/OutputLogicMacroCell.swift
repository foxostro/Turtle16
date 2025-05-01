//
//  OutputLogicMacroCell.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

/// Models one Output Logic Macro Cell (OLMC) in a GAL22V10.
/// The hardware OLMCs have different numbers of product terms. That constraint
/// is not validated here. This simulation will accept any number of terms.
public final class OutputLogicMacroCell {
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
        (s1 == 0) ? ((~flipFlopState) & 1) : prevResult
    }

    public struct Input {
        let inputs: [UInt?]
        let feedback: [UInt]
        let ar: UInt
        let sp: UInt

        public init(
            inputs: [UInt?],
            feedback: [UInt] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            ar: UInt = 0,
            sp: UInt = 0
        ) {
            assert(inputs.count == 24)
            assert(feedback.count == 10)
            self.inputs = inputs.map({ (val) -> UInt? in
                guard let val = val else {
                    return nil
                }
                return val & 1
            })
            self.feedback = feedback.map({ (val) -> UInt in val & 1 })
            self.ar = ar & 1
            self.sp = sp & 1
        }
    }

    public init(
        oe: ProductTermFuseMap,
        productTermFuseMaps: [ProductTermFuseMap],
        s0: UInt,
        s1: UInt
    ) {
        self.outputEnableProductTermFuseMap = oe
        self.productTermFuseMaps = productTermFuseMaps
        self.s0 = s0 & 1
        self.s1 = s1 & 1
        self.flipFlopState = 1  // I would have expected to need to reset this to zero but I have to reset to 1 to match behavior of real hardware. I'm not sure what's going on there.
    }

    public func step(_ input: Input) -> UInt? {
        let isRisingEdgeOfClock = (prevClock == 0 && input.inputs[1] != 0)
        prevClock = input.inputs[1] ?? 1

        let sumTerm: UInt = evaluateSumTerm(input)

        if input.ar == 1 {
            flipFlopState = 0
        }
        else if isRisingEdgeOfClock {
            if input.sp == 1 {
                flipFlopState = 1
            }
            else {
                flipFlopState = sumTerm
            }
        }

        let result: UInt =
            switch (s1, s0) {
            case (0, 0): (~flipFlopState) & 1
            case (0, 1): (flipFlopState) & 1
            case (1, 0): (~sumTerm) & 1
            case (1, 1): (sumTerm) & 1
            default: abort()
            }

        prevResult = result

        let oe = outputEnableProductTermFuseMap.evaluate(
            input.inputs.map({ (el) -> UInt in el ?? 1 })
        ).reduce(
            1,
            { (x, y) -> UInt in
                x & y
            }
        )
        if oe == 0 {
            return nil
        }

        return result
    }

    private func configureCombinatorialInputs(_ input: Input) -> [UInt] {
        var modified = input.inputs

        if s1 == 0 {
            // Registered pin
            // It is an error to attempt to actively, externally drive a registered output pin.
            assert(input.inputs[23] == nil)
            assert(input.inputs[22] == nil)
            assert(input.inputs[21] == nil)
            assert(input.inputs[20] == nil)
            assert(input.inputs[19] == nil)
            assert(input.inputs[18] == nil)
            assert(input.inputs[17] == nil)
            assert(input.inputs[16] == nil)
            assert(input.inputs[15] == nil)
            assert(input.inputs[14] == nil)
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
        }
        else {
            // Combinatorial pin
            modified[23] = input.inputs[23] ?? input.feedback[0]
            modified[22] = input.inputs[22] ?? input.feedback[1]
            modified[21] = input.inputs[21] ?? input.feedback[2]
            modified[20] = input.inputs[20] ?? input.feedback[3]
            modified[19] = input.inputs[19] ?? input.feedback[4]
            modified[18] = input.inputs[18] ?? input.feedback[5]
            modified[17] = input.inputs[17] ?? input.feedback[6]
            modified[16] = input.inputs[16] ?? input.feedback[7]
            modified[15] = input.inputs[15] ?? input.feedback[8]
            modified[14] = input.inputs[14] ?? input.feedback[9]
        }

        return modified.map({ (maybe) -> UInt in maybe! })
    }

    public func evaluateSumTerm(_ input: Input) -> UInt {
        productTermFuseMaps
            .map { (productTermFuseMap: ProductTermFuseMap) -> [UInt] in
                productTermFuseMap.evaluate(configureCombinatorialInputs(input))
            }
            .map { (productTerm) -> UInt in
                productTerm.reduce(1) { (x, y) -> UInt in
                    x & y
                }
            }
            .reduce(0) { (x, y) -> UInt in
                x | y
            }
    }
}
