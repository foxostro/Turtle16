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
        try rvalueContext.check(expression: node0) // Make sure the `As` expression is type-sound.
        let objectType = try rvalueContext.check(expression: node0.expr)
        let targetType = try rvalueContext.check(expression: node0.targetType)
        let node1 = try super.visit(as: node0)
        guard let node1 = node1 as? As else { return node1 }
        let result =
            if case .unionType(let info) = objectType {
                try convertFromUnionValue(info, node1)
            }
            else if case .unionType(let info) = targetType {
                try convertToUnionValue(info, objectType, node1)
            }
            else {
                node1
            }
        return result
    }

    private func convertFromUnionValue(
        _ info: UnionTypeInfo,
        _ node1: As
    ) throws -> Expression? {
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
    
    private func convertToUnionValue(
        _ unionTypeInfo: UnionTypeInfo,
        _ objectType: SymbolType,
        _ node1: As
    ) throws -> Expression? {
        let s = node1.sourceAnchor
        let tempName = "__temp0"
        let temp = Identifier(sourceAnchor: s, identifier: tempName)
        let tagValue = unionTypeInfo.members.firstIndex { member in
            rvalueContext.areTypesAreConvertible(
                ltype: member,
                rtype: objectType,
                isExplicitCast: false
            )
        }
        guard let tagValue else {
            let unionTypesDesc = unionTypeInfo.members.map { "`\($0)`" }.joined(separator: ",")
            throw CompilerError(
                sourceAnchor: node1.targetType.sourceAnchor,
                message: "expected the target type to match one of the union types, but `\(objectType)' does not match any of {\(unionTypesDesc)}"
            )
        }
        let eseq = Eseq(
            sourceAnchor: s,
            seq: Seq(
                sourceAnchor: s,
                children: [
                    VarDeclaration(
                        sourceAnchor: s,
                        identifier: temp,
                        explicitType: PrimitiveType(
                            .structType(
                                StructTypeInfo(
                                    name: "",
                                    fields: try fields(for: unionTypeInfo)
                                )
                            )
                        ),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    ),
                    InitialAssignment(
                        sourceAnchor: s,
                        lexpr: Get(
                            sourceAnchor: s,
                            expr: temp,
                            member: Identifier(sourceAnchor: s, identifier: tag)
                        ),
                        rexpr: LiteralInt(sourceAnchor: s, value: tagValue)
                    ),
                    InitialAssignment(
                        lexpr: Get(
                            sourceAnchor: s,
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Get(
                                        expr: temp,
                                        member: Identifier(sourceAnchor: s, identifier: payload)
                                    )
                                ),
                                targetType: PointerType(
                                    PrimitiveType(
                                        unionTypeInfo.members[tagValue]
                                    )
                                )
                            ),
                            member: Identifier(sourceAnchor: s, identifier: pointee)
                        ),
                        rexpr: node1.expr
                    )
                ]
            ),
            expr: temp
        )
        return eseq
    }

    public override func visit(is node0: Is) throws -> Expression? {
        try rvalueContext.check(expression: node0) // make sure the expression type checks
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
        let actualType: SymbolType = try rvalueContext.check(identifier: node0.identifier)
        guard case .unionType(_) = actualType else {
            return node0
        }

        let identifier = try with(context: .none) {
            try visit(identifier: node0.identifier)
        }
        guard let identifier = identifier as? Identifier else {
            throw CompilerError(
                sourceAnchor: node0.identifier.sourceAnchor,
                message: "expected identifier: `\(node0.identifier)'"
            )
        }
        guard node0.explicitType != nil else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: "expected an explicit type"
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
        let myAssignment = try visit(
            initialAssignment: InitialAssignment(
                sourceAnchor: expr.sourceAnchor,
                lexpr: identifier,
                rexpr: rexpr
            )
        )
        guard let myAssignment else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "expected an Assignment"
            )
        }
        let eseq = Eseq(
            sourceAnchor: node0.sourceAnchor,
            seq: Seq(
                sourceAnchor: node0.sourceAnchor,
                children: [decl]
            ),
            expr: myAssignment
        )
        return eseq
    }

    public func visit<T: Assignment>(someAssignment node0: T) throws -> Expression? {
        try rvalueContext.check(expression: node0) // make sure the expression type checks
        let node1 =
            switch node0 {
            case let a as Assignment:
                try super.visit(assignment: a)
            case let a as InitialAssignment:
                try super.visit(initialAssignment: a)
            default:
                throw CompilerError(
                    sourceAnchor: node0.sourceAnchor,
                    message: "expected an assignment"
                )
            }
        guard let node1 = node1 as? T else { return node1 }
        let ltype = try lvalueContext.check(expression: node1.lexpr)
        guard let ltype else {
            throw CompilerError(
                sourceAnchor: node1.lexpr.sourceAnchor,
                message: "expected lvalue"
            )
        }
        guard case .unionType(let unionTypeInfo) = ltype else { return node1 }
        let rtype = try rvalueContext.check(expression: node1.rexpr)
        guard rtype.correspondingConstType != ltype.correspondingConstType else { return node0 }
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
                    node1
                        .withLexpr(
                            Get(
                                sourceAnchor: node1.sourceAnchor,
                                expr: node1.lexpr,
                                member: Identifier(
                                    sourceAnchor: node1.sourceAnchor,
                                    identifier: tag
                                )
                            )
                        )
                        .withRexpr(
                            LiteralInt(
                                sourceAnchor: node1.sourceAnchor,
                                value: tagValue
                            )
                        )
                        .withNewId()
                ]
            ),
            expr: node1.withLexpr(
                Get(
                    expr: Bitcast(
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
    
    public override func visit(initialAssignment node0: InitialAssignment) throws -> Expression? {
        try visit(someAssignment: node0)
    }
    
    public override func visit(assignment node0: Assignment) throws -> Expression? {
        try visit(someAssignment: node0)
    }

    public override func visit(unionType: UnionType) throws -> Expression? {
        let i = try rvalueContext.unionTypeInfo(for: unionType)
        let f = try fields(for: i)
        let r = PrimitiveType(.structType(StructTypeInfo(name: "", fields: f)))
        return r
    }

    public func fields(for info: UnionTypeInfo) throws -> Env {
        let payloadSize = info.members.reduce(0) { (accum, type) in
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
        _ m: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseUnions(memoryLayoutStrategy: m).run(self)
    }
}
