//
//  SymbolConstantWord.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class SymbolConstantWord: Symbol {
    public let value: UInt8
    
    public init(identifier: String, value: UInt8) {
        self.value = value
        super.init(identifier: identifier)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        let rhs = rhs as! SymbolConstantWord
        guard isBaseClassPartEqual(rhs) else { return false }
        guard value == rhs.value else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(value)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
