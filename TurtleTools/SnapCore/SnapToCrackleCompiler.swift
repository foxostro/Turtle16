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
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool { !errors.isEmpty }
    public private(set) var instructions: [CrackleInstruction] = []
    public var programDebugInfo: SnapDebugInfo? = nil
    public private(set) var globalSymbols = SymbolTable()
    
    let kStackPointerAddress: Int = Int(SnapCompilerMetrics.kStackPointerAddressHi)
    let memoryLayoutStrategy: MemoryLayoutStrategy
    let globalEnvironment: GlobalEnvironment
    let labelMaker = LabelMaker()
    var symbols = SymbolTable()
    var currentSourceAnchor: SourceAnchor? = nil
    
    public init(_ memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL(), _ globalEnvironment: GlobalEnvironment = GlobalEnvironment()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.globalEnvironment = globalEnvironment
    }
    
    public func compile(ast: Block) {
        instructions = []
        do {
            try compile(topLevel: ast)
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    func emit(_ ins: [CrackleInstruction]) {
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
    
    func compile(topLevel: Block) throws {
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
    
    func compile(genericNode: AbstractSyntaxTreeNode) throws {
        currentSourceAnchor = genericNode.sourceAnchor
        switch genericNode {
        case let node as VarDeclaration:
            try compile(varDecl: node)
        case let node as Expression:
            try compile(expression: node)
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
    
    func compile(varDecl: VarDeclaration) throws {
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
    
    @discardableResult private func compile(expression: Expression) throws -> RvalueExpressionCompiler {
        currentSourceAnchor = expression.sourceAnchor
        let exprCompiler = RvalueExpressionCompiler(symbols: symbols,
                                                    labelMaker: labelMaker,
                                                    memoryLayoutStrategy: memoryLayoutStrategy)
        let ir = try exprCompiler.compile(expression: expression)
        emit(ir)
        return exprCompiler
    }
    
    func compile(if stmt: If) throws {
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
    
    func compile(while stmt: While) throws {
        currentSourceAnchor = stmt.sourceAnchor?.split().first
        let labelHead = labelMaker.next()
        let labelTail = labelMaker.next()
        emit([.label(labelHead)])
        let tempConditionResult = try compile(expression: stmt.condition).temporaryStack.pop()
        emit([
            .jz(labelTail, tempConditionResult.address)
        ])
        try compile(genericNode: stmt.body)
        emit([
            .jmp(labelHead),
            .label(labelTail)
        ])
    }
    
    func compile(seq: Seq) throws {
        currentSourceAnchor = seq.sourceAnchor
        for child in seq.children {
            try compile(genericNode: child)
        }
    }
    
    func compile(block: Block) throws {
        currentSourceAnchor = block.sourceAnchor
        
        let parent = symbols
        symbols = block.symbols
        
        for child in block.children {
            try compile(genericNode: child)
        }
        
        symbols = parent
    }
    
    func compile(return node: Return) throws {
        currentSourceAnchor = node.sourceAnchor
        guard node.expression == nil else {
            throw CompilerError(message: "only supports nil return expressions: `\(node)'")
        }
        emit([
            .leave,
            .ret
        ])
    }
    
    func compile(func node: FunctionDeclaration) throws {
        currentSourceAnchor = node.sourceAnchor?.split().first
        
        let mangledName = (try TypeContextTypeChecker(symbols: symbols).check(expression: node.functionType).unwrapFunctionType()).mangledName!
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
        symbols = parent
        
        emit([
            .label(labelTail),
        ])
    }
}
