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
    public static let kCALL    = "TACK_CALL"
    public static let kENTER   = "TACK_ENTER"
    public static let kLEAVE   = "TACK_LEAVE"
    public static let kRET     = "TACK_RET"
    public static let kJMP     = "TACK_JMP"
    public static let kNOT     = "TACK_NOT"
    public static let kLA      = "TACK_LA"
    public static let kBZ      = "TACK_BZ"
    public static let kBNZ     = "TACK_BNZ"
    public static let kLOAD    = "TACK_LOAD"
    public static let kSTORE   = "TACK_STORE"
    public static let kMEMCPY  = "TACK_MEMCPY"
    
    public static let kANDI16  = "TACK_ANDI16"
    public static let kADDI16  = "TACK_ADDI16"
    public static let kSUBI16  = "TACK_SUBI16"
    public static let kMULI16  = "TACK_MULI16"
    
    public static let kLI16    = "TACK_LI16"
    public static let kLIU16   = "TACK_LIU16"
    public static let kCMP16   = "TACK_CMP16"
    public static let kAND16   = "TACK_AND16"
    public static let kOR16    = "TACK_OR16"
    public static let kXOR16   = "TACK_XOR16"
    public static let kNEG16   = "TACK_NEG16"
    public static let kADD16   = "TACK_ADD16"
    public static let kSUB16   = "TACK_SUB16"
    public static let kMUL16   = "TACK_MUL16"
    public static let kDIV16   = "TACK_DIV16"
    public static let kMOD16   = "TACK_MOD16"
    public static let kLSL16   = "TACK_LSL16"
    public static let kLSR16   = "TACK_LSR16"
    public static let kEQ16    = "TACK_EQ16"
    public static let kNE16    = "TACK_NE16"
    public static let kLT16    = "TACK_LT16"
    public static let kGE16    = "TACK_GE16"
    public static let kLE16    = "TACK_LE16"
    public static let kGT16    = "TACK_GT16"
    
    public static let kLI8     = "TACK_LI8"
    public static let kCMP8    = "TACK_CMP8"
    public static let kAND8    = "TACK_AND8"
    public static let kOR8     = "TACK_OR8"
    public static let kXOR8    = "TACK_XOR8"
    public static let kNEG8    = "TACK_NEG8"
    public static let kADD8    = "TACK_ADD8"
    public static let kSUB8    = "TACK_SUB8"
    public static let kMUL8    = "TACK_MUL8"
    public static let kDIV8    = "TACK_DIV8"
    public static let kMOD8    = "TACK_MOD8"
    public static let kLSL8    = "TACK_LSL8"
    public static let kLSR8    = "TACK_LSR8"
    public static let kEQ8     = "TACK_EQ8"
    public static let kNE8     = "TACK_NE8"
    public static let kLT8     = "TACK_LT8"
    public static let kGE8     = "TACK_GE8"
    public static let kLE8     = "TACK_LE8"
    public static let kGT8     = "TACK_GT8"
}

public class SnapToTackCompiler: SnapASTTransformerBase {
    public let globalEnvironment: GlobalEnvironment
    public internal(set) var registerStack: [String] = []
    var nextRegisterIndex = 0
    let fp = "fp"
    let sp = "sp"
    let kUnionPayloadOffset: Int
    let kUnionTypeTagOffset: Int
    
    func pushRegister(_ identifier: String) {
        registerStack.append(identifier)
    }
    
    func popRegister() -> String {
        assert(!registerStack.isEmpty)
        return registerStack.removeLast()
    }
    
    func peekRegister() -> String {
        assert(!registerStack.isEmpty)
        return registerStack.last!
    }
    
    func nextRegister() -> String {
        let result = "vr\(nextRegisterIndex)"
        nextRegisterIndex += 1
        return result
    }
    
    public init(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        kUnionTypeTagOffset = 0
        kUnionPayloadOffset = globalEnvironment.memoryLayoutStrategy.sizeof(type: .u16)
        super.init(symbols)
    }
    
    public override func compile(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        return flatten(try super.compile(node0))
    }
    
    func flatten(_ node: AbstractSyntaxTreeNode?) -> AbstractSyntaxTreeNode {
        return try! SnapASTTransformerFlattenSeq().compile(node)!
    }
    
    public override func compile(block node: Block) throws -> AbstractSyntaxTreeNode? {
        let block = try super.compile(block: node) as! Block
        return Seq(sourceAnchor: node.sourceAnchor, children: block.children)
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
            try compile(node.body)!,
            LabelDeclaration(sourceAnchor: node.sourceAnchor, identifier: labelTail),
        ]
        
        return Seq(sourceAnchor: node.sourceAnchor, children: children)
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
        let savedRegisterStack = registerStack
        let result = try rvalue(expr: node)
        registerStack = savedRegisterStack
        return result
    }
    
    @discardableResult func typeCheck(rexpr: Expression) throws -> SymbolType {
        return try RvalueExpressionTypeChecker(symbols: symbols!).check(expression: rexpr)
    }
    
    @discardableResult func typeCheck(lexpr: Expression) throws -> SymbolType? {
        return try LvalueExpressionTypeChecker(symbols: symbols!).check(expression: lexpr)
    }
    
    public func lvalue(expr: Expression) throws -> AbstractSyntaxTreeNode {
        try typeCheck(lexpr: expr)
        let result: AbstractSyntaxTreeNode
        switch expr {
        case let node as Expression.Identifier:
            result = try lvalue(identifier: node)
        case let node as Expression.Subscript:
            result = try lvalue(subscript: node)
        case let node as Expression.Get:
            result = try lvalue(get: node)
        default:
            fatalError("unimplemented")
        }
        return flatten(result)
    }
    
    func lvalue(identifier node: Expression.Identifier) throws -> AbstractSyntaxTreeNode {
        let resolution = try symbols!.resolveWithStackFrameDepth(sourceAnchor: node.sourceAnchor, identifier: node.identifier)
        let symbol = resolution.0
        let depth = symbols!.stackFrameIndex - resolution.1
        assert(depth >= 0)
        let result = computeAddressOfSymbol(sourceAnchor: node.sourceAnchor, symbol: symbol, depth: depth)
        return try compile(result)!
    }
    
    func lvalue(subscript expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        let elementType = try typeCheck(rexpr: expr)
        let elementSize = globalEnvironment.memoryLayoutStrategy.sizeof(type: elementType)
        
        var children: [AbstractSyntaxTreeNode] = [
            try lvalue(expr: expr.subscriptable)
        ]
        
        switch elementSize {
        case 0:
            break
            
        case 1:
            let baseAddr = popRegister()
            children += [
                try rvalue(expr: expr.argument)
            ]
            let index = popRegister()
            let accessAddr = nextRegister()
            pushRegister(accessAddr)
            children += [
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kADD16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: accessAddr),
                    ParameterIdentifier(value: index),
                    ParameterIdentifier(value: baseAddr)
                ]))
            ]
            
        default:
            let baseAddr = popRegister()
            children += [
                try rvalue(expr: expr.argument)
            ]
            let index = popRegister()
            let offset = nextRegister()
            let accessAddr = nextRegister()
            pushRegister(accessAddr)
            children += [
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kMULI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: offset),
                    ParameterIdentifier(value: index),
                    ParameterNumber(value: elementSize)
                ])),
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kADD16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: accessAddr),
                    ParameterIdentifier(value: offset),
                    ParameterIdentifier(value: baseAddr)
                ]))
            ]
        }
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
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
                InstructionNode(sourceAnchor: sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp_framePointer),
                    ParameterIdentifier(value: fp)
                ]))
            ]
            
            // Follow the frame pointer `depth' times.
            for _ in 1..<depth {
                children += [
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
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
    
    func lvalue(get expr: Expression.Get) throws -> AbstractSyntaxTreeNode {
        let name = expr.member.identifier
        let resultType = try typeCheck(lexpr: expr.expr)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        switch resultType {
        case .constStructType(let typ), .structType(let typ):
            let symbol = try typ.symbols.resolve(identifier: name)
            
            children += [
                try lvalue(expr: expr.expr)
            ]
            let tempStructAddress = popRegister()
            let dst = nextRegister()
            pushRegister(dst)
            children += [
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kADDI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: tempStructAddress),
                    ParameterNumber(value: symbol.offset)
                ]))
            ]
            
        case .constPointer(let typ), .pointer(let typ):
            if name == "pointee" {
                children += [
                    try rvalue(expr: expr.expr)
                ]
            } else {
                switch typ {
                case .constStructType(let b), .structType(let b):
                    let symbol = try b.symbols.resolve(identifier: name)
                    
                    children += [
                        try rvalue(expr: expr.expr)
                    ]
                    let tempStructAddress = popRegister()
                    let dst = nextRegister()
                    pushRegister(dst)
                    children += [
                        InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kADDI16, parameters: ParameterList(parameters: [
                            ParameterIdentifier(value: dst),
                            ParameterIdentifier(value: tempStructAddress),
                            ParameterNumber(value: symbol.offset)
                        ]))
                    ]
                    
                default:
                    fatalError("unimplemented")
                }
            }
        
        default:
            fatalError("unimplemented")
        }
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    public func rvalue(expr: Expression) throws -> AbstractSyntaxTreeNode {
        try typeCheck(rexpr: expr)
        let result: AbstractSyntaxTreeNode
        switch expr {
        case let group as Expression.Group:
            result = try rvalue(expr: group.expression)
        case let literal as Expression.LiteralInt:
            result = rvalue(literalInt: literal)
        case let literal as Expression.LiteralBool:
            result = rvalue(literalBoolean: literal)
        case let literal as Expression.LiteralArray:
            result = try rvalue(literalArray: literal)
        case let literal as Expression.LiteralString:
            result = try rvalue(literalString: literal)
        case let node as Expression.Identifier:
            result = try rvalue(identifier: node)
        case let node as Expression.As:
            result = try rvalue(as: node)
        case let node as Expression.Bitcast:
            result = try rvalue(bitcast: node)
        case let node as Expression.Unary:
            result = try rvalue(unary: node)
        case let node as Expression.Binary:
            result = try rvalue(binary: node)
        case let expr as Expression.Is:
            result = try rvalue(is: expr)
        case let expr as Expression.Assignment:
            result = try rvalue(assignment: expr)
        case let expr as Expression.Subscript:
            result = try rvalue(subscript: expr)
        case let expr as Expression.Get:
            result = try rvalue(get: expr)
        case let node as Expression.StructInitializer:
            result = try rvalue(structInitializer: node)
        case let node as Expression.Call:
            result = try rvalue(call: node)
        default:
            throw CompilerError(message: "unimplemented: `\(expr)'")
        }
        return flatten(result)
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
    
    func rvalue(literalArray expr: Expression.LiteralArray) throws -> AbstractSyntaxTreeNode {
        let savedRegisterStack = registerStack
        let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, expr.arrayType)
        var children: [AbstractSyntaxTreeNode] = []
        for i in 0..<expr.elements.count {
            let slot = Expression.Subscript(sourceAnchor: expr.sourceAnchor,
                                            subscriptable: tempArrayId,
                                            argument: Expression.LiteralInt(i))
            let child =  try rvalue(expr: Expression.Assignment(sourceAnchor: expr.sourceAnchor,
                                                                lexpr: slot,
                                                                rexpr: expr.elements[i]))
            children.append(child)
        }
        registerStack = savedRegisterStack
        children += [
            try lvalue(identifier: tempArrayId)
        ]
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    func makeCompilerTemporary(_ sourceAnchor: SourceAnchor?, _ type: Expression) throws -> Expression.Identifier {
        let tempArrayId = Expression.Identifier(sourceAnchor: sourceAnchor, identifier: globalEnvironment.tempNameMaker.next())
        let tempDecl = VarDeclaration(sourceAnchor: sourceAnchor,
                                      identifier: tempArrayId,
                                      explicitType: type,
                                      expression: nil,
                                      storage: .automaticStorage,
                                      isMutable: true,
                                      visibility: .privateVisibility)
        let varDeclCompiler = SnapSubcompilerVarDeclaration(symbols: symbols!, globalEnvironment: globalEnvironment)
        let _ = try varDeclCompiler.compile(tempDecl)
        return tempArrayId
    }
    
    func rvalue(literalString expr: Expression.LiteralString) throws -> AbstractSyntaxTreeNode {
        let arrayType = Expression.ArrayType(sourceAnchor: expr.sourceAnchor,
                                             count: Expression.LiteralInt(expr.value.count),
                                             elementType: Expression.PrimitiveType(.u8))
        let elements = expr.value.utf8.map { Expression.LiteralInt(sourceAnchor: expr.sourceAnchor, value: Int($0)) }
        return try rvalue(literalArray: Expression.LiteralArray(sourceAnchor: expr.sourceAnchor,
                                                                arrayType: arrayType,
                                                                elements: elements))
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
            children += [
                InstructionNode(sourceAnchor: node.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dest),
                    ParameterIdentifier(value: addr),
                ]))
            ]
        }
        
        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    func rvalue(as expr: Expression.As) throws -> AbstractSyntaxTreeNode {
        let targetType = try typeCheck(rexpr: expr.targetType)
        return try compileAndConvertExpression(rexpr: expr.expr, ltype: targetType, isExplicitCast: true)
    }
    
    func rvalue(bitcast expr: Expression.Bitcast) throws -> AbstractSyntaxTreeNode {
        return try rvalue(expr: expr.expr)
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
            result = InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLI8, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: dst),
                ParameterNumber(value: a)
            ]))
            
        case (.compTimeInt(let a), .u16),
             (.compTimeInt(let a), .constU16):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister()
            pushRegister(dst)
            result = InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: dst),
                ParameterNumber(value: a)
            ]))
            
        case (.compTimeBool(let a), .bool),
             (.compTimeBool(let a), .constBool):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister()
            pushRegister(dst)
            result = InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLI16, parameters: ParameterList(parameters: [
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
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (.array(let n, _), .array(let m, let b)):
            guard n == m || m == nil, let n = n else {
                fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
            }
            let savedRegisterStack = registerStack
            let tempArrayId = try makeCompilerTemporary(rexpr.sourceAnchor, Expression.PrimitiveType(ltype))
            var children: [AbstractSyntaxTreeNode] = []
            for i in 0..<n {
                children += [
                    try rvalue(expr: Expression.Assignment(
                        sourceAnchor: rexpr.sourceAnchor,
                        lexpr: Expression.Subscript(sourceAnchor: rexpr.sourceAnchor,
                                                    subscriptable: tempArrayId,
                                                    argument: Expression.LiteralInt(i)),
                        rexpr: Expression.As(sourceAnchor: rexpr.sourceAnchor,
                                             expr: Expression.Subscript(sourceAnchor: rexpr.sourceAnchor,
                                                                        subscriptable: rexpr,
                                                                        argument: Expression.LiteralInt(i)),
                                             targetType: Expression.PrimitiveType(b))))
                ]
            }
            registerStack = savedRegisterStack
            children += [
                try lvalue(identifier: tempArrayId)
            ]
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (.array(let n?, let a), .constDynamicArray(let b)),
             (.array(let n?, let a), .dynamicArray(let b)):
            assert(canValueBeTriviallyReinterpreted(b, a))
            let tempArrayId = try makeCompilerTemporary(rexpr.sourceAnchor, Expression.PrimitiveType(ltype))
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(expr: tempArrayId)
            ]
            let savedRegisterStack = registerStack
            let dst = popRegister()
            children += [
                try lvalue(expr: rexpr),
                InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kSTORE, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: popRegister()),
                    ParameterNumber(value: 0),
                ]))
            ]
            let countReg = nextRegister()
            let countOffset = globalEnvironment.memoryLayoutStrategy.sizeof(type: .u16)
            children += [
                InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: countReg),
                    ParameterNumber(value: n),
                ])),
                InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kSTORE, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: countReg),
                    ParameterNumber(value: countOffset),
                ]))
            ]
            registerStack = savedRegisterStack
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (_, .unionType(let typ)):
            let tempArrayId = try makeCompilerTemporary(rexpr.sourceAnchor, Expression.PrimitiveType(ltype))
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(expr: tempArrayId)
            ]
            let tempUnionAddr = popRegister()
            let tempUnionTypeTag = nextRegister()
            let unionTypeTag = determineUnionTypeTag(typ, rtype)!
            children += [
                InstructionNode(instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: tempUnionTypeTag),
                    ParameterNumber(value: unionTypeTag)
                ])),
                InstructionNode(instruction: Tack.kSTORE, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: tempUnionAddr),
                    ParameterIdentifier(value: tempUnionTypeTag),
                    ParameterNumber(value: kUnionTypeTagOffset)
                ]))
            ]
            if rtype.isPrimitive {
                children += [
                    try rvalue(expr: rexpr),
                    InstructionNode(instruction: Tack.kSTORE, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: tempUnionAddr),
                        ParameterIdentifier(value: popRegister()),
                        ParameterNumber(value: kUnionPayloadOffset)
                    ]))
                ]
            } else {
                let size = globalEnvironment.memoryLayoutStrategy.sizeof(type: rtype)
                let tempUnionPayloadAddress = nextRegister()
                children += [
                    InstructionNode(instruction: Tack.kADDI16, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: tempUnionPayloadAddress),
                        ParameterIdentifier(value: tempUnionAddr),
                        ParameterNumber(value: kUnionPayloadOffset)
                    ])),
                    try rvalue(expr: rexpr),
                    InstructionNode(instruction: Tack.kMEMCPY, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: tempUnionPayloadAddress),
                        ParameterIdentifier(value: popRegister()),
                        ParameterNumber(value: size)
                    ]))
                ]
            }
            pushRegister(tempUnionAddr)
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (.unionType, _):
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(expr: rexpr)
            ]
            let tempUnionAddr = popRegister()
            let dst = nextRegister()
            pushRegister(dst)
            if ltype.isPrimitive {
                children += [
                    InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: dst),
                        ParameterIdentifier(value: tempUnionAddr),
                        ParameterNumber(value: kUnionPayloadOffset),
                    ]))
                ]
            } else {
                children += [
                    InstructionNode(sourceAnchor: rexpr.sourceAnchor, instruction: Tack.kADDI16, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: dst),
                        ParameterIdentifier(value: tempUnionAddr),
                        ParameterNumber(value: kUnionPayloadOffset),
                    ]))
                ]
            }
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (.traitType(let a), .traitType(let b)):
            fatalError("unimplemented: trait(\(a)) -> trait(\(b))")
            
        default:
            fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
        }
        
        return result
    }
    
    func canValueBeTriviallyReinterpreted(_ ltype: SymbolType, _ rtype: SymbolType) -> Bool {
        // The type checker has already verified that the conversion is legal.
        // The SnapToTackCompiler class must only determine how to implement it.
        // So conversions from one array type to another are assumed to be fine
        // we only need determine whether the in-memory representations of
        // elements can be trivially reinterpreted as the new type. This is the
        // case for conversions to and from "const" for example.
        // Same thing for conversions of pointers and dynamic array types.
        
        if ltype == rtype {
            return true
        }
        
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
             (.pointer, .pointer),
             (.constDynamicArray, .constDynamicArray),
             (.constDynamicArray, .dynamicArray),
             (.dynamicArray, .constDynamicArray),
             (.dynamicArray, .dynamicArray),
             (.unionType, .unionType):
            result = true
            
        case (.array(_, let a), .array(_, let b)):
            // When implmenting a conversion between array types, it might be
            // possible to trivially reinterpret the bits in the new type.
            // It might also be the case that we need to emit code to convert
            // each element.
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
            
            result = Seq(sourceAnchor: expr.sourceAnchor, children: instructions)
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
        
        return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])
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
            return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])
            
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
            return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])
            
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
        return Seq(sourceAnchor: binary.sourceAnchor, children: instructions)
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
        return Seq(sourceAnchor: binary.sourceAnchor, children: instructions)
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
            InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
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
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
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
    
    func rvalue(assignment expr: Expression.Assignment) throws -> AbstractSyntaxTreeNode {
        guard let ltype = try LvalueExpressionTypeChecker(symbols: symbols!).check(expression: expr.lexpr) else {
            throw CompilerError(sourceAnchor: expr.lexpr.sourceAnchor,
                                message: "lvalue required in assignment")
        }
        
        guard false==ltype.isConst || (expr is Expression.InitialAssignment) else {
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(expr)")
        }
        
        let size = globalEnvironment.memoryLayoutStrategy.sizeof(type: ltype)
        let result: Seq
        
        if ltype.isPrimitive {
            let lvalueProc = try lvalue(expr: expr.lexpr)
            let dst = popRegister()
            let rvalueProc = try compileAndConvertExpression(rexpr: expr.rexpr, ltype: ltype, isExplicitCast: false)
            let src = peekRegister()
            
            result = Seq(sourceAnchor: expr.sourceAnchor, children: [
                lvalueProc,
                rvalueProc,
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kSTORE, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: src)
                ]))
            ])
        } else if size == 0 {
            result = Seq(sourceAnchor: expr.sourceAnchor, children: [
                try lvalue(expr: expr.lexpr)
            ])
        } else if let structInitializer = expr.rexpr as? Expression.StructInitializer {
            let children = structInitializer.arguments.map {
                Expression.Assignment(sourceAnchor: expr.rexpr.sourceAnchor,
                                      lexpr: Expression.Get(sourceAnchor: expr.rexpr.sourceAnchor,
                                                            expr: expr.lexpr,
                                                            member: Expression.Identifier($0.name)),
                                      rexpr: $0.expr)
            }
            result = Seq(sourceAnchor: expr.sourceAnchor, children: children)
        } else {
            let lvalueProc = try lvalue(expr: expr.lexpr)
            let dst = popRegister()
            let rvalueProc = try compileAndConvertExpression(rexpr: expr.rexpr, ltype: ltype, isExplicitCast: false)
            let src = peekRegister()
            
            result = Seq(sourceAnchor: expr.sourceAnchor, children: [
                lvalueProc,
                rvalueProc,
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kMEMCPY, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: src),
                    ParameterNumber(value: size)
                ]))
            ])
        }
        
        return result
    }
    
    func rvalue(subscript expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        let elementType = try typeCheck(rexpr: expr)
        let argumentType = try typeCheck(rexpr: expr.argument)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        if case .compTimeInt(let index) = argumentType, elementType.isPrimitive {
            children += [
                try lvalue(expr: expr.subscriptable)
            ]
            let baseAddr = popRegister()
            let dst = nextRegister()
            pushRegister(dst)
            children += [
                InstructionNode(instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: dst),
                    ParameterIdentifier(value: baseAddr),
                    ParameterNumber(value: index)
                ]))
            ]
        } else {
            children += [
                try lvalue(expr: expr)
            ]
            
            if elementType.isPrimitive {
                let addr = popRegister()
                let dest = nextRegister()
                pushRegister(dest)
                children += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: dest),
                        ParameterIdentifier(value: addr),
                    ]))
                ]
            }
        }
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    func rvalue(get expr: Expression.Get) throws -> AbstractSyntaxTreeNode {
        let name = expr.member.identifier
        let resultType = try typeCheck(rexpr: expr.expr)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        switch resultType {
        case .array(count: let count, elementType: _):
            assert(name == "count")
            let countReg = nextRegister()
            pushRegister(countReg)
            children += [
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: countReg),
                    ParameterNumber(value: count!)
                ]))
            ]
            
        case .constDynamicArray, .dynamicArray:
            assert(name == "count")
            children += [
                try rvalue(expr: expr.expr)
            ]
            let sliceAddr = popRegister()
            let countReg = nextRegister()
            pushRegister(countReg)
            let countOffset = globalEnvironment.memoryLayoutStrategy.sizeof(type: .u16)
            children += [
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: countReg),
                    ParameterIdentifier(value: sliceAddr),
                    ParameterNumber(value: countOffset)
                ]))
            ]
        
        case .constStructType(let typ), .structType(let typ):
            let symbol = try typ.symbols.resolve(identifier: name)
            
            if symbol.type.isPrimitive {
                // Read the field in-place
                children += [
                    try lvalue(expr: expr.expr)
                ]
                let tempStructAddress = popRegister()
                let dst = nextRegister()
                pushRegister(dst)
                children += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: dst),
                        ParameterIdentifier(value: tempStructAddress),
                        ParameterNumber(value: symbol.offset)
                    ]))
                ]
            } else {
                children += [
                    try lvalue(expr: expr)
                ]
            }
            
        case .constPointer(let typ), .pointer(let typ):
            if name == "pointee" {
                children += [
                    try rvalue(expr: expr.expr)
                ]
                
                // If the pointee is a primitive then load it into a register.
                // Else, the expression value is the value of the pointer, which
                // is the same as the pointee's lvalue.
                if typ.isPrimitive {
                    let pointerValue = popRegister()
                    let pointeeValue = nextRegister()
                    pushRegister(pointeeValue)
                    children += [
                        InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                            ParameterIdentifier(value: pointeeValue),
                            ParameterIdentifier(value: pointerValue)
                        ]))
                    ]
                }
            } else {
                switch typ {
                case .array(count: let count, elementType: _):
                    assert(name == "count")
                    let countReg = nextRegister()
                    pushRegister(countReg)
                    children += [
                        InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLIU16, parameters: ParameterList(parameters: [
                            ParameterIdentifier(value: countReg),
                            ParameterNumber(value: count!)
                        ]))
                    ]
                    
                case .constDynamicArray, .dynamicArray:
                    assert(name == "count")
                    children += [
                        try rvalue(expr: expr.expr)
                    ]
                    let sliceAddr = popRegister()
                    let countReg = nextRegister()
                    pushRegister(countReg)
                    let countOffset = globalEnvironment.memoryLayoutStrategy.sizeof(type: .u16)
                    children += [
                        InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                            ParameterIdentifier(value: countReg),
                            ParameterIdentifier(value: sliceAddr),
                            ParameterNumber(value: countOffset)
                        ]))
                    ]
                    
                case .constStructType(let b), .structType(let b):
                    let symbol = try b.symbols.resolve(identifier: name)
                    
                    if symbol.type.isPrimitive {
                        // If the field is a primitive then load into a register
                        children += [
                            try lvalue(expr: expr.expr)
                        ]
                        let structAddr = popRegister()
                        let fieldAddr = nextRegister()
                        let dst = nextRegister()
                        pushRegister(dst)
                        children += [
                            InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                                ParameterIdentifier(value: fieldAddr),
                                ParameterIdentifier(value: structAddr)
                            ])),
                            InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kLOAD, parameters: ParameterList(parameters: [
                                ParameterIdentifier(value: dst),
                                ParameterIdentifier(value: fieldAddr),
                                ParameterNumber(value: symbol.offset)
                            ]))
                        ]
                    } else {
                        children += [
                            try lvalue(expr: expr)
                        ]
                    }
                    
                default:
                    fatalError("unimplemented")
                }
            }
        
        default:
            fatalError("unimplemented")
        }
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    func rvalue(structInitializer expr: Expression.StructInitializer) throws -> AbstractSyntaxTreeNode {
        let resultType = try typeCheck(rexpr: expr)
        let savedRegisterStack = registerStack
        let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, Expression.PrimitiveType(resultType))
        var children: [AbstractSyntaxTreeNode] = []
        for arg in expr.arguments {
            let slot = Expression.Get(sourceAnchor: expr.sourceAnchor,
                                      expr: tempArrayId,
                                      member: Expression.Identifier(arg.name))
            let child =  try rvalue(expr: Expression.Assignment(sourceAnchor: expr.sourceAnchor,
                                                                lexpr: slot,
                                                                rexpr: arg.expr))
            children.append(child)
        }
        registerStack = savedRegisterStack
        children += [
            try lvalue(identifier: tempArrayId)
        ]
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    func rvalue(call expr: Expression.Call) throws -> AbstractSyntaxTreeNode {
        let calleeType = try typeCheck(rexpr: expr.callee)
        
        switch calleeType {
        case .function(let typ), .pointer(.function(let typ)), .constPointer(.function(let typ)):
            return try rvalue(call: expr, typ: typ)
            
        default:
            fatalError("cannot call value of non-function type `\(calleeType)'")
        }
    }
    
    func rvalue(call expr: Expression.Call, typ: FunctionType) throws -> AbstractSyntaxTreeNode {
        if typ.name == "hlt" {
           return InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: kHLT)
        }
        
        // Allocate a temporary to hold the function call return value.
        var tempRetId: Expression.Identifier! = nil
        if typ.returnType != .void {
            tempRetId = try makeCompilerTemporary(expr.sourceAnchor, Expression.PrimitiveType(typ.returnType))
        }
        
        let parent = symbols
        let innerBlock = SymbolTable(parent: parent)
        symbols = innerBlock
        
        var children: [AbstractSyntaxTreeNode] = []
        
        // Allocate temporaries for each argument to the function call.
        // Evaluation of argument expressions may involve allocating memory on
        // the stack so we evaluate first and then copy into the argument pack.
        var tempArgIds: [Expression.Identifier] = []
        for i in 0..<typ.arguments.count {
            let tempArgId = Expression.Identifier(sourceAnchor: expr.sourceAnchor, identifier: globalEnvironment.tempNameMaker.next())
            let tempDecl = VarDeclaration(sourceAnchor: expr.sourceAnchor,
                                          identifier: tempArgId,
                                          explicitType: Expression.PrimitiveType(typ.arguments[i]),
                                          expression: expr.arguments[i],
                                          storage: .automaticStorage,
                                          isMutable: false,
                                          visibility: .privateVisibility)
            let varDeclCompiler = SnapSubcompilerVarDeclaration(symbols: symbols!, globalEnvironment: globalEnvironment)
            let assignmentExpr = try varDeclCompiler.compile(tempDecl)!
            let argProc = try compile(assignmentExpr)!
            children.append(argProc)
            tempArgIds.append(tempArgId)
        }
        
        // Allocate storage on the stack for the return value.
        let returnTypeSize = globalEnvironment.memoryLayoutStrategy.sizeof(type: typ.returnType)
        if returnTypeSize > 0 {
            children += [
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kSUBI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: sp),
                    ParameterIdentifier(value: sp),
                    ParameterNumber(value: returnTypeSize)
                ]))
            ]
        }
        
        // Allocate stack space for another argument and copy in the argument.
        for i in 0..<typ.arguments.count {
            let tempArgId = tempArgIds[i]
            let argType = typ.arguments[i]
            let argTypeSize = globalEnvironment.memoryLayoutStrategy.sizeof(type: argType)
            if argTypeSize > 0 {
                children += [
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kSUBI16, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: sp),
                        ParameterIdentifier(value: sp),
                        ParameterNumber(value: argTypeSize)
                    ])),
                    try lvalue(identifier: tempArgId),
                    InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kMEMCPY, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: sp),
                        ParameterIdentifier(value: popRegister()),
                        ParameterNumber(value: argTypeSize)
                    ]))
                ]
            }
        }
        
        // Make the function call.
        children += [
            InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kCALL, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: typ.mangledName!)
            ]))
        ]
        
        // Free up stack storage allocated for arguments.
        let argPackSize = typ.arguments.reduce(0) { (result, type) in
            result + globalEnvironment.memoryLayoutStrategy.sizeof(type: type)
        }
        if argPackSize > 0 {
            children += [
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kADDI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: sp),
                    ParameterIdentifier(value: sp),
                    ParameterNumber(value: argPackSize)
                ]))
            ]
        }
        
        // Copy the function call return value to the compiler temporary we
        // allocated earlier. Free stack storage allocated earlier.
        if returnTypeSize > 0 {
            children += [
                try lvalue(identifier: tempRetId!),
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kMEMCPY, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: popRegister()),
                    ParameterIdentifier(value: sp),
                    ParameterNumber(value: returnTypeSize)
                ])),
                InstructionNode(sourceAnchor: expr.sourceAnchor, instruction: Tack.kADDI16, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: sp),
                    ParameterIdentifier(value: sp),
                    ParameterNumber(value: returnTypeSize)
                ]))
            ]
        }
        
        let innerSeq = Seq(sourceAnchor: expr.sourceAnchor, children: children)
        
        symbols = parent
        if let symbols = symbols, innerBlock.stackFrameIndex == symbols.stackFrameIndex {
            symbols.highwaterMark = max(symbols.highwaterMark, innerBlock.highwaterMark)
        }
        
        // If the function call evaluates to a non-void value then get the
        // rvalue of the compiler temporary so we can chain that value into the
        // next expression.
        let outerSeq: Seq
        if typ.returnType != .void {
            outerSeq = Seq(sourceAnchor: expr.sourceAnchor, children: [
                innerSeq,
                try rvalue(identifier: tempRetId!)
            ])
        } else {
            outerSeq = Seq(sourceAnchor: expr.sourceAnchor, children: [
                innerSeq
            ])
        }
        return outerSeq
    }
}
