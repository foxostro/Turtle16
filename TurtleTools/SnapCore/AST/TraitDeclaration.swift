//
//  TraitDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class TraitDeclaration: AbstractSyntaxTreeNode {
    public struct Member: Hashable, Equatable, CustomStringConvertible  {
        public let name: String
        public let memberType: Expression
        
        public init(name: String, type: Expression) {
            self.name = name
            self.memberType = type
        }
        
        public var description: String {
            "\(name): \(memberType)"
        }
    }
    
    public let identifier: Expression.Identifier
    public let mangledName: String
    public let typeArguments: [Expression.GenericTypeArgument]
    public let members: [Member]
    public let visibility: SymbolVisibility
    
    public var nameOfVtableType: String {
        var result = "\(mangledName)_vtable"
        if !result.hasPrefix("__") {
            result = "__" + result
        }
        return result
    }
    public var nameOfTraitObjectType: String {
        var result = "\(mangledName)_object"
        if !result.hasPrefix("__") {
            result = "__" + result
        }
        return result
    }
    
    public var name: String {
        identifier.identifier
    }
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public required init(sourceAnchor: SourceAnchor? = nil,
                         identifier: Expression.Identifier,
                         typeArguments: [Expression.GenericTypeArgument] = [],
                         members: [Member],
                         visibility: SymbolVisibility = .privateVisibility,
                         mangledName: String? = nil,
                         id: ID = ID()) {
        self.identifier = identifier
        self.typeArguments = typeArguments
        self.members = members.map {
            Member(name: $0.name, type: $0.memberType)
        }
        self.visibility = visibility
        self.mangledName = mangledName ?? identifier.identifier
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TraitDeclaration {
        TraitDeclaration(sourceAnchor: sourceAnchor,
                         identifier: identifier,
                         typeArguments: typeArguments,
                         members: members,
                         visibility: visibility,
                         mangledName: mangledName,
                         id: id)
    }
    
    public func withMangledName(_ mangledName: String) -> TraitDeclaration {
        TraitDeclaration(sourceAnchor: sourceAnchor,
                         identifier: identifier,
                         typeArguments: typeArguments,
                         members: members,
                         visibility: visibility,
                         mangledName: mangledName,
                         id: id)
    }
    
    public func eraseTypeArguments() -> TraitDeclaration {
        TraitDeclaration(sourceAnchor: sourceAnchor,
                         identifier: identifier,
                         typeArguments: [],
                         members: members,
                         visibility: visibility,
                         mangledName: mangledName,
                         id: id)
    }
    
    public func withNewId() -> TraitDeclaration {
        TraitDeclaration(sourceAnchor: sourceAnchor,
                         identifier: identifier,
                         typeArguments: typeArguments,
                         members: members,
                         visibility: visibility,
                         mangledName: mangledName,
                         id: ID())
    }
    
    public func withIdentifier(_ identifier: Expression.Identifier) -> TraitDeclaration {
        TraitDeclaration(sourceAnchor: sourceAnchor,
                         identifier: identifier,
                         typeArguments: typeArguments,
                         members: members,
                         visibility: visibility,
                         mangledName: mangledName,
                         id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? TraitDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard members == rhs.members else { return false }
        guard visibility == rhs.visibility else { return false }
        guard mangledName == rhs.mangledName else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(members)
        hasher.combine(typeArguments)
        hasher.combine(visibility)
        hasher.combine(mangledName)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let unindented = """
            \(visibilityDescription) trait \(name)\(typeArgumentsDescription) {\(membersDescription)
            }
            """
        let indented = indent(text: unindented, depth: depth)
        return indented
    }
    
    private func indent(text: String, depth: Int) -> String {
        let indentLine = makeIndent(depth: depth)
        let indented = text.split(separator: "\n").map { line in
            "\(indentLine)\(line)"
        }.joined(separator: "\n")
        return indented
    }
    
    private var visibilityDescription: String {
        switch visibility {
        case .publicVisibility:
            return "public"
        case .privateVisibility:
            return "private"
        }
    }
    
    public var typeArgumentsDescription: String {
        guard !typeArguments.isEmpty else {
            return ""
        }
        
        let str = typeArguments.map { arg in
            arg.shortDescription
        }.joined(separator: ", ")
        
        return "[\(str)]"
    }
    
    private var membersDescription: String {
        guard !members.isEmpty else {
            return ""
        }
        
        let result = "\n" + members.map { arg in
            "\t\(arg.description)"
        }.joined(separator: ",\n")
        return result
    }
}
