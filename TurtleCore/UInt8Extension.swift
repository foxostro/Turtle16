//
//  UInt8Extension.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public extension UInt8 {
    func reverseBits() -> UInt8 {
        var n = self
        var result: UInt8 = 0
        while (n > 0) {
            result <<= 1
            if ((n & 1) == 1) {
                result ^= 1
            }
            n >>= 1
        }
        return result
    }
}
