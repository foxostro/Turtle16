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
    
    let memoryLayoutStrategy: MemoryLayoutStrategy
    let globalEnvironment: GlobalEnvironment
    var symbols = SymbolTable()
    var currentSourceAnchor: SourceAnchor? = nil
    
    public init(_ memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL(),
                _ globalEnvironment: GlobalEnvironment = GlobalEnvironment()) {
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
        case let node as Expression:
            try compile(expression: node)
        case let node as LabelDeclaration:
            try compile(label: node)
        case let node as Goto:
            try compile(goto: node)
        case let node as GotoIfFalse:
            try compile(gotoIfFalse: node)
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
    
    @discardableResult private func compile(expression: Expression) throws -> RvalueExpressionCompiler {
        currentSourceAnchor = expression.sourceAnchor
        let exprCompiler = RvalueExpressionCompiler(symbols: symbols,
                                                    labelMaker: globalEnvironment.labelMaker,
                                                    memoryLayoutStrategy: memoryLayoutStrategy)
        let ir = try exprCompiler.compile(expression: expression)
        emit(ir)
        return exprCompiler
    }
    
    func compile(label node: LabelDeclaration) throws {
        currentSourceAnchor = node.sourceAnchor
        emit([
            .label(node.identifier)
        ])
    }
    
    func compile(goto node: Goto) throws {
        currentSourceAnchor = node.sourceAnchor
        emit([
            .jmp(node.target)
        ])
    }
    
    func compile(gotoIfFalse node: GotoIfFalse) throws {
        currentSourceAnchor = node.sourceAnchor
        let tempConditionResult = try compile(expression: node.condition).temporaryStack.pop()
        emit([
            .jz(node.target, tempConditionResult.address)
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
        
        let sizeOfLocalVariables = node.symbols.highwaterMark
        
        let mangledName = (try TypeContextTypeChecker(symbols: symbols).check(expression: node.functionType).unwrapFunctionType()).mangledName!
        let labelHead = mangledName
        let labelTail = "__\(mangledName)_tail"
        emit([
            .jmp(labelTail),
            .label(labelHead),
            .pushReturnAddress,
            .enter(sizeOfLocalVariables)
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
