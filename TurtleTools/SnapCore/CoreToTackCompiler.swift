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

    func nextRegister(type: RegisterType, hint: Register? = nil) -> Register {
        if let hint {
            assert(hint.type == type)
            return hint
        }
        else {
            let result: Register =
                switch type {
                case .p: .p(.p(nextRegisterIndex))
                case .w: .w(.w(nextRegisterIndex))
                case .b: .b(.b(nextRegisterIndex))
                case .o: .o(.o(nextRegisterIndex))
                }
            nextRegisterIndex += 1
            return result
        }
    }

    public init(
        symbols: Env = Env(),
        staticStorageFrame: Frame = Frame(
            storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress
        ),
        memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16(),
        options: CoreToTackCompiler.Options = Options()
    ) {
        self.options = options
        kSliceBaseAddressOffset = 0
        kSliceCountOffset = memoryLayoutStrategy.sizeof(type: .pointer(.void))
        let structSymbols = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (kSliceBase, Symbol(type: kSliceBaseAddressType, offset: kSliceBaseAddressOffset)),
                (kSliceCount, Symbol(type: kSliceCountType, offset: kSliceCountOffset))
            ]
        )
        kSliceType = .structType(StructTypeInfo(name: kSliceName, fields: structSymbols))
        super.init(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
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
                memoryLayoutStrategy: memoryLayoutStrategy
            )!
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
            memoryLayoutStrategy: memoryLayoutStrategy
        )
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
                    symbols: symbols
                ),
                TackInstructionNode(
                    instruction: .ret,
                    sourceAnchor: node.sourceAnchor,
                    symbols: symbols
                )
            ]
        )
    }

    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let symbols = symbols!
        let mangledName = try symbols
            .resolve(
                sourceAnchor: node.sourceAnchor,
                identifier: node.identifier.identifier
            )
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
                    symbols: symbols
                ),
                subroutineBody
            ]
        )
        subroutines.append(subroutine)
        return nil
    }

    public override func visit(asm node: Asm) throws -> AbstractSyntaxTreeNode? {
        TackInstructionNode(
            instruction: .inlineAssembly(node.assemblyCode),
            sourceAnchor: node.sourceAnchor,
            symbols: symbols
        )
    }

    public override func visit(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        TackInstructionNode(
            instruction: .jmp(node.target),
            sourceAnchor: node.sourceAnchor,
            symbols: symbols
        )
    }

    public override func visit(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        var children: [AbstractSyntaxTreeNode] = try [
            rvalue(expr: node.condition)
        ]

        children += [
            TackInstructionNode(
                instruction: .bz(popRegister().unwrapBool!, node.target),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols
            )
        ]

        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }

    public override func visit(
        expressionStatement node: Expression
    ) throws -> AbstractSyntaxTreeNode? {
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
        let expr1 =
            switch expr0 {
            case let node as Identifier:
                try lvalue(identifier: node)
            case let node as Subscript:
                try lvalue(subscript: node)
            case let node as Get:
                try lvalue(get: node)
            case let node as Bitcast:
                try lvalue(expr: node.expr)
            case let node as GenericTypeApplication:
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message: "internal compiler error: expected generics to have been erased by this point: `\(node)'"
                )
            default:
                throw CompilerError(
                    sourceAnchor: expr0.sourceAnchor,
                    message: "internal compiler error: unimplemented support for expression in CoreToTackCompiler: `\(expr0)'"
                )
            }
        let expr2 = try expr1.flatten() ?? Seq(sourceAnchor: expr1.sourceAnchor, children: [])
        return expr2
    }

    func lvalue(identifier node: Identifier) throws -> AbstractSyntaxTreeNode {
        let lvalueType = try typeCheck(lexpr: node)
        switch lvalueType {
        case let .function(typ):
            guard let mangledName = typ.mangledName else {
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message: "internal compiler error: function has no mangled name: `\(lvalueType!)'"
                )
            }

            let dst = nextRegister(type: .p)
            pushRegister(dst)
            let result = TackInstructionNode(
                instruction: .la(dst.unwrapPointer!, mangledName),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols
            )
            return result

        case .genericFunction:
            throw CompilerError(
                sourceAnchor: node.sourceAnchor,
                message: "internal compiler error: expected generics to have been erased by this point: `\(node)'"
            )

        default:
            let resolution = try symbols!.resolveWithStackFrameDepth(
                sourceAnchor: node.sourceAnchor,
                identifier: node.identifier
            )
            let symbol = resolution.0
            let depth = resolution.1
            assert(depth >= 0)

            guard !symbol.storage.isRegisterStorage else {
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message: "internal compiler error: symbol with register storage has no memory address: \(symbol)"
                )
            }

            let result = computeAddressOfSymbol(
                sourceAnchor: node.sourceAnchor,
                symbol: symbol,
                depth: depth
            )
            return try visit(result)!
        }
    }

    func lvalue(subscript expr: Subscript) throws -> AbstractSyntaxTreeNode {
        let argumentType = try typeCheck(rexpr: expr.argument)

        guard !argumentType.isStructType else {
            return try lvalue(slice: expr)
        }

        let elementType = try typeCheck(rexpr: expr)
        let elementSize = memoryLayoutStrategy.sizeof(type: elementType)
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)

        // Can we determine the index at compile time?
        let maybeStaticIndex: Int? =
            if case let .arithmeticType(.compTimeInt(index)) =
            argumentType {
                index
            }
            else {
                nil
            }

        // Can we determine the upper bound at compile time?
        let maybeUpperBound: Int? =
            if case .array(
                count: let n,
                elementType: _
            ) = subscriptableType {
                n
            }
            else {
                nil
            }

        // We can catch some out of bounds errors at compile time
        if let index = maybeStaticIndex {
            if index < 0 {
                throw CompilerError(
                    sourceAnchor: expr.argument.sourceAnchor,
                    message: "Array index is always out of bounds: `\(index)' is less than zero"
                )
            }

            if let n = maybeUpperBound, index >= n {
                throw CompilerError(
                    sourceAnchor: expr.argument.sourceAnchor,
                    message: "Array index is always out of bounds: `\(index)' is not in 0..\(n)"
                )
            }
        }

        var children: [AbstractSyntaxTreeNode] = []

        // If this is a pointer to array then we must follow the pointer to get
        // the base address of the array.
        let computeArrayBaseAddress =
            switch subscriptableType {
            case .pointer(.array(count: _, elementType: _)),
                 .pointer(.dynamicArray(elementType: _)):
                try rvalue(expr: expr.subscriptable)

            default:
                try lvalue(expr: expr.subscriptable)
            }
        children.append(computeArrayBaseAddress)

        // If this is a dynamic array then we must dereference the slice.
        // The slice is a structure that contains a pointer and a count, and the
        // slice lvalue is the address of this structure. We must perform
        // another load to extract the base address.
        let sliceAddr: Register!
        switch subscriptableType {
        case .dynamicArray:
            sliceAddr = popRegister()
            let baseAddr = nextRegister(type: .p)
            pushRegister(baseAddr)
            children += [
                TackInstructionNode(
                    instruction: .lp(
                        baseAddr.unwrapPointer!,
                        sliceAddr.unwrapPointer!,
                        kSliceBaseAddressOffset
                    ),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]

        default:
            sliceAddr = nil
        }

        if elementSize > 0 {
            let baseAddr = popRegister()
            try children += [
                compileAndConvertExpression(
                    rexpr: expr.argument,
                    ltype: .arithmeticType(.immutableInt(.u16)),
                    isExplicitCast: false
                )
            ]
            let index = popRegister()

            // We may need to insert a run time bounds checks.
            if options.isBoundsCheckEnabled, maybeStaticIndex == nil {
                // Lower bound
                let lowerBound = 0
                let tempLowerBound = nextRegister(type: .w)
                let tempComparison1 = nextRegister(type: .o)
                let labelPassesLowerBoundsCheck = symbols!.nextLabel()
                children += [
                    TackInstructionNode(
                        instruction: .liw(tempLowerBound.unwrap16!, lowerBound),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .gew(
                            tempComparison1.unwrapBool!,
                            index.unwrap16!,
                            tempLowerBound.unwrap16!
                        ),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .bnz(tempComparison1.unwrapBool!, labelPassesLowerBoundsCheck),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .call(kOOB),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    LabelDeclaration(
                        sourceAnchor: expr.sourceAnchor,
                        identifier: labelPassesLowerBoundsCheck
                    )
                ]

                // Upper bound
                let tempUpperBound = nextRegister(type: .w)
                switch subscriptableType {
                case .array(count: let n?, elementType: _):
                    // The upper bound is known at compile time
                    children += [
                        TackInstructionNode(.liw(tempUpperBound.unwrap16!, n))
                    ]

                case .dynamicArray:
                    // The upper bound is embedded in the slice object
                    children += [
                        TackInstructionNode(
                            instruction: .lw(
                                tempUpperBound.unwrap16!,
                                sliceAddr.unwrapPointer!,
                                kSliceCountOffset
                            ),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
                    ]

                default:
                    fatalError("unimplemented")
                }

                let tempComparison2 = nextRegister(type: .o)
                let labelPassesUpperBoundsCheck = symbols!.nextLabel()
                children += [
                    TackInstructionNode(
                        instruction: .ltw(
                            tempComparison2.unwrapBool!,
                            index.unwrap16!,
                            tempUpperBound.unwrap16!
                        ),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .bnz(tempComparison2.unwrapBool!, labelPassesUpperBoundsCheck),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .call(kOOB),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    LabelDeclaration(
                        sourceAnchor: expr.sourceAnchor,
                        identifier: labelPassesUpperBoundsCheck
                    )
                ]
            }

            if elementSize == 1 {
                let accessAddr = nextRegister(type: .p)
                pushRegister(accessAddr)
                children += [
                    TackInstructionNode(
                        instruction: .addpw(
                            accessAddr.unwrapPointer!,
                            baseAddr.unwrapPointer!,
                            index.unwrap16!
                        ),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]
            }
            else {
                let offset = nextRegister(type: .w)
                let accessAddr = nextRegister(type: .p)
                pushRegister(accessAddr)
                children += [
                    TackInstructionNode(
                        instruction: .muliw(offset.unwrap16!, index.unwrap16!, elementSize),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .addpw(
                            accessAddr.unwrapPointer!,
                            baseAddr.unwrapPointer!,
                            offset.unwrap16!
                        ),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]
            }
        }

        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }

    func lvalue(slice expr: Subscript) throws -> AbstractSyntaxTreeNode {
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        switch subscriptableType {
        case .array:
            return try lvalue(arraySlice: expr)

        case .dynamicArray:
            return try lvalue(dynamicArraySlice: expr)

        default:
            fatalError(
                "Cannot subscript an expression of type `\(subscriptableType)'. Semantic analysis should have caught this error at an earlier step."
            )
        }
    }

    func lvalue(arraySlice expr: Subscript) throws -> AbstractSyntaxTreeNode {
        guard isAcceptableArraySliceArgument(expr.argument) else {
            throw CompilerError(
                sourceAnchor: expr.argument.sourceAnchor,
                message: "internal compiler error: expression is not an acceptable argument to an array slice"
            )
        }

        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)
        let beginExpr = Get(expr: expr.argument, member: Identifier(kRangeBegin))
        let limitExpr = Get(expr: expr.argument, member: Identifier(kRangeLimit))
        let upperBound = subscriptableType.arrayCount!
        var children: [AbstractSyntaxTreeNode] = []

        // Can we determine the range's bounds at compile time?
        let maybeBegin: Int? =
            switch try? typeCheck(rexpr: beginExpr) {
            case let .arithmeticType(.compTimeInt(n)):
                n

            default:
                nil
            }

        let maybeLimit: Int? =
            switch try? typeCheck(rexpr: limitExpr) {
            case let .arithmeticType(.compTimeInt(n)):
                n

            default:
                nil
            }

        if let begin = maybeBegin, begin < 0 || begin >= upperBound {
            throw CompilerError(
                sourceAnchor: expr.argument.sourceAnchor,
                message: "Array index is always out of bounds: `\(begin)' is not in 0..\(upperBound)"
            )
        }

        if let limit = maybeLimit, limit < 0 || limit > upperBound {
            throw CompilerError(
                sourceAnchor: expr.argument.sourceAnchor,
                message: "Array index is always out of bounds: `\(limit)' is not in 0..\(upperBound)"
            )
        }

        if let begin = maybeBegin, let limit = maybeLimit, begin > limit {
            throw CompilerError(
                sourceAnchor: expr.argument.sourceAnchor,
                message: "Range requires begin less than or equal to limit: `\(begin)..\(limit)'"
            )
        }

        // Insert bounds check when bounds cannot be verified at compile time.
        if options.isBoundsCheckEnabled {
            if maybeBegin == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .ge,
                        left: beginExpr,
                        right: LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: upperBound
                        )
                    ),
                    then: Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Identifier(kOOB)
                    )
                )
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!
                )
                if let boundsCheck2 = try super.visit(boundsCheck1) {
                    children.append(boundsCheck2)
                }
            }

            if maybeLimit == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .gt,
                        left: limitExpr,
                        right: LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: upperBound
                        )
                    ),
                    then: Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Identifier(
                            sourceAnchor: expr.sourceAnchor,
                            identifier: kOOB
                        )
                    )
                )
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!
                )
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

        let arrayBeginExpr = Bitcast(
            sourceAnchor: expr.sourceAnchor,
            expr: Unary(
                sourceAnchor: expr.sourceAnchor,
                op: .ampersand,
                expression: expr.subscriptable
            ),
            targetType: PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: .u16
            )
        )

        let baseExpr: Expression =
            if let begin = maybeBegin {
                if begin == 0 {
                    arrayBeginExpr
                }
                else {
                    Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .plus,
                        left: arrayBeginExpr,
                        right: LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: begin * elementSize
                        )
                    )
                }
            }
            else {
                if elementSize == 1 {
                    Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .plus,
                        left: arrayBeginExpr,
                        right: beginExpr
                    )
                }
                else {
                    Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .plus,
                        left: arrayBeginExpr,
                        right: Binary(
                            sourceAnchor: expr.sourceAnchor,
                            op: .star,
                            left: beginExpr,
                            right: LiteralInt(
                                sourceAnchor: expr.sourceAnchor,
                                value: elementSize
                            )
                        )
                    )
                }
            }

        let countExpr: Expression =
            if let begin = maybeBegin, let limit = maybeLimit {
                LiteralInt(
                    sourceAnchor: expr.sourceAnchor,
                    value: limit - begin
                )
            }
            else {
                Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .minus,
                    left: limitExpr,
                    right: beginExpr
                )
            }

        let sliceExpr = StructInitializer(
            sourceAnchor: expr.sourceAnchor,
            identifier: Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: kSliceName
            ),
            arguments: [
                StructInitializer.Argument(name: kSliceBase, expr: baseExpr),
                StructInitializer.Argument(name: kSliceCount, expr: countExpr)
            ]
        )
        let bitcastExpr = Bitcast(
            sourceAnchor: expr.sourceAnchor,
            expr: sliceExpr,
            targetType: PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: sliceType
            )
        )
        let compiledNode = try rvalue(expr: bitcastExpr)
        children.append(compiledNode)

        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }

    fileprivate func isAcceptableArraySliceArgument(_ argument: Expression) -> Bool {
        let result: Bool
        let argumentType = try? typeCheck(rexpr: argument)
        switch argumentType {
        case let .structType(typ):
            if typ.name == kRangeName,
               typ.symbols.maybeResolve(identifier: kRangeBegin) != nil,
               typ.symbols.maybeResolve(identifier: kRangeLimit) != nil {
                result = true
            }
            else {
                result = false
            }

        default:
            result = false
        }
        return result
    }

    func lvalue(dynamicArraySlice expr: Subscript) throws -> AbstractSyntaxTreeNode {
        guard let range = expr.argument as? StructInitializer, range.arguments.count == 2,
              range.arguments[0].name == kRangeBegin, range.arguments[1].name == kRangeLimit
        else {
            fatalError(
                "Array slice requires the argument to be range. Semantic analysis should have caught this error at an earlier step."
            )
        }

        // Can we determine the range's bounds at compile time?
        let maybeBegin: Int? =
            switch try? typeCheck(rexpr: range.arguments[0].expr) {
            case let .arithmeticType(.compTimeInt(n)):
                n

            default:
                nil
            }

        let maybeLimit: Int? =
            switch try? typeCheck(rexpr: range.arguments[1].expr) {
            case let .arithmeticType(.compTimeInt(n)):
                n

            default:
                nil
            }

        var children: [AbstractSyntaxTreeNode] = []
        let beginExpr = range.arguments[0].expr
        let limitExpr = range.arguments[1].expr

        // Insert dynamic bounds check
        if options.isBoundsCheckEnabled {
            let upperBoundExpr = Get(
                sourceAnchor: expr.sourceAnchor,
                expr: Bitcast(
                    sourceAnchor: expr.sourceAnchor,
                    expr: expr.subscriptable,
                    targetType: Identifier(
                        sourceAnchor: expr.sourceAnchor,
                        identifier: kSliceName
                    )
                ),
                member: Identifier(
                    sourceAnchor: expr.sourceAnchor,
                    identifier: kSliceCount
                )
            )

            if maybeBegin == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .ge,
                        left: beginExpr,
                        right: upperBoundExpr
                    ),
                    then: Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Identifier(
                            sourceAnchor: expr.sourceAnchor,
                            identifier: kOOB
                        )
                    )
                )
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!
                )
                if let boundsCheck2 = try super.visit(boundsCheck1) {
                    children.append(boundsCheck2)
                }
            }

            if maybeLimit == nil {
                let boundsCheck0 = If(
                    sourceAnchor: expr.sourceAnchor,
                    condition: Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .gt,
                        left: limitExpr,
                        right: upperBoundExpr
                    ),
                    then: Call(
                        sourceAnchor: expr.sourceAnchor,
                        callee: Identifier(
                            sourceAnchor: expr.sourceAnchor,
                            identifier: kOOB
                        )
                    )
                )
                let boundsCheck1 = try SnapSubcompilerIf().compile(
                    if: boundsCheck0,
                    symbols: symbols!
                )
                if let boundsCheck2 = try super.visit(boundsCheck1) {
                    children.append(boundsCheck2)
                }
            }
        } // if options.isBoundsCheckEnabled

        // Compile an expression to initialize a Slice struct with populated
        // base and count fields. This involves some unsafe, platform-specific
        // bitcasts and assumptions about the memory layout.
        let arrayBeginExpr = Get(
            sourceAnchor: expr.sourceAnchor,
            expr: Bitcast(
                sourceAnchor: expr.sourceAnchor,
                expr: expr.subscriptable,
                targetType: PrimitiveType(
                    sourceAnchor: expr.sourceAnchor,
                    typ: kSliceType
                )
            ),
            member: Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: kSliceBase
            )
        )
        let sliceType = try typeCheck(rexpr: expr)
        let elementSize = memoryLayoutStrategy.sizeof(type: sliceType.arrayElementType)

        let baseExpr: Expression =
            if let begin = maybeBegin {
                if begin == 0 {
                    arrayBeginExpr
                }
                else {
                    Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .plus,
                        left: arrayBeginExpr,
                        right: LiteralInt(
                            sourceAnchor: expr.sourceAnchor,
                            value: begin * elementSize
                        )
                    )
                }
            }
            else {
                if elementSize == 1 {
                    Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .plus,
                        left: arrayBeginExpr,
                        right: beginExpr
                    )
                }
                else {
                    Binary(
                        sourceAnchor: expr.sourceAnchor,
                        op: .plus,
                        left: arrayBeginExpr,
                        right: Binary(
                            sourceAnchor: expr.sourceAnchor,
                            op: .star,
                            left: beginExpr,
                            right: LiteralInt(
                                sourceAnchor: expr.sourceAnchor,
                                value: elementSize
                            )
                        )
                    )
                }
            }

        let countExpr: Expression =
            if let begin = maybeBegin, let limit = maybeLimit {
                LiteralInt(
                    sourceAnchor: expr.sourceAnchor,
                    value: limit - begin
                )
            }
            else {
                Binary(
                    sourceAnchor: expr.sourceAnchor,
                    op: .minus,
                    left: limitExpr,
                    right: beginExpr
                )
            }

        let sliceExpr = StructInitializer(
            sourceAnchor: expr.sourceAnchor,
            identifier: Identifier(
                sourceAnchor: expr.sourceAnchor,
                identifier: kSliceName
            ),
            arguments: [
                StructInitializer.Argument(name: kSliceBase, expr: baseExpr),
                StructInitializer.Argument(name: kSliceCount, expr: countExpr)
            ]
        )
        let bitcastExpr = Bitcast(
            sourceAnchor: expr.sourceAnchor,
            expr: sliceExpr,
            targetType: PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: sliceType
            )
        )
        try children.append(rvalue(expr: bitcastExpr))

        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }

    func computeAddressOfSymbol(sourceAnchor: SourceAnchor?, symbol: Symbol, depth: Int) -> Seq {
        assert(depth >= 0)
        var children: [AbstractSyntaxTreeNode] = []
        switch symbol.storage {
        case let .staticStorage(offset):
            guard let offset else {
                fatalError("symbol is missing an expected offset: \(symbol)")
            }
            let temp = nextRegister(type: .p)
            pushRegister(temp)
            children += [
                TackInstructionNode(
                    instruction: .lip(temp.unwrapPointer!, offset),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols
                )
            ]
        case let .automaticStorage(offset):
            guard let offset else {
                fatalError("symbol is missing an expected offset: \(symbol)")
            }
            children += [
                computeAddressOfLocalVariable(
                    sourceAnchor: sourceAnchor,
                    offset: offset,
                    depth: depth
                )
            ]
        case .registerStorage:
            fatalError(
                "internal compiler error: symbol with register storage has no memory address: \(symbol)"
            )
        }
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }

    func computeAddressOfLocalVariable(sourceAnchor: SourceAnchor?, offset: Int, depth: Int) -> Seq
    {
        assert(depth >= 0)

        var children: [AbstractSyntaxTreeNode] = []

        let temp_framePointer: RegisterPointer

        if depth == 0 {
            temp_framePointer = .fp
        }
        else {
            temp_framePointer = nextRegister(type: .p).unwrapPointer!

            children += [
                TackInstructionNode(
                    instruction: .lp(temp_framePointer, .fp, 0),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols
                )
            ]

            // Follow the frame pointer `depth' times.
            for _ in 1..<depth {
                children += [
                    TackInstructionNode(
                        instruction: .lp(temp_framePointer, temp_framePointer, 0),
                        sourceAnchor: sourceAnchor,
                        symbols: symbols
                    )
                ]
            }
        }

        let temp_result = nextRegister(type: .p)

        if offset >= 0 {
            children += [
                TackInstructionNode(
                    instruction: .subip(temp_result.unwrapPointer!, temp_framePointer, offset),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols
                )
            ]
        }
        else {
            children += [
                TackInstructionNode(
                    instruction: .addip(temp_result.unwrapPointer!, temp_framePointer, -offset),
                    sourceAnchor: sourceAnchor,
                    symbols: symbols
                )
            ]
        }

        pushRegister(temp_result)

        return Seq(sourceAnchor: sourceAnchor, children: children)
    }

    func lvalue(get expr: Get) throws -> AbstractSyntaxTreeNode {
        guard let member = expr.member as? Identifier else {
            throw CompilerError(
                sourceAnchor: expr.member.sourceAnchor,
                message: "expected identifier in get expression"
            )
        }

        if let structInitializer = expr.expr as? StructInitializer {
            let argument = structInitializer.arguments.first(where: { $0.name == member.identifier }
            )
            let memberExpr = argument!.expr
            return try lvalue(expr: memberExpr)
        }

        let name = member.identifier
        let resultType = try typeCheck(rexpr: expr.expr)
        var children: [AbstractSyntaxTreeNode] = []

        switch resultType {
        case let .structType(typ):
            let symbol = try typ.symbols.resolve(identifier: name)
            let offset = symbol.storage.offset!
            try children += [
                lvalue(expr: expr.expr)
            ]
            let tempStructAddress = popRegister().unwrapPointer!
            let dst = nextRegister(type: .p)
            pushRegister(dst)
            children += [
                TackInstructionNode(
                    instruction: .addip(dst.unwrapPointer!, tempStructAddress, offset),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]

        case let .pointer(typ):
            if name == "pointee" {
                try children += [
                    rvalue(expr: expr.expr)
                ]
            }
            else {
                switch typ {
                case let .structType(b):
                    let symbol = try b.symbols.resolve(identifier: name)
                    let offset = symbol.storage.offset!

                    try children += [
                        rvalue(expr: expr.expr)
                    ]
                    let tempStructAddress = popRegister().unwrapPointer!
                    let dst = nextRegister(type: .p)
                    pushRegister(dst)
                    children += [
                        TackInstructionNode(
                            instruction: .addip(dst.unwrapPointer!, tempStructAddress, offset),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
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
        let expr1 =
            switch expr0 {
            case let group as Group:
                try rvalue(expr: group.expression)
            case let literal as LiteralInt:
                rvalue(literalInt: literal)
            case let literal as LiteralBool:
                rvalue(literalBoolean: literal)
            case let literal as LiteralArray:
                try rvalue(literalArray: literal)
            case let literal as LiteralString:
                try rvalue(literalString: literal)
            case let node as Identifier:
                try rvalue(identifier: node)
            case let node as As:
                try rvalue(as: node)
            case let node as Bitcast:
                try rvalue(bitcast: node)
            case let node as Unary:
                try rvalue(unary: node)
            case let node as Binary:
                try rvalue(binary: node)
            case let expr as Is:
                try rvalue(is: expr)
            case let expr as Assignment:
                try rvalue(assignment: expr)
            case let expr as Subscript:
                try rvalue(subscript: expr)
            case let expr as Get:
                try rvalue(get: expr)
            case let node as StructInitializer:
                try rvalue(structInitializer: node)
            case let node as Call:
                try rvalue(call: node)
            case let node as SizeOf:
                try rvalue(sizeof: node)
            case let eseq as Eseq:
                try rvalue(eseq: eseq)
            case let node as GenericTypeApplication:
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message: "internal compiler error: expected generics to have been erased by this point: `\(node)'"
                )
            default:
                throw CompilerError(
                    sourceAnchor: expr0.sourceAnchor,
                    message: "internal compiler error: unimplemented support for expression in CoreToTackCompiler: `\(expr0)'"
                )
            }
        let expr2 = try expr1.flatten() ?? Seq(sourceAnchor: expr1.sourceAnchor, children: [])
        return expr2
    }

    func rvalue(literalInt node: LiteralInt) -> AbstractSyntaxTreeNode {
        let result: AbstractSyntaxTreeNode
        switch ArithmeticTypeInfo.compTimeInt(node.value).intClass {
        case .i8:
            let dest = nextRegister(type: .b)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .lib(dest.unwrap8!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols
            )

        case .u8:
            let dest = nextRegister(type: .b)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .liub(dest.unwrap8!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols
            )

        case .i16:
            let dest = nextRegister(type: .w)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .liw(dest.unwrap16!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols
            )

        case .u16:
            let dest = nextRegister(type: .w)
            pushRegister(dest)
            result = TackInstructionNode(
                instruction: .liuw(dest.unwrap16!, node.value),
                sourceAnchor: node.sourceAnchor,
                symbols: symbols
            )

        case .none:
            fatalError(
                "Expected to be able to determine the type of an integer literal at this point: \(node)"
            )
        }

        return result
    }

    func rvalue(literalBoolean node: LiteralBool) -> AbstractSyntaxTreeNode {
        let dest = nextRegister(type: .o)
        pushRegister(dest)
        let result = TackInstructionNode(
            instruction: .lio(dest.unwrapBool!, node.value),
            sourceAnchor: node.sourceAnchor,
            symbols: symbols
        )
        return result
    }

    func rvalue(literalArray expr: LiteralArray) throws -> AbstractSyntaxTreeNode {
        let arrayType = try typeCheck(rexpr: expr)
        let arrayElementType = try typeCheck(rexpr: expr.arrayType).arrayElementType
        guard arrayElementType.isPrimitive else {
            let savedRegisterStack = registerStack
            let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, expr.arrayType)
            var children: [AbstractSyntaxTreeNode] = []
            for i in 0..<expr.elements.count {
                let slot = Subscript(
                    sourceAnchor: expr.sourceAnchor,
                    subscriptable: tempArrayId,
                    argument: LiteralInt(
                        sourceAnchor: expr.sourceAnchor,
                        value: i
                    )
                )
                let child = try rvalue(
                    expr: Assignment(
                        sourceAnchor: expr.sourceAnchor,
                        lexpr: slot,
                        rexpr: expr.elements[i]
                    )
                )
                children.append(child)
            }
            registerStack = savedRegisterStack
            try children += [
                lvalue(identifier: tempArrayId)
            ]
            return Seq(sourceAnchor: expr.sourceAnchor, children: children)
        }
        let tempArrayId = try makeCompilerTemporary(
            expr.sourceAnchor,
            PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: arrayType
            )
        )
        var children: [AbstractSyntaxTreeNode] = try [
            lvalue(identifier: tempArrayId)
        ]
        let tempArrayAddr = popRegister()
        for i in 0..<expr.elements.count {
            try children += [
                rvalue(
                    as: As(
                        expr: expr.elements[i],
                        targetType: PrimitiveType(arrayElementType)
                    )
                )
            ]

            let resultRegister = popRegister()
            let ins: TackInstruction =
                switch resultRegister {
                case let .p(src): .sp(src, tempArrayAddr.unwrapPointer!, i)
                case let .w(src): .sw(src, tempArrayAddr.unwrapPointer!, i)
                case let .b(src): .sb(src, tempArrayAddr.unwrapPointer!, i)
                case let .o(src): .so(src, tempArrayAddr.unwrapPointer!, i)
                }

            children += [
                TackInstructionNode(
                    instruction: ins,
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]
        }
        pushRegister(tempArrayAddr)
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }

    func makeCompilerTemporary(
        _ sourceAnchor: SourceAnchor?,
        _ type: Expression
    ) throws -> Identifier {
        let tempArrayId = Identifier(
            sourceAnchor: sourceAnchor,
            identifier: symbols!.tempName(prefix: "__temp")
        )
        let tempDecl = VarDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: tempArrayId,
            explicitType: type,
            expression: nil,
            storage: .automaticStorage(offset: nil),
            isMutable: true,
            visibility: .privateVisibility
        )
        let varDeclCompiler = SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        let _ = try varDeclCompiler.compile(tempDecl)
        return tempArrayId
    }

    func rvalue(literalString expr: LiteralString) throws -> AbstractSyntaxTreeNode {
        let arrayType = ArrayType(
            sourceAnchor: expr.sourceAnchor,
            count: LiteralInt(
                sourceAnchor: expr.sourceAnchor,
                value: expr.value.count
            ),
            elementType: PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: .u8
            )
        )
        let tempArrayId = try makeCompilerTemporary(expr.sourceAnchor, arrayType)
        return try Seq(
            sourceAnchor: expr.sourceAnchor,
            children: [
                lvalue(identifier: tempArrayId),
                TackInstructionNode(
                    instruction: .ststr(peekRegister().unwrapPointer!, expr.value),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]
        )
    }

    func rvalue(identifier node: Identifier) throws -> AbstractSyntaxTreeNode {
        let symbol = try symbols!.resolve(identifier: node.identifier)

        // If the symbol has register storage then the value is already in a
        // register. Push that register onto the stack.
        if symbol.storage.isRegisterStorage {
            guard let dst = symbol.storage.register else {
                throw CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message: "symbol has register storage with no bound register: \(node)"
                )
            }
            pushRegister(dst)
            return Seq()
        }

        var children: [AbstractSyntaxTreeNode] = try [
            lvalue(expr: node)
        ]

        if let primitiveType = symbol.type.primitiveType {
            let addr = popRegister().unwrapPointer!
            let dest = nextRegister(type: primitiveType)

            let ins: TackInstruction =
                switch primitiveType {
                case .p: .lp(dest.unwrapPointer!, addr, 0)
                case .w: .lw(dest.unwrap16!, addr, 0)
                case .b: .lb(dest.unwrap8!, addr, 0)
                case .o: .lo(dest.unwrapBool!, addr, 0)
                }

            pushRegister(dest)
            children += [
                TackInstructionNode(
                    instruction: ins,
                    sourceAnchor: node.sourceAnchor,
                    symbols: symbols
                )
            ]
        }

        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }

    func rvalue(as expr: As) throws -> AbstractSyntaxTreeNode {
        let targetType = try typeCheck(rexpr: expr.targetType)
        guard case .array = targetType, let literalArray0 = expr.expr as? LiteralArray else {
            return try compileAndConvertExpression(
                rexpr: expr.expr,
                ltype: targetType,
                isExplicitCast: true
            )
        }
        let elementType = targetType.arrayElementType
        let elements = literalArray0.elements.map {
            As(
                sourceAnchor: expr.sourceAnchor,
                expr: $0,
                targetType: PrimitiveType(
                    sourceAnchor: expr.sourceAnchor,
                    typ: elementType
                )
            )
        }
        let literalArray1 = LiteralArray(
            sourceAnchor: literalArray0.sourceAnchor,
            arrayType: expr.targetType,
            elements: elements
        )
        return try rvalue(literalArray: literalArray1)
    }

    func rvalue(bitcast expr: Bitcast) throws -> AbstractSyntaxTreeNode {
        var children: [AbstractSyntaxTreeNode] = try [
            rvalue(expr: expr.expr)
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
                    symbols: symbols
                )
            ]
        }
        let seq = Seq(sourceAnchor: expr.sourceAnchor, children: children)
        return seq
    }

    func compileAndConvertExpression(
        rexpr: Expression,
        ltype: SymbolType,
        isExplicitCast: Bool,
        destination desiredDst: Register? = nil
    ) throws -> AbstractSyntaxTreeNode {
        if let getExpr = rexpr as? Get,
           let member = getExpr.member as? Identifier,
           let structInitializer = getExpr.expr as? StructInitializer {
            let argument = structInitializer.arguments.first {
                $0.name == member.identifier
            }
            let memberExpr = argument!.expr
            let result = try compileAndConvertExpression(
                rexpr: memberExpr,
                ltype: ltype,
                isExplicitCast: isExplicitCast,
                destination: desiredDst
            )
            return result
        }

        let rtype = try typeCheck(rexpr: rexpr)

        guard !rtype.isUnionType, !ltype.isUnionType else {
            throw CompilerError(
                sourceAnchor: rexpr.sourceAnchor,
                message: "internal compiler error: unions should have been erased in a previous compiler pass"
            )
        }

        guard !rtype.isTraitType, !ltype.isTraitType else {
            throw CompilerError(
                sourceAnchor: rexpr.sourceAnchor,
                message: "internal compiler error: traits should have been erased in a previous compiler pass"
            )
        }

        guard !canValueBeTriviallyReinterpreted(ltype, rtype) else {
            // The expression produces a value whose bitpattern can be trivially
            // reinterpreted as the target type.
            return try rvalue(expr: rexpr)
        }

        let result: AbstractSyntaxTreeNode

        switch (rtype, ltype) {
        case let (.booleanType(.compTimeBool(a)), .bool):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .o, hint: desiredDst)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .lio(dst.unwrapBool!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols
            )

        case let (.arithmeticType(.compTimeInt(a)), .u8),
             let (.arithmeticType(.compTimeInt(a)), .arithmeticType(.immutableInt(.u8))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .b, hint: desiredDst)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .liub(dst.unwrap8!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols
            )

        case let (.arithmeticType(.compTimeInt(a)), .i8),
             let (.arithmeticType(.compTimeInt(a)), .arithmeticType(.immutableInt(.i8))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .b, hint: desiredDst)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .lib(dst.unwrap8!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols
            )

        case let (.arithmeticType(.compTimeInt(a)), .i16),
             let (.arithmeticType(.compTimeInt(a)), .arithmeticType(.immutableInt(.i16))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .w, hint: desiredDst)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .liw(dst.unwrap16!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols
            )

        case let (.arithmeticType(.compTimeInt(a)), .u16),
             let (.arithmeticType(.compTimeInt(a)), .arithmeticType(.immutableInt(.u16))):
            // The expression produces a value that is known at compile time.
            // Add an instruction to load a register with that known value.
            let dst = nextRegister(type: .w, hint: desiredDst)
            pushRegister(dst)
            result = TackInstructionNode(
                instruction: .liuw(dst.unwrap16!, a),
                sourceAnchor: rexpr.sourceAnchor,
                symbols: symbols
            )

        case let (.arithmeticType(src), .arithmeticType(dst)):
            switch (src.intClass, dst.intClass) {
            case (.i8, .i16),
                 (.i8, .u16):
                var children: [AbstractSyntaxTreeNode] = []
                try children += [
                    rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .w, hint: desiredDst)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movswb(dst.unwrap16!, src.unwrap8!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols
                    )
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)

            case (.u8, .i16),
                 (.u8, .u16):
                var children: [AbstractSyntaxTreeNode] = []
                try children += [
                    rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .w, hint: desiredDst)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movzwb(dst.unwrap16!, src.unwrap8!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols
                    )
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)

            case (.u16, .u8),
                 (.u16, .i8):
                // Convert from u16 to u8 by masking off the upper byte.
                assert(isExplicitCast)
                var children: [AbstractSyntaxTreeNode] = []
                try children += [
                    rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .b, hint: desiredDst)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movzbw(dst.unwrap8!, src.unwrap16!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols
                    )
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)

            case (.i16, .u8),
                 (.i16, .i8):
                // The upper byte of the result will contain a sign-extension of
                // the lower byte instead of the original upper byte, which has
                // been discarded.
                assert(isExplicitCast)
                var children: [AbstractSyntaxTreeNode] = []
                try children += [
                    rvalue(expr: rexpr)
                ]
                let src = popRegister()
                let dst = nextRegister(type: .b, hint: desiredDst)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: .movsbw(dst.unwrap8!, src.unwrap16!),
                        sourceAnchor: rexpr.sourceAnchor,
                        symbols: symbols
                    )
                ]
                result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)

            case (.i16, .u16),
                 (.u16, .i16),
                 (.u8, .i8),
                 (.i8, .u8):
                result = try rvalue(expr: rexpr)

            default:
                fatalError(
                    "Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)"
                )
            }

        case let (.array(n, _), .array(m, b)):
            guard n == m || m == nil, let n else {
                fatalError(
                    "Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)"
                )
            }
            let savedRegisterStack = registerStack
            let tempArrayId = try makeCompilerTemporary(rexpr.sourceAnchor, PrimitiveType(ltype))
            var children: [AbstractSyntaxTreeNode] = []
            for i in 0..<n {
                try children += [
                    rvalue(
                        expr: Assignment(
                            sourceAnchor: rexpr.sourceAnchor,
                            lexpr: Subscript(
                                sourceAnchor: rexpr.sourceAnchor,
                                subscriptable: tempArrayId,
                                argument: LiteralInt(
                                    sourceAnchor: rexpr.sourceAnchor,
                                    value: i
                                )
                            ),
                            rexpr: As(
                                sourceAnchor: rexpr.sourceAnchor,
                                expr: Subscript(
                                    sourceAnchor: rexpr.sourceAnchor,
                                    subscriptable: rexpr,
                                    argument: LiteralInt(
                                        sourceAnchor: rexpr.sourceAnchor,
                                        value: i
                                    )
                                ),
                                targetType: PrimitiveType(
                                    sourceAnchor: rexpr.sourceAnchor,
                                    typ: b
                                )
                            )
                        )
                    )
                ]
            }
            registerStack = savedRegisterStack
            try children += [
                lvalue(identifier: tempArrayId)
            ]
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)

        case let (.array(n?, a), .dynamicArray(b)):
            assert(canValueBeTriviallyReinterpreted(b, a))
            let tempArrayId = try makeCompilerTemporary(rexpr.sourceAnchor, PrimitiveType(ltype))
            var children: [AbstractSyntaxTreeNode] = try [
                lvalue(expr: tempArrayId)
            ]
            let savedRegisterStack = registerStack
            let dst = popRegister()
            try children += [
                rvalue(expr: rexpr),
                TackInstructionNode(
                    instruction: { resultRegister in
                        switch resultRegister {
                        case let .p(p): .sp(p, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        case let .w(w): .sw(w, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        case let .b(b): .sb(b, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        case let .o(o): .so(o, dst.unwrapPointer!, kSliceBaseAddressOffset)
                        }
                    }(popRegister()),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols
                )
            ]
            let countReg = nextRegister(type: .w).unwrap16!
            children += [
                TackInstructionNode(
                    instruction: .liuw(countReg, n),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols
                ),
                TackInstructionNode(
                    instruction: .sw(countReg, dst.unwrapPointer!, kSliceCountOffset),
                    sourceAnchor: rexpr.sourceAnchor,
                    symbols: symbols
                )
            ]
            registerStack = savedRegisterStack
            result = Seq(sourceAnchor: rexpr.sourceAnchor, children: children)

        case let (_, .pointer(b)):
            guard !rtype.isTraitType else {
                throw CompilerError(
                    sourceAnchor: rexpr.sourceAnchor,
                    message: "internal compiler error: traits should have been erased in a previous compiler pass"
                )
            }

            if rtype == b {
                result = try lvalue(expr: rexpr)
            }
            else {
                throw CompilerError(
                    sourceAnchor: rexpr.sourceAnchor,
                    message: "Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)"
                )
            }

        default:
            fatalError(
                "Unsupported type conversion from \(rtype) to \(ltype). Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(rexpr)"
            )
        }

        return result
    }

    func canValueBeTriviallyReinterpreted(_ ltype: SymbolType, _ rtype: SymbolType) -> Bool {
        // The type checker has already verified that the conversion is legal.
        // The SnapToTackCompiler class must only determine how to implement it.
        // So conversions from one array type to another are assumed to be fine
        // we only need determine whether the in-memory representations of
        // elements can be trivially reinterpreted as the new type. This is the
        // case for of pointers and dynamic array types.

        guard ltype != rtype else {
            return true
        }

        let result: Bool =
            switch (rtype, ltype) {
            case let (.booleanType(a), .booleanType(b)):
                a.canValueBeTriviallyReinterpretedAs(type: b)

            case let (.arithmeticType(a), .arithmeticType(b)):
                a.canValueBeTriviallyReinterpretedAs(type: b)

            case (.pointer, .pointer),
                 (.dynamicArray, .dynamicArray):
                true

            case let (.array(_, a), .array(_, b)):
                // When implmenting a conversion between array types, it might be
                // possible to trivially reinterpret the bits in the new type.
                // It might also be the case that we need to emit code to convert
                // each element.
                canValueBeTriviallyReinterpreted(b, a)

            default:
                false
            }

        return result
    }

    func rvalue(unary expr: Unary) throws -> AbstractSyntaxTreeNode {
        let childType = try typeCheck(rexpr: expr.child).correspondingMutableType

        let result: AbstractSyntaxTreeNode

        if expr.op == .ampersand {
            switch childType {
            case let .function(typ):
                let label = typ.mangledName ?? typ.name!
                let dst = nextRegister(type: .p)
                result = TackInstructionNode(
                    instruction: .la(dst.unwrapPointer!, label),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
                pushRegister(dst)
            default:
                result = try lvalue(expr: expr.child)
            }
        }
        else {
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
                        symbols: symbols
                    )
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
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .subb(c.unwrap8!, a.unwrap8!, b.unwrap8!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
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
                        symbols: symbols
                    ),
                    TackInstructionNode(
                        instruction: .subw(c.unwrap16!, a.unwrap16!, b.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]

            case (.u8, .tilde),
                 (.i8, .tilde):
                let c = nextRegister(type: .b)
                pushRegister(c)
                instructions += [
                    TackInstructionNode(
                        instruction: .negb(c.unwrap8!, b.unwrap8!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]

            case (.u16, .tilde),
                 (.i16, .tilde):
                let c = nextRegister(type: .w)
                pushRegister(c)
                instructions += [
                    TackInstructionNode(
                        instruction: .negw(c.unwrap16!, b.unwrap16!),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]

            default:
                fatalError(
                    "`\(expr.op)' is not a prefix unary operator. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(expr)"
                )
            }

            result = Seq(sourceAnchor: expr.sourceAnchor, children: instructions)
        }

        return result
    }

    func rvalue(binary: Binary) throws -> AbstractSyntaxTreeNode {
        let rightType = try typeCheck(rexpr: binary.right)
        let leftType = try typeCheck(rexpr: binary.left)

        if leftType.isArithmeticType, rightType.isArithmeticType {
            return try compileArithmeticBinaryExpression(binary)
        }

        if leftType.isBooleanType, rightType.isBooleanType {
            return try compileBooleanBinaryExpression(binary, leftType, rightType)
        }

        fatalError(
            "Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)"
        )
    }

    func compileArithmeticBinaryExpression(_ binary: Binary) throws -> AbstractSyntaxTreeNode {
        let resultType = try typeCheck(rexpr: binary)
        let rightType = try typeCheck(rexpr: binary.right)
        let leftType = try typeCheck(rexpr: binary.left)

        guard !(leftType.isCompileTimeArithmeticType && rightType.isCompileTimeArithmeticType)
        else {
            throw CompilerError(
                sourceAnchor: binary.sourceAnchor,
                message: "internal compiler error: compile time arithmetic expressions should have been erased in an earlier compiler pass"
            )
        }

        switch (leftType, rightType) {
        case let (.arithmeticType(leftArithmeticType), .arithmeticType(rightArithmeticType)):
            if let arithmeticTypeForArithmetic = ArithmeticTypeInfo.binaryResultType(
                left: leftArithmeticType,
                right: rightArithmeticType
            ) {
                let intClass: IntClass = arithmeticTypeForArithmetic.intClass!
                let typeForArithmetic: SymbolType = .arithmeticType(arithmeticTypeForArithmetic)

                let right = try compileAndConvertExpression(
                    rexpr: binary.right,
                    ltype: typeForArithmetic,
                    isExplicitCast: false
                )
                let left = try compileAndConvertExpression(
                    rexpr: binary.left,
                    ltype: typeForArithmetic,
                    isExplicitCast: false
                )

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
                    b
                )

                return Seq(
                    sourceAnchor: binary.sourceAnchor,
                    children: [
                        right,
                        left,
                        TackInstructionNode(
                            instruction: ins,
                            sourceAnchor: binary.sourceAnchor,
                            symbols: symbols
                        )
                    ]
                )
            }

        default:
            break
        }

        fatalError(
            "Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)"
        )
    }

    func determineArithmeticInstruction(
        _ binary: Binary,
        _: SymbolType,
        _: SymbolType,
        _ intClass: IntClass,
        _ c: Register,
        _ a: Register,
        _ b: Register
    ) throws -> TackInstruction {
        let ins: TackInstruction
        switch binary.op {
        case .eq:
            switch intClass {
            case .i8,
                 .u8:
                ins = .eqb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .eqw(c.unwrapBool!, a.unwrap16!, b.unwrap16!)
            }
        case .ne:
            switch intClass {
            case .i8,
                 .u8:
                ins = .neb(c.unwrapBool!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
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
            case .i8,
                 .u8:
                ins = .addb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .addw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .minus:
            switch intClass {
            case .i8,
                 .u8:
                ins = .subb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .subw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .star:
            switch intClass {
            case .i8,
                 .u8:
                ins = .mulb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .mulw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .divide:
            switch intClass {
            case .i8: ins = .divb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .u8: ins = .divub(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16: ins = .divw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            case .u16: ins = .divuw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .modulus:
            switch intClass {
            case .i8,
                 .u8:
                ins = .modb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .modw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .ampersand:
            switch intClass {
            case .i8,
                 .u8:
                ins = .andb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .andw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .pipe:
            switch intClass {
            case .i8,
                 .u8:
                ins = .orb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .orw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .caret:
            switch intClass {
            case .i8,
                 .u8:
                ins = .xorb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .xorw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .leftDoubleAngle:
            switch intClass {
            case .i8,
                 .u8:
                ins = .lslb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .lslw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        case .rightDoubleAngle:
            switch intClass {
            case .i8,
                 .u8:
                ins = .lsrb(c.unwrap8!, a.unwrap8!, b.unwrap8!)
            case .i16,
                 .u16:
                ins = .lsrw(c.unwrap16!, a.unwrap16!, b.unwrap16!)
            }
        default:
            fatalError(
                "Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)"
            )
        }
        return ins
    }

    func compileBooleanBinaryExpression(
        _ binary: Binary,
        _ leftType: SymbolType,
        _ rightType: SymbolType
    ) throws -> AbstractSyntaxTreeNode {
        assert(leftType.isBooleanType && rightType.isBooleanType)

        guard !(leftType.isCompileTimeBooleanType && rightType.isCompileTimeBooleanType) else {
            throw CompilerError(
                sourceAnchor: binary.sourceAnchor,
                message: "internal compiler error: compile time boolean expressions should have been erased in an earlier compiler pass"
            )
        }

        switch binary.op {
        case .eq:
            let right = try compileAndConvertExpression(
                rexpr: binary.right,
                ltype: .bool,
                isExplicitCast: false
            )
            let left = try compileAndConvertExpression(
                rexpr: binary.left,
                ltype: .bool,
                isExplicitCast: false
            )
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
                symbols: symbols
            )
            return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])

        case .ne:
            let right = try compileAndConvertExpression(
                rexpr: binary.right,
                ltype: .bool,
                isExplicitCast: false
            )
            let left = try compileAndConvertExpression(
                rexpr: binary.left,
                ltype: .bool,
                isExplicitCast: false
            )
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
                symbols: symbols
            )
            return Seq(sourceAnchor: binary.sourceAnchor, children: [right, left, op])

        case .doubleAmpersand:
            return try logicalAnd(binary)

        case .doublePipe:
            return try logicalOr(binary)

        default:
            fatalError(
                "Unsupported expression. Semantic analysis should have caught and rejected the program at an earlier stage of compilation: \(binary)"
            )
        }
    }

    func logicalAnd(_ binary: Binary) throws -> AbstractSyntaxTreeNode {
        var instructions: [AbstractSyntaxTreeNode] = []
        let labelFalse = symbols!.nextLabel()
        let labelTail = symbols!.nextLabel()
        try instructions.append(
            compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false)
        )
        let a = popRegister()
        try instructions += [
            TackInstructionNode(
                instruction: .bz(a.unwrapBool!, labelFalse),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            compileAndConvertExpression(
                rexpr: binary.right,
                ltype: .bool,
                isExplicitCast: false
            )
        ]
        let b = popRegister()
        let c = nextRegister(type: .o)
        pushRegister(c)
        instructions += [
            TackInstructionNode(
                instruction: .bz(b.unwrapBool!, labelFalse),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, true),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            TackInstructionNode(
                instruction: .jmp(labelTail),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelFalse
            ),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, false),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelTail
            )
        ]
        return Seq(sourceAnchor: binary.sourceAnchor, children: instructions)
    }

    func logicalOr(_ binary: Binary) throws -> AbstractSyntaxTreeNode {
        var instructions: [AbstractSyntaxTreeNode] = []
        let labelTrue = symbols!.nextLabel()
        let labelTail = symbols!.nextLabel()
        try instructions.append(
            compileAndConvertExpression(rexpr: binary.left, ltype: .bool, isExplicitCast: false)
        )
        let a = popRegister()
        try instructions += [
            TackInstructionNode(
                instruction: .bnz(a.unwrapBool!, labelTrue),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            compileAndConvertExpression(
                rexpr: binary.right,
                ltype: .bool,
                isExplicitCast: false
            )
        ]
        let b = popRegister()
        let c = nextRegister(type: .o)
        pushRegister(c)
        instructions += [
            TackInstructionNode(
                instruction: .bnz(b.unwrapBool!, labelTrue),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, false),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            TackInstructionNode(
                instruction: .jmp(labelTail),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelTrue
            ),
            TackInstructionNode(
                instruction: .lio(c.unwrapBool!, true),
                sourceAnchor: binary.sourceAnchor,
                symbols: symbols
            ),
            LabelDeclaration(
                sourceAnchor: binary.sourceAnchor,
                identifier: labelTail
            )
        ]
        return Seq(sourceAnchor: binary.sourceAnchor, children: instructions)
    }

    func rvalue(is expr: Is) throws -> AbstractSyntaxTreeNode {
        throw CompilerError(
            sourceAnchor: expr.sourceAnchor,
            message: "internal compiler error: `Is` nodes should have been erased in an earlier compiler pass: \(expr)"
        )
    }

    func rvalue(assignment expr: Assignment) throws -> AbstractSyntaxTreeNode {
        guard let ltype = try typeCheck(lexpr: expr.lexpr) else {
            throw CompilerError(
                sourceAnchor: expr.lexpr.sourceAnchor,
                message: "lvalue required in assignment"
            )
        }

        let size = memoryLayoutStrategy.sizeof(type: ltype)
        let result: Seq

        // If the symbol has register storage but currently unbound then bind it
        // now to the next available Tack register.
        if let lexpr = expr.lexpr as? Identifier,
           let symbol = symbols!.maybeResolve(identifier: lexpr.identifier),
           let primitiveType = symbol.type.primitiveType,
           symbol.storage.isRegisterStorage,
           symbol.storage.register == nil {
            let nextReg = nextRegister(type: primitiveType)
            let nextSym = symbol.withStorage(.registerStorage(nextReg))
            symbols!.bind(identifier: lexpr.identifier, symbol: nextSym)
        }

        if ltype.isPrimitive {
            if let lexpr = expr.lexpr as? Identifier,
               let symbol = symbols!.maybeResolve(identifier: lexpr.identifier),
               symbol.storage.isRegisterStorage {
                // In this case, the destination symbol is of a primitive type
                // with storage in an explicitly defined register. Instead of
                // trying fruitlessly to produce the address of the symbol, emit
                // a sequence of instructions which moves the rvalue into the
                // destination register.

                guard let dst = symbol.storage.register else {
                    throw CompilerError(
                        sourceAnchor: lexpr.sourceAnchor,
                        message: "symbol has register storage with no bound register: \(lexpr)"
                    )
                }

                let rvalueProc = try compileAndConvertExpression(
                    rexpr: expr.rexpr,
                    ltype: ltype,
                    isExplicitCast: false,
                    destination: dst
                )
                let src = popRegister()

                var children: [AbstractSyntaxTreeNode] = [
                    rvalueProc
                ]

                if src != dst {
                    let mov: TackInstruction =
                        switch (dst, src) {
                        case let (.p(p1), .p(p0)): .movp(p1, p0)
                        case let (.w(w1), .w(w0)): .movw(w1, w0)
                        case let (.b(b1), .b(b0)): .movb(b1, b0)
                        case let (.o(o1), .o(o0)): .movo(o1, o0)
                        default:
                            throw CompilerError(
                                sourceAnchor: expr.sourceAnchor,
                                message: "internal compiler error: failed to generate appropriate MOV instruction for (\(dst), \(src))"
                            )
                        }
                    children.append(
                        TackInstructionNode(
                            instruction: mov,
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
                    )
                }

                result = Seq(
                    sourceAnchor: expr.sourceAnchor,
                    children: children
                )

                pushRegister(dst)
            }
            else {
                // In this case, the destination symbol is of a primitive type
                // with storage in memory. Produce the address of the symbol,
                // and emit a sequence of instructions which store the rvalue
                // into memory at that location.

                let lvalueProc = try lvalue(expr: expr.lexpr)
                let dst = popRegister()
                let rvalueProc = try compileAndConvertExpression(
                    rexpr: expr.rexpr,
                    ltype: ltype,
                    isExplicitCast: false
                )
                let src = peekRegister()

                let storeIns: TackInstruction =
                    switch src {
                    case let .p(p): .sp(p, dst.unwrapPointer!, 0)
                    case let .w(w): .sw(w, dst.unwrapPointer!, 0)
                    case let .b(b): .sb(b, dst.unwrapPointer!, 0)
                    case let .o(o): .so(o, dst.unwrapPointer!, 0)
                    }

                result = Seq(
                    sourceAnchor: expr.sourceAnchor,
                    children: [
                        lvalueProc,
                        rvalueProc,
                        TackInstructionNode(
                            instruction: storeIns,
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
                    ]
                )
            }
        }
        else if size == 0 {
            result = try Seq(
                sourceAnchor: expr.sourceAnchor,
                children: [
                    lvalue(expr: expr.lexpr)
                ]
            )
        }
        else if let structInitializer = expr.rexpr as? StructInitializer {
            let children = try structInitializer.arguments
                .map {
                    expr
                        .withLexpr(
                            Get(
                                sourceAnchor: expr.lexpr.sourceAnchor,
                                expr: expr.lexpr,
                                member: Identifier($0.name)
                            )
                        )
                        .withRexpr($0.expr)
                }
                .map {
                    try rvalue(expr: $0)
                }
            result = Seq(sourceAnchor: expr.sourceAnchor, children: children)
            // TODO: We don't push a result register on the stack here. This may be a bug.
        }
        else {
            let lvalueProc = try lvalue(expr: expr.lexpr)
            let dst = popRegister()
            let rvalueProc = try compileAndConvertExpression(
                rexpr: expr.rexpr,
                ltype: ltype,
                isExplicitCast: false
            )
            let src = peekRegister()

            result = Seq(
                sourceAnchor: expr.sourceAnchor,
                children: [
                    lvalueProc,
                    rvalueProc,
                    TackInstructionNode(
                        instruction: .memcpy(dst.unwrapPointer!, src.unwrapPointer!, size),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]
            )
        }

        return result
    }

    func rvalue(subscript expr: Subscript) throws -> AbstractSyntaxTreeNode {
        let subscriptableType = try typeCheck(rexpr: expr.subscriptable)

        switch subscriptableType {
        case let .structType(typ):
            guard typ.name == "Range" else {
                fatalError("Cannot subscript an expression of type `\(subscriptableType)'")
            }
            let lowered = Binary(
                sourceAnchor: expr.sourceAnchor,
                op: .plus,
                left: Get(
                    sourceAnchor: expr.sourceAnchor,
                    expr: expr.subscriptable,
                    member: Identifier("begin")
                ),
                right: expr.argument
            )
            let result = try rvalue(expr: lowered)
            return result

        default:
            var children: [AbstractSyntaxTreeNode] = try [
                lvalue(subscript: expr)
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
                            case let .p(p): .lp(p, addr, 0)
                            case let .w(w): .lw(w, addr, 0)
                            case let .b(b): .lb(b, addr, 0)
                            case let .o(o): .lo(o, addr, 0)
                            }
                        }(),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]
            }

            return Seq(sourceAnchor: expr.sourceAnchor, children: children)
        }
    }

    func rvalue(get expr: Get) throws -> AbstractSyntaxTreeNode {
        guard let member = expr.member as? Identifier else {
            fatalError("expected identifier in get expression")
        }

        if let structInitializer = expr.expr as? StructInitializer {
            let argument = structInitializer.arguments.first(where: { $0.name == member.identifier }
            )
            guard let memberExpr = argument?.expr else {
                fatalError("unimplemented")
            }
            return try rvalue(expr: memberExpr)
        }

        let name = member.identifier
        let resultType = try typeCheck(rexpr: expr.expr)

        var children: [AbstractSyntaxTreeNode] = []

        switch resultType {
        case .array(let count, elementType: _):
            assert(name == "count")
            let countReg = nextRegister(type: .w)
            pushRegister(countReg)
            children += [
                TackInstructionNode(
                    instruction: .liuw(countReg.unwrap16!, count!),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]

        case .dynamicArray:
            assert(name == "count")
            try children += [
                rvalue(expr: expr.expr)
            ]
            let sliceAddr = popRegister().unwrapPointer!
            let countReg = nextRegister(type: .w)
            pushRegister(countReg)
            children += [
                TackInstructionNode(
                    instruction: .lw(countReg.unwrap16!, sliceAddr, kSliceCountOffset),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]

        case let .structType(typ):
            let symbol = try typ.symbols.resolve(identifier: name)
            let offset = symbol.storage.offset!

            if let primitiveType = symbol.type.primitiveType {
                // Read the field in-place
                try children += [
                    lvalue(expr: expr.expr)
                ]
                let tempStructAddress = popRegister().unwrapPointer!
                let dst = nextRegister(type: primitiveType)
                pushRegister(dst)
                children += [
                    TackInstructionNode(
                        instruction: {
                            switch dst {
                            case let .p(p): .lp(p, tempStructAddress, offset)
                            case let .w(w): .lw(w, tempStructAddress, offset)
                            case let .b(b): .lb(b, tempStructAddress, offset)
                            case let .o(o): .lo(o, tempStructAddress, offset)
                            }
                        }(),
                        sourceAnchor: expr.sourceAnchor,
                        symbols: symbols
                    )
                ]
            }
            else {
                try children += [
                    lvalue(expr: expr)
                ]
            }

        case let .pointer(typ):
            if name == "pointee" {
                try children += [
                    rvalue(expr: expr.expr)
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
                                case let .p(p): .lp(p, pointerValue, 0)
                                case let .w(w): .lw(w, pointerValue, 0)
                                case let .b(b): .lb(b, pointerValue, 0)
                                case let .o(o): .lo(o, pointerValue, 0)
                                }
                            }(),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
                    ]
                }
            }
            else {
                switch typ {
                case .array(let count, elementType: _):
                    assert(name == "count")
                    let countReg = nextRegister(type: .w)
                    pushRegister(countReg)
                    children += [
                        TackInstructionNode(
                            instruction: .liuw(countReg.unwrap16!, count!),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
                    ]

                case .dynamicArray:
                    assert(name == "count")
                    try children += [
                        rvalue(expr: expr.expr)
                    ]
                    let sliceAddr = popRegister().unwrapPointer!
                    let countReg = nextRegister(type: .w)
                    pushRegister(countReg)
                    children += [
                        TackInstructionNode(
                            instruction: .lw(countReg.unwrap16!, sliceAddr, kSliceCountOffset),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
                    ]

                case let .structType(b):
                    let symbol = try b.symbols.resolve(identifier: name)
                    let offset = symbol.storage.offset!

                    if let primitiveType = symbol.type.primitiveType {
                        // If the field is a primitive then load into a register
                        try children += [
                            rvalue(expr: expr.expr)
                        ]
                        let structAddr = popRegister().unwrapPointer!
                        let dst = nextRegister(type: primitiveType)
                        pushRegister(dst)
                        children += [
                            TackInstructionNode(
                                instruction: {
                                    switch dst {
                                    case let .p(p): .lp(p, structAddr, offset)
                                    case let .w(w): .lw(w, structAddr, offset)
                                    case let .b(b): .lb(b, structAddr, offset)
                                    case let .o(o): .lo(o, structAddr, offset)
                                    }
                                }(),
                                sourceAnchor: expr.sourceAnchor,
                                symbols: symbols
                            )
                        ]
                    }
                    else {
                        try children += [
                            lvalue(expr: expr)
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

    func rvalue(structInitializer expr: StructInitializer) throws -> AbstractSyntaxTreeNode {
        let resultType = try typeCheck(rexpr: expr)
        let savedRegisterStack = registerStack
        let tempArrayId = try makeCompilerTemporary(
            expr.sourceAnchor,
            PrimitiveType(
                sourceAnchor: expr.sourceAnchor,
                typ: resultType
            )
        )
        var children: [AbstractSyntaxTreeNode] = []
        for arg in expr.arguments {
            let slot = Get(
                sourceAnchor: expr.sourceAnchor,
                expr: tempArrayId,
                member: Identifier(
                    sourceAnchor: expr.sourceAnchor,
                    identifier: arg.name
                )
            )
            let child = try rvalue(
                expr: Assignment(
                    sourceAnchor: expr.sourceAnchor,
                    lexpr: slot,
                    rexpr: arg.expr
                )
            )
            children.append(child)
        }
        registerStack = savedRegisterStack
        try children += [
            lvalue(identifier: tempArrayId)
        ]
        return Seq(sourceAnchor: expr.sourceAnchor, children: children)
    }

    func rvalue(call expr: Call) throws -> AbstractSyntaxTreeNode {
        let calleeType: SymbolType =
            if let symbols,
            let identifier = expr.callee as? Identifier {
                try symbols.resolveTypeOfIdentifier(
                    sourceAnchor: identifier.sourceAnchor,
                    identifier: identifier.identifier
                )
            }
            else {
                try typeCheck(rexpr: expr.callee)
            }

        switch calleeType {
        case let .function(typ),
             let .pointer(.function(typ)):
            return try rvalue(call: expr, typ: typ)

        case let .genericFunction(typ):
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "internal compiler error: expected generics to have been erased by this point: `\(expr)' of type `\(typ)'"
            )

        default:
            throw CompilerError(message: "cannot call value of non-function type `\(calleeType)'")
        }
    }

    func rvalue(
        call expr: Call,
        typ: FunctionTypeInfo
    ) throws -> AbstractSyntaxTreeNode {
        _ = try RvalueExpressionTypeChecker(symbols: symbols!).checkInner(call: expr, typ: typ)

        let calleeType = try typeCheck(rexpr: expr.callee)

        // Allocate a temporary to hold the function call return value.
        var tempRetId: Identifier! = nil
        if typ.returnType != .void {
            tempRetId = try makeCompilerTemporary(
                expr.sourceAnchor,
                PrimitiveType(
                    sourceAnchor: expr.sourceAnchor,
                    typ: typ.returnType
                )
            )
        }

        let innerBlock = Env(parent: symbols)
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
            try children += [
                rvalue(
                    expr: As(
                        sourceAnchor: expr.sourceAnchor,
                        expr: argExpr,
                        targetType: PrimitiveType(
                            sourceAnchor: expr.sourceAnchor,
                            typ: argType
                        )
                    )
                )
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
                    symbols: symbols
                )
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
                        symbols: symbols
                    )
                ]
                if argType.isPrimitive {
                    children += [
                        TackInstructionNode(
                            instruction: {
                                switch tempArg {
                                case let .p(p): .sp(p, dst, 0)
                                case let .w(w): .sw(w, dst, 0)
                                case let .b(b): .sb(b, dst, 0)
                                case let .o(o): .so(o, dst, 0)
                                }
                            }(),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
                    ]
                }
                else {
                    children += [
                        TackInstructionNode(
                            instruction: .memcpy(dst, tempArg.unwrapPointer!, argTypeSize),
                            sourceAnchor: expr.sourceAnchor,
                            symbols: symbols
                        )
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
                    symbols: symbols
                )
            ]

        case .pointer:
            try children += [
                rvalue(expr: expr.callee),
                TackInstructionNode(
                    instruction: .callptr(popRegister().unwrapPointer!),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]

        default:
            fatalError("unimplemented")
        }

        // Copy the function call return value to the compiler temporary we
        // allocated earlier. Free stack storage allocated earlier.
        if returnTypeSize > 0 {
            try children += [
                lvalue(identifier: tempRetId!),
                TackInstructionNode(
                    instruction: .memcpy(
                        popRegister().unwrapPointer!,
                        tempReturnValueAddr.unwrapPointer!,
                        returnTypeSize
                    ),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]
        }

        // Free up stack storage allocated for arguments and return value.
        let argPackSize = typ.arguments.reduce(0) { result, type in
            result + memoryLayoutStrategy.sizeof(type: type)
        }
        if argPackSize + returnTypeSize > 0 {
            children += [
                TackInstructionNode(
                    instruction: .free(argPackSize + returnTypeSize),
                    sourceAnchor: expr.sourceAnchor,
                    symbols: symbols
                )
            ]
        }

        let innerSeq = Seq(sourceAnchor: expr.sourceAnchor, children: children)

        env.pop()

        // If the function call evaluates to a non-void value then get the
        // rvalue of the compiler temporary so we can chain that value into the
        // next expression.
        let outerSeq =
            if typ.returnType != .void {
                try Seq(
                    sourceAnchor: expr.sourceAnchor,
                    children: [
                        innerSeq,
                        rvalue(identifier: tempRetId!)
                    ]
                )
            }
            else {
                Seq(
                    sourceAnchor: expr.sourceAnchor,
                    children: [
                        innerSeq
                    ]
                )
            }
        return outerSeq
    }

    func rvalue(sizeof expr: SizeOf) throws -> AbstractSyntaxTreeNode {
        throw CompilerError(
            sourceAnchor: expr.sourceAnchor,
            message: "internal compiler error: `SizeOf` nodes should have been erased in an earlier compiler pass: \(expr)"
        )
    }

    func rvalue(eseq expr: Eseq) throws -> AbstractSyntaxTreeNode {
        throw CompilerError(
            sourceAnchor: expr.sourceAnchor,
            message: "internal compiler error: `Eseq` nodes should have been erased in an earlier compiler pass: \(expr)"
        )
    }

    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        guard node0.expression == nil else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: "internal compiler error: VarDeclaration's expression should have been erased already: `\(node0)'"
            )
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
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        return seq
    }
}

extension AbstractSyntaxTreeNode {
    private func flattenTackProgram() throws -> TackProgram {
        try TackFlattener.compile(self)
    }

    /// Lower a Snap program, written in a minimal core subset of the language, to equivalent Tack
    /// code
    public func coreToTack(
        memoryLayoutStrategy: MemoryLayoutStrategy,
        options: CoreToTackCompiler.Options
    ) throws -> TackProgram {
        let staticStorageFrame = Frame(
            storagePointer: SnapCompilerMetrics.kStaticStorageStartAddress
        )
        let compiler = CoreToTackCompiler(
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy,
            options: options
        )
        let tackAst = try compiler.run(self)
        let tackProgram = try TackFlattener.compile(tackAst)
        return tackProgram
    }
}
