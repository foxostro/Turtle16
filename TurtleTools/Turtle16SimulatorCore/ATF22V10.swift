//
//  ATF22V10.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// The ATF22V10 contains a 132x44 programmable interconnect array.
// The ProgrammableLogicInterconnect class simulates this array.
// This produces lists of product terms for the OLMCs.
public class ATF22V10: NSObject {
    public static let numberOfProductTerms = 132
    public static let sizeOfProductTerm = 44
    public static let numberOfInputPins = 11
    public let outputLogicMacroCells: [OutputLogicMacroCell]
    public let signature: [UInt]
    
    public init(fuseList: [UInt]) {
        assert(fuseList.count == 5892)
        
        // Each OLMC's OE product term is based at the corresponding index in this list.
        let outputEnableProductTermFuseMapDefns = [
              44,
             440,
             924,
            1496,
            2156,
            2904,
            3652,
            4312,
            4884,
            5368
        ]
        let outputEnableProductTermFuseMaps: [ProductTermFuseMap] = ATF22V10.makeSingleProductTerms(outputEnableProductTermFuseMapDefns, fuseList)
        
        // A list of tuples, each containing 1) the index of the first fuse for
        // the OLMC, and 2) the number of product terms for this OLMC. This
        // information comes from five of the Lattice 22V10C datasheet.
        let logicProductTermFuseMapDefns = [
            (  44+44,  8),
            ( 440+44, 10),
            ( 924+44, 12),
            (1496+44, 14),
            (2156+44, 16),
            (2904+44, 16),
            (3652+44, 14),
            (4312+44, 12),
            (4884+44, 10),
            (5368+44,  8)
        ]
        let logicProductTermFuseMaps: [[ProductTermFuseMap]] = ATF22V10.makeProductTerms(logicProductTermFuseMapDefns, fuseList)
        
        outputLogicMacroCells = [
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[0],
                                 productTermFuseMaps: logicProductTermFuseMaps[0],
                                 s0: fuseList[5808],
                                 s1: fuseList[5809]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[1],
                                 productTermFuseMaps: logicProductTermFuseMaps[1],
                                 s0: fuseList[5810],
                                 s1: fuseList[5811]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[2],
                                 productTermFuseMaps: logicProductTermFuseMaps[2],
                                 s0: fuseList[5812],
                                 s1: fuseList[5813]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[3],
                                 productTermFuseMaps: logicProductTermFuseMaps[3],
                                 s0: fuseList[5814],
                                 s1: fuseList[5815]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[4],
                                 productTermFuseMaps: logicProductTermFuseMaps[4],
                                 s0: fuseList[5816],
                                 s1: fuseList[5817]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[5],
                                 productTermFuseMaps: logicProductTermFuseMaps[5],
                                 s0: fuseList[5818],
                                 s1: fuseList[5819]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[6],
                                 productTermFuseMaps: logicProductTermFuseMaps[6],
                                 s0: fuseList[5820],
                                 s1: fuseList[5821]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[7],
                                 productTermFuseMaps: logicProductTermFuseMaps[7],
                                 s0: fuseList[5822],
                                 s1: fuseList[5823]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[8],
                                 productTermFuseMaps: logicProductTermFuseMaps[8],
                                 s0: fuseList[5824],
                                 s1: fuseList[5825]),
            OutputLogicMacroCell(oe: outputEnableProductTermFuseMaps[9],
                                 productTermFuseMaps: logicProductTermFuseMaps[9],
                                 s0: fuseList[5826],
                                 s1: fuseList[5827])
        ]
        signature = Array<UInt>(fuseList[5828..<5892])
    }
    
    fileprivate static func makeSingleProductTerms(_ defs: [Int], _ fuseList: [UInt]) -> [ProductTermFuseMap] {
        ATF22V10.makeProductTerms(defs.map({ (begin) -> (Int, Int) in
            (begin, 1)
        }), fuseList).map { (maps: [ProductTermFuseMap]) -> ProductTermFuseMap in
            maps.first!
        }
    }
    
    fileprivate static func makeProductTerms(_ defs: [(Int, Int)], _ fuseList: [UInt]) -> [[ProductTermFuseMap]] {
        return defs.map({ (begin, n) -> Range<Int> in
            let a = begin / ATF22V10.sizeOfProductTerm
            return a..<(a+n)
        }).map({ (range) -> [ProductTermFuseMap] in
            range.map({ (i: Int) -> ProductTermFuseMap in
                ProductTermFuseMap(fuseList: Array<UInt>(fuseList[(i+0)*ATF22V10.sizeOfProductTerm..<((i+1)*ATF22V10.sizeOfProductTerm)]))
            })
        })
    }
    
    public func step(inputs: [UInt]) -> [UInt?] {
        let feedback = outputLogicMacroCells.map({ (olmc) -> UInt in olmc.feedback })
        return outputLogicMacroCells.map({(olmc) -> UInt? in
            olmc.step(OutputLogicMacroCell.Input(inputs: inputs, feedback: feedback))
        })
    }
}
