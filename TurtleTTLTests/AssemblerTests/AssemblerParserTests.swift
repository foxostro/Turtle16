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
    func tokenize(_ text: String) -> [Token] {
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        let tokens = tokenizer.tokens
        return tokens
    }
    
    func testEmptyProgramYieldsEmptyAST() {
        let parser = AssemblerParser(tokens: tokenize(""))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
    }
    
    func testParseNOPYieldsSingleNOPNode() {
        let parser = AssemblerParser(tokens: tokenize("NOP"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], NOPNode())
    }

    func testParsingBogusOpcodeYieldsError() {
        let parser = AssemblerParser(tokens: tokenize("BOGUS"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "no such instruction: `BOGUS'")
    }

    func testParsingBogusOpcodeWithNewlineYieldsError() {
        let parser = AssemblerParser(tokens: tokenize("BOGUS\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "no such instruction: `BOGUS'")
    }

    func testParseTwoNOPsYieldsTwoNOPNodes() {
        let parser = AssemblerParser(tokens: tokenize("NOP\nNOP\n"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], NOPNode())
        XCTAssertEqual(ast.children[1], NOPNode())
    }

    func testNOPAcceptsNoOperands() {
        let parser = AssemblerParser(tokens: tokenize("NOP $1\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "instruction takes no operands: `NOP'")
    }

    func testCMPParses() {
        let parser = AssemblerParser(tokens: tokenize("CMP"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], CMPNode())
    }

    func testCMPAcceptsNoOperands() {
        let parser = AssemblerParser(tokens: tokenize("CMP $1\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "instruction takes no operands: `CMP'")
    }

    func testHLTParses() {
        let parser = AssemblerParser(tokens: tokenize("HLT"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], HLTNode())
    }

    func testHLTAcceptsNoOperands() {
        let parser = AssemblerParser(tokens: tokenize("HLT $1\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "instruction takes no operands: `HLT'")
    }

    func testLabelDeclaration() {
        let parser = AssemblerParser(tokens: tokenize("label:"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "label")))
    }

    func testLabelDeclarationAtAnotherAddress() {
        let parser = AssemblerParser(tokens: tokenize("NOP\nlabel:"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], NOPNode())
        XCTAssertEqual(ast.children[1], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "label")))
    }

    func testParseLabelNameIsANumber() {
        let parser = AssemblerParser(tokens: tokenize("123:"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testParseLabelNameIsAKeyword() {
        let parser = AssemblerParser(tokens: tokenize("NOP:"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "instruction takes no operands: `NOP'")
    }

    func testParseExtraneousColon() {
        let parser = AssemblerParser(tokens: tokenize(":"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testFailToCompileJMPWithZeroOperands() {
        let parser = AssemblerParser(tokens: tokenize("JMP"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `JMP'")
    }

    func testParseSucceedsWithJMPWithUndeclaredLabel() {
        let parser = AssemblerParser(tokens: tokenize("JMP label"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], JMPToLabelNode(token: TokenIdentifier(lineNumber: 1, lexeme: "label")))
    }

    func testJMPParses() {
        let parser = AssemblerParser(tokens: tokenize("label:\nJMP label"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!

        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "label")))
        XCTAssertEqual(ast.children[1], JMPToLabelNode(token: TokenIdentifier(lineNumber: 2, lexeme: "label")))
    }
    
    func testParseJMPWithAddress() {
        let parser = AssemblerParser(tokens: tokenize("JMP 0x0000"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], JMPToAddressNode(address: 0))
    }

    func testFailToParseJCWithZeroOperands() {
        let parser = AssemblerParser(tokens: tokenize("JC"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `JC'")
    }

    func testParseSucceedsWithJCWithUndeclaredLabel() {
        let parser = AssemblerParser(tokens: tokenize("JC label"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], JCToLabelNode(token: TokenIdentifier(lineNumber: 1, lexeme: "label")))
    }

    func testJCParses() {
        let parser = AssemblerParser(tokens: tokenize("label:\nJC label"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "label")))
        XCTAssertEqual(ast.children[1], JCToLabelNode(token: TokenIdentifier(lineNumber: 2, lexeme: "label")))
    }
    
    func testParseJCWithAddress() {
        let parser = AssemblerParser(tokens: tokenize("JC 0x0000"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], JCToAddressNode(address: 0))
    }

    func testFailToParseADDWithZeroOperands() {
        let parser = AssemblerParser(tokens: tokenize("ADD"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `ADD'")
    }

    func testFailToParseADDWithIdentifierOperand() {
        let parser = AssemblerParser(tokens: tokenize("ADD label"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `ADD'")
    }

    func testParseADDWithRegisterOperand() {
        let parser = AssemblerParser(tokens: tokenize("ADD D"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], ADDNode(destination: .D))
    }

    func testFailToParseADDWithInvalidDestinationRegisterE() {
        let parser = AssemblerParser(tokens: tokenize("ADD E"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToParseADDWithInvalidDestinationRegisterC() {
        let parser = AssemblerParser(tokens: tokenize("ADD C"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToParseLIWithNoOperands() {
        let parser = AssemblerParser(tokens: tokenize("LI"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToParseLIWithOneOperand() {
        let parser = AssemblerParser(tokens: tokenize("LI $1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToParseLIWhichIsMissingTheCommaOperand() {
        let parser = AssemblerParser(tokens: tokenize("LI A $1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToParseLIWithBadComma() {
        let parser = AssemblerParser(tokens: tokenize("LI,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToParseLIWhereDestinationIsANumber() {
        let parser = AssemblerParser(tokens: tokenize("LI $1, A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToParseLIWhereSourceIsARegister() {
        let parser = AssemblerParser(tokens: tokenize("LI B, A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToParseLIWithTooManyOperands() {
        let parser = AssemblerParser(tokens: tokenize("LI A, $1, B"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LI'")
    }

    func testParseValidLI() {
        let parser = AssemblerParser(tokens: tokenize("LI D, 42"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LINode(destination: .D, immediate: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42)))
    }

    func testLIParsesWithTooBigNumber() {
        // It's the code generator which checks that the value is appropriate.
        let parser = AssemblerParser(tokens: tokenize("LI D, 10000000"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LINode(destination: .D, immediate: TokenNumber(lineNumber: 1, lexeme: "10000000", literal: 10000000)))
    }

    func testFailToParseMOVWithNoOperands() {
        let parser = AssemblerParser(tokens: tokenize("MOV"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToParseMOVWithOneOperand() {
        let parser = AssemblerParser(tokens: tokenize("MOV A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToParseMOVWithTooManyOperands() {
        let parser = AssemblerParser(tokens: tokenize("MOV A, B, C"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToParseMOVWithNumberInFirstOperand() {
        let parser = AssemblerParser(tokens: tokenize("MOV $1, A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToParseMOVWithNumberInSecondOperand() {
        let parser = AssemblerParser(tokens: tokenize("MOV A, $1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToParseMOVWithInvalidDestinationRegisterE() {
        let parser = AssemblerParser(tokens: tokenize("MOV E, A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToParseMOVWithInvalidDestinationRegisterC() {
        let parser = AssemblerParser(tokens: tokenize("MOV C, A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToParseMOVWithInvalidSourceRegisterD() {
        let parser = AssemblerParser(tokens: tokenize("MOV A, D"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "register cannot be used as a source: `D'")
    }

    func testParseValidMOV() {
        let parser = AssemblerParser(tokens: tokenize("MOV D, A"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], MOVNode(destination: .D, source: .A))
    }
    
    func testFailToParseStoreWithZeroOperands() {
        let parser = AssemblerParser(tokens: tokenize("STORE"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `STORE'")
    }
    
    func testFailToParseStoreWithTooFewArguments() {
        let parser = AssemblerParser(tokens: tokenize("STORE $0"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `STORE'")
    }
    
    func testFailToParseStoreWithTooManyArguments() {
        let parser = AssemblerParser(tokens: tokenize("STORE $0, $0, $0"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `STORE'")
    }
    
    func testFailToParseStoreWithBadTypeForDestination() {
        let parser = AssemblerParser(tokens: tokenize("STORE A, 1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `STORE'")
    }
    
    func testFailToParseStoreWithBadTypeForSource() {
        let parser = AssemblerParser(tokens: tokenize("STORE A, B"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `STORE'")
    }
    
    func testFailToParseStoreWithInappropriateSourceRegister() {
        let parser = AssemblerParser(tokens: tokenize("STORE 0, D"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "register cannot be used as a source: `D'")
    }
    
    func testParseValidStore() {
        let parser = AssemblerParser(tokens: tokenize("STORE 42, A"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], StoreNode(destinationAddress: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42), source: .A))
    }
    
    func testParseValidStoreImmediate() {
        let parser = AssemblerParser(tokens: tokenize("STORE 1, 2"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], StoreImmediateNode(destinationAddress: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1), immediate: 2))
    }
    
    func testFailToParseLoadWithZeroOperands() {
        let parser = AssemblerParser(tokens: tokenize("LOAD"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LOAD'")
    }
    
    func testFailToParseLoadWithTooFewArguments() {
        let parser = AssemblerParser(tokens: tokenize("LOAD $0"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LOAD'")
    }
    
    func testFailToParseLoadWithTooManyArguments() {
        let parser = AssemblerParser(tokens: tokenize("LOAD $0, $0, $0"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LOAD'")
    }

    func testFailToParseLoadWithBadTypeForDestination() {
        let parser = AssemblerParser(tokens: tokenize("LOAD 1, 1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LOAD'")
    }

    func testFailToParseLoadWithBadTypeForSource() {
        let parser = AssemblerParser(tokens: tokenize("LOAD A, A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `LOAD'")
    }

    func testFailToParseLoadWithInappropriateDestinationRegister() {
        let parser = AssemblerParser(tokens: tokenize("LOAD C, 0"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testParseValidLoad() {
        let parser = AssemblerParser(tokens: tokenize("LOAD A, 42"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LoadNode(destination: .A, sourceAddress: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42)))
    }
    
    func testMultipleErrorsParsingInstructions() {
        let parser = AssemblerParser(tokens: tokenize("NOP $1\nLOAD C, 0\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors[0].line, 1)
        XCTAssertEqual(parser.errors[0].message, "instruction takes no operands: `NOP'")
        XCTAssertEqual(parser.errors[1].line, 2)
        XCTAssertEqual(parser.errors[1].message, "register cannot be used as a destination: `C'")
    }
}
