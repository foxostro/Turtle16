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
    public let members: [Member]
    public let visibility: SymbolVisibility
    public let isConst: Bool
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: Expression.Identifier,
                members: [Member],
                visibility: SymbolVisibility = .privateVisibility,
                isConst: Bool = false) {
        self.identifier = identifier.withSourceAnchor(sourceAnchor)
        self.members = members.map {
            Member(name: $0.name,
                   type: $0.memberType.withSourceAnchor(sourceAnchor))
        }
        self.visibility = visibility
        self.isConst = isConst
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> StructDeclaration {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return StructDeclaration(sourceAnchor: sourceAnchor,
                                 identifier: identifier,
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
        guard members == rhs.members else { return false }
        guard visibility == rhs.visibility else { return false }
        guard isConst == rhs.isConst else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(members)
        hasher.combine(visibility)
        hasher.combine(isConst)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@identifier: %@\n%@visibility: %@\n%@members: %@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      (isConst ? "const " : "") + String(describing: type(of: self)),
                      makeIndent(depth: depth + 1),
                      identifier.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      visibility.description,
                      makeIndent(depth: depth + 1),
                      makeMembersDescription(depth: depth + 1))
    }
    
    private func makeMembersDescription(depth: Int) -> String {
        var result: String = ""
        if members.isEmpty {
            result = "none"
        } else {
            for member in members {
                result += "\n"
                result += makeIndent(depth: depth + 1)
                result += "\(member.name): \(member.memberType.makeIndentedDescription(depth: depth + 1))"
            }
        }
        return result
    }
}
