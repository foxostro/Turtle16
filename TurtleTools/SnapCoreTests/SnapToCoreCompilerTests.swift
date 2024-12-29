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

class SnapToCoreCompilerTests: XCTestCase {
    func testExample() throws {
        let input = TopLevel(children: [CommentNode(string: "")])
        let expected = Block(symbols: SymbolTable(),
                             children: [CommentNode(string: "")])
        
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
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtle16())
        let symbols = SymbolTable()

        let ast0 = Block(symbols: symbols, children: [
            TraitDeclaration(identifier: Expression.Identifier("Serial"),
                             members: [],
                             visibility: .privateVisibility),
            StructDeclaration(identifier: Expression.Identifier("SerialFake"),
                              members: []),
            ImplFor(typeArguments: [],
                    traitTypeExpr: Expression.Identifier("Serial"),
                    structTypeExpr: Expression.Identifier("SerialFake"),
                    children: []),
            VarDeclaration(identifier: Expression.Identifier("serialFake"),
                           explicitType: Expression.Identifier("SerialFake"),
                           expression: nil,
                           storage: .staticStorage,
                           isMutable: true),
            VarDeclaration(identifier: Expression.Identifier("serial"),
                           explicitType: Expression.Identifier("Serial"),
                           expression: Expression.Unary(op: .ampersand, expression: Expression.Identifier("serialFake")),
                           storage: .staticStorage,
                           isMutable: false)
        ])
        
        let expected = Block(children: [
            Expression.InitialAssignment(
                lexpr: Expression.Identifier("__Serial_SerialFake_vtable_instance"),
                rexpr: Expression.StructInitializer(
                    expr: Expression.Identifier("__Serial_vtable"),
                    arguments: [])),
            Expression.InitialAssignment(
                lexpr: Expression.Identifier("serial"),
                rexpr: Expression.StructInitializer(
                    identifier: Expression.Identifier("__Serial_object"),
                    arguments: [
                        Expression.StructInitializer.Argument(
                            name: "object",
                            expr: Expression.Bitcast(
                                expr: Expression.Unary(
                                    op: .ampersand,
                                    expression: Expression.Identifier("serialFake")),
                                targetType: Expression.PointerType(Expression.PrimitiveType(.void)))),
                        Expression.StructInitializer.Argument(
                            name: "vtable",
                            expr: Expression.Identifier("__Serial_SerialFake_vtable_instance"))
                    ]))
        ])
            .reconnect(parent: nil)
        
        let actual = try SnapToCoreCompiler(globalEnvironment: globalEnvironment)
            .compile(ast0)
            .get()
        
        XCTAssertEqual(actual, expected)
    }
}
