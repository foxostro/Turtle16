//
//  CompilerPassEraseEseq.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/5/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Bubble Eseq nodes up the AST, toward the root, until they can be erased.
public final class CompilerPassEraseEseq: CompilerPass {
    public struct Options: OptionSet {
        public let rawValue: UInt
        public static let ignoreLoopCondition = Options(rawValue: 1 << 0)
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    public let options: Options
    
    public init(options: Options = [], symbols: Env? = nil) {
        self.options = options
        super.init(symbols)
    }
    
    public override func visit(eseq node0: Eseq) throws -> Expression? {
        let node1 = try super.visit(eseq: node0)
        guard let node1 = node1 as? Eseq else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: "internal compiler error: expected Eseq: \(String(describing: node1))"
            )
        }
        if node1.seq.children.isEmpty {
            return node1.expr
        }
        else if let expr = node1.expr as? Eseq {
            let node2 = node1
                .withSeq(
                    node1.seq.appending(children: expr.seq.children)
                )
                .withExpr(expr.expr)
            return node2
        }
        else {
            return node1
        }
    }

    public override func visit(
        children: [AbstractSyntaxTreeNode]
    ) throws -> [AbstractSyntaxTreeNode] {
        try children.compactMap { child0 in
            let child1 = try visit(child0)
            if let child1 = child1 as? Eseq {
                let child2 = child1.seq.appending(child: child1.expr)
                return child2
            }
            else {
                return child1
            }
        }
    }

    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(varDecl: node0)
        guard let node1 = node1 as? VarDeclaration else { return node1 }
        var node2 = node1
        var preface: [AbstractSyntaxTreeNode] = []
        if let eseq = node1.explicitType as? Eseq {
            preface += eseq.seq.children
            node2 = node2.withExplicitType(eseq.expr)
        }
        if let eseq = node1.expression as? Eseq {
            preface += eseq.seq.children
            node2 = node2.withExpression(eseq.expr)
        }
        guard !preface.isEmpty else { return node2 }
        let node3 = Seq(
            sourceAnchor: node2.sourceAnchor,
            children: preface + [node2]
        )
        return node3
    }

    public override func visit(if node0: If) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(if: node0)
        guard let node1 = node1 as? If else { return node1 }
        guard let eseq = node1.condition as? Eseq else { return node1 }
        let node2 = Seq(
            sourceAnchor: node0.sourceAnchor,
            children: eseq.seq.children + [node1.withCondition(eseq.expr)]
        )
        return node2
    }

    public override func visit(while node0: While) throws -> AbstractSyntaxTreeNode? {
        guard options.contains(.ignoreLoopCondition) || !(node0.condition is Eseq) else {
            throw CompilerError(
                sourceAnchor: node0.condition.sourceAnchor,
                message: "internal compiler error: unable to erase an Eseq when used as the condition of a while-loop"
            )
        }
        return try super.visit(while: node0)
    }

    public override func visit(forIn node0: ForIn) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(forIn: node0)
        guard let node1 = node1 as? ForIn else { return node1 }
        guard let eseq = node1.sequenceExpr as? Eseq else { return node1 }
        let node2 = Seq(
            sourceAnchor: node1.sourceAnchor,
            children: eseq.seq.children + [node1.withSequenceExpr(eseq.expr)]
        )
        return node2
    }

    public override func visit(return node0: Return) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(return: node0)
        guard let node1 = node1 as? Return else { return node1 }
        guard let eseq = node1.expression as? Eseq else { return node1 }
        let node2 = Seq(
            sourceAnchor: node1.sourceAnchor,
            children: eseq.seq.children + [node1.withExpression(eseq.expr)]
        )
        return node2
    }

    public override func visit(match node0: Match) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(match: node0)
        guard let node1 = node1 as? Match else { return node1 }
        guard let eseq = node1.expr as? Eseq else { return node1 }
        let node2 = Seq(
            sourceAnchor: node1.sourceAnchor,
            children: eseq.seq.children + [node1.withExpr(eseq.expr)]
        )
        return node2
    }

    public override func visit(assert node0: Assert) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(assert: node0)
        guard let node1 = node1 as? Assert else { return node1 }
        guard let eseq = node1.condition as? Eseq else { return node1 }
        let node2 = Seq(
            sourceAnchor: node1.sourceAnchor,
            children: eseq.seq.children + [node1.withCondition(eseq.expr)]
        )
        return node2
    }

    public override func visit(gotoIfFalse node0: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(gotoIfFalse: node0)
        guard let node1 = node1 as? GotoIfFalse else { return node1 }
        guard let eseq = node1.condition as? Eseq else { return node1 }
        let node2 = Seq(
            sourceAnchor: node1.sourceAnchor,
            children: eseq.seq.children + [node1.withCondition(eseq.expr)]
        )
        return node2
    }

    public override func visit(literalArray node0: LiteralArray) throws -> Expression? {
        let node1 = try super.visit(literalArray: node0)
        guard let node1 = node1 as? LiteralArray else { return node1 }
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        let elements = node1.elements.map { element in
            guard let eseq = element as? Eseq else { return element }
            seq = seq.appending(children: eseq.seq.children)
            return eseq.expr
        }
        guard !seq.children.isEmpty else { return node1 }
        let node2 = node1.withElements(elements)
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(as node0: As) throws -> Expression? {
        let node1 = try super.visit(as: node0)
        guard let node1 = node1 as? As else { return node1 }
        guard let eseq = node1.expr as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withExpr(eseq.expr)
        )
        return node2
    }

    public override func visit(bitcast node0: Bitcast) throws -> Expression? {
        let node1 = try super.visit(bitcast: node0)
        guard let node1 = node1 as? Bitcast else { return node1 }
        guard let eseq = node1.expr as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withExpr(eseq.expr)
        )
        return node2
    }

    public override func visit(unary node0: Unary) throws -> Expression? {
        let node1 = try super.visit(unary: node0)
        guard let node1 = node1 as? Unary else { return node1 }
        guard let eseq = node1.child as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withExpression(eseq.expr)
        )
        return node2
    }

    public override func visit(binary node0: Binary) throws -> Expression? {
        let node1 = try super.visit(binary: node0)
        guard let node1 = node1 as? Binary else { return node1 }
        var node2 = node1
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        if let eseq = node1.left as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withLeft(eseq.expr)
        }
        if let eseq = node1.right as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withRight(eseq.expr)
        }
        guard !seq.children.isEmpty else { return node1 }
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(is node0: Is) throws -> Expression? {
        let node1 = try super.visit(is: node0)
        guard let node1 = node1 as? Is else { return node1 }
        guard let eseq = node1.expr as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withExpr(eseq.expr)
        )
        return node2
    }

    public override func visit(initialAssignment node0: InitialAssignment) throws -> Expression? {
        let node1 = try super.visit(initialAssignment: node0)
        guard let node1 = node1 as? InitialAssignment else { return node1 }
        var node2 = node1
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        if let eseq = node1.lexpr as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withLexpr(eseq.expr)
        }
        if let eseq = node1.rexpr as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withRexpr(eseq.expr)
        }
        guard !seq.children.isEmpty else { return node1 }
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(assignment node0: Assignment) throws -> Expression? {
        let node1 = try super.visit(assignment: node0)
        guard let node1 = node1 as? Assignment else { return node1 }
        var node2 = node1
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        if let eseq = node1.lexpr as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withLexpr(eseq.expr)
        }
        if let eseq = node1.rexpr as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withRexpr(eseq.expr)
        }
        guard !seq.children.isEmpty else { return node1 }
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(subscript node0: Subscript) throws -> Expression? {
        let node1 = try super.visit(subscript: node0)
        guard let node1 = node1 as? Subscript else { return node1 }
        var node2 = node1
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        if let eseq = node1.subscriptable as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withSubscriptable(eseq.expr)
        }
        if let eseq = node1.argument as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withArgument(eseq.expr)
        }
        guard !seq.children.isEmpty else { return node1 }
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(get node0: Get) throws -> Expression? {
        let node1 = try super.visit(get: node0)
        guard let node1 = node1 as? Get else { return node1 }
        var node2 = node1
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        if let eseq = node1.expr as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withExpr(eseq.expr)
        }
        if let eseq = node1.member as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withMember(eseq.expr)
        }
        guard !seq.children.isEmpty else { return node1 }
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(structInitializer node0: StructInitializer) throws -> Expression? {
        let node1 = try super.visit(structInitializer: node0)
        guard let node1 = node1 as? StructInitializer else { return node1 }
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        let arguments = node1.arguments.map { arg in
            guard let eseq = arg.expr as? Eseq else { return arg }
            seq = seq.appending(children: eseq.seq.children)
            return arg.withExpr(eseq.expr)
        }
        guard !seq.children.isEmpty else { return node1 }
        let node2 = node1.withArguments(arguments)
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(call node0: Call) throws -> Expression? {
        let node1 = try super.visit(call: node0)
        guard let node1 = node1 as? Call else { return node1 }
        var node2 = node1
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        if let eseq = node1.callee as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node1.withCallee(eseq.expr)
        }
        let arguments = node2.arguments.map { arg in
            guard let eseq = arg as? Eseq else { return arg }
            seq = seq.appending(children: eseq.seq.children)
            return eseq.expr
        }
        node2 = node2.withArguments(arguments)
        guard !seq.children.isEmpty else { return node1 }
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(sizeof node0: SizeOf) throws -> Expression? {
        let node1 = try super.visit(sizeof: node0)
        guard let node1 = node1 as? SizeOf else { return node1 }
        guard let eseq = node1.expr as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withExpr(eseq.expr)
        )
        return node2
    }

    public override func visit(typeof node0: TypeOf) throws -> Expression? {
        let node1 = try super.visit(typeof: node0)
        guard let node1 = node1 as? TypeOf else { return node1 }
        guard let eseq = node1.expr as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withExpr(eseq.expr)
        )
        return node2
    }

    public override func visit(pointerType node0: PointerType) throws -> Expression? {
        let node1 = try super.visit(pointerType: node0)
        guard let node1 = node1 as? PointerType else { return node1 }
        guard let eseq = node1.typ as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withTyp(eseq.expr)
        )
        return node2
    }

    public override func visit(constType node0: ConstType) throws -> Expression? {
        let node1 = try super.visit(constType: node0)
        guard let node1 = node1 as? ConstType else { return node1 }
        guard let eseq = node1.typ as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withTyp(eseq.expr)
        )
        return node2
    }

    public override func visit(mutableType node0: MutableType) throws -> Expression? {
        let node1 = try super.visit(mutableType: node0)
        guard let node1 = node1 as? MutableType else { return node1 }
        guard let eseq = node1.typ as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withTyp(eseq.expr)
        )
        return node2
    }

    public override func visit(unionType node0: UnionType) throws -> Expression? {
        let node1 = try super.visit(unionType: node0)
        guard let node1 = node1 as? UnionType else { return node1 }
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        let members = node1.members.map { member in
            guard let eseq = member as? Eseq else { return member }
            seq = seq.appending(children: eseq.seq.children)
            return eseq.expr
        }
        guard !seq.children.isEmpty else { return node1 }
        let node2 = node1.withMembers(members)
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(
        dynamicArrayType node0: DynamicArrayType
    ) throws -> Expression? {
        let node1 = try super.visit(dynamicArrayType: node0)
        guard let node1 = node1 as? DynamicArrayType else { return node1 }
        guard let eseq = node1.elementType as? Eseq else { return node1 }
        let node2 = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: eseq.seq,
            expr: node1.withElementType(eseq.expr)
        )
        return node2
    }

    public override func visit(arrayType node0: ArrayType) throws -> Expression? {
        let node1 = try super.visit(arrayType: node0)
        guard let node1 = node1 as? ArrayType else { return node1 }
        var node2 = node1
        var seq = Seq(sourceAnchor: node0.sourceAnchor, children: [])
        if let eseq = node1.count as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withCount(eseq.expr)
        }
        if let eseq = node1.elementType as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withElementType(eseq.expr)
        }
        guard !seq.children.isEmpty else { return node2 }
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(functionType node0: FunctionType) throws -> Expression? {
        let node1 = try super.visit(functionType: node0)
        guard var node2 = node1 as? FunctionType else { return node1 }
        var seq = Seq(sourceAnchor: node2.sourceAnchor)
        if let eseq = node2.returnType as? Eseq {
            seq = seq.appending(children: eseq.seq.children)
            node2 = node2.withReturnType(eseq.expr)
        }
        let arguments = node2.arguments.map { arg in
            guard let eseq = arg as? Eseq else { return arg }
            seq = seq.appending(children: eseq.seq.children)
            return eseq.expr
        }
        guard !seq.children.isEmpty else { return node1 }
        node2 = node2.withArguments(arguments)
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }

    public override func visit(
        genericTypeApplication node0: GenericTypeApplication
    ) throws -> Expression? {
        let node1 = try super.visit(genericTypeApplication: node0)
        guard let node1 = node1 as? GenericTypeApplication else { return node1 }
        var seq = Seq(sourceAnchor: node1.sourceAnchor)
        let arguments = node1.arguments.map { arg in
            guard let eseq = arg as? Eseq else { return arg }
            seq = seq.appending(children: eseq.seq.children)
            return eseq.expr
        }
        guard !seq.children.isEmpty else { return node1 }
        let node2 = node1.withArguments(arguments)
        let node3 = Eseq(
            sourceAnchor: node2.sourceAnchor,
            seq: seq,
            expr: node2
        )
        return node3
    }
}

extension AbstractSyntaxTreeNode {
    /// Bubble Eseq nodes up the AST, toward the root, until they can be erased.
    public func eraseEseq(
        options opts: CompilerPassEraseEseq.Options = []
    ) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseEseq(options: opts).visit(self)
    }
}
