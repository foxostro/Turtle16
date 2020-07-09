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
            return try compile(literalInt: literal)
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
        } else if let call = expression as? Expression.Call {
            return try compile(call: call)
        }
        
        throw unsupportedError(expression: expression)
    }
    
    private func compile(literalInt: Expression.LiteralWord) throws -> [YertleInstruction] {
        let value = literalInt.number.literal
        if value >= 0 && value < 256 {
            return [.push(value)]
        }
        if value >= 256 && value < 65536 {
            return [.push16(value)]
        }
        throw CompilerError(line: literalInt.number.lineNumber, message: "literal int `\(literalInt.number.lexeme)' is too large")
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
        let childExpr = try compile(expression: unary.child)
        let childType = try ExpressionTypeChecker(symbols: symbols).check(expression: unary.child)
        var result: [YertleInstruction] = []
        switch childType {
        case .u16:
            result += childExpr
            result += [.push16(0)]
            switch unary.op.op {
            case .minus:
                result += [.sub16]
            default:
                throw invalidUnaryOperator(unary)
            }
        case .u8:
            result += childExpr
            result += [.push(0)]
            switch unary.op.op {
            case .minus:
                result += [.sub]
            default:
                throw invalidUnaryOperator(unary)
            }
        default:
            throw unsupportedError(expression: unary)
        }
        return result
    }
    
    private func invalidUnaryOperator(_ unary: Expression.Unary) -> CompilerError {
        let lineNumber = unary.tokens.first?.lineNumber ?? -1
        return CompilerError(line: lineNumber, message: "`\(unary.op.lexeme)' is not a prefix unary operator")
    }
    
    private func compile(binary: Expression.Binary) throws -> [YertleInstruction] {
        let right: [YertleInstruction] = try compile(expression: binary.right)
        let rightType = try ExpressionTypeChecker(symbols: symbols).check(expression: binary.right)
        
        let left: [YertleInstruction] = try compile(expression: binary.left)
        let leftType = try ExpressionTypeChecker(symbols: symbols).check(expression: binary.left)
        
        switch (binary.op.op, leftType, rightType) {
        case (.eq, .u8, .u8):         return right + left + [.eq]
        case (.eq, .u8, .u16):        return right + left + [.push(0), .eq16]
        case (.eq, .u16, .u8):        return right + [.push(0)] + left + [.eq16]
        case (.eq, .u16, .u16):       return right + left + [.eq16]
        case (.eq, .bool, .bool):     return right + left + [.eq]
        case (.ne, .u8, .u8):         return right + left + [.ne]
        case (.ne, .u8, .u16):        return right + left + [.push(0), .ne16]
        case (.ne, .u16, .u8):        return right + [.push(0)] + left + [.ne16]
        case (.ne, .u16, .u16):       return right + left + [.ne16]
        case (.ne, .bool, .bool):     return right + left + [.ne]
        case (.lt, .u8, .u8):         return right + left + [.lt]
        case (.lt, .u8, .u16):        return right + left + [.push(0), .lt16]
        case (.lt, .u16, .u8):        return right + [.push(0)] + left + [.lt16]
        case (.lt, .u16, .u16):       return right + left + [.lt16]
        case (.lt, .bool, .bool):     return right + left + [.lt]
        case (.gt, .u8, .u8):         return right + left + [.gt]
        case (.gt, .u8, .u16):        return right + left + [.push(0), .gt16]
        case (.gt, .u16, .u8):        return right + [.push(0)] + left + [.gt16]
        case (.gt, .u16, .u16):       return right + left + [.gt16]
        case (.gt, .bool, .bool):     return right + left + [.gt]
        case (.le, .u8, .u8):         return right + left + [.le]
        case (.le, .u8, .u16):        return right + left + [.push(0), .le16]
        case (.le, .u16, .u8):        return right + [.push(0)] + left + [.le16]
        case (.le, .u16, .u16):       return right + left + [.le16]
        case (.le, .bool, .bool):     return right + left + [.le]
        case (.ge, .u8, .u8):         return right + left + [.ge]
        case (.ge, .u8, .u16):        return right + left + [.push(0), .ge16]
        case (.ge, .u16, .u8):        return right + [.push(0)] + left + [.ge16]
        case (.ge, .u16, .u16):       return right + left + [.ge16]
        case (.ge, .bool, .bool):     return right + left + [.ge]
        case (.plus, .u8, .u8):       return right + left + [.add]
        case (.plus, .u8, .u16):      return right + left + [.push(0), .add16]
        case (.plus, .u16, .u8):      return right + [.push(0)] + left + [.add16]
        case (.plus, .u16, .u16):     return right + left + [.add16]
        case (.minus, .u8, .u8):      return right + left + [.sub]
        case (.minus, .u8, .u16):     return right + left + [.push(0), .sub16]
        case (.minus, .u16, .u8):     return right + [.push(0)] + left + [.sub16]
        case (.minus, .u16, .u16):    return right + left + [.sub16]
        case (.multiply, .u8, .u8):   return right + left + [.mul]
        case (.multiply, .u8, .u16):  return right + left + [.push(0), .mul16]
        case (.multiply, .u16, .u8):  return right + [.push(0)] + left + [.mul16]
        case (.multiply, .u16, .u16): return right + left + [.mul16]
        case (.divide, .u8, .u8):     return right + left + [.div]
        case (.divide, .u8, .u16):    return right + left + [.push(0), .div16]
        case (.divide, .u16, .u8):    return right + [.push(0)] + left + [.div16]
        case (.divide, .u16, .u16):   return right + left + [.div16]
        case (.modulus, .u8, .u8):    return right + left + [.mod]
        case (.modulus, .u8, .u16):   return right + left + [.push(0), .mod16]
        case (.modulus, .u16, .u8):   return right + [.push(0)] + left + [.mod16]
        case (.modulus, .u16, .u16):  return right + left + [.mod16]
        default:
            throw unsupportedError(expression: binary)
        }
    }
    
    private func compile(identifier: Expression.Identifier) throws -> [YertleInstruction] {
        let resolution = try symbols.resolveWithStackFrameDepth(identifierToken: identifier.identifier)
        let symbol = resolution.0
        let depth = symbols.stackFrameIndex - resolution.1
        switch symbol.storage {
        case .staticStorage:
            return loadStaticSymbol(symbol)
        case .stackStorage:
            return loadStackSymbol(symbol, depth)
        }
    }
    
    private func loadStaticSymbol(_ symbol: Symbol) -> [YertleInstruction] {
        switch symbol.type {
        case .u16:
            return [.load16(symbol.offset)]
        case .u8, .bool:
            return [.load(symbol.offset)]
        case .function, .void:
            abort()
        }
    }
    
    private func loadStackSymbol(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        instructions += computeAddressOfLocalVariable(symbol, depth)
        switch symbol.type {
        case .u16:
            instructions += [.loadIndirect16]
        case .u8, .bool:
            instructions += [.loadIndirect]
        case .function, .void:
            abort()
        }
        return instructions
    }
    
    private func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        
        // Load the frame pointer.
        instructions += [.load16(kFramePointerAddressHi)]
        
        // Follow the frame pointer `depth' times.
        instructions += [YertleInstruction].init(repeating: .loadIndirect16, count: depth)
        
        // Push the symbol offset. This is used in the subtraction below.
        instructions += [.push16(symbol.offset)]
        
        // Apply the offset to get the final address.
        instructions += [.sub16]
        
        return instructions
    }
    
    private func compile(assignment: Expression.Assignment) throws -> [YertleInstruction] {
        let resolution = try symbols.resolveWithStackFrameDepth(identifierToken: assignment.identifier)
        let symbol = resolution.0
        let depth = resolution.1
        guard symbol.isMutable else {
            throw CompilerError(line: assignment.identifier.lineNumber, message: "cannot assign to immutable variable `\(assignment.identifier.lexeme)'")
        }
        
        var instructions: [YertleInstruction] = []
        
        switch symbol.type {
        case .u16, .u8, .bool:
            let expr = assignment.child
            let exprType = try ExpressionTypeChecker(symbols: symbols).check(expression: expr)
            let compiledInstructions = try compile(expression: expr)
            switch (exprType, symbol.type) {
            case (.bool, .bool): instructions += compiledInstructions
            case (.u8, .u8):     instructions += compiledInstructions
            case (.u8, .u16):    instructions += compiledInstructions + [.push(0)]
            case (.u16, .u16):   instructions += compiledInstructions
            default:
                abort()
            }
            instructions += storeSymbol(symbol, depth)
        case .function, .void:
            abort()
        }
        
        return instructions
    }
    
    private func storeSymbol(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        assert(symbol.isMutable)
        var instructions: [YertleInstruction] = []
        switch symbol.storage {
        case .staticStorage:
            switch symbol.type {
            case .u16:
                instructions += [.store16(symbol.offset)]
            case .u8, .bool:
                instructions += [.store(symbol.offset)]
            case .function, .void:
                abort()
            }
        case .stackStorage:
            instructions += computeAddressOfLocalVariable(symbol, depth)
            switch symbol.type {
            case .u16:
                instructions += [.storeIndirect16]
            case .u8, .bool:
                instructions += [.storeIndirect]
            case .function, .void:
                abort()
            }
        }
        return instructions
    }
    
    private func compile(call node: Expression.Call) throws -> [YertleInstruction] {
        let identifierToken = (node.callee as! Expression.Identifier).identifier
        let symbol = try symbols.resolve(identifierToken: identifierToken)
        switch symbol.type {
        case .function(name: _, mangledName: let mangledName, functionType: let typ):
            var instructions: [YertleInstruction] = []
            for i in 0..<typ.arguments.count {
                let argExpr = node.arguments[i]
                let arg = try compile(expression: argExpr)
                let expectedType = typ.arguments[i].argumentType
                let actualType = try ExpressionTypeChecker(symbols: symbols).check(expression: argExpr)
                switch (actualType, expectedType) {
                case (.bool, .bool): instructions += arg
                case (.u8, .u8):     instructions += arg
                case (.u8, .u16):    instructions += arg + [.push(0)]
                case (.u16, .u16):   instructions += arg
                default:
                    abort()
                }
            }
            instructions += [
                .jalr(TokenIdentifier(lineNumber: identifierToken.lineNumber, lexeme: mangledName))
            ]
            
            for arg in typ.arguments.reversed() {
                switch arg.argumentType {
                case .u16:       instructions += [.pop16]
                case .u8, .bool: instructions += [.pop]
                default:
                    abort()
                }
            }
            
            switch typ.returnType {
            case .u16:
                instructions += [.load16(SnapToYertleCompiler.kReturnValueScratchLocation)]
            case .u8, .bool:
                instructions += [.load(SnapToYertleCompiler.kReturnValueScratchLocation)]
            case .void:
                break
            default:
                abort()
            }
            
            return instructions
        default:
            let message = "cannot call value of non-function type `\(String(describing: symbol.type))'"
            if let lineNumber = node.tokens.first?.lineNumber {
                throw CompilerError(line: lineNumber, message: message)
            } else {
                throw CompilerError(message: message)
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
