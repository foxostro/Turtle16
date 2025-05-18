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
    let tempBackingStoragePrefix = "__tempStorage"

#if false
    public override func postProcess(
        _ node: AbstractSyntaxTreeNode?
    ) throws -> AbstractSyntaxTreeNode? {
        try node?.eraseEseq()?.flatten()
    }
#endif
    
    public override func visit(
        expressionStatement node: Expression
    ) throws -> AbstractSyntaxTreeNode? {
        let expr0 = try visit(expr: node)
        let expr1 =
            switch expr0 {
            case let expr as Get:
                try extract(expr: expr)
                
            default:
                expr0
            }
        return expr1
    }
    
    public override func visit(literalInt node: LiteralInt) throws -> Expression? {
        try extract(expr: try super.visit(literalInt: node))
    }

    public override func visit(literalBoolean node: LiteralBool) throws -> Expression? {
        try extract(expr: try super.visit(literalBoolean: node))
    }

    public override func visit(literalArray node: LiteralArray) throws -> Expression? {
        try extract(expr: try super.visit(literalArray: node))
    }

    public override func visit(literalString node: LiteralString) throws -> Expression? {
        try extract(expr: try super.visit(literalString: node))
    }

    public override func visit(identifier node: Identifier) throws -> Expression? {
        switch context {
        case .concrete:
            guard !isCompilerTemporary(node) else { return node }
            
            let tempRef0 = Identifier(
                sourceAnchor: node.sourceAnchor,
                identifier: nextTempName()
            )
            let tempDecl0 = VarDeclaration(
                sourceAnchor: node.sourceAnchor,
                identifier: tempRef0,
                explicitType: nil,
                expression: Unary(op: .ampersand, expression: node),
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
            _ = try SnapSubcompilerVarDeclaration(
                symbols: symbols!,
                staticStorageFrame: staticStorageFrame,
                memoryLayoutStrategy: memoryLayoutStrategy
            )
            .compile(tempDecl0)
            let temp0 = Eseq(
                seq: Seq(children: [tempDecl0]),
                expr: tempRef0
            )
            let tempRef1 = Identifier(
                sourceAnchor: node.sourceAnchor,
                identifier: nextTempName()
            )
            let tempDecl1 = VarDeclaration(
                sourceAnchor: node.sourceAnchor,
                identifier: tempRef1,
                explicitType: nil,
                expression: Get(
                    sourceAnchor: node.sourceAnchor,
                    expr: temp0,
                    member: Identifier(
                        sourceAnchor: node.sourceAnchor,
                        identifier: "pointee"
                    )
                ),
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
            _ = try SnapSubcompilerVarDeclaration(
                symbols: symbols!,
                staticStorageFrame: staticStorageFrame,
                memoryLayoutStrategy: memoryLayoutStrategy
            )
            .compile(tempDecl1)
            let temp1 = Eseq(seq: Seq(children: [tempDecl1]), expr: tempRef1)
            return temp1
            
        case .temporary:
            guard !isCompilerTemporary(node) else { return node }
            
            let tempRef0 = Identifier(
                sourceAnchor: node.sourceAnchor,
                identifier: nextTempName()
            )
            let tempDecl0 = VarDeclaration(
                sourceAnchor: node.sourceAnchor,
                identifier: tempRef0,
                explicitType: nil,
                expression: Unary(op: .ampersand, expression: node),
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
            _ = try SnapSubcompilerVarDeclaration(
                symbols: symbols!,
                staticStorageFrame: staticStorageFrame,
                memoryLayoutStrategy: memoryLayoutStrategy
            )
            .compile(tempDecl0)
            let temp0 = Eseq(
                seq: Seq(children: [tempDecl0]),
                expr: tempRef0
            )
            return temp0
            
        default:
            return node
        }
    }

    public override func visit(as node: As) throws -> Expression? {
        try extract(expr: try super.visit(as: node))
    }

    public override func visit(bitcast node: Bitcast) throws -> Expression? {
        try extract(expr: try super.visit(bitcast: node))
    }

    public override func visit(unary node0: Unary) throws -> Expression? {
        switch node0.op {
        case .ampersand:
            try extract(expr: try visit(addressOf: node0))
        default:
            try extract(expr: try super.visit(unary: node0))
        }
    }
    
    private func visit(addressOf node0: Unary) throws -> Expression? {
        assert(node0.op == .ampersand)
        switch node0.child {
        case _ as Identifier:
            // In the case where we're taking the address of a bare identifier,
            // we want to leave the expression unchanged. Expressions of the
            // form, `AddressOf(Identifier)`, are already irreducible. The
            // compiler will translate this to a sequence of instructions to
            // derive the address of the symbol, if it has one.
            return node0
            
        case let child0 as Get:
            // In the case where we're taking the address of a Get expression,
            // note that expressions of the form, `AddressOf(Get(_, Member))`,
            // are already irreducible. We want to visit the expression
            // represented by `_` and extract it to a new compiler-generated
            // temporary value.
            let getExpr0 = child0.expr
            let getExpr1 =
                switch getExpr0 {
                case let expr as Identifier:
                    try extract(
                        expr: Unary(
                            sourceAnchor: expr.sourceAnchor,
                            op: .ampersand,
                            expression: expr
                        )
                    )!
                    
                default:
                    try super.visit(expr: getExpr0)!
                }
            let child1 = child0.withExpr(getExpr1)
            let node1 = node0.withExpression(child1)
            return node1
            
        default:
            return try super.visit(unary: node0)
        }
    }

    public override func visit(binary node: Binary) throws -> Expression? {
        try extract(expr: try super.visit(binary: node))
    }

    public override func visit(is node: Is) throws -> Expression? {
        let a = try rvalueContext.check(expression: node.expr)
        let b = try typeContext.check(expression: node.testType)
        let result = try extract(expr: LiteralBool(a == b))
        return result
    }

    public override func visit(assignment node: Assignment) throws -> Expression? {
        // Evaluate both the left and right hand sides of the assignment using
        // a transient context. This causes the original right and left hand
        // expressions to each compile to an expression which computes the
        // address in memory for the source and for the destination. Take these
        // transient values and wrap them with `Get(_, pointee)` to indicate
        // that these are resolved to concrete values through memory accesses.
        try extract(
            expr: node
                .withLexpr(
                    Get(
                        sourceAnchor: node.sourceAnchor,
                        expr: {
                            try with(context: .temporary) {
                                try visit(expr: node.lexpr)!
                            }
                        }(),
                        member: Identifier(
                            sourceAnchor: node.sourceAnchor,
                            identifier: "pointee"
                        )
                    )
                )
                .withRexpr({
                    // The right-hand side may be some temporary value which is
                    // never materialized in memory. (For example, this can
                    // happen when assigning a literal integer to a variable.)
                    // If this is the case then evaluating the expression in a
                    // transient context will yield something other than a
                    // pointer. So, if we see this, then just pass it along.
                    let rvalue0 = node.rexpr
                    let rvalue1 = try with(context: .temporary) {
                        try visit(expr: rvalue0)!
                    }
                    let rvalue2 =
                        if let eseq = rvalue1 as? Eseq,
                           let varDecl = eseq.seq.children.first as? VarDeclaration,
                           !(try rvalueContext.check(identifier: varDecl.identifier).isPointerType) {
                            
                            rvalue1
                        }
                        else {
                            Get(
                                sourceAnchor: node.sourceAnchor,
                                expr: rvalue1,
                                member: Identifier(
                                    sourceAnchor: node.sourceAnchor,
                                    identifier: "pointee"
                                )
                            )
                        }
                    return rvalue2
                }())
        )
    }

    public override func visit(subscript node0: Subscript) throws -> Expression? {
        let argument = try with(context: .concrete) {
            try visit(expr: node0.argument)!
        }
        let subscriptable = try with(context: .temporary) {
            try visit(expr: node0.subscriptable)!
        }
        let node1 = node0
            .withArgument(argument)
            .withSubscriptable(subscriptable)
        let node2 =
            if context == .temporary {
                Unary(
                    sourceAnchor: node1.sourceAnchor,
                    op: .ampersand,
                    expression: node1
                )
            }
            else {
                node1
            }
        let node3 = try extract(expr: node2)
        return node3
    }

    public override func visit(get node0: Get) throws -> Expression? {
        let node1 =
            switch node0.expr {
            case let expr as Identifier where isCompilerTemporary(expr):
                try extract(expr: node0)
                
            case let expr as Identifier where !isCompilerTemporary(expr):
                try with(context: .temporary) {
                    try visit(getFromBareIdentifier: node0)
                }
                
            case _ as Get:
                try with(context: .temporary) {
                    try visit(getFromGetExpression: node0)
                }
                
            default:
                try with(context: .concrete) {
                    try super.visit(get: node0)
                }
            }
        
        let node2 = try extract(expr: node1)!
        
        // We may want to evaluated a Get expression for either a concrete value
        // or for a transient value. The concrete value is an actual, real value
        // matching the value of the member per the environment. Evaluating this
        // may require copying the value when the program executes through the
        // following `Get(expr, pointee)` expression. This same expression may
        // also be evaluated for an lvalue in, e.g., an assignment statement.
        // The transient value is part of a larger expression, the value of
        // which is never taken explicitly. All the Get expressions in a chain
        // of Get expressions are transient until the final Get, which resolves
        // to a concrete value.
        let node3 =
            switch context {
            case .concrete:
                Get(
                    sourceAnchor: node2.sourceAnchor,
                    expr: node2,
                    member: Identifier(
                        sourceAnchor: node2.sourceAnchor,
                        identifier: "pointee"
                    )
                )
                
            case .temporary:
                node2
                
            case .none, .type:
                fatalError("invalid context for Get expression: \(context)")
            }
        
        return node3
    }
    
    private func visit(getFromBareIdentifier node0: Get) throws -> Expression? {
        assert(node0.expr is Identifier)
        assert(!isCompilerTemporary(node0.expr))
        
        let expr: Expression! = try with(context: .temporary) {
            try visit(expr: node0.expr)
        }

        // Take the address of the symbol and stuff it in a new temporary value.
        // Note that expressions of the form, `AddressOf(Get(_, Member))`, are
        // already irreducible.
        let node1: Expression! = node0.withExpr(expr)
        let node2 = Unary(
            sourceAnchor: node0.sourceAnchor,
            op: .ampersand,
            expression: node1!
        )
        
        return node2
    }
    
    private func visit(getFromGetExpression node0: Get) throws -> Expression? {
        let getExpr0 = node0.expr as! Get
        let getExpr1 = try with(context: .temporary) {
            try visit(expr: getExpr0)!
        }
        
        // We're getting _from_ a Get expression.
        // Decompose this inner Get expression, which may form a long chain for
        // all we know right now.
        let node1 = node0.withExpr(getExpr1)
        
        // Take the address of this inner Get expression and stuff it in a new
        // temporary value.
        // Note that expressions of the form, `AddressOf(Get(_, Member))`, are
        // already irreducible.
        let node2 = Unary(
            sourceAnchor: node1.sourceAnchor,
            op: .ampersand,
            expression: node1
        )
        
        return node2
    }

    public override func visit(structInitializer node0: StructInitializer) throws -> Expression? {
        guard [.concrete, .temporary].contains(context) else { return node0 }
        
        let temp = Identifier(
            sourceAnchor: node0.sourceAnchor,
            identifier: nextTempName()
        )
        
        let tempDecl: AbstractSyntaxTreeNode! = try visit(
            VarDeclaration(
                sourceAnchor: node0.sourceAnchor,
                identifier: temp,
                explicitType: node0.expr,
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        )
        
        var children: [AbstractSyntaxTreeNode] = [tempDecl]
        
        if let firstArg = node0.arguments.first {
            let child: Expression! = try visit(
                initialAssignment: InitialAssignment(
                    sourceAnchor: node0.sourceAnchor,
                    lexpr: Get(
                        sourceAnchor: node0.sourceAnchor,
                        expr: temp,
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
                            expr: temp,
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
        
        let eseq = Eseq(
            sourceAnchor: node0.sourceAnchor,
            seq: Seq(
                sourceAnchor: node0.sourceAnchor,
                children: children
            ),
            expr: temp
        )
        return eseq
    }

    public override func visit(call node0: Call) throws -> Expression? {
        let node1 = try super.visit(call: node0)
        let result = try extract(expr: node1)
        return result
    }

    public override func visit(typeof node: TypeOf) throws -> Expression? {
        PrimitiveType(
            sourceAnchor: node.sourceAnchor,
            typ: try rvalueContext.check(expression: node.expr)
        )
    }
    
    public override func visit(sizeof node: SizeOf) throws -> Expression? {
        let type = try rvalueContext.check(expression: node.expr)
        let size = memoryLayoutStrategy.sizeof(type: type)
        return LiteralInt(
            sourceAnchor: node.sourceAnchor,
            value: size
        )
    }

    public override func visit(eseq node: Eseq) throws -> Expression? {
        try extract(expr: try super.visit(eseq: node))
    }
    
    func extract(expr: Expression?) throws -> Expression? {
        guard [.concrete, .temporary].contains(context) else { return expr }
        guard let expr, !isCompilerTemporary(expr) else { return expr }
        
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
                children: [ tempDecl ]
            ),
            expr: temp
        )
        return eseq
    }
    
    private func nextTempName() -> String {
        symbols!.tempName(prefix: tempPrefix)
    }
    
    private func isCompilerTemporary(_ expr: Expression?) -> Bool {
        guard let expr = expr as? Identifier else { return false }
        let type = try? rvalueContext.check(identifier: expr)
        return (true==type?.isPrimitive) && expr.identifier.hasPrefix(tempPrefix)
    }
}

extension AbstractSyntaxTreeNode {
    /// Decompose expressions into simpler ones connected by temporary values
    public func decomposeExpressions() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassDecomposeExpressions().run(self)
    }
}
