//
//  CompilerTemporariesStack.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CompilerTemporariesStack: NSObject {
    private var stack: [CompilerTemporary] = []
    
    public func push(_ temporary: CompilerTemporary) {
        stack.append(temporary)
    }
    
    public func peek() -> CompilerTemporary {
        return stack.last!
    }
    
    public func pop() -> CompilerTemporary {
        return stack.popLast()!
    }
    
    public var isEmpty: Bool {
        return stack.isEmpty
    }
}
