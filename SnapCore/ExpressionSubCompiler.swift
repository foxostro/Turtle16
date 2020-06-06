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
public class ExpressionSubCompiler: NSObject {
    let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    public func compile(expression: Expression) throws -> [YertleInstruction] {
        if let literal = expression as? Expression.Literal {
            return compile(literal: literal)
        } else if let binary = expression as? Expression.Binary {
            return try compile(binary: binary)
        } else if let identifier = expression as? Expression.Identifier {
            return try compile(identifier: identifier)
        } else if let assignment = expression as? Expression.Assignment {
            return try compile(assignment: assignment)
        } else {
            throw unsupportedError(expression: expression)
        }
    }
    
    private func compile(literal: Expression.Literal) -> [YertleInstruction] {
        return compile(intValue: literal.number.literal)
    }
    
    private func compile(intValue: Int) -> [YertleInstruction] {
        return [.push(intValue)]
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
        case .lt:
            return .lt
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
    
    private func compile(identifier: Expression.Identifier) throws -> [YertleInstruction] {
        let symbol = try symbols.resolve(identifierToken: identifier.identifier)
        switch symbol {
        case .label(let value):
            return compile(intValue: value)
        case .word(let storage):
            switch storage {
            case .constantInt(let value):
                return compile(intValue: value)
            case .staticStorage(let address, _):
                return [.load(address)]
            }
        }
    }
    
    private func compile(assignment: Expression.Assignment) throws -> [YertleInstruction] {
        let symbol = try symbols.resolve(identifierToken: assignment.identifier)
        switch symbol {
        case .label(_):
            throw CompilerError(line: assignment.identifier.lineNumber, message: "cannot assign to label `\(assignment.identifier.lexeme)'")
        case .word(let storage):
            switch storage {
            case .constantInt(_):
                throw CompilerError(line: assignment.identifier.lineNumber, message: "cannot assign to constant value `\(assignment.identifier.lexeme)'")
            case .staticStorage(let address, let isMutable):
                if isMutable {
                    return try compile(expression: assignment.child) + [.store(address)]
                } else {
                    throw CompilerError(line: assignment.identifier.lineNumber, message: "cannot assign to immutable variable `\(assignment.identifier.lexeme)'")
                }
            }
        }
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
