//
//  RvalueExpressionCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Takes an expression and generates intermediate code which can be more easily
// compiled to machine code. (see also CrackleToTurtleMachineCodeCompiler)
// The expression will push the result onto the stack. The client assumes the
// responsibility of cleaning up.
public class RvalueExpressionCompiler: BaseExpressionCompiler {
    public let typeChecker: RvalueExpressionTypeChecker
    
    private let kSliceBaseAddressOffset = 0
    private let kSliceBaseAddressSize = 2
    private let kSliceCountOffset = 2
    private let kSliceCountSize = 2
    private let kSliceSize = 4 // kSliceBaseAddressSize + kSliceCountSize
    private let kStackPointerAddress: Int = Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi)
    
    public static func bindCompilerIntrinsicFunctions(symbols: SymbolTable) -> SymbolTable {
        return bindCompilerInstrinsicHlt(symbols:
            bindCompilerInstrinsicPokePeripheral(symbols:
                bindCompilerInstrinsicPeekPeripheral(symbols:
                    bindCompilerInstrinsicPokeMemory(symbols:
                        bindCompilerInstrinsicPeekMemory(symbols: symbols)))))
    }
    
    private static func bindCompilerInstrinsicPeekMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "peekMemory"
        let functionType = FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "address", type: .u16)])
        let typ: SymbolType = .function(name: name, mangledName: name, functionType: functionType)
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPokeMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "pokeMemory"
        let functionType = FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "value", type: .u8), FunctionType.Argument(name: "address", type: .u16)])
        let typ: SymbolType = .function(name: name, mangledName: name, functionType: functionType)
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPeekPeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "peekPeripheral"
        let functionType = FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "address", type: .u16), FunctionType.Argument(name: "device", type: .u8)])
        let typ: SymbolType = .function(name: name, mangledName: name, functionType: functionType)
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPokePeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "pokePeripheral"
        let functionType = FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "value", type: .u8), FunctionType.Argument(name: "address", type: .u16), FunctionType.Argument(name: "device", type: .u8)])
        let typ: SymbolType = .function(name: name, mangledName: name, functionType: functionType)
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicHlt(symbols: SymbolTable) -> SymbolTable{
        let name = "hlt"
        let functionType = FunctionType(returnType: .void, arguments: [])
        let typ: SymbolType = .function(name: name, mangledName: name, functionType: functionType)
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    public override init(symbols: SymbolTable = SymbolTable(),
                         labelMaker: LabelMaker = LabelMaker(),
                         temporaryStack: CompilerTemporariesStack = CompilerTemporariesStack(),
                         temporaryAllocator: CompilerTemporariesAllocator = CompilerTemporariesAllocator()) {
        self.typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        super.init(symbols: symbols,
                   labelMaker: labelMaker,
                   temporaryStack: temporaryStack,
                   temporaryAllocator: temporaryAllocator)
    }
    
    public override func compile(expression: Expression) throws -> [CrackleInstruction] {
        try typeChecker.check(expression: expression)
        
        switch expression {
        case let literal as Expression.LiteralInt:
            return try compile(literalInt: literal)
        case let literal as Expression.LiteralBool:
            return compile(literalBoolean: literal)
        case let binary as Expression.Binary:
            return try compile(binary: binary)
        case let group as Expression.Group:
            return try compile(expression: group.expression)
        case let unary as Expression.Unary:
            return try compile(unary: unary)
        case let identifier as Expression.Identifier:
            return try compile(identifier: identifier)
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
        case let expr as Expression.Get:
            return try compile(get: expr)
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error about an unsupported expression before
            // we get to this point.
            assert(false)
            throw unsupportedError(expression: expression)
        }
    }
    
    private func compile(literalInt: Expression.LiteralInt) throws -> [CrackleInstruction] {
        let value = literalInt.value
        if value >= 0 && value < 256 {
            let temp = temporaryAllocator.allocate()
            temporaryStack.push(temp)
            return [.storeImmediate(temp.address, value)]
        }
        if value >= 256 && value < 65536 {
            let temp = temporaryAllocator.allocate()
            temporaryStack.push(temp)
            return [.storeImmediate16(temp.address, value)]
        }
        let lexeme = literalInt.sourceAnchor?.text ?? "\(value)"
        throw CompilerError(sourceAnchor: literalInt.sourceAnchor, message: "integer literal `\(lexeme)' overflows when stored into `u16'")
    }
    
    private func compile(literalBoolean: Expression.LiteralBool) -> [CrackleInstruction] {
        let temp = temporaryAllocator.allocate()
        temporaryStack.push(temp)
        return [.storeImmediate(temp.address, literalBoolean.value ? 1 : 0)]
    }
    
    private func compile(unary: Expression.Unary) throws -> [CrackleInstruction] {
        let childExpr = try compile(expression: unary.child)
        let childType = try typeChecker.check(expression: unary.child)
        
        let a = temporaryAllocator.allocate()
        let c = temporaryAllocator.allocate()
        let b = temporaryStack.pop()
        temporaryStack.push(c)
        
        var result: [CrackleInstruction] = []
        switch (childType, unary.op) {
        case (.u16, .minus):
            result += childExpr
            result += [.storeImmediate16(a.address, 0)]
            result += [.tac_sub16(c.address, a.address, b.address)]
        case (.u8, .minus):
            result += childExpr
            result += [.storeImmediate(a.address, 0)]
            result += [.tac_sub(c.address, a.address, b.address)]
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error about an invalid unary operator before
            // we get to this point.
            assert(false)
            throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "`\(unary.op)' is not a prefix unary operator")
        }
        
        a.consume()
        b.consume()
        
        return result
    }
    
    private func compile(binary: Expression.Binary) throws -> [CrackleInstruction] {
        let rightType = try typeChecker.check(expression: binary.right)
        let leftType = try typeChecker.check(expression: binary.left)
        
        switch (binary.op, leftType, rightType) {
        case (.eq, .u8, .u8),
             (.eq, .u8, .constInt),
             (.eq, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_eq(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.eq, .u8, .u16),
             (.eq, .u16, .u8),
             (.eq, .u16, .u16),
             (.eq, .u16, .constInt),
             (.eq, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_eq16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.eq, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a == b) ? 1 : 0)]
        case (.eq, .bool, .bool),
             (.eq, .bool, .constBool),
             (.eq, .constBool, .bool):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .bool)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .bool)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_eq(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.eq, .constBool(let a), .constBool(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a == b) ? 1 : 0)]
        case (.ne, .u8, .u8),
             (.ne, .u8, .constInt),
             (.ne, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_ne(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ne, .u8, .u16),
             (.ne, .u16, .u8),
             (.ne, .u16, .u16),
             (.ne, .u16, .constInt),
             (.ne, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_ne16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ne, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a != b) ? 1 : 0)]
        case (.ne, .bool, .bool),
             (.ne, .bool, .constBool),
             (.ne, .constBool, .bool):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .bool)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .bool)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_ne(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ne, .constBool(let a), .constBool(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a != b) ? 1 : 0)]
        case (.lt, .u8, .u8),
             (.lt, .u8, .constInt),
             (.lt, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_lt(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.lt, .u8, .u16),
             (.lt, .u16, .u8),
             (.lt, .u16, .u16),
             (.lt, .u16, .constInt),
             (.lt, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_lt16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.lt, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a < b) ? 1 : 0)]
        case (.gt, .u8, .u8),
             (.gt, .constInt, .u8),
             (.gt, .u8, .constInt):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_gt(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.gt, .u8, .u16),
             (.gt, .u16, .u8),
             (.gt, .u16, .u16),
             (.gt, .u16, .constInt),
             (.gt, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_gt16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.gt, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a > b) ? 1 : 0)]
        case (.le, .u8, .u8),
             (.le, .u8, .constInt),
             (.le, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_le(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.le, .u8, .u16),
             (.le, .u16, .u8),
             (.le, .u16, .u16),
             (.le, .u16, .constInt),
             (.le, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_le16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.le, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a <= b) ? 1 : 0)]
        case (.ge, .u8, .u8),
             (.ge, .u8, .constInt),
             (.ge, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_ge(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ge, .u8, .u16),
             (.ge, .u16, .u8),
             (.ge, .u16, .u16),
             (.ge, .u16, .constInt),
             (.ge, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_ge16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ge, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a >= b) ? 1 : 0)]
        case (.plus, .u8, .u8),
             (.plus, .constInt, .u8),
             (.plus, .u8, .constInt):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_add(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.plus, .u8, .u16),
             (.plus, .u16, .u8),
             (.plus, .u16, .u16),
             (.plus, .u16, .constInt),
             (.plus, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_add16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.plus, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            let value = a + b
            if value > 255 {
                return [.storeImmediate16(dst.address, value)]
            } else {
                return [.storeImmediate(dst.address, value)]
            }
        case (.minus, .u8, .u8),
             (.minus, .constInt, .u8),
             (.minus, .u8, .constInt):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_sub(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.minus, .u8, .u16),
             (.minus, .u16, .u8),
             (.minus, .u16, .u16),
             (.minus, .u16, .constInt),
             (.minus, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_sub16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.minus, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            let value = a - b
            if value > 255 {
                return [.storeImmediate16(dst.address, value)]
            } else {
                return [.storeImmediate(dst.address, value)]
            }
        case (.multiply, .u8, .u8),
             (.multiply, .u8, .constInt),
             (.multiply, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_mul(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.multiply, .u8, .u16),
             (.multiply, .u16, .u8),
             (.multiply, .u16, .u16),
             (.multiply, .u16, .constInt),
             (.multiply, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_mul16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.multiply, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            let value = a * b
            if value > 255 {
                return [.storeImmediate16(dst.address, value)]
            } else {
                return [.storeImmediate(dst.address, value)]
            }
        case (.divide, .u8, .u8),
             (.divide, .u8, .constInt),
             (.divide, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_div(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.divide, .u8, .u16),
             (.divide, .u16, .u8),
             (.divide, .u16, .u16),
             (.divide, .u16, .constInt),
             (.divide, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_div16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.divide, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            let value = a / b
            if value > 255 {
                return [.storeImmediate16(dst.address, value)]
            } else {
                return [.storeImmediate(dst.address, value)]
            }
        case (.modulus, .u8, .u8),
             (.modulus, .u8, .constInt),
             (.modulus, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_mod(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.modulus, .u8, .u16),
             (.modulus, .u16, .u8),
             (.modulus, .u16, .u16),
             (.modulus, .u16, .constInt),
             (.modulus, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.tac_mod16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.modulus, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            let value = a % b
            if value > 255 {
                return [.storeImmediate16(dst.address, value)]
            } else {
                return [.storeImmediate(dst.address, value)]
            }
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
    }
    
    private func compile(identifier: Expression.Identifier) throws -> [CrackleInstruction] {
        let resolution = try symbols.resolveWithStackFrameDepth(sourceAnchor: identifier.sourceAnchor, identifier: identifier.identifier)
        let symbol = resolution.0
        let depth = symbols.stackFrameIndex - resolution.1
        switch symbol.storage {
        case .staticStorage:
            return loadStaticSymbol(symbol)
        case .stackStorage:
            return loadStackSymbol(symbol, depth)
        }
    }
    
    public func compile(assignment: Expression.Assignment) throws -> [CrackleInstruction] {
        let ltype = try LvalueExpressionTypeChecker(symbols: symbols).check(expression: assignment.lexpr)
        var instructions: [CrackleInstruction] = []
        
        // Calculate the lvalue, the destination in memory for the assignment.
        let ctx = lvalueContext()
        ctx.shouldAllowAssignmentToImmutableVariables = assignment is Expression.InitialAssignment
        let lvalue_proc = try ctx.compile(expression: assignment.lexpr)
        instructions += lvalue_proc
        let lvalue = temporaryStack.pop()
        
        // Different implementations of assignment for different types.
        let rtype = try typeChecker.check(expression: assignment.rexpr)
        switch (rtype, ltype) {
        case (.array(let n, _), .array(let m, let b)):
            assert(n == m || m == nil)
            switch assignment.rexpr {
            case let literalArray as Expression.LiteralArray:
                // In the case where we assign a literal array to some array
                // symbol, iterate the expressions for each element, evaluate
                // the expression, and copy the result to the address of the
                // next array element.
                let tempElementSize = temporaryAllocator.allocate()
                instructions += [.storeImmediate16(tempElementSize.address, b.sizeof)]
                
                for i in 0..<literalArray.elements.count {
                    let el = literalArray.elements[i]
                    
                    // Evaluate the expression and copy to the destination.
                    instructions += try compileAndConvertExpression(rexpr: el, ltype: b, isExplicitCast: false)
                    let tempElementValue = temporaryStack.pop()
                    assert(b.sizeof <= 2)
                    instructions += [
                        .copyWordsIndirectDestination(lvalue.address, tempElementValue.address, b.sizeof)
                    ]
                    tempElementValue.consume()

                    // Increment the lvalue so we can do the next element.
                    if i != literalArray.elements.count-1 {
                        instructions += [.tac_add16(lvalue.address, lvalue.address, tempElementSize.address)]
                    }
                }
                
                tempElementSize.consume()
            default:
                instructions += try compileGenericAssignment(assignment, lvalue)
            }
        default:
            instructions += try compileGenericAssignment(assignment, lvalue)
        }
        
        lvalue.consume()
        
        return instructions
    }
    
    private func compileGenericAssignment(_ assignment: Expression.Assignment, _ lvalue: CompilerTemporary) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let ltype = try LvalueExpressionTypeChecker(symbols: symbols).check(expression: assignment.lexpr)
        
        // Calculate the rvalue, the value that is being assigned.
        // To handle automatic conversion and promotion, the value of this
        // expression is converted now to the type of the destination variable.
        let rvalue_proc = try compileAndConvertExpressionForAssignment(rexpr: assignment.rexpr, ltype: ltype)
        instructions += rvalue_proc
        let rvalue = temporaryStack.pop()
        
        // Emit code to copy the rvalue to the address given by the lvalue.
        // The expression result is assumed to be small enough to fit into
        // a temporary allocated from the scratch memory region.
        // If it doesn't fit then an error would have been raised before
        // this point.
        instructions += [.copyWordsIndirectDestination(lvalue.address, rvalue.address, ltype.sizeof)]
        
        rvalue.consume()
        
        return instructions
    }
    
    private func compileAndConvertExpressionForAssignment(rexpr: Expression, ltype: SymbolType) throws -> [CrackleInstruction] {
        return try rvalueContext().compileAndConvertExpression(rexpr: rexpr, ltype: ltype, isExplicitCast: false)
    }
    
    public func compileAndConvertExpressionForExplicitCast(rexpr: Expression, ltype: SymbolType) throws -> [CrackleInstruction] {
        return try compileAndConvertExpression(rexpr: rexpr, ltype: ltype, isExplicitCast: true)
    }
    
    private func compileAndConvertExpression(rexpr: Expression, ltype: SymbolType, isExplicitCast: Bool) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        let rtype = try typeChecker.check(expression: rexpr)
        switch (rtype, ltype) {
        case (.bool, .bool), (.u8, .u8), (.u16, .u16):
            instructions += try compile(expression: rexpr)
        case (.constInt(let a), .u8):
            assert(a >= 0 && a < 256)
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            instructions += [.storeImmediate(dst.address, a)]
        case (.constInt(let a), .u16):
            assert(a >= 0 && a < 65536)
            let dst = temporaryAllocator.allocate()
            instructions += [.storeImmediate16(dst.address, a)]
            temporaryStack.push(dst)
        case (.constBool(let a), .bool):
            let dst = temporaryAllocator.allocate()
            instructions += [.storeImmediate(dst.address, a ? 1 : 0)]
            temporaryStack.push(dst)
        case (.u8, .u16):
            instructions += try compile(expression: rexpr)
            let dst = temporaryAllocator.allocate()
            let src = temporaryStack.pop()
            instructions += [.copyWordZeroExtend(dst.address, src.address)]
            temporaryStack.push(dst)
            src.consume()
        case (.u16, .u8):
            assert(isExplicitCast)
            instructions += try compile(expression: rexpr)
            let dst = temporaryAllocator.allocate()
            let src = temporaryStack.pop()
            instructions += [.copyWords(dst.address, src.address, 1)]
            temporaryStack.push(dst)
            src.consume()
        case (.array(let n, let a), .array(let m, let b)):
            assert(n == m || m == nil)
            let n = n!
            switch rexpr {
            case let literalArray as Expression.LiteralArray:
                let dst = temporaryAllocator.allocate(size: n * b.sizeof)
                for i in 0..<literalArray.elements.count {
                    let el = literalArray.elements[i]
                    instructions += try compileAndConvertExpression(rexpr: el, ltype: b, isExplicitCast: isExplicitCast)
                    let src = temporaryStack.pop()
                    instructions += [.copyWords(dst.address + i * b.sizeof, src.address, b.sizeof)]
                    src.consume()
                }
                temporaryStack.push(dst)
            case let identifier as Expression.Identifier:
                let elements = stride(from: 0, through: n-1, by: 1).map({i in
                    Expression.As(sourceAnchor: identifier.sourceAnchor,
                                  expr: Expression.Subscript(sourceAnchor: identifier.sourceAnchor,
                                                             identifier: identifier,
                                                             expr: Expression.LiteralInt(sourceAnchor: identifier.sourceAnchor, value: i)),
                                  targetType: b)
                })
                let synthesized = Expression.LiteralArray(sourceAnchor: identifier.sourceAnchor,
                                                          explicitType: b,
                                                          explicitCount: elements.count,
                                                          elements: elements)
                instructions += try compile(expression: synthesized)
            default:
                assert(a == b)
                instructions += try compile(expression: rexpr)
            }
        case (.array(let n, let a), .dynamicArray(elementType: let b)):
            assert(n != nil)
            let n = n!
            assert(a == b)
            switch rexpr {
            case let identifier as Expression.Identifier:
                // Create a new temporary for the array slice which represents
                // the dynamic array. Populate it with information relating to
                // the underlying fixed-size array.
                let resolution = try symbols.resolveWithStackFrameDepth(sourceAnchor: identifier.sourceAnchor, identifier: identifier.identifier)
                let symbol = resolution.0
                let depth = symbols.stackFrameIndex - resolution.1
                
                let tempArraySlice = temporaryAllocator.allocate(size: kSliceSize)
                
                instructions += computeAddressOfSymbol(symbol, depth)
                let tempBaseAddress = temporaryStack.pop()
                
                instructions += [.copyWords(tempArraySlice.address + kSliceBaseAddressOffset, tempBaseAddress.address, 2)]
                tempBaseAddress.consume()
                
                instructions += [.storeImmediate16(tempArraySlice.address + kSliceCountOffset, n)]
                
                temporaryStack.push(tempArraySlice)
            default:
                // Allocate a temporary value on the stack for the source array.
                // Copy the value of the right expression into that temporary.
                let rhsSize = n * b.sizeof
                instructions += try compile(expression: rexpr)
                let tempRightExpr = temporaryStack.pop()
                
                let tempRhsSize = temporaryAllocator.allocate()
                instructions += [
                    // stackPointer -= rhsSize
                    .storeImmediate16(tempRhsSize.address, rhsSize),
                    .tac_sub16(kStackPointerAddress, kStackPointerAddress, tempRhsSize.address),
                ]
                tempRhsSize.consume()
                
                instructions += [
                    // Copy the rhs result to the stack.
                    .copyWordsIndirectDestination(kStackPointerAddress, tempRightExpr.address, rhsSize)
                ]
                tempRightExpr.consume()
                
                // Then, bind the dynamic array to that temporary.
                let tempArraySlice = temporaryAllocator.allocate(size: kSliceSize)
                instructions += [
                    .copyWords(tempArraySlice.address + kSliceBaseAddressOffset, kStackPointerAddress, 2),
                    .storeImmediate16(tempArraySlice.address + kSliceCountOffset, rhsSize)
                ]
                temporaryStack.push(tempArraySlice)
            }
        case (.dynamicArray(elementType: let a), .dynamicArray(elementType: let b)):
            assert(a == b)
            instructions += try compile(expression: rexpr)
        default:
            assert(false) // unreachable
        }
        return instructions
    }
    
    private func compile(call node: Expression.Call) throws -> [CrackleInstruction] {
        let identifier = (node.callee as! Expression.Identifier).identifier
        let symbol = try symbols.resolve(sourceAnchor: node.sourceAnchor, identifier: identifier)
        switch symbol.type {
        case .function(name: _, mangledName: let mangledName, functionType: let typ):
            var instructions: [CrackleInstruction] = []
            switch mangledName {
            case "peekMemory":      instructions += try compileFunctionPeekMemory(typ, node)
            case "pokeMemory":      instructions += try compileFunctionPokeMemory(typ, node)
            case "peekPeripheral":  instructions += try compileFunctionPeekPeripheral(typ, node)
            case "pokePeripheral":  instructions += try compileFunctionPokePeripheral(typ, node)
            case "hlt":             instructions += [.hlt]
            default:                instructions += try compileFunctionUserDefined(typ, node, mangledName)
            }
            return instructions
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            let message = "cannot call value of non-function type `\(String(describing: symbol.type))'"
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: message)
        }
    }
    
    private func compileFunctionPeekMemory(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        instructions += try pushFunctionArgumentsToCompilerTemporariesStack(typ, node)
        let tempArgumentValue = temporaryStack.pop()
        let tempReturnValue = temporaryAllocator.allocate(size: typ.returnType.sizeof)
        instructions += [
            .copyWordsIndirectSource(tempReturnValue.address, tempArgumentValue.address, typ.returnType.sizeof)
        ]
        tempArgumentValue.consume()
        temporaryStack.push(tempReturnValue)
        return instructions
    }
    
    private func compileFunctionPokeMemory(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        instructions += try pushFunctionArgumentsToCompilerTemporariesStack(typ, node)
        let tempAddressArg = temporaryStack.pop()
        let tempValueArg = temporaryStack.pop()
        instructions += [
            .copyWordsIndirectDestination(tempAddressArg.address, tempValueArg.address, 1)
        ]
        tempValueArg.consume()
        tempAddressArg.consume()
        return instructions
    }
    
    private func compileFunctionPeekPeripheral(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        instructions += try pushFunctionArguments(typ, node)
        instructions += [.peekPeripheral]
        instructions += moveFunctionReturnValueFromStackToTemporary(typ)
        return instructions
    }
    
    private func compileFunctionPokePeripheral(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        instructions += try pushFunctionArguments(typ, node)
        instructions += [
            .pokePeripheral,
            .pop
        ]
        instructions += moveFunctionReturnValueFromStackToTemporary(typ)
        return instructions
    }
    
    private func pushFunctionArgumentsToCompilerTemporariesStack(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        // Push function arguments to the compiler temporaries stack
        // with appropriate type conversions.
        var instructions: [CrackleInstruction] = []
        for i in 0..<typ.arguments.count {
            instructions += try compileAndConvertExpressionForAssignment(rexpr: node.arguments[i], ltype: typ.arguments[i].argumentType)
        }
        return instructions
    }
    
    private func compileFunctionUserDefined(_ typ: FunctionType, _ node: Expression.Call, _ mangledName: String) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        var tempReturnValue: CompilerTemporary!
        
        // Save all live temporaries to preserve their values across the call.
        // We cannot know which temporaries will be invalidated by code in
        // the function body.
        let temporariesToPreserve = temporaryAllocator.liveTemporaries
        for temporary in temporariesToPreserve {
            instructions += pushTemporary(temporary)
        }
        
        if typ.returnType.sizeof > 0 {
            tempReturnValue = temporaryAllocator.allocate(size: typ.returnType.sizeof)
        }
        
        instructions += try pushToAllocateFunctionReturnValue(typ)
        instructions += try pushFunctionArguments(typ, node)
        instructions += [.jalr(mangledName)]
        instructions += popFunctionArguments(typ)
                
        // If there is a return value then it can be found at the top of the
        // stack. Copy it to the temporary we allocated for it, above.
        if typ.returnType.sizeof > 0 {
            instructions += [
                .copyWordsIndirectSource(tempReturnValue.address, kStackPointerAddress, typ.returnType.sizeof)
            ]
            switch typ.returnType.sizeof {
            case 1:  instructions += [.pop]
            case 2:  instructions += [.pop16]
            default: instructions += [.popn(typ.returnType.sizeof)]
            }
            temporaryStack.push(tempReturnValue)
        }
        
        // Restore live temporaries after the function call returns.
        for temporary in temporariesToPreserve.reversed() {
            instructions += popTemporary(temporary)
        }
        
        return instructions
    }
    
    private func pushTemporary(_ temporary: CompilerTemporary) -> [CrackleInstruction] {
        return pushTemporary(temporary: temporary, explicitSize: temporary.size)
    }
    
    private func pushTemporary(temporary: CompilerTemporary, explicitSize: Int) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        switch explicitSize {
        case 1:  instructions += [.load(temporary.address)]
        case 2:  instructions += [.load16(temporary.address)]
        default:
            // TODO: a dedicated LOADN instruction would help here, removing the need for a PUSH16.
            instructions += [
                .push16(temporary.address),
                .loadIndirectN(explicitSize)
            ]
        }
        return instructions
    }
    
    private func popTemporary(_ temporary: CompilerTemporary) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        switch temporary.size {
        case 1:  instructions += [.store(temporary.address), .pop]
        case 2:  instructions += [.store16(temporary.address), .pop16]
        default: abort() // unimplemented
        }
        return instructions
    }
    
    private func pushToAllocateFunctionReturnValue(_ typ: FunctionType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Allocate space for the return value, if any. When we pop arguments
        // off the stack, we leave the return value in place.
        // TODO: add a pushn instruction so we can do something like pushn(typ.returnType.sizeof)
        instructions += [CrackleInstruction].init(repeating: .push(0), count: typ.returnType.sizeof)
        
        return instructions
    }
    
    private func pushFunctionArguments(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Push function arguments to the stack with appropriate type conversions.
        for i in 0..<typ.arguments.count {
            let type = typ.arguments[i].argumentType
            instructions += try compileAndConvertExpressionForAssignment(rexpr: node.arguments[i], ltype: type)
            let tempArgumentValue = temporaryStack.pop()
            instructions += pushTemporary(temporary: tempArgumentValue, explicitSize: type.sizeof)
            tempArgumentValue.consume()
        }
        
        return instructions
    }
    
    private func popFunctionArguments(_ typ: FunctionType) -> [CrackleInstruction] {
        var totalSize = 0
        for arg in typ.arguments {
            totalSize += arg.argumentType.sizeof
        }
        if totalSize > 0 {
            return [.popn(totalSize)]
        } else {
            return []
        }
    }
    
    // The function put the return value on the stack. Move that value
    // to a compiler temporary in the scratch memory region.
    private func moveFunctionReturnValueFromStackToTemporary(_ typ: FunctionType) -> [CrackleInstruction] {
        guard typ.returnType.sizeof > 0 else {
            return []
        }
        let size = typ.returnType.sizeof
        let tempReturnValue = temporaryAllocator.allocate(size: size)
        let instructions: [CrackleInstruction] = [
            .copyWordsIndirectSource(tempReturnValue.address, kStackPointerAddress, size),
            .popn(size)
        ]
        temporaryStack.push(tempReturnValue)
        return instructions
    }
    
    private func compile(as expr: Expression.As) throws -> [CrackleInstruction] {
        let instructions = try compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: expr.targetType)
        return instructions
    }
    
    private func compile(literalArray expr: Expression.LiteralArray) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        let resultType = try typeChecker.check(expression: expr)
        let tempResult = temporaryAllocator.allocate(size: resultType.sizeof)
        var offset = 0
        for el in expr.elements {
            instructions += try compile(expression: el)
            let tempElement = temporaryStack.pop()
            instructions += [.copyWords(tempResult.address + offset, tempElement.address, expr.explicitType.sizeof)]
            tempElement.consume()
            offset += expr.explicitType.sizeof
        }
        temporaryStack.push(tempResult)
        return instructions
    }
    
    // Compile an array element lookup through the subscript operator.
    public override func arraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        instructions += try arraySubscriptLvalue(symbol, depth, expr, elementType)
        instructions += try loadFromLvalueIntoTemporary(elementType)
        return instructions
    }
    
    // Assuming the top of the temporaries stack holds an lvalue, load the
    // value in memory at that address into a new temporary.
    // Leave that temporary on top of the temporaries stack too.
    private func loadFromLvalueIntoTemporary(_ elementType: SymbolType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        let tempLvalue = temporaryStack.pop()
        let tempResult = temporaryAllocator.allocate()
        instructions += [.copyWordsIndirectSource(tempResult.address, tempLvalue.address, elementType.sizeof)]
        temporaryStack.push(tempResult)
        tempLvalue.consume()
        return instructions
    }
    
    // Compile an array element lookup in a dynamic array through the subscript operator.
    public override func dynamicArraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        instructions += try dynamicArraySubscriptLvalue(symbol, depth, expr, elementType)
        instructions += try loadFromLvalueIntoTemporary(elementType)
        return instructions
    }
    
    public func compile(get expr: Expression.Get) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let tempCount = temporaryAllocator.allocate()
        
        instructions += try compile(expression: expr.expr)
        let tempExprResult = temporaryStack.pop()
        
        let member = expr.member.identifier
        let resultType = try typeChecker.check(expression: expr.expr)
        
        assert(member == "count") // other members are unimplemented right now
        
        switch resultType {
        case .array(count: let count, elementType: _):
            instructions += [.storeImmediate16(tempCount.address, count!)]
        case .dynamicArray:
            instructions += [.copyWords(tempCount.address, tempExprResult.address + kSliceCountOffset, kSliceCountSize)]
        default:
            assert(false) // unreachable
        }
        
        tempExprResult.consume()
        temporaryStack.push(tempCount)
        
        return instructions
    }
}
