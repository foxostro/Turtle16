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
        else if let node = genericNode as? LetDeclaration {
            try compile(letDecl: node)
        }
        else if let node = genericNode as? VarDeclaration {
            try compile(varDecl: node)
        }
        else if let node = genericNode as? Expression {
            try compile(expression: node)
            instructions += [.pop] // Clean up the expression result
        }
        else if let node = genericNode as? If {
            try compile(if: node)
        }
        else if let node = genericNode as? While {
            try compile(while: node)
        }
        else if let node = genericNode as? ForLoop {
            try compile(forLoop: node)
        }
        else if let node = genericNode as? Block {
            for child in node.children {
                try compile(genericNode: child)
            }
        }
    }
    
    private func compile(label node: LabelDeclarationNode) {
        instructions += [.label(node.identifier)]
    }
    
    private func compile(letDecl: LetDeclaration) throws {
        let name = letDecl.identifier.lexeme
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: letDecl.identifier.lineNumber,
                                format: "constant redefines existing symbol: `%@'",
                                letDecl.identifier.lexeme)
        }
        
        let address = allocateStaticStorage()
        let symbol = try inferSymbolTypeFromExpressionType(expression: letDecl.expression, address: address, isMutable: false)
        symbols.bind(identifier: name, symbol: symbol)
        try compile(expression: letDecl.expression)
        instructions += [.store(address), .pop]
    }
    
    private func inferSymbolTypeFromExpressionType(expression: Expression, address: Int, isMutable: Bool) throws -> SymbolTable.Symbol {
        let symbol: SymbolTable.Symbol
        let inferredType = try ExpressionTypeChecker(symbols: symbols).check(expression: expression)
        switch inferredType {
        case .boolean:
            symbol = .boolean(.staticStorage(address: address, isMutable: isMutable))
        case .word:
            symbol = .word(.staticStorage(address: address, isMutable: isMutable))
        }
        return symbol
    }
    
    private func compile(varDecl: VarDeclaration) throws {
        let name = varDecl.identifier.lexeme
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: varDecl.identifier.lineNumber,
                                format: "variable redefines existing symbol: `%@'",
                                varDecl.identifier.lexeme)
        }
        let address = allocateStaticStorage()
        let symbol = try inferSymbolTypeFromExpressionType(expression: varDecl.expression, address: address, isMutable: true)
        symbols.bind(identifier: name, symbol: symbol)
        try compile(expression: varDecl.expression)
        instructions += [.store(address), .pop]
    }
    
    // The expression will push the result onto the stack. The client assumes the
    // responsibility of cleaning up.
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
    
    func compile(forLoop stmt: ForLoop) throws {
        let labelHead = makeTempLabel()
        let labelTail = makeTempLabel()
        try compile(genericNode: stmt.initializerClause)
        instructions += [.label(labelHead)]
        try compile(expression: stmt.conditionClause)
        instructions += [
            .push(0),
            .je(labelTail)
        ]
        try compile(genericNode: stmt.body)
        try compile(genericNode: stmt.incrementClause)
        instructions += [
            .jmp(labelHead),
            .label(labelTail)
        ]
    }
}
