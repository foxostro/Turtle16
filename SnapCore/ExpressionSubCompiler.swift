//
//  ExpressionSubCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Takes an expression and generates intermediate code which can be more easily
// compiled to machine code. (see also YertleToTurtleMachineCodeCompiler)
// The expression will push the result onto the stack. The client assumes the
// responsibility of cleaning up.
public class ExpressionSubCompiler: NSObject {
    let symbols: SymbolTable
    let kFramePointerAddressHi = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    let kFramePointerAddressLo = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    public func compile(expression: Expression) throws -> [YertleInstruction] {
        try ExpressionTypeChecker(symbols: symbols).check(expression: expression)
        
        if let literal = expression as? Expression.LiteralWord {
            return compile(literalWord: literal)
        } else if let literal = expression as? Expression.LiteralBoolean {
            return compile(literalBoolean: literal)
        } else if let binary = expression as? Expression.Binary {
            return try compile(binary: binary)
        } else if let unary = expression as? Expression.Unary {
            return try compile(unary: unary)
        } else if let identifier = expression as? Expression.Identifier {
            return try compile(identifier: identifier)
        } else if let assignment = expression as? Expression.Assignment {
            return try compile(assignment: assignment)
        }
        
        throw unsupportedError(expression: expression)
    }
    
    private func compile(literalWord: Expression.LiteralWord) -> [YertleInstruction] {
        return compile(intValue: literalWord.number.literal)
    }
    
    private func compile(intValue: Int) -> [YertleInstruction] {
        return [.push(intValue)]
    }
    
    private func compile(literalBoolean: Expression.LiteralBoolean) -> [YertleInstruction] {
        return compile(boolValue: literalBoolean.boolean.literal)
    }
    
    private func compile(boolValue: Bool) -> [YertleInstruction] {
        return compile(intValue: boolValue ? 1 : 0)
    }
    
    private func compile(unary: Expression.Unary) throws -> [YertleInstruction] {
        var result: [YertleInstruction] = []
        result += [.push(0)]
        result += try compile(expression: unary.child)
        result += [try getOperator(unary: unary)]
        return result
    }
    
    private func compile(binary: Expression.Binary) throws -> [YertleInstruction] {
        let right: [YertleInstruction] = try compile(expression: binary.right)
        let left: [YertleInstruction] = try compile(expression: binary.left)
        return right + left + [getOperator(binary: binary)]
    }
    
    private func getOperator(binary: Expression.Binary) -> YertleInstruction {
        switch binary.op.op {
        case .eq:
            return .eq
        case .ne:
            return .ne
        case .lt:
            return .lt
        case .gt:
            return .gt
        case .le:
            return .le
        case .ge:
            return .ge
        case .plus:
            return .add
        case .minus:
            return .sub
        case .multiply:
            return .mul
        case .divide:
            return .div
        case .modulus:
            return .mod
        }
    }
    
    private func getOperator(unary: Expression.Unary) throws -> YertleInstruction {
        switch unary.op.op {
        case .minus:
            return .sub
        default:
            let lineNumber = unary.tokens.first?.lineNumber ?? -1
            throw CompilerError(line: lineNumber, message: "`\(unary.op.lexeme)' is not a prefix unary operator")
        }
    }
    
    private func compile(identifier: Expression.Identifier) throws -> [YertleInstruction] {
        let resolution = try symbols.resolveWithDepth(identifierToken: identifier.identifier)
        let symbol = resolution.0
        let depth = resolution.1
        switch symbol.storage {
        case .staticStorage:
            return loadStaticSymbol(symbol)
        case .stackStorage:
            return loadStackSymbol(symbol, depth)
        }
    }
    
    private func loadStaticSymbol(_ symbol: Symbol) -> [YertleInstruction] {
        switch symbol.type {
        case .u8, .boolean:
            return [.load(symbol.offset)]
        }
    }
    
    private func loadStackSymbol(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        switch symbol.type {
        case .u8, .boolean:
            return loadOneWord(symbol, depth)
        }
    }
    
    private func loadOneWord(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        instructions += computeAddressOfLocalVariable(symbol, depth)
        instructions += [.loadIndirect] // load the value at the final computed address
        return instructions
    }
    
    private func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        // TODO: Assume the high byte is 0xfe. This will not work if the stack grows larger than 256 bytes. To fix this, the IR language needs to support 16-bit math.
        let kFramePointerHighByte = 0xfe
        var instructions: [YertleInstruction] = []
        instructions += [
            .push(kFramePointerHighByte), // HACK: just assume the high byte of the frame pointer one level up is 0xfe
            .push(symbol.offset)
        ]
        instructions += [YertleInstruction].init(repeating: .push(kFramePointerHighByte), count: depth)
        instructions += [
            .load(kFramePointerAddressLo)
        ]
        instructions += [YertleInstruction].init(repeating: .loadIndirect, count: depth)
        instructions += [
            .sub, // apply the offset to get the final address
        ]
        return instructions
    }
    
    private func compile(assignment: Expression.Assignment) throws -> [YertleInstruction] {
        let resolution = try symbols.resolveWithDepth(identifierToken: assignment.identifier)
        let symbol = resolution.0
        let depth = resolution.1
        guard symbol.isMutable else {
            throw CompilerError(line: assignment.identifier.lineNumber, message: "cannot assign to immutable variable `\(assignment.identifier.lexeme)'")
        }
        
        switch symbol.type {
        case .u8, .boolean:
            return try compile(expression: assignment.child) + storeOneWord(symbol, depth)
        }
    }
    
    private func storeOneWord(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        assert(symbol.isMutable)
        switch symbol.storage {
        case .staticStorage:
            return storeOneWordStatic(symbol: symbol)
        case .stackStorage:
            return storeOneWordStack(symbol, depth)
        }
    }
    
    private func storeOneWordStatic(symbol: Symbol) -> [YertleInstruction] {
        assert(symbol.isMutable)
        assert(symbol.storage == .staticStorage)
        return [.store(symbol.offset)]
    }
    
    private func storeOneWordStack(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        assert(symbol.isMutable)
        assert(symbol.storage == .stackStorage)
        var instructions: [YertleInstruction] = []
        instructions += computeAddressOfLocalVariable(symbol, depth)
        instructions += [.storeIndirect] // store the value at the final computed address
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
