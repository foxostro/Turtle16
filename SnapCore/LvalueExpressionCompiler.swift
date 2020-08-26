//
//  LvalueExpressionCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Compiles an expression in an lvalue context. This results in code which
// pushes a destination address to the stack. (or else a type error)
public class LvalueExpressionCompiler: BaseExpressionCompiler {
    let typeChecker: LvalueExpressionTypeChecker
    
    public override init(symbols: SymbolTable = SymbolTable(),
                         labelMaker: LabelMaker = LabelMaker(),
                         temporaryStack: CompilerTemporariesStack =     CompilerTemporariesStack(),
                         temporaryAllocator: CompilerTemporariesAllocator = CompilerTemporariesAllocator()) {
        self.typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        super.init(symbols: symbols,
                   labelMaker: labelMaker,
                   temporaryStack: temporaryStack,
                   temporaryAllocator: temporaryAllocator)
    }
    
    public override func compile(expression: Expression) throws -> [CrackleInstruction] {
        try typeChecker.check(expression: expression)
        
        switch expression {
        case let identifier as Expression.Identifier:
            return try compile(identifier: identifier)
        case let expr as Expression.Subscript:
            return try compile(subscript: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }
    
    private func compile(identifier expr: Expression.Identifier) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let resolution = try symbols.resolveWithStackFrameDepth(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier)
        let symbol = resolution.0
        let depth = symbols.stackFrameIndex - resolution.1
        guard symbol.isMutable else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot assign to immutable variable `\(expr.identifier)'")
        }
        
        switch symbol.storage {
        case .staticStorage:
            let dst = temporaryAllocator.maybeAllocate(size: 2)!
            temporaryStack.push(dst)
            instructions += [.storeImmediate16(dst.address, symbol.offset)]
        case .stackStorage:
            instructions += computeAddressOfLocalVariable(symbol, depth)
        }
        
        return instructions
    }
    
    public override func arraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        return try arraySubscriptLvalue(symbol, depth, expr, elementType)
    }
    
    public override func dynamicArraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        return try dynamicArraySubscriptLvalue(symbol, depth, expr, elementType)
    }
}
