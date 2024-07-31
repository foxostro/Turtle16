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
    // Remember where the declaration of a generic occurred.
    // Assist in writing declarations for concrete instantiations of that type.
    fileprivate class DeclarationWriter : NSObject {
        var blocksForDecl: [String : Block] = [:]
        var declsToInsert: [Block : [AbstractSyntaxTreeNode]] = [:]
        
        // Remember the block which encloses the specified generic declaration
        // At the moment, this does not handle shadowed declarations.
        func rememberGenericDeclaration(identifier: String, enclosingBlock: Block) {
            assert(blocksForDecl[identifier] == nil)
            blocksForDecl[identifier] = enclosingBlock
        }
        
        // Return the block which encloses the specified generic declaration
        func lookupBlockWhichEnclosesGenericDeclaration(identifier: String) -> Block? {
            blocksForDecl[identifier]
        }
        
        // Note a concrete declaration that we need for a previous generic declaration
        func addConcreteDeclaration(identifierForGenericDeclaration: String, declaration: AbstractSyntaxTreeNode) {
            if let block = lookupBlockWhichEnclosesGenericDeclaration(identifier: identifierForGenericDeclaration) {
                declsToInsert[block, default: []].append(declaration)
            }
        }
        
        // Rewrite the block to include the declarations provided earlier
        // Because rewriting the AST will create new nodes, with different
        // identity, we need a reference to the original block instance that we
        // recorded earlier.
        func rewriteToIncludeDeclarations(blockForIdentity: Block, blockToRewrite: Block) -> Block {
            blockToRewrite.withChildren(declsToInsert[blockForIdentity, default: []] + blockToRewrite.children)
        }
    }
    
    fileprivate let globalEnvironment: GlobalEnvironment?
    fileprivate var enclosingBlock: Block?
    fileprivate let funcDeclWriter = DeclarationWriter()
    
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
        let block1 = funcDeclWriter.rewriteToIncludeDeclarations(
            blockForIdentity: node,
            blockToRewrite: block0)
        return block1
    }
    
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        try SnapSubcompilerFunctionDeclaration().compile(globalEnvironment: globalEnvironment!, symbols: symbols!, node: node)
        
        if node.isGeneric, let enclosingBlock {
            funcDeclWriter.rememberGenericDeclaration(
                identifier: node.identifier.identifier,
                enclosingBlock: enclosingBlock)
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
        if let block = funcDeclWriter.lookupBlockWhichEnclosesGenericDeclaration(identifier: functionType.name!) {
            let decl = makeConcreteFunctionDeclaration(
                parentSymbols: block.symbols,
                functionType: functionType)
            funcDeclWriter.addConcreteDeclaration(
                identifierForGenericDeclaration: functionType.name!,
                declaration: decl)
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
