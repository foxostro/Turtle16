//
//  CompilerIntrinsicSymbolBinder.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public class CompilerIntrinsicSymbolBinder: NSObject {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func bindCompilerIntrinsics(symbols symbols0: SymbolTable) -> SymbolTable {
        let symbols1 = bindCompilerInstrinsicHlt(symbols: symbols0)
        let symbols2 = bindCompilerInstrinsicSyscall(symbols: symbols1)
        let symbols3 = bindCompilerIntrinsicRangeType(symbols: symbols2)
        let symbols4 = bindCompilerIntrinsicSliceType(symbols: symbols3)
        return symbols4
    }
    
    func bindCompilerIntrinsicSliceType(symbols: SymbolTable) -> SymbolTable {
        let sizeOfU16 = memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u16)))
        let name = "Slice"
        let typ: SymbolType = .structType(StructType(name: name, symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0, storage: .automaticStorage)),
            ("count", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: sizeOfU16, storage: .automaticStorage))
        ])))
        symbols.bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return symbols
    }
    
    func bindCompilerIntrinsicRangeType(symbols: SymbolTable) -> SymbolTable {
        let sizeOfU16 = memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u16)))
        let name = "Range"
        let typ: SymbolType = .structType(StructType(name: name, symbols: SymbolTable(tuples: [
            ("begin", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0*sizeOfU16, storage: .automaticStorage)),
            ("limit", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 1*sizeOfU16, storage: .automaticStorage))
        ])))
        symbols.bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return symbols
    }
    
    func bindCompilerInstrinsicHlt(symbols: SymbolTable) -> SymbolTable {
        let name = "hlt"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    func bindCompilerInstrinsicSyscall(symbols: SymbolTable) -> SymbolTable {
        let name = "__syscall"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: [
            .arithmeticType(.immutableInt(.u16)),
            .pointer(.void)
        ]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
}
