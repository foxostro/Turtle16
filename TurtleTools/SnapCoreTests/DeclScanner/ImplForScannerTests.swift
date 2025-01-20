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
    fileprivate func scanSerialTrait(_ symbols: SymbolTable) throws {
        
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
                            Expression.DynamicArrayType(Expression.PrimitiveType(.u8))
                        ])))
            ],
            visibility: .privateVisibility)
        
        let scanner = TraitScanner(
            staticStorageFrame: Frame(),
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
            symbols: symbols)
        try scanner.scan(trait: traitDecl)
    }
    
    fileprivate func scanSerialFake(_ symbols: SymbolTable) throws {
        
        let fake = StructDeclaration(
            identifier: Expression.Identifier("SerialFake"),
            members: [])
        try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        .compile(fake)
    }
    
    func testScanImplForTrait() throws {
        let symbols = SymbolTable()
        
        try scanSerialTrait(symbols)
        try scanSerialFake(symbols)
        
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
                            Expression.DynamicArrayType(Expression.PrimitiveType(.u8))
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block())
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(
            staticStorageFrame: Frame(),
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
            symbols: symbols)
        try scanner.scan(implFor: ast)
        
        // Let's examine, for correctness, the vtable symbol
        let nameOfVtableInstance = "__Serial_SerialFake_vtable_instance"
        let vtableInstance = try symbols.resolve(identifier: nameOfVtableInstance)
        let vtableStructType = vtableInstance.type.unwrapStructType()
        XCTAssertEqual(vtableStructType.name, "__Serial_vtable")
        XCTAssertEqual(vtableStructType.symbols.exists(identifier: "puts"), true)
        let putsSymbol = try vtableStructType.symbols.resolve(identifier: "puts")
        XCTAssertEqual(putsSymbol.type, .pointer(.function(FunctionType(returnType: .void, arguments: [.pointer(.void), .dynamicArray(elementType: .u8)]))))
        XCTAssertEqual(putsSymbol.offset, 0)
    }
    
    func testFailToScanImplForTraitBecauseMethodsAreMissing() throws {
        let symbols = SymbolTable()
        
        try scanSerialTrait(symbols)
        try scanSerialFake(symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [])
        
        let scanner = ImplForScanner(
            staticStorageFrame: Frame(),
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
            symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' does not implement all trait methods; missing `puts'.")
        }
    }
    
    func testFailToScanImplForTraitBecauseMethodHasIncorrectNumberOfParameters() throws {
        let symbols = SymbolTable()
        
        try scanSerialTrait(symbols)
        try scanSerialFake(symbols)
        
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
        
        let scanner = ImplForScanner(
            staticStorageFrame: Frame(),
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
            symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2.")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectParameterTypes() throws {
        let symbols = SymbolTable()
        
        try scanSerialTrait(symbols)
        try scanSerialFake(symbols)
        
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
                                                      Expression.PrimitiveType(.u8)
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block())
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(
            staticStorageFrame: Frame(),
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
            symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `[]u8' argument, got `u8' instead")
        }
    }
    
    func testFailToScanImplForTraitBecauseMethodHasIncorrectSelfParameterTypes() throws {
        let symbols = SymbolTable()
        
        try scanSerialTrait(symbols)
        try scanSerialFake(symbols)
        
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
                            Expression.PrimitiveType(.u8),
                            Expression.DynamicArrayType(Expression.PrimitiveType(.u8))
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block())
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(
            staticStorageFrame: Frame(),
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
            symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `*SerialFake' argument, got `u8' instead")
        }
    }
    
    func testFailToCompileImplForTraitBecauseMethodHasIncorrectReturnType() throws {
        let symbols = SymbolTable()
        
        try scanSerialTrait(symbols)
        try scanSerialFake(symbols)
        
        let ast = ImplFor(
            typeArguments: [],
            traitTypeExpr: Expression.Identifier("Serial"),
            structTypeExpr: Expression.Identifier("SerialFake"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("puts"),
                    functionType: Expression.FunctionType(
                        name: "puts",
                        returnType: Expression.PrimitiveType(.bool),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("SerialFake")),
                            Expression.DynamicArrayType(Expression.PrimitiveType(.u8))
                        ]),
                    argumentNames: ["self", "s"],
                    body: Block(children: [
                        Return(Expression.LiteralBool(false))
                    ]))
            ])
            .reconnect(parent: nil)
        
        let scanner = ImplForScanner(
            staticStorageFrame: Frame(),
            memoryLayoutStrategy: MemoryLayoutStrategyTurtle16(),
            symbols: symbols)
        
        XCTAssertThrowsError(try scanner.scan(implFor: ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `void' return value, got `bool' instead")
        }
    }
}
