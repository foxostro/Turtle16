//
//  Seq.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

extension String {
    /// A tag to mark code sequences used to setup vtables
    public static let vtable = "vtable"
}

public class Seq: AbstractSyntaxTreeNode {
    public let tags: Set<String>
    public let children: [AbstractSyntaxTreeNode]
    
    public init(sourceAnchor: SourceAnchor? = nil,
                tags: Set<String> = Set<String>(),
                children: [AbstractSyntaxTreeNode] = [],
                id: ID = ID()) {
        self.tags = tags
        self.children = children
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Seq {
        Seq(sourceAnchor: sourceAnchor,
            tags: tags,
            children: children,
            id: id)
    }
    
    public func withChildren(_ children: [AbstractSyntaxTreeNode]) -> Seq {
        Seq(sourceAnchor: sourceAnchor,
            tags: tags,
            children: children,
            id: id)
    }
    
    public func appending(children moreChildren: [AbstractSyntaxTreeNode]) -> Seq {
        withChildren(children + moreChildren)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Seq else { return false }
        guard tags == rhs.tags else { return false }
        guard children == rhs.children else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(tags)
        hasher.combine(children)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let leading = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let selfDesc = String(describing: type(of: self))
        let tagsDesc = tags.isEmpty ? "" : "(tags: [\(tags.joined(separator: ", "))])"
        let childDesc = makeChildDescriptions(depth: depth + 1)
        let result = "\(leading)\(selfDesc)\(tagsDesc)\(childDesc)"
        return result
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        let result: String
        if children.isEmpty {
            result = " (empty)"
        } else {
            result = "\n" + children.map {
                $0.makeIndentedDescription(depth: depth, wantsLeadingWhitespace: true)
            }.joined(separator: "\n")
        }
        return result
    }
    
    // TODO: Remove this hack. This hack prevents duplicate vtable declarations in the SymbolTable.pendingInsertions. It would be better to have an ImplFor compiler pass which rewrites the AST to insert this code instead.
    public func removeDuplicateVtableDeclarations() -> Seq {
        var vtableInitialAssignments: [Expression.InitialAssignment] = []
        var vtableDeclarations: [VarDeclaration] = []
        var vtableStructDeclarations: [StructDeclaration] = []
        
        let result = self.withChildren(children.compactMap {
            switch $0 {
            case let initialAssignment as Expression.InitialAssignment:
                // TODO: Remove this vtable-related hack too
                let ident = (initialAssignment.lexpr as! Expression.Identifier).identifier
                let isVtableInstanceAssignment = ident.hasPrefix("__") && ident.hasSuffix("_vtable_instance")
                if isVtableInstanceAssignment {
                    let alreadyHaveIt = vtableInitialAssignments.contains { ident == ($0.lexpr as! Expression.Identifier).identifier }
                    if alreadyHaveIt {
                        return nil
                    }
                }
                vtableInitialAssignments.append(initialAssignment)
                return initialAssignment
                
            case let varDecl as VarDeclaration:
                // TODO: Remove this vtable-related hack too
                let ident = varDecl.identifier.identifier
                let isVtableDeclaration = ident.hasPrefix("__") && ident.hasSuffix("_vtable_instance")
                if isVtableDeclaration {
                    let alreadyHaveIt = vtableDeclarations.contains { ident == $0.identifier.identifier }
                    if alreadyHaveIt {
                        return nil
                    }
                }
                vtableDeclarations.append(varDecl)
                return varDecl
                
            case let structDecl as StructDeclaration:
                let ident = structDecl.identifier.identifier
                let isVtableStructDeclaration = ident.hasPrefix("__") && ident.hasSuffix("_vtable")
                if isVtableStructDeclaration {
                    let alreadyHaveIt = vtableStructDeclarations.contains { ident == $0.identifier.identifier }
                    if alreadyHaveIt {
                        return nil
                    }
                }
                vtableStructDeclarations.append(structDecl)
                return structDecl
                
            default:
                return $0
            }
        })
        
        return result
    }
}
