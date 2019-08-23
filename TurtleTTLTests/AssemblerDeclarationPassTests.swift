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
    typealias Token = AssemblerScanner.Token
    
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
        let ast = AbstractSyntaxTreeNode(children: [LINode(destination: "D", immediate: Token(type: .number, lineNumber: 1, lexeme: "42", literal: 42))])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
    
//    func testStoreToMemory() {
//        let backEnd = AssemblerDeclarationPass()
//        backEnd.begin()
//        try! backEnd.store(address: 0xaabb, source: "A")
//        try! backEnd.end()
//        let instructions = backEnd.instructions
//
//        XCTAssertEqual(instructions.count, 4)
//
//        // The first instruction in memory must be a NOP. Without this, CPU
//        // reset does not work.
//        XCTAssertEqual(instructions[0].opcode, nop)
//
//        // The next two instructions load an address into XY.
//        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
//        XCTAssertEqual(instructions[1].immediate, 0xaa)
//        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
//        XCTAssertEqual(instructions[2].immediate, 0xbb)
//
//        // And an instructions to store the A register in memory
//        let opcode = UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV M, A")!)
//        XCTAssertEqual(instructions[3].opcode, opcode)
//    }
    
//    func testStoreToMemoryWithInvalidAddress() {
//        let backEnd = AssemblerDeclarationPass()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.store(address: 0xffffff, source: "A"))
//    }
    
//    func testLoadFromMemory() {
//        let backEnd = AssemblerDeclarationPass()
//        backEnd.begin()
//        try! backEnd.store(address: 0xaabb, immediate: 42)
//        try! backEnd.load(address: 0xaabb, destination: "A")
//        try! backEnd.end()
//        let instructions = backEnd.instructions
//
//        XCTAssertEqual(instructions.count, 7)
//
//        // The first instruction in memory must be a NOP. Without this, CPU
//        // reset does not work.
//        XCTAssertEqual(instructions[0].opcode, nop)
//
//        // The next two instructions load an address into XY.
//        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
//        XCTAssertEqual(instructions[1].immediate, 0xaa)
//        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
//        XCTAssertEqual(instructions[2].immediate, 0xbb)
//
//        // And an instructions to store the immediate value 42 in memory
//        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV M, C")!))
//        XCTAssertEqual(instructions[3].immediate, 42)
//
//        // The next two instructions load an address into XY.
//        XCTAssertEqual(instructions[4].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
//        XCTAssertEqual(instructions[4].immediate, 0xaa)
//        XCTAssertEqual(instructions[5].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
//        XCTAssertEqual(instructions[5].immediate, 0xbb)
//
//        // And an instructions to store the A register in memory
//        XCTAssertEqual(instructions[6].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV A, M")!))
//    }
    
//    func testLoadFromMemoryWithNegativeAddress() {
//        let backEnd = AssemblerDeclarationPass()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.store(address: -1, immediate: 42)) { e in
//            let error = e as! AssemblerError
//            XCTAssertEqual(error.message, "Address is invalid: 0xffffffff")
//        }
//    }
    
//    func testLoadFromMemoryWithTooLargeImmediate() {
//        let backEnd = AssemblerDeclarationPass()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.store(address: 0, immediate: 1000)) { e in
//            let error = e as! AssemblerError
//            XCTAssertEqual(error.message, "Immediate is invalid: 0x3e8")
//        }
//    }
    
//    func testLoadFromMemoryWithInvalidAddress() {
//        let backEnd = AssemblerDeclarationPass()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.load(address: 0xffffff, destination: "A"))
//    }
    
    func testAdd() {
        let ast = AbstractSyntaxTreeNode(children: [ADDNode(destination: "D")])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.programCounter, 2)
    }
    
    func testLabel() {
        let labelNode = LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "foo"))
        let jmpNode = JMPToLabelNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode, jmpNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.symbols, ["foo" : 1])
        XCTAssertEqual(backEnd.programCounter, 6)
    }
    
    func testDuplicateLabel() {
        let labelNode1 = LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "foo"))
        let labelNode2 = LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode1, labelNode2])
        let backEnd = AssemblerDeclarationPass()
        XCTAssertThrowsError(try backEnd.doDeclarations(ast)) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 2)
            XCTAssertEqual(error.message, "duplicate label: `foo'")
        }
    }
    
    func testJmp() {
        let labelNode = LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "foo"))
        let jmpNode = JMPToLabelNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode, jmpNode])
        let backEnd = AssemblerDeclarationPass()
        try! backEnd.doDeclarations(ast)
        XCTAssertEqual(backEnd.symbols, ["foo" : 1])
        XCTAssertEqual(backEnd.programCounter, 6)
    }
    
    func testForwardJmp() {
        let jmpNode = JMPToLabelNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))
        let labelNode = LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))
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
        let labelNode = LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "foo"))
        let jcNode = JCToLabelNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))
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
