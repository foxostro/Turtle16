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
public class CompilerPassGenerics: CompilerPass {
    fileprivate let globalEnvironment: GlobalEnvironment
    fileprivate var pendingInsertions: [AbstractSyntaxTreeNode.ID : [AbstractSyntaxTreeNode]] = [:]
    
    fileprivate class BlockRewriter: CompilerPass {
        fileprivate let pendingInsertions: [AbstractSyntaxTreeNode.ID : [AbstractSyntaxTreeNode]]
        
        init(_ pendingInsertions: [AbstractSyntaxTreeNode.ID : [AbstractSyntaxTreeNode]]) {
            self.pendingInsertions = pendingInsertions
        }
        
        public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
            let block1 = try super.visit(block: block0) as! Block
            let block2 = block1.inserting(children: pendingInsertions[block1.id, default: []], at: 0)
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
    
    public init(symbols: SymbolTable?, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func run(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.run(node0)
        let node2 = try BlockRewriter(pendingInsertions).run(node1)
        return node2
    }
    
    public override func visit(func node0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        node0.isGeneric ? nil : node0
    }
    
    public override func visit(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        node0.isGeneric ? nil : node0
    }
    
    public override func visit(trait node0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        node0.isGeneric ? nil : node0
    }
    
    public override func visit(genericTypeApplication expr: Expression.GenericTypeApplication) throws -> Expression? {
        let exprTyp = try typeCheck(rexpr: expr)
        
        switch exprTyp {
        case .function(let typ):
            return try visit(genericTypeApplication: expr, functionType: typ)
            
        case .structType(let typ), .constStructType(let typ):
            return try visit(genericTypeApplication: expr, structType: typ)
            
        case .traitType(let typ), .constTraitType(let typ):
            return try visit(genericTypeApplication: expr, traitType: typ)
            
        default:
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "internal compiler error: expected expression to have a function type: `\(expr)'")
        }
    }
    
    fileprivate func visit(genericTypeApplication expr: Expression.GenericTypeApplication, functionType: FunctionType) throws -> Expression? {
        
        guard let mangledName = functionType.mangledName else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "internal compiler error: concrete instance of generic function has no mangled name: `\(functionType)'")
        }
        
        let symbol = Symbol(type: .function(functionType),
                            offset: 0,
                            storage: .automaticStorage,
                            visibility: .privateVisibility)
        symbols!.bind(identifier: mangledName, symbol: symbol)
        
        // The compiler pass must insert the concrete instantiation of the
        // function into the AST that it produces.
        if let scope = symbols!.lookupScopeEnclosingSymbol(identifier: functionType.name!), let id = scope.associatedNodeId {
            let decl = makeConcreteFunctionDeclaration(
                parentSymbols: scope,
                functionType: functionType)
            pendingInsertions[id, default: []].append(decl)
        }
        
        return Expression.Identifier(mangledName)
    }
    
    fileprivate func makeConcreteFunctionDeclaration(parentSymbols: SymbolTable, functionType: FunctionType) -> FunctionDeclaration {
        let mangledName = functionType.mangledName!
        let funSym = SymbolTable(parent: parentSymbols, frameLookupMode: .set(Frame()))
        let bodySyms = SymbolTable(parent: funSym)
        let decl = FunctionDeclaration(
            identifier: Expression.Identifier(mangledName),
            functionType: Expression.FunctionType(
                name: mangledName,
                returnType: Expression.PrimitiveType(functionType.returnType),
                arguments: functionType.arguments.map { Expression.PrimitiveType($0) }),
            argumentNames: ["a"],
            body: Block(symbols: bodySyms, children: [
                Return(Expression.Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: funSym)
        return decl
    }
    
    fileprivate func visit(genericTypeApplication expr: Expression.GenericTypeApplication, structType: StructType) throws -> Expression? {
        
        symbols!.bind(
            identifier: structType.name,
            symbolType: .structType(structType))
        
        // The compiler pass must insert the concrete instantiation of the
        // struct into the AST that it produces.
        if let scope = symbols!.lookupScopeEnclosingType(identifier: structType.name), let id = scope.associatedNodeId {
            let decl = StructDeclaration(
                identifier: Expression.Identifier(structType.name),
                members: structType.symbols.symbolTable.map {
                    StructDeclaration.Member(
                        name: $0.key,
                        type: Expression.PrimitiveType($0.value.type))
                },
                visibility: .privateVisibility,
                isConst: false)
            pendingInsertions[id, default: []].append(decl)
        }
        
        return Expression.Identifier(structType.name)
    }
    
    fileprivate func visit(genericTypeApplication expr: Expression.GenericTypeApplication, traitType: TraitType) throws -> Expression? {
        
        symbols!.bind(
            identifier: traitType.name,
            symbolType: .traitType(traitType))
        
        // The compiler pass must insert the concrete instantiation of the
        // trait into the AST that it produces.
        if let scope = symbols!.lookupScopeEnclosingType(identifier: traitType.name), let id = scope.associatedNodeId {
            let decl = TraitDeclaration(
                identifier: Expression.Identifier(traitType.name),
                members: traitType.symbols.symbolTable.map {
                    TraitDeclaration.Member(
                        name: $0.key,
                        type: Expression.PrimitiveType($0.value.type))
                },
                visibility: .privateVisibility)
            pendingInsertions[id, default: []].append(decl)
        }
        
        return Expression.Identifier(traitType.name)
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
            return expr0
        }
    }
}

extension AbstractSyntaxTreeNode {
    /// Erase generics, rewriting in terms of new concrete types
    public func genericsPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        let compiler = CompilerPassGenerics(symbols: nil, globalEnvironment: globalEnvironment)
        let result = try compiler.run(self)
        return result
    }
}
