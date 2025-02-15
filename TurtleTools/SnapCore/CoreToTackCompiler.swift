//
//  CoreToTackCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public final class CoreToTackCompiler: CompilerPassWithDeclScan {
    public typealias Register = TackInstruction.Register
    public typealias RegisterPointer = TackInstruction.RegisterPointer
    public typealias RegisterType = TackInstruction.RegisterType
    public typealias Options = SnapCompilerFrontEnd.Options
    
    private let options: Options
    private var subroutines: [Subroutine] = []
    public internal(set) var registerStack: [Register] = []
    private var nextRegisterIndex = 0
    private let kOOB = "__oob"
    private let kHalt = "hlt"
    private let kSyscall = "__syscall"
    
    private let kUnionPayloadOffset: Int
    private let kUnionTypeTagOffset: Int
    
    private let kSliceName = "Slice"
    private let kSliceBase = "base"
    private let kSliceBaseAddressOffset: Int
    private let kSliceBaseAddressType = SymbolType.u16
    private let kSliceCount = "count"
    private let kSliceCountOffset: Int
    private let kSliceCountType = SymbolType.u16
    private let kSliceType: SymbolType
    
    private let kRangeName = "Range"
    private let kRangeBegin = "begin"
    private let kRangeLimit = "limit"
    
    func pushRegister(_ identifier: Register) {
        registerStack.append(identifier)
    }
    
    func popRegister() -> Register {
        assert(!registerStack.isEmpty)
        return registerStack.removeLast()
    }
    
    func peekRegister() -> Register {
        assert(!registerStack.isEmpty)
        return registerStack.last!
    }
    
    func nextRegister(type: RegisterType) -> Register {
        let result: Register = {
            switch type {
            case .p: return .p(.p(nextRegisterIndex))
            case .w: return .w(.w(nextRegisterIndex))
            case .b: return .b(.b(nextRegisterIndex))
            case .o: return .o(.o(nextRegisterIndex))
            }
        }()
        nextRegisterIndex += 1
        return result
    }
    
    public init(symbols: SymbolTable = SymbolTable(),
                staticStorageFrame: Frame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress),
                memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16(),
                options: CoreToTackCompiler.Options = Options()) {
        self.options = options
        kUnionTypeTagOffset = 0
        kUnionPayloadOffset = memoryLayoutStrategy.sizeof(type: .u16)
        kSliceBaseAddressOffset = 0
        kSliceCountOffset = memoryLayoutStrategy.sizeof(type: .pointer(.void))
        let structSymbols = SymbolTable(
            frameLookupMode: .set(Frame()),
            tuples: [
                (kSliceBase,  Symbol(type: kSliceBaseAddressType, offset: kSliceBaseAddressOffset)),
                (kSliceCount, Symbol(type: kSliceCountType, offset: kSliceCountOffset))
            ])
        kSliceType = .structType(StructTypeInfo(name: kSliceName, symbols: structSymbols))
        super.init(symbols: symbols,
                   staticStorageFrame: staticStorageFrame,
                   memoryLayoutStrategy: memoryLayoutStrategy)
    }
    
    public override func run(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode {
        
        var children: [AbstractSyntaxTreeNode] = []
        
        if let compiledNode = try super.run(node0) {
            children.append(compiledNode)
        }
        
        children += try subroutines.map { subroutine in
            try subroutine.linearizeLabels(
                relativeTo: symbols!,
                staticStorageFrame: staticStorageFrame,
                memoryLayoutStrategy: memoryLayoutStrategy)!
        }
        
        let seq = Seq(sourceAnchor: node0?.sourceAnchor, children: children)
        let result = try seq.flatten() ?? Seq()
        return result
    }
    
    public override func visit(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(node0)
        let node2 = try node1?.flatten()
        return node2
    }
    
    public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
        let block1 = try super.visit(block: block0) as! Block
        let seq = try block1.eraseBlock(
            relativeTo: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
        return seq
    }
    
    public override func visit(return node: Return) throws -> AbstractSyntaxTreeNode? {
        assert(node.expression == nil)
        return Seq(
            sourceAnchor: node.sourceAnchor,
            children: [
                TackInstructionNode(
                    instruction: .leave,
                    sourceAnchor: node.sourceAnchor,
                    symbols: symbols),
                TackInstructionNode(
                    instruction: .ret,
                    sourceAnchor: node.sourceAnchor,
                    symbols: symbols)
            ])
    }
    
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let symbols = symbols!
        let mangledName = try symbols
            .resolve(
                sourceAnchor: node.sourceAnchor,
                identifier: node.identifier.identifier)
            .type
            .unwrapFunctionType()
            .mangledName! // TODO: Should a function's mangled name also be stored in the AST in the FunctionDeclaration node itself?
        let stackFrame = symbols.frame!
        assert(symbols.frameLookupMode == .set(stackFrame))
        let subroutineBody = try visit(node.body) ?? Seq()
        let sizeOfLocalVariables = stackFrame.storagePointer
        let subroutine = Subroutine(
            sourceAnchor: node.sourceAnchor,
            identifier: mangledName,
            children: [
                TackInstructionNode(
                    instruction: .enter(sizeOfLocalVariables),
                    sourceAnchor: node.sourceAnchor,
                    symbols: symbols),
                subroutineBody
            ])
        subroutines.append(subroutine)
        return nil
    }
    
    public override func visit(asm node: Asm) throws -> AbstractSyntaxTreeNode? {
        TackInstructionNode(
            instruction: .inlineAssembly(node.assemblyCode),
            sourceAnchor: node.sourceAnchor,
            symbols: symbols)
    }
    
    public override func visit(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        TackInstructionNode(
            instruction: .jmp(node.target),
            sourceAnchor: node.sourceAnchor,
            symbols: symbols)
    }
    
    public override func visit(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        var children: [AbstractSyntaxTreeNode] = [
            try rvalue(expr: node.condition)
        ]
        
        children += [
            TackInstructionNode(
                instruction: .bz(popRegister().unwrapBool!, node.target),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols)
        ]
        
        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    public override func visit(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        let savedRegisterStack = registerStack
        let result = try rvalue(expr: node)
        registerStack = savedRegisterStack
        return result
    }
    
    @discardableResult func typeCheck(rexpr: Expression) throws -> SymbolType {
        try rvalueContext.check(expression: rexpr)
    }
    
    @discardableResult func typeCheck(lexpr: Expression) throws -> SymbolType? {
        try lvalueContext.check(expression: lexpr)
    }
    
    public func lvalue(expr expr0: Expression) throws -> AbstractSyntaxTreeNode {
        guard try typeCheck(lexpr: expr0) != nil else {
            throw CompilerError(sourceAnchor: expr0.sourceAnchor, message: "lvalue required")
        }
        let expr1 = switch expr0 {
        case let node as Expression.Identifier:
            try lvalue(identifier: node)
        case let node as Expression.Subscript:
            try lvalue(subscript: node)
        case let node as Expression.Get:
            try lvalue(get: node)
        case let node as Expression.Bitcast:
            try lvalue(expr: node.expr)
        case let node as Expression.GenericTypeApplication:
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "internal compiler error: expected generics to have been erased by this point: `\(node)'")
        default:
            throw CompilerError(sourceAnchor: expr0.sourceAnchor, message: "internal compiler error: unimplemented support for expression in CoreToTackCompiler: `\(expr0)'")
        }
        let expr2 = try expr1.flatten() ?? Seq(sourceAnchor: expr1.sourceAnchor, children: [])
        return expr2
    }
    
    func lvalue(identifier node: Expression.Identifier) throws -> AbstractSyntaxTreeNode {
        let lvalueType = try typeCheck(lexpr: node)
        switch lvalueType {
        case .function(let typ):
            guard let mangledName = typ.mangledName else {
                throw CompilerError(sourceAnchor: node.sourceAnchor, message: "internal compiler error: function has no mangled name: `\(lvalueType!.description)'")
            }
            
            let dst = nextRegister(type: .p)
            pushRegister(dst)
            let result = TackInstructionNode(
                instruction: .la(dst.unwrapPointer!, mangledName),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols)
            return result
            
        case .genericFunction:
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "internal compiler error: expected generics to have been erased by this point: `\(node)'")
            
        default:
            let resolution = try symbols!.resolveWithStackFrameDepth(sourceAnchor: node.sourceAnchor, identifier: node.identifier)
            let symbol = resolution.0
            let depth = resolution.1
            assert(depth >= 0)
            let result = computeAddressOfSymbol(sourceAnchor: node.sourceAnchor, symbol: symbol, depth: depth)
            return try visit(result)!
        }
    }
    
    func lvalue(subscript expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        let argumentType = try typeCheck(rexpr: expr.argument)
        
        switch argumentType {
        case .structType, .constStructType:
            return try lvalue(slice: expr)
            
        default:
            break
        }
        
        let elementType = try typeCheck(rexpr: expr)
        let elementSize = memoryLayoutStrategy.sizeof(type: elementType)
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        
        // Can we determine the index at compile time?
        let maybeStaticIndex: Int?
        if case .arithmeticType(.compTimeInt(let index)) = argumentType {
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
        
        // If this is a dynamic array then we must dereference the slice.
        // The slice is a structure that contains a pointer and a count, and the
        // slice lvalue is the address of this structure. We must perform
        // another load to extract the base address.
        let sliceAddr: Register!
        switch subscriptableType {
        case .dynamicArray, .constDynamicArray:
            sliceAddr = popRegister()
            let baseAddr = nextRegister(type: .p)
            pushRegister(baseAddr)
            children += [
                TackInstructionNode(
                    instruction: .lp(baseAddr.unwrapPointer!, sliceAddr.unwrapPointer!, kSliceBaseAddressOffset),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
            
        default:
            sliceAddr = nil
        }
        
        if elementSize > 0 {
            let baseAddr = popRegister()
            children += [
                try compileAndConvertExpression(
                    rexpr: expr.argument,
                    ltype: .arithmeticType(.immutableInt(.u16)),
                    isExplicitCast: false)
            ]
            let index = popRegister()
            
            // We may need to insert a run time bounds checks.
            if options.isBoundsCheckEnabled && maybeStaticIndex == nil {
                // Lower bound
                let lowerBound = 0
                let tempLowerBound = nextRegister(type: .w)
                let tempComparison1 = nextRegister(type: .o)
                let labelPassesLowerBoundsCheck = symbols!.nextLabel()
                children += [
                    TackInstructionNode(
                        instruction: .liw(tempLowerBound.unwrap16!, lowerBound),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .gew(tempComparison1.unwrapBool!, index.unwrap16!, tempLowerBound.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .bnz(tempComparison1.unwrapBool!, labelPassesLowerBoundsCheck),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .call(kOOB),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    LabelDeclaration(
                        sourceAnchor: expr.sourceAnchor,
                        identifier: labelPassesLowerBoundsCheck)
                ]
                
                // Upper bound
                let tempUpperBound = nextRegister(type: .w)
                switch subscriptableType {
                case .array(count: let n?, elementType: _):
                    // The upper bound is known at compile time
                    children += [
                        TackInstructionNode(.liw(tempUpperBound.unwrap16!, n))
                    ]
                    
                case .dynamicArray, .constDynamicArray:
                    // The upper bound is embedded in the slice object
                    children += [
                        TackInstructionNode(
                            instruction: .lw(tempUpperBound.unwrap16!, sliceAddr.unwrapPointer!, kSliceCountOffset),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols)
                    ]
                    
                default:
                    fatalError("unimplemented")
                }
                
                let tempComparison2 = nextRegister(type: .o)
                let labelPassesUpperBoundsCheck = symbols!.nextLabel()
                children += [
                    TackInstructionNode(
                        instruction: .ltw(tempComparison2.unwrapBool!, index.unwrap16!, tempUpperBound.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .bnz(tempComparison2.unwrapBool!, labelPassesUpperBoundsCheck),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .call(kOOB),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    LabelDeclaration(
                        sourceAnchor: expr.sourceAnchor,
                        identifier: labelPassesUpperBoundsCheck),
                ]
            }
            
            if elementSize == 1 {
                let accessAddr = nextRegister(type: .p)
                pushRegister(accessAddr)
                children += [
                    TackInstructionNode(
                        instruction: .addpw(accessAddr.unwrapPointer!, baseAddr.unwrapPointer!, index.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
            } else {
                let offset = nextRegister(type: .w)
                let accessAddr = nextRegister(type: .p)
                pushRegister(accessAddr)
                children += [
                    TackInstructionNode(
                        instruction: .muliw(offset.unwrap16!, index.unwrap16!, elementSize),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .addpw(accessAddr.unwrapPointer!, baseAddr.unwrapPointer!, offset.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
            }
        }
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    func lvalue(slice expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        switch subscriptableType {
        case .array:
            return try lvalue(arraySlice: expr)

        case .dynamicArray, .constDynamicArray:
            return try lvalue(dynamicArraySlice: expr)
            
        default:
            fatalError("Cannot subscript an expression of type `\(subscriptableType)'. Semantic analysis should have caught this error at an earlier step.")
        }
    }
    
    func lvalue(arraySlice expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        assert(isAcceptableArraySliceArgument(expr.argument))
        
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        let beginExpr = Expression.Get(expr: expr.argument, member: Expression.Identifier(kRangeBegin))
        let limitExpr = Expression.Get(expr: expr.argument, member: Expression.Identifier(kRangeLimit))
        let upperBound = subscriptableType.arrayCount!
        var children: [AbstractSyntaxTreeNode] = []
        
        // Can we determine the range's bounds at compile time?
        let maybeBegin: Int?
        switch try? typeCheck(rexpr: beginExpr) {
        case .arithmeticType(.compTimeInt(let n)):
            maybeBegin = n
            
        default:
            maybeBegin = nil
        }
        
        let maybeLimit: Int?
        switch try? typeCheck(rexpr: limitExpr) {
        case .arithmeticType(.compTimeInt(let n)):
            maybeLimit = n
            
        default:
            maybeLimit = nil
        }
        
        if let begin = maybeBegin, begin < 0 || begin >= upperBound {
            throw CompilerError(sourceAnchor: expr.argument.sourceAnchor, message: "Array index is always out of bounds: `\(begin)' is not in 0..\(upperBound)")
        }
        
        if let limit = maybeLimit, limit < 0 || limit > upperBound {
            throw CompilerError(sourceAnchor: expr.argument.sourceAnchor, message: "Array index is always out of bounds: `\(limit)' is not in 0..\(upperBound)")
        }
        
        if let begin = maybeBegin, let limit = maybeLimit, begin > limit {
            throw CompilerError(sourceAnchor: expr.argument.sourceAnchor, message: "Range requires begin less than or equal to limit: `\(begin)..\(limit)'")
        }
        
        // Insert bounds check when bounds cannot be verified at compile time.
        if options.isBoundsCheckEnabled {
            if maybeBegin == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Expression.Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .ge,
                        left: beginExpr,
                        right: Expression.LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: upperBound)),
                    then: Expression.Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Expression.Identifier(kOOB)))
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!)
                if let boundsCheck2 = try super.visit(boundsCheck1) {
                    children.append(boundsCheck2)
                }
            }
            
            if maybeLimit == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Expression.Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .gt,
                        left: limitExpr,
                        right: Expression.LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: upperBound)),
                    then: Expression.Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Expression.Identifier(
                            sourceAnchor: expr.sourceAnchor,
                            identifier: kOOB)))
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!)
                if let boundsCheck2 = try super.visit(boundsCheck1) {
                    children.append(boundsCheck2)
                }
            }
        } // if options.isBoundsCheckEnabled
        
        // Compile an expression to initialize a Slice struct with populated
        // base and count fields. This involves some unsafe, platform-specific
        // bitcasts and assumptions about the memory layout.
        let sliceType = try typeCheck(rexpr: expr)
        let elementSize = memoryLayoutStrategy.sizeof(type: sliceType.arrayElementType)
        
        let arrayBeginExpr = Expression.Bitcast(
            sourceAnchor: expr.sourceAnchor,
            expr: Expression.Unary(
                sourceAnchor: expr.sourceAnchor,
                op: .ampersand,
                expression: expr.subscriptable),
            targetType: Expression.PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: .u16))
        
        let baseExpr: Expression
        if let begin = maybeBegin {
            if begin == 0 {
                baseExpr = arrayBeginExpr
            }
            else {
                baseExpr = Expression.Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .plus,
                    left: arrayBeginExpr,
                    right: Expression.LiteralInt(
                        sourceAnchor: expr.sourceAnchor,
                        value: begin * elementSize))
            }
        }
        else {
            if elementSize == 1 {
                baseExpr = Expression.Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .plus,
                    left: arrayBeginExpr,
                    right: beginExpr)
            }
            else {
                baseExpr = Expression.Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .plus,
                    left: arrayBeginExpr,
                    right: Expression.Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .star,
                        left: beginExpr,
                        right: Expression.LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: elementSize)))
            }
        }
        
        let countExpr: Expression
        if let begin = maybeBegin, let limit = maybeLimit {
            countExpr = Expression.LiteralInt(
                sourceAnchor: expr.sourceAnchor,
                value: limit - begin)
        }
        else {
            countExpr = Expression.Binary(
                sourceAnchor: expr.sourceAnchor,
                op: .minus,
                left: limitExpr,
                right: beginExpr)
        }
        
        let sliceExpr = Expression.StructInitializer(
            sourceAnchor: expr.sourceAnchor,
            identifier: Expression.Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: kSliceName),
            arguments: [
                Expression.StructInitializer.Argument(name: kSliceBase, expr: baseExpr),
                Expression.StructInitializer.Argument(name: kSliceCount, expr: countExpr)
            ])
        let bitcastExpr = Expression.Bitcast(
            sourceAnchor: expr.sourceAnchor,
            expr: sliceExpr,
            targetType: Expression.PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: sliceType))
        let compiledNode = try rvalue(expr: bitcastExpr)
        children.append(compiledNode)
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    fileprivate func isAcceptableArraySliceArgument(_ argument: Expression) -> Bool {
        let result: Bool
        let argumentType = try? typeCheck(rexpr: argument)
        switch argumentType {
        case .structType(let typ), .constStructType(let typ):
            if typ.name == kRangeName,
               typ.symbols.maybeResolve(identifier: kRangeBegin) != nil,
               typ.symbols.maybeResolve(identifier: kRangeLimit) != nil {
                result = true
            } else {
                result = false
            }
            
        default:
            result = false
        }
        return result
    }
    
    func lvalue(dynamicArraySlice expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        guard let range = expr.argument as? Expression.StructInitializer, range.arguments.count == 2, range.arguments[0].name == kRangeBegin, range.arguments[1].name == kRangeLimit else {
            fatalError("Array slice requires the argument to be range. Semantic analysis should have caught this error at an earlier step.")
        }
        
        // Can we determine the range's bounds at compile time?
        let maybeBegin: Int?
        switch try? typeCheck(rexpr: range.arguments[0].expr) {
        case .arithmeticType(.compTimeInt(let n)):
            maybeBegin = n
            
        default:
            maybeBegin = nil
        }
        
        let maybeLimit: Int?
        switch try? typeCheck(rexpr: range.arguments[1].expr) {
        case .arithmeticType(.compTimeInt(let n)):
            maybeLimit = n
            
        default:
            maybeLimit = nil
        }
        
        var children: [AbstractSyntaxTreeNode] = []
        let beginExpr = range.arguments[0].expr
        let limitExpr = range.arguments[1].expr
        
        // Insert dynamic bounds check
        if options.isBoundsCheckEnabled {
            let upperBoundExpr = Expression.Get(
                sourceAnchor: expr.sourceAnchor,
                expr: Expression.Bitcast(
                    sourceAnchor: expr.sourceAnchor,
                    expr: expr.subscriptable,
                    targetType: Expression.Identifier(
                        sourceAnchor: expr.sourceAnchor,
                        identifier: kSliceName)),
                member: Expression.Identifier(
                    sourceAnchor: expr.sourceAnchor,
                    identifier: kSliceCount))
            
            if maybeBegin == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Expression.Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .ge,
                        left: beginExpr,
                        right: upperBoundExpr),
                    then: Expression.Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Expression.Identifier(
                            sourceAnchor: expr.sourceAnchor,
                            identifier: kOOB)))
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!)
                if let boundsCheck2 = try super.visit(boundsCheck1) {
                    children.append(boundsCheck2)
                }
            }
            
            if maybeLimit == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Expression.Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .gt,
                        left: limitExpr,
                        right: upperBoundExpr),
                    then: Expression.Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Expression.Identifier(
                            sourceAnchor: expr.sourceAnchor,
                            identifier: kOOB)))
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!)
                if let boundsCheck2 = try super.visit(boundsCheck1) {
                    children.append(boundsCheck2)
                }
            }
        } // if options.isBoundsCheckEnabled
        
        // Compile an expression to initialize a Slice struct with populated
        // base and count fields. This involves some unsafe, platform-specific
        // bitcasts and assumptions about the memory layout.
        let arrayBeginExpr = Expression.Get(
            sourceAnchor: expr.sourceAnchor,
            expr: Expression.Bitcast(
                sourceAnchor: expr.sourceAnchor,
                expr: expr.subscriptable,
                targetType: Expression.PrimitiveType(
                    sourceAnchor: expr.sourceAnchor,
                    typ: kSliceType)),
            member: Expression.Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: kSliceBase))
        let sliceType = try typeCheck(rexpr: expr)
        let elementSize = memoryLayoutStrategy.sizeof(type: sliceType.arrayElementType)
        
        let baseExpr: Expression
        if let begin = maybeBegin {
            if begin == 0 {
                baseExpr = arrayBeginExpr
            }
            else {
                baseExpr = Expression.Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .plus,
                    left: arrayBeginExpr,
                    right: Expression.LiteralInt(
                        sourceAnchor: expr.sourceAnchor,
                        value: begin * elementSize))
            }
        }
        else {
            if elementSize == 1 {
                baseExpr = Expression.Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .plus,
                    left: arrayBeginExpr,
                    right: beginExpr)
            }
            else {
                baseExpr = Expression.Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .plus,
                    left: arrayBeginExpr,
                    right: Expression.Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .star,
                        left: beginExpr,
                        right: Expression.LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: elementSize)))
            }
        }
        
        let countExpr: Expression
        if let begin = maybeBegin, let limit = maybeLimit {
            countExpr = Expression.LiteralInt(
                sourceAnchor: expr.sourceAnchor,
                value: limit - begin)
        }
        else {
            countExpr = Expression.Binary(
                sourceAnchor: expr.sourceAnchor,
                op: .minus,
                left: limitExpr,
                right: beginExpr)
        }
        
        let sliceExpr = Expression.StructInitializer(
            sourceAnchor: expr.sourceAnchor,
            identifier: Expression.Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: kSliceName),
            arguments: [
                Expression.StructInitializer.Argument(name: kSliceBase, expr: baseExpr),
                Expression.StructInitializer.Argument(name: kSliceCount, expr: countExpr)
            ])
        let bitcastExpr = Expression.Bitcast(
            sourceAnchor: expr.sourceAnchor,
            expr: sliceExpr,
            targetType: Expression.PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: sliceType))
        children.append(try rvalue(expr: bitcastExpr))
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    func computeAddressOfSymbol(sourceAnchor: SourceAnchor?, symbol: Symbol, depth: Int) -> Seq {
        assert(depth >= 0)
        var children: [AbstractSyntaxTreeNode] = []
        switch symbol.storage {
        case .staticStorage:
            let temp = nextRegister(type: .p)
            pushRegister(temp)
            children += [
                TackInstructionNode(
                    instruction: .lip(temp.unwrapPointer!, symbol.offset),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols
                )
            ]
        case .automaticStorage:
            children += [
                computeAddressOfLocalVariable(
                    sourceAnchor: sourceAnchor,
                    offset: symbol.offset,
                    depth: depth)
            ]
        }
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }
    
    func computeAddressOfLocalVariable(sourceAnchor: SourceAnchor?, offset: Int, depth: Int) -> Seq {
        assert(depth >= 0)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        let temp_framePointer: RegisterPointer
        
        if depth == 0 {
            temp_framePointer = .fp
        } else {
            temp_framePointer = nextRegister(type: .p).unwrapPointer!
            
            children += [
                TackInstructionNode(
                    instruction: .lp(temp_framePointer, .fp, 0),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols)
            ]
            
            // Follow the frame pointer `depth' times.
            for _ in 1..<depth {
                children += [
                    TackInstructionNode(
                        instruction: .lp(temp_framePointer, temp_framePointer, 0),
                        sourceAnchor: sourceAnchor,
                        symbols: symbols)
                ]
            }
        }
        
        let temp_result = nextRegister(type: .p)
        
        if offset >= 0 {
            children += [
                TackInstructionNode(
                    instruction: .subip(temp_result.unwrapPointer!, temp_framePointer, offset),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols)
            ]
        } else {
            children += [
                TackInstructionNode(
                    instruction: .addip(temp_result.unwrapPointer!, temp_framePointer, -offset),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols)
            ]
        }
        
        pushRegister(temp_result)
        
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }
    
    func lvalue(get expr: Expression.Get) throws -> AbstractSyntaxTreeNode {
        guard let member = expr.member as? Expression.Identifier else {
            throw CompilerError(sourceAnchor: expr.member.sourceAnchor, message: "expected identifier in get expression")
        }
        
        if let structInitializer = expr.expr as? Expression.StructInitializer {
            let argument = structInitializer.arguments.first(where: {$0.name == member.identifier})
            let memberExpr = argument!.expr
            return try lvalue(expr: memberExpr)
        }
        
        let name = member.identifier
        let resultType = try typeCheck(rexpr: expr.expr)
        var children: [AbstractSyntaxTreeNode] = []
        
        switch resultType {
        case .constStructType(let typ), .structType(let typ):
            let symbol = try typ.symbols.resolve(identifier: name)
            
            children += [
                try lvalue(expr: expr.expr)
            ]
            let tempStructAddress = popRegister().unwrapPointer!
            let dst = nextRegister(type: .p)
            pushRegister(dst)
            children += [
                TackInstructionNode(
                    instruction: .addip(dst.unwrapPointer!, tempStructAddress, symbol.offset),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
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
                    let tempStructAddress = popRegister().unwrapPointer!
                    let dst = nextRegister(type: .p)
                    pushRegister(dst)
                    children += [
                        TackInstructionNode(
                            instruction: .addip(dst.unwrapPointer!, tempStructAddress, symbol.offset),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols)
                    ]
                    
                default:
                    fatalError("unimplemented: typ=\(typ)")
                }
            }
        
        default:
            fatalError("unimplemented: resultType=\(resultType)")
        }
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    public func rvalue(expr expr0: Expression) throws -> AbstractSyntaxTreeNode {
        try typeCheck(rexpr: expr0)
        let expr1 = switch expr0 {
        case let group as Expression.Group:
            try rvalue(expr: group.expression)
        case let literal as Expression.LiteralInt:
            rvalue(literalInt: literal)
        case let literal as Expression.LiteralBool:
            rvalue(literalBoolean: literal)
        case let literal as Expression.LiteralArray:
            try rvalue(literalArray: literal)
        case let literal as Expression.LiteralString:
            try rvalue(literalString: literal)
        case let node as Expression.Identifier:
            try rvalue(identifier: node)
        case let node as Expression.As:
            try rvalue(as: node)
        case let node as Expression.Bitcast:
            try rvalue(bitcast: node)
        case let node as Expression.Unary:
            try rvalue(unary: node)
        case let node as Expression.Binary:
            try rvalue(binary: node)
        case let expr as Expression.Is:
            try rvalue(is: expr)
        case let expr as Expression.Assignment:
            try rvalue(assignment: expr)
        case let expr as Expression.Subscript:
            try rvalue(subscript: expr)
        case let expr as Expression.Get:
            try rvalue(get: expr)
        case let node as Expression.StructInitializer:
            try rvalue(structInitializer: node)
        case let node as Expression.Call:
            try rvalue(call: node)
        case let node as Expression.SizeOf:
            try rvalue(sizeof: node)
        case let eseq as Expression.Eseq:
            try rvalue(eseq: eseq)
        case let node as Expression.GenericTypeApplication:
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "internal compiler error: expected generics to have been erased by this point: `\(node)'")
        default:
            throw CompilerError(sourceAnchor: expr0.sourceAnchor, message: "internal compiler error: unimplemented support for expression in CoreToTackCompiler: `\(expr0)'")
        }
        let expr2 = try expr1.flatten() ?? Seq(sourceAnchor: expr1.sourceAnchor, children: [])
        return expr2
    }
    
    func rvalue(literalInt node: Expression.LiteralInt) -> AbstractSyntaxTreeNode {
        let result: AbstractSyntaxTreeNode
        switch ArithmeticTypeInfo.compTimeInt(node.value).intClass {
        case .i8:
            let dest = nextRegister(type: .b)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .lib(dest.unwrap8!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols)
            
        case .u8:
            let dest = nextRegister(type: .b)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .liub(dest.unwrap8!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols)
            
        case .i16:
            let dest = nextRegister(type: .w)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .liw(dest.unwrap16!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols)
            
        case .u16:
            let dest = nextRegister(type: .w)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .liuw(dest.unwrap16!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols)
            
        case .none:
            fatalError("Expected to be able to determine the type of an integer literal at this point: \(node)")
        }
        
        return result
    }
    
    func rvalue(literalBoolean node: Expression.LiteralBool) -> AbstractSyntaxTreeNode {
        let dest = nextRegister(type: .o)
        pushRegister(dest)
        let result = TackInstructionNode(
            instruction: .lio(dest.unwrapBool!, node.value),
            sourceAnchor: node.sourceAnchor,
            symbols: symbols)
        return result
    }
    
    func rvalue(literalArray expr: Expression.LiteralArray) throws -> AbstractSyntaxTreeNode {
        let arrayType = try typeCheck(rexpr: expr)
        let arrayElementType = try typeCheck(rexpr: expr.arrayType).arrayElementType
        if arrayElementType.isPrimitive {
            let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, Expression.PrimitiveType(
                    sourceAnchor: expr.sourceAnchor,
                    typ: arrayType))
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(identifier: tempArrayId)
            ]
            let tempArrayAddr = popRegister()
            for i in 0..<expr.elements.count {
                children += [
                    try rvalue(as: Expression.As(expr: expr.elements[i], targetType: Expression.PrimitiveType(arrayElementType)))
                ]
                
                let resultRegister = popRegister()
                let ins: TackInstruction = {
                    switch resultRegister {
                    case .p(let src): return .sp(src, tempArrayAddr.unwrapPointer!, i)
                    case .w(let src): return .sw(src, tempArrayAddr.unwrapPointer!, i)
                    case .b(let src): return .sb( src, tempArrayAddr.unwrapPointer!, i)
                    case .o(let src): return .so( src, tempArrayAddr.unwrapPointer!, i)
                    }
                }()
                
                children += [
                    TackInstructionNode(
                        instruction: ins,
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
            }
            pushRegister(tempArrayAddr)
            return Seq(sourceAnchor: expr.sourceAnchor, children: children)
        } else {
            let savedRegisterStack = registerStack
            let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, expr.arrayType)
            var children: [AbstractSyntaxTreeNode] = []
            for i in 0..<expr.elements.count {
                let slot = Expression.Subscript(
                    sourceAnchor: expr.sourceAnchor,
                    subscriptable: tempArrayId,
                    argument: Expression.LiteralInt(
                        sourceAnchor: expr.sourceAnchor,
                        value: i))
                let child =  try rvalue(expr: Expression.Assignment(
                    sourceAnchor: expr.sourceAnchor,
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
    }
    
    func makeCompilerTemporary(_ sourceAnchor: SourceAnchor?, _ type: Expression) throws -> Expression.Identifier {
        let tempArrayId = Expression.Identifier(
            sourceAnchor: sourceAnchor,
            identifier: symbols!.tempName(prefix: "__temp"))
        let tempDecl = VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: tempArrayId,
            explicitType: type,
            expression: nil,
            storage: .automaticStorage,
            isMutable: true,
            visibility: .privateVisibility)
        let varDeclCompiler = SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
        let _ = try varDeclCompiler.compile(tempDecl)
        return tempArrayId
    }
    
    func rvalue(literalString expr: Expression.LiteralString) throws -> AbstractSyntaxTreeNode {
        let arrayType = Expression.ArrayType(
            sourceAnchor: expr.sourceAnchor,
            count: Expression.LiteralInt(
                sourceAnchor: expr.sourceAnchor,
                value: expr.value.count),
            elementType: Expression.PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: .u8))
        let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, arrayType)
        return Seq(sourceAnchor: expr.sourceAnchor, children: [
            try lvalue(identifier: tempArrayId),
            TackInstructionNode(
                instruction: .ststr(peekRegister().unwrapPointer!, expr.value),
                sourceAnchor: expr.sourceAnchor,
                symbols: symbols)
        ])
    }
    
    func rvalue(identifier node: Expression.Identifier) throws -> AbstractSyntaxTreeNode {
        let symbol = try symbols!.resolve(identifier: node.identifier)
        
        var children: [AbstractSyntaxTreeNode] = [
            try lvalue(expr: node)
        ]
        
        if let primitiveType = symbol.type.primitiveType {
            let addr = popRegister().unwrapPointer!
            let dest = nextRegister(type: primitiveType)
            
            let ins: TackInstruction = {
                switch primitiveType {
                case .p: return .lp(dest.unwrapPointer!, addr, 0)
                case .w: return .lw(dest.unwrap16!, addr, 0)
                case .b: return .lb(dest.unwrap8!, addr, 0)
                case .o: return .lo(dest.unwrapBool!, addr, 0)
                }
            }()
            
            pushRegister(dest)
            children += [
                TackInstructionNode(
                    instruction: ins,
                    sourceAnchor: node.sourceAnchor,
                    symbols: symbols)
            ]
        }
        
        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    func rvalue(as expr: Expression.As) throws -> AbstractSyntaxTreeNode {
        let targetType = try typeCheck(rexpr: expr.targetType)
        if case .array = targetType, let literalArray0 = expr.expr as? Expression.LiteralArray {
            let elementType = targetType.arrayElementType
            let elements = literalArray0.elements.map {
                Expression.As(
                    sourceAnchor: expr.sourceAnchor,
                    expr: $0,
                    targetType: Expression.PrimitiveType(
                        sourceAnchor: expr.sourceAnchor,
                        typ: elementType))
            }
            let literalArray1 = Expression.LiteralArray(
                sourceAnchor: literalArray0.sourceAnchor,
                arrayType: expr.targetType,
                elements: elements)
            return try rvalue(literalArray: literalArray1)
        }
        else {
            return try compileAndConvertExpression(
                rexpr: expr.expr,
                ltype: targetType,
                isExplicitCast: true)
        }
    }
    
    func rvalue(bitcast expr: Expression.Bitcast) throws -> AbstractSyntaxTreeNode {
        var children: [AbstractSyntaxTreeNode] = [
            try rvalue(expr: expr.expr)
        ]
        let targetType = try typeCheck(rexpr: expr)
        let registerType = targetType.primitiveType ?? .p
        if peekRegister().type != registerType {
            let a = popRegister()
            let b = nextRegister(type: registerType)
            pushRegister(b)
            children += [
                TackInstructionNode(
                    instruction: .bitcast(b, a),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
        }
        let seq = Seq(sourceAnchor: expr.sourceAnchor, children: children)
        return seq
    }
    
    func compileAndConvertExpression(rexpr: Expression, ltype: SymbolType, isExplicitCast: Bool) throws -> AbstractSyntaxTreeNode {
        if let getExpr = rexpr as? Expression.Get,
           let member = getExpr.member as? Expression.Identifier,
           let structInitializer = getExpr.expr as? Expression.StructInitializer {
            let argument = structInitializer.arguments.first(where: {$0.name == member.identifier})
            let memberExpr = argument!.expr
            let result = try compileAndConvertExpression(
                rexpr: memberExpr,
                ltype: ltype,
                isExplicitCast: isExplicitCast)
            return result
        }
        
        let rtype = try typeCheck(rexpr: rexpr)
        
        if canValueBeTriviallyReinterpreted(ltype, rtype) {
            // The expression produces a value whose bitpattern can be trivially
            // reinterpreted as the target type.
            return try rvalue(expr: rexpr)
        }
        
        let result: AbstractSyntaxTreeNode
        
        switch (rtype, ltype) {
        case (.booleanType(.compTimeBool(let a)), .bool),
             (.booleanType(.compTimeBool(let a)), .constBool):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .o)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .lio(dst.unwrapBool!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols)
            
        case (.arithmeticType(.compTimeInt(let a)), .u8),
             (.arithmeticType(.compTimeInt(let a)), .arithmeticType(.immutableInt(.u8))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .b)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .liub(dst.unwrap8!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols)
            
        case (.arithmeticType(.compTimeInt(let a)), .i8),
             (.arithmeticType(.compTimeInt(let a)), .arithmeticType(.immutableInt(.i8))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .b)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .lib(dst.unwrap8!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols)
            
        case (.arithmeticType(.compTimeInt(let a)), .i16),
             (.arithmeticType(.compTimeInt(let a)), .arithmeticType(.immutableInt(.i16))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .w)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .liw(dst.unwrap16!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols)
            
        case (.arithmeticType(.compTimeInt(let a)), .u16),
             (.arithmeticType(.compTimeInt(let a)), .arithmeticType(.immutableInt(.u16))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .w)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .liuw(dst.unwrap16!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols)
            
        case (.arithmeticType(let src), .arithmeticType(let dst)):
            switch (src.intClass, dst.intClass) {
            case (.i8, .i16),
                 (.i8, .u16):
                var children: [AbstractSyntaxTreeNode] = []
                children += [
                    try rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .w)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movswb(dst.unwrap16!, src.unwrap8!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
                
            case (.u8, .i16),
                 (.u8, .u16):
                var children: [AbstractSyntaxTreeNode] = []
                children += [
                    try rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .w)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movzwb(dst.unwrap16!, src.unwrap8!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
                
            case (.u16, .u8),
                 (.u16, .i8):
                // Convert from u16 to u8 by masking off the upper byte.
                assert(isExplicitCast)
                var children: [AbstractSyntaxTreeNode] = []
                children += [
                    try rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .b)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movzbw(dst.unwrap8!, src.unwrap16!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
                
            case (.i16, .u8),
                 (.i16, .i8):
                // The upper byte of the result will contain a sign-extension of
                // the lower byte instead of the original upper byte, which has
                // been discarded.
                assert(isExplicitCast)
                var children: [AbstractSyntaxTreeNode] = []
                children += [
                    try rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .b)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movsbw(dst.unwrap8!, src.unwrap16!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
                
            case (.i16, .u16),
                 (.u16, .i16),
                 (.u8, .i8),
                 (.i8, .u8):
                result = try rvalue(expr: rexpr)
                
            default:
                fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
            }
            
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
                        lexpr: Expression.Subscript(
                            sourceAnchor: rexpr.sourceAnchor,
                            subscriptable: tempArrayId,
                            argument: Expression.LiteralInt(
                                sourceAnchor: rexpr.sourceAnchor,
                                value: i)),
                        rexpr: Expression.As(
                            sourceAnchor: rexpr.sourceAnchor,
                            expr: Expression.Subscript(
                                sourceAnchor: rexpr.sourceAnchor,
                                subscriptable: rexpr,
                                argument: Expression.LiteralInt(
                                    sourceAnchor: rexpr.sourceAnchor,
                                    value: i)),
                            targetType: Expression.PrimitiveType(
                                sourceAnchor: rexpr.sourceAnchor,
                                typ: b))))
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
                TackInstructionNode(
                    instruction: { resultRegister in
                        switch resultRegister {
                        case .p(let p): return .sp(p, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        case .w(let w): return .sw(w, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        case .b(let b): return .sb(b, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        case .o(let o): return .so(o, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        }
                    }(popRegister()),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols)
            ]
            let countReg = nextRegister(type: .w).unwrap16!
            children += [
                TackInstructionNode(
                    instruction: .liuw(countReg, n),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols),
                TackInstructionNode(
                    instruction: .sw(countReg, dst.unwrapPointer!, kSliceCountOffset),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols)
            ]
            registerStack = savedRegisterStack
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (_, .unionType(let typ)):
            let tempArrayId = try makeCompilerTemporary(rexpr.sourceAnchor, Expression.PrimitiveType(
                    sourceAnchor: rexpr.sourceAnchor,
                    typ: ltype))
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(expr: tempArrayId)
            ]
            let tempUnionAddr = popRegister()
            let tempUnionTypeTag = nextRegister(type: .w).unwrap16!
            let targetType = determineUnionTargetType(typ, rtype)!
            let unionTypeTag = determineUnionTypeTag(typ, targetType)!
            children += [
                TackInstructionNode(
                    instruction: .liuw(tempUnionTypeTag, unionTypeTag),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols),
                TackInstructionNode(
                    instruction: .sw(tempUnionTypeTag, tempUnionAddr.unwrapPointer!, kUnionTypeTagOffset),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols)
            ]
            if targetType.isPrimitive {
                children += [
                    try rvalue(as: Expression.As(
                        sourceAnchor: rexpr.sourceAnchor,
                        expr: rexpr,
                        targetType: Expression.PrimitiveType(
                            sourceAnchor: rexpr.sourceAnchor,
                            typ: targetType))),
                    TackInstructionNode(
                        instruction: { resultRegister in
                            switch resultRegister {
                            case .p(let p): return .sp(p, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            case .w(let w): return .sw(w, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            case .b(let b): return .sb(b, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            case .o(let o): return .so(o, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            }
                        }(popRegister()),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
                ]
            } else {
                let size = memoryLayoutStrategy.sizeof(type: rtype)
                let tempUnionPayloadAddress = nextRegister(type: .p).unwrapPointer!
                children += [
                    TackInstructionNode(
                        instruction: .addip(tempUnionPayloadAddress, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols),
                    try rvalue(as: Expression.As(
                        sourceAnchor: rexpr.sourceAnchor,
                        expr: rexpr,
                        targetType: Expression.PrimitiveType(
                            sourceAnchor: rexpr.sourceAnchor,
                            typ: targetType))),
                    TackInstructionNode(
                        instruction: .memcpy(tempUnionPayloadAddress, popRegister().unwrapPointer!, size),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
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
            if options.isBoundsCheckEnabled && typ.members.count > 1 {
                let targetType = determineUnionTargetType(typ, ltype)!
                let unionTypeTag = determineUnionTypeTag(typ, targetType)!
                let tempUnionTag = nextRegister(type: .w)
                let tempComparison = nextRegister(type: .w)
                let labelSkipPanic = symbols!.nextLabel()
                children += [
                    TackInstructionNode(
                        instruction: .lw(tempUnionTag.unwrap16!, tempUnionAddr.unwrapPointer!, kUnionTypeTagOffset),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .subiw(tempComparison.unwrap16!, tempUnionTag.unwrap16!, unionTypeTag),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .bzw(tempComparison.unwrap16!, labelSkipPanic),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .call(kOOB),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols),
                    LabelDeclaration(
                        sourceAnchor: rexpr.sourceAnchor,
                        identifier: labelSkipPanic)
                ]
            }
            
            if let primitiveType = ltype.primitiveType {
                let dst = nextRegister(type: primitiveType)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: {
                            switch dst {
                            case .p(let p): return .lp(p, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            case .w(let w): return .lw(w, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            case .b(let b): return .lb(b, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            case .o(let o): return .lo(o, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset)
                            }
                        }(),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
                ]
            } else {
                let dst = nextRegister(type: .p)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .addip(dst.unwrapPointer!, tempUnionAddr.unwrapPointer!, kUnionPayloadOffset),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols)
                ]
            }
            
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)
            
        case (.constPointer(let a), .traitType(let b)),
             (.pointer(let a), .traitType(let b)),
             (.constPointer(let a), .constTraitType(let b)),
             (.pointer(let a), .constTraitType(let b)):
            let structType = a.unwrapStructType()
            let nameOfVtableInstance = nameOfVtableInstance(
                traitName: b.name,
                structName: structType.name)
            result = try rvalue(expr: Expression.StructInitializer(
                sourceAnchor: rexpr.sourceAnchor,
                expr: Expression.Identifier(
                    sourceAnchor: rexpr.sourceAnchor,
                    identifier: b.nameOfTraitObjectType),
                arguments: [
                    // Take the pointer to the object and cast as an opaque *void
                    Expression.StructInitializer.Argument(
                        name: "object",
                        expr: Expression.Bitcast(
                            sourceAnchor: rexpr.sourceAnchor,
                            expr: rexpr,
                            targetType: Expression.PointerType(
                                sourceAnchor: rexpr.sourceAnchor,
                                typ: Expression.PrimitiveType(
                                    sourceAnchor: rexpr.sourceAnchor,
                                    typ: .void)))),
                
                    // Attach a pointer to the appropriate vtable instance.
                    Expression.StructInitializer.Argument(
                        name: "vtable",
                        expr: Expression.Unary(
                            sourceAnchor: rexpr.sourceAnchor,
                            op: .ampersand,
                            expression: Expression.Identifier(
                                sourceAnchor: rexpr.sourceAnchor,
                                identifier: nameOfVtableInstance)))
            ]))
            
        case (.constStructType(let structType), .traitType(let b)),
             (.structType(let structType), .traitType(let b)),
             (.constStructType(let structType), .constTraitType(let b)),
             (.structType(let structType), .constTraitType(let b)):
            let nameOfVtableInstance = nameOfVtableInstance(
                traitName: b.name,
                structName: structType.name)
            let objectPointer = Expression.Unary(
                sourceAnchor: rexpr.sourceAnchor,
                op: .ampersand,
                expression: rexpr)
            result = try rvalue(expr: Expression.StructInitializer(
                sourceAnchor: rexpr.sourceAnchor,
                identifier: Expression.Identifier(
                    sourceAnchor: rexpr.sourceAnchor,
                    identifier: b.nameOfTraitObjectType),
                arguments: [
                    // Take the pointer to the object and cast as an opaque *void
                    Expression.StructInitializer.Argument(name: "object", expr: Expression.Bitcast(
                            sourceAnchor: rexpr.sourceAnchor,
                            expr: objectPointer,
                            targetType: Expression.PointerType(
                                sourceAnchor: rexpr.sourceAnchor,
                                typ: Expression.PrimitiveType(
                                    sourceAnchor: rexpr.sourceAnchor,
                                    typ: .void)))),
                
                    // Attach a pointer to the appropriate vtable instance.
                    Expression.StructInitializer.Argument(
                        name: "vtable",
                        expr: Expression.Unary(
                            sourceAnchor: rexpr.sourceAnchor,
                            op: .ampersand,
                            expression: Expression.Identifier(
                                sourceAnchor: rexpr.sourceAnchor,
                                identifier: nameOfVtableInstance)))
                ]))
            
        case (_, .constPointer(let b)),
             (_, .pointer(let b)):
            if rtype.correspondingConstType == b.correspondingConstType {
                result = try lvalue(expr: rexpr)
            }
            else {
                switch rtype {
                case .traitType(let a), .constTraitType(let a):
                    let traitObjectType = try? symbols!.resolveType(identifier: a.nameOfTraitObjectType)
                    if traitObjectType == b {
                        result = try lvalue(expr: rexpr)
                    }
                    else {
                        fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
                    }
                    
                default:
                    fatalError("Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)")
                }
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
        case (.booleanType(let a), .booleanType(let b)):
            result = a.canValueBeTriviallyReinterpretedAs(type: b)
            
        case (.arithmeticType(let a), .arithmeticType(let b)):
            result = a.canValueBeTriviallyReinterpretedAs(type: b)
            
        case (.constPointer, .constPointer),
             (.constPointer, .pointer),
             (.pointer, .constPointer),
             (.pointer, .pointer),
             (.constDynamicArray, .constDynamicArray),
             (.constDynamicArray, .dynamicArray),
             (.dynamicArray, .constDynamicArray),
             (.dynamicArray, .dynamicArray),
             (.unionType, .unionType),
             (.traitType, .constTraitType),
             (.constTraitType, .traitType),
             (.structType, .constStructType),
             (.constStructType, .structType):
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
        let childType = try typeCheck(rexpr: expr.child).correspondingMutableType
        
        let result: AbstractSyntaxTreeNode
        
        if expr.op == .ampersand {
            switch childType {
            case .function(let typ):
                let label = typ.mangledName ?? typ.name!
                let dst = nextRegister(type: .p)
                result = TackInstructionNode(
                    instruction: .la(dst.unwrapPointer!, label),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
                pushRegister(dst)
            default:
                result = try lvalue(expr: expr.child)
            }
        } else {
            let childExpr = try rvalue(expr: expr.child)
            let b = popRegister()
            
            var instructions: [AbstractSyntaxTreeNode] = [childExpr]
            
            switch (childType, expr.op) {
            case (.booleanType, .bang):
                let c = nextRegister(type: .o)
                pushRegister(c)
                instructions += [
                    TackInstructionNode(
                        instruction: .not(c.unwrapBool!, b.unwrapBool!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
                
            case (.u8, .minus),
                 (.i8, .minus):
                let a = nextRegister(type: .b)
                let c = nextRegister(type: .b)
                pushRegister(c)
                instructions += [
                    TackInstructionNode(
                        instruction: .liub(a.unwrap8!, 0),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .subb(c.unwrap8!, a.unwrap8!, b.unwrap8!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
                
            case (.u16, .minus),
                 (.i16, .minus):
                let a = nextRegister(type: .w)
                let c = nextRegister(type: .w)
                pushRegister(c)
                instructions += [
                    TackInstructionNode(
                        instruction: .liuw(a.unwrap16!, 0),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols),
                    TackInstructionNode(
                        instruction: .subw(c.unwrap16!, a.unwrap16!, b.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
                
            case (.u8, .tilde),
                 (.i8, .tilde):
                let c = nextRegister(type: .b)
                pushRegister(c)
                instructions += [
                    TackInstructionNode(
                        instruction: .negb(c.unwrap8!, b.unwrap8!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
                
            case (.u16, .tilde),
                 (.i16, .tilde):
                let c = nextRegister(type: .w)
                pushRegister(c)
                instructions += [
                    TackInstructionNode(
                        instruction: .negw(c.unwrap16!, b.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
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
            return try compileArithmeticBinaryExpression(binary)
        }
        
        if leftType.isBooleanType && rightType.isBooleanType {
            return try compileBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
    }
    
    func compileArithmeticBinaryExpression(_ binary: Expression.Binary) throws -> AbstractSyntaxTreeNode {
        
        let resultType = try typeCheck(rexpr: binary)
        let rightType = try typeCheck(rexpr: binary.right)
        let leftType = try typeCheck(rexpr: binary.left)
            
        switch (leftType, rightType) {
        case (.arithmeticType(.compTimeInt), .arithmeticType(.compTimeInt)):
            return try compileConstantArithmeticBinaryExpression(binary, leftType, rightType)
        
        case (.arithmeticType(let leftArithmeticType), .arithmeticType(let rightArithmeticType)):
            if let arithmeticTypeForArithmetic = ArithmeticTypeInfo.binaryResultType(left: leftArithmeticType, right: rightArithmeticType) {
                let intClass: IntClass = arithmeticTypeForArithmetic.intClass!
                let typeForArithmetic: SymbolType = .arithmeticType(arithmeticTypeForArithmetic)
                
                let right = try compileAndConvertExpression(rexpr: binary.right, ltype: typeForArithmetic, isExplicitCast: false)
                let left = try compileAndConvertExpression(rexpr: binary.left, ltype: typeForArithmetic, isExplicitCast: false)
                
                let a = popRegister()
                let b = popRegister()
                let c = nextRegister(type: resultType.primitiveType!)
                pushRegister(c)
                
                let ins = try determineArithmeticInstruction(
                    binary,
                    leftType,
                    rightType,
                    intClass,
                    c,
                    a,
                    b)
                
                return Seq(
                    sourceAnchor: binary.sourceAnchor,
                    children: [
                        right,
                        left,
                        TackInstructionNode(
                            instruction: ins,
                            sourceAnchor: binary.sourceAnchor,
                            symbols: symbols)
                    ])
            }
            
        default:
            break
        }
        
        fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
    }
    
    func determineArithmeticInstruction(
        _ binary: Expression.Binary,
        _ leftType: SymbolType,
        _ rightType: SymbolType,
        _ intClass: IntClass,
        _ c: Register,
        _ a: Register,
        _ b: Register) throws -> TackInstruction {
        
        let ins: TackInstruction
        switch binary.op {
        case .eq:
            switch intClass {
            case .i8, .u8:
                ins = .eqb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .eqw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            }
        case .ne:
            switch intClass {
            case .i8, .u8:
                ins = .neb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .new(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            }
        case .lt:
            switch intClass {
            case .i8:
                ins = .ltb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .u8:
                ins = .ltub(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16:
                ins = .ltw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            case .u16:
                ins = .ltuw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            }
        case .gt:
            switch intClass {
            case .i8:
                ins = .gtb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .u8:
                ins = .gtub(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16:
                ins = .gtw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            case .u16:
                ins = .gtuw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            }
        case .le:
            switch intClass {
            case .i8:
                ins = .leb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .u8:
                ins = .leub(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16:
                ins = .lew(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            case .u16:
                ins = .leuw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            }
        case .ge:
            switch intClass {
            case .i8:
                ins = .geb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .u8:
                ins = .geub(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16:
                ins = .gew(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            case .u16:
                ins = .geuw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            }
        case .plus:
            switch intClass {
            case .i8, .u8:
                ins = .addb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .addw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .minus:
            switch intClass {
            case .i8, .u8:
                ins = .subb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .subw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .star:
            switch intClass {
            case .i8, .u8:
                ins = .mulb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .mulw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .divide:
            switch intClass {
            case .i8:  ins = .divb( c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .u8:  ins = .divub(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16: ins = .divw( c.unwrap16!, a.unwrap16!, b.unwrap16!)
            case .u16: ins = .divuw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .modulus:
            switch intClass {
            case .i8, .u8:
                ins = .modb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .modw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .ampersand:
            switch intClass {
            case .i8, .u8:
                ins = .andb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .andw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .pipe:
            switch intClass {
            case .i8, .u8:
                ins = .orb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .orw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .caret:
            switch intClass {
            case .i8, .u8:
                ins = .xorb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .xorw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .leftDoubleAngle:
            switch intClass {
            case .i8, .u8:
                ins = .lslb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .lslw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .rightDoubleAngle:
            switch intClass {
            case .i8, .u8:
                ins = .lsrb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16, .u16:
                ins = .lsrw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        default:
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        return ins
    }
    
    func compileConstantArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> AbstractSyntaxTreeNode {
        guard case .arithmeticType(.compTimeInt(let a)) = leftType, case .arithmeticType(.compTimeInt(let b)) = rightType else {
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
        let exprType = try typeCheck(rexpr: binary)
        
        guard let primitiveType = exprType.primitiveType else {
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        let dst = nextRegister(type: primitiveType)
        pushRegister(dst)
        
        switch exprType {
        case .arithmeticType(let arithmeticType):
            switch arithmeticType.intClass {
            case .u8:
                ins = .liub(dst.unwrap8!, value)
            case .u16:
                ins = .liuw(dst.unwrap16!, value)
            case .i8:
                ins = .lib(dst.unwrap8!, value)
            case .i16:
                ins = .liw(dst.unwrap16!, value)
            case .none:
                fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
            }
        case .booleanType:
            ins = .lio(dst.unwrapBool!, value==0 ? false : true)
        default:
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        
        return TackInstructionNode(
            instruction: ins,
            sourceAnchor: binary.sourceAnchor,
            symbols: symbols)
    }
    
    func compileBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> AbstractSyntaxTreeNode {
        assert(leftType.isBooleanType && rightType.isBooleanType)

        if case .booleanType(.compTimeBool) = leftType, case .booleanType(.compTimeBool) = rightType {
            return try compileConstantBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        switch binary.op {
        case .eq:
            let right = try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
            let left = try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false)
            let a = popRegister()
            let b = popRegister()
            let c = nextRegister(type: .o)
            pushRegister(c)
            let op = TackInstructionNode(
                instruction: {
                    assert(a.type == b.type)
                    switch a.type {
                    case .p: return .eqp(c.unwrapBool!, a.unwrapPointer!, b.unwrapPointer!)
                    case .w: return .eqw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
                    case .b: return .eqb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
                    case .o: return .eqo(c.unwrapBool!, a.unwrapBool!, b.unwrapBool!)
                    }
                }(),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols)
            return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])
            
        case .ne:
            let right = try compileAndConvertExpression(rexpr: binary.right, ltype: .bool, isExplicitCast: false)
            let left = try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false)
            let a = popRegister()
            let b = popRegister()
            let c = nextRegister(type: .o)
            pushRegister(c)
            let op = TackInstructionNode(
                instruction: {
                    assert(a.type == b.type)
                    switch a.type {
                    case .p: return .nep(c.unwrapBool!, a.unwrapPointer!, b.unwrapPointer!)
                    case .w: return .new(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
                    case .b: return .neb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
                    case .o: return .neo(c.unwrapBool!, a.unwrapBool!, b.unwrapBool!)
                    }
                }(),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols)
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
        guard case .booleanType(.compTimeBool(let a)) = leftType, case .booleanType(.compTimeBool(let b)) = rightType else {
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        
        let value: Bool
        
        switch binary.op {
        case .eq:
            value = (a == b)
            
        case .ne:
            value = (a != b)
            
        case .doubleAmpersand:
            value = (a && b)
            
        case .doublePipe:
            value = (a || b)
            
        default:
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)")
        }
        
        let dst = nextRegister(type: .o)
        pushRegister(dst)
        
        return TackInstructionNode(
            instruction: .lio(dst.unwrapBool!, value),
            sourceAnchor: binary.sourceAnchor,
            symbols: symbols)
    }
    
    func logicalAnd(_ binary: Expression.Binary) throws -> AbstractSyntaxTreeNode {
        var instructions: [AbstractSyntaxTreeNode] = []
        let labelFalse = symbols!.nextLabel()
        let labelTail = symbols!.nextLabel()
        instructions.append(try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false))
        let a = popRegister()
        instructions += [
            TackInstructionNode(
                instruction: .bz(a.unwrapBool!, labelFalse),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            try compileAndConvertExpression(
                rexpr: binary.right,
                ltype: .bool,
                isExplicitCast: false)
        ]
        let b = popRegister()
        let c = nextRegister(type: .o)
        pushRegister(c)
        instructions += [
            TackInstructionNode(
                instruction: .bz(b.unwrapBool!, labelFalse),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, true),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            TackInstructionNode(
                instruction: .jmp(labelTail),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelFalse),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, false),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelTail)
        ]
        return Seq(sourceAnchor: binary.sourceAnchor, children: instructions)
    }
    
    func logicalOr(_ binary: Expression.Binary) throws -> AbstractSyntaxTreeNode {
        var instructions: [AbstractSyntaxTreeNode] = []
        let labelTrue = symbols!.nextLabel()
        let labelTail = symbols!.nextLabel()
        instructions.append(try compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false))
        let a = popRegister()
        instructions += [
            TackInstructionNode(
                instruction: .bnz(a.unwrapBool!, labelTrue),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            try compileAndConvertExpression(
                rexpr: binary.right,
                ltype: .bool,
                isExplicitCast: false)
        ]
        let b = popRegister()
        let c = nextRegister(type: .o)
        pushRegister(c)
        instructions += [
            TackInstructionNode(
                instruction: .bnz(b.unwrapBool!, labelTrue),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, false),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            TackInstructionNode(
                instruction: .jmp(labelTail),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelTrue),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, true),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelTail)
        ]
        return Seq(sourceAnchor: binary.sourceAnchor, children: instructions)
    }
    
    func rvalue(is expr: Expression.Is) throws -> AbstractSyntaxTreeNode {
        let exprType = try typeCheck(rexpr: expr)
        
        switch exprType {
        case .booleanType(.compTimeBool(let val)):
            let tempResult = nextRegister(type: .o)
            let result = TackInstructionNode(
                instruction: .lio(tempResult.unwrapBool!, val),
                sourceAnchor: expr.sourceAnchor,
                symbols: symbols)
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
    
    func compileUnionTypeIs(_ expr: Expression.Is, _ typ: UnionTypeInfo) throws -> AbstractSyntaxTreeNode {
        var children: [AbstractSyntaxTreeNode] = []
        
        // Take the test type and determine the corresponding type tag.
        let testType = try typeCheck(rexpr: expr.testType)
        let typeTag: Int! = determineUnionTypeTag(typ, testType)
        let tempTestTag = nextRegister(type: .w)
        children += [
            TackInstructionNode(
                instruction: .liw(tempTestTag.unwrap16!, typeTag),
                sourceAnchor: expr.sourceAnchor,
                symbols: symbols)
        ]
        
        // Get the address of the union in memory.
        children += [
            try lvalue(expr: expr.expr)
        ]
        let tempUnionAddr = popRegister()
        
        // Read the union type tag in memory.
        let tempActualTag = nextRegister(type: .w)
        children += [
            TackInstructionNode(
                instruction: .lw(tempActualTag.unwrap16!, tempUnionAddr.unwrapPointer!, 0),
                sourceAnchor: expr.sourceAnchor,
                symbols: symbols)
        ]
        
        // Compare the union's actual type tag against the tag of the test type.
        let tempResult = nextRegister(type: .o)
        children += [
            TackInstructionNode(
                instruction: .eqw(tempResult.unwrapBool!, tempActualTag.unwrap16!, tempTestTag.unwrap16!),
                sourceAnchor: expr.sourceAnchor,
                symbols: symbols)
        ]
        
        pushRegister(tempResult)
        
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }
    
    // Given a type and a related union, determine the type to which to convert
    // when inserting into the union. This is necessary because many types
    // can automatically promote and convert to other types. For example, if
    // the union can hold a u16 then we should automatically convert
    // LiteralInt(1) to u16 in order to insert into the union.
    func determineUnionTargetType(_ typ: UnionTypeInfo, _ rtype: SymbolType) -> SymbolType? {
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
    func determineUnionTypeTag(_ typ: UnionTypeInfo, _ testType: SymbolType) -> Int? {
        for i in 0..<typ.members.count {
            let member = typ.members[i]
            if testType == member || testType.correspondingConstType == member {
                return i
            }
        }
        return nil
    }
    
    func rvalue(assignment expr: Expression.Assignment) throws -> AbstractSyntaxTreeNode {
        guard let ltype = try typeCheck(lexpr: expr.lexpr) else {
            throw CompilerError(sourceAnchor: expr.lexpr.sourceAnchor,
                                message: "lvalue required in assignment")
        }
        
        guard false==ltype.isConst || (expr is Expression.InitialAssignment) else {
            fatalError("Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(expr)")
        }
        
        let size = memoryLayoutStrategy.sizeof(type: ltype)
        let result: Seq
        
        if ltype.isPrimitive {
            let lvalueProc = try lvalue(expr: expr.lexpr)
            let dst = popRegister()
            let rvalueProc = try compileAndConvertExpression(rexpr: expr.rexpr, ltype: ltype, isExplicitCast: false)
            let src = peekRegister()
            
            result = Seq(sourceAnchor: expr.sourceAnchor, children: [
                lvalueProc,
                rvalueProc,
                TackInstructionNode(
                    instruction: {
                        switch src {
                        case .p(let p): return .sp(p, dst.unwrapPointer!, 0)
                        case .w(let w): return .sw(w, dst.unwrapPointer!, 0)
                        case .b(let b): return .sb(b, dst.unwrapPointer!, 0)
                        case .o(let o): return .so(o, dst.unwrapPointer!, 0)
                        }
                    }(),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ])
        } else if size == 0 {
            result = Seq(sourceAnchor: expr.sourceAnchor, children: [
                try lvalue(expr: expr.lexpr)
            ])
        } else if let structInitializer = expr.rexpr as? Expression.StructInitializer {
            let children = try structInitializer.arguments.map {
                let g = Expression.Get(sourceAnchor: expr.lexpr.sourceAnchor,
                                       expr: expr.lexpr,
                                       member: Expression.Identifier($0.name))
                let assig: Expression.Assignment
                if expr is Expression.InitialAssignment {
                    assig = Expression.InitialAssignment(
                        sourceAnchor: expr.sourceAnchor,
                        lexpr: g,
                        rexpr: $0.expr)
                } else {
                    assig = Expression.Assignment(
                        sourceAnchor: expr.sourceAnchor,
                        lexpr: g,
                        rexpr: $0.expr)
                }
                return assig
            }
            .map {
                try rvalue(expr: $0)
            }
            result = Seq(sourceAnchor: expr.sourceAnchor, children: children)
            // TODO: We don't push a result register on the stack here. This may be a bug.
        } else {
            let lvalueProc = try lvalue(expr: expr.lexpr)
            let dst = popRegister()
            let rvalueProc = try compileAndConvertExpression(rexpr: expr.rexpr, ltype: ltype, isExplicitCast: false)
            let src = peekRegister()
            
            result = Seq(sourceAnchor: expr.sourceAnchor, children: [
                lvalueProc,
                rvalueProc,
                TackInstructionNode(
                    instruction: .memcpy(dst.unwrapPointer!, src.unwrapPointer!, size),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ])
        }
        
        return result
    }
    
    func rvalue(subscript expr: Expression.Subscript) throws -> AbstractSyntaxTreeNode {
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        
        switch subscriptableType {
        case .structType(let typ), .constStructType(let typ):
            guard typ.name == "Range" else {
                fatalError("Cannot subscript an expression of type `\(subscriptableType)'")
            }
            let lowered = Expression.Binary(
                sourceAnchor: expr.sourceAnchor,
                op: .plus,
                left: Expression.Get(
                    sourceAnchor: expr.sourceAnchor,
                    expr: expr.subscriptable,
                    member: Expression.Identifier("begin")),
                right: expr.argument)
            let result = try rvalue(expr: lowered)
            return result
            
        default:
            var children: [AbstractSyntaxTreeNode] = [
                try lvalue(subscript: expr)
            ]
            
            let elementType = try typeCheck(rexpr: expr)
            
            if let primitiveType = elementType.primitiveType {
                let addr = popRegister().unwrapPointer!
                let dest = nextRegister(type: primitiveType)
                pushRegister(dest)
                children += [
                    TackInstructionNode(
                        instruction: {
                            switch dest {
                            case .p(let p): return .lp(p, addr, 0)
                            case .w(let w): return .lw(w, addr, 0)
                            case .b(let b): return .lb(b, addr, 0)
                            case .o(let o): return .lo(o, addr, 0)
                            }
                        }(),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
            }
            
            return Seq(sourceAnchor: expr.sourceAnchor, children: children)
        }
    }
    
    func rvalue(get expr: Expression.Get) throws -> AbstractSyntaxTreeNode {
        guard let member = expr.member as? Expression.Identifier else {
            fatalError("expected identifier in get expression")
        }
        
        if let structInitializer = expr.expr as? Expression.StructInitializer {
            let argument = structInitializer.arguments.first(where: {$0.name == member.identifier})
            guard let memberExpr = argument?.expr else {
                fatalError("unimplemented")
            }
            return try rvalue(expr: memberExpr)
        }
        
        let name = member.identifier
        let resultType = try typeCheck(rexpr: expr.expr)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        switch resultType {
        case .array(count: let count, elementType: _):
            assert(name == "count")
            let countReg = nextRegister(type: .w)
            pushRegister(countReg)
            children += [
                TackInstructionNode(
                    instruction: .liuw(countReg.unwrap16!, count!),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
            
        case .constDynamicArray, .dynamicArray:
            assert(name == "count")
            children += [
                try rvalue(expr: expr.expr)
            ]
            let sliceAddr = popRegister().unwrapPointer!
            let countReg = nextRegister(type: .w)
            pushRegister(countReg)
            children += [
                TackInstructionNode(
                    instruction: .lw(countReg.unwrap16!, sliceAddr, kSliceCountOffset),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
        
        case .constStructType(let typ), .structType(let typ):
            // TODO: The compiler has special handling of Range.count but maybe it shouldn't
            if typ.name == "Range", name == "count" {
                let calcCount = Expression.Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .minus,
                    left: Expression.Get(
                        sourceAnchor: expr.sourceAnchor,
                        expr: expr.expr,
                        member: Expression.Identifier("limit")),
                    right: Expression.Get(
                        sourceAnchor: expr.sourceAnchor,
                        expr: expr.expr,
                        member: Expression.Identifier("begin")))
                let result = try rvalue(binary: calcCount)
                return result
            }
            
            let symbol = try typ.symbols.resolve(identifier: name)
            
            if let primitiveType = symbol.type.primitiveType {
                // Read the field in-place
                children += [
                    try lvalue(expr: expr.expr)
                ]
                let tempStructAddress = popRegister().unwrapPointer!
                let dst = nextRegister(type: primitiveType)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: {
                            switch dst {
                            case .p(let p): return .lp(p, tempStructAddress, symbol.offset)
                            case .w(let w): return .lw(w, tempStructAddress, symbol.offset)
                            case .b(let b): return .lb(b, tempStructAddress, symbol.offset)
                            case .o(let o): return .lo(o, tempStructAddress, symbol.offset)
                            }
                        }(),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
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
                if let primitiveType = typ.primitiveType {
                    let pointerValue = popRegister().unwrapPointer!
                    let pointeeValue = nextRegister(type: primitiveType)
                    pushRegister(pointeeValue)
                    children += [
                        TackInstructionNode(
                            instruction: {
                                switch pointeeValue {
                                case .p(let p): return .lp(p, pointerValue, 0)
                                case .w(let w): return .lw(w, pointerValue, 0)
                                case .b(let b): return .lb(b, pointerValue, 0)
                                case .o(let o): return .lo(o, pointerValue, 0)
                                }
                            }(),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols)
                    ]
                }
            } else {
                switch typ {
                case .array(count: let count, elementType: _):
                    assert(name == "count")
                    let countReg = nextRegister(type: .w)
                    pushRegister(countReg)
                    children += [
                        TackInstructionNode(
                            instruction: .liuw(countReg.unwrap16!, count!),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols)
                    ]
                    
                case .constDynamicArray, .dynamicArray:
                    assert(name == "count")
                    children += [
                        try rvalue(expr: expr.expr)
                    ]
                    let sliceAddr = popRegister().unwrapPointer!
                    let countReg = nextRegister(type: .w)
                    pushRegister(countReg)
                    children += [
                        TackInstructionNode(
                            instruction: .lw(countReg.unwrap16!, sliceAddr, kSliceCountOffset),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols)
                    ]
                    
                case .constStructType(let b), .structType(let b):
                    let symbol = try b.symbols.resolve(identifier: name)
                    
                    if let primitiveType = symbol.type.primitiveType {
                        // If the field is a primitive then load into a register
                        children += [
                            try rvalue(expr: expr.expr)
                        ]
                        let structAddr = popRegister().unwrapPointer!
                        let dst = nextRegister(type: primitiveType)
                        pushRegister(dst)
                        children += [
                            TackInstructionNode(
                                instruction: {
                                    switch dst {
                                    case .p(let p): return .lp(p, structAddr, symbol.offset)
                                    case .w(let w): return .lw(w, structAddr, symbol.offset)
                                    case .b(let b): return .lb(b, structAddr, symbol.offset)
                                    case .o(let o): return .lo(o, structAddr, symbol.offset)
                                    }
                                }(),
                                sourceAnchor: expr.sourceAnchor,
                                symbols: symbols)
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
        let tempArrayId = try makeCompilerTemporary(
            expr.sourceAnchor,
            Expression.PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: resultType))
        var children: [AbstractSyntaxTreeNode] = []
        for arg in expr.arguments {
            let slot = Expression.Get(
                sourceAnchor: expr.sourceAnchor,
                expr: tempArrayId,
                member: Expression.Identifier(
                    sourceAnchor: expr.sourceAnchor,
                    identifier: arg.name))
            let child =  try rvalue(expr: Expression.Assignment(
                sourceAnchor: expr.sourceAnchor,
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
        let calleeType: SymbolType
        if let symbols,
           let identifier = expr.callee as? Expression.Identifier {
            calleeType = try symbols.resolveTypeOfIdentifier(sourceAnchor: identifier.sourceAnchor, identifier: identifier.identifier)
        }
        else {
            calleeType = try typeCheck(rexpr: expr.callee)
        }
        
        switch calleeType {
        case .function(let typ), .pointer(.function(let typ)), .constPointer(.function(let typ)):
            return try rvalue(call: expr, typ: typ)
            
        case .genericFunction(let typ):
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "internal compiler error: expected generics to have been erased by this point: `\(expr)' of type `\(typ)'")
            
        default:
            throw CompilerError(message: "cannot call value of non-function type `\(calleeType)'")
        }
    }
    
    func rvalue(call expr: Expression.Call, typ: FunctionTypeInfo) throws -> AbstractSyntaxTreeNode {
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
    
    fileprivate func rvalueInner(call expr: Expression.Call, typ: FunctionTypeInfo) throws -> AbstractSyntaxTreeNode {
        _ = try RvalueExpressionTypeChecker(symbols: symbols!).checkInner(call: expr, typ: typ)
        
        let calleeType = try typeCheck(rexpr: expr.callee)
        
        // Allocate a temporary to hold the function call return value.
        var tempRetId: Expression.Identifier! = nil
        if typ.returnType != .void {
            tempRetId = try makeCompilerTemporary(
                expr.sourceAnchor,
                Expression.PrimitiveType(
                    sourceAnchor: expr.sourceAnchor,
                    typ: typ.returnType))
        }
        
        let innerBlock = SymbolTable(parent: symbols)
        env.push(innerBlock)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        // Evaluation of expressions for function call arguments may involve
        // allocating memory on the stack. We first evaluate each expression
        // and then copy the value into the function call argument pack.
        assert(expr.arguments.count == typ.arguments.count)
        var tempArgs: [Register] = []
        for i in 0..<typ.arguments.count {
            let argType = typ.arguments[i]
            let argExpr = expr.arguments[i]
            children += [
                try rvalue(expr: Expression.As(
                    sourceAnchor: expr.sourceAnchor,
                    expr: argExpr,
                    targetType: Expression.PrimitiveType(
                        sourceAnchor: expr.sourceAnchor,
                        typ: argType)))
            ]
            tempArgs.append(popRegister())
        }
        
        // Allocate storage on the stack for the return value.
        let returnTypeSize = memoryLayoutStrategy.sizeof(type: typ.returnType)
        var tempReturnValueAddr: Register!
        if returnTypeSize > 0 {
            tempReturnValueAddr = nextRegister(type: .p)
            children += [
                TackInstructionNode(
                    instruction: .alloca(tempReturnValueAddr.unwrapPointer!, returnTypeSize),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
        }
        
        // Allocate stack space for another argument and copy it into the pack.
        for i in 0..<typ.arguments.count {
            let tempArg = tempArgs[i]
            let argType = typ.arguments[i]
            let argTypeSize = memoryLayoutStrategy.sizeof(type: argType)
            let dst = nextRegister(type: .p).unwrapPointer!
            if argTypeSize > 0 {
                children += [
                    TackInstructionNode(
                        instruction: .alloca(dst, argTypeSize),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols)
                ]
                if argType.isPrimitive {
                    children += [
                        TackInstructionNode(
                            instruction: {
                                switch tempArg {
                                case .p(let p): return .sp(p, dst, 0)
                                case .w(let w): return .sw(w, dst, 0)
                                case .b(let b): return .sb(b, dst, 0)
                                case .o(let o): return .so(o, dst, 0)
                                }
                            }(),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols)
                    ]
                } else {
                    children += [
                        TackInstructionNode(
                            instruction: .memcpy(dst, tempArg.unwrapPointer!, argTypeSize),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols)
                    ]
                }
            }
        }
        
        // Make the function call.
        switch calleeType {
        case .function:
            children += [
                TackInstructionNode(
                    instruction: .call(typ.mangledName!),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
            
        case .pointer, .constPointer:
            children += [
                try rvalue(expr: expr.callee),
                TackInstructionNode(
                    instruction: .callptr(popRegister().unwrapPointer!),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
            
        default:
            fatalError("unimplemented")
        }
        
        // Copy the function call return value to the compiler temporary we
        // allocated earlier. Free stack storage allocated earlier.
        if returnTypeSize > 0 {
            children += [
                try lvalue(identifier: tempRetId!),
                TackInstructionNode(
                    instruction: .memcpy(popRegister().unwrapPointer!, tempReturnValueAddr.unwrapPointer!, returnTypeSize),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
        }
        
        // Free up stack storage allocated for arguments and return value.
        let argPackSize = typ.arguments.reduce(0) { (result, type) in
            result + memoryLayoutStrategy.sizeof(type: type)
        }
        if argPackSize + returnTypeSize > 0 {
            children += [
                TackInstructionNode(
                    instruction: .free(argPackSize + returnTypeSize),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols)
            ]
        }
        
        let innerSeq = Seq(sourceAnchor: expr.sourceAnchor, children: children)
        
        env.pop()
        
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
            try StructMemberFunctionCallMatcher(
                call: expr,
                typeChecker: rvalueContext)
            .match()
        }
        
        func rewriteStructMemberFunctionCall(_ match: StructMemberFunctionCallMatcher.Match) throws -> AbstractSyntaxTreeNode {
            let expr = match.callExpr
            let tempSelf = try makeCompilerTemporary(expr.sourceAnchor, Expression.PrimitiveType(match.firstArgumentType))
            let assign = try rvalue(assignment: Expression.InitialAssignment(sourceAnchor: expr.sourceAnchor, lexpr: tempSelf, rexpr: match.getExpr.expr))
            registerStack.removeLast()
            return Seq(sourceAnchor: expr.sourceAnchor, children: [
                assign,
                try rvalue(
                    call: Expression.Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Expression.Get(
                            sourceAnchor: expr.sourceAnchor,
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
    
    func rvalue(sizeof expr: Expression.SizeOf) throws -> AbstractSyntaxTreeNode {
        let targetType = try typeCheck(rexpr: expr.expr)
        let size = memoryLayoutStrategy.sizeof(type: targetType)
        let dest = nextRegister(type: .w)
        pushRegister(dest)
        let result = TackInstructionNode(
            instruction: .liuw(dest.unwrap16!, size),
            sourceAnchor: expr.sourceAnchor,
            symbols: symbols)
        return result
    }
    
    func rvalue(eseq: Expression.Eseq) throws -> AbstractSyntaxTreeNode {
        var children: [AbstractSyntaxTreeNode] = []
        if eseq.children.count > 1 {
            for child in eseq.children[0..<eseq.children.count-1] {
                let savedRegisterStack = registerStack
                children.append(try rvalue(expr: child))
                registerStack = savedRegisterStack
            }
        }
        if let lastChild = eseq.children.last {
            children.append(try rvalue(expr: lastChild))
        }
        return Seq(sourceAnchor: eseq.sourceAnchor, children: children)
    }
    
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        guard node0.expression == nil else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: "internal compiler error: VarDeclaration's expression should have been erased already: `\(node0)'")
        }
        _ = try super.visit(varDecl: node0)
        return nil
    }
    
    public override func visit(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        _ = try super.visit(struct: node0)
        return nil
    }

    public override func visit(typealias node0: Typealias) throws -> AbstractSyntaxTreeNode? {
        _ = try super.visit(typealias: node0)
        return nil
    }

    public override func visit(import node0: Import) throws -> AbstractSyntaxTreeNode? {
        _ = try super.visit(import: node0)
        return nil
    }
    
    public override func visit(module node0: Module) throws -> Seq {
        // The module was compiled during the scan phase. Now erase it.
        let node1 = modules[node0.name]!
        let seq = try node1.block.eraseBlock(
            relativeTo: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
        return seq
    }
}

extension AbstractSyntaxTreeNode {
    fileprivate func flattenTackProgram() throws -> TackProgram {
        try TackFlattener.compile(self)
    }
    
    /// Lower a Snap program, written in a minimal core subset of the language, to equivalent Tack code
    public func coreToTack(
        memoryLayoutStrategy: MemoryLayoutStrategy,
        options: CoreToTackCompiler.Options
    ) throws -> TackProgram {
        let staticStorageFrame = Frame(storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress)
        let compiler = CoreToTackCompiler(
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy,
            options: options)
        let tackAst = try compiler.run(self)
        let tackProgram = try TackFlattener.compile(tackAst)
        return tackProgram
    }
}
