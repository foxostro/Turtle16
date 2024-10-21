//
//  ImplForScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class ImplForScannerTests: XCTestCase {
    fileprivate func scanSerialTrait(_ globalEnvironment: GlobalEnvironment,
                                     _ symbols: SymbolTable) throws {
        
        let traitDecl = TraitDeclaration(
            identifier: Expression.Identifier("Serial"),
            members: [
                TraitDeclaration.Member(
                    name: "puts",
                    type:  Expression.PointerType(Expression.FunctionType(
                        name: nil,
                        returnType: Expression.PrimitiveType(.void),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("Serial")),
                            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                        ])))
            ],
            visibility: .privateVisibility)
        
        let scanner = TraitScanner(globalEnvironment: globalEnvironment,
                                   symbols: symbols)
        try scanner.scan(trait: traitDecl)
    }
    
    fileprivate func scanSerialFake(_ globalEnvironment: GlobalEnvironment,
                                    _ symbols: SymbolTable) throws {
        
        let fake = StructDeclaration(
            identifier: Expression.Identifier("SerialFake"),
            members: [])
        try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(fake)
    }
    
    func testScanImplForTrait() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        
        try scanSerialTrait(globalEnvironment, symbols)
        try scanSerialFake(globalEnvironment, symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("puts"),
                    functionType: Expression.FunctionType(
                        name: "puts",
                        returnType: Expression.PrimitiveType(.void),
                        arguments: [
                            Expression.PointerType(
                                Expression.Identifier("Serial")),
                            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block())
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(globalEnvironment: globalEnvironment,
                                     symbols: symbols)
        try scanner.scan(implFor: ast)
        
        // Let's examine, for correctness, the vtable symbol
        let nameOfVtableInstance = "__Serial_SerialFake_vtable_instance"
        let vtableInstance = try symbols.resolve(identifier: nameOfVtableInstance)
        let vtableStructType = vtableInstance.type.unwrapStructType()
        XCTAssertEqual(vtableStructType.name, "__Serial_vtable")
        XCTAssertEqual(vtableStructType.symbols.exists(identifier: "puts"), true)
        let putsSymbol = try vtableStructType.symbols.resolve(identifier: "puts")
        XCTAssertEqual(putsSymbol.type, .pointer(.function(FunctionType(returnType: .void, arguments: [.pointer(.void), .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8)))]))))
        XCTAssertEqual(putsSymbol.offset, 0)
    }
    
    func testFailToScanImplForTraitBecauseMethodsAreMissing() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        
        try scanSerialTrait(globalEnvironment, symbols)
        try scanSerialFake(globalEnvironment, symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [])
        
        let scanner = ImplForScanner(globalEnvironment: globalEnvironment,
                                     symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' does not implement all trait methods; missing `puts'.")
        }
    }
    
    func testFailToScanImplForTraitBecauseMethodHasIncorrectNumberOfParameters() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        
        try scanSerialTrait(globalEnvironment, symbols)
        try scanSerialFake(globalEnvironment, symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("puts"),
                    functionType: Expression.FunctionType(
                        name: "puts",
                        returnType: Expression.PrimitiveType(.void),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("SerialFake"))
                        ]),
                    argumentNames: ["self"],
                    body: Block())
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(globalEnvironment: globalEnvironment,
                                     symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2.")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectParameterTypes() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        
        try scanSerialTrait(globalEnvironment, symbols)
        try scanSerialFake(globalEnvironment, symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("puts"),
                    functionType: Expression.FunctionType(
                        name: "puts",
                        returnType: Expression.PrimitiveType(.void),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("SerialFake")),
                                                      Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block())
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(globalEnvironment: globalEnvironment,
                                     symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `[]u8' argument, got `u8' instead")
        }
    }
    
    func testFailToScanImplForTraitBecauseMethodHasIncorrectSelfParameterTypes() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        
        try scanSerialTrait(globalEnvironment, symbols)
        try scanSerialFake(globalEnvironment, symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("puts"),
                    functionType: Expression.FunctionType(
                        name: "puts",
                        returnType: Expression.PrimitiveType(.void),
                        arguments: [
                            Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block())
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(globalEnvironment: globalEnvironment,
                                     symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `*SerialFake' argument, got `u8' instead")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectReturnType() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        
        try scanSerialTrait(globalEnvironment, symbols)
        try scanSerialFake(globalEnvironment, symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("puts"),
                    functionType: Expression.FunctionType(
                        name: "puts",
                        returnType: Expression.PrimitiveType(.bool(.mutableBool)),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("SerialFake")),
                            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block(children: [
                        Return(Expression.LiteralBool(false))
                    ]))
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(globalEnvironment: globalEnvironment,
                                     symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `void' return value, got `bool' instead")
        }
    }
}
