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
        case .void,
             .function,
             .genericFunction,
             .genericStructType,
             .genericTraitType,
             .label:
            0
        case let .booleanType(boolType):
            switch boolType {
            case .compTimeBool:
                0
            case .immutableBool,
                 .mutableBool:
                1
            }
        case let .arithmeticType(arithmeticType):
            switch arithmeticType {
            case .compTimeInt:
                0

            case let .mutableInt(width),
                 let .immutableInt(width):
                switch width {
                case .i8,
                     .u8:
                    1
                case .i16,
                     .u16:
                    1
                }
            }
        case .constPointer,
             .pointer:
            1
        case .constDynamicArray(elementType: _),
             .dynamicArray(elementType: _),
             .constTraitType(_),
             .traitType:
            2
        case let .array(count, elementType):
            (count ?? 0) * sizeof(type: elementType)
        case let .constStructType(typ),
             let .structType(typ):
            sizeof(struct: typ)
        case let .unionType(typ):
            sizeof(union: typ)
        }
    }

    public var sizeOfSaveArea: Int { 7 }
}
