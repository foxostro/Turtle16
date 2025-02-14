//
//  MemoryLayoutStrategy.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/25/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

/// Abstract away platform-specific details of memory layout
public protocol MemoryLayoutStrategy {
    /// Returns the number of words needed to store the given type in memory
    func sizeof(type: SymbolType) -> Int
    
    /// The number of words to reserve in the stack frame to save registers.
    var sizeOfSaveArea: Int { get }
}
