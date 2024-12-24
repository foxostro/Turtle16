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
            Seq(tags: [.vtable],
                children: [
                    Expression.InitialAssignment(
                        lexpr: Expression.Identifier("__Serial_SerialFake_vtable_instance"),
                        rexpr: Expression.StructInitializer(
                            expr: Expression.Identifier("__Serial_vtable"),
                            arguments: []))
                ]),
            Expression.InitialAssignment(
                lexpr: Expression.Identifier("serial"),
                rexpr: Expression.Unary(
                    op: .ampersand,
                    expression: Expression.Identifier("serialFake")))
        ])
            .reconnect(parent: nil)
        
        let actual = try SnapToCoreCompiler(globalEnvironment: globalEnvironment)
            .compile(ast0)
            .get()
        
        XCTAssertEqual(actual, expected)
    }
}
