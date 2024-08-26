//
//  StructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class StructDeclaration: AbstractSyntaxTreeNode {
    public class Member: NSObject {
        public let name: String
        public let memberType: Expression
        
        public init(name: String, type: Expression) {
            self.name = name
            self.memberType = type
        }
        
        public static func ==(lhs: Member, rhs: Member) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Member else { return false }
            guard name == rhs.name else { return false }
            guard memberType == rhs.memberType else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(name)
            hasher.combine(memberType)
            return hasher.finalize()
        }
        
        public override var description: String {
            return "\(name): \(memberType)"
        }
    }
    
    public let identifier: Expression.Identifier
    public let typeArguments: [Expression.GenericTypeArgument]
    public let members: [Member]
    public let visibility: SymbolVisibility
    public let isConst: Bool
    
    public var name: String {
        identifier.identifier
    }
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: Expression.Identifier,
                typeArguments: [Expression.GenericTypeArgument] = [],
                members: [Member],
                visibility: SymbolVisibility = .privateVisibility,
                isConst: Bool = false) {
        self.identifier = identifier.withSourceAnchor(sourceAnchor)
        self.typeArguments = typeArguments
        self.members = members.map {
            Member(name: $0.name,
                   type: $0.memberType.withSourceAnchor(sourceAnchor))
        }
        self.visibility = visibility
        self.isConst = isConst
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: typeArguments,
                          members: members,
                          visibility: visibility,
                          isConst: isConst)
    }
    
    public func eraseTypeArguments() -> StructDeclaration {
        StructDeclaration(sourceAnchor: sourceAnchor,
                          identifier: identifier,
                          typeArguments: [],
                          members: members,
                          visibility: visibility,
                          isConst: isConst)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? StructDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard members == rhs.members else { return false }
        guard visibility == rhs.visibility else { return false }
        guard isConst == rhs.isConst else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(typeArguments)
        hasher.combine(members)
        hasher.combine(visibility)
        hasher.combine(isConst)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let unindented = """
            \(visibilityDescription) struct \(name)\(typeArgumentsDescription) {\(membersDescription)
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
