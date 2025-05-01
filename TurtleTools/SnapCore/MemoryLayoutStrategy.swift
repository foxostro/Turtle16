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

extension MemoryLayoutStrategy {
    func sizeof(struct typ: StructTypeInfo) -> Int {
        typ.fields.symbolTable.values.reduce(0) { $0 + sizeof(type: $1.type) }
    }

    func sizeof(union typ: UnionTypeInfo) -> Int {
        sizeofUnionTag + typ.members.reduce(0) { max($0, sizeof(type: $1)) }
    }

    var sizeofUnionTag: Int { sizeof(type: .u8) }
}
