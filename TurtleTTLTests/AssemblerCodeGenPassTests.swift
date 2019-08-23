//
//  AssemblerCodeGenPassTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerCodeGenPassTests: XCTestCase {
    typealias Token = AssemblerScanner.Token
    var microcodeGenerator = MicrocodeGenerator()
    var nop: UInt8 = 0
    var hlt: UInt8 = 0
    
    func makeBackEnd(symbols: [String : Int] = [:]) -> AssemblerCodeGenPass {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        return AssemblerCodeGenPass(codeGenerator: codeGen, symbols: symbols)
    }
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        nop = UInt8(microcodeGenerator.getOpcode(withMnemonic: "NOP")!)
        hlt = UInt8(microcodeGenerator.getOpcode(withMnemonic: "HLT")!)
    }
    
    func testEmptyProgram() {
        let instructions = try! makeBackEnd().generate(AbstractSyntaxTreeNode())
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, nop)
    }
    
    func testNop() {
        let ast = AbstractSyntaxTreeNode(children: [NOPNode()])
        let instructions = try! makeBackEnd().generate(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, nop)
    }
    
    func testHlt() {
        let ast = AbstractSyntaxTreeNode(children: [HLTNode()])
        let instructions = try! makeBackEnd().generate(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, hlt)
    }
    
    func testMov() throws {
        let ast = AbstractSyntaxTreeNode(children: [MOVNode(destination: "D", source: "A")])
        let instructions = try! makeBackEnd().generate(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.AO, false)
        XCTAssertEqual(controlWord.DI, false)
    }
    
    func testLoadImmediate() {
        let ast = AbstractSyntaxTreeNode(children: [LINode(destination: "D", immediate: Token(type: .number, lineNumber: 1, lexeme: "42", literal: 42))])
        let instructions = try! makeBackEnd().generate(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 42)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.CO, false)
        XCTAssertEqual(controlWord.DI, false)
    }
    
//    func testStoreToMemory() {
//        let backEnd = makeBackEnd()
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
//
//    func testStoreToMemoryWithInvalidAddress() {
//        let backEnd = makeBackEnd()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.store(address: 0xffffff, source: "A"))
//    }
//
//    func testLoadFromMemory() {
//        let backEnd = makeBackEnd()
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
//
//    func testLoadFromMemoryWithNegativeAddress() {
//        let backEnd = makeBackEnd()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.store(address: -1, immediate: 42)) { e in
//            let error = e as! AssemblerError
//            XCTAssertEqual(error.message, "Address is invalid: 0xffffffff")
//        }
//    }
//
//    func testLoadFromMemoryWithTooLargeImmediate() {
//        let backEnd = makeBackEnd()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.store(address: 0, immediate: 1000)) { e in
//            let error = e as! AssemblerError
//            XCTAssertEqual(error.message, "Immediate is invalid: 0x3e8")
//        }
//    }
//
//    func testLoadFromMemoryWithInvalidAddress() {
//        let backEnd = makeBackEnd()
//        backEnd.begin()
//        XCTAssertThrowsError(try backEnd.load(address: 0xffffff, destination: "A"))
//    }
    
    func testAdd() {
        let ast = AbstractSyntaxTreeNode(children: [ADDNode(destination: "D")])
        let instructions = try! makeBackEnd().generate(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        XCTAssertEqual(instructions[1].immediate, 0b011001)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.EO, false)
        XCTAssertEqual(controlWord.DI, false)
    }
    
    func testResolveUnrecognizedLabel() {
        let backEnd = makeBackEnd()
        XCTAssertThrowsError(try backEnd.resolveSymbol(name: ""))
    }
    
    func testJmp() {
        let labelNode = LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "foo"))
        let jmpNode = JMPToLabelNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))
        let ast = AbstractSyntaxTreeNode(children: [labelNode, jmpNode])
        let backEnd = makeBackEnd(symbols: ["foo" : 1])
        let instructions = try! backEnd.generate(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 1)
        
        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))
        
        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testForwardJmp() {
        let ast = AbstractSyntaxTreeNode(children: [
            JMPToLabelNode(token: Token(type: .identifier, lineNumber: 1, lexeme: "foo")),
            LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 2, lexeme: "foo")),
            HLTNode()])
        let backEnd = makeBackEnd(symbols: ["foo" : 6])
        let instructions = try! backEnd.generate(ast)
        
        XCTAssertEqual(instructions.count, 7)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 6)
        
        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))
        
        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
        
        // HLT halts the machine to stop it running.
        XCTAssertEqual(instructions[6].opcode, hlt)
    }
    
    func testJmpToAddressZero() {
        let ast = AbstractSyntaxTreeNode(children: [JMPToAddressNode(address: 0)])
        let backEnd = makeBackEnd()
        let instructions = try! backEnd.generate(ast)

        XCTAssertEqual(instructions.count, 6)

        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)

        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0)

        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))

        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJmpToAddressNegative() {
        let ast = AbstractSyntaxTreeNode(children: [JMPToAddressNode(address: -1)])
        let backEnd = makeBackEnd()
        XCTAssertThrowsError(try backEnd.generate(ast)) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "invalid address: 0xffffffff")
        }
    }
    
    func testJmpToAddressTooLarge() {
        let ast = AbstractSyntaxTreeNode(children: [JMPToAddressNode(address: 0x10000)])
        let backEnd = makeBackEnd()
        XCTAssertThrowsError(try backEnd.generate(ast)) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "invalid address: 0x10000")
        }
    }
    
    func testJC() {
        let ast = AbstractSyntaxTreeNode(children: [
            LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "foo")),
            JCNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "foo"))])
        let instructions = try! makeBackEnd(symbols: ["foo" : 1]).generate(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 1)
        
        // The JC command jumps to the address in the XY register pair, but only
        // if the carry flag is set.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JC")!))
        
        // JC must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testCMP() {
        let ast = AbstractSyntaxTreeNode(children: [CMPNode()])
        let instructions = try! makeBackEnd().generate(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU")!))
        XCTAssertEqual(instructions[1].immediate, 0b010110)
    }
}
