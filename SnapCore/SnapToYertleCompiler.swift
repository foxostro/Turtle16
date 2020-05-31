//
//  SnapToYertleCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Compiles a Snap AST to the Yertle intermediate language.
public class SnapToYertleCompiler: NSObject {
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool { !errors.isEmpty }
    public private(set) var instructions: [YertleInstruction] = []
    public let symbols = SymbolTable()
    
    private var tempLabelCounter = 0
    
    // The generated program will need unique, temporary labels.
    private func makeTempLabel() -> TokenIdentifier {
        let label = ".L\(tempLabelCounter)"
        tempLabelCounter += 1
        return TokenIdentifier(lineNumber: -1, lexeme: label)
    }
    
    // Static storage is allocated in a region starting at this address.
    // The allocator is a simple bump pointer.
    public static let kStaticStorageStartAddress: Int = 0x0010
    private var staticStoragePointer = kStaticStorageStartAddress
    
    private func allocateStaticStorage(_ size: Int = 1) -> Int {
        let result = staticStoragePointer
        staticStoragePointer += size
        return result
    }
    
    public func compile(ast: AbstractSyntaxTreeNode) {
        instructions = []
        do {
            try tryCompile(ast: ast)
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    private func tryCompile(ast: AbstractSyntaxTreeNode) throws {
        try ast.iterate {
            try compile(genericNode: $0)
        }
    }
    
    private func compile(genericNode: AbstractSyntaxTreeNode) throws {
        if let node = genericNode as? LabelDeclarationNode {
            compile(label: node)
        }
        else if let node = genericNode as? ConstantDeclaration {
            try compile(constant: node)
        }
        else if let node = genericNode as? VarDeclaration {
            try compile(static: node)
        }
        else if let node = genericNode as? Expression {
            try compile(expression: node)
        }
        else if let node = genericNode as? If {
            try compile(if: node)
        }
        else if let node = genericNode as? While {
            try compile(while: node)
        }
    }
    
    private func compile(label node: LabelDeclarationNode) {
        instructions += [.label(node.identifier)]
    }
    
    private func compile(constant: ConstantDeclaration) throws {
        let name = constant.identifier.lexeme
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: constant.identifier.lineNumber,
                                format: "constant redefines existing symbol: `%@'",
                                constant.identifier.lexeme)
        }
        let eval = ExpressionEvaluatorCompileTime(symbols: symbols)
        do {
            let value = try eval.evaluate(expression: constant.expression)
            symbols.bindConstantWord(identifier: name, value: UInt8(value))
        } catch _ as Expression.MustBeCompileTimeConstantError {
            let address = allocateStaticStorage()
            symbols.bindStaticWord(identifier: name,
                                   address: address,
                                   isMutable: false)
            try compile(expression: constant.expression)
            instructions += [.store(address)]
        }
    }
    
    private func compile(static staticDeclaration: VarDeclaration) throws {
        let name = staticDeclaration.identifier.lexeme
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: staticDeclaration.identifier.lineNumber,
                                format: "variable redefines existing symbol: `%@'",
                                staticDeclaration.identifier.lexeme)
        }
        let address = allocateStaticStorage()
        symbols.bindStaticWord(identifier: name, address: address)
        try compile(expression: staticDeclaration.expression)
        instructions += [.store(address)]
    }
    
    private func compile(expression: Expression) throws {
        let exprCompiler = ExpressionSubCompiler(symbols: symbols)
        let ir = try exprCompiler.compile(expression: expression)
        instructions += ir
    }
    
    private func compile(if stmt: If) throws {
        if let elseBranch = stmt.elseBranch {
            let labelElse = makeTempLabel()
            let labelTail = makeTempLabel()
            try compile(expression: stmt.condition)
            instructions += [
                .push(0),
                .je(labelElse),
            ]
            try compile(genericNode: stmt.thenBranch)
            instructions += [
                .jmp(labelTail),
                .label(labelElse),
            ]
            try compile(genericNode: elseBranch)
            instructions += [.label(labelTail)]
        } else {
            let labelTail = makeTempLabel()
            try compile(expression: stmt.condition)
            instructions += [
                .push(0),
                .je(labelTail)
            ]
            try compile(genericNode: stmt.thenBranch)
            instructions += [.label(labelTail)]
        }
    }
    
    func compile(while stmt: While) throws {
        let labelHead = makeTempLabel()
        let labelTail = makeTempLabel()
        instructions += [.label(labelHead)]
        try compile(expression: stmt.condition)
        instructions += [
            .push(0),
            .je(labelTail)
        ]
        try compile(genericNode: stmt.body)
        instructions += [
            .jmp(labelHead),
            .label(labelTail)
        ]
    }
}
