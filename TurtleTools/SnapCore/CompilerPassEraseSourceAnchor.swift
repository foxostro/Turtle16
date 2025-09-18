//
//  CompilerPassEraseSourceAnchor.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/19/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

public final class CompilerPassEraseSourceAnchor: CompilerPass {
    public override func visit(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        try super.visit(topLevel: node)?.withSourceAnchor(nil)
    }

    public override func visit(subroutine node: Subroutine) throws -> AbstractSyntaxTreeNode? {
        try super.visit(subroutine: node)?.withSourceAnchor(nil)
    }

    public override func visit(seq node: Seq) throws -> AbstractSyntaxTreeNode? {
        try super.visit(seq: node)?.withSourceAnchor(nil)
    }

    public override func visit(varDecl node: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        try super.visit(varDecl: node)?.withSourceAnchor(nil)
    }

    public override func visit(if node: If) throws -> AbstractSyntaxTreeNode? {
        try super.visit(if: node)?.withSourceAnchor(nil)
    }

    public override func visit(while node: While) throws -> AbstractSyntaxTreeNode? {
        try super.visit(while: node)?.withSourceAnchor(nil)
    }

    public override func visit(forIn node: ForIn) throws -> AbstractSyntaxTreeNode? {
        try super.visit(forIn: node)?.withSourceAnchor(nil)
    }

    public override func visit(block node: Block) throws -> AbstractSyntaxTreeNode? {
        try super.visit(block: node)?.withSourceAnchor(nil)
    }

    public override func visit(module node: Module) throws -> AbstractSyntaxTreeNode? {
        try super.visit(module: node)?.withSourceAnchor(nil)
    }

    public override func visit(return node: Return) throws -> AbstractSyntaxTreeNode? {
        try super.visit(return: node)?.withSourceAnchor(nil)
    }

    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        try super.visit(func: node)?.withSourceAnchor(nil)
    }

    public override func visit(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        try super.visit(struct: node)?.withSourceAnchor(nil)
    }

    public override func visit(impl node: Impl) throws -> AbstractSyntaxTreeNode? {
        try super.visit(impl: node)?.withSourceAnchor(nil)
    }

    public override func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        try super.visit(implFor: node)?.withSourceAnchor(nil)
    }

    public override func visit(match node: Match) throws -> AbstractSyntaxTreeNode? {
        try super.visit(match: node)?.withSourceAnchor(nil)
    }

    public override func visit(assert node: Assert) throws -> AbstractSyntaxTreeNode? {
        try super.visit(assert: node)?.withSourceAnchor(nil)
    }

    public override func visit(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        try super.visit(trait: node)?.withSourceAnchor(nil)
    }

    public override func visit(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        try super.visit(testDecl: node)?.withSourceAnchor(nil)
    }

    public override func visit(typealias node: Typealias) throws -> AbstractSyntaxTreeNode? {
        try super.visit(typealias: node)?.withSourceAnchor(nil)
    }

    public override func visit(import node: Import) throws -> AbstractSyntaxTreeNode? {
        try super.visit(import: node)?.withSourceAnchor(nil)
    }

    public override func visit(asm node: Asm) throws -> AbstractSyntaxTreeNode? {
        try super.visit(asm: node)?.withSourceAnchor(nil)
    }

    public override func visit(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        try super.visit(goto: node)?.withSourceAnchor(nil)
    }

    public override func visit(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        try super.visit(gotoIfFalse: node)?.withSourceAnchor(nil)
    }

    public override func visit(instruction node: InstructionNode) throws -> AbstractSyntaxTreeNode?
    {
        try super.visit(instruction: node)?.withSourceAnchor(nil)
    }

    public override func visit(tack node: TackInstructionNode) throws -> AbstractSyntaxTreeNode? {
        try super.visit(tack: node)?.withSourceAnchor(nil)
    }

    public override func visit(
        expressionStatement node: Expression
    ) throws -> AbstractSyntaxTreeNode? {
        try super.visit(expressionStatement: node)?.withSourceAnchor(nil)
    }

    public override func visit(unsupported node: UnsupportedExpression) throws -> Expression? {
        try super.visit(unsupported: node)?.withSourceAnchor(nil)
    }

    public override func visit(literalInt node: LiteralInt) throws -> Expression? {
        try super.visit(literalInt: node)?.withSourceAnchor(nil)
    }

    public override func visit(literalBoolean node: LiteralBool) throws -> Expression? {
        try super.visit(literalBoolean: node)?.withSourceAnchor(nil)
    }

    public override func visit(literalArray expr: LiteralArray) throws -> Expression? {
        try super.visit(literalArray: expr)?.withSourceAnchor(nil)
    }

    public override func visit(literalString expr: LiteralString) throws -> Expression? {
        try super.visit(literalString: expr)?.withSourceAnchor(nil)
    }

    public override func visit(identifier node: Identifier) throws -> Expression? {
        try super.visit(identifier: node)?.withSourceAnchor(nil)
    }

    public override func visit(as expr: As) throws -> Expression? {
        try super.visit(as: expr)?.withSourceAnchor(nil)
    }

    public override func visit(bitcast node: Bitcast) throws -> Expression? {
        try super.visit(bitcast: node)?.withSourceAnchor(nil)
    }

    public override func visit(unary node: Unary) throws -> Expression? {
        try super.visit(unary: node)?.withSourceAnchor(nil)
    }

    public override func visit(binary node: Binary) throws -> Expression? {
        try super.visit(binary: node)?.withSourceAnchor(nil)
    }

    public override func visit(is node: Is) throws -> Expression? {
        try super.visit(is: node)?.withSourceAnchor(nil)
    }

    public override func visit(assignment node: Assignment) throws -> Expression? {
        try super.visit(assignment: node)?.withSourceAnchor(nil)
    }

    public override func visit(subscript node: Subscript) throws -> Expression? {
        try super.visit(subscript: node)?.withSourceAnchor(nil)
    }

    public override func visit(get node: Get) throws -> Expression? {
        try super.visit(get: node)?.withSourceAnchor(nil)
    }

    public override func visit(structInitializer node: StructInitializer) throws -> Expression? {
        try super.visit(structInitializer: node)?.withSourceAnchor(nil)
    }

    public override func visit(call node: Call) throws -> Expression? {
        try super.visit(call: node)?.withSourceAnchor(nil)
    }

    public override func visit(typeof node: TypeOf) throws -> Expression? {
        try super.visit(typeof: node)?.withSourceAnchor(nil)
    }

    public override func visit(sizeof node: SizeOf) throws -> Expression? {
        try super.visit(sizeof: node)?.withSourceAnchor(nil)
    }

    public override func visit(
        genericTypeApplication expr: GenericTypeApplication
    ) throws -> Expression? {
        try super.visit(genericTypeApplication: expr)?.withSourceAnchor(nil)
    }

    public override func visit(genericTypeArgument node: GenericTypeArgument) throws -> Expression?
    {
        try super.visit(genericTypeArgument: node)?.withSourceAnchor(nil)
    }

    public override func visit(eseq node: Eseq) throws -> Expression? {
        try super.visit(eseq: node)?.withSourceAnchor(nil)
    }

    public override func visit(primitiveType node: PrimitiveType) throws -> Expression? {
        try super.visit(primitiveType: node)?.withSourceAnchor(nil)
    }

    public override func visit(pointerType node: PointerType) throws -> Expression? {
        try super.visit(pointerType: node)?.withSourceAnchor(nil)
    }

    public override func visit(constType node: ConstType) throws -> Expression? {
        try super.visit(constType: node)?.withSourceAnchor(nil)
    }

    public override func visit(mutableType node: MutableType) throws -> Expression? {
        try super.visit(mutableType: node)?.withSourceAnchor(nil)
    }

    public override func visit(unionType node: UnionType) throws -> Expression? {
        try super.visit(unionType: node)?.withSourceAnchor(nil)
    }

    public override func visit(dynamicArrayType node: DynamicArrayType) throws -> Expression? {
        try super.visit(dynamicArrayType: node)?.withSourceAnchor(nil)
    }

    public override func visit(arrayType node: ArrayType) throws -> Expression? {
        try super.visit(arrayType: node)?.withSourceAnchor(nil)
    }

    public override func visit(functionType node: FunctionType) throws -> Expression? {
        try super.visit(functionType: node)?.withSourceAnchor(nil)
    }

    public override func visit(genericFunctionType node: GenericFunctionType) throws -> Expression?
    {
        try super.visit(genericFunctionType: node)?.withSourceAnchor(nil)
    }
}

extension AbstractSyntaxTreeNode {
    // Remove all source anchors from all nodes in the AST
    public func eraseSourceAnchors() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseSourceAnchor().run(self)
    }
}
