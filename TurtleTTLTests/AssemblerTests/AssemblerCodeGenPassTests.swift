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
    let aabb = TokenNumber(lineNumber: 1, lexeme: "0xaabb", literal: 0xaabb)
    let tooLargeAddress = TokenNumber(lineNumber: 1, lexeme: "0xffffffff", literal: 0xffffffff)
    let negativeAddress = TokenNumber(lineNumber: 1, lexeme: "-1", literal: -1)
    
    var microcodeGenerator = MicrocodeGenerator()
    var nop: UInt8 = 0
    var hlt: UInt8 = 0
    
    func makeBackEnd(symbols: [String : Int] = [:]) -> AssemblerCodeGenPass {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        let compiler = AssemblerCodeGenPass(codeGenerator: codeGen)
        compiler.symbols = symbols
        return compiler
    }
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        nop = UInt8(microcodeGenerator.getOpcode(withMnemonic: "NOP")!)
        hlt = UInt8(microcodeGenerator.getOpcode(withMnemonic: "HLT")!)
    }
    
    func mustCompile(_ root: AbstractSyntaxTreeNode) -> [Instruction] {
        let compiler = makeBackEnd()
        compiler.compile(root)
        assert(!compiler.hasError)
        return compiler.instructions
    }
    
    func mustFailToCompile(_ root: AbstractSyntaxTreeNode) -> [AssemblerError] {
        let compiler = makeBackEnd()
        compiler.compile(root)
        assert(compiler.hasError)
        return compiler.errors
    }
    
    func testEmptyProgram() {
        let instructions = mustCompile(AbstractSyntaxTreeNode())
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, nop)
    }
    
    func testNop() {
        let ast = AbstractSyntaxTreeNode(children: [NOPNode()])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, nop)
    }
    
    func testHlt() {
        let ast = AbstractSyntaxTreeNode(children: [HLTNode()])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, hlt)
    }
    
    func testMov() throws {
        let ast = AbstractSyntaxTreeNode(children: [MOVNode(destination: .D, source: .A)])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.AO, .active)
        XCTAssertEqual(controlWord.DI, .active)
    }
    
    func testLoadImmediate() {
        let ast = AbstractSyntaxTreeNode(children: [LINode(destination: .D, immediate: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42))])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 42)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.CO, .active)
        XCTAssertEqual(controlWord.DI, .active)
    }
    
    func testStoreToMemory() {
        let ast = AbstractSyntaxTreeNode(children: [StoreNode(destinationAddress: aabb, source: .A)])
        let instructions = mustCompile(ast)

        XCTAssertEqual(instructions.count, 4)

        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)

        // The next two instructions load an address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0xaa)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0xbb)

        // And an instructions to store the A register in memory
        let opcode = UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV M, A")!)
        XCTAssertEqual(instructions[3].opcode, opcode)
    }

    func testStoreToMemoryWithInvalidAddress() {
        let ast = AbstractSyntaxTreeNode(children: [StoreNode(destinationAddress: tooLargeAddress, source: .A)])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.line, 1)
        XCTAssertEqual(error.message, "Address is invalid: 0xffffffff")
    }
    
    func testStoreImmediateToMemoryWithInvalidAddress() {
        let ast = AbstractSyntaxTreeNode(children: [StoreImmediateNode(destinationAddress: TokenNumber(lineNumber: 1, lexeme: "0xffffffff", literal: 0xffffffff), immediate: 0)])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.line, 1)
        XCTAssertEqual(error.message, "Address is invalid: 0xffffffff")
    }
    
    func testStoreImmediateToMemoryWithImmediate() {
        let ast = AbstractSyntaxTreeNode(children: [StoreImmediateNode(destinationAddress: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0), immediate: 0xffffffff)])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.line, 1)
        XCTAssertEqual(error.message, "Immediate is invalid: 0xffffffff")
    }

    func testLoadFromMemory() {
        let ast = AbstractSyntaxTreeNode(children: [
            StoreImmediateNode(destinationAddress: aabb, immediate: 42),
            LoadNode(destination: .A, sourceAddress: aabb)])
        let instructions = mustCompile(ast)

        XCTAssertEqual(instructions.count, 7)

        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)

        // The next two instructions load an address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0xaa)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0xbb)

        // And an instructions to store the immediate value 42 in memory
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV M, C")!))
        XCTAssertEqual(instructions[3].immediate, 42)

        // The next two instructions load an address into XY.
        XCTAssertEqual(instructions[4].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[4].immediate, 0xaa)
        XCTAssertEqual(instructions[5].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[5].immediate, 0xbb)

        // And an instructions to store the A register in memory
        XCTAssertEqual(instructions[6].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV A, M")!))
    }

    func testLoadFromMemoryWithNegativeAddress() {
        let ast = AbstractSyntaxTreeNode(children: [LoadNode(destination: .A, sourceAddress: negativeAddress)])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.line, 1)
        XCTAssertEqual(error.message, "Address is invalid: 0xffffffff")
    }

    func testLoadFromMemoryWithTooLargeAddress() {
        let ast = AbstractSyntaxTreeNode(children: [LoadNode(destination: .A, sourceAddress: tooLargeAddress)])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.line, 1)
        XCTAssertEqual(error.message, "Address is invalid: 0xffffffff")
    }
    
    func testAdd() {
        let ast = AbstractSyntaxTreeNode(children: [ADDNode(destination: .D)])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        XCTAssertEqual(instructions[1].immediate, 0b011001)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.EO, .active)
        XCTAssertEqual(controlWord.DI, .active)
    }
    
    func testJmp() {
        let labelNode = LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        let lxyNode = LXYWithLabelNode(token: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        let jmpNode = JMPNode()
        let ast = AbstractSyntaxTreeNode(children: [labelNode, lxyNode, jmpNode])
        let instructions = mustCompile(ast)
        
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
            LXYWithLabelNode(token: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
            JMPNode(),
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo")),
            HLTNode()])
        let instructions = mustCompile(ast)
        
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
        let ast = AbstractSyntaxTreeNode(children: [
            LXYWithAddressNode(address: 0),
            JMPNode()
        ])
        let instructions = mustCompile(ast)

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
        let ast = AbstractSyntaxTreeNode(children: [
            LXYWithAddressNode(address: -1),
            JMPNode()
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJmpToAddressTooLarge() {
        let ast = AbstractSyntaxTreeNode(children: [
            LXYWithAddressNode(address: 0x10000),
            JMPNode()
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testJC() {
        let ast = AbstractSyntaxTreeNode(children: [
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
            LXYWithLabelNode(token: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
            JCNode()
        ])
        let instructions = mustCompile(ast)
        
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
    
    func testJCToAddressZero() {
        let ast = AbstractSyntaxTreeNode(children: [
            LXYWithAddressNode(address: 0),
            JCNode()
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0)
        
        // The JC command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JC")!))
        
        // JC must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJCToAddressNegative() {
        let ast = AbstractSyntaxTreeNode(children: [
            LXYWithAddressNode(address: -1),
            JCNode()
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJCToAddressTooLarge() {
        let ast = AbstractSyntaxTreeNode(children: [
            LXYWithAddressNode(address: 0x10000),
            JCNode()
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testCMP() {
        let ast = AbstractSyntaxTreeNode(children: [CMPNode()])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU")!))
        XCTAssertEqual(instructions[1].immediate, 0b010110)
    }
}
