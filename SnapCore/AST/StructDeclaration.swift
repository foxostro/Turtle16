//
//  StructDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
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
    
    public convenience init(identifier: Expression.Identifier,
                            members: [Member]) {
        self.init(sourceAnchor: nil,
                  identifier: identifier,
                  members: members)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         identifier: Expression.Identifier,
                         members: [Member]) {
        self.identifier = identifier
        self.members = members
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? StructDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard members == rhs.members else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(members)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: identifier=%@, members=%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier.makeIndentedDescription(depth: depth + 1),
                      makeMembersDescription())
    }
    
    public func makeMembersDescription() -> String {
        let result = members.map({"\t\($0.name) : \($0.memberType)"}).joined(separator: ",\n")
        return result
    }
}
