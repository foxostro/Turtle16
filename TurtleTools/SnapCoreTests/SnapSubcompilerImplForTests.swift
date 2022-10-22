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
    fileprivate func compileSerialTrait(_ globalEnvironment: GlobalEnvironment,  _ globalSymbols: SymbolTable) {
        let bar = TraitDeclaration.Member(name: "puts", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
            Expression.PointerType(Expression.Identifier("Serial")),
            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])))
        let traitDecl = TraitDeclaration(identifier: Expression.Identifier("Serial"),
                                         members: [bar],
                                         visibility: .privateVisibility)
        _ = compileTrait(globalEnvironment, globalSymbols, traitDecl)
    }
    
    fileprivate func compileTrait(_ globalEnvironment: GlobalEnvironment,  _ globalSymbols: SymbolTable, _ traitDecl: TraitDeclaration) -> Block {
        let t0 = try! SnapSubcompilerTraitDeclaration(memoryLayoutStrategy: globalEnvironment.memoryLayoutStrategy, symbols: globalSymbols)
            .compile(traitDecl)
        try! SnapSubcompilerStructDeclaration(symbols: globalSymbols, globalEnvironment: globalEnvironment)
            .compile(t0.children[0] as! StructDeclaration)
        try! SnapSubcompilerStructDeclaration(symbols: globalSymbols, globalEnvironment: globalEnvironment)
            .compile(t0.children[1] as! StructDeclaration)
        let t1 = try! SnapSubcompilerImpl(memoryLayoutStrategy: globalEnvironment.memoryLayoutStrategy, symbols: globalSymbols)
            .compile(t0.children[2] as! Impl)
        return t1
    }
    
    fileprivate func compileSerialFake(_ globalEnvironment: GlobalEnvironment,  _ globalSymbols: SymbolTable) {
        let fake = StructDeclaration(identifier: Expression.Identifier("SerialFake"), members: [])
        try! SnapSubcompilerStructDeclaration(symbols: globalSymbols, globalEnvironment: globalEnvironment)
            .compile(fake)
    }
    
    func testCompileImplForTrait() {
        let globalSymbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        
        compileSerialTrait(globalEnvironment, globalSymbols)
        compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitIdentifier: Expression.Identifier("Serial"),
                          structIdentifier: Expression.Identifier("SerialFake"),
                          children: [
                              FunctionDeclaration(identifier: Expression.Identifier("puts"),
                                                  functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [
                                                      Expression.PointerType(Expression.Identifier("Serial")),
                                                      Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                                  ]),
                                                  argumentNames: ["self", "s"],
                                                  body: Block())
                          ])
        
        let compiler = SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        
        var seq: Seq? = nil
        XCTAssertNoThrow(seq = try compiler.compile(ast))
        
        // Compile the vtable instance so we can compare it's type against our
        // expectations. We could also examine the type expression in the
        // uncompiled VarDeclaration node, but this ensures we evaluate that
        // expression in the same way it would be in the full compiler.
        guard let vtableDeclaration = seq?.children.last as? VarDeclaration else {
            XCTFail()
            return
        }
        
        _ = try? SnapSubcompilerVarDeclaration(symbols: globalSymbols, globalEnvironment: globalEnvironment).compile(vtableDeclaration)
        
        let nameOfVtableInstance = "__Serial_SerialFake_vtable_instance"
        let vtableInstance = try? globalSymbols.resolve(identifier: nameOfVtableInstance)
        let vtableStructType = vtableInstance?.type.unwrapStructType()
        XCTAssertEqual(vtableStructType?.name, "__Serial_vtable")
        XCTAssertEqual(vtableStructType?.symbols.exists(identifier: "puts"), true)
        let putsSymbol = try? vtableStructType?.symbols.resolve(identifier: "puts")
        XCTAssertEqual(putsSymbol?.type, .pointer(.function(FunctionType(returnType: .void, arguments: [.pointer(.void), .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8)))]))))
        XCTAssertEqual(putsSymbol?.offset, 0)
    }
    
    func testFailToCompileImplForTraitBecauseMethodsAreMissing() {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = SymbolTable()
        
        compileSerialTrait(globalEnvironment, globalSymbols)
        compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitIdentifier: Expression.Identifier("Serial"),
                          structIdentifier: Expression.Identifier("SerialFake"),
                          children: [])
        
        let compiler = SnapSubcompilerImplFor(symbols: globalSymbols, globalEnvironment: globalEnvironment)
        XCTAssertThrowsError(try compiler.compile(ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' does not implement all trait methods; missing `puts'.")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectNumberOfParameters() {
        let globalSymbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        
        compileSerialTrait(globalEnvironment, globalSymbols)
        compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitIdentifier: Expression.Identifier("Serial"),
                          structIdentifier: Expression.Identifier("SerialFake"),
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
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectParameterTypes() {
        let globalSymbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        
        compileSerialTrait(globalEnvironment, globalSymbols)
        compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitIdentifier: Expression.Identifier("Serial"),
                          structIdentifier: Expression.Identifier("SerialFake"),
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
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectSelfParameterTypes() {
        let globalSymbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        
        compileSerialTrait(globalEnvironment, globalSymbols)
        compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitIdentifier: Expression.Identifier("Serial"),
                          structIdentifier: Expression.Identifier("SerialFake"),
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
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectReturnType() {
        let globalSymbols = SymbolTable()
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        
        compileSerialTrait(globalEnvironment, globalSymbols)
        compileSerialFake(globalEnvironment, globalSymbols)
        
        let ast = ImplFor(typeArguments: [],
                          traitIdentifier: Expression.Identifier("Serial"),
                          structIdentifier: Expression.Identifier("SerialFake"),
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
