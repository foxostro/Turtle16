//
//  SnapSubcompilerStructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerStructDeclaration: NSObject {
    public private(set) var symbols: SymbolTable? = nil
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable) {
        self.symbols = symbols
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(_ node: StructDeclaration) throws -> StructDeclaration? {
        let name = node.identifier.identifier
        
        let members = SymbolTable(parent: symbols)
        let fullyQualifiedStructType = StructType(name: name, symbols: members)
        symbols!.bind(identifier: name,
                      symbolType: node.isConst ? .constStructType(fullyQualifiedStructType) : .structType(fullyQualifiedStructType),
                      visibility: node.visibility)
        
        members.enclosingFunctionNameMode = .set(name)
        for memberDeclaration in node.members {
            let memberType = try TypeContextTypeChecker(symbols: members).check(expression: memberDeclaration.memberType)
            if memberType == .structType(fullyQualifiedStructType) || memberType == .constStructType(fullyQualifiedStructType) {
                throw CompilerError(sourceAnchor: memberDeclaration.memberType.sourceAnchor, message: "a struct cannot contain itself recursively")
            }
            let symbol = Symbol(type: memberType, offset: members.storagePointer, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            members.storagePointer += sizeOfMemberType
        }
        members.parent = nil
        
        return nil // Erase the StructDeclaration now that it's been processd.
    }
}
