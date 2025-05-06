//
//  CompilerPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CompilerPass {
    struct EnvStack {
        private var stack: [Env] = []

        var symbols: Env? {
            stack.last
        }

        mutating func push(_ newSymbols: Env) {
            stack.append(newSymbols)
        }

        mutating func pop() {
            stack.removeLast().performDeferredActions()
        }
    }
    var env = EnvStack()

    public var symbols: Env? {
        env.symbols
    }

    public init(_ symbols: Env? = nil) {
        if let symbols {
            env.push(symbols)
        }
    }

    /// Override in a subclass to specify actions to perform before and after
    /// visiting the nodes in the tree.
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
            try outerVisit(func: node)
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
        case let node as LabelDeclaration:
            try visit(label: node)
        default:
            genericNode
        }
    }
    
    public func visit(children: [AbstractSyntaxTreeNode]) throws -> [AbstractSyntaxTreeNode] {
        try children.compactMap { try visit($0) }
    }

    public func visit(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        node.withChildren(try visit(children: node.children))
    }

    public func visit(subroutine node: Subroutine) throws -> AbstractSyntaxTreeNode? {
        node.withChildren(try visit(children: node.children))
    }

    public func visit(seq node: Seq) throws -> AbstractSyntaxTreeNode? {
        node.withChildren(try visit(children: node.children))
    }

    public func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        guard let identifier = try visit(identifier: node0.identifier) as? Identifier else {
            throw CompilerError(
                sourceAnchor: node0.identifier.sourceAnchor,
                message: "expected identifier: `\(node0.identifier)'"
            )
        }
        let node1 = VarDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: identifier,
            explicitType: try node0.explicitType.flatMap { try visit(expr: $0) },
            expression: try node0.expression.flatMap { try visit(expr: $0) },
            storage: node0.storage,
            isMutable: node0.isMutable,
            visibility: node0.visibility,
            id: node0.id
        )
        return node1
    }

    public func visit(if node: If) throws -> AbstractSyntaxTreeNode? {
        If(
            sourceAnchor: node.sourceAnchor,
            condition: try visit(expr: node.condition)!,
            then: try visit(node.thenBranch)!,
            else: try node.elseBranch.flatMap { try visit($0) },
            id: node.id
        )
    }

    public func visit(while node: While) throws -> AbstractSyntaxTreeNode? {
        While(
            sourceAnchor: node.sourceAnchor,
            condition: try visit(expr: node.condition)!,
            body: try visit(node.body)!,
            id: node.id
        )
    }

    public func visit(forIn node: ForIn) throws -> AbstractSyntaxTreeNode? {
        ForIn(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Identifier,
            sequenceExpr: try visit(expr: node.sequenceExpr)!,
            body: try visit(node.body) as! Block,
            id: node.id
        )
    }

    public func visit(block node0: Block) throws -> AbstractSyntaxTreeNode? {
        try willVisit(block: node0)
        let node1 = node0.withChildren(try visit(children: node0.children))
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
        node.withExpression(
            try node.expression.flatMap {
                try visit(expr: $0)
            }
        )
    }

    private func outerVisit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let val: AbstractSyntaxTreeNode?
        try willVisit(func: node)
        val = try visit(func: node)
        didVisit(func: node)
        return val
    }

    public func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        FunctionDeclaration(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Identifier,
            functionType: try visit(expr: node.functionType) as! FunctionType,
            argumentNames: node.argumentNames,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! GenericTypeArgument?
            },
            body: try visit(node.body) as! Block,
            visibility: node.visibility,
            symbols: node.symbols,
            id: node.id
        )
    }

    public func willVisit(func node: FunctionDeclaration) throws {
        env.push(node.symbols)
    }

    public func didVisit(func node: FunctionDeclaration) {
        env.pop()
    }

    public func visit(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let maybeIdentNode = try visit(identifier: node0.identifier)
        guard let identifier = maybeIdentNode as? Identifier else {
            throw CompilerError(
                sourceAnchor: node0.identifier.sourceAnchor,
                message: "expected identifier: `\(node0.identifier)'"
            )
        }
        let node1 = StructDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: identifier,
            typeArguments: try node0.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! GenericTypeArgument?
            },
            members: try node0.members.map {
                StructDeclaration.Member(
                    name: $0.name,
                    type: try visit(expr: $0.memberType)!
                )
            },
            visibility: node0.visibility,
            isConst: node0.isConst,
            associatedTraitType: node0.associatedTraitType,
            id: node0.id
        )
        return node1
    }

    public func visit(impl node: Impl) throws -> AbstractSyntaxTreeNode? {
        Impl(
            sourceAnchor: node.sourceAnchor,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! GenericTypeArgument?
            },
            structTypeExpr: try visit(expr: node.structTypeExpr)!,
            children: try visit(children: node.children).compactMap {
                $0 as? FunctionDeclaration
            },
            id: node.id
        )
    }

    public func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        ImplFor(
            sourceAnchor: node.sourceAnchor,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! GenericTypeArgument?
            },
            traitTypeExpr: try visit(expr: node.traitTypeExpr)!,
            structTypeExpr: try visit(expr: node.structTypeExpr)!,
            children: try visit(children: node.children).compactMap {
                $0 as? FunctionDeclaration
            },
            id: node.id
        )
    }

    public func visit(match node: Match) throws -> AbstractSyntaxTreeNode? {
        Match(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            clauses: try node.clauses.map {
                Match.Clause(
                    sourceAnchor: $0.sourceAnchor,
                    valueIdentifier: try visit(identifier: $0.valueIdentifier) as! Identifier,
                    valueType: try visit(expr: $0.valueType)!,
                    block: try visit(clause: $0, in: node)
                )
            },
            elseClause: try visit(node.elseClause) as? Block,
            id: node.id
        )
    }

    private func visit(clause: Match.Clause, in match: Match) throws -> Block {
        let node0 = clause.block
        try willVisit(block: node0, clause: clause, in: match)
        let node1 = node0.withChildren(try visit(children: node0.children))
        didVisit(block: node0, clause: clause, in: match)
        return node1
    }

    /// Called when the compiler pass is about to visit the specified match clause's block
    public func willVisit(block: Block, clause: Match.Clause, in match: Match) throws {
        env.push(block.symbols)
    }

    /// Called when the compiler pass has just visited the specified match clause's block
    public func didVisit(block: Block, clause: Match.Clause, in match: Match) {
        env.pop()
    }

    public func visit(assert node: Assert) throws -> AbstractSyntaxTreeNode? {
        node.withCondition(try visit(expr: node.condition)!)
    }

    public func visit(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        TraitDeclaration(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Identifier,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! GenericTypeArgument?
            },
            members: try node.members.map {
                TraitDeclaration.Member(
                    name: $0.name,
                    type: try visit(expr: $0.memberType)!
                )
            },
            visibility: node.visibility,
            mangledName: node.mangledName,
            id: node.id
        )
    }

    public func visit(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        node.withBody(try visit(node.body) as! Block)
    }

    public func visit(typealias node: Typealias) throws -> AbstractSyntaxTreeNode? {
        Typealias(
            sourceAnchor: node.sourceAnchor,
            lexpr: try visit(identifier: node.lexpr) as! Identifier,
            rexpr: try visit(expr: node.rexpr)!,
            visibility: node.visibility,
            id: node.id
        )
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
        node.withCondition(try visit(expr: node.condition)!)
    }

    public func visit(instruction node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        node
    }

    public func visit(tack node: TackInstructionNode) throws -> AbstractSyntaxTreeNode? {
        node
    }

    public func visit(label node: LabelDeclaration) throws -> LabelDeclaration {
        node
    }

    public func visit(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        try visit(expr: node)
    }

    public func visit(expr: Expression) throws -> Expression? {
        switch expr {
        case let node as UnsupportedExpression:
            try visit(unsupported: node)
        case let literal as LiteralInt:
            try visit(literalInt: literal)
        case let literal as LiteralBool:
            try visit(literalBoolean: literal)
        case let node as Identifier:
            try visit(identifier: node)
        case let node as Unary:
            try visit(unary: node)
        case let group as Group:
            try visit(expr: group.expression)
        case let eseq as Eseq:
            try visit(eseq: eseq)
        case let node as Binary:
            try visit(binary: node)
        case let expr as InitialAssignment:
            try visit(initialAssignment: expr)
        case let expr as Assignment:
            try visit(assignment: expr)
        case let node as Call:
            try visit(call: node)
        case let node as As:
            try visit(as: node)
        case let node as Bitcast:
            try visit(bitcast: node)
        case let expr as Is:
            try visit(is: expr)
        case let expr as Subscript:
            try visit(subscript: expr)
        case let literal as LiteralArray:
            try visit(literalArray: literal)
        case let expr as Get:
            try visit(get: expr)
        case let expr as PrimitiveType:
            try visit(primitiveType: expr)
        case let expr as DynamicArrayType:
            try visit(dynamicArrayType: expr)
        case let expr as ArrayType:
            try visit(arrayType: expr)
        case let expr as FunctionType:
            try visit(functionType: expr)
        case let expr as GenericFunctionType:
            try visit(genericFunctionType: expr)
        case let node as GenericTypeApplication:
            try visit(genericTypeApplication: node)
        case let node as GenericTypeArgument:
            try visit(genericTypeArgument: node)
        case let node as PointerType:
            try visit(pointerType: node)
        case let node as ConstType:
            try visit(constType: node)
        case let node as MutableType:
            try visit(mutableType: node)
        case let node as UnionType:
            try visit(unionType: node)
        case let node as StructInitializer:
            try visit(structInitializer: node)
        case let literal as LiteralString:
            try visit(literalString: literal)
        case let node as TypeOf:
            try visit(typeof: node)
        case let node as SizeOf:
            try visit(sizeof: node)
        default:
            throw CompilerError(message: "unimplemented: `\(expr)'")
        }
    }

    public func visit(unsupported node: UnsupportedExpression) throws -> Expression? {
        node
    }

    public func visit(literalInt node: LiteralInt) throws -> Expression? {
        node
    }

    public func visit(literalBoolean node: LiteralBool) throws -> Expression? {
        node
    }

    public func visit(literalArray expr: LiteralArray) throws -> Expression? {
        LiteralArray(
            sourceAnchor: expr.sourceAnchor,
            arrayType: try visit(expr: expr.arrayType)!,
            elements: try expr.elements.compactMap {
                try visit(expr: $0)
            },
            id: expr.id
        )
    }

    public func visit(literalString expr: LiteralString) throws -> Expression? {
        expr
    }

    public func visit(identifier node: Identifier) throws -> Expression? {
        node
    }

    public func visit(as expr: As) throws -> Expression? {
        As(
            sourceAnchor: expr.sourceAnchor,
            expr: try visit(expr: expr.expr)!,
            targetType: try visit(expr: expr.targetType)!,
            id: expr.id
        )
    }

    public func visit(bitcast node: Bitcast) throws -> Expression? {
        Bitcast(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            targetType: try visit(expr: node.targetType)!,
            id: node.id
        )
    }

    public func visit(unary node: Unary) throws -> Expression? {
        node.withExpression(try visit(expr: node.child)!)
    }

    public func visit(binary node: Binary) throws -> Expression? {
        Binary(
            sourceAnchor: node.sourceAnchor,
            op: node.op,
            left: try visit(expr: node.left)!,
            right: try visit(expr: node.right)!,
            id: node.id
        )
    }

    public func visit(is node: Is) throws -> Expression? {
        Is(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            testType: try visit(expr: node.testType)!,
            id: node.id
        )
    }

    public func visit(initialAssignment node: InitialAssignment) throws -> Expression? {
        InitialAssignment(
            sourceAnchor: node.sourceAnchor,
            lexpr: try visit(expr: node.lexpr)!,
            rexpr: try visit(expr: node.rexpr)!,
            id: node.id
        )
    }

    public func visit(assignment node: Assignment) throws -> Expression? {
        Assignment(
            sourceAnchor: node.sourceAnchor,
            lexpr: try visit(expr: node.lexpr)!,
            rexpr: try visit(expr: node.rexpr)!,
            id: node.id
        )
    }

    public func visit(subscript node: Subscript) throws -> Expression? {
        Subscript(
            sourceAnchor: node.sourceAnchor,
            subscriptable: try visit(expr: node.subscriptable)!,
            argument: try visit(expr: node.argument)!,
            id: node.id
        )
    }

    public func visit(get node: Get) throws -> Expression? {
        Get(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            member: try visit(expr: node.member)!
        )
    }

    public func visit(structInitializer node: StructInitializer) throws -> Expression? {
        StructInitializer(
            sourceAnchor: node.sourceAnchor,
            expr: try visit(expr: node.expr)!,
            arguments: try node.arguments.compactMap {
                StructInitializer.Argument(
                    name: $0.name,
                    expr: try visit(expr: $0.expr)!
                )
            },
            id: node.id
        )
    }

    public func visit(call node: Call) throws -> Expression? {
        Call(
            sourceAnchor: node.sourceAnchor,
            callee: try visit(expr: node.callee)!,
            arguments: try node.arguments.compactMap {
                try visit(expr: $0)
            },
            id: node.id
        )
    }

    public func visit(typeof node: TypeOf) throws -> Expression? {
        node.withExpr(try visit(expr: node.expr)!)
    }

    public func visit(sizeof node: SizeOf) throws -> Expression? {
        node.withExpr(try visit(expr: node.expr)!)
    }

    public func visit(genericTypeApplication expr: GenericTypeApplication) throws -> Expression? {
        GenericTypeApplication(
            sourceAnchor: expr.sourceAnchor,
            identifier: try visit(identifier: expr.identifier) as! Identifier,
            arguments: try expr.arguments.compactMap {
                try visit(expr: $0)
            },
            id: expr.id
        )
    }

    public func visit(genericTypeArgument node: GenericTypeArgument) throws -> Expression? {
        GenericTypeArgument(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Identifier,
            constraints: try node.constraints.compactMap {
                try visit(expr: $0) as! Identifier?
            },
            id: node.id
        )
    }

    public func visit(eseq node: Eseq) throws -> Expression? {
        node
            .withSeq(try visit(seq: node.seq) as! Seq)
            .withExpr(try visit(expr: node.expr)!)
    }

    public func visit(primitiveType node: PrimitiveType) throws -> Expression? {
        node
    }

    public func visit(pointerType node: PointerType) throws -> Expression? {
        node.withTyp(try visit(expr: node.typ)!)
    }

    public func visit(constType node: ConstType) throws -> Expression? {
        node.withTyp(try visit(expr: node.typ)!)
    }

    public func visit(mutableType node: MutableType) throws -> Expression? {
        node.withTyp(try visit(expr: node.typ)!)
    }

    public func visit(unionType node: UnionType) throws -> Expression? {
        node.withMembers(
            try node.members.compactMap {
                try visit(expr: $0)
            }
        )
    }

    public func visit(dynamicArrayType node: DynamicArrayType) throws -> Expression? {
        node.withElementType(try visit(expr: node.elementType)!)
    }

    public func visit(arrayType node: ArrayType) throws -> Expression? {
        ArrayType(
            sourceAnchor: node.sourceAnchor,
            count: try node.count.flatMap {
                try visit(expr: $0)
            },
            elementType: try visit(expr: node.elementType)!,
            id: node.id
        )
    }

    public func visit(functionType node: FunctionType) throws -> Expression? {
        FunctionType(
            sourceAnchor: node.sourceAnchor,
            name: node.name,
            returnType: try visit(expr: node.returnType)!,
            arguments: try node.arguments.compactMap {
                try visit(expr: $0)
            },
            id: node.id
        )
    }

    public func visit(genericFunctionType node0: GenericFunctionType) throws -> Expression? {
        let template0 = node0.template
        let template1 = try visit(func: template0) as! FunctionDeclaration
        let node1 = node0.withTemplate(template1)
        return node1
    }
}
