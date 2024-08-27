//
//  CompilerPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CompilerPass: NSObject {
    struct Environment {
        private var stack: [SymbolTable] = []
        
        var symbols: SymbolTable? {
            stack.last
        }
        
        mutating func push(_ newSymbols: SymbolTable) {
            stack.append(newSymbols)
        }
        
        @discardableResult mutating func pop() -> SymbolTable {
            stack.removeLast()
        }
    }
    var env = Environment()
    
    public var symbols: SymbolTable? {
        env.symbols
    }
    
    public init(_ symbols: SymbolTable? = nil) {
        if let symbols {
            env.push(symbols)
        }
    }
    
    // Override in a subclass to specify actions to perform before and after
    // visiting the nodes in the tree.
    public func run(_ node: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        try visit(node)
    }
    
    public func visit(_ genericNode: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        switch genericNode {
        case let node as TopLevel:
            try visit(topLevel: node)
        case let node as Subroutine:
            try visit(subroutine: node)
        case let node as Seq:
            try visit(seq: node)
        case let node as VarDeclaration:
            try visit(varDecl: node)
        case let node as Expression:
            try visit(expressionStatement: node)
        case let node as If:
            try visit(if: node)
        case let node as While:
            try visit(while: node)
        case let node as ForIn:
            try visit(forIn: node)
        case let node as Block:
            try visit(block: node)
        case let node as Module:
            try visit(module: node)
        case let node as Return:
            try visit(return: node)
        case let node as FunctionDeclaration:
            try visit(func: node)
        case let node as StructDeclaration:
            try visit(struct: node)
        case let node as Impl:
            try visit(impl: node)
        case let node as ImplFor:
            try visit(implFor: node)
        case let node as Match:
            try visit(match: node)
        case let node as Assert:
            try visit(assert: node)
        case let node as TraitDeclaration:
            try visit(trait: node)
        case let node as TestDeclaration:
            try visit(testDecl: node)
        case let node as Typealias:
            try visit(typealias: node)
        case let node as Import:
            try visit(import: node)
        case let node as Asm:
            try visit(asm: node)
        case let node as Goto:
            try visit(goto: node)
        case let node as GotoIfFalse:
            try visit(gotoIfFalse: node)
        case let node as InstructionNode:
            try visit(instruction: node)
        case let node as TackInstructionNode:
            try visit(tack: node)
        default:
            genericNode
        }
    }
    
    public func visit(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        let children = try node.children.compactMap { try visit($0) }
        return TopLevel(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    public func visit(subroutine node: Subroutine) throws -> AbstractSyntaxTreeNode? {
        let children = try node.children.compactMap { try visit($0) }
        return Subroutine(sourceAnchor: node.sourceAnchor, identifier: node.identifier, children: children)
    }
    
    public func visit(seq node: Seq) throws -> AbstractSyntaxTreeNode? {
        let children = try node.children.compactMap { try visit($0) }
        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    public func visit(varDecl node: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        VarDeclaration(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Expression.Identifier,
            explicitType: try node.explicitType.flatMap {
                try visit(expr: $0)
            },
            expression: try node.expression.flatMap {
                try visit(expr: $0)
            },
            storage: node.storage,
            isMutable: node.isMutable,
            visibility: node.visibility)
    }
    
    public func visit(if node: If) throws -> AbstractSyntaxTreeNode? {
        If(sourceAnchor: node.sourceAnchor,
           condition: try visit(expr: node.condition)!,
           then: try visit(node.thenBranch)!,
           else: try node.elseBranch.flatMap {
            try visit($0)
        })
    }
    
    public func visit(while node: While) throws -> AbstractSyntaxTreeNode? {
        While(
            sourceAnchor: node.sourceAnchor,
            condition: try visit(expr: node.condition)!,
            body: try visit(node.body)!)
    }
    
    public func visit(forIn node: ForIn) throws -> AbstractSyntaxTreeNode? {
        ForIn(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Expression.Identifier,
            sequenceExpr: try visit(expr: node.sequenceExpr)!,
            body: try visit(node.body) as! Block)
    }
    
    public func visit(block node0: Block) throws -> AbstractSyntaxTreeNode? {
        try willVisit(block: node0)
        let node1 = node0.withChildren(try node0.children.compactMap {
            try visit($0)
        })
        didVisit(block: node0)
        return node1
    }
    
    public func willVisit(block node: Block) throws {
        env.push(node.symbols)
    }
    
    public func didVisit(block node: Block) {
        env.pop()
    }
    
    public func visit(module node0: Module) throws -> AbstractSyntaxTreeNode? {
        let compiledBlock = try visit(block: node0.block)
        return switch compiledBlock {
        case let block as Block:
            node0.withBlock(block)
        default:
            compiledBlock
        }
    }
    
    public func visit(return node: Return) throws -> AbstractSyntaxTreeNode? {
        Return(
            sourceAnchor: node.sourceAnchor,
            expression: try node.expression.flatMap {
                try visit(expr: $0)
            })
    }
    
    public func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        try willVisit(func: node)
        let result = FunctionDeclaration(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Expression.Identifier,
            functionType: try visit(expr: node.functionType) as! Expression.FunctionType,
            argumentNames: node.argumentNames,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            body: try visit(node.body) as! Block,
            visibility: node.visibility,
            symbols: node.symbols)
        didVisit(func: node)
        return result
    }
    
    public func willVisit(func node: FunctionDeclaration) throws {
        env.push(node.symbols)
    }
    
    public func didVisit(func node: FunctionDeclaration) {
        env.pop()
    }
    
    public func visit(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        StructDeclaration(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Expression.Identifier,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            members: try node.members.map {
                StructDeclaration.Member(
                    name: $0.name,
                    type: try visit(expr: $0.memberType)!)
            },
            visibility: node.visibility,
            isConst: node.isConst)
    }
    
    public func visit(impl node: Impl) throws -> AbstractSyntaxTreeNode? {
        Impl(
            sourceAnchor: node.sourceAnchor,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            structTypeExpr: try visit(expr: node.structTypeExpr)!,
            children: try node.children.compactMap {
                try visit($0) as? FunctionDeclaration
            },
            id: node.id)
    }
    
    public func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        ImplFor(
            sourceAnchor: node.sourceAnchor,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            traitTypeExpr: try visit(expr: node.traitTypeExpr)!,
            structTypeExpr: try visit(expr: node.structTypeExpr)!,
            children: try node.children.compactMap {
                try visit($0) as? FunctionDeclaration
            })
    }
    
    public func visit(match node: Match) throws -> AbstractSyntaxTreeNode? {
        Match(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            clauses: try node.clauses.map {
                Match.Clause(
                    sourceAnchor: $0.sourceAnchor,
                    valueIdentifier: try visit(identifier: $0.valueIdentifier) as! Expression.Identifier,
                    valueType: try visit(expr: $0.valueType)!,
                    block: try visit(block: $0.block) as! Block)
            },
            elseClause: try visit(node.elseClause) as? Block)
    }
    
    public func visit(assert node: Assert) throws -> AbstractSyntaxTreeNode? {
        Assert(
            sourceAnchor: node.sourceAnchor,
            condition: try visit(expr: node.condition)!,
            message: node.message,
            enclosingTestName: node.enclosingTestName)
    }
    
    public func visit(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        TraitDeclaration(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Expression.Identifier,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            members: try node.members.map {
                TraitDeclaration.Member(
                    name: $0.name,
                    type: try visit(expr: $0.memberType)!)
            },
            visibility: node.visibility,
            mangledName: node.mangledName)
    }
    
    public func visit(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        TestDeclaration(
            sourceAnchor: node.sourceAnchor,
            name: node.name,
            body: try visit(node.body) as! Block)
    }
    
    public func visit(typealias node: Typealias) throws -> AbstractSyntaxTreeNode? {
        Typealias(
            sourceAnchor: node.sourceAnchor,
            lexpr: try visit(identifier: node.lexpr) as! Expression.Identifier,
            rexpr: try visit(expr: node.rexpr)!,
            visibility: node.visibility)
    }
    
    public func visit(import node: Import) throws -> AbstractSyntaxTreeNode? {
        node
    }
    
    public func visit(asm node: Asm) throws -> AbstractSyntaxTreeNode? {
        node
    }
    
    public func visit(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        node
    }
    
    public func visit(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        GotoIfFalse(
            sourceAnchor: node.sourceAnchor,
            condition: try visit(expr: node.condition)!,
            target: node.target)
    }
    
    public func visit(instruction node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        node
    }
    
    public func visit(tack node: TackInstructionNode) throws -> AbstractSyntaxTreeNode? {
        node
    }
    
    public func visit(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        try visit(expr: node)
    }
    
    public func visit(expr: Expression) throws -> Expression? {
        switch expr {
        case let node as Expression.UnsupportedExpression:
            return try visit(unsupported: node)
        case let literal as Expression.LiteralInt:
            return try visit(literalInt: literal)
        case let literal as Expression.LiteralBool:
            return try visit(literalBoolean: literal)
        case let node as Expression.Identifier:
            return try visit(identifier: node)
        case let node as Expression.Unary:
            return try visit(unary: node)
        case let group as Expression.Group:
            return try visit(expr: group.expression)
        case let eseq as Expression.Eseq:
            return try visit(eseq: eseq)
        case let node as Expression.Binary:
            return try visit(binary: node)
        case let expr as Expression.InitialAssignment:
            return try visit(initialAssignment: expr)
        case let expr as Expression.Assignment:
            return try visit(assignment: expr)
        case let node as Expression.Call:
            return try visit(call: node)
        case let node as Expression.As:
            return try visit(as: node)
        case let node as Expression.Bitcast:
            return try visit(bitcast: node)
        case let expr as Expression.Is:
            return try visit(is: expr)
        case let expr as Expression.Subscript:
            return try visit(subscript: expr)
        case let literal as Expression.LiteralArray:
            return try visit(literalArray: literal)
        case let expr as Expression.Get:
            return try visit(get: expr)
        case let expr as Expression.PrimitiveType:
            return try visit(primitiveType: expr)
        case let expr as Expression.DynamicArrayType:
            return try visit(dynamicArrayType: expr)
        case let expr as Expression.ArrayType:
            return try visit(arrayType: expr)
        case let expr as Expression.FunctionType:
            return try visit(functionType: expr)
        case let expr as Expression.GenericFunctionType:
            return try visit(genericFunctionType: expr)
        case let node as Expression.GenericTypeApplication:
            return try visit(genericTypeApplication: node)
        case let node as Expression.GenericTypeArgument:
            return try visit(genericTypeArgument: node)
        case let node as Expression.PointerType:
            return try visit(pointerType: node)
        case let node as Expression.ConstType:
            return try visit(constType: node)
        case let node as Expression.MutableType:
            return try visit(mutableType: node)
        case let node as Expression.UnionType:
            return try visit(unionType: node)
        case let node as Expression.StructInitializer:
            return try visit(structInitializer: node)
        case let literal as Expression.LiteralString:
            return try visit(literalString: literal)
        case let node as Expression.TypeOf:
            return try visit(typeof: node)
        case let node as Expression.SizeOf:
            return try visit(sizeof: node)
        default:
            throw CompilerError(message: "unimplemented: `\(expr)'")
        }
    }
    
    public func visit(unsupported node: Expression.UnsupportedExpression) throws -> Expression? {
        node
    }
    
    public func visit(literalInt node: Expression.LiteralInt) throws -> Expression? {
        node
    }
    
    public func visit(literalBoolean node: Expression.LiteralBool) throws -> Expression? {
        node
    }
    
    public func visit(literalArray expr: Expression.LiteralArray) throws -> Expression? {
        Expression.LiteralArray(
            sourceAnchor: expr.sourceAnchor,
            arrayType: try visit(expr: expr.arrayType)!,
            elements: try expr.elements.compactMap {
                try visit(expr: $0)
            })
    }
    
    public func visit(literalString expr: Expression.LiteralString) throws -> Expression? {
        expr
    }
    
    public func visit(identifier node: Expression.Identifier) throws -> Expression? {
        node
    }
    
    public func visit(as expr: Expression.As) throws -> Expression? {
        Expression.As(
            sourceAnchor: expr.sourceAnchor,
            expr: try visit(expr: expr.expr)!,
            targetType: try visit(expr: expr.targetType)!)
    }
    
    public func visit(bitcast node: Expression.Bitcast) throws -> Expression? {
        Expression.Bitcast(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            targetType: try visit(expr: node.targetType)!)
    }
    
    public func visit(unary node: Expression.Unary) throws -> Expression? {
        Expression.Unary(
            sourceAnchor: node.sourceAnchor,
            op: node.op,
            expression: try visit(expr: node.child)!)
    }
    
    public func visit(binary node: Expression.Binary) throws -> Expression? {
        Expression.Binary(
            sourceAnchor: node.sourceAnchor,
            op: node.op,
            left: try visit(expr: node.left)!,
            right: try visit(expr: node.right)!)
    }
    
    public func visit(is node: Expression.Is) throws -> Expression? {
        Expression.Is(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            testType: try visit(expr: node.testType)!)
    }
    
    public func visit(initialAssignment node: Expression.InitialAssignment) throws -> Expression? {
        Expression.InitialAssignment(
            sourceAnchor: node.sourceAnchor,
            lexpr: try visit(expr: node.lexpr)!,
            rexpr: try visit(expr: node.rexpr)!)
    }
    
    public func visit(assignment node: Expression.Assignment) throws -> Expression? {
        Expression.Assignment(
            sourceAnchor: node.sourceAnchor,
            lexpr: try visit(expr: node.lexpr)!,
            rexpr: try visit(expr: node.rexpr)!)
    }
    
    public func visit(subscript node: Expression.Subscript) throws -> Expression? {
        Expression.Subscript(
            sourceAnchor: node.sourceAnchor,
            subscriptable: try visit(expr: node.subscriptable)!,
            argument: try visit(expr: node.argument)!)
    }
    
    public func visit(get node: Expression.Get) throws -> Expression? {
        Expression.Get(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            member: try visit(expr: node.member)!)
    }
    
    public func visit(structInitializer node: Expression.StructInitializer) throws -> Expression? {
        Expression.StructInitializer(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            arguments: try node.arguments.compactMap {
                Expression.StructInitializer.Argument(
                    name: $0.name,
                    expr: try visit(expr: $0.expr)!)
            })
    }
    
    public func visit(call node: Expression.Call) throws -> Expression? {
        Expression.Call(
            sourceAnchor: node.sourceAnchor,
            callee: try visit(expr: node.callee)!,
            arguments: try node.arguments.compactMap {
                try visit(expr: $0)
            })
    }
    
    public func visit(typeof node: Expression.TypeOf) throws -> Expression? {
        Expression.TypeOf(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!)
    }
    
    public func visit(sizeof node: Expression.SizeOf) throws -> Expression? {
        Expression.SizeOf(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!)
    }
    
    public func visit(genericTypeApplication expr: Expression.GenericTypeApplication) throws -> Expression? {
        Expression.GenericTypeApplication(
            sourceAnchor: expr.sourceAnchor,
            identifier: try visit(identifier: expr.identifier) as! Expression.Identifier,
            arguments: try expr.arguments.compactMap {
                try visit(expr: $0)
            })
    }
    
    public func visit(genericTypeArgument node: Expression.GenericTypeArgument) throws -> Expression? {
        Expression.GenericTypeArgument(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Expression.Identifier,
            constraints: try node.constraints.compactMap {
                try visit(expr: $0) as! Expression.Identifier?
            })
    }
    
    public func visit(eseq node: Expression.Eseq) throws -> Expression? {
        Expression.Eseq(
            sourceAnchor: node.sourceAnchor,
            children: try node.children.compactMap {
                try visit(expr: $0)
            })
    }
    
    public func visit(primitiveType node: Expression.PrimitiveType) throws -> Expression? {
        node
    }
    
    public func visit(pointerType node: Expression.PointerType) throws -> Expression? {
        Expression.PointerType(
            sourceAnchor: node.sourceAnchor,
            typ: try visit(expr: node.typ)!)
    }
    
    public func visit(constType node: Expression.ConstType) throws -> Expression? {
        Expression.ConstType(
            sourceAnchor: node.sourceAnchor,
            typ: try visit(expr: node.typ)!)
    }
    
    public func visit(mutableType node: Expression.MutableType) throws -> Expression? {
        Expression.MutableType(
            sourceAnchor: node.sourceAnchor,
            typ: try visit(expr: node.typ)!)
    }
    
    public func visit(unionType node: Expression.UnionType) throws -> Expression? {
        Expression.UnionType(
            sourceAnchor: node.sourceAnchor,
            members: try node.members.compactMap {
                try visit(expr: $0)
            })
    }
    
    public func visit(dynamicArrayType node: Expression.DynamicArrayType) throws -> Expression? {
        Expression.DynamicArrayType(
            sourceAnchor: node.sourceAnchor,
            elementType: try visit(expr: node.elementType)!)
    }
    
    public func visit(arrayType node: Expression.ArrayType) throws -> Expression? {
        Expression.ArrayType(
            sourceAnchor: node.sourceAnchor,
            count: try node.count.flatMap {
                try visit(expr: $0)
            },
            elementType: try visit(expr: node.elementType)!)
    }
    
    public func visit(functionType node: Expression.FunctionType) throws -> Expression? {
        Expression.FunctionType(
            sourceAnchor: node.sourceAnchor,
            name: node.name,
            returnType: try visit(expr: node.returnType)!,
            arguments: try node.arguments.compactMap {
                try visit(expr: $0)
            })
    }
    
    public func visit(genericFunctionType node0: Expression.GenericFunctionType) throws -> Expression? {
        
        let template0 = node0.template
        let template1 = try visit(func: template0) as! FunctionDeclaration
        let node1 = node0.withTemplate(template1)
        return node1
    }
}
