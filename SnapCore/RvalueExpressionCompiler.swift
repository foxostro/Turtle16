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
    
    public static func bindCompilerIntrinsics(symbols: SymbolTable) -> SymbolTable {
        var result: SymbolTable
        result = bindCompilerInstrinsicPeekMemory(symbols: symbols)
        result = bindCompilerInstrinsicPokeMemory(symbols: result)
        result = bindCompilerInstrinsicPeekPeripheral(symbols: result)
        result = bindCompilerInstrinsicPokePeripheral(symbols: result)
        result = bindCompilerInstrinsicHlt(symbols: result)
        result = bindCompilerIntrinsicRangeType(symbols: result)
        return result
    }
    
    private static func bindCompilerIntrinsicRangeType(symbols: SymbolTable) -> SymbolTable {
        let name = "Range"
        let typ: SymbolType = .structType(StructType(name: name, symbols: SymbolTable([
            "begin" : Symbol(type: .u16, offset: 0),
            "limit" : Symbol(type: .u16, offset: 2)
        ])))
        symbols.bind(identifier: name, symbolType: typ, visibility: .privateVisibility)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPeekMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "peekMemory"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .u8, arguments: [.u16]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPokeMemory(symbols: SymbolTable) -> SymbolTable {
        let name = "pokeMemory"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: [.u8, .u16]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPeekPeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "peekPeripheral"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .u8, arguments: [.u16, .u8]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicPokePeripheral(symbols: SymbolTable) -> SymbolTable {
        let name = "pokePeripheral"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: [.u8, .u16, .u8]))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
        symbols.bind(identifier: name, symbol: symbol)
        return symbols
    }
    
    private static func bindCompilerInstrinsicHlt(symbols: SymbolTable) -> SymbolTable{
        let name = "hlt"
        let typ: SymbolType = .function(FunctionType(name: name, returnType: .void, arguments: []))
        let symbol = Symbol(type: typ, offset: 0x0000, storage: .staticStorage, visibility: .privateVisibility)
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
        case let expr as Expression.Is:
            return try compile(is: expr)
        case let expr as Expression.LiteralArray:
            return try compile(literalArray: expr)
        case let expr as Expression.Subscript:
            return try compile(subscript: expr)
        case let expr as Expression.Get:
            return try compile(get: expr)
        case let expr as Expression.StructInitializer:
            return try compile(structInitializer: expr)
        case let expr as Expression.LiteralString:
            return try compile(literalString: expr)
        case let expr as Expression.Bitcast:
            return try compile(bitcast: expr)
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
        let childType = try typeChecker.check(expression: unary.child)
        
        var instructions: [CrackleInstruction] = []
        
        if unary.op == .ampersand {
            switch childType {
            case .function(let typ):
                let label = typ.mangledName ?? typ.name!
                let a = temporaryAllocator.allocate()
                instructions += [
                    .copyLabel(a.address, label)
                ]
                temporaryStack.push(a)
            default:
                instructions += try lvalueContext().compile(expression: unary.child)
            }
        } else {
            let childExpr = try compile(expression: unary.child)
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
            
            b.consume()
            a.consume()
        }
        
        return instructions
    }
    
    private func compile(binary: Expression.Binary) throws -> [CrackleInstruction] {
        let rightType = try typeChecker.check(expression: binary.right)
        let leftType = try typeChecker.check(expression: binary.left)
        
        if leftType.isArithmeticType && rightType.isArithmeticType {
            return try compileArithmeticBinaryExpression(binary, leftType, rightType)
        }
        
        if leftType.isBooleanType && rightType.isBooleanType {
            return try compileBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        // This is basically unreachable since the type checker will
        // typically throw an error before we get to this point.
        assert(false)
        throw unsupportedError(expression: binary)
    }
    
    private func compileBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> [CrackleInstruction] {
        guard leftType.isBooleanType && rightType.isBooleanType else {
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
        
        if case .compTimeBool = leftType, case .compTimeBool = rightType {
            return try compileConstantBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: .bool)
        let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: .bool)
        
        let c = temporaryAllocator.allocate()
        let a = temporaryStack.pop()
        let b = temporaryStack.pop()
        
        var instructions: [CrackleInstruction] = []
        
        switch binary.op {
        case .eq:
            instructions += right + left + [.eq(c.address, a.address, b.address)]
        case .ne:
            instructions += right + left + [.ne(c.address, a.address, b.address)]
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
        
        temporaryStack.push(c)
        a.consume()
        b.consume()
        
        return instructions
    }
    
    private func compileConstantBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> [CrackleInstruction] {
        guard case .compTimeBool(let a) = leftType, case .compTimeBool(let b) = rightType else {
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
        
        var instructions: [CrackleInstruction] = []
        
        let dst = temporaryAllocator.allocate()
        
        switch binary.op {
        case .eq:
            instructions += [.storeImmediate(dst.address, (a == b) ? 1 : 0)]
        case .ne:
            instructions += [.storeImmediate(dst.address, (a != b) ? 1 : 0)]
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
        
        temporaryStack.push(dst)
        return instructions
    }
    
    private func compileArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> [CrackleInstruction] {
        guard leftType.isArithmeticType && rightType.isArithmeticType else {
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }

        if case .compTimeInt = leftType, case .compTimeInt = rightType {
            return try compileConstantArithmeticBinaryExpression(binary, leftType, rightType)
        }
        
        let typeForArithmetic: SymbolType = (max(leftType.max(), rightType.max()) > 255) ? .u16 : .u8
        
        var instructions: [CrackleInstruction] = []
        
        let right: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.right, ltype: typeForArithmetic)
        instructions += right
        
        let left: [CrackleInstruction] = try compileAndConvertExpressionForAssignment(rexpr: binary.left, ltype: typeForArithmetic)
        instructions += left
        
        let a = temporaryStack.pop()
        let b = temporaryStack.pop()
        let c = temporaryAllocator.allocate()
        
        switch (binary.op, typeForArithmetic) {
        case (.eq, .u8):
            instructions += [.eq(c.address, a.address, b.address)]
        case (.eq, .u16):
            instructions += [.eq16(c.address, a.address, b.address)]
        case (.ne, .u8):
            instructions += [.ne(c.address, a.address, b.address)]
        case (.ne, .u16):
            instructions += [.ne16(c.address, a.address, b.address)]
        case (.lt, .u8):
            instructions += [.lt(c.address, a.address, b.address)]
        case (.lt, .u16):
            instructions += [.lt16(c.address, a.address, b.address)]
        case (.gt, .u8):
            instructions += [.gt(c.address, a.address, b.address)]
        case (.gt, .u16):
            instructions += [.gt16(c.address, a.address, b.address)]
        case (.le, .u8):
            instructions += [.le(c.address, a.address, b.address)]
        case (.le, .u16):
            instructions += [.le16(c.address, a.address, b.address)]
        case (.ge, .u8):
            instructions += [.ge(c.address, a.address, b.address)]
        case (.ge, .u16):
            instructions += [.ge16(c.address, a.address, b.address)]
        case (.plus, .u8):
            instructions += [.add(c.address, a.address, b.address)]
        case (.plus, .u16):
            instructions += [.add16(c.address, a.address, b.address)]
        case (.minus, .u8):
            instructions += [.sub(c.address, a.address, b.address)]
        case (.minus, .u16):
            instructions += [.sub16(c.address, a.address, b.address)]
        case (.star, .u8):
            instructions += [.mul(c.address, a.address, b.address)]
        case (.star, .u16):
            instructions += [.mul16(c.address, a.address, b.address)]
        case (.divide, .u8):
            instructions += [.div(c.address, a.address, b.address)]
        case (.divide, .u16):
            instructions += [.div16(c.address, a.address, b.address)]
        case (.modulus, .u8):
            instructions += [.mod(c.address, a.address, b.address)]
        case (.modulus, .u16):
            instructions += [.mod16(c.address, a.address, b.address)]
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
        
        temporaryStack.push(c)
        b.consume()
        a.consume()
        
        return instructions
    }
    
    private func compileConstantArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> [CrackleInstruction] {
        guard case .compTimeInt(let a) = leftType, case .compTimeInt(let b) = rightType else {
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
        
        var instructions: [CrackleInstruction] = []
        
        let dst = temporaryAllocator.allocate()
        
        switch binary.op {
        case .eq:
            instructions += [.storeImmediate(dst.address, (a == b) ? 1 : 0)]
        case .ne:
            instructions += [.storeImmediate(dst.address, (a != b) ? 1 : 0)]
        case .lt:
            instructions += [.storeImmediate(dst.address, (a < b) ? 1 : 0)]
        case .gt:
            instructions += [.storeImmediate(dst.address, (a > b) ? 1 : 0)]
        case .le:
            instructions += [.storeImmediate(dst.address, (a <= b) ? 1 : 0)]
        case .ge:
            instructions += [.storeImmediate(dst.address, (a >= b) ? 1 : 0)]
        case .plus:
            let value = a + b
            if value > 255 {
                instructions += [.storeImmediate16(dst.address, value)]
            } else {
                instructions += [.storeImmediate(dst.address, value)]
            }
        case .minus:
            let value = a - b
            if value > 255 {
                instructions += [.storeImmediate16(dst.address, value)]
            } else {
                instructions += [.storeImmediate(dst.address, value)]
            }
        case .star:
            let value = a * b
            if value > 255 {
                instructions += [.storeImmediate16(dst.address, value)]
            } else {
                instructions += [.storeImmediate(dst.address, value)]
            }
        case .divide:
            let value = a / b
            if value > 255 {
                instructions += [.storeImmediate16(dst.address, value)]
            } else {
                instructions += [.storeImmediate(dst.address, value)]
            }
        case .modulus:
            let value = a % b
            if value > 255 {
                instructions += [.storeImmediate16(dst.address, value)]
            } else {
                instructions += [.storeImmediate(dst.address, value)]
            }
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false)
            throw unsupportedError(expression: binary)
        }
        
        temporaryStack.push(dst)
        
        return instructions
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
        let ltype = try lvalueContext().typeChecker.check(expression: assignment.lexpr)
        var instructions: [CrackleInstruction] = []
        
        guard ltype != nil else {
            abort()
        }
        
        guard false==ltype!.isConst || (assignment is Expression.InitialAssignment) else {
            abort()
        }
        
        // Calculate the lvalue, the destination in memory for the assignment.
        let lvalue_proc = try lvalueContext().compile(expression: assignment.lexpr)
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
        
        guard let ltype = try lvalueContext().typeChecker.check(expression: assignment.lexpr) else {
            throw CompilerError(sourceAnchor: assignment.lexpr.sourceAnchor,
                                message: "lvalue required in assignment")
        }
        
        // Calculate the rvalue, the value that is being assigned.
        // To handle automatic conversion and promotion, the value of this
        // expression is converted now to the type of the destination variable.
        let rvalue_proc = try compileAndConvertExpressionForAssignment(rexpr: assignment.rexpr, ltype: ltype)
        instructions += rvalue_proc
        let rvalue = temporaryStack.peek()
        
        // Emit code to copy the rvalue to the address given by the lvalue.
        // The expression result is assumed to be small enough to fit into
        // a temporary allocated from the scratch memory region.
        // If it doesn't fit then an error would have been raised before
        // this point.
        instructions += [.copyWordsIndirectDestination(lvalue.address, rvalue.address, ltype.sizeof)]
        
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
        case (.constBool, .constBool),
             (.constBool, .bool),
             (.bool, .constBool),
             (.bool, .bool),
             (.constU8, .constU8),
             (.constU8, .u8),
             (.u8, .constU8),
             (.u8, .u8),
             (.constU16, .constU16),
             (.constU16, .u16),
             (.u16, .constU16),
             (.u16, .u16):
             instructions += try compile(expression: rexpr)
        case (.compTimeInt(let a), .u8), (.compTimeInt(let a), .constU8):
            assert(a >= 0 && a < 256)
            let dst = temporaryAllocator.allocate()
            temporaryStack.push(dst)
            instructions += [.storeImmediate(dst.address, a)]
        case (.compTimeInt(let a), .u16), (.compTimeInt(let a), .constU16):
            assert(a >= 0 && a < 65536)
            let dst = temporaryAllocator.allocate()
            instructions += [.storeImmediate16(dst.address, a)]
            temporaryStack.push(dst)
        case (.compTimeBool(let a), .bool), (.compTimeBool(let a), .constBool):
            let dst = temporaryAllocator.allocate()
            instructions += [.storeImmediate(dst.address, a ? 1 : 0)]
            temporaryStack.push(dst)
        case (.constU8, .constU16),
             (.constU8, .u16),
             (.u8, .constU16),
             (.u8, .u16):
            instructions += try compile(expression: rexpr)
            let dst = temporaryAllocator.allocate()
            let src = temporaryStack.pop()
            instructions += [.copyWordZeroExtend(dst.address, src.address)]
            temporaryStack.push(dst)
            src.consume()
        case (.constU16, .constU8),
             (.constU16, .u8),
             (.u16, .constU8),
             (.u16, .u8):
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
                // TODO: Is it bad to check for the Expression.Identifier type here explicitly? Do I get unexpected/incorrect behavior if I retrieve the array from a struct via a Get expression, for example?
                let elements = stride(from: 0, through: n-1, by: 1).map({i in
                    Expression.As(sourceAnchor: identifier.sourceAnchor,
                                  expr: Expression.Subscript(sourceAnchor: identifier.sourceAnchor,
                                                             subscriptable: identifier,
                                                             argument: Expression.LiteralInt(sourceAnchor: identifier.sourceAnchor, value: i)),
                                  targetType: Expression.PrimitiveType(b))
                })
                let arrayType = Expression.ArrayType(count: Expression.LiteralInt(elements.count),
                                                     elementType: Expression.PrimitiveType(b))
                let synthesized = Expression.LiteralArray(sourceAnchor: identifier.sourceAnchor,
                                                          arrayType: arrayType,
                                                          elements: elements)
                instructions += try compile(expression: synthesized)
            default:
                // When we convert an array, we can change the element type from
                // the mutable type to the corresponding const type.
                guard a == b || a == b.correspondingConstType || a.correspondingConstType == b else {
                    assert(false) // unreachable
                    abort()
                }
                instructions += try compile(expression: rexpr)
            }
        case (.array(let n?, let a), .constDynamicArray(let b)),
             (.array(let n?, let a), .dynamicArray(let b)):
            guard a == b || a == b.correspondingConstType || a.correspondingConstType == b else {
                assert(false) // unreachable
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
        case (.constDynamicArray(let a), .constDynamicArray(let b)),
             (.constDynamicArray(let a), .dynamicArray(let b)),
             (.dynamicArray(let a), .constDynamicArray(let b)),
             (.dynamicArray(let a), .dynamicArray(let b)):
            // When we convert a dynamic array, we can change the element type
            // from the mutable type to the corresponding const type.
            guard a == b || a.correspondingConstType == b else {
                assert(false) // unreachable
                abort()
            }
            instructions += try compile(expression: rexpr)
        case (.constStructType(let a), .constStructType(let b)),
             (.constStructType(let a), .structType(let b)),
             (.structType(let a), .constStructType(let b)),
             (.structType(let a), .structType(let b)):
            // When we convert a struct type, the underlying struct layouts
            // must be identical.
            guard a == b else {
                assert(false) // unreachable
                abort()
            }
            instructions += try compile(expression: rexpr)
        case (.constPointer(let a), .constPointer(let b)),
             (.constPointer(let a), .pointer(let b)),
             (.pointer(let a), .constPointer(let b)),
             (.pointer(let a), .pointer(let b)):
            // When we convert a pointer, we can change the pointee type
            // from the mutable type to the corresponding const type.
            guard a == b || a.correspondingConstType == b else {
                assert(false) // unreachable
                abort()
            }
            instructions += try compile(expression: rexpr)
        case (.unionType, .unionType):
            instructions += try compile(expression: rexpr)
        case (_, .unionType(let typ)):
            // So which type are we converting to in the union? And the tag?
            var targetType: SymbolType?
            var typeTag: Int?
            for i in 0..<typ.members.count {
                let member = typ.members[i]
                let status = typeChecker.convertBetweenTypes(ltype: member,
                                                             rtype: rtype,
                                                             sourceAnchor: rexpr.sourceAnchor,
                                                             messageWhenNotConvertible: "",
                                                             isExplicitCast: false)
                switch status {
                case .acceptable(let typ):
                    targetType = typ
                    typeTag = i
                case .unacceptable:
                    break // just move on to the next one
                }
            }
            
            // Convert the expression to the target type.
            instructions += try compileAndConvertExpression(rexpr: rexpr, ltype: targetType!, isExplicitCast: false)
            let src = temporaryStack.pop()
            
            // Allocate a temporary for the union structure.
            // Write the converted value into the union structure.
            let dst = temporaryAllocator.allocate(size: ltype.sizeof)
            instructions += [.copyWords(dst.address+1, src.address, targetType!.sizeof)]
            src.consume()
            
            // Write the type tag into the union structure too.
            instructions += [.storeImmediate(dst.address+0, typeTag!)]
            temporaryStack.push(dst)
        case (.unionType, _):
            assert(isExplicitCast)
            instructions += try compile(expression: rexpr)
            let dst = temporaryAllocator.allocate(size: ltype.sizeof)
            let src = temporaryStack.pop()
            instructions += [.copyWords(dst.address, src.address+1, ltype.sizeof)]
            temporaryStack.push(dst)
            src.consume()
        case (.constPointer(let a), .traitType(let b)),
             (.pointer(let a), .traitType(let b)):
            guard case .structType(let structType) = a else {
                abort()
            }
            let nameOfVtableInstance = "__\(b.name)_\(structType.name)_vtable_instance"
            instructions += try compile(expression: Expression.StructInitializer(identifier: Expression.Identifier(b.nameOfTraitObjectType), arguments: [
                // Take the pointer to the object and cast as an opaque *void
                Expression.StructInitializer.Argument(name: "object", expr: Expression.Bitcast(expr: rexpr, targetType: Expression.PointerType(Expression.PrimitiveType(.void)))),
                
                // Attach a pointer to the appropriate vtable instance.
                Expression.StructInitializer.Argument(name: "vtable", expr: Expression.Unary(op: .ampersand, expression: Expression.Identifier(nameOfVtableInstance)))
            ]))
        default:
            assert(false) // unreachable
            abort()
        }
        return instructions
    }
    
    private func compile(call node: Expression.Call) throws -> [CrackleInstruction] {
        let calleeType = try RvalueExpressionTypeChecker(symbols: symbols).check(expression: node.callee)
        
        switch calleeType {
        case .function(let typ), .pointer(.function(let typ)), .constPointer(.function(let typ)):
            return try compile(call: node, typ: typ)
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false) // unreachable
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "cannot call value of non-function type `\(calleeType)'")
        }
    }
    
    private func compile(call node: Expression.Call, typ: FunctionType) throws -> [CrackleInstruction] {
        if typ.arguments.count > 0 {
            let selfExpr: Expression?
            switch node.callee {
            case let expr as Expression.Get:
                selfExpr = expr.expr
            case let expr as Expression.Identifier:
                selfExpr = expr
            default:
                selfExpr = nil
            }
            if let selfExpr = selfExpr {
                var selfType = try RvalueExpressionTypeChecker(symbols: symbols).check(expression: selfExpr)
                if case .traitType(let typ) = selfType {
                    selfType = try symbols.resolveType(identifier: typ.nameOfTraitObjectType)
                }
                let argType0 = typ.arguments[0]
                if argType0 == selfType || argType0.correspondingConstType == selfType {
                    return try compileStructMemberFunctionCall(typ, node, selfExpr)
                }
                if argType0 == .pointer(selfType) || argType0 == .pointer(selfType.correspondingConstType) || argType0.correspondingConstType == .constPointer(selfType) {
                    let addressOf = Expression.Bitcast(expr: Expression.Unary(sourceAnchor: selfExpr.sourceAnchor, op: .ampersand, expression: selfExpr), targetType: Expression.PrimitiveType(argType0))
                    return try compileStructMemberFunctionCall(typ, node, addressOf)
                }
            }
        }
        
        var instructions: [CrackleInstruction] = []
        switch typ.name {
        case "peekMemory":      instructions += try compileFunctionPeekMemory(typ, node)
        case "pokeMemory":      instructions += try compileFunctionPokeMemory(typ, node)
        case "peekPeripheral":  instructions += try compileFunctionPeekPeripheral(typ, node)
        case "pokePeripheral":  instructions += try compileFunctionPokePeripheral(typ, node)
        case "hlt":             instructions += [.hlt]
        default:                instructions += try compileFunctionUserDefined(typ, node)
        }
        return instructions
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
    
    private func pushFunctionArguments(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Push function arguments to the stack with appropriate type conversions.
        for i in 0..<typ.arguments.count {
            let type = typ.arguments[i]
            instructions += try compileAndConvertExpressionForAssignment(rexpr: node.arguments[i], ltype: type)
            let tempArgumentValue = temporaryStack.pop()
            instructions += pushTemporary(temporary: tempArgumentValue, explicitSize: type.sizeof)
            tempArgumentValue.consume()
        }
        
        return instructions
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
    
    private func compileFunctionUserDefined(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        let evaluateFunctionArguments = { () -> [CrackleInstruction] in
            var instructions: [CrackleInstruction] = []
            for i in (0..<typ.arguments.count).reversed() {
                let argumentType = typ.arguments[i]
                instructions += try self.compileAndConvertExpressionForAssignment(rexpr: node.arguments[i], ltype: argumentType)
            }
            return instructions
        }
        return try compileGenericUserDefinedFunctionCall(typ, node, evaluateFunctionArguments)
    }
    
    private func compileStructMemberFunctionCall(_ typ: FunctionType, _ node: Expression.Call, _ selfExpr: Expression) throws -> [CrackleInstruction] {
        let evaluateFunctionArguments = { () -> [CrackleInstruction] in
            var instructions: [CrackleInstruction] = []
            
            for i in (0..<node.arguments.count).reversed() {
                instructions += try self.compileAndConvertExpressionForAssignment(rexpr: node.arguments[i], ltype: typ.arguments[i+1])
            }
            
            instructions += try self.compileAndConvertExpressionForAssignment(rexpr: selfExpr, ltype: typ.arguments[0])
            
            return instructions
        }
        return try compileGenericUserDefinedFunctionCall(typ, node, evaluateFunctionArguments)
    }
    
    private func compileGenericUserDefinedFunctionCall(_ typ: FunctionType, _ node: Expression.Call, _ evaluateFunctionArguments: () throws -> [CrackleInstruction]) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Determine the temporaries that need to be preserved across the call.
        // Only preserve the temporaries which are live on entering this method.
        // The ones generated below are consumed below as well.
        let temporariesToPreserve = temporaryAllocator.liveTemporaries
        
        // Evaluate function arguments, putting the value of each into a
        // temporary. These are all evaluated in reverse order and end up on
        // the compiler temporaries stack in reverse order.
        instructions += try evaluateFunctionArguments()
        
        // Now we preserve those temporaries. We can't do that sooner because
        // the evaluation of function arguments might allocate memory on the
        // stack. The temporaries must be preserved on the stack with a
        // predictable memory layout.
        instructions += saveCompilerTemporariesForFunctionCall(temporariesToPreserve)
        
        // Allocate a compiler temporary, and space on the program stack, for
        // the function's return value.
        let tempReturnValue: CompilerTemporary? = allocateTemporaryForFunctionCallReturn(typ)
        instructions += try pushToAllocateFunctionReturnValue(typ)
        
        // The values of function arguments are on the compiler temporaries
        // stack right now. Push them to the program stack to build up the
        // function arguments pack.
        for argumentType in typ.arguments {
            let tempArgumentValue = temporaryStack.pop()
            instructions += pushTemporary(temporary: tempArgumentValue, explicitSize: argumentType.sizeof)
            tempArgumentValue.consume()
        }
        
        // Compile the branch to the function. The branch may be compiled
        // differently depending on whether this is a call to a function known
        // at compile time, or a call through a function pointer.
        instructions += try compileBranchToCallee(node)
        
        instructions += popFunctionArguments(typ)
        
        // Copy the return value from the program stack to the temporary we
        // allocated earlier. This pushes that temporary to the compiler's
        // temporaries stack to allow this call to be composed with the
        // evaluation of other expressions.
        instructions += copyReturnValueForFunctionCall(typ, tempReturnValue)
        
        // The call to the function will have surely trampled on compiler
        // temporaries which were in use before the call. Restore those now.
        instructions += restoreCompilerTemporariesForFunctionCall(temporariesToPreserve)
        
        return instructions
    }
    
    private func compileBranchToCallee(_ node: Expression.Call) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        let calleeType = try RvalueExpressionTypeChecker(symbols: symbols).check(expression: node.callee)
        switch calleeType {
        case .function(let typ):
            // If the callee is an identifier which resolves to a function then
            // we can get the label from the function's type record.
            instructions += [.jalr(typ.mangledName!)]
        case .pointer(.function), .constPointer(.function):
            // If the callee is a pointer then we need to evaluate the callee
            // expression to determine the value of the pointer and then branch
            // to that address.
            instructions += try compile(expression: node.callee)
            let tempPointerValue = temporaryStack.pop()
            instructions += [
                .indirectJalr(tempPointerValue.address)
            ]
        default:
            // This is basically unreachable since the type checker will
            // typically throw an error before we get to this point.
            assert(false) // unreachable
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "cannot call value of non-function type `\(calleeType)'")
        }
        return instructions
    }
    
    // Save all live temporaries to preserve their values across the call.
    // We cannot know which temporaries will be invalidated by code in
    // the function body.
    private func saveCompilerTemporariesForFunctionCall(_ temporariesToPreserve: [CompilerTemporary]) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        for temporary in temporariesToPreserve {
            instructions += pushTemporary(temporary)
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
    
    private func allocateTemporaryForFunctionCallReturn(_ typ: FunctionType) -> CompilerTemporary? {
        let tempReturnValue: CompilerTemporary?
        if case .void = typ.returnType {
            tempReturnValue = nil
        } else {
            tempReturnValue = temporaryAllocator.allocate(size: typ.returnType.sizeof)
        }
        return tempReturnValue
    }
    
    private func pushToAllocateFunctionReturnValue(_ typ: FunctionType) throws -> [CrackleInstruction] {
        if typ.returnType.sizeof > 0 {
            return [.subi16(kStackPointerAddress, kStackPointerAddress, typ.returnType.sizeof)]
        } else {
            return []
        }
    }
    
    private func pushFunctionArgumentsToCompilerTemporariesStack(_ typ: FunctionType, _ node: Expression.Call) throws -> [CrackleInstruction] {
        // Push function arguments to the compiler temporaries stack
        // with appropriate type conversions.
        var instructions: [CrackleInstruction] = []
        for i in 0..<typ.arguments.count {
            instructions += try compileAndConvertExpressionForAssignment(rexpr: node.arguments[i], ltype: typ.arguments[i])
        }
        return instructions
    }
    
    private func popFunctionArguments(_ typ: FunctionType) -> [CrackleInstruction] {
        var totalSize = 0
        for arg in typ.arguments {
            totalSize += arg.sizeof
        }
        if totalSize > 0 {
            return [.addi16(kStackPointerAddress, kStackPointerAddress, totalSize)]
        } else {
            return []
        }
    }
    
    // If there is a return value then it can be found at the top of the
    // stack. Copy it to the temporary we allocated for it, above.
    private func copyReturnValueForFunctionCall(_ typ: FunctionType, _ tempReturnValue: CompilerTemporary?) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        if let tempReturnValue = tempReturnValue {
            if typ.returnType.sizeof > 0 {
                instructions += [
                    .copyWordsIndirectSource(tempReturnValue.address, kStackPointerAddress, typ.returnType.sizeof),
                    .addi16(kStackPointerAddress, kStackPointerAddress, typ.returnType.sizeof)
                ]
            }
            temporaryStack.push(tempReturnValue)
        }
        return instructions
    }
    
    // Restore live temporaries after the function call returns.
    private func restoreCompilerTemporariesForFunctionCall(_ temporariesToPreserve: [CompilerTemporary]) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        for temporary in temporariesToPreserve.reversed() {
            instructions += popTemporary(temporary)
        }
        return instructions
    }
    
    private func popTemporary(_ temporary: CompilerTemporary) -> [CrackleInstruction] {
        let instructions: [CrackleInstruction] = [
            .copyWordsIndirectSource(temporary.address, kStackPointerAddress, temporary.size),
            .addi16(kStackPointerAddress, kStackPointerAddress, temporary.size)
        ]
        return instructions
    }
    
    private func compile(as expr: Expression.As) throws -> [CrackleInstruction] {
        let targetType = try typeChecker.check(expression: expr.targetType)
        let instructions = try compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: targetType)
        return instructions
    }
    
    private func compile(is expr: Expression.Is) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        let tempResult = temporaryAllocator.allocate()
        let exprType = try typeChecker.check(expression: expr)
        switch exprType {
        case .compTimeBool(let val):
            instructions += [.storeImmediate(tempResult.address, val ? 1 : 0)]
        default:
            switch try typeChecker.check(expression: expr.expr) {
            case .unionType(let typ):
                instructions += try compileUnionTypeIs(expr, tempResult, typ)
            default:
                assert(false) // unreachable
                abort()
            }
        }
        temporaryStack.push(tempResult)
        return instructions
    }
    
    private func compileUnionTypeIs(_ expr: Expression.Is, _ tempResult: CompilerTemporary, _ typ: UnionType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Take the test type and determine the corresponding type tag.
        let testType = try typeChecker.check(expression: expr.testType)
        let typeTag: Int! = determineUnionTypeTag(typ, testType)
        instructions += [.storeImmediate(tempResult.address, typeTag)]
        
        // Compile the expression to get the value of the union.
        instructions += try compile(expression: expr.expr)
        let tempUnionValue = temporaryStack.pop()
        
        // Compare the union's type tag against the tag of the test type.
        instructions += [.eq(tempResult.address, tempResult.address, tempUnionValue.address)]
        tempUnionValue.consume()
        
        return instructions
    }
    
    // Given a type and a related union, determine the corresponding type tag.
    // Return nil if the type does not match the union after all.
    private func determineUnionTypeTag(_ typ: UnionType, _ testType: SymbolType) -> Int? {
        for i in 0..<typ.members.count {
            let member = typ.members[i]
            if testType == member || testType.correspondingConstType == member {
                return i
            }
        }
        return nil
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
    public override func arraySubscript(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        instructions += try arraySubscriptLvalue(expr)
        
        let symbolType = try rvalueContext().typeChecker.check(expression: expr.subscriptable)
        let elementType = symbolType.arrayElementType
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
    public override func dynamicArraySubscript(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        instructions += try dynamicArraySubscriptLvalue(expr)
        
        let symbolType = try rvalueContext().typeChecker.check(expression: expr.subscriptable)
        let elementType = symbolType.arrayElementType
        instructions += try loadFromLvalueIntoTemporary(elementType)
        
        return instructions
    }
    
    public func compile(get expr: Expression.Get) throws -> [CrackleInstruction] {
        let name = expr.member.identifier
        let resultType = try typeChecker.check(expression: expr.expr)
        
        var instructions: [CrackleInstruction] = []
        
        switch resultType {
        case .array(count: let count, elementType: _):
            assert(name == "count")
            instructions += try compile(expression: expr.expr)
            let tempExprResult = temporaryStack.pop()
            let tempCount = temporaryAllocator.allocate()
            instructions += [.storeImmediate16(tempCount.address, count!)]
            tempExprResult.consume()
            temporaryStack.push(tempCount)
        case .constDynamicArray, .dynamicArray:
            assert(name == "count")
            instructions += try compile(expression: expr.expr)
            let tempExprResult = temporaryStack.pop()
            let tempCount = temporaryAllocator.allocate()
            instructions += [.copyWords(tempCount.address, tempExprResult.address + kSliceCountOffset, kSliceCountSize)]
            tempExprResult.consume()
            temporaryStack.push(tempCount)
        case .constStructType(let typ), .structType(let typ):
            instructions += try lvalueContext().compile(expression: expr.expr)
            
            // Read the field in-place
            let tempStructAddress = temporaryStack.pop()
            let symbol = try typ.symbols.resolve(identifier: name)
            let tempStructMember = temporaryAllocator.allocate(size: symbol.type.sizeof)
            instructions += [
                .addi16(tempStructAddress.address, tempStructAddress.address, symbol.offset),
                .copyWordsIndirectSource(tempStructMember.address, tempStructAddress.address, symbol.type.sizeof)
            ]
            tempStructAddress.consume()
            temporaryStack.push(tempStructMember)
        case .constPointer(let typ), .pointer(let typ):
            instructions += try compile(expression: expr.expr)
            let tempExprResult = temporaryStack.pop()
            if name == "pointee" {
                let tempPointee = temporaryAllocator.allocate()
                instructions += [.copyWordsIndirectSource(tempPointee.address, tempExprResult.address, typ.sizeof)]
                tempExprResult.consume()
                temporaryStack.push(tempPointee)
            } else {
                switch typ {
                case .array(count: let count, elementType: _):
                    assert(name == "count")
                    let tempCount = temporaryAllocator.allocate()
                    instructions += [.storeImmediate16(tempCount.address, count!)]
                    tempExprResult.consume()
                    temporaryStack.push(tempCount)
                case .constDynamicArray, .dynamicArray:
                    assert(name == "count")
                    let tempCount = temporaryAllocator.allocate()
                    instructions += [
                        .copyWords(tempCount.address, tempExprResult.address + kSliceCountOffset, kSliceCountSize)
                    ]
                    tempExprResult.consume()
                    temporaryStack.push(tempCount)
                case .constStructType(let b), .structType(let b):
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
                    abort()
                }
            }
        default:
            assert(false) // unreachable
            abort()
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
            let member = try typ.symbols.resolve(identifier: arg.name)
            instructions += try compileAndConvertExpressionForExplicitCast(rexpr: arg.expr, ltype: member.type)
            let tempArg = temporaryStack.pop()
            instructions += [.copyWords(tempResult.address + member.offset, tempArg.address, member.type.sizeof)]
            tempArg.consume()
        }
        temporaryStack.push(tempResult)
        return instructions
    }
    
    private func compile(literalString expr: Expression.LiteralString) throws -> [CrackleInstruction] {
        let typ = Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8))
        let sourceAnchor = expr.sourceAnchor
        let elements = expr.value.utf8.map({
            Expression.LiteralInt(sourceAnchor: sourceAnchor, value: Int($0))
        })
        let arr = Expression.LiteralArray(sourceAnchor: sourceAnchor,
                                          arrayType: typ,
                                          elements: elements)
        return try compile(literalArray: arr)
    }
    
    private func compile(bitcast expr: Expression.Bitcast) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let targetType = try typeChecker.check(expression: expr.targetType)
        let tempDst = temporaryAllocator.allocate(size: targetType.sizeof)
        
        instructions += try compile(expression: expr.expr)
        let tempSrc = temporaryStack.pop()
        instructions += [
            .copyWords(tempDst.address, tempSrc.address, targetType.sizeof)
        ]
        tempSrc.consume()
        temporaryStack.push(tempDst)
        
        return instructions
    }
}
