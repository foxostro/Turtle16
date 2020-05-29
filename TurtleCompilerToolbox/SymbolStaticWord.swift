//
//  SymbolStaticWord.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

// A word-sized variable whose address is known statically at compile time.
public class SymbolStaticWord: Symbol {
    public let address: Int
    
    public init(identifier: String, address: Int) {
        self.address = address
        super.init(identifier: identifier)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        let rhs = rhs as! SymbolStaticWord
        guard isBaseClassPartEqual(rhs) else { return false }
        guard address == rhs.address else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(address)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
