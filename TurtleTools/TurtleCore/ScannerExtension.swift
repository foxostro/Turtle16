//
//  ScannerExtension.swift
//  TurtleCore
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public extension Scanner {
    func scanBinaryInt(_ result: inout Int) -> Bool {
        _ = scanString("0b")
        let binaryDigits = CharacterSet(charactersIn: "01")
        guard let string = scanCharacters(from: binaryDigits) else {
            return false
        }
        var accum = 0
        for digit in string {
            let (partialValue, overflow) = accum.addingReportingOverflow(accum)
            if overflow {
                accum = Int.max
                break
            }
            else {
                accum = partialValue
            }
            if digit == "1" {
                accum = accum + 1 // cannot overflow here
            }
        }
        result = accum
        return true
    }
}
