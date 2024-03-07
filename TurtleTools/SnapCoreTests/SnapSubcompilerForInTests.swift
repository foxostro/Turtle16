//
//  SnapSubcompilerForInTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerForInTests: XCTestCase {
    public let kRangeType: SymbolType = .structType(StructType(name: "Range", symbols: SymbolTable(frameLookupMode: .set(Frame()), tuples: [
        ("begin", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0)),
        ("limit", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 2))
    ])))
    
    func testCompileForInLoop_Range() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0))
        ])
        symbols.bind(identifier: "Range", symbolType: kRangeType)
        let input = ForIn(identifier: Expression.Identifier("i"),
                          sequenceExpr: Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
                            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(0)),
                            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(10))
                          ]),
                          body: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                  rexpr: Expression.Identifier("i"))
                          ]))
        var result: Block? = nil
        XCTAssertNoThrow(result = try SnapSubcompilerForIn(symbols).compile(input))
        
        let sequence: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__sequence" })
        let expectedSequenceExpr = Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [
            Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(0)),
            Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(10))
        ])
        XCTAssertEqual(sequence?.expression, expectedSequenceExpr)
        
        let limit: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__limit" })
        let expectedLimitExpr = Expression.Get(expr: Expression.Identifier("__sequence"), member: Expression.Identifier("limit"))
        XCTAssertEqual(limit?.expression, expectedLimitExpr)
        
        let iter: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "i" })
        let expectedIterExpr = Expression.LiteralInt(0)
        XCTAssertEqual(iter?.expression, expectedIterExpr)
        let expectedIterType = Expression.TypeOf(Expression.Identifier("__limit"))
        XCTAssertEqual(iter?.explicitType, expectedIterType)
        
        let whileStmt = result?.children.last as? While
        let expectedWhileCondExpr = Expression.Binary(op: .ne, left: Expression.Identifier("i"), right: Expression.Identifier("__limit"))
        XCTAssertEqual(whileStmt?.condition, expectedWhileCondExpr)
    }
    
    func testCompileForInLoop_String() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u8)), offset: 0))
        ])
        let input = ForIn(identifier: Expression.Identifier("i"),
                          sequenceExpr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))), elements: [
                            Expression.LiteralInt(Int("h".utf8.first!)),
                            Expression.LiteralInt(Int("e".utf8.first!)),
                            Expression.LiteralInt(Int("l".utf8.first!)),
                            Expression.LiteralInt(Int("l".utf8.first!)),
                            Expression.LiteralInt(Int("o".utf8.first!))
                          ]),
                          body: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                  rexpr: Expression.Identifier("i"))
                        ]))
        var result: Block? = nil
        XCTAssertNoThrow(result = try SnapSubcompilerForIn(symbols).compile(input))
        
        let sequence: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__sequence" })
        let expectedSequenceExpr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))), elements: [
            Expression.LiteralInt(Int("h".utf8.first!)),
            Expression.LiteralInt(Int("e".utf8.first!)),
            Expression.LiteralInt(Int("l".utf8.first!)),
            Expression.LiteralInt(Int("l".utf8.first!)),
            Expression.LiteralInt(Int("o".utf8.first!))
          ])
        XCTAssertEqual(sequence?.expression, expectedSequenceExpr)
        
        let index: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__index" })
        XCTAssertEqual(index?.expression, Expression.LiteralInt(0))
        
        let limit: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__limit" })
        let expectedLimitExpr = Expression.Get(expr: Expression.Identifier("__sequence"), member: Expression.Identifier("count"))
        XCTAssertEqual(limit?.expression, expectedLimitExpr)
        
        let iter: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "i" })
        XCTAssertNil(iter?.expression)
        XCTAssertEqual(iter?.explicitType, Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        
        let whileStmt = result?.children.last as? While
        let expectedWhileCondExpr = Expression.Binary(op: .ne, left: Expression.Identifier("__index"), right: Expression.Identifier("__limit"))
        XCTAssertEqual(whileStmt?.condition, expectedWhileCondExpr)
    }
    
    func testCompileForInLoop_ArrayOfU16() {
        let symbols = SymbolTable(frameLookupMode: .set(Frame()), tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0))
        ])
        let input = ForIn(identifier: Expression.Identifier("i"),
                          sequenceExpr: Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))), elements: [
                            Expression.LiteralInt(0x1000),
                            Expression.LiteralInt(0x2000),
                            Expression.LiteralInt(0x3000),
                            Expression.LiteralInt(0x4000),
                            Expression.LiteralInt(0x5000)
                          ]),
                          body: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                  rexpr: Expression.Identifier("i"))
                        ]))
        var result: Block? = nil
        XCTAssertNoThrow(result = try SnapSubcompilerForIn(symbols).compile(input))
        
        let sequence: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__sequence" })
        let expectedSequenceExpr = Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))), elements: [
            Expression.LiteralInt(0x1000),
            Expression.LiteralInt(0x2000),
            Expression.LiteralInt(0x3000),
            Expression.LiteralInt(0x4000),
            Expression.LiteralInt(0x5000)
          ])
        XCTAssertEqual(sequence?.expression, expectedSequenceExpr)
        
        let limit: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__limit" })
        let expectedLimitExpr = Expression.Get(expr: Expression.Identifier("__sequence"), member: Expression.Identifier("count"))
        XCTAssertEqual(limit?.expression, expectedLimitExpr)
        
        let iter: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "i" })
        XCTAssertNil(iter?.expression)
        let expectedIterType = Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))
        XCTAssertEqual(iter?.explicitType, expectedIterType)
        
        let whileStmt = result?.children.last as? While
        let expectedWhileCondExpr = Expression.Binary(op: .ne, left: Expression.Identifier("__index"), right: Expression.Identifier("__limit"))
        XCTAssertEqual(whileStmt?.condition, expectedWhileCondExpr)
    }
    
    func testCompileForInLoop_DynamicArray() {
        let symbols = SymbolTable(tuples: [
            ("foo", Symbol(type: .arithmeticType(.mutableInt(.u16)), offset: 0)),
            ("arr", Symbol(type: .array(count: 5, elementType: .arithmeticType(.mutableInt(.u16))), offset: 2)),
            ("slice", Symbol(type: .dynamicArray(elementType: .arithmeticType(.mutableInt(.u16))), offset: 12))
        ])
        let input = ForIn(identifier: Expression.Identifier("i"),
                          sequenceExpr: Expression.Identifier("slice"),
                          body: Block(children: [
                            Expression.Assignment(lexpr: Expression.Identifier("foo"),
                                                  rexpr: Expression.Identifier("i"))
                        ]))
        var result: Block? = nil
        XCTAssertNoThrow(result = try SnapSubcompilerForIn(symbols).compile(input))
        
        let sequence: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__sequence" })
        let expectedSequenceExpr = Expression.Identifier("slice")
        XCTAssertEqual(sequence?.expression, expectedSequenceExpr)
        
        let limit: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "__limit" })
        let expectedLimitExpr = Expression.Get(expr: Expression.Identifier("__sequence"), member: Expression.Identifier("count"))
        XCTAssertEqual(limit?.expression, expectedLimitExpr)
        
        let iter: VarDeclaration? = result?.children.compactMap({$0 as? VarDeclaration}).first(where: { $0.identifier.identifier == "i" })
        XCTAssertNil(iter?.expression)
        let expectedIterType = Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16)))
        XCTAssertEqual(iter?.explicitType, expectedIterType)
        
        let whileStmt = result?.children.last as? While
        let expectedWhileCondExpr = Expression.Binary(op: .ne, left: Expression.Identifier("__index"), right: Expression.Identifier("__limit"))
        XCTAssertEqual(whileStmt?.condition, expectedWhileCondExpr)
    }
}
