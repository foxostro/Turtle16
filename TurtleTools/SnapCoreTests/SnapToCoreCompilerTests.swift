//
//  SnapToCoreCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class SnapToCoreCompilerTests: XCTestCase {
    fileprivate typealias Bitcast = Expression.Bitcast
    fileprivate typealias ConstType = Expression.ConstType
    fileprivate typealias Identifier = Expression.Identifier
    fileprivate typealias InitialAssignment = Expression.InitialAssignment
    fileprivate typealias PointerType = Expression.PointerType
    fileprivate typealias PrimitiveType = Expression.PrimitiveType
    fileprivate typealias StructInitializer = Expression.StructInitializer
    fileprivate typealias Unary = Expression.Unary
    
    func testExample() throws {
        let input = TopLevel(
            children: [
                CommentNode(string: "")
            ])
        let expected = Block(
            symbols: SymbolTable(),
            children: [
                CommentNode(string: "")
            ])
        
        let actual = try SnapToCoreCompiler()
            .compile(input)
            .get()
        XCTAssertEqual(expected, actual)
    }
    
    func testExpectTopLevelNodeAtRoot() throws {
        let input = CommentNode(string: "")
        XCTAssertThrowsError(try SnapToCoreCompiler()
            .compile(input)
            .get())
    }
    
    func testRvalue_convert_pointer_to_trait() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()

        let ast0 = Block(symbols: symbols, children: [
            TraitDeclaration(
                identifier: Identifier("Serial"),
                members: [],
                visibility: .privateVisibility),
            StructDeclaration(
                identifier: Identifier("SerialFake"),
                members: []),
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Identifier("Serial"),
                structTypeExpr: Identifier("SerialFake"),
                children: []),
            VarDeclaration(
                identifier: Identifier("serialFake"),
                explicitType: Identifier("SerialFake"),
                expression: nil,
                storage: .staticStorage,
                isMutable: true),
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("Serial"),
                expression: Unary(
                    op: .ampersand,
                    expression: Identifier("serialFake")),
                storage: .staticStorage,
                isMutable: false)
        ])
        
        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("__Serial_vtable"),
                members: []),
            StructDeclaration(
                identifier: Identifier("__Serial_object"),
                members: [
                    StructDeclaration.Member(
                        name: "object",
                        type: PointerType(PrimitiveType(.void))),
                    StructDeclaration.Member(
                        name: "vtable",
                        type: PointerType(ConstType(Identifier("__Serial_vtable"))))
                ],
                associatedTraitType: "Serial"),
            VarDeclaration(
                identifier: Identifier("__Serial_SerialFake_vtable_instance"),
                explicitType: Identifier("__Serial_vtable"),
                expression: nil,
                storage: .staticStorage,
                isMutable: false),
            InitialAssignment(
                lexpr: Identifier("__Serial_SerialFake_vtable_instance"),
                rexpr: StructInitializer(
                    expr: Identifier("__Serial_vtable"),
                    arguments: [])),
            StructDeclaration(
                identifier: Identifier("SerialFake"),
                members: []),
            VarDeclaration(
                identifier: Identifier("serialFake"),
                explicitType: Identifier("SerialFake"),
                expression: nil,
                storage: .staticStorage,
                isMutable: true),
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("__Serial_object"),
                expression: nil,
                storage: .staticStorage,
                isMutable: false),
            InitialAssignment(
                lexpr: Identifier("serial"),
                rexpr: StructInitializer(
                    identifier: Identifier("__Serial_object"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "object",
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Identifier("serialFake")),
                                targetType: PointerType(PrimitiveType(.void)))),
                        StructInitializer.Argument(
                            name: "vtable",
                            expr: Identifier("__Serial_SerialFake_vtable_instance"))
                    ]))
        ])
            .reconnect(parent: nil)
        
        let actual = try SnapToCoreCompiler(globalEnvironment: globalEnvironment)
            .compile(ast0)
            .get()
        
        XCTAssertEqual(actual, expected)
    }
}
