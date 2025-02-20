//
//  StructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Declare a new struct type
public final class StructDeclaration: AbstractSyntaxTreeNode {
    public struct Member: Hashable, CustomStringConvertible {
        public let name: String
        public let memberType: Expression
        
        public init(name: String, type: Expression) {
            self.name = name
            self.memberType = type
        }
        
        public var description: String {
            "\(name): \(memberType)"
        }
        
        public func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let result = "\(indent0)\(name): \(memberType.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: false))"
            return result
        }
        
        private func makeIndent(depth: Int) -> String {
            String(repeating: "\t", count: depth)
        }
    }
    
    public let identifier: Identifier
    public let typeArguments: [GenericTypeArgument]
    public let members: [Member]
    public let visibility: SymbolVisibility
    public let isConst: Bool
    public let associatedTraitType: String?
    
    public var name: String {
        identifier.identifier
    }
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public convenience init(_ structType: StructTypeInfo) {
        let rejectFunctions = { (ident: String, sym: Symbol) in
            switch sym.type {
            case .function, .genericFunction: false
            default: true
            }
        }
        let nonFunctionSymbols = structType.symbols.symbolTable.filter(rejectFunctions)
        
        self.init(
            identifier: Identifier(structType.name),
            members: nonFunctionSymbols.map {
                StructDeclaration.Member(
                    name: $0.key,
                    type: PrimitiveType($0.value.type))
            },
            visibility: .privateVisibility,
            isConst: false,
            associatedTraitType: structType.associatedTraitType)
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: Identifier,
                typeArguments: [GenericTypeArgument] = [],
                members: [Member],
                visibility: SymbolVisibility = .privateVisibility,
                isConst: Bool = false,
                associatedTraitType: String? = nil,
                id: ID = ID()) {
        self.identifier = identifier
        self.typeArguments = typeArguments
        self.members = members.map {
            Member(name: $0.name, type: $0.memberType)
        }
        self.visibility = visibility
        self.isConst = isConst
        self.associatedTraitType = associatedTraitType
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: typeArguments,
                          members: members,
                          visibility: visibility,
                          isConst: isConst,
                          associatedTraitType: associatedTraitType,
                          id: id)
    }
    
    public func withVisibility(_ visibility: SymbolVisibility) -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: typeArguments,
                          members: members,
                          visibility: visibility,
                          isConst: isConst,
                          associatedTraitType: associatedTraitType,
                          id: id)
    }
    
    public func eraseTypeArguments() -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: [],
                          members: members,
                          visibility: visibility,
                          isConst: isConst,
                          associatedTraitType: associatedTraitType,
                          id: id)
    }
    
    public func withIdentifier(_ identifier: Identifier) -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: typeArguments,
                          members: members,
                          visibility: visibility,
                          isConst: isConst,
                          associatedTraitType: associatedTraitType,
                          id: id)
    }
    
    public func withAssociatedTraitType(_ associatedTraitType: String?) -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: typeArguments,
                          members: members,
                          visibility: visibility,
                          isConst: isConst,
                          associatedTraitType: associatedTraitType,
                          id: id)
    }
    
    public func withNewId() -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: typeArguments,
                          members: members,
                          visibility: visibility,
                          isConst: isConst,
                          associatedTraitType: associatedTraitType,
                          id: ID())
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard identifier == rhs.identifier else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard members == rhs.members else { return false }
        guard visibility == rhs.visibility else { return false }
        guard isConst == rhs.isConst else { return false }
        guard associatedTraitType == rhs.associatedTraitType else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(identifier)
        hasher.combine(typeArguments)
        hasher.combine(members)
        hasher.combine(visibility)
        hasher.combine(isConst)
        hasher.combine(associatedTraitType)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace w: Bool = false) -> String {
        let indent0 = w ? makeIndent(depth: depth) : ""
        let result = "\(indent0)\(selfDesc)(\(visibility) \(name)\(typeArgumentsDescription))\(makeMembersDescription(depth: depth + 1))"
        return result
    }
    
    public var typeArgumentsDescription: String {
        guard !typeArguments.isEmpty else { return "" }
        
        let str = typeArguments
            .map { $0.shortDescription }
            .joined(separator: ", ")
        
        return "[\(str)]"
    }
    
    private func makeMembersDescription(depth: Int) -> String {
        guard !members.isEmpty else { return "" }
        let result = "\n" + members
            .map {
                $0.makeIndentedDescription(depth: depth, wantsLeadingWhitespace: true)
            }
            .joined(separator: ",\n")
        return result
    }
}
