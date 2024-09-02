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
    fileprivate var pendingInsertions: [AbstractSyntaxTreeNode.ID : [AbstractSyntaxTreeNode]] = [:]
    
    fileprivate func appendPendingInsertion(_ node: AbstractSyntaxTreeNode, at id: AbstractSyntaxTreeNode.ID) {
        pendingInsertions[id, default: []].append(node)
    }
    
    fileprivate func appendPendingInsertions(_ nodes: [AbstractSyntaxTreeNode], at id: AbstractSyntaxTreeNode.ID) {
        pendingInsertions[id, default: []].append(contentsOf: nodes)
    }
    
    fileprivate class BlockRewriter: CompilerPass {
        fileprivate let pendingInsertions: [AbstractSyntaxTreeNode.ID : [AbstractSyntaxTreeNode]]
        
        init(_ pendingInsertions: [AbstractSyntaxTreeNode.ID : [AbstractSyntaxTreeNode]]) {
            self.pendingInsertions = pendingInsertions
        }
        
        public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
            let block1 = try super.visit(block: block0) as! Block
            let index = block1.children.firstIndex {
                ($0 as? Seq)?.tags.contains(.scopePrologue) ?? false
            }
            let block2 = block1.inserting(
                children: pendingInsertions[block1.id, default: []],
                at: index ?? 0)
            return block2
        }
        
        public override func visit(impl node0: Impl) throws -> AbstractSyntaxTreeNode? {
            let node1 = try super.visit(impl: node0) as! Impl
            let toInsert = pendingInsertions[node1.id, default: []].map {
                $0 as! FunctionDeclaration
            }
            let node2 = node1.inserting(children: toInsert, at: 0)
            return node2
        }
    }
    
    @discardableResult fileprivate func typeCheck(rexpr: Expression) throws -> SymbolType {
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols!, globalEnvironment: globalEnvironment)
        return try typeChecker.check(expression: rexpr)
    }
    
    public override func run(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let node1 = try node0?.clearSymbols(globalEnvironment)
        let node2 = try super.run(node1)
        let node3 = try BlockRewriter(pendingInsertions).run(node2)
        return node3
    }
    
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            nil
        }
        else {
            try super.visit(func: node) as! FunctionDeclaration
        }
    }
    
    public override func visit(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            nil
        }
        else {
            try super.visit(struct: node) as! StructDeclaration
        }
    }
    
    public override func visit(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            return nil
        }
        else {
            let node1 = try super.visit(trait: node) as! TraitDeclaration
            return node1
        }
    }
    
    public override func visit(impl node: Impl) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            nil
        }
        else {
            try super.visit(impl: node) as! Impl
        }
    }
    
    public override func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        if node.isGeneric {
            nil
        }
        else {
            try super.visit(implFor: node) as! ImplFor
        }
    }
    
    public override func visit(genericTypeApplication expr: Expression.GenericTypeApplication) throws -> Expression? {
        try visit(genericTypeApplication: expr, symbols: symbols!)
    }
    
    fileprivate func visit(genericTypeApplication expr: Expression.GenericTypeApplication, symbols: SymbolTable) throws -> Expression? {
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
        let exprTyp = try typeChecker.check(expression: expr)
        
        switch exprTyp {
        case .function(let typ):
            return try visit(expr: expr,
                             symbols: symbols,
                             concreteFunctionType: typ)
            
        case .structType(let typ), .constStructType(let typ):
            return try visit(expr: expr,
                             symbols: symbols,
                             concreteStructType: typ)
            
        case .traitType(let typ), .constTraitType(let typ):
            return try visit(expr: expr,
                             symbols: symbols,
                             concreteTraitType: typ)
            
        default:
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "internal compiler error: expected expression to have a function type: `\(expr)'")
        }
    }
    
    fileprivate func visit(expr: Expression.GenericTypeApplication,
                           symbols: SymbolTable,
                           concreteFunctionType: FunctionType) throws -> Expression? {
        
        let genericFunctionType = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.identifier.sourceAnchor,
            identifier: expr.identifier.identifier)
            .unwrapGenericFunctionType()
        
        // The compiler must an emit AST node for the concrete instantiaton of
        // the generic function.
        if let scope = symbols.lookupScopeEnclosingSymbol(identifier: genericFunctionType.name),
           let id = genericFunctionType.enclosingImplId ?? scope.associatedNodeId,
           let ast = concreteFunctionType.ast {
            
            appendPendingInsertion(ast, at: id)
        }
        
        return Expression.Identifier(concreteFunctionType.mangledName!)
    }
    
    fileprivate func visit(expr: Expression.GenericTypeApplication,
                           symbols: SymbolTable,
                           concreteStructType: StructType) throws -> Expression? {
        
        let genericStructType = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.identifier.sourceAnchor,
            identifier: expr.identifier.identifier)
            .unwrapGenericStructType()
        
        // The compiler must emit AST nodes for the the concrete instantiation
        // of the generic struct and all of its impl nodes.
        if let scope = symbols.lookupScopeEnclosingType(identifier: genericStructType.name),
           let id = scope.associatedNodeId {
            
            // TODO: Would this fail if we had two generic type applications for this generic struct? If we had two then we would insert the same StructDeclaration twice.
            // TODO: This inserts the concrete impl nodes right after the struct declaration, but this may not be correct. Some symbols used in the impl block might not be defined at this point in the program. (maybe?)
            let nodes = makeNodesForConcreteStruct(concreteStructType)
            appendPendingInsertions(nodes, at: id)
        }
        
        return Expression.Identifier(concreteStructType.name)
    }
    
    func makeNodesForConcreteStruct(_ concreteStructType: StructType) -> [AbstractSyntaxTreeNode] {
        var result: [AbstractSyntaxTreeNode] = [
            StructDeclaration(concreteStructType)
        ]
        
        let methods = concreteStructType
            .symbols
            .symbolTable
            .values
            .compactMap { symbol in
                switch symbol.type {
                case .function(let typ):
                    typ.ast
                    
                case .genericFunction(let typ):
                    #if false
                    let template = typ.template
                    let impl = Impl(
                        typeArguments: [],
                        structTypeExpr: Expression.Identifier(),
                        children: [
                            template
                        ])
                    return impl
                    #else
                    typ.template
                    #endif
                    
                default:
                    nil
                }
            }
        
        if !methods.isEmpty {
            result.append(Impl(
                typeArguments: [],
                structTypeExpr: Expression.Identifier(concreteStructType.name),
                children: methods))
        }
        
        return result
    }
    
    fileprivate func visit(expr: Expression.GenericTypeApplication,
                           symbols: SymbolTable,
                           concreteTraitType: TraitType) throws -> Expression? {
        
        let genericTraitType = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.identifier.sourceAnchor,
            identifier: expr.identifier.identifier)
            .unwrapGenericTraitType()
        
        // The compiler pass must insert the concrete instantiation of the
        // trait into the AST that it produces.
        if let scope = symbols.lookupScopeEnclosingType(identifier: genericTraitType.name),
           let id = scope.associatedNodeId {
            
            appendPendingInsertion(TraitDeclaration(concreteTraitType), at: id)
        }
        
        return Expression.Identifier(concreteTraitType.name)
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
            let typeChecker = RvalueExpressionTypeChecker(symbols: symbols!, globalEnvironment: globalEnvironment)
            let app = try typeChecker.synthesizeGenericTypeApplication(call: expr0, genericFunctionType: typ)
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
    public func genericsPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassGenerics(globalEnvironment: globalEnvironment).run(self)
    }
}
