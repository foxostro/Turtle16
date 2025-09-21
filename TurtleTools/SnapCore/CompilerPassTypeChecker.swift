//
//  CompilerPassTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// A compiler pass that type checks all expressions in the AST.
/// This pass validates that all expressions are well-typed and throws
/// compiler errors for any type mismatches or invalid operations.
public final class CompilerPassTypeChecker: CompilerPassWithDeclScan {
    public override func visit(if node: If) throws -> AbstractSyntaxTreeNode? {
        let visitedNode = try super.visit(if: node)
        if let visitedNode = visitedNode as? If {
            let conditionType = try rvalueContext.check(expression: visitedNode.condition)
            guard conditionType.isBooleanType else {
                throw CompilerError(
                    sourceAnchor: visitedNode.condition.sourceAnchor,
                    message: "condition must be of boolean type, not `\(conditionType)'"
                )
            }
        }
        return visitedNode
    }

    public override func visit(while node: While) throws -> AbstractSyntaxTreeNode? {
        let visitedNode = try super.visit(while: node)
        if let visitedNode = visitedNode as? While {
            let conditionType = try rvalueContext.check(expression: visitedNode.condition)
            guard conditionType.isBooleanType else {
                throw CompilerError(
                    sourceAnchor: visitedNode.condition.sourceAnchor,
                    message: "condition must be of boolean type, not `\(conditionType)'"
                )
            }
        }
        return visitedNode
    }

    public override func visit(assignment node: Assignment) throws -> Expression? {
        // We must type check this one first because the superclass may mark a variable as having
        // been initialized in the assignment and this may turn valid assignments to uninitialized
        // constants into invalid assignments to initialized constants, resulting in type errors.
        _ = try rvalueContext.check(expression: node)
        return try super.visit(assignment: node)
    }

    public override func visit(binary node: Binary) throws -> Expression? {
        let visitedNode = try super.visit(binary: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(unary node: Unary) throws -> Expression? {
        let visitedNode = try super.visit(unary: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(call node: Call) throws -> Expression? {
        let visitedNode = try super.visit(call: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(subscript node: Subscript) throws -> Expression? {
        let visitedNode = try super.visit(subscript: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(get node: Get) throws -> Expression? {
        let visitedNode = try super.visit(get: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(structInitializer node: StructInitializer) throws -> Expression? {
        let visitedNode = try super.visit(structInitializer: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(as node: As) throws -> Expression? {
        let visitedNode = try super.visit(as: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(bitcast node: Bitcast) throws -> Expression? {
        let visitedNode = try super.visit(bitcast: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(is node: Is) throws -> Expression? {
        let visitedNode = try super.visit(is: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(typeof node: TypeOf) throws -> Expression? {
        let visitedNode = try super.visit(typeof: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(sizeof node: SizeOf) throws -> Expression? {
        let visitedNode = try super.visit(sizeof: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(assert node: Assert) throws -> AbstractSyntaxTreeNode? {
        let visitedNode = try super.visit(assert: node)
        if let visitedNode = visitedNode as? Assert {
            let conditionType = try rvalueContext.check(expression: visitedNode.condition)
            guard conditionType.isBooleanType else {
                throw CompilerError(
                    sourceAnchor: visitedNode.condition.sourceAnchor,
                    message: "assert condition must be of boolean type, not `\(conditionType)'"
                )
            }
        }
        return visitedNode
    }

    public override func visit(match node: Match) throws -> AbstractSyntaxTreeNode? {
        let visitedNode = try super.visit(match: node)
        if let visitedNode = visitedNode as? Match {
            _ = try rvalueContext.check(expression: visitedNode.expr)
            for clause in visitedNode.clauses {
                _ = try rvalueContext.check(expression: clause.valueType)
            }
        }
        return visitedNode
    }

    public override func visit(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        let visitedNode = try super.visit(gotoIfFalse: node)
        if let visitedNode = visitedNode as? GotoIfFalse {
            let conditionType = try rvalueContext.check(expression: visitedNode.condition)
            guard conditionType.isBooleanType else {
                throw CompilerError(
                    sourceAnchor: visitedNode.condition.sourceAnchor,
                    message: "goto condition must be of boolean type, not `\(conditionType)'"
                )
            }
        }
        return visitedNode
    }

    public override func visit(genericTypeApplication node: GenericTypeApplication) throws
        -> Expression? {
        let visitedNode = try super.visit(genericTypeApplication: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(eseq node: Eseq) throws -> Expression? {
        let visitedNode = try super.visit(eseq: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(group node: Group) throws -> Expression? {
        let visitedNode = try super.visit(group: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(identifier node: Identifier) throws -> Expression? {
        let visitedNode = try super.visit(identifier: node)
        if let visitedNode {
            switch context {
            case .value:
                _ = try rvalueContext.check(expression: visitedNode)

            case .type:
                _ = try rvalueContext.check(expression: visitedNode)

            case .none:
                break
            }
        }
        return visitedNode
    }

    public override func visit(primitiveType node: PrimitiveType) throws -> Expression? {
        let visitedNode = try super.visit(primitiveType: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(pointerType node: PointerType) throws -> Expression? {
        let visitedNode = try super.visit(pointerType: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(constType node: ConstType) throws -> Expression? {
        let visitedNode = try super.visit(constType: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(dynamicArrayType node: DynamicArrayType) throws -> Expression? {
        let visitedNode = try super.visit(dynamicArrayType: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(arrayType node: ArrayType) throws -> Expression? {
        let visitedNode = try super.visit(arrayType: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(functionType node: FunctionType) throws -> Expression? {
        let visitedNode = try super.visit(functionType: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }

    public override func visit(genericFunctionType node: GenericFunctionType) throws
        -> Expression? {
        let visitedNode = try super.visit(genericFunctionType: node)
        if let visitedNode {
            _ = try rvalueContext.check(expression: visitedNode)
        }
        return visitedNode
    }
}

public extension AbstractSyntaxTreeNode {
    func typeCheck() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassTypeChecker().run(self)
    }
}
