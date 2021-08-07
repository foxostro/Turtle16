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
    
    public var isUsingStandardLibrary = false
    
    public var sandboxAccessManager: SandboxAccessManager? = nil
    
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
        
        var children: [AbstractSyntaxTreeNode] = []
        if isUsingStandardLibrary {
            let importStmt = Import(moduleName: kStandardLibraryModuleName)
            children.insert(importStmt, at: 0)
        }
        children += topLevel.children
        
        for node in children {
            try performDeclPass(genericNode: node)
        }
        
        for node in children {
            try compile(genericNode: node)
        }
    }
    
    private func performDeclPass(genericNode: AbstractSyntaxTreeNode) throws {
        switch genericNode {
        case let node as FunctionDeclaration:
            try performDeclPass(func: node)
        case let node as StructDeclaration:
            try performDeclPass(struct: node)
        case let node as Block:
            try performDeclPass(block: node)
        case let node as Typealias:
            try performDeclPass(typealias: node)
        case let node as Import:
            try performDeclPass(import: node)
        case let node as Module:
            try performDeclPass(module: node)
        case let node as TraitDeclaration:
            try performDeclPass(trait: node)
        case let node as TestDeclaration:
            fatalError("TestDeclaration should have been handled at a higher level: \(node)")
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
        let name = funDecl.identifier.identifier
        
        guard symbols.existsAndCannotBeShadowed(identifier: name) == false else {
            throw CompilerError(sourceAnchor: funDecl.identifier.sourceAnchor,
                                message: "function redefines existing symbol: `\(name)'")
        }
        
        let functionType = try evaluateFunctionTypeExpression(funDecl.functionType)
        let typ: SymbolType = .function(functionType)
        let symbol = Symbol(type: typ, offset: 0, storage: .automaticStorage, visibility: funDecl.visibility)
        symbols.bind(identifier: name, symbol: symbol)
    }
    
    private func evaluateFunctionTypeExpression(_ expr: Expression) throws -> FunctionType {
        return try TypeContextTypeChecker(symbols: symbols).check(expression: expr).unwrapFunctionType()
    }
    
    private func performDeclPass(struct structDecl: StructDeclaration) throws {
        let name = structDecl.identifier.identifier
        
        let members = SymbolTable(parent: symbols)
        let fullyQualifiedStructType = StructType(name: name, symbols: members)
        symbols.bind(identifier: name,
                     symbolType: .structType(fullyQualifiedStructType),
                     visibility: structDecl.visibility)
        
        members.enclosingFunctionNameMode = .set(name)
        for memberDeclaration in structDecl.members {
            let memberType = try TypeContextTypeChecker(symbols: members).check(expression: memberDeclaration.memberType)
            if memberType == .structType(fullyQualifiedStructType) || memberType == .constStructType(fullyQualifiedStructType) {
                throw CompilerError(sourceAnchor: memberDeclaration.memberType.sourceAnchor, message: "a struct cannot contain itself recursively")
            }
            let symbol = Symbol(type: memberType, offset: members.storagePointer, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            members.storagePointer += sizeOfMemberType
        }
        members.parent = nil
    }
    
    private func performDeclPass(typealias node: Typealias) throws {
        guard false == symbols.existsAsTypeAndCannotBeShadowed(identifier: node.lexpr.identifier) else {
            throw CompilerError(sourceAnchor: node.lexpr.sourceAnchor,
                                message: "typealias redefines existing type: `\(node.lexpr.identifier)'")
        }
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let symbolType = try typeChecker.check(expression: node.rexpr)
        symbols.bind(identifier: node.lexpr.identifier,
                     symbolType: symbolType,
                     visibility: node.visibility)
    }
    
    private var moduleSymbols: [String : SymbolTable] = [:]
    
    private func performDeclPass(import node: Import) throws {
        guard symbols.parent == nil else {
            throw CompilerError(sourceAnchor: node.sourceAnchor, message: "declaration is only valid at file scope")
        }
        
        guard false == modulesBeingImported.contains(node.moduleName) else {
            return
        }
        
        modulesBeingImported.insert(node.moduleName)
        
        if nil == moduleSymbols[node.moduleName] && false == modulesAlreadyImported.contains(node.moduleName) {
            try compileModuleForImport(import: node)
        }
        
        try exportPublicSymbolsFromModule(sourceAnchor: node.sourceAnchor, name: node.moduleName)
        
        modulesBeingImported.remove(node.moduleName)
    }
    
    public func compileModuleForImport(import node: Import) throws {
        let moduleData = try readModuleFromFile(sourceAnchor: node.sourceAnchor, moduleName: node.moduleName)
        let moduleTopLevel = try compileProgramText(url: moduleData.1, text: moduleData.0)
        let module = Module(sourceAnchor: moduleTopLevel.sourceAnchor,
                            name: node.moduleName,
                            children: moduleTopLevel.children,
                            symbols: moduleTopLevel.symbols)
        try performDeclPass(genericNode: module)
        try compile(genericNode: module)
    }
    
    public func compileProgramText(url: URL?, text: String) throws -> Block {
        let filename = url?.lastPathComponent
        
        // Lexer pass
        let lexer = SnapLexer(text, url)
        lexer.scanTokens()
        if lexer.hasError {
            throw CompilerError.makeOmnibusError(fileName: filename, errors: lexer.errors)
        }
        
        // Compile to a parser syntax tree
        let parser = SnapParser(tokens: lexer.tokens)
        parser.parse()
        if parser.hasError {
            throw CompilerError.makeOmnibusError(fileName: filename, errors: parser.errors)
        }
        
        // AST contraction step
        let contractionStep = SnapAbstractSyntaxTreeCompiler(memoryLayoutStrategy: memoryLayoutStrategy)
        contractionStep.compile(parser.syntaxTree)
        if contractionStep.hasError {
            throw CompilerError.makeOmnibusError(fileName: filename, errors: contractionStep.errors)
        }
        let topLevel = contractionStep.ast
        
        return topLevel
    }
    
    private func performDeclPass(module: Module) throws {
        guard symbols.parent == nil else {
            throw CompilerError(sourceAnchor: module.sourceAnchor, message: "declaration is only valid at file scope")
        }
        
        currentSourceAnchor = module.sourceAnchor
        
        // Modules do not inherit symbols from the code which imports them.
        // Create a new symbol table with no relationship to the existing one.
        // Change the storage pointer so the new one doesn't overwrite existing
        // symbols.
        let oldModulesAlreadyImported = modulesAlreadyImported
        modulesAlreadyImported = []
        let oldSymbols = symbols
        symbols = module.symbols
        symbols.storagePointer = oldSymbols.storagePointer
        
        // Make sure to import the standard library when building a module.
        // TODO: Adding an `import stdlib` to the Module body is something that can be done in an AST macro
        let importStdlib = Import(moduleName: kStandardLibraryModuleName)
        let nodes: [AbstractSyntaxTreeNode] = [importStdlib] + module.children
        
        for node in nodes {
            SymbolTablesReconnector(symbols).reconnect(node)
        }
        for node in nodes {
            try performDeclPass(genericNode: node)
        }
        for child in nodes {
            try compile(genericNode: child)
        }
        
        // Stash away the symbol table of the module and restore the old symbol
        // table chain. Make sure to continue allocating where the module left
        // off.
        // TODO: Why not put a symbol table on Module and store it there? SymbolTableReconnector should handle the case of Module too. Or maybe the entire module should be put into the symbol table as a distinct global instance of a distinct type?
        moduleSymbols[module.name] = symbols
        let storagePointer = symbols.storagePointer
        symbols = oldSymbols
        symbols.storagePointer = storagePointer
        modulesAlreadyImported = oldModulesAlreadyImported
    }
    
    private func readModuleFromFile(sourceAnchor: SourceAnchor?, moduleName: String) throws -> (String, URL) {
        // Try retrieving the module from the manually injected modules.
        if let sourceCode = injectedModules[moduleName] {
            return (sourceCode, URL.init(string: moduleName)!)
        }
        
        // Try retrieving the module from file.
        if let sourceAnchor = sourceAnchor, let url = URL.init(string: moduleName.appending(".snap"), relativeTo: sourceAnchor.url?.deletingLastPathComponent()) {
            sandboxAccessManager?.requestAccess(url: sourceAnchor.url?.deletingLastPathComponent())
            do {
                let text = try String(contentsOf: url, encoding: String.Encoding.utf8)
                return (text, url)
            } catch {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "failed to read module `\(moduleName)' from file `\(url)'")
            }
        }
        else if let url = Bundle(for: type(of: self)).url(forResource: moduleName, withExtension: "snap") { // Try retrieving the module from bundle resources.
            do {
                let text = try String(contentsOf: url)
                return (text, url)
            } catch {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "failed to read module `\(moduleName)' from file `\(url)'")
            }
        }
        
        throw CompilerError(sourceAnchor: sourceAnchor, message: "no such module `\(moduleName)'")
    }
    
    private var modulesBeingImported: Set<String> = []
    private var modulesAlreadyImported: Set<String> = []
    
    // Copy symbols from the module to the parent scope.
    private func exportPublicSymbolsFromModule(sourceAnchor: SourceAnchor?, name: String) throws {
        guard false == modulesAlreadyImported.contains(name) else {
            return
        }
        
        guard let src = moduleSymbols[name] else {
            throw CompilerError(sourceAnchor: sourceAnchor, message: "failed to get symbols for module `\(name)'")
        }
        
        for (identifier, symbol) in src.symbolTable {
            if symbol.visibility == .publicVisibility {
                guard symbols.existsAndCannotBeShadowed(identifier: identifier) == false else {
                    throw CompilerError(sourceAnchor: sourceAnchor, message: "import of module `\(name)' redefines existing symbol: `\(identifier)'")
                }
                symbols.bind(identifier: identifier,
                             symbol: Symbol(type: symbol.type,
                                            offset: symbol.offset,
                                            storage: symbol.storage,
                                            visibility: .privateVisibility))
            }
        }
        
        for (identifier, record) in src.typeTable {
            if record.visibility == .publicVisibility {
                guard symbols.existsAsType(identifier: identifier) == false else {
                    throw CompilerError(sourceAnchor: sourceAnchor, message: "import of module `\(name)' redefines existing type: `\(identifier)'")
                }
                symbols.bind(identifier: identifier,
                            symbolType: record.symbolType,
                            visibility: .privateVisibility)
            }
        }
        
        modulesAlreadyImported.insert(name)
    }
    
    private func performDeclPass(trait traitDecl: TraitDeclaration) throws {
        try declareTraitType(traitDecl)
        try declareVtableType(traitDecl)
        try declareTraitObjectType(traitDecl)
    }
    
    fileprivate func declareTraitType(_ traitDecl: TraitDeclaration) throws {
        let name = traitDecl.identifier.identifier
        
        let members = SymbolTable(parent: symbols)
        let fullyQualifiedTraitType = TraitType(name: name, nameOfTraitObjectType: traitDecl.nameOfTraitObjectType, nameOfVtableType: traitDecl.nameOfVtableType, symbols: members)
        symbols.bind(identifier: name,
                     symbolType: .traitType(fullyQualifiedTraitType),
                     visibility: traitDecl.visibility)
        
        members.enclosingFunctionNameMode = .set(name)
        for memberDeclaration in traitDecl.members {
            let memberType = try TypeContextTypeChecker(symbols: members).check(expression: memberDeclaration.memberType)
            let symbol = Symbol(type: memberType, offset: members.storagePointer, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            members.storagePointer += sizeOfMemberType
        }
        members.parent = nil
    }
    
    fileprivate func declareVtableType(_ traitDecl: TraitDeclaration) throws {
        let traitName = traitDecl.identifier.identifier
        let members: [StructDeclaration.Member] = traitDecl.members.map {
            let memberType = rewriteTraitMemberTypeForVtable(traitName, $0.memberType)
            let member = StructDeclaration.Member(name: $0.name, type: memberType)
            return member
        }
        let structDecl = StructDeclaration(sourceAnchor: traitDecl.sourceAnchor,
                                           identifier: Expression.Identifier(traitDecl.nameOfVtableType),
                                           members: members,
                                           visibility: traitDecl.visibility)
        return try performDeclPass(struct: structDecl)
    }
    
    fileprivate func rewriteTraitMemberTypeForVtable(_ traitName: String, _ expr: Expression) -> Expression {
        if let functionType = (expr as? Expression.PointerType)?.typ as? Expression.FunctionType {
            if let arg0 = functionType.arguments.first {
                if ((arg0 as? Expression.PointerType)?.typ as? Expression.Identifier)?.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = Expression.PointerType(Expression.PrimitiveType(.void))
                    let modifiedFunctionType = Expression.FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return Expression.PointerType(modifiedFunctionType)
                }
                
                if (((arg0 as? Expression.PointerType)?.typ as? Expression.ConstType)?.typ as? Expression.Identifier)?.identifier == traitName {
                    var arguments: [Expression] = functionType.arguments
                    arguments[0] = Expression.PointerType(Expression.PrimitiveType(.void))
                    let modifiedFunctionType = Expression.FunctionType(returnType: functionType.returnType, arguments: arguments)
                    return Expression.PointerType(modifiedFunctionType)
                }
            }
        }
        
        return expr
    }
    
    fileprivate func declareTraitObjectType(_ traitDecl: TraitDeclaration) throws {
        let members: [StructDeclaration.Member] = [
            StructDeclaration.Member(name: "object", type: Expression.PointerType(Expression.PrimitiveType(.void))),
            StructDeclaration.Member(name: "vtable", type: Expression.PointerType(Expression.ConstType(Expression.Identifier(traitDecl.nameOfVtableType))))
        ]
        let structDecl = StructDeclaration(sourceAnchor: traitDecl.sourceAnchor,
                                           identifier: Expression.Identifier(traitDecl.nameOfTraitObjectType),
                                           members: members,
                                           visibility: traitDecl.visibility)
        return try performDeclPass(struct: structDecl)
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
        case let node as Block:
            try compile(block: node)
        case let node as Return:
            try compile(return: node)
        case let node as FunctionDeclaration:
            try compile(func: node)
        case let node as Impl:
            try compile(impl: node)
        case let node as ImplFor:
            try compile(implFor: node)
        case let node as Match:
            try compile(match: node)
        case let node as Assert:
            try compile(assert: node)
        case let node as TraitDeclaration:
            try compile(trait: node)
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
    
    private func compile(block: Block) throws {
        currentSourceAnchor = block.sourceAnchor
        
        let parent = symbols
        assert(block.symbols.parent == symbols)
        symbols = block.symbols
        
        try performDeclPass(block: block)
        for child in block.children {
            try compile(genericNode: child)
        }
        
        let storagePointer = symbols.storagePointer
        symbols = parent
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
        node.symbols.parent = parent
        node.symbols.enclosingFunctionTypeMode = .set(functionType)
        node.symbols.enclosingFunctionNameMode = .set(node.identifier.identifier)
        node.symbols.storagePointer = 0
        node.symbols.stackFrameIndex = parent.stackFrameIndex + 1
        symbols = node.symbols
        
        bindFunctionArguments(functionType: functionType, argumentNames: node.argumentNames)
        try performDeclPass(block: node.body)
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
    
    private func compile(impl: Impl) throws {
        let typ = try symbols.resolveType(sourceAnchor: impl.identifier.sourceAnchor, identifier: impl.identifier.identifier).unwrapStructType()
        
        symbols = SymbolTable(parent: symbols)
        symbols.enclosingFunctionNameMode = .set(impl.identifier.identifier)
        
        SymbolTablesReconnector(symbols).reconnect(impl)
        
        for child in impl.children {
            let identifier = child.identifier.identifier
            if typ.symbols.exists(identifier: identifier) {
                throw CompilerError(sourceAnchor: child.sourceAnchor,
                                    message: "function redefines existing symbol: `\(identifier)'")
            }
            try performDeclPass(func: child)
            
            // Put the symbol back into the struct type's symbol table too.
            typ.symbols.bind(identifier: identifier, symbol: symbols.symbolTable[identifier]!)
        }
        
        for child in impl.children {
            try compile(func: child)
        }
        
        let storagePointer = symbols.storagePointer
        symbols = symbols.parent!
        symbols.storagePointer = storagePointer
    }
    
    private func compile(implFor: ImplFor) throws {
        let traitType = try symbols.resolveType(sourceAnchor: implFor.sourceAnchor,
                                                identifier: implFor.traitIdentifier.identifier).unwrapTraitType()
        let structType = try symbols.resolveType(sourceAnchor: implFor.sourceAnchor,
                                                 identifier: implFor.structIdentifier.identifier).unwrapStructType()
        let vtableType = try symbols.resolveType(sourceAnchor: implFor.sourceAnchor,
                                                 identifier: traitType.nameOfVtableType).unwrapStructType()
        
        try compile(impl: Impl(sourceAnchor: implFor.sourceAnchor, identifier: implFor.structIdentifier, children: implFor.children))
        
        let sortedTraitSymbols = traitType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (requiredMethodName, requiredMethodSymbol) in sortedTraitSymbols {
            let maybeActualMethodSymbol = structType.symbols.maybeResolve(identifier: requiredMethodName)
            guard let actualMethodSymbol = maybeActualMethodSymbol else {
                throw CompilerError(sourceAnchor: implFor.sourceAnchor, message: "`\(structType.name)' does not implement all trait methods; missing `\(requiredMethodName)'.")
            }
            let actualMethodType = actualMethodSymbol.type.unwrapFunctionType()
            let expectedMethodType = requiredMethodSymbol.type.unwrapPointerType().unwrapFunctionType()
            guard actualMethodType.arguments.count == expectedMethodType.arguments.count else {
                throw CompilerError(sourceAnchor: implFor.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has \(actualMethodType.arguments.count) parameter but the declaration in the `\(traitType.name)' trait has \(expectedMethodType.arguments.count).")
            }
            if actualMethodType.arguments.count > 0 {
                let actualArgumentType = actualMethodType.arguments[0]
                let expectedArgumentType = expectedMethodType.arguments[0]
                if actualArgumentType != expectedArgumentType {
                    let typeChecker = TypeContextTypeChecker(symbols: symbols)
                    let genericMutableSelfPointerType = try typeChecker.check(expression: Expression.PointerType(Expression.Identifier(traitType.name)))
                    let concreteMutableSelfPointerType = try typeChecker.check(expression: Expression.PointerType(Expression.Identifier(structType.name)))
                    if expectedArgumentType == genericMutableSelfPointerType {
                        if actualArgumentType != concreteMutableSelfPointerType {
                            throw CompilerError(sourceAnchor: implFor.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(concreteMutableSelfPointerType)' argument, got `\(actualArgumentType)' instead")
                        }
                    }
                    else {
                        throw CompilerError(sourceAnchor: implFor.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedArgumentType)' argument, got `\(actualArgumentType)' instead")
                    }
                }
            }
            if actualMethodType.arguments.count > 1 {
                for i in 1..<actualMethodType.arguments.count {
                    let actualArgumentType = actualMethodType.arguments[i]
                    let expectedArgumentType = expectedMethodType.arguments[i]
                    guard actualArgumentType == expectedArgumentType else {
                        throw CompilerError(sourceAnchor: implFor.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedArgumentType)' argument, got `\(actualArgumentType)' instead")
                    }
                }
            }
            if actualMethodType.returnType != expectedMethodType.returnType {
                throw CompilerError(sourceAnchor: implFor.sourceAnchor, message: "`\(structType.name)' method `\(requiredMethodName)' has incompatible type for trait `\(traitType.name)'; expected `\(expectedMethodType.returnType)' return value, got `\(actualMethodType.returnType)' instead")
            }
        }
        
        let nameOfVtableInstance = "__\(traitType.name)_\(structType.name)_vtable_instance"
        var arguments: [Expression.StructInitializer.Argument] = []
        let sortedVtableSymbols = vtableType.symbols.symbolTable.sorted { $0.0 < $1.0 }
        for (methodName, methodSymbol) in sortedVtableSymbols {
            let arg = Expression.StructInitializer.Argument(name: methodName, expr: Expression.Bitcast(expr: Expression.Unary(op: .ampersand, expression: Expression.Get(expr: Expression.Identifier(structType.name), member: Expression.Identifier(methodName))), targetType: Expression.PrimitiveType(methodSymbol.type)))
            arguments.append(arg)
        }
        let initializer = Expression.StructInitializer(identifier: Expression.Identifier(traitType.nameOfVtableType), arguments: arguments)
        let visibility = try symbols.resolveTypeRecord(sourceAnchor: implFor.sourceAnchor,
                                                       identifier: implFor.traitIdentifier.identifier).visibility
        try compile(varDecl: VarDeclaration(identifier: Expression.Identifier(nameOfVtableInstance),
                                            explicitType: Expression.Identifier(traitType.nameOfVtableType),
                                            expression: initializer,
                                            storage: .staticStorage,
                                            isMutable: false,
                                            visibility: visibility))
    }
    
    private func compile(match: Match) throws {
        let ast = try MatchCompiler(memoryLayoutStrategy).compile(match: match, symbols: symbols)
        try compile(genericNode: ast)
    }
    
    private func compile(assert node: Assert) throws {
        let ast = try SnapSubcompilerAssert().compile(node)
        SymbolTablesReconnector(symbols).reconnect(ast)
        try compile(genericNode: ast)
    }
    
    private func compile(trait traitDecl: TraitDeclaration) throws {
        // TODO: It might be better to split handling of an impl block into a declaration phase and a compile phase, as is done for functions.
        try compileTraitObjectThunks(traitDecl)
    }
    
    fileprivate func compileTraitObjectThunks(_ traitDecl: TraitDeclaration) throws {
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map { ($0 == 0) ? "self" : "arg\($0)" }
            let callee = Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier(method.name))
            let arguments = [Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))] + argumentNames[1...].map({Expression.Identifier($0)})
            
            let outer = SymbolTable(parent: symbols)
            
            let fnBody: Block
            let returnType = try TypeContextTypeChecker(symbols: symbols).check(expression: functionType.returnType)
            if returnType == .void {
                fnBody = Block(symbols: SymbolTable(parent: outer),
                               children: [Expression.Call(callee: callee, arguments: arguments)])
            } else {
                fnBody = Block(symbols: SymbolTable(parent: outer),
                               children: [Return(Expression.Call(callee: callee, arguments: arguments))])
            }
            
            let fnDecl = FunctionDeclaration(identifier: Expression.Identifier(method.name),
                                             functionType: functionType,
                                             argumentNames: argumentNames,
                                             body: fnBody,
                                             symbols: outer)
            thunks.append(fnDecl)
        }
        let implBlock = Impl(sourceAnchor: traitDecl.sourceAnchor, identifier: Expression.Identifier(traitDecl.nameOfTraitObjectType), children: thunks)
        return try compile(impl: implBlock)
    }
    
    fileprivate func rewriteTraitMemberTypeForThunk(_ traitDecl: TraitDeclaration, _ method: TraitDeclaration.Member) -> Expression.FunctionType {
        
        let traitName = traitDecl.identifier.identifier
        let traitObjectName = traitDecl.nameOfTraitObjectType
        let functionType = (method.memberType as! Expression.PointerType).typ as! Expression.FunctionType
        
        if let arg0 = functionType.arguments.first {
            if ((arg0 as? Expression.PointerType)?.typ as? Expression.Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = Expression.PointerType(Expression.Identifier(traitObjectName))
                let modifiedFunctionType = Expression.FunctionType(name: method.name, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
            
            if (((arg0 as? Expression.PointerType)?.typ as? Expression.ConstType)?.typ as? Expression.Identifier)?.identifier == traitName {
                var arguments: [Expression] = functionType.arguments
                arguments[0] = Expression.PointerType(Expression.ConstType(Expression.Identifier(traitObjectName)))
                let modifiedFunctionType = Expression.FunctionType(name: method.name, returnType: functionType.returnType, arguments: arguments)
                return modifiedFunctionType
            }
        }
        
        return functionType
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
