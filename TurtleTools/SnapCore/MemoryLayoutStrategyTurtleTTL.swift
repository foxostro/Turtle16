//
//  MemoryLayoutStrategyTurtleTTL.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/25/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public class MemoryLayoutStrategyTurtleTTL: NSObject, MemoryLayoutStrategy {
    public func sizeof(type: SymbolType) -> Int {
        switch type {
        case .compTimeInt, .compTimeBool, .void, .function:
            return 0
        case .constU8, .u8, .bool, .constBool:
            return 1
        case .constU16, .u16:
            return 2
        case .constPointer, .pointer:
            return 2
        case .constDynamicArray(elementType: _), .dynamicArray(elementType: _), .traitType(_):
            return 4
        case .array(count: let count, elementType: let elementType):
            return (count ?? 0) * sizeof(type: elementType)
        case .constStructType(let typ), .structType(let typ):
            return sizeof(struct: typ)
        case .unionType(let typ):
            return sizeof(union: typ)
        }
    }
    
    func sizeof(struct typ: StructType) -> Int {
        var accum = 0
        for (_, symbol) in typ.symbols.symbolTable {
            accum += sizeof(type: symbol.type)
        }
        return accum
    }
    
    func sizeof(union typ: UnionType) -> Int {
        let kTagSize = sizeof(type: .u8)
        let kBufferSize = typ.members.reduce(0) { (result, memberType) -> Int in
            return max(result, sizeof(type: memberType))
        }
        return kTagSize + kBufferSize
    }
    
    public func layout(symbolTable: SymbolTable) -> SymbolTable {
        let result = SymbolTable()
        var offset = 0
        for identifier in symbolTable.declarationOrder {
            let originalSymbol = symbolTable.symbolTable[identifier]!
            let modifiedSymbol = originalSymbol
                .withOffset(offset)
                .withType(layout(type: originalSymbol.type))
            result.bind(identifier: identifier, symbol: modifiedSymbol)
            offset += sizeof(type: modifiedSymbol.type)
        }
        result.typeTable = symbolTable.typeTable
        result.parent = symbolTable.parent
        result.storagePointer = offset
        result.enclosingFunctionType = symbolTable.enclosingFunctionType
        result.enclosingFunctionName = symbolTable.enclosingFunctionName
        result.stackFrameIndex = symbolTable.stackFrameIndex
        return result
    }
    
    func layout(type originalType: SymbolType) -> SymbolType {
        let result: SymbolType
        switch originalType {
        case .structType(let typ1):
            let typ2 = layout(struct: typ1)
            result = .structType(typ2)
            
        case .constStructType(let typ1):
            let typ2 = layout(struct: typ1)
            result = .constStructType(typ2)
        
        default:
            result = originalType
        }
        return result
    }
    
    func layout(struct original: StructType) -> StructType {
        let modifiedSymbolTable = layout(symbolTable: original.symbols)
        let result = StructType(name: original.name, symbols: modifiedSymbolTable)
        return result
    }
}
