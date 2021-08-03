//
//  MemoryLayoutStrategy.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/25/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public protocol MemoryLayoutStrategy: NSObject {
    var staticStorageOffset: Int { get set }
    func sizeof(type: SymbolType) -> Int
    func layout(symbolTable: SymbolTable) -> SymbolTable
}
