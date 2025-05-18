//
//  CompilerPassEraseUnions.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/12/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Lower and erase union types from the program being compiled
public final class CompilerPassEraseUnions: CompilerPassWithDeclScan {
    private let pointee = "pointee"
    private let payload = "payload"
    private let tag = "tag"
    private let tagType: SymbolType = .u16
    private let tagOffset = 0
    private let payloadOffset: Int

    public override init(
        symbols: Env? = nil,
        staticStorageFrame: Frame = Frame(),
        memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) {
        self.payloadOffset = memoryLayoutStrategy.sizeof(type: tagType)
        super.init(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
    }

    public override func visit(as node0: As) throws -> Expression? {
        let node1 = try super.visit(as: node0)
        guard let node1 = node1 as? As else { return node1 }
        let objectType = try rvalueContext.check(expression: node1.expr)
        guard case .unionType(let info) = objectType else { return node1 }
        try rvalueContext.check(expression: node1) // Make sure the `As` expression is type-sound.

        let s = node1.sourceAnchor
        let isExpr = try visit(
            is: Is(
                sourceAnchor: s,
                expr: node1.expr,
                testType: node1.targetType
            )
        )
        guard let isExpr else { fatalError("internal compiler error") }

        let evaluatedTargetType = try rvalueContext.check(expression: node1.targetType)
        let firstExactMatch = info.members.first { evaluatedTargetType == $0 }
        let firstInexactMatch = info.members.first {
            rvalueContext.areTypesAreConvertible(
                ltype: $0,
                rtype: evaluatedTargetType,
                isExplicitCast: true
            )
        }
        let targetMember: SymbolType! = firstExactMatch ?? firstInexactMatch
        let extractPayload = As(
            sourceAnchor: s,
            expr: Unary(
                sourceAnchor: s,
                op: .ampersand,
                expression: Get(
                    sourceAnchor: s,
                    expr: node1.expr,
                    member: Identifier(
                        sourceAnchor: s,
                        identifier: payload
                    )
                )
            ),
            targetType: targetMember.lift
        )
        let convertPayload =
            if firstExactMatch != nil {
                extractPayload
            }
            else {
                // TODO: It's weird and potentially problematic to have so much implicit and automatic type conversion in the Snap language. Consider removing all implicit type conversions. In this case, a value can only be extracted from a union by casting explicitly to one of the types in the union.
                As(
                    sourceAnchor: s,
                    expr: extractPayload,
                    targetType: node1.targetType
                )
            }

        let eseq = Eseq(
            sourceAnchor: s,
            seq: Seq(
                sourceAnchor: s,
                children: [
                    If(
                        sourceAnchor: s,
                        condition: Unary(
                            op: .bang,
                            expression: isExpr
                        ),
                        then: Block(
                            symbols: Env(parent: symbols),
                            children: [
                                Call(
                                    sourceAnchor: s,
                                    callee: Identifier("__panic"),
                                    arguments: [
                                        LiteralString("bad union cast")
                                    ]
                                )
                            ]
                        ),
                        else: nil
                    )
                ]
            ),
            expr: convertPayload
        )
        return eseq
    }

    public override func visit(is node0: Is) throws -> Expression? {
        let node1 = try super.visit(is: node0)
        guard let node1 = node1 as? Is else { return node1 }
        let exprType = try rvalueContext.check(expression: node1.expr)
        guard case .unionType(let unionTypeInfo) = exprType else { return node1 }
        let testType = try rvalueContext.check(expression: node1.testType)
        let tagValue = unionTypeInfo.members.firstIndex { member in
            rvalueContext.areTypesAreConvertible(
                ltype: member,
                rtype: testType,
                isExplicitCast: false
            )
        }
        guard let tagValue else {
            let unionTypesDesc = unionTypeInfo.members.map { "`\($0)`" }.joined(separator: ",")
            throw CompilerError(
                sourceAnchor: node1.testType.sourceAnchor,
                message: "expected the test type to match one of the union types, but `\(testType)' does not match any of {\(unionTypesDesc)}"
            )
        }
        let node2 = Binary(
            sourceAnchor: node1.sourceAnchor,
            op: .eq,
            left: Get(
                sourceAnchor: node1.expr.sourceAnchor,
                expr: node1.expr,
                member: Identifier(
                    sourceAnchor: node1.expr.sourceAnchor,
                    identifier: tag
                )
            ),
            right: LiteralInt(tagValue)
        )
        return node2
    }

    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        // Allow symbols with union types to be added to the environment.
        // This helps to identify them later in this compiler pass.
        _ = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(node0)

        let identifier = try with(context: .none) {
            try visit(identifier: node0.identifier)
        }
        guard let identifier = identifier as? Identifier else {
            throw CompilerError(
                sourceAnchor: node0.identifier.sourceAnchor,
                message: "expected identifier: `\(node0.identifier)'"
            )
        }
        let decl = VarDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: identifier,
            explicitType: try with(context: .type) {
                try node0.explicitType.flatMap {
                    try visit(expr: $0)
                }
            },
            expression: nil,
            storage: node0.storage,
            isMutable: node0.isMutable,
            visibility: node0.visibility,
            id: node0.id
        )
        guard let expr = node0.expression, let rexpr = try visit(expr: expr) else { return decl }
        let eseq = Eseq(
            sourceAnchor: node0.sourceAnchor,
            seq: Seq(
                sourceAnchor: node0.sourceAnchor,
                children: [decl]
            ),
            expr: InitialAssignment(
                sourceAnchor: expr.sourceAnchor,
                lexpr: identifier,
                rexpr: rexpr
            )
        )
        return eseq
    }

    public override func visit(assignment node0: Assignment) throws -> Expression? {
        let node1 = try super.visit(assignment: node0)
        guard let node1 = node1 as? Assignment else { return node1 }
        let ltype = try lvalueContext.check(expression: node1.lexpr)
        guard let ltype else {
            throw CompilerError(
                sourceAnchor: node1.lexpr.sourceAnchor,
                message: "expected lvalue"
            )
        }
        guard case .unionType(let unionTypeInfo) = ltype else { return node1 }
        let rtype = try rvalueContext.check(expression: node1.rexpr)
        let tagValue = unionTypeInfo.members.firstIndex { member in
            rvalueContext.areTypesAreConvertible(
                ltype: member,
                rtype: rtype,
                isExplicitCast: false
            )
        }
        guard let tagValue else {
            throw CompilerError(
                sourceAnchor: node1.rexpr.sourceAnchor,
                message: "expected the type of the right-hand expression to exactly match one of the union types: `\(rtype)'"
            )
        }
        let eseq = Eseq(
            sourceAnchor: node1.sourceAnchor,
            seq: Seq(
                sourceAnchor: node1.sourceAnchor,
                children: [
                    Assignment(
                        sourceAnchor: node1.sourceAnchor,
                        lexpr: Get(
                            expr: node1.lexpr,
                            member: Identifier(
                                sourceAnchor: node1.sourceAnchor,
                                identifier: tag
                            )
                        ),
                        rexpr: LiteralInt(tagValue)
                    )
                ]
            ),
            expr: node1.withLexpr(
                Get(
                    expr: As(
                        expr: Unary(
                            op: .ampersand,
                            expression: Get(
                                expr: node1.lexpr,
                                member: Identifier(
                                    sourceAnchor: node1.sourceAnchor,
                                    identifier: payload
                                )
                            )
                        ),
                        targetType: PointerType(
                            PrimitiveType(
                                unionTypeInfo.members[tagValue]
                            )
                        )
                    ),
                    member: Identifier(
                        sourceAnchor: node1.sourceAnchor,
                        identifier: pointee
                    )
                )
            )
        )
        return eseq
    }

    public override func visit(unionType: UnionType) throws -> Expression? {
        PrimitiveType(
            .structType(
                StructTypeInfo(
                    name: "",
                    fields: try fields(for: unionType)
                )
            )
        )
    }

    public func fields(for unionType: UnionType) throws -> Env {
        let payloadSize = try unionType.members
            .map {
                try rvalueContext.check(expression: $0)
            }
            .reduce(0) { (accum, type) in
                max(accum, memoryLayoutStrategy.sizeof(type: type))
            }
        let payloadType: SymbolType = .array(count: payloadSize, elementType: .u8)
        let env = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag, Symbol(type: tagType, offset: tagOffset)),
                (payload, Symbol(type: payloadType, offset: payloadOffset))
            ]
        )
        return env
    }
}

extension AbstractSyntaxTreeNode {
    /// Lower and erase union types from the program being compiled
    public func eraseUnions(
        memoryLayoutStrategy m: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseUnions(memoryLayoutStrategy: m).run(self)
    }
}
