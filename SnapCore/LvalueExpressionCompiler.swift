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
    let kSizeOfAddress = 2
    let typeChecker: LvalueExpressionTypeChecker
    
    public override init(symbols: SymbolTable = SymbolTable(),
                         labelMaker: LabelMaker = LabelMaker(),
                         mapMangledFunctionName: MangledFunctionNameMap = MangledFunctionNameMap(),
                         temporaryStack: CompilerTemporariesStack =     CompilerTemporariesStack(),
                         temporaryAllocator: CompilerTemporariesAllocator = CompilerTemporariesAllocator()) {
        self.typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
        super.init(symbols: symbols,
                   labelMaker: labelMaker,
                   mapMangledFunctionName: mapMangledFunctionName,
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
        case let expr as Expression.Get:
            return try compile(get: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }
    
    private func compile(identifier expr: Expression.Identifier) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let resolution = try symbols.resolveWithStackFrameDepth(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier)
        let symbol = resolution.0
        let depth = symbols.stackFrameIndex - resolution.1
        
        switch symbol.storage {
        case .staticStorage:
            let dst = temporaryAllocator.maybeAllocate(size: kSizeOfAddress)!
            temporaryStack.push(dst)
            instructions += [.storeImmediate16(dst.address, symbol.offset)]
        case .stackStorage:
            instructions += computeAddressOfLocalVariable(symbol, depth)
        }
        
        return instructions
    }
    
    private func compile(get expr: Expression.Get) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let name = expr.member.identifier
        let resultType = try rvalueContext().typeChecker.check(expression: expr.expr)
        
        switch resultType {
        case .constStructType(let typ), .structType(let typ):
            instructions += try compile(expression: expr.expr)
            
            // We'll leave this temporary on the stack and modify it in place.
            let tempResult = temporaryStack.peek()
            let symbol = try typ.symbols.resolve(identifier: name)
            instructions += [
                .addi16(tempResult.address, tempResult.address, symbol.offset)
            ]
        case .constPointer(let typ), .pointer(let typ):
            instructions += try rvalueContext().compile(expression: expr.expr)
            if name == "pointee" {
                // Do nothing. The pointer value is already on the top of the
                // compiler temporaries stack, and that's what we want when
                // evaluating `pointee' in an lvalue context.
            } else {
                switch typ {
                case .structType(let b):
                    // We'll leave this temporary on the stack and modify it in place.
                    let tempResult = temporaryStack.peek()
                    let symbol = try b.symbols.resolve(identifier: name)
                    instructions += [
                        .addi16(tempResult.address, tempResult.address, symbol.offset)
                    ]
                default:
                    assert(false) // unreachable
                    throw unsupportedError(expression: expr.expr)
                }
            }
        default:
            throw unsupportedError(expression: expr.expr)
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
