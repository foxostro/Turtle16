//
//  SnapToTackCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import Turtle16SimulatorCore

// Program are compiled to an intermediate language called Tack which uses
// InstructionNode, similar to the representation of an assembly program. The
// instruction operands are taken from the following list.
public struct Tack {
    public static let kCALL   = "TACK_CALL"
    public static let kENTER  = "TACK_ENTER"
    public static let kLEAVE  = "TACK_LEAVE"
    public static let kRET    = "TACK_RET"
    public static let kJMP    = "TACK_JMP"
    public static let kNOT    = "TACK_NOT"
    public static let kLA     = "TACK_LA"
    public static let kBZ     = "TACK_BZ"
    public static let kBNZ    = "TACK_BNZ"
    
    public static let kANDI16 = "TACK_ANDI16"
    public static let kADDI16 = "TACK_ADDI16"
    public static let kSUBI16 = "TACK_SUBI16"
    
    public static let kLOAD16 = "TACK_LOAD16"
    public static let kLI16   = "TACK_LI16"
    public static let kLIU16  = "TACK_LIU16"
    public static let kCMP16  = "TACK_CMP16"
    public static let kAND16  = "TACK_AND16"
    public static let kOR16   = "TACK_OR16"
    public static let kXOR16  = "TACK_XOR16"
    public static let kNEG16  = "TACK_NEG16"
    public static let kADD16  = "TACK_ADD16"
    public static let kSUB16  = "TACK_SUB16"
    public static let kMUL16  = "TACK_MUL16"
    public static let kDIV16  = "TACK_DIV16"
    public static let kMOD16  = "TACK_MOD16"
    public static let kLSL16  = "TACK_LSL16"
    public static let kLSR16  = "TACK_LSR16"
    public static let kEQ16   = "TACK_EQ16"
    public static let kNE16   = "TACK_NE16"
    public static let kLT16   = "TACK_LT16"
    public static let kGE16   = "TACK_GE16"
    public static let kLE16   = "TACK_LE16"
    public static let kGT16   = "TACK_GT16"
    
    public static let kLOAD8  = "TACK_LOAD8"
    public static let kLI8    = "TACK_LI8"
    public static let kCMP8   = "TACK_CMP8"
    public static let kAND8   = "TACK_AND8"
    public static let kOR8    = "TACK_OR8"
    public static let kXOR8   = "TACK_XOR8"
    public static let kNEG8   = "TACK_NEG8"
    public static let kADD8   = "TACK_ADD8"
    public static let kSUB8   = "TACK_SUB8"
    public static let kMUL8   = "TACK_MUL8"
    public static let kDIV8   = "TACK_DIV8"
    public static let kMOD8   = "TACK_MOD8"
    public static let kLSL8   = "TACK_LSL8"
    public static let kLSR8   = "TACK_LSR8"
    public static let kEQ8    = "TACK_EQ8"
    public static let kNE8    = "TACK_NE8"
    public static let kLT8    = "TACK_LT8"
    public static let kGE8    = "TACK_GE8"
    public static let kLE8    = "TACK_LE8"
    public static let kGT8    = "TACK_GT8"
}

public class SnapToTackCompiler: SnapASTTransformerBase {
    public let globalEnvironment: GlobalEnvironment
    public internal(set) var registerStack: [String] = []
    var nextRegisterIndex = 0
    let fp = "fp"
    
    func pushRegister(_ identifier: String) {
        registerStack.append(identifier)
    }
    
    func popRegister() -> String {
        assert(!registerStack.isEmpty)
        return registerStack.removeLast()
    }
    
    func nextRegister() -> String {
        let result = "vr\(nextRegisterIndex)"
        nextRegisterIndex += 1
        return result
    }
    
    public init(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func compile(block node: Block) throws -> AbstractSyntaxTreeNode? {
        let result = try super.compile(block: node) as! Block
        
        if result.children.count < 2 {
            return result.children.first
        }
        
        return Seq(sourceAnchor: node.sourceAnchor, children: result.children)
    }
    
    public override func compile(return node: Return) throws -> AbstractSyntaxTreeNode? {
        assert(node.expression == nil)
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kLEAVE),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kRET)
        ])
    }
    
    public override func compile(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let sizeOfLocalVariables = node.symbols.highwaterMark
        
        let mangledName = (try TypeContextTypeChecker(symbols: symbols!).check(expression: node.functionType).unwrapFunctionType()).mangledName!
        let labelHead = mangledName
        let labelTail = "__\(mangledName)_tail"
        
        var children: [AbstractSyntaxTreeNode] = []
        
        children += [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: labelTail)
            ])),
            LabelDeclaration(sourceAnchor: node.sourceAnchor, identifier: labelHead),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kENTER, parameters: ParameterList(parameters: [
                ParameterNumber(value: sizeOfLocalVariables)
            ])),
            node.body,
            LabelDeclaration(sourceAnchor: node.sourceAnchor, identifier: labelTail),
        ]
        
        return try compile(seq: Seq(sourceAnchor: node.sourceAnchor, children: children))
    }
    
    public override func compile(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kJMP, parameters: ParameterList(parameters: [ParameterIdentifier(value: node.target)]))
    }
    
    public override func compile(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            try rvalue(expr: node.condition),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kBZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: popRegister()),
                ParameterIdentifier(value: "foo")
            ]))
        ])
    }
    
    public override func compile(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        return try rvalue(expr: node)
    }
    
    func typeCheck(rexpr: Expression) throws -> SymbolType {
        return try RvalueExpressionTypeChecker(symbols: symbols!).check(expression: rexpr)
    }
    
    func lvalue(expr: Expression) throws -> AbstractSyntaxTreeNode {
        switch expr {
        case let node as Expression.Identifier:
            return try lvalue(identifier: node)
        default:
            fatalError("unimplemented")
        }
    }
    
    func lvalue(identifier node: Expression.Identifier) throws -> AbstractSyntaxTreeNode {
        let resolution = try symbols!.resolveWithStackFrameDepth(sourceAnchor: node.sourceAnchor, identifier: node.identifier)
        let symbol = resolution.0
        let depth = symbols!.stackFrameIndex - resolution.1
        assert(depth >= 0)
        let result = computeAddressOfSymbol(sourceAnchor: node.sourceAnchor, symbol: symbol, depth: depth)
        return try compile(result)!
    }
    
    func computeAddressOfSymbol(sourceAnchor: SourceAnchor?, symbol: Symbol, depth: Int) -> Seq {
        assert(depth >= 0)
        var children: [AbstractSyntaxTreeNode] = []
        switch symbol.storage {
        case .staticStorage:
            let temp = nextRegister()
            pushRegister(temp)
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp),
                    ParameterNumber(value: symbol.offset)
                ]))
            ]
        case .automaticStorage:
            children += [
                computeAddressOfLocalVariable(sourceAnchor: sourceAnchor, offset: symbol.offset, depth: depth)
            ]
        }
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }
    
    func computeAddressOfLocalVariable(sourceAnchor: SourceAnchor?, offset: Int, depth: Int) -> Seq {
        assert(depth >= 0)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        let temp_framePointer: String
        
        if depth == 0 {
            temp_framePointer = fp
        } else {
            temp_framePointer = nextRegister()
            
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp_framePointer),
                    ParameterIdentifier(value: fp)
                ]))
            ]
            
            // Follow the frame pointer `depth' times.
            for _ in 1..<depth {
                children += [
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: temp_framePointer),
                        ParameterIdentifier(value: temp_framePointer)
                    ]))
                ]
            }
        }
        
        let temp_result = nextRegister()
        
        if offset >= 0 {
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: Tack.kSUBI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp_result),
                    ParameterIdentifier(value: temp_framePointer),
                    ParameterNumber(value: offset)
                ]))
            ]
        } else {
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: Tack.kADDI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp_result),
                    ParameterIdentifier(value: temp_framePointer),
                    ParameterNumber(value: -offset)
                ]))
            ]
        }
        
        pushRegister(temp_result)
        
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }
    
    func rvalue(expr: Expression) throws -> AbstractSyntaxTreeNode {
        switch expr {
        case let group as Expression.Group:
            return try rvalue(expr: group.expression)
        case let literal as Expression.LiteralInt:
            return rvalue(literalInt: literal)
        case let literal as Expression.LiteralBool:
            return rvalue(literalBoolean: literal)
        case let node as Expression.Identifier:
            return try rvalue(identifier: node)
        case let node as Expression.As:
            return try rvalue(as: node)
        case let node as Expression.Unary:
            return try rvalue(unary: node)
        case let node as Expression.Binary:
            return try rvalue(binary: node)
        case let expr as Expression.Is:
            return try rvalue(is: expr)
        default:
            throw CompilerError(message: "unimplemented: `\(expr)'")
        }
    }
    
    func rvalue(literalInt node: Expression.LiteralInt) -> AbstractSyntaxTreeNode {
        let dest = nextRegister()
        pushRegister(dest)
        let op = (node.value < 256) ? Tack.kLI8 : Tack.kLI16
        let result = InstructionNode(sourceAnchor: node.sourceAnchor, instruction: op, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: dest),
            ParameterNumber(value: node.value)
        ]))
        return result
    }
    
    func rvalue(literalBoolean node: Expression.LiteralBool) -> AbstractSyntaxTreeNode {
        let dest = nextRegister()
        pushRegister(dest)
        let result = InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: dest),
            ParameterNumber(value: node.value ? 1 : 0)
        ]))
        return result
    }
    
    func rvalue(identifier node: Expression.Identifier) throws -> AbstractSyntaxTreeNode {
        let symbol = try symbols!.resolve(identifier: node.identifier)
        
        var children: [AbstractSyntaxTreeNode] = [
            try lvalue(expr: node)
        ]
        
        if symbol.type.isPrimitive {
            let addr = popRegister()
            let dest = nextRegister()
            pushRegister(dest)
            let ins = (symbol.type == .u8) ? Tack.kLOAD8 : Tack.kLOAD16
            children += [
                InstructionNode(sourceAnchor: node.sourceAnchor, instruction: ins, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dest),
                    ParameterIdentifier(value: addr),
                ]))
            ]
        }
        
        return try compile(seq: Seq(sourceAnchor: node.sourceAnchor, children: children))!
    }
    
    func rvalue(as expr: Expression.As) throws -> AbstractSyntaxTreeNode {
        let targetType = try typeCheck(rexpr: expr.targetType)
        return try compileAndConvertExpression(rexpr: expr.expr, ltype: targetType, isExplicitCast: true)
    }
    
    func compileAndConvertExpression(rexpr: Expression, ltype: SymbolType, isExplicitCast: Bool) throws -> AbstractSyntaxTreeNode {
        let rtype = try typeCheck(rexpr: rexpr)
        
        if canValueBeTriviallyReinterpreted(ltype, rtype) {
            // The expression produces a value whose bitpattern can be trivially
            // reinterpreted as the target type.
            return try rvalue(expr: rexpr)
        }
        
        let result: AbstractSyntaxTreeNode
        
        switch (rtype, ltype) {
        case (.compTimeInt(let a), .u8),
             (.compTimeInt(let a), .constU8):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister()
            pushRegister(dst)
            return InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLI8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: dst),
                ParameterNumber(value: a)
            ]))
            
        case (.compTimeInt(let a), .u16),
             (.compTimeInt(let a), .constU16):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister()
            pushRegister(dst)
            return InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: dst),
                ParameterNumber(value: a)
            ]))
            
        case (.compTimeBool(let a), .bool),
             (.compTimeBool(let a), .constBool):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister()
            pushRegister(dst)
            return InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: dst),
                ParameterNumber(value: a ? 1 : 0)
            ]))
            
        case (.constU16, .constU8),
             (.constU16, .u8),
             (.u16, .constU8),
             (.u16, .u8):
            // Convert from u16 to u8 by masking off the upper byte.
            assert(isExplicitCast)
            var children: [AbstractSyntaxTreeNode] = []
            children += [
                try rvalue(expr: rexpr)
            ]
            let src = popRegister()
            let dst = nextRegister()
            pushRegister(dst)
            children += [
                InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kANDI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: src),
                    ParameterNumber(value: 0x00ff)
                ]))
            ]
            result = try compile(seq: Seq(sourceAnchor: rexpr.sourceAnchor, children: children))!
            
        case (.array(let n, _), .array(let m, let b)):
            guard n == m || m == nil, let n = n else {
                fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
            }
            let savedRegisterStack = registerStack
            let tempArrayId = Expression.Identifier(sourceAnchor: rexpr.sourceAnchor, identifier: globalEnvironment.tempNameMaker.next())
            let tempDecl = VarDeclaration(sourceAnchor: rexpr.sourceAnchor,
                                          identifier: tempArrayId,
                                          explicitType: Expression.PrimitiveType(ltype),
                                          expression: nil,
                                          storage: .automaticStorage,
                                          isMutable: true,
                                          visibility: .privateVisibility)
            let varDeclCompiler = SnapSubcompilerVarDeclaration(symbols: symbols!, globalEnvironment: globalEnvironment)
            let _ = try varDeclCompiler.compile(tempDecl)
            for i in 0..<n {
                _ = try rvalue(expr: Expression.Assignment(sourceAnchor: rexpr.sourceAnchor,
                                                   lexpr: Expression.Subscript(sourceAnchor: rexpr.sourceAnchor,
                                                                               subscriptable: tempArrayId,
                                                                               argument: Expression.LiteralInt(i)),
                                                   rexpr: Expression.As(sourceAnchor: rexpr.sourceAnchor,
                                                                        expr: Expression.Subscript(sourceAnchor: rexpr.sourceAnchor,
                                                                                                   subscriptable: rexpr,
                                                                                                   argument: Expression.LiteralInt(i)),
                                                                        targetType: Expression.PrimitiveType(b))))
            }
            registerStack = savedRegisterStack
            result = try lvalue(identifier: tempArrayId)
            
        case (.array(let n?, let a), .constDynamicArray(let b)),
             (.array(let n?, let a), .dynamicArray(let b)):
            fatalError("unimplemented: array(\(n), \(a)) -> dynamicArray(\(b)")
            
        case (.constDynamicArray(let a), .constDynamicArray(let b)),
             (.constDynamicArray(let a), .dynamicArray(let b)),
             (.dynamicArray(let a), .constDynamicArray(let b)),
             (.dynamicArray(let a), .dynamicArray(let b)):
            fatalError("unimplemented: dynamicArray(\(a)) -> dynamicArray(\(b))")
            
        case (.constStructType(let a), .constStructType(let b)),
             (.constStructType(let a), .structType(let b)),
             (.structType(let a), .constStructType(let b)),
             (.structType(let a), .structType(let b)):
            fatalError("unimplemented: structType(\(a)) -> structType(\(b))")
            
        case (.unionType, .unionType):
            fatalError("unimplemented: unionType -> unionType")
            
        case (_, .unionType(let typ)):
            fatalError("unimplemented: * -> unionType(\(typ))")
            
        case (.unionType, _):
            fatalError("unimplemented: unionType -> *")
            
        case (.constPointer(let a), .traitType(let b)),
             (.pointer(let a), .traitType(let b)):
            fatalError("unimplemented: pointer(\(a)) -> pointer(\(b))")
            
        case (.traitType(let a), .traitType(let b)):
            fatalError("unimplemented: trait(\(a)) -> trait(\(b))")
            
        default:
            fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
        }
        
        return result
    }
    
    func canValueBeTriviallyReinterpreted(_ ltype: SymbolType, _ rtype: SymbolType) -> Bool {
        let result: Bool
        
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
             (.u16, .u16),
             (.constU8, .constU16),
             (.constU8, .u16),
             (.u8, .constU16),
             (.u8, .u16),
             (.constPointer, .constPointer),
             (.constPointer, .pointer),
             (.pointer, .constPointer),
             (.pointer, .pointer):
            result = true
            
        case (.array(_, let a), .array(_, let b)):
            result = canValueBeTriviallyReinterpreted(b, a)
            
        default:
            result = false
        }
        
        return result
    }
    
    func rvalue(unary expr: Expression.Unary) throws -> AbstractSyntaxTreeNode {
        let childType = try typeCheck(rexpr: expr.child)
        
        let result: AbstractSyntaxTreeNode
        
        if expr.op == .ampersand {
            switch childType {
            case .function(let typ):
                let label = typ.mangledName ?? typ.name!
                let dst = nextRegister()
                result = InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLA, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: label)
                ]))
                pushRegister(dst)
            default:
                result = try lvalue(expr: expr.child)
            }
        } else {
            let childExpr = try rvalue(expr: expr.child)
            let b = popRegister()
            
            var instructions: [AbstractSyntaxTreeNode] = [childExpr]
            
            switch (childType, expr.op) {
            case (.u8, .minus):
                let a = nextRegister()
                let c = nextRegister()
                let d = nextRegister()
                pushRegister(d)
                instructions += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLI8, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: a),
                        ParameterNumber(value: 0)
                    ])),
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kSUB8, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: c),
                        ParameterIdentifier(value: a),
                        ParameterIdentifier(value: b)
                    ]))
                ]
                
            case (.u16, .minus):
                let a = nextRegister()
                let c = nextRegister()
                pushRegister(c)
                instructions += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: a),
                        ParameterNumber(value: 0)
                    ])),
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kSUB16, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: c),
                        ParameterIdentifier(value: a),
                        ParameterIdentifier(value: b)
                    ]))
                ]
                
            case (.bool, .bang):
                let a = nextRegister()
                let c = nextRegister()
                pushRegister(c)
                instructions += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kNOT, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: a),
                        ParameterIdentifier(value: b)
                    ]))
                ]
                
            case (.u8, .tilde):
                let c = nextRegister()
                let d = nextRegister()
                pushRegister(d)
                instructions += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kNEG8, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: c),
                        ParameterIdentifier(value: b)
                    ]))
                ]
                
            case (.u16, .tilde):
                let c = nextRegister()
                pushRegister(c)
                instructions += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kNEG16, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: c),
                        ParameterIdentifier(value: b)
                    ]))
                ]
                
            default:
                fatalError("`\(expr.op)' is not a prefix unary operator. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(expr)")
            }
            
            result = try compile(seq: Seq(sourceAnchor: expr.sourceAnchor, children: instructions))!
        }
        
        return result
    }
    
    func rvalue(binary: Expression.Binary) throws -> AbstractSyntaxTreeNode {
        let rightType = try typeCheck(rexpr: binary.right)
        let leftType = try typeCheck(rexpr: binary.left)
        
        if leftType.isArithmeticType && rightType.isArithmeticType {
            return try compileArithmeticBinaryExpression(binary, leftType, rightType)
        }
        
        if leftType.isBooleanType && rightType.isBooleanType {
            return try compileBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
    }
    
    func compileArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> AbstractSyntaxTreeNode {
        assert(leftType.isArithmeticType && rightType.isArithmeticType)

        if case .compTimeInt = leftType, case .compTimeInt = rightType {
            return try compileConstantArithmeticBinaryExpression(binary, leftType, rightType)
        }
        
        let typeForArithmetic: SymbolType = (max(leftType.max(), rightType.max()) > 255) ? .u16 : .u8
        let right = try compileAndConvertExpression(rexpr: binary.right, ltype: typeForArithmetic, isExplicitCast: false)
        let left = try compileAndConvertExpression(rexpr: binary.left, ltype: typeForArithmetic, isExplicitCast: false)
        
        let a = popRegister()
        let b = popRegister()
        let c = nextRegister()
        pushRegister(c)
        
        let operandIns = try getOperand(binary, leftType, rightType, typeForArithmetic)
        let op = InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: operandIns, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: c),
            ParameterIdentifier(value: a),
            ParameterIdentifier(value: b)
        ]))
        
        return try compile(seq: Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op]))!
    }
    
    func getOperand(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType, _ typeForArithmetic: SymbolType) throws -> String {
        let op: String
        switch (binary.op, typeForArithmetic) {
        case (.eq, .u8):
            op = Tack.kEQ8
        case (.eq, .u16):
            op = Tack.kEQ16
        case (.ne, .u8):
            op = Tack.kNE8
        case (.ne, .u16):
            op = Tack.kNE16
        case (.lt, .u8):
            op = Tack.kLT8
        case (.lt, .u16):
            op = Tack.kLT16
        case (.gt, .u8):
            op = Tack.kGT8
        case (.gt, .u16):
            op = Tack.kGT16
        case (.le, .u8):
            op = Tack.kLE8
        case (.le, .u16):
            op = Tack.kLE16
        case (.ge, .u8):
            op = Tack.kGE8
        case (.ge, .u16):
            op = Tack.kGE16
        case (.plus, .u8):
            op = Tack.kADD8
        case (.plus, .u16):
            op = Tack.kADD16
        case (.minus, .u8):
            op = Tack.kSUB8
        case (.minus, .u16):
            op = Tack.kSUB16
        case (.star, .u8):
            op = Tack.kMUL8
        case (.star, .u16):
            op = Tack.kMUL16
        case (.divide, .u8):
            op = Tack.kDIV8
        case (.divide, .u16):
            op = Tack.kDIV16
        case (.modulus, .u8):
            op = Tack.kMOD8
        case (.modulus, .u16):
            op = Tack.kMOD16
        case (.ampersand, .u8):
            op = Tack.kAND8
        case (.ampersand, .u16):
            op = Tack.kAND16
        case (.pipe, .u8):
            op = Tack.kOR8
        case (.pipe, .u16):
            op = Tack.kOR16
        case (.caret, .u8):
            op = Tack.kXOR8
        case (.caret, .u16):
            op = Tack.kXOR16
        case (.leftDoubleAngle, .u8):
            op = Tack.kLSL8
        case (.leftDoubleAngle, .u16):
            op = Tack.kLSL16
        case (.rightDoubleAngle, .u8):
            op = Tack.kLSR8
        case (.rightDoubleAngle, .u16):
            op = Tack.kLSR16
        default:
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        return op
    }
    
    func compileConstantArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> AbstractSyntaxTreeNode {
        guard case .compTimeInt(let a) = leftType, case .compTimeInt(let b) = rightType else {
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        
        let value: Int
        
        switch binary.op {
        case .eq:
            value = (a == b) ? 1 : 0
            
        case .ne:
            value = (a != b) ? 1 : 0
            
        case .lt:
            value = (a < b) ? 1 : 0
            
        case .gt:
            value = (a > b) ? 1 : 0
            
        case .le:
            value = (a <= b) ? 1 : 0
            
        case .ge:
            value = (a >= b) ? 1 : 0
            
        case .plus:
            value = a + b
            
        case .minus:
            value = a - b
            
        case .star:
            value = a * b
            
        case .divide:
            value = a / b
            
        case .modulus:
            value = a % b
            
        case .ampersand:
            value = a & b
            
        case .pipe:
            value = a | b
            
        case .caret:
            value = a ^ b
            
        case .leftDoubleAngle:
            value = a << b
            
        case .rightDoubleAngle:
            value = a >> b
            
        default:
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        
        let ins: String
        switch try typeCheck(rexpr: binary) {
        case .u8, .constU8:
            ins = Tack.kLI8
            
        default:
            ins = Tack.kLI16
        }
        
        let dst = nextRegister()
        pushRegister(dst)
        
        return InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: ins, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: dst),
            ParameterNumber(value: value)
        ]))
    }
    
    func compileBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> AbstractSyntaxTreeNode {
        assert(leftType.isBooleanType && rightType.isBooleanType)

        if case .compTimeBool = leftType, case .compTimeBool = rightType {
            return try compileConstantBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        switch binary.op {
        case .eq:
            let right = try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
            let left = try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false)
            let a = popRegister()
            let b = popRegister()
            let c = nextRegister()
            pushRegister(c)
            let op = InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kEQ16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: c),
                ParameterIdentifier(value: a),
                ParameterIdentifier(value: b)
            ]))
            return try compile(seq: Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op]))!
            
        case .ne:
            let right = try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
            let left = try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false)
            let a = popRegister()
            let b = popRegister()
            let c = nextRegister()
            pushRegister(c)
            let op = InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kNE16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: c),
                ParameterIdentifier(value: a),
                ParameterIdentifier(value: b)
            ]))
            return try compile(seq: Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op]))!
            
        case .doubleAmpersand:
            return try logicalAnd(binary)
            
        case .doublePipe:
            return try logicalOr(binary)
            
        default:
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
    }
    
    func compileConstantBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> AbstractSyntaxTreeNode {
        guard case .compTimeBool(let a) = leftType, case .compTimeBool(let b) = rightType else {
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        
        let value: Int
        
        switch binary.op {
        case .eq:
            value = (a == b) ? 1 : 0
            
        case .ne:
            value = (a != b) ? 1 : 0
            
        case .doubleAmpersand:
            value = (a && b) ? 1 : 0
            
        case .doublePipe:
            value = (a || b) ? 1 : 0
            
        default:
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        
        let dst = nextRegister()
        pushRegister(dst)
        
        return InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: dst),
            ParameterNumber(value: value)
        ]))
    }
    
    func logicalAnd(_ binary: Expression.Binary) throws -> AbstractSyntaxTreeNode {
        var instructions: [AbstractSyntaxTreeNode] = []
        let labelFalse = globalEnvironment.labelMaker.next()
        let labelTail = globalEnvironment.labelMaker.next()
        instructions.append(try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false))
        let a = popRegister()
        instructions += [
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kBZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: a),
                ParameterIdentifier(value: labelFalse)
            ])),
            try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
        ]
        let b = popRegister()
        let c = nextRegister()
        pushRegister(c)
        instructions += [
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kBZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: b),
                ParameterIdentifier(value: labelFalse)
            ])),
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: c),
                ParameterNumber(value: 1)
            ])),
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: labelTail)
            ])),
            LabelDeclaration(sourceAnchor: binary.sourceAnchor, identifier: labelFalse),
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: c),
                ParameterNumber(value: 0)
            ])),
            LabelDeclaration(sourceAnchor: binary.sourceAnchor, identifier: labelTail)
        ]
        return try compile(seq: Seq(sourceAnchor: binary.sourceAnchor, children: instructions))!
    }
    
    func logicalOr(_ binary: Expression.Binary) throws -> AbstractSyntaxTreeNode {
        var instructions: [AbstractSyntaxTreeNode] = []
        let labelTrue = globalEnvironment.labelMaker.next()
        let labelTail = globalEnvironment.labelMaker.next()
        instructions.append(try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false))
        let a = popRegister()
        instructions += [
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kBNZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: a),
                ParameterIdentifier(value: labelTrue)
            ])),
            try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
        ]
        let b = popRegister()
        let c = nextRegister()
        pushRegister(c)
        instructions += [
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kBNZ, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: b),
                ParameterIdentifier(value: labelTrue)
            ])),
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: c),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: labelTail)
            ])),
            LabelDeclaration(sourceAnchor: binary.sourceAnchor, identifier: labelTrue),
            InstructionNode(sourceAnchor: binary.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: c),
                ParameterNumber(value: 1)
            ])),
            LabelDeclaration(sourceAnchor: binary.sourceAnchor, identifier: labelTail)
        ]
        return try compile(seq: Seq(sourceAnchor: binary.sourceAnchor, children: instructions))!
    }
    
    func rvalue(is expr: Expression.Is) throws -> AbstractSyntaxTreeNode {
        let exprType = try typeCheck(rexpr: expr)
        
        switch exprType {
        case .compTimeBool(let val):
            let tempResult = nextRegister()
            let result = InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: tempResult),
                ParameterNumber(value: val ? 1 : 0)
            ]))
            pushRegister(tempResult)
            return result
            
        default:
            switch try typeCheck(rexpr: expr.expr) {
            case .unionType(let typ):
                return try compileUnionTypeIs(expr, typ)
                
            default:
                fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(expr)")
            }
        }
    }
    
    func compileUnionTypeIs(_ expr: Expression.Is, _ typ: UnionType) throws -> AbstractSyntaxTreeNode {
        var children: [AbstractSyntaxTreeNode] = []
        
        // Take the test type and determine the corresponding type tag.
        let testType = try typeCheck(rexpr: expr.testType)
        let typeTag: Int! = determineUnionTypeTag(typ, testType)
        let tempTestTag = nextRegister()
        children += [
            InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: tempTestTag),
                ParameterNumber(value: typeTag)
            ]))
        ]
        
        // Get the address of the union in memory.
        children += [
            try lvalue(expr: expr.expr)
        ]
        let tempUnionAddr = popRegister()
        
        // Read the union type tag in memory.
        let tempActualTag = nextRegister()
        children += [
            InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: tempActualTag),
                ParameterIdentifier(value: tempUnionAddr)
            ]))
        ]
        
        // Compare the union's actual type tag against the tag of the test type.
        let tempResult = nextRegister()
        children += [
            InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kEQ16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: tempResult),
                ParameterIdentifier(value: tempActualTag),
                ParameterIdentifier(value: tempTestTag)
            ]))
        ]
        
        pushRegister(tempResult)
        
        return try compile(seq: Seq(sourceAnchor: expr.sourceAnchor, children: children))!
    }
    
    // Given a type and a related union, determine the corresponding type tag.
    // Return nil if the type does not match the union after all.
    func determineUnionTypeTag(_ typ: UnionType, _ testType: SymbolType) -> Int? {
        for i in 0..<typ.members.count {
            let member = typ.members[i]
            if testType == member || testType.correspondingConstType == member {
                return i
            }
        }
        return nil
    }
}
