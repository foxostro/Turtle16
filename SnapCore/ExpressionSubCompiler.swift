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
    let compilerInstrinsicFunctions: [String: [YertleInstruction]] = [
        "peekMemory" : [.loadIndirect],
        "pokeMemory" : [.storeIndirect, .pop],
        "peekPeripheral" : [.peekPeripheral],
        "pokePeripheral" : [.pokePeripheral, .pop]
    ]
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    public func compile(expression: Expression) throws -> [YertleInstruction] {
        try ExpressionTypeChecker(symbols: symbols).check(expression: expression)
        
        switch expression {
        case let literal as Expression.LiteralWord:
            return try compile(literalInt: literal)
        case let literal as Expression.LiteralBoolean:
            return compile(literalBoolean: literal)
        case let binary as Expression.Binary:
            return try compile(binary: binary)
        case let unary as Expression.Unary:
            return try compile(unary: unary)
        case let identifier as Expression.Identifier:
            return try compile(identifier: identifier)
        case let assignment as Expression.InitialAssignment:
            return try compile(assignment: assignment)
        case let assignment as Expression.Assignment:
            return try compile(assignment: assignment)
        case let call as Expression.Call:
            return try compile(call: call)
        case let expr as Expression.As:
            return try compile(as: expr)
        case let expr as Expression.LiteralArray:
            return try compile(literalArray: expr)
        case let expr as Expression.Subscript:
            return try compile(subscript: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }
    
    private func compile(literalInt: Expression.LiteralWord) throws -> [YertleInstruction] {
        let value = literalInt.number.literal
        if value >= 0 && value < 256 {
            return [.push(value)]
        }
        if value >= 256 && value < 65536 {
            return [.push16(value)]
        }
        throw CompilerError(line: literalInt.number.lineNumber, message: "integer literal `\(literalInt.number.lexeme)' overflows when stored into `u16'")
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
        case (.eq, .u8, .u8): return right + left + [.eq]
        case (.eq, .u8, .u16): return right + left + [.push(0), .eq16]
        case (.eq, .u8, .constInt(let a)): return [.push(a)] + left + [.eq]
        case (.eq, .u16, .u8): return right + [.push(0)] + left + [.eq16]
        case (.eq, .u16, .u16): return right + left + [.eq16]
        case (.eq, .u16, .constInt(let a)): return [.push16(a)] + left + [.eq16]
        case (.eq, .constInt(let a), .u8): return right + [.push(a)] + [.eq]
        case (.eq, .constInt(let a), .u16): return right + [.push16(a)] + [.eq16]
        case (.eq, .constInt(let a), .constInt(let b)): return [.push((a == b) ? 1 : 0)]
        case (.eq, .bool, .bool): return right + left + [.eq]
        case (.eq, .bool, .constBool): return right + left + [.eq]
        case (.eq, .constBool, .bool): return right + left + [.eq]
        case (.eq, .constBool(let a), .constBool(let b)): return [.push((a == b) ? 1 : 0)]
        case (.ne, .u8, .u8): return right + left + [.ne]
        case (.ne, .u8, .u16): return right + left + [.push(0), .ne16]
        case (.ne, .u8, .constInt(let a)): return [.push(a)] + left + [.ne]
        case (.ne, .u16, .u8): return right + [.push(0)] + left + [.ne16]
        case (.ne, .u16, .u16): return right + left + [.ne16]
        case (.ne, .u16, .constInt(let a)): return [.push16(a)] + left + [.ne16]
        case (.ne, .constInt(let a), .u8): return right + [.push(a)] + [.ne]
        case (.ne, .constInt(let a), .u16): return right + [.push16(a)] + [.ne16]
        case (.ne, .constInt(let a), .constInt(let b)): return [.push((a == b) ? 1 : 0)]
        case (.ne, .bool, .bool): return right + left + [.ne]
        case (.ne, .bool, .constBool): return right + left + [.ne]
        case (.ne, .constBool, .bool): return right + left + [.ne]
        case (.ne, .constBool(let a), .constBool(let b)): return [.push((a != b) ? 1 : 0)]
        case (.lt, .u8, .u8): return right + left + [.lt]
        case (.lt, .u8, .u16): return right + left + [.push(0), .lt16]
        case (.lt, .u8, .constInt(let a)): return [.push(a)] + left + [.lt]
        case (.lt, .u16, .u8): return right + [.push(0)] + left + [.lt16]
        case (.lt, .u16, .u16): return right + left + [.lt16]
        case (.lt, .u16, .constInt(let a)): return [.push16(a)] + left + [.lt16]
        case (.lt, .constInt(let a), .u8): return right + [.push(a)] + [.lt]
        case (.lt, .constInt(let a), .u16): return right + [.push16(a)] + [.lt16]
        case (.lt, .constInt(let a), .constInt(let b)): return [.push((a < b) ? 1 : 0)]
        case (.gt, .u8, .u8): return right + left + [.gt]
        case (.gt, .u8, .u16): return right + left + [.push(0), .gt16]
        case (.gt, .u8, .constInt(let a)): return [.push(a)] + left + [.gt]
        case (.gt, .u16, .u8): return right + [.push(0)] + left + [.gt16]
        case (.gt, .u16, .u16): return right + left + [.gt16]
        case (.gt, .u16, .constInt(let a)): return [.push16(a)] + left + [.gt16]
        case (.gt, .constInt(let a), .u8): return right + [.push(a)] + [.gt]
        case (.gt, .constInt(let a), .u16): return right + [.push16(a)] + [.gt16]
        case (.gt, .constInt(let a), .constInt(let b)): return [.push((a > b) ? 1 : 0)]
        case (.le, .u8, .u8): return right + left + [.le]
        case (.le, .u8, .u16): return right + left + [.push(0), .le16]
        case (.le, .u8, .constInt(let a)): return [.push(a)] + left + [.le]
        case (.le, .u16, .u8): return right + [.push(0)] + left + [.le16]
        case (.le, .u16, .u16): return right + left + [.le16]
        case (.le, .u16, .constInt(let a)): return [.push16(a)] + left + [.le16]
        case (.le, .constInt(let a), .u8): return right + [.push(a)] + [.le]
        case (.le, .constInt(let a), .u16): return right + [.push16(a)] + [.le16]
        case (.le, .constInt(let a), .constInt(let b)): return [.push((a <= b) ? 1 : 0)]
        case (.ge, .u8, .u8): return right + left + [.ge]
        case (.ge, .u8, .u16): return right + left + [.push(0), .ge16]
        case (.ge, .u8, .constInt(let a)): return [.push(a)] + left + [.ge]
        case (.ge, .u16, .u8): return right + [.push(0)] + left + [.ge16]
        case (.ge, .u16, .u16): return right + left + [.ge16]
        case (.ge, .u16, .constInt(let a)): return [.push16(a)] + left + [.ge16]
        case (.ge, .constInt(let a), .u8): return right + [.push(a)] + [.ge]
        case (.ge, .constInt(let a), .u16): return right + [.push16(a)] + [.ge16]
        case (.ge, .constInt(let a), .constInt(let b)): return [.push((a >= b) ? 1 : 0)]
        case (.plus, .u8, .u8): return right + left + [.add]
        case (.plus, .u8, .u16): return right + left + [.push(0), .add16]
        case (.plus, .u8, .constInt(let a)): return [.push(a)] + left + [.add]
        case (.plus, .u16, .u8): return right + [.push(0)] + left + [.add16]
        case (.plus, .u16, .u16): return right + left + [.add16]
        case (.plus, .u16, .constInt(let a)): return [.push16(a)] + left + [.add16]
        case (.plus, .constInt(let a), .u8): return right + [.push(a)] + [.add]
        case (.plus, .constInt(let a), .u16): return right + [.push16(a)] + [.add16]
        case (.plus, .constInt(let a), .constInt(let b)):
            if a + b > 255 {
                return [.push16(a + b)]
            } else {
                return [.push(a + b)]
            }
        case (.minus, .u8, .u8): return right + left + [.sub]
        case (.minus, .u8, .u16): return right + left + [.push(0), .sub16]
        case (.minus, .u8, .constInt(let a)): return [.push(a)] + left + [.sub]
        case (.minus, .u16, .u8): return right + [.push(0)] + left + [.sub16]
        case (.minus, .u16, .u16): return right + left + [.sub16]
        case (.minus, .u16, .constInt(let a)): return [.push16(a)] + left + [.sub16]
        case (.minus, .constInt(let a), .u8): return right + [.push(a)] + [.sub]
        case (.minus, .constInt(let a), .u16): return right + [.push16(a)] + [.sub16]
        case (.minus, .constInt(let a), .constInt(let b)):
            if a - b > 255 {
                return [.push16(a - b)]
            } else {
                return [.push(a - b)]
            }
        case (.multiply, .u8, .u8): return right + left + [.mul]
        case (.multiply, .u8, .u16): return right + left + [.push(0), .mul16]
        case (.multiply, .u8, .constInt(let a)): return [.push(a)] + left + [.mul]
        case (.multiply, .u16, .u8): return right + [.push(0)] + left + [.mul16]
        case (.multiply, .u16, .u16): return right + left + [.mul16]
        case (.multiply, .u16, .constInt(let a)): return [.push16(a)] + left + [.mul16]
        case (.multiply, .constInt(let a), .u8): return right + [.push(a)] + [.mul16]
        case (.multiply, .constInt(let a), .u16): return right + [.push16(a)] + [.mul16]
        case (.multiply, .constInt(let a), .constInt(let b)):
            if a * b > 255 {
                return [.push16(a * b)]
            } else {
                return [.push(a * b)]
            }
        case (.divide, .u8, .u8): return right + left + [.div]
        case (.divide, .u8, .u16): return right + left + [.push(0), .div16]
        case (.divide, .u8, .constInt(let a)): return [.push(a)] + left + [.div]
        case (.divide, .u16, .u8): return right + [.push(0)] + left + [.div16]
        case (.divide, .u16, .u16): return right + left + [.div16]
        case (.divide, .u16, .constInt(let a)): return [.push16(a)] + left + [.div16]
        case (.divide, .constInt(let a), .u8): return right + [.push(a)] + [.div16]
        case (.divide, .constInt(let a), .u16): return right + [.push16(a)] + [.div16]
        case (.divide, .constInt(let a), .constInt(let b)):
            if a / b > 255 {
                return [.push16(a / b)]
            } else {
                return [.push(a / b)]
            }
        case (.modulus, .u8, .u8): return right + left + [.mod]
        case (.modulus, .u8, .u16): return right + left + [.push(0), .mod16]
        case (.modulus, .u8, .constInt(let a)): return [.push(a)] + left + [.mod]
        case (.modulus, .u16, .u8): return right + [.push(0)] + left + [.mod16]
        case (.modulus, .u16, .u16): return right + left + [.mod16]
        case (.modulus, .u16, .constInt(let a)): return [.push16(a)] + left + [.mod16]
        case (.modulus, .constInt(let a), .u8): return right + [.push(a)] + [.mod16]
        case (.modulus, .constInt(let a), .u16): return right + [.push16(a)] + [.mod16]
        case (.modulus, .constInt(let a), .constInt(let b)):
            if a % b > 255 {
                return [.push16(a % b)]
            } else {
                return [.push(a % b)]
            }
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
        default:
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
        default:
            abort()
        }
        return instructions
    }
    
    private func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
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
    
    private func compile(assignment: Expression.Assignment) throws -> [YertleInstruction] {
        let resolution = try symbols.resolveWithStackFrameDepth(identifierToken: assignment.identifier)
        let symbol = resolution.0
        let depth = resolution.1
        guard symbol.isMutable else {
            throw CompilerError(line: assignment.identifier.lineNumber, message: "cannot assign to immutable variable `\(assignment.identifier.lexeme)'")
        }
        
        var instructions: [YertleInstruction] = []
        instructions += try compileAndConvertExpressionForAssignment(rexpr: assignment.child, ltype: symbol.type)
        instructions += storeSymbol(symbol, depth)
        return instructions
    }
    
    private func compile(assignment: Expression.InitialAssignment) throws -> [YertleInstruction] {
        let resolution = try symbols.resolveWithStackFrameDepth(identifierToken: assignment.identifier)
        let symbol = resolution.0
        
        var instructions: [YertleInstruction] = []
        instructions += try compileAndConvertExpressionForAssignment(rexpr: assignment.child, ltype: symbol.type)
        return instructions
    }
    
    private func compileAndConvertExpressionForAssignment(rexpr: Expression, ltype: SymbolType) throws -> [YertleInstruction] {
        return try compileAndConvertExpression(rexpr: rexpr, ltype: ltype, isExplicitCast: false)
    }
    
    private func compileAndConvertExpressionForExplicitCast(rexpr: Expression, ltype: SymbolType) throws -> [YertleInstruction] {
        return try compileAndConvertExpression(rexpr: rexpr, ltype: ltype, isExplicitCast: true)
    }
    
    private func compileAndConvertExpression(rexpr: Expression, ltype: SymbolType, isExplicitCast: Bool) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        let rtype = try ExpressionTypeChecker(symbols: symbols).check(expression: rexpr)
        switch (rtype, ltype) {
        case (.bool, .bool), (.u8, .u8), (.u16, .u16):
            instructions += try compile(expression: rexpr)
        case (.constInt(let a), .u8):
            instructions += [.push(a)]
        case (.constInt(let a), .u16):
            instructions += [.push16(a)]
        case (.constBool(let a), .bool):
            instructions += [.push(a ? 1 : 0)]
        case (.u8, .u16):
            instructions += try compile(expression: rexpr)
            instructions += [.push(0)]
        case (.u16, .u8):
            guard isExplicitCast else {
                abort()
            }
            instructions += try compile(expression: rexpr)
            instructions += [.pop]
        case (.array(let n, let a), .array(let m, let b)):
            guard n == m else {
                abort()
            }
            guard a == b else {
                abort()
            }
            instructions += try compile(expression: rexpr)
        default:
            abort()
        }
        return instructions
    }
    
    private func storeSymbol(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        switch (symbol.storage, symbol.type) {
        case (.staticStorage, .u16):
            instructions += [.store16(symbol.offset)]
        case (.staticStorage, .u8), (.staticStorage, .bool):
            instructions += [.store(symbol.offset)]
        case (.stackStorage, .u16):
            instructions += computeAddressOfLocalVariable(symbol, depth)
            instructions += [.storeIndirect16]
        case (.stackStorage, .u8), (.stackStorage, .bool):
            instructions += computeAddressOfLocalVariable(symbol, depth)
            instructions += [.storeIndirect]
        default:
            abort()
        }
        return instructions
    }
    
    private func compile(call node: Expression.Call) throws -> [YertleInstruction] {
        let identifierToken = (node.callee as! Expression.Identifier).identifier
        let symbol = try symbols.resolve(identifierToken: identifierToken)
        switch symbol.type {
        case .function(name: _, mangledName: let mangledName, functionType: let typ):
            var instructions: [YertleInstruction] = []
            instructions += try pushFunctionArguments(typ, node)
            if let ins = compilerInstrinsicFunctions[mangledName] {
                instructions += ins
            } else {
                let fn = TokenIdentifier(lineNumber: identifierToken.lineNumber, lexeme: mangledName)
                instructions += [.jalr(fn)]
                instructions += popFunctionArguments(typ)
                instructions += doFunctionReturnValue(typ)
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
    
    private func pushFunctionArguments(_ typ: FunctionType, _ node: Expression.Call) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        for i in 0..<typ.arguments.count {
            instructions += try compileAndConvertExpressionForAssignment(rexpr: node.arguments[i],
                                                                         ltype: typ.arguments[i].argumentType)
        }
        return instructions
    }
    
    private func popFunctionArguments(_ typ: FunctionType) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        for arg in typ.arguments.reversed() {
            switch arg.argumentType {
            case .u16:       instructions += [.pop16]
            case .u8, .bool: instructions += [.pop]
            default:
                abort()
            }
        }
        return instructions
    }
    
    private func doFunctionReturnValue(_ typ: FunctionType) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
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
    }
    
    private func compile(as expr: Expression.As) throws -> [YertleInstruction] {
        let instructions = try compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: expr.targetType)
        return instructions
    }
    
    private func compile(literalArray expr: Expression.LiteralArray) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        instructions += [.push16(expr.elements.count)]
        for el in expr.elements {
            if let explicitElementType = expr.explicitElementType {
                instructions += try compileAndConvertExpressionForExplicitCast(rexpr: el, ltype: explicitElementType)
            } else {
                instructions += try compile(expression: el)
            }
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
            
            // Apply an offset to skip the array header.
            let kOffsetToSkipArrayHeader = 2
            instructions += [
                .push16(kOffsetToSkipArrayHeader),
                .add16
            ]
            
            // Push instructions to compute the subscript index.
            // This must be converted to u16 so we can do math with the address.
            instructions += try compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: .u16)
            
            // Multiply the index by the size of an element.
            // Add the element offset to the array address.
            instructions += [
                .push16(elementType.sizeof),
                .mul16,
                .add16
            ]
            
            // Load the element. This depends on the element type.
            switch elementType.sizeof {
            case 2:
                instructions += [.loadIndirect16]
            case 1:
                instructions += [.loadIndirect]
            default:
                abort()
            }
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
