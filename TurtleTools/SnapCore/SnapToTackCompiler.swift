//
//  SnapToTackCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import Turtle16SimulatorCore

public class SnapToTackCompiler: SnapASTTransformerBase {
    public let globalEnvironment: GlobalEnvironment
    public internal(set) var registerStack: [String] = []
    var nextRegisterIndex = 0
    let fp = "fp"
    let kPanic = "panic"
    let kUnionPayloadOffset: Int
    let kUnionTypeTagOffset: Int
    let kSliceBaseAddrOffset: Int
    let kSliceCountOffset: Int
    
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
        kSliceBaseAddrOffset = 0
        kSliceCountOffset = globalEnvironment.memoryLayoutStrategy.sizeof(type: .pointer(.void))
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
            TackInstructionNode(instruction: .leave),
            TackInstructionNode(instruction: .ret)
        ])
    }
    
    public override func compile(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let sizeOfLocalVariables = node.symbols.highwaterMark
        
        let mangledName = (try TypeContextTypeChecker(symbols: symbols!).check(expression: node.functionType).unwrapFunctionType()).mangledName!
        let labelHead = mangledName
        let labelTail = "__\(mangledName)_tail"
        
        var children: [AbstractSyntaxTreeNode] = []
        
        children += [
            TackInstructionNode(instruction: .jmp, parameters: [
                ParameterIdentifier(labelTail)
            ]),
            LabelDeclaration(identifier: labelHead),
            TackInstructionNode(instruction: .enter, parameters: [
                ParameterNumber(sizeOfLocalVariables)
            ]),
            try compile(node.body)!,
            LabelDeclaration(identifier: labelTail),
        ]
        
        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    public override func compile(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        return TackInstructionNode(instruction: .jmp, parameters: [ParameterIdentifier(node.target)])
    }
    
    public override func compile(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            try rvalue(expr: node.condition),
            TackInstructionNode(instruction: .bz, parameters: [
                ParameterIdentifier(popRegister()),
                ParameterIdentifier("foo")
            ])
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
        guard try typeCheck(lexpr: expr) != nil else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "lvalue required")
        }
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
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        let argumentType = try typeCheck(rexpr: expr.argument)
        
        // Can we determine the index at compile time?
        let maybeStaticIndex: Int?
        if case .compTimeInt(let index) = argumentType {
            maybeStaticIndex = index
        } else {
            maybeStaticIndex = nil
        }
        
        // Can we determine the upper bound at compile time?
        let maybeUpperBound: Int?
        if case .array(count: let n, elementType: _) = subscriptableType {
            maybeUpperBound = n
        } else {
            maybeUpperBound = nil
        }
        
        // We can catch some out of bounds errors at compile time
        if let index = maybeStaticIndex {
            if index < 0 {
                throw CompilerError(sourceAnchor: expr.argument.sourceAnchor, message: "Array index is always out of bounds: `\(index)' is less than zero")
            }
            
            if let n = maybeUpperBound, index >= n {
                throw CompilerError(sourceAnchor: expr.argument.sourceAnchor, message: "Array index is always out of bounds: `\(index)' is not in 0..\(n)")
            }
        }
        
        var children: [AbstractSyntaxTreeNode] = [
            try lvalue(expr: expr.subscriptable)
        ]
        
        if elementSize > 0 {
            let baseAddr = popRegister()
            children += [
                try rvalue(expr: expr.argument)
            ]
            let index = popRegister()
            
            // We may need to insert a run time bounds checks.
            if maybeStaticIndex == nil {
                // Lower bound
                let lowerBound = 0
                let tempLowerBound = nextRegister()
                let tempComparison1 = nextRegister()
                let labelPassesLowerBoundsCheck = globalEnvironment.labelMaker.next()
                children += [
                    TackInstructionNode(instruction: .li16, parameters: [
                        ParameterIdentifier(tempLowerBound),
                        ParameterNumber(lowerBound)
                    ]),
                    TackInstructionNode(instruction: .ge16, parameters: [
                        ParameterIdentifier(tempComparison1),
                        ParameterIdentifier(index),
                        ParameterIdentifier(tempLowerBound)
                    ]),
                    TackInstructionNode(instruction: .bnz, parameters: [
                        ParameterIdentifier(tempComparison1),
                        ParameterIdentifier(labelPassesLowerBoundsCheck)
                    ]),
                    TackInstructionNode(instruction: .call, parameters: [
                        ParameterIdentifier(kPanic)
                    ]),
                    LabelDeclaration(identifier: labelPassesLowerBoundsCheck)
                ]
                
                // Upper bound
                let tempUpperBound = nextRegister()
                switch subscriptableType {
                case .array(count: let n?, elementType: _):
                    // The upper bound is known at compile time
                    children += [
                        TackInstructionNode(instruction: .li16, parameters: [
                            ParameterIdentifier(tempUpperBound),
                            ParameterNumber(n)
                        ])
                    ]
                    
                case .dynamicArray, .constDynamicArray:
                    // The upper bound is embedded in the slice object
                    children += [
                        TackInstructionNode(instruction: .load, parameters: [
                            ParameterIdentifier(tempUpperBound),
                            ParameterIdentifier(baseAddr),
                            ParameterNumber(kSliceCountOffset)
                        ])
                    ]
                    
                default:
                    fatalError("unimplemented")
                }
                
                let tempComparison2 = nextRegister()
                let labelPassesUpperBoundsCheck = globalEnvironment.labelMaker.next()
                children += [
                    TackInstructionNode(instruction: .lt16, parameters: [
                        ParameterIdentifier(tempComparison2),
                        ParameterIdentifier(index),
                        ParameterIdentifier(tempUpperBound)
                    ]),
                    TackInstructionNode(instruction: .bnz, parameters: [
                        ParameterIdentifier(tempComparison2),
                        ParameterIdentifier(labelPassesUpperBoundsCheck)
                    ]),
                    TackInstructionNode(instruction: .call, parameters: [
                        ParameterIdentifier(kPanic)
                    ]),
                    LabelDeclaration(identifier: labelPassesUpperBoundsCheck),
                ]
            }
            
            if elementSize == 1 {
                let accessAddr = nextRegister()
                pushRegister(accessAddr)
                children += [
                    TackInstructionNode(instruction: .add16, parameters: [
                        ParameterIdentifier(accessAddr),
                        ParameterIdentifier(index),
                        ParameterIdentifier(baseAddr)
                    ])
                ]
            } else {
                let offset = nextRegister()
                let accessAddr = nextRegister()
                pushRegister(accessAddr)
                children += [
                    TackInstructionNode(instruction: .muli16, parameters: [
                        ParameterIdentifier(offset),
                        ParameterIdentifier(index),
                        ParameterNumber(elementSize)
                    ]),
                    TackInstructionNode(instruction: .add16, parameters: [
                        ParameterIdentifier(accessAddr),
                        ParameterIdentifier(offset),
                        ParameterIdentifier(baseAddr)
                    ])
                ]
            }
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
                TackInstructionNode(instruction: .liu16, parameters: [
                    ParameterIdentifier(temp),
                    ParameterNumber(symbol.offset)
                ])
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
                TackInstructionNode(instruction: .load, parameters: [
                    ParameterIdentifier(temp_framePointer),
                    ParameterIdentifier(fp)
                ])
            ]
            
            // Follow the frame pointer `depth' times.
            for _ in 1..<depth {
                children += [
                    TackInstructionNode(instruction: .load, parameters: [
                        ParameterIdentifier(temp_framePointer),
                        ParameterIdentifier(temp_framePointer)
                    ])
                ]
            }
        }
        
        let temp_result = nextRegister()
        
        if offset >= 0 {
            children += [
                TackInstructionNode(instruction: .subi16, parameters: [
                    ParameterIdentifier(temp_result),
                    ParameterIdentifier(temp_framePointer),
                    ParameterNumber(offset)
                ])
            ]
        } else {
            children += [
                TackInstructionNode(instruction: .addi16, parameters: [
                    ParameterIdentifier(temp_result),
                    ParameterIdentifier(temp_framePointer),
                    ParameterNumber(-offset)
                ])
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
                TackInstructionNode(instruction: .addi16, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(tempStructAddress),
                    ParameterNumber(symbol.offset)
                ])
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
                        TackInstructionNode(instruction: .addi16, parameters: [
                            ParameterIdentifier(dst),
                            ParameterIdentifier(tempStructAddress),
                            ParameterNumber(symbol.offset)
                        ])
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
        let op: TackInstruction = (node.value < 256) ? .li8 : .li16
        let result = TackInstructionNode(instruction: op, parameters: [
            ParameterIdentifier(dest),
            ParameterNumber(node.value)
        ])
        return result
    }
    
    func rvalue(literalBoolean node: Expression.LiteralBool) -> AbstractSyntaxTreeNode {
        let dest = nextRegister()
        pushRegister(dest)
        let result = TackInstructionNode(instruction: .li16, parameters: [
            ParameterIdentifier(dest),
            ParameterNumber(node.value ? 1 : 0)
        ])
        return result
    }
    
    func rvalue(literalArray expr: Expression.LiteralArray) throws -> AbstractSyntaxTreeNode {
        let arrayElementType = try typeCheck(rexpr: expr.arrayType).arrayElementType
        if arrayElementType.isPrimitive {
            let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, expr.arrayType)
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(identifier: tempArrayId)
            ]
            let tempArrayAddr = popRegister()
            for i in 0..<expr.elements.count {
                children += [
                    try rvalue(as: Expression.As(expr: expr.elements[i], targetType: Expression.PrimitiveType(arrayElementType))),
                    TackInstructionNode(instruction: .store, parameters: [
                        ParameterIdentifier(tempArrayAddr),
                        ParameterIdentifier(popRegister()),
                        ParameterNumber(i)
                    ])
                ]
            }
            pushRegister(tempArrayAddr)
            return Seq(sourceAnchor: expr.sourceAnchor, children: children)
        } else {
            let savedRegisterStack = registerStack
            let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, expr.arrayType)
            var children: [AbstractSyntaxTreeNode] = []
            for i in 0..<expr.elements.count {
                let slot = Expression.Subscript(subscriptable: tempArrayId,
                                                argument: Expression.LiteralInt(i))
                let child =  try rvalue(expr: Expression.Assignment(lexpr: slot,
                                                                    rexpr: expr.elements[i]))
                children.append(child)
            }
            registerStack = savedRegisterStack
            children += [
                try lvalue(identifier: tempArrayId)
            ]
            return Seq(sourceAnchor: expr.sourceAnchor, children: children)
        }
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
        let arrayType = Expression.ArrayType(count: Expression.LiteralInt(expr.value.count),
                                             elementType: Expression.PrimitiveType(.u8))
        let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, arrayType)
        return Seq(sourceAnchor: expr.sourceAnchor, children: [
            try lvalue(identifier: tempArrayId),
            TackInstructionNode(instruction: .ststr, parameters: [
                ParameterIdentifier(peekRegister()),
                ParameterString(expr.value)
            ])
        ])
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
                TackInstructionNode(instruction: .load, parameters: [
                    ParameterIdentifier(dest),
                    ParameterIdentifier(addr),
                ])
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
            result = TackInstructionNode(instruction: .li8, parameters: [
                ParameterIdentifier(dst),
                ParameterNumber(a)
            ])
            
        case (.compTimeInt(let a), .u16),
             (.compTimeInt(let a), .constU16):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister()
            pushRegister(dst)
            result = TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(dst),
                ParameterNumber(a)
            ])
            
        case (.compTimeBool(let a), .bool),
             (.compTimeBool(let a), .constBool):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister()
            pushRegister(dst)
            result = TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(dst),
                ParameterNumber(a ? 1 : 0)
            ])
            
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
                TackInstructionNode(instruction: .andi16, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(src),
                    ParameterNumber(0x00ff)
                ])
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
                        lexpr: Expression.Subscript(subscriptable: tempArrayId,
                                                    argument: Expression.LiteralInt(i)),
                        rexpr: Expression.As(expr: Expression.Subscript(subscriptable: rexpr,
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
                try rvalue(expr: rexpr),
                TackInstructionNode(instruction: .store, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(popRegister()),
                    ParameterNumber(kSliceBaseAddrOffset),
                ])
            ]
            let countReg = nextRegister()
            children += [
                TackInstructionNode(instruction: .liu16, parameters: [
                    ParameterIdentifier(countReg),
                    ParameterNumber(n),
                ]),
                TackInstructionNode(instruction: .store, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(countReg),
                    ParameterNumber(kSliceCountOffset),
                ])
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
            let targetType = determineUnionTargetType(typ, rtype)!
            let unionTypeTag = determineUnionTypeTag(typ, targetType)!
            children += [
                TackInstructionNode(instruction: .liu16, parameters: [
                    ParameterIdentifier(tempUnionTypeTag),
                    ParameterNumber(unionTypeTag)
                ]),
                TackInstructionNode(instruction: .store, parameters: [
                    ParameterIdentifier(tempUnionAddr),
                    ParameterIdentifier(tempUnionTypeTag),
                    ParameterNumber(kUnionTypeTagOffset)
                ])
            ]
            if targetType.isPrimitive {
                children += [
                    try rvalue(as: Expression.As(expr: rexpr, targetType: Expression.PrimitiveType(targetType))),
                    TackInstructionNode(instruction: .store, parameters: [
                        ParameterIdentifier(tempUnionAddr),
                        ParameterIdentifier(popRegister()),
                        ParameterNumber(kUnionPayloadOffset)
                    ])
                ]
            } else {
                let size = globalEnvironment.memoryLayoutStrategy.sizeof(type: rtype)
                let tempUnionPayloadAddress = nextRegister()
                children += [
                    TackInstructionNode(instruction: .addi16, parameters: [
                        ParameterIdentifier(tempUnionPayloadAddress),
                        ParameterIdentifier(tempUnionAddr),
                        ParameterNumber(kUnionPayloadOffset)
                    ]),
                    try rvalue(as: Expression.As(expr: rexpr, targetType: Expression.PrimitiveType(targetType))),
                    TackInstructionNode(instruction: .memcpy, parameters: [
                        ParameterIdentifier(tempUnionPayloadAddress),
                        ParameterIdentifier(popRegister()),
                        ParameterNumber(size)
                    ])
                ]
            }
            pushRegister(tempUnionAddr)
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (.unionType(let typ), _):
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(expr: rexpr)
            ]
            let tempUnionAddr = popRegister()
            
            // If the union can contain more than one type then insert a runtime
            // check that the tag matches that of the requested type.
            if typ.members.count > 1 {
                let targetType = determineUnionTargetType(typ, ltype)!
                let unionTypeTag = determineUnionTypeTag(typ, targetType)!
                let tempUnionTag = nextRegister()
                let tempComparison = nextRegister()
                let labelSkipPanic = globalEnvironment.labelMaker.next()
                children += [
                    TackInstructionNode(instruction: .load, parameters: [
                        ParameterIdentifier(tempUnionTag),
                        ParameterIdentifier(tempUnionAddr),
                        ParameterNumber(kUnionTypeTagOffset)
                    ]),
                    TackInstructionNode(instruction: .subi16, parameters: [
                        ParameterIdentifier(tempComparison),
                        ParameterIdentifier(tempUnionTag),
                        ParameterNumber(unionTypeTag)
                    ]),
                    TackInstructionNode(instruction: .bz, parameters: [
                        ParameterIdentifier(tempComparison),
                        ParameterIdentifier(labelSkipPanic)
                    ]),
                    TackInstructionNode(instruction: .call, parameters: [
                        ParameterIdentifier(kPanic)
                    ]),
                    LabelDeclaration(identifier: labelSkipPanic)
                ]
            }
            
            let dst = nextRegister()
            pushRegister(dst)
            
            if ltype.isPrimitive {
                children += [
                    TackInstructionNode(instruction: .load, parameters: [
                        ParameterIdentifier(dst),
                        ParameterIdentifier(tempUnionAddr),
                        ParameterNumber(kUnionPayloadOffset),
                    ])
                ]
            } else {
                children += [
                    TackInstructionNode(instruction: .addi16, parameters: [
                        ParameterIdentifier(dst),
                        ParameterIdentifier(tempUnionAddr),
                        ParameterNumber(kUnionPayloadOffset),
                    ])
                ]
            }
            
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (.constPointer(let a), .traitType(let b)),
             (.pointer(let a), .traitType(let b)):
            fatalError("unimplemented: pointer(\(a)) -> trait(\(b))")
            
        case (_, .constPointer(let b)),
             (_, .pointer(let b)):
            if rtype.correspondingConstType == b.correspondingConstType {
                result = try lvalue(expr: rexpr)
            }
            else if case .traitType(let a) = rtype {
                let traitObjectType = try? symbols!.resolveType(identifier: a.nameOfTraitObjectType)
                if traitObjectType == b {
                    result = try lvalue(expr: rexpr)
                }
                else {
                    fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
                }
            }
            else {
                fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
            }
            
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
             (.unionType, .unionType),
             (.traitType, .traitType):
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
                result = TackInstructionNode(instruction: .la, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(label)
                ])
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
                    TackInstructionNode(instruction: .li8, parameters: [
                        ParameterIdentifier(a),
                        ParameterNumber(0)
                    ]),
                    TackInstructionNode(instruction: .sub8, parameters: [
                        ParameterIdentifier(c),
                        ParameterIdentifier(a),
                        ParameterIdentifier(b)
                    ])
                ]
                
            case (.u16, .minus):
                let a = nextRegister()
                let c = nextRegister()
                pushRegister(c)
                instructions += [
                    TackInstructionNode(instruction: .li16, parameters: [
                        ParameterIdentifier(a),
                        ParameterNumber(0)
                    ]),
                    TackInstructionNode(instruction: .sub16, parameters: [
                        ParameterIdentifier(c),
                        ParameterIdentifier(a),
                        ParameterIdentifier(b)
                    ])
                ]
                
            case (.bool, .bang):
                let a = nextRegister()
                let c = nextRegister()
                pushRegister(c)
                instructions += [
                    TackInstructionNode(instruction: .not, parameters: [
                        ParameterIdentifier(a),
                        ParameterIdentifier(b)
                    ])
                ]
                
            case (.u8, .tilde):
                let c = nextRegister()
                let d = nextRegister()
                pushRegister(d)
                instructions += [
                    TackInstructionNode(instruction: .neg8, parameters: [
                        ParameterIdentifier(c),
                        ParameterIdentifier(b)
                    ])
                ]
                
            case (.u16, .tilde):
                let c = nextRegister()
                pushRegister(c)
                instructions += [
                    TackInstructionNode(instruction: .neg16, parameters: [
                        ParameterIdentifier(c),
                        ParameterIdentifier(b)
                    ])
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
        let op = TackInstructionNode(instruction: operandIns, parameters: [
            ParameterIdentifier(c),
            ParameterIdentifier(a),
            ParameterIdentifier(b)
        ])
        
        return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])
    }
    
    func getOperand(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType, _ typeForArithmetic: SymbolType) throws -> TackInstruction {
        let op: TackInstruction
        switch (binary.op, typeForArithmetic) {
        case (.eq, .u8):
            op = .eq8
        case (.eq, .u16):
            op = .eq16
        case (.ne, .u8):
            op = .ne8
        case (.ne, .u16):
            op = .ne16
        case (.lt, .u8):
            op = .lt8
        case (.lt, .u16):
            op = .lt16
        case (.gt, .u8):
            op = .gt8
        case (.gt, .u16):
            op = .gt16
        case (.le, .u8):
            op = .le8
        case (.le, .u16):
            op = .le16
        case (.ge, .u8):
            op = .ge8
        case (.ge, .u16):
            op = .ge16
        case (.plus, .u8):
            op = .add8
        case (.plus, .u16):
            op = .add16
        case (.minus, .u8):
            op = .sub8
        case (.minus, .u16):
            op = .sub16
        case (.star, .u8):
            op = .mul8
        case (.star, .u16):
            op = .mul16
        case (.divide, .u8):
            op = .div8
        case (.divide, .u16):
            op = .div16
        case (.modulus, .u8):
            op = .mod8
        case (.modulus, .u16):
            op = .mod16
        case (.ampersand, .u8):
            op = .and8
        case (.ampersand, .u16):
            op = .and16
        case (.pipe, .u8):
            op = .or8
        case (.pipe, .u16):
            op = .or16
        case (.caret, .u8):
            op = .xor8
        case (.caret, .u16):
            op = .xor16
        case (.leftDoubleAngle, .u8):
            op = .lsl8
        case (.leftDoubleAngle, .u16):
            op = .lsl16
        case (.rightDoubleAngle, .u8):
            op = .lsr8
        case (.rightDoubleAngle, .u16):
            op = .lsr16
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
        
        let ins: TackInstruction
        switch try typeCheck(rexpr: binary) {
        case .u8, .constU8:
            ins = .li8
            
        default:
            ins = .li16
        }
        
        let dst = nextRegister()
        pushRegister(dst)
        
        return TackInstructionNode(instruction: ins, parameters: [
            ParameterIdentifier(dst),
            ParameterNumber(value)
        ])
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
            let op = TackInstructionNode(instruction: .eq16, parameters: [
                ParameterIdentifier(c),
                ParameterIdentifier(a),
                ParameterIdentifier(b)
            ])
            return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])
            
        case .ne:
            let right = try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
            let left = try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false)
            let a = popRegister()
            let b = popRegister()
            let c = nextRegister()
            pushRegister(c)
            let op = TackInstructionNode(instruction: .ne16, parameters: [
                ParameterIdentifier(c),
                ParameterIdentifier(a),
                ParameterIdentifier(b)
            ])
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
        
        return TackInstructionNode(instruction: .li16, parameters: [
            ParameterIdentifier(dst),
            ParameterNumber(value)
        ])
    }
    
    func logicalAnd(_ binary: Expression.Binary) throws -> AbstractSyntaxTreeNode {
        var instructions: [AbstractSyntaxTreeNode] = []
        let labelFalse = globalEnvironment.labelMaker.next()
        let labelTail = globalEnvironment.labelMaker.next()
        instructions.append(try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false))
        let a = popRegister()
        instructions += [
            TackInstructionNode(instruction: .bz, parameters: [
                ParameterIdentifier(a),
                ParameterIdentifier(labelFalse)
            ]),
            try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
        ]
        let b = popRegister()
        let c = nextRegister()
        pushRegister(c)
        instructions += [
            TackInstructionNode(instruction: .bz, parameters: [
                ParameterIdentifier(b),
                ParameterIdentifier(labelFalse)
            ]),
            TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(c),
                ParameterNumber(1)
            ]),
            TackInstructionNode(instruction: .jmp, parameters: [
                ParameterIdentifier(labelTail)
            ]),
            LabelDeclaration(identifier: labelFalse),
            TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(c),
                ParameterNumber(0)
            ]),
            LabelDeclaration(identifier: labelTail)
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
            TackInstructionNode(instruction: .bnz, parameters: [
                ParameterIdentifier(a),
                ParameterIdentifier(labelTrue)
            ]),
            try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
        ]
        let b = popRegister()
        let c = nextRegister()
        pushRegister(c)
        instructions += [
            TackInstructionNode(instruction: .bnz, parameters: [
                ParameterIdentifier(b),
                ParameterIdentifier(labelTrue)
            ]),
            TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(c),
                ParameterNumber(0)
            ]),
            TackInstructionNode(instruction: .jmp, parameters: [
                ParameterIdentifier(labelTail)
            ]),
            LabelDeclaration(identifier: labelTrue),
            TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(c),
                ParameterNumber(1)
            ]),
            LabelDeclaration(identifier: labelTail)
        ]
        return Seq(sourceAnchor: binary.sourceAnchor, children: instructions)
    }
    
    func rvalue(is expr: Expression.Is) throws -> AbstractSyntaxTreeNode {
        let exprType = try typeCheck(rexpr: expr)
        
        switch exprType {
        case .compTimeBool(let val):
            let tempResult = nextRegister()
            let result = TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(tempResult),
                ParameterNumber(val ? 1 : 0)
            ])
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
            TackInstructionNode(instruction: .li16, parameters: [
                ParameterIdentifier(tempTestTag),
                ParameterNumber(typeTag)
            ])
        ]
        
        // Get the address of the union in memory.
        children += [
            try lvalue(expr: expr.expr)
        ]
        let tempUnionAddr = popRegister()
        
        // Read the union type tag in memory.
        let tempActualTag = nextRegister()
        children += [
            TackInstructionNode(instruction: .load, parameters: [
                ParameterIdentifier(tempActualTag),
                ParameterIdentifier(tempUnionAddr)
            ])
        ]
        
        // Compare the union's actual type tag against the tag of the test type.
        let tempResult = nextRegister()
        children += [
            TackInstructionNode(instruction: .eq16, parameters: [
                ParameterIdentifier(tempResult),
                ParameterIdentifier(tempActualTag),
                ParameterIdentifier(tempTestTag)
            ])
        ]
        
        pushRegister(tempResult)
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    // Given a type and a related union, determine the type to which to convert
    // when inserting into the union. This is necessary because many types
    // can automatically promote and convert to other types. For example, if
    // the union can hold a u16 then we should automatically convert
    // LiteralInt(1) to u16 in order to insert into the union.
    func determineUnionTargetType(_ typ: UnionType, _ rtype: SymbolType) -> SymbolType? {
        // Find the first type that is an exact match
        for ltype in typ.members {
            if rtype == ltype {
                return ltype
            }
        }
        
        // Find the first type that matches except for its const-ness
        for ltype in typ.members {
            if rtype.correspondingConstType == ltype {
                return ltype
            }
        }
        
        // Find the first type that can be automatically converted in an assignment
        for ltype in typ.members {
            let typeChecker = RvalueExpressionTypeChecker(symbols: symbols!)
            let status = typeChecker.convertBetweenTypes(ltype: ltype,
                                                         rtype: rtype,
                                                         sourceAnchor: nil,
                                                         messageWhenNotConvertible: "",
                                                         isExplicitCast: false)
            switch status {
            case .acceptable(let symbolType):
                return symbolType
                
            case .unacceptable:
                break
            }
        }
        
        return nil
    }
    
    // Given a type and a related union, determine the corresponding type tag.
    // Return nil if the type does not match the union after all.
    func determineUnionTypeTag(_ typ: UnionType, _ testType: SymbolType) -> Int? {
        for i in 0..<typ.members.count {
            let member = typ.members[i]
            if testType == member {
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
                TackInstructionNode(instruction: .store, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(src)
                ])
            ])
        } else if size == 0 {
            result = Seq(sourceAnchor: expr.sourceAnchor, children: [
                try lvalue(expr: expr.lexpr)
            ])
        } else if let structInitializer = expr.rexpr as? Expression.StructInitializer {
            let children = structInitializer.arguments.map {
                Expression.Assignment(lexpr: Expression.Get(sourceAnchor: expr.lexpr.sourceAnchor,
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
                TackInstructionNode(instruction: .memcpy, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(src),
                    ParameterNumber(size)
                ])
            ])
        }
        
        return result
    }
    
    func rvalue(subscript expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        let elementType = try typeCheck(rexpr: expr)
        let argumentType = try typeCheck(rexpr: expr.argument)
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        
        // Can we determine the index at compile time?
        let maybeStaticIndex: Int?
        if case .compTimeInt(let index) = argumentType {
            maybeStaticIndex = index
        } else {
            maybeStaticIndex = nil
        }
        
        // Can we determine the upper bound at compile time?
        let maybeUpperBound: Int?
        if case .array(count: let n, elementType: _) = subscriptableType {
            maybeUpperBound = n
        } else {
            maybeUpperBound = nil
        }
        
        // We can catch some out of bounds errors at compile time
        if let index = maybeStaticIndex {
            if index < 0 {
                throw CompilerError(sourceAnchor: expr.argument.sourceAnchor, message: "Array index is always out of bounds: `\(index)' is less than zero")
            }
            
            if let n = maybeUpperBound, index >= n {
                throw CompilerError(sourceAnchor: expr.argument.sourceAnchor, message: "Array index is always out of bounds: `\(index)' is not in 0..\(n)")
            }
        }
        
        var children: [AbstractSyntaxTreeNode] = []
        
        if case .compTimeInt(let index) = argumentType, elementType.isPrimitive {
            children += [
                try lvalue(expr: expr.subscriptable)
            ]
            let baseAddr = popRegister()
            let dst = nextRegister()
            pushRegister(dst)
            children += [
                TackInstructionNode(instruction: .load, parameters: [
                    ParameterIdentifier(dst),
                    ParameterIdentifier(baseAddr),
                    ParameterNumber(index)
                ])
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
                    TackInstructionNode(instruction: .load, parameters: [
                        ParameterIdentifier(dest),
                        ParameterIdentifier(addr),
                    ])
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
                TackInstructionNode(instruction: .liu16, parameters: [
                    ParameterIdentifier(countReg),
                    ParameterNumber(count!)
                ])
            ]
            
        case .constDynamicArray, .dynamicArray:
            assert(name == "count")
            children += [
                try rvalue(expr: expr.expr)
            ]
            let sliceAddr = popRegister()
            let countReg = nextRegister()
            pushRegister(countReg)
            children += [
                TackInstructionNode(instruction: .load, parameters: [
                    ParameterIdentifier(countReg),
                    ParameterIdentifier(sliceAddr),
                    ParameterNumber(kSliceCountOffset)
                ])
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
                    TackInstructionNode(instruction: .load, parameters: [
                        ParameterIdentifier(dst),
                        ParameterIdentifier(tempStructAddress),
                        ParameterNumber(symbol.offset)
                    ])
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
                        TackInstructionNode(instruction: .load, parameters: [
                            ParameterIdentifier(pointeeValue),
                            ParameterIdentifier(pointerValue)
                        ])
                    ]
                }
            } else {
                switch typ {
                case .array(count: let count, elementType: _):
                    assert(name == "count")
                    let countReg = nextRegister()
                    pushRegister(countReg)
                    children += [
                        TackInstructionNode(instruction: .liu16, parameters: [
                            ParameterIdentifier(countReg),
                            ParameterNumber(count!)
                        ])
                    ]
                    
                case .constDynamicArray, .dynamicArray:
                    assert(name == "count")
                    children += [
                        try rvalue(expr: expr.expr)
                    ]
                    let sliceAddr = popRegister()
                    let countReg = nextRegister()
                    pushRegister(countReg)
                    children += [
                        TackInstructionNode(instruction: .load, parameters: [
                            ParameterIdentifier(countReg),
                            ParameterIdentifier(sliceAddr),
                            ParameterNumber(kSliceCountOffset)
                        ])
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
                            TackInstructionNode(instruction: .load, parameters: [
                                ParameterIdentifier(fieldAddr),
                                ParameterIdentifier(structAddr)
                            ]),
                            TackInstructionNode(instruction: .load, parameters: [
                                ParameterIdentifier(dst),
                                ParameterIdentifier(fieldAddr),
                                ParameterNumber(symbol.offset)
                            ])
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
            let slot = Expression.Get(expr: tempArrayId, member: Expression.Identifier(arg.name))
            let child =  try rvalue(expr: Expression.Assignment(lexpr: slot, rexpr: arg.expr))
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
        do {
            return try rvalueInner(call: expr, typ: typ)
        }
        catch let err as CompilerError {
            if let rewritten = try rewriteStructMemberFunctionCallIfPossible(expr) {
                return rewritten
            } else {
                throw err
            }
        }
    }
    
    fileprivate func rvalueInner(call expr: Expression.Call, typ: FunctionType) throws -> AbstractSyntaxTreeNode {
        _ = try RvalueExpressionTypeChecker(symbols: symbols!).checkInner(call: expr, typ: typ)
        
        let calleeType = try typeCheck(rexpr: expr.callee)
        
        // Allocate a temporary to hold the function call return value.
        var tempRetId: Expression.Identifier! = nil
        if typ.returnType != .void {
            tempRetId = try makeCompilerTemporary(expr.sourceAnchor, Expression.PrimitiveType(typ.returnType))
        }
        
        let parent = symbols
        let innerBlock = SymbolTable(parent: parent)
        symbols = innerBlock
        
        var children: [AbstractSyntaxTreeNode] = []
        
        // Evaluation of expressions for function call arguments may involve
        // allocating memory on the stack. We first evaluate each expression
        // and then copy the value into the function call argument pack.
        assert(expr.arguments.count == typ.arguments.count)
        var tempArgs: [String] = []
        for i in 0..<typ.arguments.count {
            let argType = typ.arguments[i]
            let argExpr = expr.arguments[i]
            children += [
                try rvalue(expr: Expression.As(expr: argExpr, targetType: Expression.PrimitiveType(argType)))
            ]
            tempArgs.append(popRegister())
        }
        
        // Allocate storage on the stack for the return value.
        let returnTypeSize = globalEnvironment.memoryLayoutStrategy.sizeof(type: typ.returnType)
        var tempReturnValueAddr: String!
        if returnTypeSize > 0 {
            tempReturnValueAddr = nextRegister()
            children += [
                TackInstructionNode(instruction: .alloca, parameters: [
                    ParameterIdentifier(tempReturnValueAddr),
                    ParameterNumber(returnTypeSize)
                ])
            ]
        }
        
        // Allocate stack space for another argument and copy it into the pack.
        for i in 0..<typ.arguments.count {
            let tempArg = tempArgs[i]
            let argType = typ.arguments[i]
            let argTypeSize = globalEnvironment.memoryLayoutStrategy.sizeof(type: argType)
            let dst = nextRegister()
            if argTypeSize > 0 {
                children += [
                    TackInstructionNode(instruction: .alloca, parameters: [
                        ParameterIdentifier(dst),
                        ParameterNumber(argTypeSize)
                    ])
                ]
                if argType.isPrimitive {
                    children += [
                        TackInstructionNode(instruction: .store, parameters: [
                            ParameterIdentifier(dst),
                            ParameterIdentifier(tempArg)
                        ])
                    ]
                } else {
                    children += [
                        TackInstructionNode(instruction: .memcpy, parameters: [
                            ParameterIdentifier(dst),
                            ParameterIdentifier(tempArg),
                            ParameterNumber(argTypeSize)
                        ])
                    ]
                }
            }
        }
        
        // Make the function call.
        switch calleeType {
        case .function:
            children += [
                TackInstructionNode(instruction: .call, parameters: [
                    ParameterIdentifier(typ.mangledName!)
                ])
            ]
            
        case .pointer, .constPointer:
            children += [
                try rvalue(expr: expr.callee),
                TackInstructionNode(instruction: .callptr, parameters: [
                    ParameterIdentifier(popRegister())
                ])
            ]
            
        default:
            fatalError("unimplemented")
        }
        
        // Copy the function call return value to the compiler temporary we
        // allocated earlier. Free stack storage allocated earlier.
        if returnTypeSize > 0 {
            children += [
                try lvalue(identifier: tempRetId!),
                TackInstructionNode(instruction: .memcpy, parameters: [
                    ParameterIdentifier(popRegister()),
                    ParameterIdentifier(tempReturnValueAddr),
                    ParameterNumber(returnTypeSize)
                ])
            ]
        }
        
        // Free up stack storage allocated for arguments and return value.
        let argPackSize = typ.arguments.reduce(0) { (result, type) in
            result + globalEnvironment.memoryLayoutStrategy.sizeof(type: type)
        }
        if argPackSize + returnTypeSize > 0 {
            children += [
                TackInstructionNode(instruction: .free, parameters: [
                    ParameterNumber(argPackSize + returnTypeSize)
                ])
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
    
    fileprivate func rewriteStructMemberFunctionCallIfPossible(_ expr: Expression.Call) throws -> AbstractSyntaxTreeNode? {
        func matchStructMemberFunctionCall(_ expr: Expression.Call) throws -> StructMemberFunctionCallMatcher.Match? {
            return try StructMemberFunctionCallMatcher(call: expr, typeChecker: RvalueExpressionTypeChecker(symbols: symbols!)).match()
        }
        
        func rewriteStructMemberFunctionCall(_ match: StructMemberFunctionCallMatcher.Match) throws -> AbstractSyntaxTreeNode {
            let expr = match.callExpr
            let tempSelf = try makeCompilerTemporary(expr.sourceAnchor, Expression.PrimitiveType(match.firstArgumentType))
            let assign = try rvalue(assignment: Expression.InitialAssignment(sourceAnchor: expr.sourceAnchor, lexpr: tempSelf, rexpr: match.getExpr.expr))
            registerStack.removeLast()
            return Seq(sourceAnchor: expr.sourceAnchor, children: [
                assign,
                try rvalue(call: Expression.Call(sourceAnchor: expr.sourceAnchor,
                                                 callee: Expression.Get(sourceAnchor: expr.sourceAnchor,
                                                                        expr: tempSelf,
                                                                        member: match.getExpr.member),
                                                 arguments: [tempSelf] + expr.arguments),
                           typ: match.fnType)
            ])
        }
        
        guard let match = try matchStructMemberFunctionCall(expr) else {
            return nil
        }
        return try rewriteStructMemberFunctionCall(match)
    }
}
