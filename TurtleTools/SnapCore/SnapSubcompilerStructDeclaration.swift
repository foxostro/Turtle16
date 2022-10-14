//
//  SnapSubcompilerStructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerStructDeclaration: NSObject {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public let symbols: SymbolTable
    public let functionsToCompile: FunctionsToCompile
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy,
                symbols: SymbolTable,
                functionsToCompile: FunctionsToCompile) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.symbols = symbols
        self.functionsToCompile = functionsToCompile
    }
    
    public func compile(_ node: StructDeclaration) throws {
        let name = node.identifier.identifier
        
        let members = SymbolTable(parent: symbols)
        let fullyQualifiedStructType = StructType(name: name, symbols: members)
        symbols.bind(identifier: name,
                     symbolType: node.isConst ? .constStructType(fullyQualifiedStructType) : .structType(fullyQualifiedStructType),
                     visibility: node.visibility)
        
        members.enclosingFunctionNameMode = .set(name)
        for memberDeclaration in node.members {
            let memberType = try TypeContextTypeChecker(symbols: members, functionsToCompile: functionsToCompile).check(expression: memberDeclaration.memberType)
            if memberType == .structType(fullyQualifiedStructType) || memberType == .constStructType(fullyQualifiedStructType) {
                throw CompilerError(sourceAnchor: memberDeclaration.memberType.sourceAnchor, message: "a struct cannot contain itself recursively")
            }
            let symbol = Symbol(type: memberType, offset: members.storagePointer, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            members.storagePointer += sizeOfMemberType
        }
        members.parent = nil
        
        // Erase the StructDeclaration now that it's been processd.
    }
}
