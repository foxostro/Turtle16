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
    let compilerInstrinsicFunctions: [String: [CrackleInstruction]] = [
        "peekMemory" : [.loadIndirect],
        "pokeMemory" : [.storeIndirect, .pop],
        "peekPeripheral" : [.peekPeripheral],
        "pokePeripheral" : [.pokePeripheral, .pop],
        "hlt" : [.hlt]
    ]
    public let typeChecker: RvalueExpressionTypeChecker
    
    private let kSliceBaseAddressOffset = 0
    private let kSliceCountOffset = 2
    private let kSliceSize = 4
    
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
            throw invalidUnaryOperator(unary)
        }
        
        a.consume()
        b.consume()
        
        return result
    }
    
    private func invalidUnaryOperator(_ unary: Expression.Unary) -> CompilerError {
        return CompilerError(sourceAnchor: unary.sourceAnchor, message: "`\(unary.op)' is not a prefix unary operator")
    }
    
    private func compile(binary: Expression.Binary) throws -> [CrackleInstruction] {
        let rightType = try typeChecker.check(expression: binary.right)
        let leftType = try typeChecker.check(expression: binary.left)
        
        let right: [CrackleInstruction]! = nil
        let left: [CrackleInstruction]! = nil
        
        switch (binary.op, leftType, rightType) {
        case (.eq, .u8, .u8),
             (.eq, .u8, .constInt),
             (.eq, .constInt, .u8):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_eq(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.eq, .u8, .u16),
             (.eq, .u16, .u8),
             (.eq, .u16, .u16),
             (.eq, .u16, .constInt),
             (.eq, .constInt, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_eq16(c.address, a.address, b.address)]
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
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .bool)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .bool)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_eq(c.address, a.address, b.address)]
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
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_ne(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ne, .u8, .u16),
             (.ne, .u16, .u8),
             (.ne, .u16, .u16),
             (.ne, .u16, .constInt),
             (.ne, .constInt, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_ne16(c.address, a.address, b.address)]
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
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .bool)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .bool)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_ne(c.address, a.address, b.address)]
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
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_lt(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.lt, .u8, .u16),
             (.lt, .u16, .u8),
             (.lt, .u16, .u16),
             (.lt, .u16, .constInt),
             (.lt, .constInt, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_lt16(c.address, a.address, b.address)]
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
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_gt(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.gt, .u8, .u16),
             (.gt, .u16, .u8),
             (.gt, .u16, .u16),
             (.gt, .u16, .constInt),
             (.gt, .constInt, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_gt16(c.address, a.address, b.address)]
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
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_le(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.le, .u8, .u16),
             (.le, .u16, .u8),
             (.le, .u16, .u16),
             (.le, .u16, .constInt),
             (.le, .constInt, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_le16(c.address, a.address, b.address)]
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
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_ge(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ge, .u8, .u16),
             (.ge, .u16, .u8),
             (.ge, .u16, .u16),
             (.ge, .u16, .constInt),
             (.ge, .constInt, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_ge16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.ge, .constInt(let a), .constInt(let b)):
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            return [.storeImmediate(dst.address, (a >= b) ? 1 : 0)]
        case (.plus, .u8, .u8):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_add(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.plus, .u8, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push(a)] + left + [.add]
        case (.plus, .u8, .u16),
             (.plus, .u16, .u8),
             (.plus, .u16, .u16),
             (.plus, .u16, .constInt):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_add16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.plus, .constInt(let a), .u8):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push(a)] + [.add]
        case (.plus, .constInt(let a), .u16):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push16(a)] + [.add16]
        case (.plus, .constInt(let a), .constInt(let b)):
            let value = a + b
            if value > 255 {
                let dst = temporaryAllocator.allocate()
                temporaryStack.push(dst)
                return [.storeImmediate16(dst.address, value)]
            } else {
                let dst = temporaryAllocator.allocate()
                temporaryStack.push(dst)
                return [.storeImmediate(dst.address, value)]
            }
        case (.minus, .u8, .u8):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_sub(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.minus, .u8, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push(a)] + left + [.sub]
        case (.minus, .u8, .u16),
             (.minus, .u16, .u8),
             (.minus, .u16, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_sub16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.minus, .u16, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push16(a)] + left + [.sub16]
        case (.minus, .constInt(let a), .u8):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push(a)] + [.sub]
        case (.minus, .constInt(let a), .u16):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push16(a)] + [.sub16]
        case (.minus, .constInt(let a), .constInt(let b)):
            // TODO: need to convert this case to TAC instructions too
            if a - b > 255 {
                return [.push16(a - b)]
            } else {
                return [.push(a - b)]
            }
        case (.multiply, .u8, .u8):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_mul(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.multiply, .u8, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push(a)] + left + [.mul]
        case (.multiply, .u8, .u16),
             (.multiply, .u16, .u8),
             (.multiply, .u16, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_mul16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.multiply, .u16, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push16(a)] + left + [.mul16]
        case (.multiply, .constInt(let a), .u8):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push(a)] + [.mul16]
        case (.multiply, .constInt(let a), .u16):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push16(a)] + [.mul16]
        case (.multiply, .constInt(let a), .constInt(let b)):
            // TODO: need to convert this case to TAC instructions too
            if a * b > 255 {
                return [.push16(a * b)]
            } else {
                return [.push(a * b)]
            }
        case (.divide, .u8, .u8):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_div(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.divide, .u8, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push(a)] + left + [.div]
        case (.divide, .u8, .u16),
             (.divide, .u16, .u8),
             (.divide, .u16, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_div16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.divide, .u16, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push16(a)] + left + [.div16]
        case (.divide, .constInt(let a), .u8):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push(a)] + [.div16]
        case (.divide, .constInt(let a), .u16):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push16(a)] + [.div16]
        case (.divide, .constInt(let a), .constInt(let b)):
            // TODO: need to convert this case to TAC instructions too
            if a / b > 255 {
                return [.push16(a / b)]
            } else {
                return [.push(a / b)]
            }
        case (.modulus, .u8, .u8):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u8)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u8)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_mod(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.modulus, .u8, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push(a)] + left + [.mod]
        case (.modulus, .u8, .u16),
             (.modulus, .u16, .u8),
             (.modulus, .u16, .u16):
            let right2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .u16)
            let left2: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .u16)
            let c = temporaryAllocator.allocate()
            let a = temporaryStack.pop()
            let b = temporaryStack.pop()
            let instructions = right2 + left2 + [.tac_mod16(c.address, a.address, b.address)]
            temporaryStack.push(c)
            a.consume()
            b.consume()
            return instructions
        case (.modulus, .u16, .constInt(let a)):
            // TODO: need to convert this case to TAC instructions too
            return [.push16(a)] + left + [.mod16]
        case (.modulus, .constInt(let a), .u8):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push(a)] + [.mod16]
        case (.modulus, .constInt(let a), .u16):
            // TODO: need to convert this case to TAC instructions too
            return right + [.push16(a)] + [.mod16]
        case (.modulus, .constInt(let a), .constInt(let b)):
            // TODO: need to convert this case to TAC instructions too
            if a % b > 255 {
                return [.push16(a % b)]
            } else {
                return [.push(a % b)]
            }
        default:
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
            guard n == m || m == nil else {
                abort()
            }
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
                abort() // unimplemented
            }
        default:
            // Calculate the rvalue, the value that is being assigned.
            // To handle automatic conversion and promotion, this value of this
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
        }
        
        lvalue.consume()
        
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
            guard a >= 0 && a < 256 else {
                throw CompilerError(sourceAnchor: rexpr.sourceAnchor, message: "integer constant `\(a)' overflows when stored into `u8'")
            }
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            instructions += [.storeImmediate(dst.address, a)]
        case (.constInt(let a), .u16):
            guard a >= 0 && a < 65536 else {
                throw CompilerError(sourceAnchor: rexpr.sourceAnchor, message: "integer constant `\(a)' overflows when stored into `u16'")
            }
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
            guard isExplicitCast else {
                abort()
            }
            instructions += try compile(expression: rexpr)
            let dst = temporaryAllocator.allocate()
            let src = temporaryStack.pop()
            instructions += [.copyWords(dst.address, src.address, 1)]
            temporaryStack.push(dst)
            src.consume()
        case (.array(let n, let a), .array(let m, let b)):
            guard n == m || m == nil else {
                abort()
            }
            switch rexpr {
            case let literalArray as Expression.LiteralArray:
                for el in literalArray.elements.reversed() {
                    instructions += try compileAndConvertExpression(rexpr: el, ltype: b, isExplicitCast: isExplicitCast)
                }
            case let identifier as Expression.Identifier:
                let elements = stride(from: 0, through: n!-1, by: 1).map({i in
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
                guard a == b else {
                    abort()
                }
                instructions += try compile(expression: rexpr)
            }
        case (.array(let n, let a), .dynamicArray(elementType: let b)):
            guard let n = n else {
                abort()
            }
            guard a == b else {
                abort()
            }
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
                // The dynamic array must bind to a temporary value on the stack.
                // TODO: The way this is written now, the stack will continue to grow and will eventually overflow. We need something like a way to signal that additional bytes must be popped at the end of the statement.
                instructions += try compile(expression: rexpr)
                instructions += [
                    .push16(n),
                    .push16(4),
                    .pushsp,
                    .add16
                ]
            }
        case (.dynamicArray(elementType: let a), .dynamicArray(elementType: let b)):
            guard a == b else {
                abort()
            }
            instructions += try compile(expression: rexpr)
        default:
            abort()
        }
        return instructions
    }
    
    private func compile(call node: Expression.Call) throws -> [CrackleInstruction] {
        let identifier = (node.callee as! Expression.Identifier).identifier
        let symbol = try symbols.resolve(sourceAnchor: node.sourceAnchor, identifier: identifier)
        switch symbol.type {
        case .function(name: _, mangledName: let mangledName, functionType: let typ):
            var instructions: [CrackleInstruction] = []
            if let ins = compilerInstrinsicFunctions[mangledName] {
                instructions += try pushFunctionArguments(typ, node)
                instructions += ins
            } else {
                instructions += try pushToAllocateFunctionReturnValue(typ)
                instructions += try pushFunctionArguments(typ, node)
                instructions += [.jalr(mangledName)]
                instructions += popFunctionArguments(typ)
            }
            return instructions
        default:
            let message = "cannot call value of non-function type `\(String(describing: symbol.type))'"
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: message)
        }
    }
    
    private func pushToAllocateFunctionReturnValue(_ typ: FunctionType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Allocate space for the return value, if any. When we pop arguments
        // off the stack, we leave the return value in place.
        instructions += [CrackleInstruction].init(repeating: .push(0), count: typ.returnType.sizeof)
        
        return instructions
    }
    
    private func pushFunctionArguments(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Push function arguments to the stack with appropriate type conversions.
        for i in 0..<typ.arguments.count {
            instructions += try compileAndConvertExpressionForAssignment(rexpr: node.arguments[i],
                                                                         ltype: typ.arguments[i].argumentType)
        }
        
        return instructions
    }
    
    private func popFunctionArguments(_ typ: FunctionType) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        for arg in typ.arguments.reversed() {
            let size = arg.argumentType.sizeof
            switch size {
            case 0:  break
            case 1:  instructions += [.pop]
            case 2:  instructions += [.pop16]
            default: instructions += [.popn(size)]
            }
        }
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
        switch resultType {
        case .array(count: let count, elementType: _):
            if member == "count" {
                instructions += [.storeImmediate16(tempCount.address, count!)]
            }
        case .dynamicArray:
            if member == "count" {
                instructions += [.copyWords(tempCount.address, tempExprResult.address + kSliceCountOffset, 2)]
            }
        default:
            abort()
        }
        
        tempExprResult.consume()
        temporaryStack.push(tempCount)
        
        return instructions
    }
}
