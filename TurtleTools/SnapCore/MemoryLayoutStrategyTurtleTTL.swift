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
        case .void, .function, .genericFunction, .genericStructType, .genericTraitType, .label:
            return 0
        case .booleanType(let boolType):
            switch boolType {
            case .compTimeBool:
                return 0
            case .immutableBool, .mutableBool:
                return 1
            }
        case .arithmeticType(let arithmeticType):
            switch arithmeticType {
            case .compTimeInt:
                return 0
            case .mutableInt(let width), .immutableInt(let width):
                switch width {
                case .i8, .u8:
                    return 1
                case .i16, .u16:
                    return 2
                }
            }
        case .constPointer, .pointer:
            return 2
        case .constDynamicArray(elementType: _), .dynamicArray(elementType: _), .constTraitType(_), .traitType(_):
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
    
    public var sizeOfSaveArea: Int { 4 }
}
