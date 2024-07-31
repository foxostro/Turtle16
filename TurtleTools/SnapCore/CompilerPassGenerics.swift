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
// * [WIP] Every reference to a generic struct type is rewritten to instead reference
//   the concrete instantiation of the struct. The concrete struct type is
//   inserted into the AST.
// * [WIP] Every reference to a generic trait is rewritten to instead reference the
//   concrete instantiation of the trait. The concrete trait type is inserted
//   into the AST.
public class CompilerPassGenerics: CompilerPass {
    let globalEnvironment: GlobalEnvironment?
    var enclosingBlock: Block?
    var blocksForDecl: [String : Block] = [:]
    var declsToInsert: [Block : [FunctionDeclaration]] = [:]
    
    @discardableResult func typeCheck(rexpr: Expression) throws -> SymbolType {
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols!, globalEnvironment: globalEnvironment)
        return try typeChecker.check(expression: rexpr)
    }
    
    public init(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func visit(block node: Block) throws -> AbstractSyntaxTreeNode? {
        enclosingBlock = node
        defer { enclosingBlock = nil }
        let block0 = try super.visit(block: node) as! Block
        let children1 = (declsToInsert[node] ?? []) + block0.children
        let block1 = block0.withChildren(children1)
        return block1
    }
    
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        try SnapSubcompilerFunctionDeclaration().compile(globalEnvironment: globalEnvironment!, symbols: symbols!, node: node)
        
        if node.isGeneric, let enclosingBlock {
            blocksForDecl[node.identifier.identifier] = enclosingBlock
        }
        
        return node.isGeneric ? nil : node
    }
    
    public override func visit(genericTypeApplication expr: Expression.GenericTypeApplication) throws -> Expression? {
        let exprTyp = try typeCheck(rexpr: expr)
        
        switch exprTyp {
        case .function(let typ):
            return try visit(genericTypeApplication: expr, functionType: typ)
            
        case .structType(let typ), .constStructType(let typ):
            return try visit(genericTypeApplication: expr, structType: typ)
            
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
        if let block = blocksForDecl[functionType.name!] {
            let funSym = SymbolTable(parent: block.symbols, frameLookupMode: .set(Frame()))
            let decl = FunctionDeclaration(
                identifier: Expression.Identifier(mangledName),
                functionType: Expression.FunctionType(
                    name: mangledName,
                    returnType: Expression.PrimitiveType(functionType.returnType),
                    arguments: functionType.arguments.map { Expression.PrimitiveType($0) }),
                argumentNames: ["a"],
                body: Block(children: [
                    Return(Expression.Identifier("a"))
                ]),
                visibility: .privateVisibility,
                symbols: funSym)
            
            if let currentList = declsToInsert[block] {
                declsToInsert[block] = currentList + [decl]
            }
            else {
                declsToInsert[block] = [decl]
            }
        }
        
        return Expression.Identifier(mangledName)
    }
    
    fileprivate func visit(genericTypeApplication expr: Expression.GenericTypeApplication, structType: StructType) throws -> Expression? {
        // TODO: Create a StructDeclaration for the concrete instantiation of the generic struct. Insert the concrete struct type into the symbol table. Insert the concrete struct declaration into the AST.
        expr
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
            let expr1 = Expression.Call(sourceAnchor: expr0.sourceAnchor,
                                        callee: callee1,
                                        arguments: expr0.arguments)
            return expr1
            
        default:
            return expr0
        }
    }
}
