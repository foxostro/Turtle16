//
//  CompilerPassGenerics.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/30/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

// Snap compiler pass to erase generics
// * Every expression with a generic function application is rewritten to
//   instead reference the concrete instantiation of the function. The concrete
//   instantiation of the function is inserted into the AST.
// * Every reference to a generic struct type is rewritten to instead reference
//   the concrete instantiation of the struct. The concrete struct type is
//   inserted into the AST.
// * Every reference to a generic trait is rewritten to instead reference the
//   concrete instantiation of the trait. The concrete trait type is inserted
//   into the AST.
public class CompilerPassGenerics: CompilerPassWithDeclScan {
    
    /// Maps an ID which uniquely identifies a point in the AST to a list of
    /// nodes to be inserted just after this point.
    fileprivate typealias PendingInsertions = [(AbstractSyntaxTreeNode.ID, [AbstractSyntaxTreeNode])]
    fileprivate var pendingInsertions: PendingInsertions = []
    
    fileprivate func appendPendingInsertion(_ node: AbstractSyntaxTreeNode, after id: AbstractSyntaxTreeNode.ID) {
        appendPendingInsertions([node], at: id)
    }
    
    fileprivate func appendPendingInsertions(_ nodes: [AbstractSyntaxTreeNode], at id: AbstractSyntaxTreeNode.ID) {
        pendingInsertions.append((id, nodes))
    }
    
    /// Rewrites blocks in the AST by inserting the given nodes
    fileprivate class BlockRewriter: CompilerPass {
        fileprivate let pendingInsertions: PendingInsertions
        
        init(_ pendingInsertions: PendingInsertions) {
            self.pendingInsertions = pendingInsertions
        }
        
        public override func visit(block node0: Block) throws -> AbstractSyntaxTreeNode? {
            let node1 = try super.visit(block: node0) as! Block
            var children = node1.children
            applyPendingInsertions(&children)
            let node2 = node1.withChildren(children)
            return node2
        }
        
        public override func visit(seq node0: Seq) throws -> AbstractSyntaxTreeNode? {
            let node1 = try super.visit(seq: node0) as! Block
            var children = node1.children
            applyPendingInsertions(&children)
            let node2 = node1.withChildren(children)
            return node2
        }
        
        public override func visit(impl node0: Impl) throws -> AbstractSyntaxTreeNode? {
            let node1 = try super.visit(impl: node0) as! Impl
            var children = node1.children
            applyPendingInsertions(&children)
            let node2 = node1.withChildren(children)
            return node2
        }
        
        public override func visit(implFor node0: ImplFor) throws -> AbstractSyntaxTreeNode? {
            let node1 = try super.visit(implFor: node0) as! ImplFor
            var children = node1.children
            applyPendingInsertions(&children)
            let node2 = node1.withChildren(children)
            return node2
        }
        
        private func applyPendingInsertions<T: AbstractSyntaxTreeNode>(_ children: inout [T]) {
            for (targetID, nodes) in pendingInsertions {
                if let targetIndex = children.firstIndex(where: { $0.id == targetID }) {
                    children.insert(contentsOf: nodes.map { $0 as! T },
                                    at: children.index(after: targetIndex))
                }
            }
        }
    }
    
    /// Removes nodes that are generic declarations
    fileprivate class GenericDeclarationStripper: CompilerPass {
        public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
            if node.isGeneric {
                nil
            }
            else {
                try super.visit(func: node)
            }
        }
        
        public override func visit(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
            if node.isGeneric {
                nil
            }
            else {
                try super.visit(struct: node)
            }
        }
        
        public override func visit(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
            if node.isGeneric {
                nil
            }
            else {
                try super.visit(trait: node)
            }
        }
        
        public override func visit(impl node: Impl) throws -> AbstractSyntaxTreeNode? {
            if node.isGeneric {
                nil
            }
            else {
                try super.visit(impl: node)
            }
        }
        
        public override func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
            if node.isGeneric {
                nil
            }
            else {
                try super.visit(implFor: node)
            }
        }
    }
    
    @discardableResult fileprivate func typeCheck(rexpr: Expression) throws -> SymbolType {
        let typeChecker = RvalueExpressionTypeChecker(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
        return try typeChecker.check(expression: rexpr)
    }
    
    public override func postProcess(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let node1 = try BlockRewriter(pendingInsertions)
            .run(node0)!
            .reconnect(parent: nil)
        let node2 = try GenericDeclarationStripper().run(node1)
        let node3 = try super.postProcess(node2)
        return node3
    }
    
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            node
        }
        else {
            try super.visit(func: node) as! FunctionDeclaration
        }
    }
    
    public override func visit(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            node
        }
        else {
            try super.visit(struct: node) as! StructDeclaration
        }
    }
    
    public override func visit(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            node
        }
        else {
            try super.visit(trait: node) as! TraitDeclaration
        }
    }
    
    public override func visit(impl node: Impl) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            node
        }
        else {
            try super.visit(impl: node) as! Impl
        }
    }
    
    public override func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            node
        }
        else {
            try super.visit(implFor: node) as! ImplFor
        }
    }
    
    public override func visit(genericTypeApplication expr: Expression.GenericTypeApplication) throws -> Expression? {
        try visit(genericTypeApplication: expr, symbols: symbols!)
    }
    
    fileprivate func visit(genericTypeApplication expr: Expression.GenericTypeApplication, symbols: SymbolTable) throws -> Expression? {
        
        let typeChecker = RvalueExpressionTypeChecker(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
        let exprTyp = try typeChecker.check(expression: expr)
        let concreteDeclaration = switch exprTyp {
        case .function(let typ):
            try visit(expr: expr, symbols: symbols, concreteFunctionType: typ)
        case .structType(let typ), .constStructType(let typ):
            try visit(expr: expr, symbols: symbols, concreteStructType: typ)
        case .traitType(let typ), .constTraitType(let typ):
            try visit(expr: expr, symbols: symbols, concreteTraitType: typ)
        default:
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "internal compiler error: expected expression to have a function type: `\(expr)'")
        }
        return concreteDeclaration
    }
    
    fileprivate func visit(expr: Expression.GenericTypeApplication,
                           symbols: SymbolTable,
                           concreteFunctionType: FunctionType) throws -> Expression? {
        
        let mangledName = concreteFunctionType.mangledName!
        let concreteIdent = Expression.Identifier(mangledName)
        let genericFunctionType = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.identifier.sourceAnchor,
            identifier: expr.identifier.identifier)
            .unwrapGenericFunctionType()
        
        // Instantiate the generic function with concrete type arguments
        let pairs = zip(
            genericFunctionType.typeArguments.map(\.identifier),
            try expr.arguments.map {
                Expression.PrimitiveType(try typeCheck(rexpr: $0))
            })
        let ast0 = genericFunctionType.template
        let ast1 = ast0
            .clone()
            .eraseTypeArguments()
            .withIdentifier(mangledName)
            .withFunctionType(ast0.functionType
                .withNewId()
                .withName(mangledName))
        let ast2 = try GenericsPartialEvaluator
            .eval(ast1, replacements: pairs)
        // The expectation is that the template for a generic function has no symbols yet. The unbound type parameter makes that impossible. We scan it on instantiation when all types are known.
        try FunctionScanner(
            memoryLayoutStrategy: memoryLayoutStrategy,
            symbols: ast2.symbols.parent!)
        .scanInside(func: ast2)
        let ast3 = try visit(ast2)!
        
        // The compiler must an emit AST node for the concrete instantiaton of
        // the generic function.
        // Emit at the point where the generic function was initially defined.
        // TODO: The compiler must instead insert the node at the widest lexical scope accessible to the generic type application which includes both the generic function declaration and all type arguments.
        let destination = genericFunctionType.template.id
        appendPendingInsertion(ast3, after: destination)
        
        return concreteIdent
    }
    
    /// Records which concrete types have already been instantiated from their
    /// generic recipes in the environment
    private var concreteTypesAlreadyInstantiated: [Set<String>] = [Set<String>()]
    
    /// Determine if a concrete type has already been instantiated in the environment
    private func alreadyInstantiated(_ ident: String) -> Bool {
        nil != concreteTypesAlreadyInstantiated.last { $0.contains(ident) }
    }
    
    /// Note that a concrete type has been instantiated in the environment
    private func markAlreadyInstantiated(_ ident: String) {
        concreteTypesAlreadyInstantiated[concreteTypesAlreadyInstantiated.count-1].insert(ident)
    }
    
    public override func willVisit(block node: Block) throws {
        try super.willVisit(block: node)
        concreteTypesAlreadyInstantiated.append(Set<String>())
    }
    
    public override func didVisit(block node: Block) {
        super.didVisit(block: node)
        concreteTypesAlreadyInstantiated.removeLast()
    }
    
    fileprivate func visit(expr: Expression.GenericTypeApplication,
                           symbols: SymbolTable,
                           concreteStructType: StructType) throws -> Expression? {
        
        let concreteIdent = Expression.Identifier(concreteStructType.name)
        
        // Prevent recursive instantiation
        guard !alreadyInstantiated(concreteIdent.identifier) else {
            return concreteIdent
        }
        markAlreadyInstantiated(concreteIdent.identifier)
        
        let genericStructType = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.identifier.sourceAnchor,
            identifier: expr.identifier.identifier)
            .unwrapGenericStructType()
        
        // The compiler must an emit AST node for the concrete instantiaton of
        // the generic struct. Emit at the point where the generic struct
        // was initially defined.
        // TODO: The compiler must instead insert the node at the widest lexical scope accessible to the generic type application which includes both the generic struct declaration and all type arguments.
        
        // Instantiate the generic struct declarations with concrete type arguments
        let ast0 = genericStructType.template
            .withNewId()
            .eraseTypeArguments()
            .withIdentifier(concreteIdent)
        let pairs = zip(
            genericStructType.typeArguments.map(\.identifier),
            try expr.arguments.map {
                Expression.PrimitiveType(try typeCheck(rexpr: $0))
            })
        let ast1 = try GenericsPartialEvaluator.eval(ast0, replacements: pairs)
        let ast2 = try visit(ast1)!
        appendPendingInsertion(ast2, after: genericStructType.template.id)
        
        // Instantiate each Impl node
        for implNode0 in genericStructType.implNodes {
            let implNode1 = implNode0
                .clone()
                .eraseTypeArguments()
                .withStructTypeExpr(concreteIdent)
            let implNode2 = try GenericsPartialEvaluator
                .eval(implNode1, replacements: pairs)
            let implNode3 = try visit(implNode2)!
            appendPendingInsertion(implNode3, after: implNode0.id)
        }
        
        // Instantiate each ImplFor node
        for implForNode0 in genericStructType.implForNodes {
            let implForNode1 = implForNode0
                .clone()
                .eraseTypeArguments()
                .withStructTypeExpr(concreteIdent)
            let implForNode2 = try GenericsPartialEvaluator
                .eval(implForNode1, replacements: pairs)
            let implForNode3 = try visit(implForNode2)!
            appendPendingInsertion(implForNode3, after: implForNode0.id)
        }
        
        return concreteIdent
    }
    
    fileprivate func visit(expr: Expression.GenericTypeApplication,
                           symbols: SymbolTable,
                           concreteTraitType: TraitType) throws -> Expression? {
        
        let concreteIdent = Expression.Identifier(concreteTraitType.name)
        
        // Prevent recursive instantiation
        guard !alreadyInstantiated(concreteIdent.identifier) else {
            return concreteIdent
        }
        markAlreadyInstantiated(concreteIdent.identifier)
        
        let genericTraitType = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.identifier.sourceAnchor,
            identifier: expr.identifier.identifier)
            .unwrapGenericTraitType()
        
        // The compiler must an emit AST node for the concrete instantiaton of
        // the generic trait.
        // Emit at the point where the generic trait was initially defined.
        // TODO: The compiler must instead insert the node at the widest lexical scope accessible to the generic type application which includes both the generic trait declaration and all type arguments.
        let destination = genericTraitType.template.id
        
        let ast0 = genericTraitType.template
            .withNewId()
            .eraseTypeArguments()
            .withIdentifier(concreteIdent)
            .withMangledName(concreteTraitType.name)
        let pairs = zip(
            genericTraitType.typeArguments.map(\.identifier.identifier),
            try expr.arguments.map {
                Expression.PrimitiveType(try typeCheck(rexpr: $0))
            })
        let ast1 = try GenericsPartialEvaluator.eval(ast0, replacements: pairs)
        let ast2 = try visit(ast1)!
        appendPendingInsertion(ast2, after: destination)
        
        return concreteIdent
    }
    
    public override func visit(call expr0: Expression.Call) throws -> Expression? {
        let calleeType: SymbolType
        if let symbols,
           let identifier = expr0.callee as? Expression.Identifier {
            calleeType = try symbols.resolveTypeOfIdentifier(sourceAnchor: identifier.sourceAnchor, identifier: identifier.identifier)
        }
        else {
            calleeType = try typeCheck(rexpr: expr0.callee)
        }
        
        switch calleeType {
        case .genericFunction(let typ):
            let typeChecker = RvalueExpressionTypeChecker(
                symbols: symbols!,
                staticStorageFrame: staticStorageFrame,
                memoryLayoutStrategy: memoryLayoutStrategy)
            let app = try typeChecker.synthesizeGenericTypeApplication(
                call: expr0,
                genericFunctionType: typ)
            let callee1 = try visit(genericTypeApplication: app)!
            let expr1 = expr0.withCallee(callee1)
            return expr1
            
        default:
            let callee1 = try visit(expr: expr0.callee)!
            let expr1 = expr0.withCallee(callee1)
            return expr1
        }
    }
    
    public override func visit(get expr0: Expression.Get) throws -> Expression? {
        guard let app = expr0.member as? Expression.GenericTypeApplication else {
            let expr1 = try super.visit(get: expr0)
            return expr1
        }
        
        let name = app.identifier.identifier
        let resultType = try typeCheck(rexpr: expr0.expr)
        
        switch resultType {
        case .constStructType(let typ), .structType(let typ):
            let member = try visit(genericTypeApplication: app, symbols: typ.symbols)!
            let expr1 = expr0.withMember(member)
            return expr1
            
        default:
            break
        }
        
        throw CompilerError(sourceAnchor: expr0.sourceAnchor, message: "value of type `\(resultType)' has no member `\(name)'")
    }
}

extension AbstractSyntaxTreeNode {
    /// Erase generics, rewriting in terms of new concrete types
    public func genericsPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassGenerics().run(self)
    }
}
