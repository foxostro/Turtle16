//
//  MemoryLayoutStrategyTurtleTTL.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/25/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public struct MemoryLayoutStrategyTurtleTTL: MemoryLayoutStrategy {
    public init() {}
    
    public func sizeof(type: SymbolType) -> Int {
        switch type {
        case .void, .function, .genericFunction, .genericStructType, .genericTraitType, .label:
            0
        case .booleanType(let boolType):
            switch boolType {
            case .compTimeBool:
                0
            case .immutableBool, .mutableBool:
                1
            }
        case .arithmeticType(let arithmeticType):
            switch arithmeticType {
            case .compTimeInt:
                0
            case .mutableInt(let width), .immutableInt(let width):
                switch width {
                case .i8, .u8:
                    1
                case .i16, .u16:
                    2
                }
            }
        case .constPointer, .pointer:
            2
        case .constDynamicArray(elementType: _), .dynamicArray(elementType: _), .constTraitType(_), .traitType(_):
            4
        case .array(count: let count, elementType: let elementType):
            (count ?? 0) * sizeof(type: elementType)
        case .constStructType(let typ), .structType(let typ):
            sizeof(struct: typ)
        case .unionType(let typ):
            sizeof(union: typ)
        }
    }
    
    public var sizeOfSaveArea: Int { 4 }
}
