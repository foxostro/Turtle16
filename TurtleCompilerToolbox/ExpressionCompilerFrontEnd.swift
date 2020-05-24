//
//  ExpressionCompilerFrontEnd.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

// Takes an expression and generates intermediate code which can be more easily
// compiled to machine code. (see also ExpressionCompilerBackEnd)
public class ExpressionCompilerFrontEnd: NSObject {
    let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    public func compile(expression: Expression) throws -> [StackIR] {
        if let literal = expression as? Expression.Literal {
            return compile(literal: literal)
        } else if let binary = expression as? Expression.Binary {
            return try compile(binary: binary)
        } else if let identifier = expression as? Expression.Identifier {
            return try compile(identifier: identifier)
        } else {
            throw unsupportedError(expression: expression)
        }
    }
    
    func compile(literal: Expression.Literal) -> [StackIR] {
        let value = literal.number.literal
        return [.push(value)]
    }
    
    func compile(binary: Expression.Binary) throws -> [StackIR] {
        let right: [StackIR] = try compile(expression: binary.right)
        let left: [StackIR] = try compile(expression: binary.left)
        return right + left + [getOperator(binary: binary)]
    }
    
    func getOperator(binary: Expression.Binary) -> StackIR {
        switch binary.op.op {
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
    
    func compile(identifier: Expression.Identifier) throws -> [StackIR] {
        if let symbol = symbols[identifier.identifier.lexeme] {
            return [.push(symbol)]
        }
        throw Expression.MustBeCompileTimeConstantError(line: identifier.identifier.lineNumber)
    }
    
    func unsupportedError(expression: Expression) -> Error {
        let message = "unsupported expression: \(expression)"
        if let lineNumber = expression.tokens.first?.lineNumber {
            return CompilerError(line: lineNumber, message: message)
        } else {
            return CompilerError(message: message)
        }
    }
}
