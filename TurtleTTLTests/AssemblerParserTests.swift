//
//  AssemblerParserTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerParserTests: XCTestCase {
    typealias Token = AssemblerScanner.Token
    
    func parse(_ text: String) throws -> AbstractSyntaxTreeNode {
        let tokens = tokenize(text)
        let parser = AssemblerParser(tokens: tokens)
        let ast = try parser.parse()
        return ast
    }
    
    func tokenize(_ text: String) -> [Token] {
        let tokenizer = AssemblerScanner(withString: text)
        try! tokenizer.scanTokens()
        let tokens = tokenizer.tokens
        return tokens
    }
    
    func testEmptyProgramYieldsEmptyAST() {
        let ast = try! parse("")
        XCTAssertEqual(ast.children.count, 0)
    }
    
    func testParseNOPYieldsSingleNOPNode() {
        let ast = try! parse("NOP")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], NOPNode())
    }

    func testParsingBogusOpcodeYieldsError() {
        XCTAssertThrowsError(try parse("BOGUS")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "no such instruction: `BOGUS'")
        }
    }

    func testParsingBogusOpcodeWithNewlineYieldsError() {
        XCTAssertThrowsError(try parse("BOGUS\n")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "no such instruction: `BOGUS'")
        }
    }

    func testParseTwoNOPsYieldsTwoNOPNodes() {
        let ast = try! parse("NOP\nNOP\n")
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], NOPNode())
        XCTAssertEqual(ast.children[1], NOPNode())
    }

    func testNOPAcceptsNoOperands() {
        XCTAssertThrowsError(try parse("NOP $1\n")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "instruction takes no operands: `NOP'")
        }
    }

    func testCMPParses() {
        let ast = try! parse("CMP")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], CMPNode())
    }

    func testCMPAcceptsNoOperands() {
        XCTAssertThrowsError(try parse("CMP $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "instruction takes no operands: `CMP'")
        }
    }

    func testHLTParses() {
        let ast = try! parse("HLT")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], HLTNode())
    }

    func testHLTAcceptsNoOperands() {
        XCTAssertThrowsError(try parse("HLT $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "instruction takes no operands: `HLT'")
        }
    }

    func testLabelDeclaration() {
        let ast = try! parse("label:")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "label")))
    }

    func testLabelDeclarationAtAnotherAddress() {
        let ast = try! parse("NOP\nlabel:")
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], NOPNode())
        XCTAssertEqual(ast.children[1], LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 2, lexeme: "label")))
    }

    func testParseLabelNameIsANumber() {
        XCTAssertThrowsError(try parse("123:")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "unexpected end of input")
        }
    }

    func testParseLabelNameIsAKeyword() {
        XCTAssertThrowsError(try parse("NOP:")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "instruction takes no operands: `NOP'")
        }
    }

    func testParseExtraneousColon() {
        XCTAssertThrowsError(try parse(":")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "unexpected end of input")
        }
    }

    func testFailToCompileJMPWithZeroOperands() {
        XCTAssertThrowsError(try parse("JMP")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `JMP'")
        }
    }

    func testParseSucceedsWithJMPWithUndeclaredLabel() {
        let ast = try! parse("JMP label")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], JMPNode(token: Token(type: .identifier, lineNumber: 1, lexeme: "label")))
    }

    func testJMPParses() {
        let ast = try! parse("label:\nJMP label")

        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "label")))
        XCTAssertEqual(ast.children[1], JMPNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "label")))
    }

    func testFailToParseJCWithZeroOperands() {
        XCTAssertThrowsError(try parse("JC")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `JC'")
        }
    }

    func testParseSucceedsWithJCWithUndeclaredLabel() {
        let ast = try! parse("JC label")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], JCNode(token: Token(type: .identifier, lineNumber: 1, lexeme: "label")))
    }

    func testJCParses() {
        let ast = try! parse("label:\nJC label")
        
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: Token(type: .identifier, lineNumber: 1, lexeme: "label")))
        XCTAssertEqual(ast.children[1], JCNode(token: Token(type: .identifier, lineNumber: 2, lexeme: "label")))
    }

    func testFailToParseADDWithZeroOperands() {
        XCTAssertThrowsError(try parse("ADD")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `ADD'")
        }
    }

    func testFailToParseADDWithIdentifierOperand() {
        XCTAssertThrowsError(try parse("ADD label")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `ADD'")
        }
    }

    func testParseADDWithRegisterOperand() {
        let ast = try! parse("ADD D")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], ADDNode(destination: "D"))
    }

    func testFailToParseADDWithInvalidDestinationRegisterE() {
        XCTAssertThrowsError(try parse("ADD E")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `E'")
        }
    }

    func testFailToParseADDWithInvalidDestinationRegisterC() {
        XCTAssertThrowsError(try parse("ADD C")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `C'")
        }
    }

    func testFailToParseLIWithNoOperands() {
        XCTAssertThrowsError(try parse("LI")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }

    func testFailToParseLIWithOneOperand() {
        XCTAssertThrowsError(try parse("LI $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }

    func testFailToParseLIWhichIsMissingTheCommaOperand() {
        XCTAssertThrowsError(try parse("LI A $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }

    func testFailToParseLIWithBadComma() {
        XCTAssertThrowsError(try parse("LI,")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }

    func testFailToParseLIWhereDestinationIsANumber() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("LI $1, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }

    func testFailToParseLIWhereSourceIsARegister() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("LI B, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }

    func testFailToParseLIWithTooManyOperands() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("LI A, $1, B")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }

    func testParseValidLI() {
        let ast = try! parse("LI D, 42")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LINode(destination: "D", immediate: Token(type: .number, lineNumber: 1, lexeme: "42", literal: 42)))
    }

    func testLIParsesWithTooBigNumber() {
        // It's the code generator which checks that the value is appropriate.
        let ast = try! parse("LI D, 10000000")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LINode(destination: "D", immediate: Token(type: .number, lineNumber: 1, lexeme: "10000000", literal: 10000000)))
    }

    func testFailToParseMOVWithNoOperands() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("MOV")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }

    func testFailToParseMOVWithOneOperand() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("MOV A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }

    func testFailToParseMOVWithTooManyOperands() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("MOV A, B, C")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }

    func testFailToParseMOVWithNumberInFirstOperand() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("MOV $1, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }

    func testFailToParseMOVWithNumberInSecondOperand() {
        // TODO: Better error message here
        XCTAssertThrowsError(try parse("MOV A, $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }

    func testFailToParseMOVWithInvalidDestinationRegisterE() {
        XCTAssertThrowsError(try parse("MOV E, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `E'")
        }
    }

    func testFailToParseMOVWithInvalidDestinationRegisterC() {
        XCTAssertThrowsError(try parse("MOV C, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `C'")
        }
    }

    func testFailToParseMOVWithInvalidSourceRegisterD() {
        XCTAssertThrowsError(try parse("MOV A, D")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a source: `D'")
        }
    }

    func testParseValidMOV() {
        let ast = try! parse("MOV D, A")
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], MOVNode(destination: "D", source: "A"))
    }
}
