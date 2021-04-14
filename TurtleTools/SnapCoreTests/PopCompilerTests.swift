//
//  PopCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class PopCompilerTests: XCTestCase {
    fileprivate func makeListing(_ compiler: PopCompiler) -> String {
        return AssemblyListingMaker.makeListing(0, compiler.instructions, compiler.programDebugInfo)
    }
    
    func testCompileEmptyProgram() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: []))
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileFake() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.fake]))
        XCTAssertEqual(makeListing(compiler), "")
    }
    
    func testCompileNOP() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.nop]))
        XCTAssertEqual(makeListing(compiler), "NOP")
    }
    
    func testCompileHLT() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.hlt]))
        XCTAssertEqual(makeListing(compiler), "HLT")
    }
    
    func testCompileINUV() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.inuv]))
        XCTAssertEqual(makeListing(compiler), "INUV")
    }
    
    func testCompileINXY() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.inxy]))
        XCTAssertEqual(makeListing(compiler), "INXY")
    }
    
    func testCompileMOV() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.mov(.X, .Y)]))
        XCTAssertEqual(makeListing(compiler), "MOV X, Y")
    }
    
    func testCompileLI() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.li(.X, 0xab)]))
        XCTAssertEqual(makeListing(compiler), "LI X, 0xab")
    }
    
    func testCompileADD() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.add(.A)]))
        XCTAssertEqual(makeListing(compiler), """
ADD
ADD A
""")
    }
    
    func testCompileSUB() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.sub(.A)]))
        XCTAssertEqual(makeListing(compiler), """
SUB
SUB A
""")
    }
    
    func testCompileADC() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.adc(.A)]))
        XCTAssertEqual(makeListing(compiler), """
ADC
ADC A
""")
    }
    
    func testCompileSBC() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.sbc(.A)]))
        XCTAssertEqual(makeListing(compiler), """
SBC
SBC A
""")
    }
    
    func testCompileDEA() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.dea(.A)]))
        XCTAssertEqual(makeListing(compiler), """
DEA
DEA A
""")
    }
    
    func testCompileDCA() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.dca(.A)]))
        XCTAssertEqual(makeListing(compiler), """
DCA
DCA A
""")
    }
    
    func testCompileAND() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.and(.A)]))
        XCTAssertEqual(makeListing(compiler), """
AND
AND A
""")
    }
    
    func testCompileOR() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.or(.A)]))
        XCTAssertEqual(makeListing(compiler), """
OR
OR A
""")
    }
    
    func testCompileXOR() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.xor(.A)]))
        XCTAssertEqual(makeListing(compiler), """
XOR
XOR A
""")
    }
    
    func testCompileLSL() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.lsl(.A)]))
        XCTAssertEqual(makeListing(compiler), """
LSL
LSL A
""")
    }
    
    func testCompileNEG() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.neg(.A)]))
        XCTAssertEqual(makeListing(compiler), """
NEG
NEG A
""")
    }
    
    func testCompileCMP() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.cmp]))
        XCTAssertEqual(makeListing(compiler), """
CMP
CMP
""")
    }
    
    func testCompileFailsDueToDuplicateLabel() throws {
        let compiler = PopCompiler()
        XCTAssertThrowsError(try compiler.compile(pop: [.label("foo"), .label("foo")])) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "label redefines existing symbol: `foo'")
        }
    }
    
    func testCompileLabelAtZero() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.label("foo")]))
        XCTAssertEqual(compiler.labelTable["foo"], 0)
    }
    
    func testCompileLabelAtOne() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.nop, .label("foo")]))
        XCTAssertEqual(compiler.labelTable["foo"], 1)
    }
    
    func testCompileLIXY() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.lixy("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
""")
    }
    
    func testCompileFailsDueToUndefinedLabel() throws {
        let compiler = PopCompiler()
        XCTAssertThrowsError(try compiler.compile(pop: [.jalr("foo")])) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot resolve label `foo'")
        }
    }
    
    func testCompileJALR() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jalr("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JALR
NOP
NOP
""")
    }
    
    func testCompileExplicitJalr() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.explicitJalr]))
        XCTAssertEqual(makeListing(compiler), """
JALR
NOP
NOP
""")
    }
    
    func testCompileJMP() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jmp("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JMP
NOP
NOP
""")
    }
    
    func testCompileJC() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jc("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JC
NOP
NOP
""")
    }
    
    func testCompileJNC() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jnc("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JNC
NOP
NOP
""")
    }
    
    func testCompileJE() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.je("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JE
NOP
NOP
""")
    }
    
    func testCompileJNE() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jne("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JNE
NOP
NOP
""")
    }
    
    func testCompileJG() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jg("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JG
NOP
NOP
""")
    }
    
    func testCompileJLE() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jle("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JLE
NOP
NOP
""")
    }
    
    func testCompileJL() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jl("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JL
NOP
NOP
""")
    }
    
    func testCompileJGE() throws {
        let compiler = PopCompiler()
        compiler.labelTable["foo"] = 0xabcd
        XCTAssertNoThrow(try compiler.compile(pop: [.jge("foo")]))
        XCTAssertEqual(makeListing(compiler), """
LI X, 0xab
LI Y, 0xcd
JGE
NOP
NOP
""")
    }
    
    func testCompileBLT() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.blt(.P, .M)]))
        XCTAssertEqual(makeListing(compiler), "BLT P, M")
    }
    
    func testCompileBLTI() throws {
        let compiler = PopCompiler()
        XCTAssertNoThrow(try compiler.compile(pop: [.blti(.M, 0xcc)]))
        XCTAssertEqual(makeListing(compiler), "BLTI M, 0xcc")
    }
}
