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
    public static let kReturnValueScratchLocation = 0x0005
    
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
    
    public func compile(ast: TopLevel) {
        instructions = []
        do {
            try tryCompile(ast: ast)
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    private func tryCompile(ast: TopLevel) throws {
        try compile(topLevel: ast)
    }
    
    private func compile(topLevel: TopLevel) throws {
        for node in topLevel.children {
            performDeclPass(genericNode: node)
        }
        for node in topLevel.children {
            try compile(genericNode: node)
        }
    }
    
    private func performDeclPass(genericNode: AbstractSyntaxTreeNode) {
        if let node = genericNode as? FunctionDeclaration {
            performDeclPass(func: node)
        }
        else if let node = genericNode as? Block {
            performDeclPass(block: node)
        }
    }
    
    private func performDeclPass(block: Block) {
        for node in block.children {
            performDeclPass(genericNode: node)
        }
    }
    
    private func performDeclPass(func funDecl: FunctionDeclaration) {
        let name = funDecl.identifier.lexeme
        let mangledName = makeMangledFunctionName(funDecl)
        let typ: SymbolType = .function(name: name, mangledName: mangledName, functionType: funDecl.functionType)
        let symbol = Symbol(type: typ, offset: 0x0000, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
    }
    
    private func makeMangledFunctionName(_ node: FunctionDeclaration) -> String {
        let name = Array(NSOrderedSet(array: symbols.allEnclosingFunctionNames() + [node.identifier.lexeme])).map{$0 as! String}.joined(separator: "_")
        return name
    }
    
    private func compile(genericNode: AbstractSyntaxTreeNode) throws {
        if let node = genericNode as? VarDeclaration {
            try compile(varDecl: node)
        }
        else if let node = genericNode as? Expression {
            try compile(expression: node)
            let returnExpressionType = try ExpressionTypeChecker(symbols: symbols).check(expression: node)
            switch returnExpressionType {
            case .u16:
                instructions += [.pop16]
            case .u8, .bool:
                instructions += [.pop]
            case .void:
                break
            case .function(name: _, mangledName: _, functionType: _):
                abort()
            }
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
        else if let node = genericNode as? Return {
            try compile(return: node)
        }
        else if let node = genericNode as? FunctionDeclaration {
            try compile(func: node)
        }
    }
    
    private func compile(varDecl: VarDeclaration) throws {
        let name = varDecl.identifier.lexeme
        guard symbols.existsAndCannotBeShadowed(identifier: name) == false else {
            throw CompilerError(line: varDecl.identifier.lineNumber,
                                format: "%@ redefines existing symbol: `%@'",
                                varDecl.isMutable ? "variable" : "constant",
                                varDecl.identifier.lexeme)
        }
        let symbol = try makeSymbolWithInferredType(expression: varDecl.expression, storage: varDecl.storage, isMutable: varDecl.isMutable)
        symbols.bind(identifier: name, symbol: symbol)
        try compile(expression: varDecl.expression)
        storeSymbol(symbol)
    }
    
    private func makeSymbolWithInferredType(expression: Expression, storage: SymbolStorage, isMutable: Bool) throws -> Symbol {
        let inferredType = try ExpressionTypeChecker(symbols: symbols).check(expression: expression)
        
        let storage: SymbolStorage = (symbols.stackFrameIndex==0) ? .staticStorage : storage
        
        let size: Int
        switch inferredType {
        case .u8, .bool: size = 1
        case .u16:       size = 2
        default:         size = 0
        }
        
        let offset: Int
        switch storage {
        case .staticStorage:
            offset = staticStoragePointer
            staticStoragePointer += size
        case .stackStorage:
            offset = symbols.storagePointer
            symbols.storagePointer += size
        }
        
        let symbol = Symbol(type: inferredType, offset: offset, isMutable: isMutable, storage: storage)
        return symbol
    }
    
    private func storeSymbol(_ symbol: Symbol) {
        switch symbol.storage {
        case .staticStorage:
            switch symbol.type {
            case .u16:
                instructions += [
                    .store16(symbol.offset),
                    .pop16
                ]
            case .bool, .u8:
                instructions += [
                    .store(symbol.offset),
                    .pop
                ]
            case .function, .void:
                abort()
            }
        case .stackStorage:
            // Evaluation of the expression has left the stack symbol's value
            // on the stack already. Nothing to do here.
            break
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
        performDeclPass(block: block)
        for child in block.children {
            try compile(genericNode: child)
        }
        popScope()
    }
    
    private func pushScope() {
        symbols = SymbolTable(parent: symbols)
    }
    
    private func popScope() {
        symbols = symbols.parent!
    }
    
    private func compile(return node: Return) throws {
        guard let enclosingFunctionType = symbols.enclosingFunctionType else {
            throw CompilerError(line: node.token.lineNumber, message: "return is invalid outside of a function")
        }
        if let expr = node.expression {
            try compile(expression: expr)
            let returnExpressionType = try ExpressionTypeChecker(symbols: symbols).check(expression: expr)
            switch (returnExpressionType, enclosingFunctionType.returnType) {
            case (.void, .void):
                instructions += [.store(SnapToYertleCompiler.kReturnValueScratchLocation)]
            case (.bool, .bool):
                instructions += [.store(SnapToYertleCompiler.kReturnValueScratchLocation)]
            case (.u8, .u8):
                instructions += [.store(SnapToYertleCompiler.kReturnValueScratchLocation)]
            case (.u8, .u16):
                instructions += [.push(0), .store16(SnapToYertleCompiler.kReturnValueScratchLocation)]
            case (.u16, .u16):
                instructions += [.store16(SnapToYertleCompiler.kReturnValueScratchLocation)]
            default:
                throw CompilerError(line: node.token.lineNumber,
                                    format: "cannot convert return expression of type `%@' to return type `%@'",
                                    String(describing: returnExpressionType),
                                    String(describing: enclosingFunctionType.returnType))
            }
        } else if .void != enclosingFunctionType.returnType {
            throw CompilerError(line: node.token.lineNumber, message: "non-void function should return a value")
        }
        instructions += [
            .leave,
            .ret
        ]
    }
    
    private func compile(func node: FunctionDeclaration) throws {
        try expectFunctionReturnExpressionIsCorrectType(func: node)
        
        let mangledName = makeMangledFunctionName(node)
        let labelHead = TokenIdentifier(lineNumber: -1, lexeme: mangledName)
        let labelTail = TokenIdentifier(lineNumber: -1, lexeme: "__\(mangledName)_tail")
        instructions += [
            .jmp(labelTail),
            .label(labelHead),
            .pushReturnAddress,
            .enter
        ]
        
        // Function arguments aren't inside the stack frame, but they are local
        // to the function. So, we define two scopes and only bind the inner
        // one to the stack frame.
        pushScopeForFunctionArguments(enclosingFunctionName: node.identifier.lexeme, enclosingFunctionType: node.functionType)
        bindFunctionArguments(node.functionType.arguments)
        pushScopeForNewStackFrame()
        performDeclPass(block: node.body)
        for child in node.body.children {
            try compile(genericNode: child)
        }
        if shouldSynthesizeTerminalReturnStatement(func: node) {
            try compile(return: Return(token: TokenReturn(lineNumber: -1, lexeme: ""), expression: nil))
        }
        popScope()
        popScope()
        
        instructions += [
            .label(labelTail),
        ]
    }
    
    private func pushScopeForFunctionArguments(enclosingFunctionName: String, enclosingFunctionType: FunctionType) {
        symbols = SymbolTable(parent: symbols)
        symbols.enclosingFunctionName = enclosingFunctionName
        symbols.enclosingFunctionType = enclosingFunctionType
    }
    
    private func bindFunctionArguments(_ arguments: [FunctionType.Argument]) {
        for i in 0..<arguments.count {
            let argument = arguments[i]
            let offset = symbols.storagePointer + i
            let symbol = Symbol(type: argument.argumentType, offset: offset, isMutable: false, storage: .stackStorage)
            symbols.bind(identifier: argument.name, symbol: symbol)
        }
    }
    
    private func pushScopeForNewStackFrame() {
        pushScope()
        symbols.storagePointer = 1
        symbols.stackFrameIndex += 1
    }
    
    private func expectFunctionReturnExpressionIsCorrectType(func node: FunctionDeclaration) throws {
        let tracer = StatementTracer(symbols: symbols)
        let traces = try tracer.trace(ast: node.body)
        for trace in traces {
            if let last = trace.last {
                switch last {
                case .Return:
                    break
                default:
                    if node.functionType.returnType != .void {
                        throw makeErrorForMissingReturn(node)
                    }
                }
            } else if node.functionType.returnType != .void {
                throw makeErrorForMissingReturn(node)
            }
        }
    }
    
    private func makeErrorForMissingReturn(_ node: FunctionDeclaration) -> CompilerError {
        return CompilerError(line: node.identifier.lineNumber,
                             format: "missing return in a function expected to return `%@'",
                             String(describing: node.functionType.returnType))
    }
    
    private func shouldSynthesizeTerminalReturnStatement(func node: FunctionDeclaration) -> Bool {
        guard node.functionType.returnType == .void else {
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
}
