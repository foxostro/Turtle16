//
//  StatementTracer.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class StatementTracer: NSObject {
    public enum TraceElement: Equatable {
        case Statement(String)
        case IfThen
        case IfElse
        case IfSkipped
        case LoopBody
        case LoopSkipped
        case Return
    }
    public typealias Trace = [TraceElement]
    private let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    public func trace(ast node: AbstractSyntaxTreeNode) throws -> [Trace] {
        let traces = try trace(currentTrace: [], genericNode: node)
        return traces
    }
    
    public func trace(currentTrace: Trace, genericNode: AbstractSyntaxTreeNode) throws -> [Trace] {
        if let node = genericNode as? Block {
            return try trace(currentTrace: currentTrace, block: node)
        }
        else if let node = genericNode as? If {
            return try trace(currentTrace: currentTrace, if: node)
        }
        else if let node = genericNode as? While {
            return try trace(currentTrace: currentTrace, while: node)
        }
        else if let node = genericNode as? ForLoop {
            return try trace(currentTrace: currentTrace, forLoop: node)
        }
        else if let node = genericNode as? Return {
            return try trace(currentTrace: currentTrace, return: node)
        }
        else {
            return trace(currentTrace: currentTrace, stmt: genericNode)
        }
    }
    
    private func trace(currentTrace: Trace, block: Block) throws -> [Trace] {
        try checkForCodeAfterReturn(block: block)
        var stmts = block.children
        var traces: [Trace] = [currentTrace]
        while !stmts.isEmpty {
            let stmt = stmts[0]
            stmts.remove(at: 0)
            traces = try traces.flatMap{ try trace(currentTrace: $0, genericNode: stmt) }
        }
        return traces
    }
    
    private func checkForCodeAfterReturn(block: Block) throws {
        for i in 0..<block.children.count {
            let stmt = block.children[i]
            if let _ = stmt as? Return {
                if i != block.children.count-1 {
                    // TODO: Need to get the line number for the offending statement.
                    throw CompilerError(line: -1, message: "code after return will never be executed")
                }
            }
        }
    }
    
    private func trace(currentTrace: Trace, if node: If) throws -> [Trace] {
        switch currentTrace.last {
        case .Return:
            return [currentTrace]
        default:
            let thenTraces = try trace(currentTrace: currentTrace + [.IfThen], genericNode: node.thenBranch)
            let elseTraces: [Trace]
            if let elseBranch = node.elseBranch {
                elseTraces = try trace(currentTrace: currentTrace + [.IfElse], genericNode: elseBranch)
            } else {
                elseTraces = [currentTrace + [.IfSkipped]]
            }
            return thenTraces + elseTraces
        }
    }
    
    private func trace(currentTrace: Trace, while node: While) throws -> [Trace] {
        switch currentTrace.last {
        case .Return:
            return [currentTrace]
        default:
            let bodyTraces = try trace(currentTrace: currentTrace + [.LoopBody], genericNode: node.body)
            let skippedTraces = [currentTrace + [.LoopSkipped]]
            return bodyTraces + skippedTraces
        }
    }
    
    private func trace(currentTrace: Trace, forLoop node: ForLoop) throws -> [Trace] {
        switch currentTrace.last {
        case .Return:
            return [currentTrace]
        default:
            let bodyTraces = try trace(currentTrace: currentTrace + [.LoopBody], genericNode: node.body)
            let skippedTraces = [currentTrace + [.LoopSkipped]]
            return bodyTraces + skippedTraces
        }
    }
    
    private func trace(currentTrace: Trace, stmt: AbstractSyntaxTreeNode) -> [Trace] {
        switch currentTrace.last {
        case .Return:
            return [currentTrace]
        default:
            return [currentTrace + [.Statement(String(describing: type(of: stmt)))]]
        }
    }
    
    private func trace(currentTrace: Trace, return node: Return) throws -> [Trace] {
        switch currentTrace.last {
        case .Return:
            return [currentTrace]
        default:
            return [currentTrace + [.Return]]
        }
    }
}
