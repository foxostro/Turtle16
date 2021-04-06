//
//  ProductTermFuseMap.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// The GAL22V10 contains a 132x44 programmable interconnect array. The JEDEC
// file gives one fuse list field per row in this array, each representing one
// product term. The FuseListMap class simulates one such row.
// Each OLMC accepts a list of product terms generated in this way.
public class ProductTermFuseMap: NSObject {
    public static let numberOfTerms = 44
    let fuseList: [UInt]
    
    public convenience init(fuseListBitmap: UInt) {
        assert(fuseListBitmap <= 0b11111111111111111111111111111111111111111111)
        var fuseList: [UInt] = []
        for i in 0..<ProductTermFuseMap.numberOfTerms {
            let val: UInt = ((fuseListBitmap >> (ProductTermFuseMap.numberOfTerms - i - 1)) & 1) == 0 ? 0 : 1
            fuseList.append(val)
        }
        self.init(fuseList: fuseList)
    }
    
    public init(fuseList: [UInt]) {
        assert(fuseList.count == ProductTermFuseMap.numberOfTerms)
        self.fuseList = fuseList
    }
    
    public func evaluate(_ inputs: [UInt]) -> [UInt] {
        assert(inputs.count == 24)
        var productTerm: [UInt] = []
        for i in 1...11 {
            let input0 =  inputs[i] & 1
            let input1 = ~inputs[i] & 1
            let input2 =  inputs[24-i] & 1
            let input3 = ~inputs[24-i] & 1
            
            let index0 = (i-1)*4 + 0
            let index1 = (i-1)*4 + 1
            let index2 = (i-1)*4 + 2
            let index3 = (i-1)*4 + 3
            
            let a: UInt = ((fuseList[index0] & 1) == 0) ? input0 : 1
            let b: UInt = ((fuseList[index1] & 1) == 0) ? input1 : 1
            let c: UInt = ((fuseList[index2] & 1) == 0) ? input2 : 1
            let d: UInt = ((fuseList[index3] & 1) == 0) ? input3 : 1
            
            productTerm += [a, b, c, d]
        }
        return productTerm
    }
}
