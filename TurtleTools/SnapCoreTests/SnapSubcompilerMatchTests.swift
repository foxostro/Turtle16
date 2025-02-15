//
//  SnapSubcompilerMatchTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/8/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class SnapSubcompilerMatchTests: XCTestCase {
    func testCompileEmptyMatchStatement() {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8))
        ])
        let input = Match(expr: Identifier("foo"), clauses: [], elseClause: nil)
        let compiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "match statement is not exhaustive. Missing clause: u8")
        }
    }
    
    func testCompileMatchStatementWithOnlyElseClause() {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8))
        ])
        let input = Match(expr: Identifier("result"), clauses: [], elseClause: Block(children: [
            Assignment(lexpr: Identifier("result"), rexpr: LiteralInt(42))
        ]))
        let compiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        var output: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(output = try compiler.compile(input))
        XCTAssertEqual(output, Block(children: [
            Block(children: [
                Assignment(lexpr: Identifier("result"),
                                      rexpr: LiteralInt(42))
            ])
        ]))
    }

    func testCompileMatchStatementWithOneExtraneousClause() {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8))
        ])
        let input = Match(expr: Identifier("result"), clauses: [
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.u8),
                         block: Block(children: [])),
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.bool),
                         block: Block(children: []))
        ], elseClause: nil)
        let compiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "extraneous clause in match statement: bool")
        }
    }

    func testCompileMatchStatementWithTwoExtraneousClauses() {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8))
        ], typeDict: [
            "None" : .structType(StructTypeInfo(name: "None", symbols: SymbolTable()))
        ])
        let input = Match(expr: Identifier("result"), clauses: [
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.u8),
                         block: Block(children: [])),
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.bool),
                         block: Block(children: [])),
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: Identifier("None"),
                         block: Block(children: []))
        ], elseClause: nil)
        let compiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "extraneous clauses in match statement: bool, None")
        }
    }

    func testCompileMatchStatementWithOnlyOneClause() {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8)),
            ("test", Symbol(type: .u8))
        ])
        let input = Match(expr: Identifier("test"), clauses: [
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.u8),
                         block: Block(children: [
                            Assignment(lexpr: Identifier("result"), rexpr: Identifier("foo"))
                        ]))
        ], elseClause: nil)
        let compiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        var output: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(output = try compiler.compile(input))
        XCTAssertEqual(output, Block(children: [
            VarDeclaration(identifier: Identifier("__index"),
                           explicitType: nil,
                           expression: Identifier("test"),
                           storage: .automaticStorage,
                           isMutable: true),
            If(condition: Is(expr: Identifier("__index"),
                                        testType: PrimitiveType(.u8)), then: Block(children: [
                VarDeclaration(identifier: Identifier("foo"),
                               explicitType: nil,
                               expression: As(expr: Identifier("__index"), targetType: PrimitiveType(.u8)),
                               storage: .automaticStorage,
                               isMutable: false),
                Block(children: [
                    Assignment(lexpr: Identifier("result"),
                                          rexpr: Identifier("foo"))
                ])
            ])),
        ]))
    }

    func testCompileMatchStatementWithUnionTypeAndNonexhaustiveClauses() {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8)),
            ("test", Symbol(type: .unionType(UnionTypeInfo([.u8, .bool]))))
        ])
        let input = Match(expr: Identifier("test"), clauses: [
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.u8),
                         block: Block(children: [
                            Assignment(lexpr: Identifier("result"), rexpr: LiteralInt(1))
                        ]))
        ], elseClause: nil)
        let compiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "match statement is not exhaustive. Missing clause: bool")
        }
    }

    func testCompileMatchStatementWithUnionTypeAndExhaustiveClauses() {
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let symbols = SymbolTable(tuples: [
            ("result", Symbol(type: .u8)),
            ("test", Symbol(type: .unionType(UnionTypeInfo([.u8, .bool]))))
        ])
        let input = Match(expr: Identifier("test"), clauses: [
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.u8),
                         block: Block(children: [
                            Assignment(lexpr: Identifier("result"), rexpr: LiteralInt(1))
                        ])),
            Match.Clause(valueIdentifier: Identifier("foo"),
                         valueType: PrimitiveType(.bool),
                         block: Block(children: [
                            Assignment(lexpr: Identifier("result"), rexpr: LiteralInt(2))
                        ]))
        ], elseClause: nil)
        let compiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        var output: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(output = try compiler.compile(input))
        XCTAssertEqual(output, Block(children: [
            VarDeclaration(identifier: Identifier("__index"),
                           explicitType: nil,
                           expression: Identifier("test"),
                           storage: .automaticStorage,
                           isMutable: true),
            If(condition: Is(expr: Identifier("__index"),
                                        testType: PrimitiveType(.bool)), then: Block(children: [
                VarDeclaration(identifier: Identifier("foo"),
                               explicitType: nil,
                               expression: As(expr: Identifier("__index"), targetType: PrimitiveType(.bool)),
                               storage: .automaticStorage,
                               isMutable: false),
                Block(children: [
                    Assignment(lexpr: Identifier("result"),
                                          rexpr: LiteralInt(2))
                ])
            ]), else: If(condition: Is(expr: Identifier("__index"),
                                                  testType: PrimitiveType(.u8)), then: Block(children: [
                          VarDeclaration(identifier: Identifier("foo"),
                                         explicitType: nil,
                                         expression: As(expr: Identifier("__index"), targetType: PrimitiveType(.u8)),
                                         storage: .automaticStorage,
                                         isMutable: false),
                          Block(children: [
                              Assignment(lexpr: Identifier("result"),
                                                    rexpr: LiteralInt(1))
                          ])
                      ]))
            )
        ]))
    }
}
