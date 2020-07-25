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
public class LvalueExpressionCompiler: NSObject {
    let symbols: SymbolTable
    let kFramePointerAddressHi = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    let kFramePointerAddressLo = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    let typeChecker: LvalueExpressionTypeChecker
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
        self.typeChecker = LvalueExpressionTypeChecker(symbols: symbols)
    }
    
    func rvalueContext() -> RvalueExpressionCompiler {
        return RvalueExpressionCompiler(symbols: symbols)
    }
    
    func lvalueContext() -> LvalueExpressionCompiler {
        return LvalueExpressionCompiler(symbols: symbols)
    }
    
    public func compile(expression: Expression) throws -> [YertleInstruction] {
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
    
    private func compile(identifier expr: Expression.Identifier) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        
        let resolution = try symbols.resolveWithStackFrameDepth(identifierToken: expr.identifier)
        let symbol = resolution.0
        let depth = resolution.1
        guard symbol.isMutable else {
            throw CompilerError(line: expr.identifier.lineNumber, message: "cannot assign to immutable variable `\(expr.identifier.lexeme)'")
        }
        
        switch symbol.storage {
        case .staticStorage:
            instructions += [.push16(symbol.offset)]
        case .stackStorage:
            instructions += computeAddressOfLocalVariable(symbol, depth)
        }
        
        return instructions
    }
    
    func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        
        if symbol.offset >= 0 {
            // Push the symbol offset. This is used in the subtraction below.
            instructions += [.push16(symbol.offset)]
            
            // Load the frame pointer.
            instructions += [.load16(kFramePointerAddressHi)]
            
            // Follow the frame pointer `depth' times.
            instructions += [YertleInstruction].init(repeating: .loadIndirect16, count: depth)
            
            // Apply the offset to get the final address.
            instructions += [.sub16]
        } else {
            // Push the symbol offset. This is used in the subtraction below.
            instructions += [.push16(-symbol.offset)]
            
            // Load the frame pointer.
            instructions += [.load16(kFramePointerAddressHi)]
            
            // Follow the frame pointer `depth' times.
            instructions += [YertleInstruction].init(repeating: .loadIndirect16, count: depth)
            
            // Apply the offset to get the final address.
            instructions += [.add16]
        }
        
        return instructions
    }
    
    private func compile(subscript expr: Expression.Subscript) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        
        let resolution = try symbols.resolveWithStackFrameDepth(identifierToken: expr.tokenIdentifier)
        let symbol = resolution.0
        let depth = symbols.stackFrameIndex - resolution.1
        
        switch symbol.type {
        case .array(count: _, elementType: let elementType):
            // Push instructions to compute the absolute address of the array.
            switch symbol.storage {
            case .staticStorage:
                instructions += [.push16(symbol.offset)]
            case .stackStorage:
                instructions += computeAddressOfLocalVariable(symbol, depth)
            }
            
            // Push instructions to compute the subscript index.
            // This must be converted to u16 so we can do math with the address.
            instructions += try rvalueContext().compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: .u16)
            
            // Multiply the index by the size of an element.
            // Add the element offset to the array address.
            instructions += [
                .push16(elementType.sizeof),
                .mul16,
                .add16
            ]
        default:
            abort()
        }
        
        return instructions
    }
    
    private func unsupportedError(expression: Expression) -> Error {
        let message = "unsupported expression: \(expression)"
        if let lineNumber = expression.tokens.first?.lineNumber {
            return CompilerError(line: lineNumber, message: message)
        } else {
            return CompilerError(message: message)
        }
    }
}
