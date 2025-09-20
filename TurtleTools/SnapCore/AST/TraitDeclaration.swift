//
//  TraitDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Declare a new trait type
public final class TraitDeclaration: AbstractSyntaxTreeNode {
    public struct Member: Hashable, CustomStringConvertible {
        public let name: String
        public let memberType: Expression

        public init(name: String, type: Expression) {
            self.name = name
            memberType = type
        }

        public var description: String {
            "\(name): \(memberType.makeIndentedDescription(depth: 1))"
        }
    }

    public let identifier: Identifier
    public let mangledName: String
    public let typeArguments: [GenericTypeArgument]
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

    public required init(
        sourceAnchor: SourceAnchor? = nil,
        identifier: Identifier,
        typeArguments: [GenericTypeArgument] = [],
        members: [Member],
        visibility: SymbolVisibility = .privateVisibility,
        mangledName: String? = nil,
        id: ID = ID()
    ) {
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
        TraitDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            typeArguments: typeArguments,
            members: members,
            visibility: visibility,
            mangledName: mangledName,
            id: id
        )
    }

    public func withMangledName(_ mangledName: String) -> TraitDeclaration {
        TraitDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            typeArguments: typeArguments,
            members: members,
            visibility: visibility,
            mangledName: mangledName,
            id: id
        )
    }

    public func eraseTypeArguments() -> TraitDeclaration {
        TraitDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            typeArguments: [],
            members: members,
            visibility: visibility,
            mangledName: mangledName,
            id: id
        )
    }

    public func withNewId() -> TraitDeclaration {
        TraitDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            typeArguments: typeArguments,
            members: members,
            visibility: visibility,
            mangledName: mangledName,
            id: ID()
        )
    }

    public func withIdentifier(_ identifier: Identifier) -> TraitDeclaration {
        TraitDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            typeArguments: typeArguments,
            members: members,
            visibility: visibility,
            mangledName: mangledName,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? TraitDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard members == rhs.members else { return false }
        guard visibility == rhs.visibility else { return false }
        guard mangledName == rhs.mangledName else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(identifier)
        hasher.combine(members)
        hasher.combine(typeArguments)
        hasher.combine(visibility)
        hasher.combine(mangledName)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace _: Bool = false
    ) -> String {
        let unindented = """
            \(visibilityDescription) trait \(name)\(typeArgumentsDescription) {\(membersDescription)
            }
            """
        let indented = indent(text: unindented, depth: depth)
        return indented
    }

    private func indent(text: String, depth: Int) -> String {
        text.split(separator: "\n")
            .map { line in
                "\(makeIndent(depth: depth))\(line)"
            }
            .joined(separator: "\n")
    }

    private var visibilityDescription: String {
        switch visibility {
        case .publicVisibility: "public"
        case .privateVisibility: "private"
        }
    }

    public var typeArgumentsDescription: String {
        guard !typeArguments.isEmpty else {
            return ""
        }

        let str = typeArguments.map { arg in
            arg.shortDescription
        }
        .joined(separator: ", ")

        return "[\(str)]"
    }

    private var membersDescription: String {
        if members.isEmpty {
            ""
        }
        else {
            "\n"
                + members
                .map { "\t\($0)" }
                .joined(separator: ",\n")
        }
    }
}
