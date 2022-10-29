//
//  SnapSubcompilerImplForTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerImplForTests: XCTestCase {
    fileprivate func compileSerialTrait(_ globalEnvironment: GlobalEnvironment,  _ globalSymbols: SymbolTable) throws {
        let bar = TraitDeclaration.Member(name: "puts", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
            Expression.PointerType(Expression.Identifier("Serial")),
            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])))
        let traitDecl = TraitDeclaration(identifier: Expression.Identifier("Serial"),
                                         members: [bar],
                                         visibility: .privateVisibility)
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(traitDecl)
    }
    
    fileprivate func compileSerialFake(_ globalEnvironment: GlobalEnvironment,  _ globalSymbols: SymbolTable) throws {
        let fake = StructDeclaration(identifier: Expression.Identifier("SerialFake"), members: [])
        try SnapSubcompilerStructDeclaration(symbols: globalSymbols, globalEnvironment: globalEnvironment)
            .compile(fake)
    }
    
    func testCompileImplForTrait() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        
        try compileSerialTrait(globalEnvironment, globalSymbols)
        try compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitTypeExpr: Expression.Identifier("Serial"),
                          structTypeExpr: Expression.Identifier("SerialFake"),
                          children: [
                              FunctionDeclaration(identifier: Expression.Identifier("puts"),
                                                  functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [
                                                      Expression.PointerType(Expression.Identifier("Serial")),
                                                      Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                                  ]),
                                                  argumentNames: ["self", "s"],
                                                  body: Block())
                          ])
        
        try SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment).compile(ast)
        
        // Let's examine, for correctness, the vtable symbol
        let nameOfVtableInstance = "__Serial_SerialFake_vtable_instance"
        let vtableInstance = try globalSymbols.resolve(identifier: nameOfVtableInstance)
        let vtableStructType = vtableInstance.type.unwrapStructType()
        XCTAssertEqual(vtableStructType.name, "__Serial_vtable")
        XCTAssertEqual(vtableStructType.symbols.exists(identifier: "puts"), true)
        let putsSymbol = try vtableStructType.symbols.resolve(identifier: "puts")
        XCTAssertEqual(putsSymbol.type, .pointer(.function(FunctionType(returnType: .void, arguments: [.pointer(.void), .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8)))]))))
        XCTAssertEqual(putsSymbol.offset, 0)
    }
    
    func testFailToCompileImplForTraitBecauseMethodsAreMissing() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        
        try compileSerialTrait(globalEnvironment, globalSymbols)
        try compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitTypeExpr: Expression.Identifier("Serial"),
                          structTypeExpr: Expression.Identifier("SerialFake"),
                          children: [])
        
        let compiler = SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        XCTAssertThrowsError(try compiler.compile(ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' does not implement all trait methods; missing `puts'.")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectNumberOfParameters() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        
        try compileSerialTrait(globalEnvironment, globalSymbols)
        try compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitTypeExpr: Expression.Identifier("Serial"),
                          structTypeExpr: Expression.Identifier("SerialFake"),
                          children: [
                              FunctionDeclaration(identifier: Expression.Identifier("puts"),
                                                  functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [
                                                      Expression.PointerType(Expression.Identifier("SerialFake"))
                                                  ]),
                                                  argumentNames: ["self"],
                                                  body: Block())
                          ])
        
        let compiler = SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        XCTAssertThrowsError(try compiler.compile(ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2.")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectParameterTypes() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        
        try compileSerialTrait(globalEnvironment, globalSymbols)
        try compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitTypeExpr: Expression.Identifier("Serial"),
                          structTypeExpr: Expression.Identifier("SerialFake"),
                          children: [
                              FunctionDeclaration(identifier: Expression.Identifier("puts"),
                                                  functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [
                                                      Expression.PointerType(Expression.Identifier("SerialFake")),
                                                      Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))
                                                  ]),
                                                  argumentNames: ["self", "s"],
                                                  body: Block())
                          ])
        
        let compiler = SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        XCTAssertThrowsError(try compiler.compile(ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `[]u8' argument, got `u8' instead")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectSelfParameterTypes() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        
        try compileSerialTrait(globalEnvironment, globalSymbols)
        try compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitTypeExpr: Expression.Identifier("Serial"),
                          structTypeExpr: Expression.Identifier("SerialFake"),
                          children: [
                              FunctionDeclaration(identifier: Expression.Identifier("puts"),
                                                  functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [
                                                      Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                                                      Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                                  ]),
                                                  argumentNames: ["self", "s"],
                                                  body: Block())
                          ])
        
        let compiler = SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        XCTAssertThrowsError(try compiler.compile(ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `*SerialFake' argument, got `u8' instead")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectReturnType() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        
        try compileSerialTrait(globalEnvironment, globalSymbols)
        try compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitTypeExpr: Expression.Identifier("Serial"),
                          structTypeExpr: Expression.Identifier("SerialFake"),
                          children: [
                              FunctionDeclaration(identifier: Expression.Identifier("puts"),
                                                  functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.bool(.mutableBool)), arguments: [
                                                      Expression.PointerType(Expression.Identifier("SerialFake")),
                                                      Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                                  ]),
                                                  argumentNames: ["self", "s"],
                                                  body: Block(children: [
                                                    Return(Expression.LiteralBool(false))
                                                ]))
                          ])
        
        let compiler = SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        XCTAssertThrowsError(try compiler.compile(ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `void' return value, got `bool' instead")
        }
    }
}
