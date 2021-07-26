//
//  MemoryLayoutStrategyTurtleTTLTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/25/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class MemoryLayoutStrategyTurtleTTLTests: XCTestCase {
    func makeStrategy() -> MemoryLayoutStrategy {
        return MemoryLayoutStrategyTurtleTTL()
    }
    
    func testSizeOfVoid() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .void), 0)
    }
    
    func testSizeOfU8() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .u8), 1)
    }
    
    func testSizeOfU16() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .u16), 2)
    }
    
    func testSizeOfPointer() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .pointer(.void)), 2)
    }
    
    func testSizeOfDynamicArray() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .dynamicArray(elementType: .void)), 4)
    }
    
    func testSizeOfArray() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .array(count: 10, elementType: .u8)), 10)
    }
    
    func testSizeOfArrayWithIndeterminateSize() throws {
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: .array(count: nil, elementType: .u8)), 0)
    }
    
    func testSizeOfUnion() throws {
        let typ: SymbolType = .unionType(UnionType([.u16]))
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: typ), 3)
    }
    
    func testSizeOfStruct() throws {
        let typ: SymbolType = .structType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16, offset: 0)),
            ("count", Symbol(type: .u16, offset: 2))
        ])))
        let strategy = makeStrategy()
        XCTAssertEqual(strategy.sizeof(type: typ), 4)
    }
    
    func testLayoutEmptySymbolTable() {
        let strategy = makeStrategy()
        let input = SymbolTable()
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable()
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutOneU8Symbol() {
        let strategy = makeStrategy()
        let input = SymbolTable(["foo": Symbol(type: .u8)])
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable(["foo": Symbol(type: .u8, offset: 0)])
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutTwoSymbols() {
        let strategy = makeStrategy()
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16)),
            ("bar", Symbol(type: .u8))
        ])
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: 0)),
            ("bar", Symbol(type: .u8, offset: 2))
        ])
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutUnion() {
        let strategy = makeStrategy()
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.u8, .u16])))),
            ("bar", Symbol(type: .u8))
        ])
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.u8, .u16])), offset: 0)),
            ("bar", Symbol(type: .u8, offset: 3))
        ])
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutStruct() {
        let strategy = makeStrategy()
        let expectedStructType: SymbolType = .structType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16, offset: 0)),
            ("count", Symbol(type: .u16, offset: 2))
        ])))
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: expectedStructType, offset: 0))
        ])
        let inputStructType: SymbolType = .structType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16)),
            ("count", Symbol(type: .u16))
        ])))
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: inputStructType))
        ])
        let actual = strategy.layout(symbolTable: input)
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutConstStruct() {
        let strategy = makeStrategy()
        let expectedStructType: SymbolType = .constStructType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16, offset: 0)),
            ("count", Symbol(type: .u16, offset: 2))
        ])))
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: expectedStructType, offset: 0))
        ])
        let inputStructType: SymbolType = .constStructType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16)),
            ("count", Symbol(type: .u16))
        ])))
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: inputStructType))
        ])
        let actual = strategy.layout(symbolTable: input)
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutWithParentInSameStackFrame() {
        let parent = SymbolTable(parent: nil, dict: [:], typeDict: [:])
        parent.bind(identifier: "foo", symbol: Symbol(type: .u8))
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16))
        
        let child = SymbolTable(parent: parent, dict: [:], typeDict: [:])
        child.bind(identifier: "baz", symbol: Symbol(type: .u8))
        
        let strategy = makeStrategy()
        let actual = strategy.layout(symbolTable: child)
        
        let expectedParent = SymbolTable(parent: nil, dict: [:], typeDict: [:])
        expectedParent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0))
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: 1))
        
        let expectedChild = SymbolTable(parent: expectedParent, dict: [:], typeDict: [:])
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: 3))
        
        XCTAssertEqual(expectedChild, actual)
    }
    
    func testLayoutWithParentInDifferentStackFrame() {
        let parent = SymbolTable(parent: nil, dict: [:], typeDict: [:])
        parent.bind(identifier: "foo", symbol: Symbol(type: .u8))
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16))
        
        let child = SymbolTable(parent: parent, dict: [:], typeDict: [:])
        child.stackFrameIndex = 1
        child.bind(identifier: "baz", symbol: Symbol(type: .u8))
        
        let strategy = makeStrategy()
        let actual = strategy.layout(symbolTable: child)
        
        let expectedParent = SymbolTable(parent: nil, dict: [:], typeDict: [:])
        expectedParent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0))
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: 1))
        
        let expectedChild = SymbolTable(parent: expectedParent, dict: [:], typeDict: [:])
        expectedChild.stackFrameIndex = 1
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: 0))
        
        XCTAssertEqual(expectedChild, actual)
    }
    
    func testLayoutWithParentInDifferentStackFrame2() {
        let grandparent = SymbolTable(parent: nil, dict: [:], typeDict: [:])
        grandparent.bind(identifier: "foo", symbol: Symbol(type: .u8))
        
        let parent = SymbolTable(parent: grandparent, dict: [:], typeDict: [:])
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16))
        parent.stackFrameIndex = 1
        
        let child = SymbolTable(parent: parent, dict: [:], typeDict: [:])
        child.bind(identifier: "baz", symbol: Symbol(type: .u8))
        child.stackFrameIndex = 1
        
        let strategy = makeStrategy()
        let actual = strategy.layout(symbolTable: child)
        
        let expectedGrandparent = SymbolTable(parent: nil, dict: [:], typeDict: [:])
        expectedGrandparent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0))
        
        let expectedParent = SymbolTable(parent: expectedGrandparent, dict: [:], typeDict: [:])
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: 0))
        expectedParent.stackFrameIndex = 1
        
        let expectedChild = SymbolTable(parent: expectedParent, dict: [:], typeDict: [:])
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: 2))
        expectedChild.stackFrameIndex = 1
        
        XCTAssertEqual(expectedChild, actual)
    }
}
