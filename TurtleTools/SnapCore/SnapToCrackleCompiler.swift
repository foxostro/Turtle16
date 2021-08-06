//
//  SnapToCrackleCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiles a Snap AST to the IR language.
public class SnapToCrackleCompiler: NSObject {
    private let kStackPointerAddress: Int = Int(SnapCompilerMetrics.kStackPointerAddressHi)
    
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool { !errors.isEmpty }
    public private(set) var instructions: [CrackleInstruction] = []
    public var programDebugInfo: SnapDebugInfo? = nil
    public private(set) var globalSymbols = SymbolTable()
    
    private var symbols = SymbolTable()
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    private let labelMaker = LabelMaker()
    private var currentSourceAnchor: SourceAnchor? = nil
    
    public init(_ memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(ast: Block) {
        instructions = []
        do {
            try tryCompile(ast: ast)
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    private func emit(_ ins: [CrackleInstruction]) {
        let instructionsBegin = instructions.count
        instructions += ins
        if let info = programDebugInfo {
            let instructionsEnd = instructions.count
            if instructionsBegin < instructionsEnd {
                for i in instructionsBegin..<instructionsEnd {
                    info.bind(crackleInstructionIndex: i, sourceAnchor: currentSourceAnchor)
                    info.bind(crackleInstructionIndex: i, symbols: symbols)
                }
            }
        }
    }
    
    private func tryCompile(ast: Block) throws {
        try compile(topLevel: ast)
    }
    
    private func compile(topLevel: Block) throws {
        globalSymbols = topLevel.symbols
        symbols = globalSymbols
        
        for node in topLevel.children {
            try compile(genericNode: node)
        }
    }
    
    private func evaluateFunctionTypeExpression(_ expr: Expression) throws -> FunctionType {
        return try TypeContextTypeChecker(symbols: symbols).check(expression: expr).unwrapFunctionType()
    }
    
    private func compile(genericNode: AbstractSyntaxTreeNode) throws {
        currentSourceAnchor = genericNode.sourceAnchor
        switch genericNode {
        case let node as VarDeclaration:
            try compile(varDecl: node)
        case let node as Expression:
            try compile(expressionStatement: node)
        case let node as If:
            try compile(if: node)
        case let node as While:
            try compile(while: node)
        case let node as ForIn:
            try compile(forIn: node)
        case let node as Seq:
            try compile(seq: node)
        case let node as Module:
            try compile(module: node)
        case let node as Block:
            try compile(block: node)
        case let node as Return:
            try compile(return: node)
        case let node as FunctionDeclaration:
            try compile(func: node)
        case let node as Impl:
            throw CompilerError(message: "unimplemented: `\(node)'")
        case let node as ImplFor:
            throw CompilerError(message: "unimplemented: `\(node)'")
        case let node as Match:
            try compile(match: node)
        case let node as Assert:
            throw CompilerError(message: "unimplemented: `\(node)'")
        case let node as TraitDeclaration:
            throw CompilerError(message: "unimplemented: `\(node)'")
        default:
            break
        }
    }
    
    private func compile(varDecl varDecl0: VarDeclaration) throws {
        // Compile the variable declaration using the subcompiler and then check
        // to make sure the type is as expected. This is a temporary scaffold
        // while I work to move the symbol table manipulation out of the
        // SnapToCrackleCompiler class.
        let subcompiler = SnapSubcompilerVarDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        let varDecl = try subcompiler.compile(varDecl0)
        
        // If the symbol is on the stack then allocate storage for it now.
        let symbol = try symbols.resolve(identifier: varDecl.identifier.identifier)
        if symbol.storage == .automaticStorage {
            let size = memoryLayoutStrategy.sizeof(type: symbol.type)
            emit([
                .subi16(kStackPointerAddress, kStackPointerAddress, size)
            ])
        }
        
        if let varDeclExpr = varDecl.expression {
            try compile(expression: Expression.InitialAssignment(sourceAnchor: varDecl.sourceAnchor,
                                                                 lexpr: varDecl.identifier,
                                                                 rexpr: varDeclExpr))
        }
    }
    
    // A statement can be a bare expression too.
    private func compile(expressionStatement node: Expression) throws {
        try compile(expression: node)
    }
    
    @discardableResult private func compile(expression: Expression) throws -> RvalueExpressionCompiler {
        currentSourceAnchor = expression.sourceAnchor
        let exprCompiler = RvalueExpressionCompiler(symbols: symbols,
                                                    labelMaker: labelMaker,
                                                    memoryLayoutStrategy: memoryLayoutStrategy)
        let ir = try exprCompiler.compile(expression: expression)
        emit(ir)
        return exprCompiler
    }
    
    private func compile(if stmt: If) throws {
        currentSourceAnchor = stmt.sourceAnchor
        let condition = Expression.As(sourceAnchor: stmt.condition.sourceAnchor,
                                      expr: stmt.condition,
                                      targetType: Expression.PrimitiveType(.bool))
        let tempConditionResult = try compile(expression: condition).temporaryStack.pop()
        if let elseBranch = stmt.elseBranch {
            let labelElse = labelMaker.next()
            let labelTail = labelMaker.next()
            emit([
                .jz(labelElse, tempConditionResult.address)
            ])
            try compile(genericNode: stmt.thenBranch)
            emit([
                .jmp(labelTail),
                .label(labelElse),
            ])
            try compile(genericNode: elseBranch)
            emit([.label(labelTail)])
        } else {
            let labelTail = labelMaker.next()
            emit([
                .jz(labelTail, tempConditionResult.address)
            ])
            try compile(genericNode: stmt.thenBranch)
            emit([
                .label(labelTail)
            ])
        }
    }
    
    private func compile(while stmt: While) throws {
        let sourceAnchors = stmt.sourceAnchor?.split()
        currentSourceAnchor = sourceAnchors?.first
        let labelHead = labelMaker.next()
        let labelTail = labelMaker.next()
        emit([.label(labelHead)])
        let tempConditionResult = try compile(expression: stmt.condition).temporaryStack.pop()
        emit([
            .jz(labelTail, tempConditionResult.address)
        ])
        try compile(genericNode: stmt.body)
        currentSourceAnchor = sourceAnchors?.last
        emit([
            .jmp(labelHead),
            .label(labelTail)
        ])
    }
    
    private func compile(forIn stmt: ForIn) throws {
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let sequenceType = try typeChecker.check(expression: stmt.sequenceExpr)
        switch sequenceType {
        case .constStructType(let typ), .structType(let typ):
            guard typ.name == "Range" else {
                throw CompilerError(sourceAnchor: stmt.sequenceExpr.sourceAnchor, message: "for-in loop requires iterable sequence")
            }
            try compileForInRange(stmt)
        case .array, .constDynamicArray, .dynamicArray:
            try compileForInArray(stmt)
        default:
            throw CompilerError(sourceAnchor: stmt.sequenceExpr.sourceAnchor, message: "for-in loop requires iterable sequence")
        }
    }
    
    private func compileForInRange(_ stmt: ForIn) throws {
        let sequence = Expression.Identifier("__sequence")
        let limit = Expression.Identifier("__limit")
        
        let grandparent = SymbolTable(parent: symbols)
        let parent = SymbolTable(parent: grandparent)
        let inner = SymbolTable(parent: parent)
        
        let body = Block(sourceAnchor: stmt.body.sourceAnchor,
                         symbols: inner,
                         children: stmt.body.children)
        
        let ast = Block(symbols: grandparent, children: [
            VarDeclaration(identifier: sequence,
                           explicitType: nil,
                           expression: stmt.sequenceExpr,
                           storage: .automaticStorage,
                           isMutable: true),
            VarDeclaration(identifier: limit,
                           explicitType: nil,
                           expression: Expression.Get(expr: sequence, member: Expression.Identifier("limit")),
                           storage: .automaticStorage,
                           isMutable: false),
            VarDeclaration(identifier: stmt.identifier,
                           explicitType: Expression.TypeOf(limit),
                           expression: Expression.LiteralInt(0),
                           storage: .automaticStorage,
                           isMutable: true),
            While(condition: Expression.Binary(op: .ne, left: stmt.identifier, right: limit),
                  body: Block(symbols: SymbolTable(parent: grandparent),
                              children: [body, Expression.Assignment(lexpr: stmt.identifier, rexpr: Expression.Binary(op: .plus, left: stmt.identifier, right: Expression.LiteralInt(1)))]))
        ])
        
        try compile(block: ast)
    }
    
    private func compileForInArray(_ stmt: ForIn) throws {
        let sequence = Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "__sequence")
        let index = Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "__index")
        let limit = Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "__limit")
        
        let grandparent = SymbolTable(parent: symbols)
        let parent = SymbolTable(parent: grandparent)
        let inner = SymbolTable(parent: parent)
        
        let body = Block(sourceAnchor: stmt.body.sourceAnchor,
                         symbols: inner,
                         children: stmt.body.children)
        
        let ast = Block(sourceAnchor: stmt.sourceAnchor, symbols: grandparent, children: [
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: sequence,
                           explicitType: nil,
                           expression: stmt.sequenceExpr,
                           storage: .automaticStorage,
                           isMutable: false),
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: index,
                           explicitType: nil,
                           expression: Expression.LiteralInt(sourceAnchor: stmt.sourceAnchor, value: 0),
                           storage: .automaticStorage,
                           isMutable: true),
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: limit,
                           explicitType: nil,
                           expression: Expression.Get(expr: sequence, member: Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "count")),
                           storage: .automaticStorage,
                           isMutable: false),
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: stmt.identifier,
                           explicitType: Expression.PrimitiveType(sourceAnchor: stmt.sourceAnchor, typ: try RvalueExpressionTypeChecker(symbols: symbols).check(expression: stmt.sequenceExpr).arrayElementType.correspondingMutableType),
                           expression: nil,
                           storage: .automaticStorage,
                           isMutable: true),
            While(sourceAnchor: stmt.sourceAnchor,
                  condition: Expression.Binary(sourceAnchor: stmt.sourceAnchor,
                                               op: .ne, left: index, right: limit),
                  body: Block(sourceAnchor: stmt.sourceAnchor,
                              symbols: parent,
                              children: [
                    Expression.Assignment(sourceAnchor: stmt.sourceAnchor,
                                          lexpr: stmt.identifier,
                                          rexpr: Expression.Subscript(sourceAnchor: stmt.sourceAnchor,
                                                                      subscriptable: sequence,
                                                                      argument: index)),
                    body,
                    Expression.Assignment(sourceAnchor: stmt.sourceAnchor,
                                          lexpr: index,
                                          rexpr: Expression.Binary(op: .plus,
                                                                   left: index,
                                                                   right: Expression.LiteralInt(sourceAnchor: stmt.sourceAnchor, value: 1))),
                  ]))
        ])
        
        try compile(block: ast)
    }
    
    private func compile(seq: Seq) throws {
        currentSourceAnchor = seq.sourceAnchor
        for child in seq.children {
            try compile(genericNode: child)
        }
    }
    
    private func compile(module: Module) throws {
        currentSourceAnchor = module.sourceAnchor
        
        let oldSymbols = symbols
        symbols = module.symbols
        
        for child in module.children {
            try compile(genericNode: child)
        }
        
        symbols = oldSymbols
    }
    
    private func compile(block: Block) throws {
        currentSourceAnchor = block.sourceAnchor
        
        let parent = symbols
        assert(block.symbols.parent == symbols)
        symbols = block.symbols
        
        for child in block.children {
            try compile(genericNode: child)
        }
        
        symbols = parent
    }
    
    private func compile(return node: Return) throws {
        guard let enclosingFunctionType = symbols.enclosingFunctionType else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "return is invalid outside of a function")
        }
        
        if let expr = node.expression {
            if enclosingFunctionType.returnType == .void {
                throw CompilerError(sourceAnchor: node.expression?.sourceAnchor ?? node.sourceAnchor,
                                    message: "unexpected non-void return value in void function")
            }
            
            // Synthesize an assignment to the special return value symbol.
            let kReturnValueIdentifier = "__returnValue"
            let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
            let returnExpressionType = try typeChecker.check(expression: expr)
            try typeChecker.checkTypesAreConvertibleInAssignment(ltype: enclosingFunctionType.returnType,
                                                                 rtype: returnExpressionType,
                                                                 sourceAnchor: node.sourceAnchor,
                                                                 messageWhenNotConvertible: "cannot convert return expression of type `\(returnExpressionType)' to return type `\(enclosingFunctionType.returnType)'")
            let lexpr = Expression.Identifier(sourceAnchor: node.sourceAnchor, identifier: kReturnValueIdentifier)
            try compile(expression: Expression.InitialAssignment(sourceAnchor: node.sourceAnchor, lexpr: lexpr, rexpr: expr))
        } else if .void != enclosingFunctionType.returnType {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "non-void function should return a value")
        }
        
        currentSourceAnchor = node.sourceAnchor
        emit([
            .leave,
            .ret
        ])
    }
    
    private func compile(func node: FunctionDeclaration) throws {
        let sourceAnchors = node.sourceAnchor?.split()
        currentSourceAnchor = sourceAnchors?.first
        
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        
        let mangledName = functionType.mangledName!
        let labelHead = mangledName
        let labelTail = "__\(mangledName)_tail"
        emit([
            .jmp(labelTail),
            .label(labelHead),
            .pushReturnAddress,
            .enter
        ])
        
        let parent = symbols
        symbols = node.symbols
        
        bindFunctionArguments(functionType: functionType, argumentNames: node.argumentNames)
        try expectFunctionReturnExpressionIsCorrectType(func: node)
        try compile(block: node.body)
         
        if try shouldSynthesizeTerminalReturnStatement(func: node) {
            try compile(return: Return(sourceAnchor: sourceAnchors?.last, expression: nil))
        }
        currentSourceAnchor = sourceAnchors?.last
        
        symbols = parent
        
        emit([
            .label(labelTail),
        ])
    }
    
    private func compile(match: Match) throws {
        let ast = try MatchCompiler(memoryLayoutStrategy).compile(match: match, symbols: symbols)
        try compile(genericNode: ast)
    }
    
    private func bindFunctionArguments(functionType: FunctionType, argumentNames: [String]) {
        let kReturnAddressSize = 2
        let kFramePointerSize = 2
        var offset = kReturnAddressSize + kFramePointerSize
        
        for i in (0..<functionType.arguments.count).reversed() {
            let argumentType = functionType.arguments[i]
            let argumentName = argumentNames[i]
            let symbol = Symbol(type: argumentType.correspondingConstType,
                                offset: -offset,
                                storage: .automaticStorage)
            symbols.bind(identifier: argumentName, symbol: symbol)
            let sizeOfArugmentType = memoryLayoutStrategy.sizeof(type: argumentType)
            offset += sizeOfArugmentType
        }
        
        // Bind a special symbol to contain the function return value.
        // This must be located just before the function arguments.
        let kReturnValueIdentifier = "__returnValue"
        symbols.bind(identifier: kReturnValueIdentifier,
                     symbol: Symbol(type: functionType.returnType,
                                    offset: -offset,
                                    storage: .automaticStorage))
        let sizeOfFunctionReturnType = memoryLayoutStrategy.sizeof(type: functionType.returnType)
        offset += sizeOfFunctionReturnType
    }
    
    private func expectFunctionReturnExpressionIsCorrectType(func node: FunctionDeclaration) throws {
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        let tracer = StatementTracer(symbols: symbols)
        let traces = try tracer.trace(ast: node.body)
        for trace in traces {
            if let last = trace.last {
                switch last {
                case .Return:
                    break
                default:
                    if functionType.returnType != .void {
                        throw makeErrorForMissingReturn(node)
                    }
                }
            } else if functionType.returnType != .void {
                throw makeErrorForMissingReturn(node)
            }
        }
    }
    
    private func makeErrorForMissingReturn(_ node: FunctionDeclaration) -> CompilerError {
        let functionType = try! evaluateFunctionTypeExpression(node.functionType)
        return CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                             message: "missing return in a function expected to return `\(functionType.returnType)'")
    }
    
    private func shouldSynthesizeTerminalReturnStatement(func node: FunctionDeclaration) throws -> Bool {
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        guard functionType.returnType == .void else {
            return false
        }
        let tracer = StatementTracer(symbols: symbols)
        let traces = try! tracer.trace(ast: node.body)
        var allTracesEndInReturnStatement = true
        for trace in traces {
            if let last = trace.last {
                switch last {
                case .Return:
                    break
                default:
                    allTracesEndInReturnStatement = false
                }
            } else {
                allTracesEndInReturnStatement = false
            }
        }
        return !allTracesEndInReturnStatement
    }
    
    private var injectedModules: [String : String] = [:]
    
    public func injectModule(name: String, sourceCode: String) {
        injectedModules[name] = sourceCode
    }
}
