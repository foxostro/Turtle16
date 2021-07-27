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
            ("base", Symbol(type: .u16, offset: 0, storage: .automaticStorage)),
            ("count", Symbol(type: .u16, offset: 2, storage: .automaticStorage))
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
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, storage: .automaticStorage))
        ])
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, offset: 0, storage: .automaticStorage))
        ])
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutSkipsSymbolsThatAlreadyHaveOffsets() {
        let strategy = makeStrategy()
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, offset: 100))
        ])
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: .u8, offset: 100))
        ])
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutTwoSymbols() {
        let strategy = makeStrategy()
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, storage: .automaticStorage)),
            ("bar", Symbol(type: .u8, storage: .automaticStorage))
        ])
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: .u16, offset: 0, storage: .automaticStorage)),
            ("bar", Symbol(type: .u8, offset: 2, storage: .automaticStorage))
        ])
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutUnion() {
        let strategy = makeStrategy()
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.u8, .u16])), storage: .automaticStorage)),
            ("bar", Symbol(type: .u8, storage: .automaticStorage))
        ])
        let actual = strategy.layout(symbolTable: input)
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: .unionType(UnionType([.u8, .u16])), offset: 0, storage: .automaticStorage)),
            ("bar", Symbol(type: .u8, offset: 3, storage: .automaticStorage))
        ])
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutStruct() {
        let strategy = makeStrategy()
        let expectedStructType: SymbolType = .structType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16, offset: 0, storage: .automaticStorage)),
            ("count", Symbol(type: .u16, offset: 2, storage: .automaticStorage))
        ])))
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: expectedStructType, offset: 0, storage: .automaticStorage))
        ])
        let inputStructType: SymbolType = .structType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16, storage: .automaticStorage)),
            ("count", Symbol(type: .u16, storage: .automaticStorage))
        ])))
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: inputStructType, storage: .automaticStorage))
        ])
        let actual = strategy.layout(symbolTable: input)
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutConstStruct() {
        let strategy = makeStrategy()
        let expectedStructType: SymbolType = .constStructType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16, offset: 0, storage: .automaticStorage)),
            ("count", Symbol(type: .u16, offset: 2, storage: .automaticStorage))
        ])))
        let expected = SymbolTable(tuples: [
            ("foo", Symbol(type: expectedStructType, offset: 0, storage: .automaticStorage))
        ])
        let inputStructType: SymbolType = .constStructType(StructType(name: "Slice", symbols: SymbolTable(tuples: [
            ("base", Symbol(type: .u16, storage: .automaticStorage)),
            ("count", Symbol(type: .u16, storage: .automaticStorage))
        ])))
        let input = SymbolTable(tuples: [
            ("foo", Symbol(type: inputStructType, storage: .automaticStorage))
        ])
        let actual = strategy.layout(symbolTable: input)
        XCTAssertEqual(expected, actual)
    }
    
    func testLayoutWithParentInSameStackFrame() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .u8, storage: .automaticStorage))
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16, storage: .automaticStorage))
        
        let child = SymbolTable(parent: parent)
        child.bind(identifier: "baz", symbol: Symbol(type: .u8, storage: .automaticStorage))
        
        let strategy = makeStrategy()
        let actual = strategy.layout(symbolTable: child)
        
        let expectedParent = SymbolTable()
        expectedParent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0, storage: .automaticStorage))
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: 1, storage: .automaticStorage))
        
        let expectedChild = SymbolTable(parent: expectedParent)
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: 3, storage: .automaticStorage))
        
        XCTAssertEqual(expectedChild, actual)
    }
    
    func testLayoutWithParentInDifferentStackFrame() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .u8, storage: .automaticStorage))
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16, storage: .automaticStorage))
        
        let child = SymbolTable(parent: parent)
        child.stackFrameIndex = 1
        child.bind(identifier: "baz", symbol: Symbol(type: .u8, storage: .automaticStorage))
        
        let strategy = makeStrategy()
        let actual = strategy.layout(symbolTable: child)
        
        let expectedParent = SymbolTable()
        expectedParent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0, storage: .automaticStorage))
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: 1, storage: .automaticStorage))
        
        let expectedChild = SymbolTable(parent: expectedParent)
        expectedChild.stackFrameIndex = 1
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: 0, storage: .automaticStorage))
        
        XCTAssertEqual(expectedChild, actual)
    }
    
    func testLayoutWithParentInDifferentStackFrame2() {
        let grandparent = SymbolTable()
        grandparent.bind(identifier: "foo", symbol: Symbol(type: .u8, storage: .automaticStorage))
        
        let parent = SymbolTable(parent: grandparent)
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16, storage: .automaticStorage))
        parent.stackFrameIndex = 1
        
        let child = SymbolTable(parent: parent)
        child.bind(identifier: "baz", symbol: Symbol(type: .u8, storage: .automaticStorage))
        child.stackFrameIndex = 1
        
        let strategy = makeStrategy()
        let actual = strategy.layout(symbolTable: child)
        
        let expectedGrandparent = SymbolTable(parent: nil)
        expectedGrandparent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0, storage: .automaticStorage))
        
        let expectedParent = SymbolTable(parent: expectedGrandparent)
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: 0, storage: .automaticStorage))
        expectedParent.stackFrameIndex = 1
        
        let expectedChild = SymbolTable(parent: expectedParent)
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: 2, storage: .automaticStorage))
        expectedChild.stackFrameIndex = 1
        
        XCTAssertEqual(expectedChild, actual)
    }
    
    func testLayoutStaticStorage() {
        let grandparent = SymbolTable()
        grandparent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: nil, storage: .staticStorage))
        
        let parent = SymbolTable(parent: grandparent)
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: nil, storage: .staticStorage))
        parent.stackFrameIndex = 1
        
        let child = SymbolTable(parent: parent)
        child.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: nil, storage: .staticStorage))
        child.stackFrameIndex = 1
        
        let strategy = makeStrategy()
        let actual = strategy.layout(symbolTable: child)
        
        let base = SnapCompilerMetrics.kStaticStorageStartAddress
        
        let expectedGrandparent = SymbolTable()
        expectedGrandparent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: base+0, storage: .staticStorage))
        
        let expectedParent = SymbolTable(parent: expectedGrandparent)
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: base+1, storage: .staticStorage))
        expectedParent.stackFrameIndex = 1
        
        let expectedChild = SymbolTable(parent: expectedParent)
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: base+3, storage: .staticStorage))
        expectedChild.stackFrameIndex = 1
        
        XCTAssertEqual(expectedChild, actual)
    }
    
    func testLayoutStaticStorageAgain() {
        let grandparent = SymbolTable()
        grandparent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: nil, storage: .staticStorage))
        
        let parent = SymbolTable(parent: grandparent)
        parent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: nil, storage: .staticStorage))
        parent.stackFrameIndex = 1
        
        let child = SymbolTable(parent: parent)
        child.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: nil, storage: .staticStorage))
        child.stackFrameIndex = 1
        
        let strategy = makeStrategy()
        let _ = strategy.layout(symbolTable: child)
        let actual = strategy.layout(symbolTable: child)
        
        let base = SnapCompilerMetrics.kStaticStorageStartAddress
        
        let expectedGrandparent = SymbolTable()
        expectedGrandparent.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: base+0, storage: .staticStorage))
        
        let expectedParent = SymbolTable(parent: expectedGrandparent)
        expectedParent.bind(identifier: "bar", symbol: Symbol(type: .u16, offset: base+1, storage: .staticStorage))
        expectedParent.stackFrameIndex = 1
        
        let expectedChild = SymbolTable(parent: expectedParent)
        expectedChild.bind(identifier: "baz", symbol: Symbol(type: .u8, offset: base+3, storage: .staticStorage))
        expectedChild.stackFrameIndex = 1
        
        XCTAssertEqual(expectedChild, actual)
    }
}
