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
    
    public static func bindCompilerIntrinsicFunctions(symbols: SymbolTable) -> SymbolTable {
        return bindCompilerInstrinsicHlt(symbols:
            bindCompilerInstrinsicPokePeripheral(symbols:
                bindCompilerInstrinsicPeekPeripheral(symbols:
                    bindCompilerInstrinsicPokeMemory(symbols:
                        bindCompilerInstrinsicPeekMemory(symbols: symbols)))))
    }
    
    private static func bindCompilerInstrinsicPeekMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "peekMemory"
        let typ: SymbolType = .function(FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "address", type: .u16)]))
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPokeMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "pokeMemory"
        let typ: SymbolType = .function(FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "value", type: .u8), FunctionType.Argument(name: "address", type: .u16)]))
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPeekPeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "peekPeripheral"
        let typ: SymbolType = .function(FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "address", type: .u16), FunctionType.Argument(name: "device", type: .u8)]))
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPokePeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "pokePeripheral"
        let typ: SymbolType = .function(FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "value", type: .u8), FunctionType.Argument(name: "address", type: .u16), FunctionType.Argument(name: "device", type: .u8)]))
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicHlt(symbols: SymbolTable) -> SymbolTable{
        let name = "hlt"
        let typ: SymbolType = .function(FunctionType(returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    public override init(symbols: SymbolTable = SymbolTable(),
                         labelMaker: LabelMaker = LabelMaker(),
                         mapMangledFunctionName: MangledFunctionNameMap = MangledFunctionNameMap(),
                         temporaryStack: CompilerTemporariesStack = CompilerTemporariesStack(),
                         temporaryAllocator: CompilerTemporariesAllocator = CompilerTemporariesAllocator()) {
        self.typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        super.init(symbols: symbols,
                   labelMaker: labelMaker,
                   mapMangledFunctionName: mapMangledFunctionName,
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
        case let expr as Expression.StructInitializer:
            return try compile(structInitializer: expr)
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
        
        var instructions: [CrackleInstruction] = []
        
        if unary.op == .ampersand {
            let context = lvalueContext()
            context.shouldIgnoreMutabilityRules = true // We want to take the address, not modify anything.
            instructions += try context.compile(expression: unary.child)
        } else {
            let a = temporaryAllocator.allocate()
            let c = temporaryAllocator.allocate()
            let b = temporaryStack.pop()
            temporaryStack.push(c)
            
            switch (childType, unary.op) {
            case (.u16, .minus):
                instructions += childExpr
                instructions += [.storeImmediate16(a.address, 0)]
                instructions += [.sub16(c.address, a.address, b.address)]
            case (.u8, .minus):
                instructions += childExpr
                instructions += [.storeImmediate(a.address, 0)]
                instructions += [.sub(c.address, a.address, b.address)]
            default:
                // This is basically unreachable since the type checker will
                // typically throw an error about an invalid unary operator before
                // we get to this point.
                assert(false)
                throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "`\(unary.op)' is not a prefix unary operator")
            }
            
            a.consume()
            b.consume()
        }
        
        return instructions
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
            let instructions = right + left + [.eq(c.address, a.address, b.address)]
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
            let instructions = right + left + [.eq16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.eq(c.address, a.address, b.address)]
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
            let instructions = right + left + [.ne(c.address, a.address, b.address)]
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
            let instructions = right + left + [.ne16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.ne(c.address, a.address, b.address)]
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
            let instructions = right + left + [.lt(c.address, a.address, b.address)]
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
            let instructions = right + left + [.lt16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.gt(c.address, a.address, b.address)]
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
            let instructions = right + left + [.gt16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.le(c.address, a.address, b.address)]
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
            let instructions = right + left + [.le16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.ge(c.address, a.address, b.address)]
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
            let instructions = right + left + [.ge16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.add(c.address, a.address, b.address)]
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
            let instructions = right + left + [.add16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.sub(c.address, a.address, b.address)]
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
            let instructions = right + left + [.sub16(c.address, a.address, b.address)]
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
        case (.star, .u8, .u8),
             (.star, .u8, .constInt),
             (.star, .constInt, .u8):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.mul(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.star, .u8, .u16),
             (.star, .u16, .u8),
             (.star, .u16, .u16),
             (.star, .u16, .constInt),
             (.star, .constInt, .u16):
            let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right + left + [.mul16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.star, .constInt(let a), .constInt(let b)):
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
            let instructions = right + left + [.div(c.address, a.address, b.address)]
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
            let instructions = right + left + [.div16(c.address, a.address, b.address)]
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
            let instructions = right + left + [.mod(c.address, a.address, b.address)]
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
            let instructions = right + left + [.mod16(c.address, a.address, b.address)]
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
        ctx.shouldIgnoreMutabilityRules = assignment is Expression.InitialAssignment
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
                        instructions += [.add16(lvalue.address, lvalue.address, tempElementSize.address)]
                    }
                }
                
                tempElementSize.consume()
            default:
                instructions += try compileGenericAssignment(assignment, lvalue)
            }

        case (.structType(let a), .structType(let typ)):
            assert(a == typ)
            switch assignment.rexpr {
            case let initializer as Expression.StructInitializer:
                // For each member, evaluate the expression and copy the result
                // into the struct at the designated offset.
                for i in 0..<initializer.arguments.count {
                    let arg = initializer.arguments[i]
                    let member = try! typ.symbols.resolve(identifier: arg.name)
                    instructions += try compileAndConvertExpression(rexpr: arg.expr, ltype: member.type, isExplicitCast: false)
                    let tempArg = temporaryStack.pop()
                    let memberLvalue = temporaryAllocator.allocate(size: member.type.sizeof)
                    instructions += [
                        .addi16(memberLvalue.address, lvalue.address, member.offset)
                    ]
                    instructions += [
                        .copyWordsIndirectDestination(memberLvalue.address, tempArg.address, member.type.sizeof)
                    ]
                    memberLvalue.consume()
                    tempArg.consume()
                }
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
        case (.bool, .bool),
             (.u8, .u8),
             (.u16, .u16),
             (.structType, .structType):
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
            instructions += [.copyWords(dst.address, src.address+1, 1)]
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
                                  targetType: Expression.PrimitiveType(b))
                })
                let arrayType = Expression.ArrayType(count: Expression.LiteralInt(elements.count),
                                                     elementType: Expression.PrimitiveType(b))
                let synthesized = Expression.LiteralArray(sourceAnchor: identifier.sourceAnchor,
                                                          arrayType: arrayType,
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
                
                instructions += [
                    // stackPointer -= rhsSize
                    .subi16(kStackPointerAddress, kStackPointerAddress, rhsSize),
                ]
                
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
        case (.pointer(let a), .pointer(let b)):
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
        case .function(let typ):
            var instructions: [CrackleInstruction] = []
            switch identifier {
            case "peekMemory":      instructions += try compileFunctionPeekMemory(typ, node)
            case "pokeMemory":      instructions += try compileFunctionPokeMemory(typ, node)
            case "peekPeripheral":  instructions += try compileFunctionPeekPeripheral(typ, node)
            case "pokePeripheral":  instructions += try compileFunctionPokePeripheral(typ, node)
            case "hlt":             instructions += [.hlt]
            default:                instructions += try compileFunctionUserDefined(typ, node)
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
    
    private func compileFunctionUserDefined(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        let identifier = (node.callee as! Expression.Identifier).identifier
        let symbol = try symbols.resolve(sourceAnchor: node.sourceAnchor, identifier: identifier)
        let mangledName = mapMangledFunctionName.lookup(uid: symbol.offset)
        
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
                .copyWordsIndirectSource(tempReturnValue.address, kStackPointerAddress, typ.returnType.sizeof),
                .addi16(kStackPointerAddress, kStackPointerAddress, typ.returnType.sizeof)
            ]
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
        let instructions: [CrackleInstruction] = [
            .subi16(kStackPointerAddress, kStackPointerAddress, explicitSize),
            .copyWordsIndirectDestination(kStackPointerAddress, temporary.address, explicitSize)
        ]
        return instructions
    }
    
    private func popTemporary(_ temporary: CompilerTemporary) -> [CrackleInstruction] {
        let instructions: [CrackleInstruction] = [
            .copyWordsIndirectSource(temporary.address, kStackPointerAddress, temporary.size),
            .addi16(kStackPointerAddress, kStackPointerAddress, temporary.size)
        ]
        return instructions
    }
    
    private func pushToAllocateFunctionReturnValue(_ typ: FunctionType) throws -> [CrackleInstruction] {
        return [.subi16(kStackPointerAddress, kStackPointerAddress, typ.returnType.sizeof)]
    }
    
    private func pushFunctionArguments(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Push function arguments to the stack with appropriate type conversions.
        for i in 0..<typ.arguments.count {
            let arg = typ.arguments[i]
            let type = arg.argumentType
            let argExpr = node.arguments[i]
            
            // Do not permit a mutating pointer to be constructed from an immutable object.
            if arg.isMutable {
                if let unary = argExpr as? Expression.Unary {
                    if let identifier = unary.child as? Expression.Identifier {
                        let symbol = try symbols.resolve(identifier: identifier.identifier)
                        if !symbol.isMutable {
                            throw CompilerError(sourceAnchor: identifier.sourceAnchor,
                                                message: "cannot make a mutating pointer from immutable object `\(identifier.identifier)'")
                        }
                    }
                }
            }
            
            instructions += try compileAndConvertExpressionForAssignment(rexpr: argExpr, ltype: type)
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
            return [.addi16(kStackPointerAddress, kStackPointerAddress, totalSize)]
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
            .addi16(kStackPointerAddress, kStackPointerAddress, size)
        ]
        temporaryStack.push(tempReturnValue)
        return instructions
    }
    
    private func compile(as expr: Expression.As) throws -> [CrackleInstruction] {
        let targetType = try typeChecker.check(expression: expr.targetType)
        let instructions = try compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: targetType)
        return instructions
    }
    
    private func compile(literalArray expr: Expression.LiteralArray) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        let resultType = try typeChecker.check(expression: expr)
        let arrayElementType = resultType.arrayElementType
        let tempResult = temporaryAllocator.allocate(size: resultType.sizeof)
        var offset = 0
        for el in expr.elements {
            instructions += try compile(expression: el)
            let tempElement = temporaryStack.pop()
            instructions += [.copyWords(tempResult.address + offset, tempElement.address, arrayElementType.sizeof)]
            tempElement.consume()
            offset += arrayElementType.sizeof
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
        
        instructions += try compile(expression: expr.expr)
        let tempExprResult = temporaryStack.pop()
        
        let name = expr.member.identifier
        let resultType = try typeChecker.check(expression: expr.expr)
        
        switch resultType {
        case .array(count: let count, elementType: _):
            assert(name == "count")
            let tempCount = temporaryAllocator.allocate()
            instructions += [.storeImmediate16(tempCount.address, count!)]
            tempExprResult.consume()
            temporaryStack.push(tempCount)
        case .dynamicArray:
            assert(name == "count")
            let tempCount = temporaryAllocator.allocate()
            instructions += [.copyWords(tempCount.address, tempExprResult.address + kSliceCountOffset, kSliceCountSize)]
            tempExprResult.consume()
            temporaryStack.push(tempCount)
        case .structType(let typ):
            // FIXME: This copies the struct value to a new temporary and then extracts the desired field. We should instead access the underlying symbol and read the field itself, only.
            let symbol = try typ.symbols.resolve(identifier: name)
            let size = symbol.type.sizeof
            let offset = symbol.offset
            let tempResult = temporaryAllocator.allocate(size: size)
            instructions += [.copyWords(tempResult.address, tempExprResult.address + offset, size)]
            tempExprResult.consume()
            temporaryStack.push(tempResult)
        case .pointer(let typ):
            if name == "pointee" {
                let tempPointee = temporaryAllocator.allocate()
                instructions += [.copyWordsIndirectSource(tempPointee.address, tempExprResult.address, typ.sizeof)]
                tempExprResult.consume()
                temporaryStack.push(tempPointee)
            } else {
                switch typ {
                case .structType(let b):
                    let symbol = try b.symbols.resolve(identifier: name)
                    let size = symbol.type.sizeof
                    let tempResult = temporaryAllocator.allocate(size: size)
                    instructions += [
                        .addi16(tempExprResult.address, tempExprResult.address, symbol.offset),
                        .copyWordsIndirectSource(tempResult.address, tempExprResult.address, size)
                    ]
                    tempExprResult.consume()
                    temporaryStack.push(tempResult)
                default:
                    assert(false) // unreachable
                }
            }
        default:
            assert(false) // unreachable
        }
        
        return instructions
    }
    
    public func compile(structInitializer expr: Expression.StructInitializer) throws -> [CrackleInstruction] {
        let resultType = try typeChecker.check(expression: expr)
        let typ = resultType.unwrapStructType()
        var instructions: [CrackleInstruction] = []
        let tempResult = temporaryAllocator.allocate(size: resultType.sizeof)
        for i in 0..<expr.arguments.count {
            let arg = expr.arguments[i]
            let member = try! typ.symbols.resolve(identifier: arg.name)
            instructions += try! compileAndConvertExpressionForExplicitCast(rexpr: arg.expr, ltype: member.type)
            let tempArg = temporaryStack.pop()
            instructions += [.copyWords(tempResult.address + member.offset, tempArg.address, member.type.sizeof)]
            tempArg.consume()
        }
        temporaryStack.push(tempResult)
        return instructions
    }
}
