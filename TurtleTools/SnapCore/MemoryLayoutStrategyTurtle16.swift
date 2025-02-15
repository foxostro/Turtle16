//
//  MemoryLayoutStrategyTurtle16.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public struct MemoryLayoutStrategyTurtle16: MemoryLayoutStrategy {
    public init() {}
    
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
                    return 1
                }
            }
        case .constPointer, .pointer:
            return 1
        case .constDynamicArray(elementType: _), .dynamicArray(elementType: _), .constTraitType(_), .traitType(_):
            return 2
        case .array(count: let count, elementType: let elementType):
            return (count ?? 0) * sizeof(type: elementType)
        case .constStructType(let typ), .structType(let typ):
            return sizeof(struct: typ)
        case .unionType(let typ):
            return sizeof(union: typ)
        }
    }
    
    private func sizeof(struct typ: StructTypeInfo) -> Int {
        var accum = 0
        for (_, symbol) in typ.symbols.symbolTable {
            accum += sizeof(type: symbol.type)
        }
        return accum
    }
    
    private func sizeof(union typ: UnionTypeInfo) -> Int {
        let kTagSize = sizeof(type: .u8)
        let kBufferSize = typ.members.reduce(0) { (result, memberType) -> Int in
            return max(result, sizeof(type: memberType))
        }
        return kTagSize + kBufferSize
    }
    
    public var sizeOfSaveArea: Int { 7 }
}
