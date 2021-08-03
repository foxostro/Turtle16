//
//  SnapASTTransformerStructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerStructDeclaration: SnapASTTransformerBase {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        super.init(symbols)
    }
    
    public override func compile(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let name = node.identifier.identifier
        
        let members = SymbolTable(parent: symbols)
        let fullyQualifiedStructType = StructType(name: name, symbols: members)
        symbols!.bind(identifier: name,
                      symbolType: .structType(fullyQualifiedStructType),
                      visibility: node.visibility)
        
        members.enclosingFunctionName = name
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
        
        return nil
    }
}
