//
//  CompilerPassGenericsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/30/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassGenericsTests: XCTestCase {
    fileprivate let constU16 = SymbolType.arithmeticType(.immutableInt(.u16))
    fileprivate let u16 = SymbolType.arithmeticType(.mutableInt(.u16))
    
    fileprivate func makeGenericFunctionDeclaration(_ parentSymbols: SymbolTable = SymbolTable()) -> FunctionDeclaration {
        let funSym = SymbolTable(parent: parentSymbols, frameLookupMode: .set(Frame()))
        return FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: Expression.FunctionType(
                name: "foo",
                returnType: Expression.Identifier("T"),
                arguments: [Expression.Identifier("T")]),
            argumentNames: ["a"],
            typeArguments: [
                Expression.GenericTypeArgument(
                    identifier: Expression.Identifier("T"),
                    constraints: [])
            ],
            body: Block(symbols: SymbolTable(parent: funSym), children: [
                Return(Expression.Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: funSym)
    }
    
    fileprivate func addGenericFunctionSymbol(_ symbols: SymbolTable) -> SymbolTable {
        let template = makeGenericFunctionDeclaration()
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericFunction(genericFunctionType)))
        return symbols
    }
    
    // Every expression with a generic function application is rewritten to
    // instead reference the concrete instantiation of the function.
    func testRewriteGenericFunctionApplicationExpressionToConcreteInstantiation() throws {
        let symbols = addGenericFunctionSymbol(SymbolTable())
        let expr = Expression.GenericTypeApplication(
            identifier: Expression.Identifier("foo"),
            arguments: [Expression.PrimitiveType(constU16)])
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let compiler = CompilerPassGenerics(symbols: symbols, globalEnvironment: globalEnvironment)
        let actual = try compiler.visit(expr: expr)
        let expected = Expression.Identifier("__foo_const_u16")
        XCTAssertEqual(actual, expected)
    }
    
    // The concrete instantiation of the function is inserted into the queue
    // to be compiled later.
    func testGenericFunctionApplicationCausesConcreteFunctionToBeQueued() throws {
        let symbols = addGenericFunctionSymbol(SymbolTable())
        let expr = Expression.GenericTypeApplication(
            identifier: Expression.Identifier("foo"),
            arguments: [Expression.PrimitiveType(constU16)])
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let compiler = CompilerPassGenerics(symbols: symbols, globalEnvironment: globalEnvironment)
        _ = try compiler.visit(expr: expr)
        
        XCTAssertFalse(globalEnvironment.functionsToCompile.isEmpty)
        let funTyp = globalEnvironment.functionsToCompile.removeFirst()
        XCTAssertEqual(funTyp.mangledName, "__foo_const_u16")
        XCTAssertEqual(funTyp.name, "foo")
        XCTAssertEqual(funTyp.arguments, [constU16])
        XCTAssertEqual(funTyp.returnType, constU16)
    }
    
    // The concrete instantiation of the function is added to the symbol table.
    func testGenericFunctionApplicationCausesConcreteFunctionToBeAddedToSymbolTable() throws {
        let symbols = addGenericFunctionSymbol(SymbolTable())
        let expr = Expression.GenericTypeApplication(
            identifier: Expression.Identifier("foo"),
            arguments: [Expression.PrimitiveType(constU16)])
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let compiler = CompilerPassGenerics(symbols: symbols, globalEnvironment: globalEnvironment)
        _ = try compiler.visit(expr: expr)
        
        let sym = try symbols.resolve(identifier: "__foo_const_u16")
        switch sym.type {
        case .function(let funTyp):
            XCTAssertEqual(funTyp.mangledName, "__foo_const_u16")
            XCTAssertEqual(funTyp.name, "foo")
            XCTAssertEqual(funTyp.arguments, [constU16])
            XCTAssertEqual(funTyp.returnType, constU16)
            
        default:
            XCTFail()
        }
    }
    
    // The generic function declaration is erased from the AST.
    func testGenericFunctionDeclarationIsErasedFromAST() throws {
        let ast0 = Block(children: [
            makeGenericFunctionDeclaration()
        ])
        
        let compiler = CompilerPassGenerics(symbols: SymbolTable(), globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()))
        let ast1 = try compiler.visit(ast0)
        
        XCTAssertEqual(ast1, Block())
    }
    
    // The concrete instantiation of the function is added to the AST.
    func testGenericFunctionApplicationCausesConcreteFunctionToBeAddedToAST() throws {
        let symbols = SymbolTable()
        let blockSymbols = SymbolTable(parent: symbols)
        let funSym = SymbolTable(parent: blockSymbols, frameLookupMode: .set(Frame()))
        
        let expected = Block(symbols: blockSymbols, children: [
            FunctionDeclaration(
                identifier: Expression.Identifier("__foo_const_u16"),
                functionType: Expression.FunctionType(
                    name: "__foo_const_u16",
                    returnType: Expression.PrimitiveType(constU16),
                    arguments: [Expression.PrimitiveType(constU16)]),
                argumentNames: ["a"],
                body: Block(children: [
                    Return(Expression.Identifier("a"))
                ]),
                visibility: .privateVisibility,
                symbols: funSym),
            Expression.Identifier("__foo_const_u16")
        ])
        
        let ast0 = Block(symbols: blockSymbols, children: [
            FunctionDeclaration(
                identifier: Expression.Identifier("foo"),
                functionType: Expression.FunctionType(
                    name: "foo",
                    returnType: Expression.Identifier("T"),
                    arguments: [Expression.Identifier("T")]),
                argumentNames: ["a"],
                typeArguments: [
                    Expression.GenericTypeArgument(
                        identifier: Expression.Identifier("T"),
                        constraints: [])
                ],
                body: Block(symbols: SymbolTable(parent: funSym), children: [
                    Return(Expression.Identifier("a"))
                ]),
                visibility: .privateVisibility,
                symbols: funSym),
            Expression.GenericTypeApplication(
                identifier: Expression.Identifier("foo"),
                arguments: [Expression.PrimitiveType(constU16)])
        ])
        
        let compiler = CompilerPassGenerics(symbols: symbols, globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()))
        let ast1 = try compiler.visit(ast0)
        
        XCTAssertEqual(ast1, expected)
    }
    
    // A Call expression which calls a generic function is rewritten to a
    // generic function application expression
    func testCallExprWithGenericFunctionIsRewrittenToApp() throws {
        let symbols = SymbolTable()
        let blockSymbols = SymbolTable(parent: symbols)
        let funSym = SymbolTable(parent: blockSymbols, frameLookupMode: .set(Frame()))
        
        let expected = Block(symbols: blockSymbols, children: [
            FunctionDeclaration(
                identifier: Expression.Identifier("__foo_u16"),
                functionType: Expression.FunctionType(
                    name: "__foo_u16",
                    returnType: Expression.PrimitiveType(u16),
                    arguments: [Expression.PrimitiveType(u16)]),
                argumentNames: ["a"],
                body: Block(children: [
                    Return(Expression.Identifier("a"))
                ]),
                visibility: .privateVisibility,
                symbols: funSym),
            Expression.Call(
                callee: Expression.Identifier("__foo_u16"),
                arguments: [Expression.PrimitiveType(u16)])
        ])
        
        let ast0 = Block(symbols: blockSymbols, children: [
            FunctionDeclaration(
                identifier: Expression.Identifier("foo"),
                functionType: Expression.FunctionType(
                    name: "foo",
                    returnType: Expression.Identifier("T"),
                    arguments: [Expression.Identifier("T")]),
                argumentNames: ["a"],
                typeArguments: [
                    Expression.GenericTypeArgument(
                        identifier: Expression.Identifier("T"),
                        constraints: [])
                ],
                body: Block(symbols: SymbolTable(parent: funSym), children: [
                    Return(Expression.Identifier("a"))
                ]),
                visibility: .privateVisibility,
                symbols: funSym),
            Expression.Call(
                callee: Expression.Identifier("foo"),
                arguments: [Expression.PrimitiveType(u16)])
        ])
        
        let compiler = CompilerPassGenerics(symbols: symbols, globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()))
        let ast1 = try compiler.visit(ast0)
        
        XCTAssertEqual(ast1, expected)
    }
    
    func testRejectsGenericFunctionApplicationWithIncorrectNumberOfArguments() throws {
        let symbols = SymbolTable()
        let funSym = SymbolTable(parent: symbols)
        let bodySym = SymbolTable(parent: funSym)
        let constU16 = SymbolType.arithmeticType(.mutableInt(.u16))
        let functionType = Expression.FunctionType(
            name: "foo",
            returnType: Expression.Identifier("T"),
            arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [
                Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])
            ],
            body: Block(symbols: bodySym),
            visibility: .privateVisibility,
            symbols: funSym)
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericFunction(genericFunctionType)))
        
        let compiler = CompilerPassGenerics(symbols: symbols, globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()))
        let expr = Expression.GenericTypeApplication(
            identifier: Expression.Identifier("foo"),
            arguments: [
                Expression.PrimitiveType(constU16),
                Expression.PrimitiveType(constU16)
            ])
        XCTAssertThrowsError(try compiler.visit(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic function type `foo@[u16, u16]'")
        }
    }
    
    func testCannotTakeTheAddressOfGenericFunctionWithInappropriateTypeArguments() {
        let constU16 = SymbolType.arithmeticType(.immutableInt(.u16))
        let symbols = SymbolTable()
        let funSym = SymbolTable(parent: symbols)
        let bodySym = SymbolTable(parent: funSym)
        let functionType = Expression.FunctionType(
            name: "foo",
            returnType: Expression.Identifier("T"),
            arguments: [Expression.Identifier("T")])
        let template = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [
                Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])
            ],
            body: Block(symbols: bodySym),
            visibility: .privateVisibility,
            symbols: funSym)
        let genericFunctionType = Expression.GenericFunctionType(template: template)
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericFunction(genericFunctionType)))

        let expr = Expression.Unary(
            op: .ampersand,
            expression: Expression.GenericTypeApplication(
                identifier: Expression.Identifier("foo"),
                arguments: [
                    Expression.PrimitiveType(constU16),
                    Expression.PrimitiveType(constU16)
                ]))
        let compiler = CompilerPassGenerics(symbols: symbols, globalEnvironment: GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16()))
        XCTAssertThrowsError(try compiler.visit(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "incorrect number of type arguments in application of generic function type `foo@[const u16, const u16]'")
        }
    }
}
