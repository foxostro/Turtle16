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
    public let globalEnvironment: GlobalEnvironment
    private let labelMaker = LabelMaker()
    private var currentSourceAnchor: SourceAnchor? = nil
    
    public init(_ memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL(), _ globalEnvironment: GlobalEnvironment = GlobalEnvironment()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.globalEnvironment = globalEnvironment
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
        for (_, module) in globalEnvironment.modules {
            symbols = module.symbols
            try compile(block: module)
        }
        
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
        case let node as Seq:
            try compile(seq: node)
        case let node as Block:
            try compile(block: node)
        case let node as Return:
            try compile(return: node)
        case let node as FunctionDeclaration:
            try compile(func: node)
        default:
            throw CompilerError(message: "unimplemented: `\(genericNode)'")
        }
    }
    
    private func compile(varDecl: VarDeclaration) throws {
        // Compile the variable declaration using the subcompiler and then check
        // to make sure the type is as expected. This is a temporary scaffold
        // while I work to move the symbol table manipulation out of the
        // SnapToCrackleCompiler class.
        
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
    
    private func compile(seq: Seq) throws {
        currentSourceAnchor = seq.sourceAnchor
        for child in seq.children {
            try compile(genericNode: child)
        }
    }
    
    private func compile(block: Block) throws {
        currentSourceAnchor = block.sourceAnchor
        
        let parent = symbols
        symbols = block.symbols
        
        for child in block.children {
            try compile(genericNode: child)
        }
        
        symbols = parent
    }
    
    private func compile(return node: Return) throws {
        currentSourceAnchor = node.sourceAnchor
        guard node.expression == nil else {
            throw CompilerError(message: "only supports nil return expressions: `\(node)'")
        }
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
        try compile(block: node.body)
        currentSourceAnchor = sourceAnchors?.last
        symbols = parent
        
        emit([
            .label(labelTail),
        ])
    }
}
