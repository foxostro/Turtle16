//
//  CompilerPassDecomposeExpressions.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/3/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Decompose expressions into simple expressions connected by temporary values
/// Here, "simple expression" means an irreducible expression that cannot be
/// broken up into smaller pieces of Snap code. The aim is for each simple
/// expression to have a straight-forward mapping to a sequence of Tack code in
/// a subsequent compiler pass.
public final class CompilerPassDecomposeExpressions: CompilerPassWithDeclScan {
    let tempPrefix = "__temp"
    let pointee = "pointee"

    #if false
        public override func postProcess(
            _ node: AbstractSyntaxTreeNode?
        ) throws -> AbstractSyntaxTreeNode? {
            try node?.eraseEseq()?.flatten()
        }
    #endif
    
    public override func visit(
        return node: Return
    ) throws -> AbstractSyntaxTreeNode? {
        guard let e = node.expression else { return node }
        return node.withExpression(
            try extract(expr: try visit(expr: e))
        )
    }
    
    public override func visit(if node: If) throws -> AbstractSyntaxTreeNode? {
        node.withCondition(
            try extract(expr: try visit(expr: node.condition))!
        )
    }
    
    public override func visit(while node: While) throws -> AbstractSyntaxTreeNode? {
        node.withCondition(
            try extract(expr: try visit(expr: node.condition))!
        )
    }
    
    public override func visit(forIn node: ForIn) throws -> AbstractSyntaxTreeNode? {
        node.withSequenceExpr(
            try extract(expr: try visit(expr: node.sequenceExpr))!
        )
    }
    
    public override func visit(match node: Match) throws -> AbstractSyntaxTreeNode? {
        node.withExpr(
            try extract(expr: try visit(expr: node.expr))!
        )
    }
    
    public override func visit(assert node: Assert) throws -> AbstractSyntaxTreeNode? {
        node.withCondition(
            try extract(expr: try visit(expr: node.condition))!
        )
    }
    
    public override func visit(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        node.withCondition(
            try extract(expr: try visit(expr: node.condition))!
        )
    }

    public override func visit(
        expressionStatement node0: Expression
    ) throws -> AbstractSyntaxTreeNode? {
        try visit(expr: node0)
    }

    public override func visit(as node0: As) throws -> Expression? {
        let expr0 = node0.expr
        let expr1: Expression! = try extract(expr: try visit(expr: expr0))
        let node1 = node0.withExpr(expr1)
        return node1
    }

    public override func visit(bitcast node0: Bitcast) throws -> Expression? {
        node0.withExpr(
            try extract(expr: try visit(expr: node0.expr))!
        )
    }

    public override func visit(binary node0: Binary) throws -> Expression? {
        node0
            .withLeft(
                try extract(expr: try visit(expr: node0.left))!
            )
            .withRight(
                try extract(expr: try visit(expr: node0.right))!
            )
    }
    
    public override func visit(unary node0: Unary) throws -> Expression? {
        switch node0.child {
        case is Identifier where node0.op == .ampersand:
            // In the case where we're taking the address of a bare identifier,
            // the expression is already irriducible. We can't extract the
            // identifier without changing the meaning of the expression.
            assert(!isCompilerTemporary(node0))
            return try super.visit(unary: node0)
            
        case is Get where node0.op == .ampersand:
            // In the case where we're taking the address of some field in a
            // struct, the expression may be reduced by extracting the object
            // of the Get expression, but the Get expression itself may not be
            // extracted without changing the meaning of the expression.
            return try super.visit(unary: node0)
            
        default:
            // In all other cases, decompose the expression by extracting the
            // value of the child to a new temp value and then apply the
            // operator to the temp value.
            return node0.withExpression(
                try extract(expr: try visit(expr: node0.child))!
            )
        }
    }

    public override func visit(is node: Is) throws -> Expression? {
        let a = try rvalueContext.check(expression: node.expr)
        let b = try typeContext.check(expression: node.testType)
        let result = LiteralBool(a == b)
        return result
    }

    public override func visit(assignment node0: Assignment) throws -> Expression? {
        switch node0.rexpr {
        case is LiteralArray:
            // Special case for expressions of the form
            // `Assignment(_, LiteralArray(...))`, that is, an assignment
            // with an array literal on the right-hand side.
            return try decomposeAssignmentWithLiteralArray(node0)
            
        case is LiteralString:
            // Special case for expressions of the form
            // `Assignment(_, LiteralString(...))`, that is, an assignment
            // with a string literal on the right-hand side.
            return try decomposeAssignmentWithLiteralString(node0)
            
        case is StructInitializer:
            // Special case for expressions of the form
            // `Assignment(_, StructInitializer(...))`, that is, an assignment
            // with a struct initializer on the right-hand side.
            return try decomposeAssignmentWithStructInitializer(node0)
            
        default:
            let lexpr = try lextract(expr: try visit(expr: node0.lexpr))!
            let rexpr = try extract(expr: try visit(expr: node0.rexpr))!
            let node1 = node0
                .withLexpr(lexpr)
                .withRexpr(rexpr)
            return node1
        }
    }
    
    private func decomposeAssignmentWithLiteralArray(_ node0: Assignment) throws -> Expression? {
        // Expressions of the form `Assignment(_, LiteralArray(...))`,
        // are decomposed into a sequence of assignments, one for each
        // element in the literal array.
        let arr = node0.rexpr as! LiteralArray
        let lexpr = try visit(expr: node0.lexpr)!
        
        let dstPtr = Identifier(
            sourceAnchor: lexpr.sourceAnchor,
            identifier: nextTempName()
        )
        let dstPtrDecl = VarDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: dstPtr,
            explicitType: nil,
            expression: Unary(
                sourceAnchor: node0.sourceAnchor,
                op: .ampersand,
                expression: lexpr
            ),
            storage: .automaticStorage(offset: nil),
            isMutable: false,
            visibility: .privateVisibility
        )
        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(dstPtrDecl)
        
        let elements = try arr.elements.enumerated().map { (i, el) in
            Assignment(
                sourceAnchor: node0.sourceAnchor,
                lexpr: try extractByPointer(
                    expr: Subscript(
                        sourceAnchor: node0.sourceAnchor,
                        subscriptable: dstPtr,
                        argument: try extract(expr: LiteralInt(i))!
                    )
                ),
                rexpr: try extract(expr: el)!
            )
        }
        
        let eseq = Eseq(
            sourceAnchor: node0.sourceAnchor,
            seq: Seq(
                sourceAnchor: node0.sourceAnchor,
                children: [dstPtrDecl] + elements
            ),
            expr: Get(
                sourceAnchor: node0.sourceAnchor,
                expr: dstPtr,
                member: Identifier(
                    sourceAnchor: node0.sourceAnchor,
                    identifier: pointee
                )
            )
        )
        return eseq
    }
    
    private func decomposeAssignmentWithLiteralString(_ node0: Assignment) throws -> Expression? {
        throw CompilerError(
            sourceAnchor: node0.sourceAnchor,
            message: "internal compiler error: unimplemented"
        )
    }
    
    private func decomposeAssignmentWithStructInitializer(_ node0: Assignment) throws -> Expression? {
        throw CompilerError(
            sourceAnchor: node0.sourceAnchor,
            message: "internal compiler error: unimplemented"
        )
    }

    public override func visit(subscript node0: Subscript) throws -> Expression? {
        let argument = try extract(expr: try visit(expr: node0.argument))
        let subscriptable = try extract(
            expr: Unary(
                sourceAnchor: node0.sourceAnchor,
                op: .ampersand,
                expression: try visit(expr: node0.subscriptable)!
            )
        )
        let node1 = node0
            .withArgument(argument!)
            .withSubscriptable(subscriptable!)
        return node1
    }

    public override func visit(get node0: Get) throws -> Expression? {
        // If the object of the Get expression is something that evaluates to a
        // pointer type then extract that pointer value to a new temporary.
        let objectType = try rvalueContext.check(expression: node0.expr)
        guard objectType.isPointerType else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: "internal compiler error: At this point, all Get expressions should have an object of a pointer type, not `\(objectType)`"
            )
        }
        
        return node0.withExpr(
            try extract(expr: try visit(expr: node0.expr))!
        )
    }

    public override func visit(structInitializer node0: StructInitializer) throws -> Expression? {
        guard [.concrete, .temporary].contains(context) else { return node0 }

        let backingStorage = Identifier(
            sourceAnchor: node0.sourceAnchor,
            identifier: nextTempName()
        )

        let backingStorageDecl: AbstractSyntaxTreeNode! = try visit(
            VarDeclaration(
                sourceAnchor: node0.sourceAnchor,
                identifier: backingStorage,
                explicitType: node0.expr,
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        )
        
        var children: [AbstractSyntaxTreeNode] = [
            backingStorageDecl
        ]
        
        if node0.arguments.count > 0 {
            let dst = Identifier(
                sourceAnchor: node0.sourceAnchor,
                identifier: nextTempName()
            )
            
            let dstDecl: AbstractSyntaxTreeNode! = try visit(
                VarDeclaration(
                    sourceAnchor: node0.sourceAnchor,
                    identifier: dst,
                    explicitType: nil,
                    expression: Unary(
                        sourceAnchor: node0.sourceAnchor,
                        op: .ampersand,
                        expression: backingStorage
                    ),
                    storage: .automaticStorage(offset: nil),
                    isMutable: false,
                    visibility: .privateVisibility
                )
            )
            
            children.append(dstDecl)
            
            if let firstArg = node0.arguments.first {
                let child: Expression! = try visit(
                    initialAssignment: InitialAssignment(
                        sourceAnchor: node0.sourceAnchor,
                        lexpr: Get(
                            sourceAnchor: node0.sourceAnchor,
                            expr: dst,
                            member: Identifier(
                                sourceAnchor: node0.sourceAnchor,
                                identifier: firstArg.name
                            )
                        ),
                        rexpr: firstArg.expr
                    )
                )
                children.append(child)
            }
            
            if node0.arguments.count > 1 {
                children += try node0.arguments[1...].map { arg in
                    let child: Expression! = try visit(
                        initialAssignment: InitialAssignment(
                            sourceAnchor: node0.sourceAnchor,
                            lexpr: Get(
                                sourceAnchor: node0.sourceAnchor,
                                expr: dst,
                                member: Identifier(
                                    sourceAnchor: node0.sourceAnchor,
                                    identifier: arg.name
                                )
                            ),
                            rexpr: arg.expr
                        )
                    )
                    return child
                }
            }
        }

        let eseq = Eseq(
            sourceAnchor: node0.sourceAnchor,
            seq: Seq(
                sourceAnchor: node0.sourceAnchor,
                children: children
            ),
            expr: backingStorage
        )
        return eseq
    }

    public override func visit(call node0: Call) throws -> Expression? {
        node0
            .withArguments(
                try node0.arguments.map { arg in
                    try extract(expr: try visit(expr: arg))!
                }
            )
            .withCallee(try {
                if try rvalueContext.check(expression: node0.callee).isPointerType {
                    try extract(expr: node0.callee)!
                }
                else {
                    node0.callee
                }
            }())
    }

    public override func visit(typeof node: TypeOf) throws -> Expression? {
        try rvalueContext.check(expression: node).lift
    }

    public override func visit(sizeof node: SizeOf) throws -> Expression? {
        let type = try rvalueContext.check(expression: node.expr)
        let size = memoryLayoutStrategy.sizeof(type: type)
        return LiteralInt(
            sourceAnchor: node.sourceAnchor,
            value: size
        )
    }
    
    func extract(expr: Expression?) throws -> Expression? {
        guard [.concrete, .temporary].contains(context) else { return expr }
        guard let expr else { return nil }
        guard !isCompilerTemporary(expr) else { return expr }
            
        let exprType = try rvalueContext.check(expression: expr)
        guard !exprType.isPrimitive else {
            return try extractByValue(expr)
        }
        
        guard !(expr is LiteralString) && !(expr is LiteralArray) else {
            return try extractByValue(expr)
        }
    
        let temp = Identifier(
            sourceAnchor: expr.sourceAnchor,
            identifier: nextTempName()
        )
        let tempDecl = VarDeclaration(
            sourceAnchor: expr.sourceAnchor,
            identifier: temp,
            explicitType: nil,
            expression: Unary(
                sourceAnchor: expr.sourceAnchor,
                op: .ampersand,
                expression: expr
            ),
            storage: .automaticStorage(offset: nil),
            isMutable: false,
            visibility: .privateVisibility
        )
        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(tempDecl)
        let eseq = Eseq(
            sourceAnchor: expr.sourceAnchor,
            seq: Seq(
                sourceAnchor: expr.sourceAnchor,
                children: [tempDecl]
            ),
            expr: temp
        )
        let get = Get(
            sourceAnchor: expr.sourceAnchor,
            expr: eseq,
            member: Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: pointee
            )
        )
        return get
    }
    
    private func lextract(expr: Expression?) throws -> Expression? {
        guard [.concrete, .temporary].contains(context) else { return expr }
        guard let expr else { return nil }
        let exprType = try lvalueContext.check(expression: expr)!
        
        switch expr {
        case let expr as Identifier where exprType.isPrimitive:
            return expr
            
        case let expr as Identifier where !exprType.isPrimitive:
            return try extractByPointer(expr: expr)
            
        case let expr as Subscript:
            return try extractByPointer(expr: expr)
            
        case let expr as Get:
            if (expr.member as? Identifier)?.identifier == pointee {
                return expr
            }
            else {
                return try extractByPointer(expr: expr)
            }
            
        default:
            fatalError("unimplemented")
        }
    }
    
    private func extractByValue(_ expr: Expression) throws -> Expression? {
        let temp = Identifier(
            sourceAnchor: expr.sourceAnchor,
            identifier: nextTempName()
        )
        let tempDecl = VarDeclaration(
            sourceAnchor: expr.sourceAnchor,
            identifier: temp,
            explicitType: nil,
            expression: expr,
            storage: .automaticStorage(offset: nil),
            isMutable: false,
            visibility: .privateVisibility
        )
        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(tempDecl)
        let eseq = Eseq(
            sourceAnchor: expr.sourceAnchor,
            seq: Seq(
                sourceAnchor: expr.sourceAnchor,
                children: [tempDecl]
            ),
            expr: temp
        )
        return eseq
    }
    
    private func extractByPointer(expr: Expression) throws -> Expression {
        let ptr = try extract(
            expr: Unary(
                sourceAnchor: expr.sourceAnchor,
                op: .ampersand,
                expression: expr
            )
        )
        let get = Get(
            sourceAnchor: expr.sourceAnchor,
            expr: ptr!,
            member: Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: pointee
            )
        )
        return get
    }

    private func nextTempName() -> String {
        symbols!.tempName(prefix: tempPrefix)
    }

    private func isCompilerTemporary(_ expr: Expression?) -> Bool {
        guard let expr = expr as? Identifier else { return false }
        let type = try? rvalueContext.check(identifier: expr)
        return (true == type?.isPrimitive) && expr.identifier.hasPrefix(tempPrefix)
    }
}

extension AbstractSyntaxTreeNode {
    /// Decompose expressions into simpler ones connected by temporary values
    public func decomposeExpressions() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassDecomposeExpressions().run(self)
    }
}
