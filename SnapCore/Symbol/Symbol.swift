//
//  Symbol.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class Symbol: NSObject {
    let identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public static func ==(lhs: Symbol, rhs: Symbol) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    open override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        return isBaseClassPartEqual(rhs as! Symbol)
    }
    
    public final func isBaseClassPartEqual(_ rhs: Symbol) -> Bool {
        guard identifier == rhs.identifier else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
}
