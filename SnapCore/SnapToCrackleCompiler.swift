//
//  SnapToCrackleCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

// Compiles a Snap AST to the IR language.
public class SnapToCrackleCompiler: NSObject {
    // Temporary storage is allocated in a region starting at this address.
    // These temporaries are slots for scratch memory which are treated as,
    // allocated as, pseudo-registers.
    public static let kTemporaryStorageStartAddress = 0x0010
    public static let kTemporaryStorageLength = 0x0100
    
    // Static storage is allocated in a region starting at this address.
    // The allocator is a simple bump pointer.
    public static let kStaticStorageStartAddress = kTemporaryStorageStartAddress + kTemporaryStorageLength
    
    private let kStackPointerAddress: Int = Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi)
    
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool { !errors.isEmpty }
    public private(set) var instructions: [CrackleInstruction] = []
    public private(set) var mapInstructionToSource: [Int:SourceAnchor?] = [:]
    public let globalSymbols = SymbolTable()
    
    private var symbols: SymbolTable
    private let labelMaker = LabelMaker()
    private let mapMangledFunctionName = MangledFunctionNameMap()
    private var staticStoragePointer = SnapToCrackleCompiler.kStaticStorageStartAddress
    private var currentSourceAnchor: SourceAnchor? = nil
    
    public override init() {
        symbols = RvalueExpressionCompiler.bindCompilerIntrinsicFunctions(symbols: globalSymbols)
        super.init()
    }
    
    public func compile(ast: TopLevel) {
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
        let instructionsEnd = instructions.count
        if instructionsBegin < instructionsEnd {
            for i in instructionsBegin..<instructionsEnd {
                mapInstructionToSource[i] = currentSourceAnchor
            }
        }
    }
    
    private func tryCompile(ast: TopLevel) throws {
        try compile(topLevel: ast)
    }
    
    private func compile(topLevel: TopLevel) throws {
        for node in topLevel.children {
            try performDeclPass(genericNode: node)
        }
        for node in topLevel.children {
            try compile(genericNode: node)
        }
    }
    
    private func performDeclPass(genericNode: AbstractSyntaxTreeNode) throws {
        switch genericNode {
        case let node as FunctionDeclaration:
            try performDeclPass(func: node)
        case let node as StructDeclaration:
            performDeclPass(struct: node)
        case let node as Block:
            try performDeclPass(block: node)
        default:
            break
        }
    }
    
    private func performDeclPass(block: Block) throws {
        for node in block.children {
            try performDeclPass(genericNode: node)
        }
    }
    
    private func performDeclPass(func funDecl: FunctionDeclaration) throws {
        // Labels must be unique. Mangle the function name to ensure the
        // function's label is unique.
        let uid = mapMangledFunctionName.nextUID(mangledName: makeMangledFunctionName(funDecl))
        
        let functionType = try evaluateFunctionTypeExpression(funDecl.functionType)
        let name = funDecl.identifier.identifier
        let typ: SymbolType = .function(functionType)
        let symbol = Symbol(type: typ, offset: uid, isMutable: false, storage: .staticStorage)
        symbols.bind(identifier: name, symbol: symbol)
    }
    
    private func evaluateFunctionTypeExpression(_ expr: Expression) throws -> FunctionType {
        return try TypeContextTypeChecker(symbols: symbols).check(expression: expr).unwrapFunctionType()
    }
    
    private func performDeclPass(struct structDecl: StructDeclaration) {
        let name = structDecl.identifier.identifier
        let typ: SymbolType = .structType(name: name)
        symbols.bind(identifier: name, symbolType: typ)
    }
    
    private func makeMangledFunctionName(_ node: FunctionDeclaration) -> String {
        let name = Array(NSOrderedSet(array: symbols.allEnclosingFunctionNames() + [node.identifier.identifier])).map{$0 as! String}.joined(separator: "_")
        return name
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
        case let node as ForLoop:
            try compile(forLoop: node)
        case let node as Block:
            try compile(block: node)
        case let node as Return:
            try compile(return: node)
        case let node as FunctionDeclaration:
            try compile(func: node)
        default:
            break
        }
    }
    
    private func compile(varDecl: VarDeclaration) throws {
        guard symbols.existsAndCannotBeShadowed(identifier: varDecl.identifier.identifier) == false else {
            throw CompilerError(sourceAnchor: varDecl.identifier.sourceAnchor,
                                format: "%@ redefines existing symbol: `%@'",
                                varDecl.isMutable ? "variable" : "immutable variable",
                                varDecl.identifier.identifier)
        }
        
        // If the variable declaration provided an explicit type expression then
        // the type checker can determine what type it evaluates to.
        let explicitType: SymbolType?
        if let explicitTypeExpr = varDecl.explicitType {
            explicitType = try TypeContextTypeChecker(symbols: symbols).check(expression: explicitTypeExpr)
        } else {
            explicitType = nil
        }
        
        if let varDeclExpr = varDecl.expression {
            // The type of the initial value expression may be used to infer the
            // symbol type in cases where the explicit type is not specified.
            let expressionResultType = try RvalueExpressionTypeChecker(symbols: symbols).check(expression: varDeclExpr)
            
            // An explicit array type does not specify the number of array elements.
            // If the explicit type is an array type then we must examine the
            // expression result type to determine the array length.
            let symbolType: SymbolType
            switch (expressionResultType, explicitType) {
            case (.array(count: let count, elementType: _), .array(count: _, elementType: let elementType)):
                symbolType = .array(count: count, elementType: elementType)
            default:
                if let explicitType = explicitType {
                    symbolType = explicitType
                } else {
                    // Some expression types cannot be made concrete.
                    // Convert these appropriate convertible types.
                    switch expressionResultType {
                    case .constInt(let a):
                        symbolType = a > 255 ? .u16 : .u8
                    case .constBool:
                        symbolType = .bool
                    default:
                        symbolType = expressionResultType
                    }
                }
            }
            let symbol = try makeSymbolWithExplicitType(explicitType: symbolType, storage: varDecl.storage, isMutable: varDecl.isMutable)
            symbols.bind(identifier: varDecl.identifier.identifier, symbol: symbol)
            
            // If the symbol is on the stack then allocate storage for it now.
            if symbol.storage == .stackStorage {
                emit([
                    .subi16(kStackPointerAddress, kStackPointerAddress, symbol.type.sizeof)
                ])
            }
            
            try compile(expression: Expression.InitialAssignment(sourceAnchor: varDecl.sourceAnchor,
                                                                 lexpr: varDecl.identifier,
                                                                 rexpr: varDeclExpr))
        } else if let explicitType = explicitType {
            let symbol = try makeSymbolWithExplicitType(explicitType: explicitType, storage: varDecl.storage, isMutable: varDecl.isMutable)
            symbols.bind(identifier: varDecl.identifier.identifier, symbol: symbol)
            
            // If the symbol is on the stack then allocate storage for it now.
            if symbol.storage == .stackStorage {
                emit([
                    .subi16(kStackPointerAddress, kStackPointerAddress, symbol.type.sizeof)
                ])
            }
        } else {
            throw CompilerError(sourceAnchor: varDecl.identifier.sourceAnchor,
                                format: "unable to deduce type of %@ `%@'",
                                varDecl.isMutable ? "variable" : "immutable variable",
                                varDecl.identifier.identifier)
        }
    }
    
    private func makeSymbolWithExplicitType(explicitType: SymbolType, storage: SymbolStorage, isMutable: Bool) throws -> Symbol {
        let storage: SymbolStorage = (symbols.stackFrameIndex==0) ? .staticStorage : storage
        let offset = bumpStoragePointer(explicitType, storage)
        let symbol = Symbol(type: explicitType, offset: offset, isMutable: isMutable, storage: storage)
        return symbol
    }
    
    private func bumpStoragePointer(_ symbolType: SymbolType, _ storage: SymbolStorage) -> Int {
        let size = symbolType.sizeof
        let offset: Int
        switch storage {
        case .staticStorage:
            offset = staticStoragePointer
            staticStoragePointer += size
        case .stackStorage:
            symbols.storagePointer += size
            offset = symbols.storagePointer
        }
        return offset
    }
    
    // A statement can be a bare expression too.
    private func compile(expressionStatement node: Expression) throws {
        try compile(expression: node)
    }
    
    @discardableResult private func compile(expression: Expression) throws -> RvalueExpressionCompiler {
        currentSourceAnchor = expression.sourceAnchor
        let exprCompiler = RvalueExpressionCompiler(symbols: symbols,
                                                    labelMaker: labelMaker,
                                                    mapMangledFunctionName: mapMangledFunctionName)
        let ir = try exprCompiler.compile(expression: expression)
        emit(ir)
        return exprCompiler
    }
    
    private func compile(if stmt: If) throws {
        currentSourceAnchor = stmt.sourceAnchor
        if let elseBranch = stmt.elseBranch {
            let labelElse = labelMaker.next()
            let labelTail = labelMaker.next()
            let tempConditionResult = try compile(expression: stmt.condition).temporaryStack.pop()
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
            let tempConditionResult = try compile(expression: stmt.condition).temporaryStack.pop()
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
        currentSourceAnchor = stmt.sourceAnchor
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
    
    private func compile(forLoop stmt: ForLoop) throws {
        currentSourceAnchor = stmt.sourceAnchor
        let labelHead = labelMaker.next()
        let labelTail = labelMaker.next()
        try compile(genericNode: stmt.initializerClause)
        emit([.label(labelHead)])
        let tempConditionResult = try compile(expression: stmt.conditionClause).temporaryStack.pop()
        emit([
            .jz(labelTail, tempConditionResult.address)
        ])
        try compile(genericNode: stmt.body)
        try compile(genericNode: stmt.incrementClause)
        emit([
            .jmp(labelHead),
            .label(labelTail)
        ])
    }
    
    private func compile(block: Block) throws {
        currentSourceAnchor = block.sourceAnchor
        pushScopeForBlock()
        try performDeclPass(block: block)
        for child in block.children {
            try compile(genericNode: child)
        }
        popScopeForBlock()
    }
    
    private func pushScopeForBlock() {
        symbols = SymbolTable(parent: symbols)
    }
    
    private func popScopeForBlock() {
        let storagePointer = symbols.storagePointer
        symbols = symbols.parent!
        symbols.storagePointer = storagePointer
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
            try compile(expression: Expression.Assignment(sourceAnchor: node.sourceAnchor, lexpr: lexpr, rexpr: expr))
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
        currentSourceAnchor = node.sourceAnchor
        
        try expectFunctionReturnExpressionIsCorrectType(func: node)
        
        let mangledName = makeMangledFunctionName(node)
        let labelHead = mangledName
        let labelTail = "__\(mangledName)_tail"
        emit([
            .jmp(labelTail),
            .label(labelHead),
            .pushReturnAddress,
            .enter
        ])
        
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        pushScopeForNewStackFrame(enclosingFunctionName: node.identifier.identifier,
                                  enclosingFunctionType: functionType)
        bindFunctionArguments(functionType)
        try performDeclPass(block: node.body)
        for child in node.body.children {
            try compile(genericNode: child)
        }
        if try shouldSynthesizeTerminalReturnStatement(func: node) {
            try compile(return: Return(sourceAnchor: node.sourceAnchor, expression: nil))
        }
        popScopeForStackFrame()
        
        emit([
            .label(labelTail),
        ])
    }
    
    private func pushScopeForNewStackFrame(enclosingFunctionName: String,
                                           enclosingFunctionType: FunctionType) {
        symbols = SymbolTable(parent: symbols)
        symbols.storagePointer = 0
        symbols.stackFrameIndex += 1
        symbols.enclosingFunctionName = enclosingFunctionName
        symbols.enclosingFunctionType = enclosingFunctionType
    }
    
    private func popScopeForStackFrame() {
        symbols = symbols.parent!
    }
    
    private func bindFunctionArguments(_ typ: FunctionType) {
        let kReturnAddressSize = 2
        let kFramePointerSize = 2
        var offset = kReturnAddressSize + kFramePointerSize
        
        for i in (0..<typ.arguments.count).reversed() {
            let argument = typ.arguments[i]
            let symbol = Symbol(type: argument.argumentType,
                                offset: -offset,
                                isMutable: false,
                                storage: .stackStorage)
            symbols.bind(identifier: argument.name, symbol: symbol)
            offset += argument.argumentType.sizeof
        }
        
        // Bind a special symbol to contain the function return value.
        // This must be located just before the function arguments.
        let kReturnValueIdentifier = "__returnValue"
        symbols.bind(identifier: kReturnValueIdentifier,
                     symbol: Symbol(type: typ.returnType,
                                    offset: -offset,
                                    isMutable: true,
                                    storage: .stackStorage))
        offset += typ.returnType.sizeof
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
}
