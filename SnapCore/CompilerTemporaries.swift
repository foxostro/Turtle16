//
//  CompilerTemporaries.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/12/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CompilerTemporaries: NSObject {
    public class Temporary: NSObject {
        public let address: Int
        public var refCount = 0
        
        init(address: Int) {
            self.address = address
        }
        
        public func consume() {
            assert(refCount > 0)
            refCount -= 1
        }
        
        public override var debugDescription: String {
            let addressString = String(format: "0x%04x", address)
            return "<\(type(of: self)): address=\(addressString), refCount=\(refCount)>"
        }
    }
    
    let temporaries: [Temporary]
    var temporaryStack: [Temporary] = []
    
    public func push(_ temporary: Temporary) {
        temporaryStack.append(temporary)
    }
    
    public func pop() -> Temporary {
        return temporaryStack.popLast()!
    }
    
    public func allocate() -> Temporary {
        for temporary in temporaries {
            if temporary.refCount == 0 {
                temporary.refCount = 1
                return temporary
            }
        }
        abort() // TODO: need to throw a nice compiler error here
    }
    
    public override init() {
        var temporaries: [Temporary] = []
        let limit = SnapToCrackleCompiler.kTemporaryStorageStartAddress + SnapToCrackleCompiler.kTemporaryStorageLength
        var address = SnapToCrackleCompiler.kTemporaryStorageStartAddress
        while address < limit {
            temporaries.append(Temporary(address: address))
            address += 2
        }
        self.temporaries = temporaries
    }
}
