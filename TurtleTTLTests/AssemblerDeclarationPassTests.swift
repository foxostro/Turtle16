//
//  AssemblerBackEndTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/31/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerDeclarationPassTests: XCTestCase {
    let zero = TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)
    
    func testEmptyProgram() {
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(AbstractSyntaxTreeNode())
        XCTAssertEqual(backEnd.symbols, [:])
    }
    
    func testNop() {
        let ast = AbstractSyntaxTreeNode(children: [NOPNode()])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
    
    func testHlt() {
        let ast = AbstractSyntaxTreeNode(children: [HLTNode()])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
    
    func testMov() throws {
        let ast = AbstractSyntaxTreeNode(children: [MOVNode(destination: "D", source: "A")])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
    
    func testLoadImmediate() {
        let ast = AbstractSyntaxTreeNode(children: [LINode(destination: "D", immediate: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42))])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
    
    func testLoad() {
        let ast = AbstractSyntaxTreeNode(children: [LoadNode(destination: "A", sourceAddress: zero)])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 4)
    }
    
    func testStore() {
        let ast = AbstractSyntaxTreeNode(children: [StoreNode(destinationAddress: zero, source: "A")])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 4)
    }
    
    func testStoreImmediate() {
        let ast = AbstractSyntaxTreeNode(children: [StoreImmediateNode(destinationAddress: zero, immediate: 0)])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 4)
    }
    
    func testAdd() {
        let ast = AbstractSyntaxTreeNode(children: [ADDNode(destination: "D")])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
    
    func testLabel() {
        let labelNode = LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        let jmpNode = JMPToLabelNode(token: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode, jmpNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.symbols, ["foo" : 1])
        XCTAssertEqual(backEnd.programCounter, 6)
    }
    
    func testDuplicateLabel() {
        let labelNode1 = LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        let labelNode2 = LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode1, labelNode2])
        let backEnd = AssemblerDeclarationPass()
        XCTAssertThrowsError(try backEnd.doDeclarations(ast)) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 2)
            XCTAssertEqual(error.message, "duplicate label: `foo'")
        }
    }
    
    func testJmp() {
        let labelNode = LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        let jmpNode = JMPToLabelNode(token: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode, jmpNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.symbols, ["foo" : 1])
        XCTAssertEqual(backEnd.programCounter, 6)
    }
    
    func testForwardJmp() {
        let jmpNode = JMPToLabelNode(token: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        let labelNode = LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        let hltNode = HLTNode()
        let ast = AbstractSyntaxTreeNode(children: [jmpNode, labelNode, hltNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.symbols, ["foo" : 6])
        XCTAssertEqual(backEnd.programCounter, 7)
    }
    
    func testJmpToAddressZero() {
        let jmpNode = JMPToAddressNode(address: 0)
        let ast = AbstractSyntaxTreeNode(children: [jmpNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.symbols, [:])
        XCTAssertEqual(backEnd.programCounter, 6)
    }
    
    func testJC() {
        let labelNode = LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        let jcNode = JCToLabelNode(token: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode, jcNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.symbols, ["foo" : 1])
        XCTAssertEqual(backEnd.programCounter, 6)
    }
    
    func testCMP() {
        let cmpNode = CMPNode()
        let ast = AbstractSyntaxTreeNode(children: [cmpNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
}
