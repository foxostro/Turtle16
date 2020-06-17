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
    public let globalSymbols = SymbolTable()
    
    private var symbols: SymbolTable
    private var tempLabelCounter = 0
    private var staticStoragePointer = SnapToYertleCompiler.kStaticStorageStartAddress
    
    public override init() {
        symbols = globalSymbols
        super.init()
    }
    
    // The generated program will need unique, temporary labels.
    private func makeTempLabel() -> TokenIdentifier {
        let label = ".L\(tempLabelCounter)"
        tempLabelCounter += 1
        return TokenIdentifier(lineNumber: -1, lexeme: label)
    }
    
    // Static storage is allocated in a region starting at this address.
    // The allocator is a simple bump pointer.
    public static let kStaticStorageStartAddress: Int = 0x0010
    
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
        if let node = genericNode as? VarDeclaration {
            try compile(varDecl: node)
        }
        else if let node = genericNode as? Expression {
            try compile(expression: node)
            instructions += [.pop]
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
            try compile(block: node)
        }
    }
    
    private func compile(varDecl: VarDeclaration) throws {
        let name = varDecl.identifier.lexeme
        guard symbols.exists(identifier: name) == false else {
            throw CompilerError(line: varDecl.identifier.lineNumber,
                                format: "%@ redefines existing symbol: `%@'",
                                varDecl.isMutable ? "variable" : "constant",
                                varDecl.identifier.lexeme)
        }
        let symbol = try makeSymbolWithInferredType(expression: varDecl.expression, storage: varDecl.storage, isMutable: varDecl.isMutable)
        symbols.bind(identifier: name, symbol: symbol)
        try compile(expression: varDecl.expression)
        storeSymbol(symbol)
        instructions += [.pop]
    }
    
    private func makeSymbolWithInferredType(expression: Expression, storage: SymbolStorage, isMutable: Bool) throws -> Symbol {
        let inferredType = try ExpressionTypeChecker(symbols: symbols).check(expression: expression)
        let storage: SymbolStorage = isInGlobalScope ? .staticStorage : storage
        
        let offset: Int
        switch storage {
        case .staticStorage:
            offset = staticStoragePointer
            staticStoragePointer += 1
        case .stackStorage:
            offset = symbols.storagePointer
            symbols.storagePointer += 1
        }
        
        let symbol = Symbol(type: inferredType, offset: offset, isMutable: isMutable, storage: storage)
        return symbol
    }
    
    private func storeSymbol(_ symbol: Symbol) {
        switch symbol.type {
        case .boolean, .u8:
            storeOneWord(symbol)
        case .function:
            abort()
        }
    }
    
    private func storeOneWord(_ symbol: Symbol) {
        switch symbol.storage {
        case .staticStorage:
            instructions += [
                .store(symbol.offset)
            ]
        case .stackStorage:
            // A local variable has a static offset from the frame pointer.
            // Given this offset, calculate the variable's address and then
            // store the initial value to that address. The initial value is
            // assumed to be at the top of the expression stack going into this
            // method.
            // Finally, decrement the stack pointer by one to ensure space for
            // the local variable is allocated on the stack frame.
            let kStackPointerAddressHi = Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi)
            let kStackPointerAddressLo = Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo)
            
            instructions += [
                // TODO: This whole sequence of instructions could (perhaps should) be replaced by a single, new instruction to push an eight-bit value to the control stack.
                
                .push(0xfe), // TODO: Assume the stack pointer high byte is 0xfe. This will not work if the stack grows larger than 256 bytes. To fix this, the IR language needs to support 16-bit math.
                .store(kStackPointerAddressHi),
                .pop,
                
                .push(1),
                .load(kStackPointerAddressLo),
                .sub,
                .store(kStackPointerAddressLo),
                .pop,
                
                .load(kStackPointerAddressHi),
                .load(kStackPointerAddressLo),
                .storeIndirect
            ]
        }
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
    
    private func compile(while stmt: While) throws {
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
    
    private func compile(forLoop stmt: ForLoop) throws {
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
    
    private func compile(block: Block) throws {
        pushScope()
        instructions += [.enter]
        for child in block.children {
            try compile(genericNode: child)
        }
        instructions += [.leave]
        popScope()
    }
    
    private func pushScope() {
        symbols = SymbolTable(parent: symbols)
        symbols.storagePointer = 1
    }
    
    private func popScope() {
        assert(!isInGlobalScope)
        symbols = symbols.parent!
    }
    
    private var isInGlobalScope: Bool {
        return symbols.parent == nil
    }
}
