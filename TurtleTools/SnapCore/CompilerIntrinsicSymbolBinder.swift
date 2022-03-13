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
    
    public func bindCompilerIntrinsics(symbols: SymbolTable) -> SymbolTable {
        var result: SymbolTable
        result = bindCompilerInstrinsicPeekMemory(symbols: symbols)
        result = bindCompilerInstrinsicPokeMemory(symbols: result)
        result = bindCompilerInstrinsicPeekPeripheral(symbols: result)
        result = bindCompilerInstrinsicPokePeripheral(symbols: result)
        result = bindCompilerInstrinsicHlt(symbols: result)
        result = bindCompilerIntrinsicRangeType(symbols: result)
        return result
    }
    
    func bindCompilerIntrinsicRangeType(symbols: SymbolTable) -> SymbolTable {
        let sizeOfU16 = memoryLayoutStrategy.sizeof(type: .u16)
        let name = "Range"
        let typ: SymbolType = .structType(StructType(name: name, symbols: SymbolTable(tuples: [
            ("begin", Symbol(type: .u16, offset: 0*sizeOfU16, storage: .automaticStorage)),
            ("limit", Symbol(type: .u16, offset: 1*sizeOfU16, storage: .automaticStorage))
        ])))
        symbols.bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return symbols
    }
    
    func bindCompilerInstrinsicPeekMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "peekMemory"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .u8, arguments: [.u16]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    func bindCompilerInstrinsicPokeMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "pokeMemory"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: [.u8, .u16]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    func bindCompilerInstrinsicPeekPeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "peekPeripheral"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .u8, arguments: [.u16, .u8]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    func bindCompilerInstrinsicPokePeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "pokePeripheral"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: [.u8, .u16, .u8]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    func bindCompilerInstrinsicHlt(symbols: SymbolTable) -> SymbolTable{
        let name = "hlt"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
}
