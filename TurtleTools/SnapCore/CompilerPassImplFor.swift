//
//  CompilerPassImplFor.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Snap compiler pass to erase ImplFor declarations
/// ImplFor declarations are erased and rewritten in terms of lower-level
/// concepts. The ImplFor AST node is replaced with an appropriate Impl node
/// and an appropriate vtable declaration.
public class CompilerPassImplFor: CompilerPassWithDeclScan {
    fileprivate var pendingInsertions: [AbstractSyntaxTreeNode.ID : [(String, VarDeclaration)]] = [:]
    
    fileprivate var typeChecker: RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(symbols: symbols!, globalEnvironment: globalEnvironment)
    }
    
    fileprivate class BlockRewriter: CompilerPass {
        let pendingInsertions: [AbstractSyntaxTreeNode.ID : [(String, VarDeclaration)]]
        
        init(_ pendingInsertions: [AbstractSyntaxTreeNode.ID : [(String, VarDeclaration)]]) {
            self.pendingInsertions = pendingInsertions
        }
        
        public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
            let block1 = try super.visit(block: block0) as! Block
            let block2 = insertVtableDeclarations(block1)
            return block2
        }
        
        func insertVtableDeclarations(_ block0: Block) -> Block {
            guard let pendingInsertions = pendingInsertions[block0.id] else { return block0 }
            var children = block0.children
            for (vtableTypeName, vtableInstanceDecl) in pendingInsertions {
                let indexOfDecl = children.firstIndex {
                    ($0 as? Seq)?.children.first {
                        guard let decl = $0 as? StructDeclaration else { return false }
                        return decl.identifier.identifier == vtableTypeName
                    } != nil
                }
                let insertionIndex = children.index(after: indexOfDecl!)
                children.insert(vtableInstanceDecl, at: insertionIndex)
            }
            let block1 = block0.withChildren(children)
            return block1
        }
    }
    
    /// Transformation to apply to the program AST after the compiler pass runs
    public override func postProcess(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let node1 = try BlockRewriter(pendingInsertions).run(node0)
        let node2 = try super.postProcess(node1)
        return node2
    }
    
    /// Each ImplFor node is transformed to an Impl node
    public override func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        let traitType = try typeChecker.check(expression: node.traitTypeExpr).unwrapTraitType()
        let structType = try typeChecker.check(expression: node.structTypeExpr).unwrapStructType()
        let vtableType = try typeChecker.check(identifier: Expression.Identifier(traitType.nameOfVtableType)).unwrapStructType()
        let vtableTypeScope = symbols!.lookupScopeEnclosingType(identifier: vtableType.name)!
        
        let nameOfVtableInstance = "__\(traitType.name)_\(structType.name)_vtable_instance"
        var arguments: [Expression.StructInitializer.Argument] = []
        let sortedVtableSymbols = vtableType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (methodName, methodSymbol) in sortedVtableSymbols {
            let arg = Expression.StructInitializer.Argument(
                name: methodName,
                expr: Expression.Bitcast(
                    expr: Expression.Unary(
                        op: .ampersand,
                        expression: Expression.Get(
                            expr: Expression.Identifier(structType.name),
                            member: Expression.Identifier(methodName))),
                    targetType: Expression.PrimitiveType(methodSymbol.type)))
            arguments.append(arg)
        }
        
        let initializer = Expression.StructInitializer(
            identifier: Expression.Identifier(traitType.nameOfVtableType),
            arguments: arguments)
        
        let visibility = if let identifier = node.traitTypeExpr as? Expression.Identifier {
            try symbols!.resolveTypeRecord(
                sourceAnchor: node.sourceAnchor,
                identifier: identifier.identifier).visibility
        }
        else {
            SymbolVisibility.privateVisibility
        }
        
        let vtableInstanceDecl = VarDeclaration(
            identifier: Expression.Identifier(nameOfVtableInstance),
            explicitType: Expression.Identifier(vtableType.name),
            expression: initializer,
            storage: .staticStorage,
            isMutable: false,
            visibility: visibility)
        
        // Record the vtable instance so we can later insert it immediately
        // following the declaration of the vtable struct type.
        pendingInsertions[vtableTypeScope.associatedNodeId!, default: []].append((vtableType.name, vtableInstanceDecl))
        
        let impl = Impl(
            sourceAnchor: node.sourceAnchor,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            structTypeExpr: try visit(expr: node.structTypeExpr)!,
            children: try node.children.compactMap {
                try visit($0) as? FunctionDeclaration
            },
            id: node.id)
        
        return impl
    }
}

extension AbstractSyntaxTreeNode {
    /// Erase impl-for declarations, rewriting in terms of lower-level concepts
    public func implForPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassImplFor(globalEnvironment: globalEnvironment).run(self)
    }
}
