//
//  CompilerPassMatchTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/18/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassMatchTests: XCTestCase {
    func testCompileEmptyMatchStatement() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8))
        ])
        let input = Match(expr: Expression.Identifier("foo"), clauses: [], elseClause: nil)
        
        let compiler = CompilerPassMatch(symbols: symbols)
        XCTAssertThrowsError(try compiler.run(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "match statement is not exhaustive. Missing clause: u8")
        }
    }
    
    func testCompileMatchStatementWithOnlyElseClause() throws {
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8))
        ])
        let input = Match(expr: Expression.Identifier("result"), clauses: [], elseClause: Block(children: [
            Expression.Assignment(lexpr: Expression.Identifier("result"), rexpr: Expression.LiteralInt(42))
        ]))
        let expected = Block(children: [
            Block(children: [
                Expression.Assignment(lexpr: Expression.Identifier("result"),
                                      rexpr: Expression.LiteralInt(42))
            ])
        ])
        
        let compiler = CompilerPassMatch(symbols: symbols)
        let output = try compiler.run(input)
        XCTAssertEqual(output, expected)
    }

    func testCompileMatchStatementWithOneExtraneousClause() {
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8))
        ])
        let input = Match(expr: Expression.Identifier("result"), clauses: [
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.u8),
                         block: Block(children: [])),
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.bool),
                         block: Block(children: []))
        ], elseClause: nil)
        let compiler = CompilerPassMatch(symbols: symbols)
        XCTAssertThrowsError(try compiler.run(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "extraneous clause in match statement: bool")
        }
    }

    func testCompileMatchStatementWithTwoExtraneousClauses() {
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8))
        ], typeDict: [
            "None" : .structType(StructType(name: "None", symbols: SymbolTable()))
        ])
        let input = Match(expr: Expression.Identifier("result"), clauses: [
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.u8),
                         block: Block(children: [])),
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.bool),
                         block: Block(children: [])),
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.Identifier("None"),
                         block: Block(children: []))
        ], elseClause: nil)
            .reconnect(parent: symbols)
        let compiler = CompilerPassMatch(symbols: symbols)
        XCTAssertThrowsError(try compiler.run(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "extraneous clauses in match statement: bool, None")
        }
    }

    func testCompileMatchStatementWithOnlyOneClause() throws {
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8)),
            ("test", Symbol(type: .u8))
        ])
        let input = Match(expr: Expression.Identifier("test"), clauses: [
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.u8),
                         block: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("result"), rexpr: Expression.Identifier("foo"))
                        ]))
        ], elseClause: nil)
        let expected = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("__index"),
                           explicitType: nil,
                           expression: Expression.Identifier("test"),
                           storage: .automaticStorage,
                           isMutable: true),
            If(condition: Expression.Is(expr: Expression.Identifier("__index"),
                                        testType: Expression.PrimitiveType(.u8)), then: Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: nil,
                               expression: Expression.As(expr: Expression.Identifier("__index"), targetType: Expression.PrimitiveType(.u8)),
                               storage: .automaticStorage,
                               isMutable: false),
                Block(children: [
                    Expression.Assignment(lexpr: Expression.Identifier("result"),
                                          rexpr: Expression.Identifier("foo"))
                ])
            ])),
        ])
        let compiler = CompilerPassMatch(symbols: symbols)
        let output = try compiler.run(input)
        XCTAssertEqual(output, expected)
    }

    func testCompileMatchStatementWithUnionTypeAndNonexhaustiveClauses() {
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8)),
            ("test", Symbol(type: .unionType(UnionType([.u8, .bool]))))
        ])
        let input = Match(expr: Expression.Identifier("test"), clauses: [
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.u8),
                         block: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("result"), rexpr: Expression.LiteralInt(1))
                        ]))
        ], elseClause: nil)
        let compiler = CompilerPassMatch(symbols: symbols)
        XCTAssertThrowsError(try compiler.run(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "match statement is not exhaustive. Missing clause: bool")
        }
    }

    func testCompileMatchStatementWithUnionTypeAndExhaustiveClauses() throws {
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8)),
            ("test", Symbol(type: .unionType(UnionType([.u8, .bool]))))
        ])
        let input = Match(expr: Expression.Identifier("test"), clauses: [
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.u8),
                         block: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("result"), rexpr: Expression.LiteralInt(1))
                        ])),
            Match.Clause(valueIdentifier: Expression.Identifier("foo"),
                         valueType: Expression.PrimitiveType(.bool),
                         block: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("result"), rexpr: Expression.LiteralInt(2))
                        ]))
        ], elseClause: nil)
        let expected = Block(children: [
            VarDeclaration(identifier: Expression.Identifier("__index"),
                           explicitType: nil,
                           expression: Expression.Identifier("test"),
                           storage: .automaticStorage,
                           isMutable: true),
            If(condition: Expression.Is(expr: Expression.Identifier("__index"),
                                        testType: Expression.PrimitiveType(.bool)), then: Block(children: [
                VarDeclaration(identifier: Expression.Identifier("foo"),
                               explicitType: nil,
                               expression: Expression.As(expr: Expression.Identifier("__index"), targetType: Expression.PrimitiveType(.bool)),
                               storage: .automaticStorage,
                               isMutable: false),
                Block(children: [
                    Expression.Assignment(lexpr: Expression.Identifier("result"),
                                          rexpr: Expression.LiteralInt(2))
                ])
            ]), else: If(condition: Expression.Is(expr: Expression.Identifier("__index"),
                                                  testType: Expression.PrimitiveType(.u8)), then: Block(children: [
                          VarDeclaration(identifier: Expression.Identifier("foo"),
                                         explicitType: nil,
                                         expression: Expression.As(expr: Expression.Identifier("__index"), targetType: Expression.PrimitiveType(.u8)),
                                         storage: .automaticStorage,
                                         isMutable: false),
                          Block(children: [
                              Expression.Assignment(lexpr: Expression.Identifier("result"),
                                                    rexpr: Expression.LiteralInt(1))
                          ])
                      ]))
            )
        ])
        let compiler = CompilerPassMatch(symbols: symbols)
        let output = try compiler.run(input)
        XCTAssertEqual(output, expected)
    }
}
