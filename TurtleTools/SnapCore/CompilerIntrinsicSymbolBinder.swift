//
//  CompilerIntrinsicSymbolBinder.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

extension SymbolTable {
    fileprivate func withCompilerInstrinsicHlt() -> SymbolTable {
        let name = "hlt"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        bind(identifier: name, symbol: symbol)
        return self
    }
    
    fileprivate func withCompilerInstrinsicSyscall() -> SymbolTable {
        let name = "__syscall"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: [
            .arithmeticType(.immutableInt(.u16)),
            .pointer(.void)
        ]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        bind(identifier: name, symbol: symbol)
        return self
    }
    
    fileprivate func withCompilerIntrinsicSliceType(_ memoryLayoutStrategy: MemoryLayoutStrategy) -> SymbolTable {
        let sizeOfU16 = memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u16)))
        let name = "Slice"
        let typ: SymbolType = .structType(StructType(name: name, symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage)),
            ("count", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: sizeOfU16, storage: .automaticStorage))
        ])))
        bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return self
    }
    
    public func withCompilerIntrinsicRangeType(_ memoryLayoutStrategy: MemoryLayoutStrategy) -> SymbolTable {
        let sizeOfU16 = memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u16)))
        let name = "Range"
        let typ: SymbolType = .structType(StructType(name: name, symbols: SymbolTable(tuples: [
            ("begin", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0*sizeOfU16, storage: .automaticStorage)),
            ("limit", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1*sizeOfU16, storage: .automaticStorage))
        ])))
        bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return self
    }
    
    public func withCompilerIntrinsics(_ memoryLayoutStrategy: MemoryLayoutStrategy) -> SymbolTable {
        self.withCompilerInstrinsicHlt()
            .withCompilerInstrinsicSyscall()
            .withCompilerIntrinsicSliceType(memoryLayoutStrategy)
            .withCompilerIntrinsicRangeType(memoryLayoutStrategy)
    }
}
