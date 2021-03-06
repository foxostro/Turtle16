//
//  DecoderGeneratorTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 1/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class DecoderGeneratorTests: XCTestCase {
    let HLT = 0
    let SelStoreOpA = 1
    let SelStoreOpB = 2
    let SelRightOpA = 3
    let SelRightOpB = 4
    let FI = 5
    let C0 = 6
    let I0 = 7
    let I1 = 8
    let I2 = 9
    let RS0 = 10
    let RS1 = 11
    let J = 12
    let JABS = 13
    let MemLoad = 14
    let MemStore = 15
    let AssertStoreOp = 16
    let WriteBackSrcFlag = 17
    let WRL = 18
    let WRH = 19
    let WBEN = 20
    
    func testGeneratesExactly512Entries() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        XCTAssertEqual(decoder.count, 512)
    }
    
    func testEntriesAreTwentyOneBitsWide() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for entry in decoder {
            XCTAssertLessThan(entry, (1<<21)-1)
        }
    }
    
    func testAllEntriesForResetResolveToNOP() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        let indices = generator.indicesForReset()
        for index in indices {
            XCTAssertEqual(decoder[index], 0)
        }
    }
    
    func testManyOpcodesAreNotConditional() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        let unconditionalOpcodes = [
            DecoderGenerator.opcodeNop,
            DecoderGenerator.opcodeHlt,
            DecoderGenerator.opcodeLoad,
            DecoderGenerator.opcodeStore,
            DecoderGenerator.opcodeLi,
            DecoderGenerator.opcodeLui,
            DecoderGenerator.opcodeCmp,
            DecoderGenerator.opcodeAdd,
            DecoderGenerator.opcodeSub,
            DecoderGenerator.opcodeAnd,
            DecoderGenerator.opcodeOr,
            DecoderGenerator.opcodeXor,
            DecoderGenerator.opcodeNot,
            DecoderGenerator.opcodeCmpi,
            DecoderGenerator.opcodeAddi,
            DecoderGenerator.opcodeSubi,
            DecoderGenerator.opcodeAndi,
            DecoderGenerator.opcodeOri,
            DecoderGenerator.opcodeXori,
            DecoderGenerator.opcodeJmp,
            DecoderGenerator.opcodeJr,
            DecoderGenerator.opcodeJalr
        ]
        for opcode in unconditionalOpcodes {
            let indices = generator.indicesForAllConditions(opcode)
            for index in indices {
                XCTAssertEqual(decoder[index], decoder[indices.first!])
            }
        }
    }
    
    func testOpcodeNop() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeNop) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpB) & 1, 0)
            XCTAssertEqual((controlWord >> SelRightOpA) & 1, 0)
            XCTAssertEqual((controlWord >> SelRightOpB) & 1, 0)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 1, 0)
            XCTAssertEqual((controlWord >> I1) & 1, 0)
            XCTAssertEqual((controlWord >> I2) & 1, 0)
            XCTAssertEqual((controlWord >> RS0) & 1, 0)
            XCTAssertEqual((controlWord >> RS1) & 1, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
        }
    }
    
    func testOpcodeHlt() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeHlt) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
        }
    }
    
    func testOpcodeLoad() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeLoad) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 1)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeStore() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeStore) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b10)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
        }
    }
    
    func testOpcodeLoadImmediate() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeLi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual(~(controlWord >> SelStoreOpA) & 3, 0b10)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeLoadUpperImmediate() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeLui) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual(~(controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeCmp() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeCmp) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 1)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b010)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
        }
    }
    
    func testOpcodeAdd() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAdd) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeSub() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeSub) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 1)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b010)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeAnd() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAnd) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b110)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeOr() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeOr) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b101)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeXor() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeXor) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b100)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeNot() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeNot) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b001)
            XCTAssertEqual(~(controlWord >> RS0) & 3, 0b01)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeCmpi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeCmpi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 1)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b010)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
        }
    }
    
    func testOpcodeAddi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAddi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeSubi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeSubi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 1)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b010)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeAndi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAndi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b110)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeOri() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeOri) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b101)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeXori() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeXori) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b100)
            XCTAssertEqual((controlWord >> RS0) & 3, 0)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeJmp() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeJmp) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b101)
            XCTAssertEqual(~(controlWord >> RS0) & 3, 0b10)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
        }
    }
    
    func testOpcodeJr() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeJr) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b011)
            XCTAssertEqual(~(controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
        }
    }
    
    func testOpcodeJalr() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeJalr) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0)
            XCTAssertEqual(~(controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual(~(controlWord >> C0) & 1, 0)
            XCTAssertEqual(~(controlWord >> I0) & 7, 0b011)
            XCTAssertEqual(~(controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual(~(controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
        }
    }
    
    func testOpcodeBeq() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeBeq)
        XCTAssertEqual(decoder[indexForFailCondition], 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 0, z: 1, ovf: 0, opcode: DecoderGenerator.opcodeBeq)
        let ctlHighZ = ~decoder[indexForPassCondition] & ((1<<21)-1)
        XCTAssertTrue(isRelativeJump(ctlHighZ))
    }
    
    fileprivate func isRelativeJump(_ ctlHighZ: UInt) -> Bool {
        guard (ctlHighZ >> HLT) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> SelStoreOpA) & 3 == 0b11 else {
            return false
        }
        guard (ctlHighZ >> SelRightOpA) & 3 == 0b11 else {
            return false
        }
        guard (ctlHighZ >> FI) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> C0) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> I0) & 7 == 0b101 else {
            return false
        }
        guard (ctlHighZ >> RS0) & 3 == 0b11 else {
            return false
        }
        guard (ctlHighZ >> J) & 1 == 0 else {
            return false
        }
        guard (ctlHighZ >> JABS) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> MemLoad) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> MemStore) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> AssertStoreOp) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> WriteBackSrcFlag) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> WRL) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> WRH) & 1 == 1 else {
            return false
        }
        guard (ctlHighZ >> WBEN) & 1 == 1 else {
            return false
        }
        return true
    }
    
    func testOpcodeBne() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 0, z: 1, ovf: 0, opcode: DecoderGenerator.opcodeBne)
        XCTAssertEqual(decoder[indexForFailCondition], 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeBne)
        let ctlHighZ = ~decoder[indexForPassCondition] & ((1<<21)-1)
        XCTAssertTrue(isRelativeJump(ctlHighZ))
    }
    
    func testOpcodeBlt() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeBlt)
        XCTAssertEqual(decoder[indexForFailCondition], 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 1, opcode: DecoderGenerator.opcodeBlt)
        let ctlHighZ = ~decoder[indexForPassCondition] & ((1<<21)-1)
        XCTAssertTrue(isRelativeJump(ctlHighZ))
    }
    
    func testOpcodeBge() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 1, opcode: DecoderGenerator.opcodeBge)
        XCTAssertEqual(decoder[indexForFailCondition], 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeBge)
        let ctlHighZ = ~decoder[indexForPassCondition] & ((1<<21)-1)
        XCTAssertTrue(isRelativeJump(ctlHighZ))
    }
    
    func testOpcodeBltu() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeBltu)
        XCTAssertEqual(decoder[indexForFailCondition], 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 1, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeBltu)
        let ctlHighZ = ~decoder[indexForPassCondition] & ((1<<21)-1)
        XCTAssertTrue(isRelativeJump(ctlHighZ))
    }
    
    func testOpcodeBgeu() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 1, z: 0, ovf: 1, opcode: DecoderGenerator.opcodeBgeu)
        XCTAssertEqual(decoder[indexForFailCondition], 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeBgeu)
        let ctlHighZ = ~decoder[indexForPassCondition] & ((1<<21)-1)
        XCTAssertTrue(isRelativeJump(ctlHighZ))
    }
    
    func testOpcodeAdc() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeAdc)
        let controlWordFail = ~decoder[indexForFailCondition] & ((1<<21)-1)
        XCTAssertEqual((controlWordFail >> HLT) & 1, 1)
        XCTAssertEqual((controlWordFail >> SelStoreOpA) & 3, 0b11)
        XCTAssertEqual((controlWordFail >> SelRightOpA) & 3, 0b00)
        XCTAssertEqual((controlWordFail >> FI) & 1, 0)
        XCTAssertEqual((controlWordFail >> C0) & 1, 0)
        XCTAssertEqual((controlWordFail >> I0) & 7, 0b011)
        XCTAssertEqual((controlWordFail >> RS0) & 3, 0b11)
        XCTAssertEqual((controlWordFail >> J) & 1, 1)
        XCTAssertEqual((controlWordFail >> JABS) & 1, 1)
        XCTAssertEqual((controlWordFail >> MemLoad) & 1, 1)
        XCTAssertEqual((controlWordFail >> MemStore) & 1, 1)
        XCTAssertEqual((controlWordFail >> AssertStoreOp) & 1, 1)
        XCTAssertEqual((controlWordFail >> WriteBackSrcFlag) & 1, 0)
        XCTAssertEqual((controlWordFail >> WRL) & 1, 0)
        XCTAssertEqual((controlWordFail >> WRH) & 1, 0)
        XCTAssertEqual((controlWordFail >> WBEN) & 1, 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 1, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeAdc)
        let controlWordPass = ~decoder[indexForPassCondition] & ((1<<21)-1)
        XCTAssertEqual((controlWordPass >> HLT) & 1, 1)
        XCTAssertEqual((controlWordPass >> SelStoreOpA) & 3, 0b11)
        XCTAssertEqual((controlWordPass >> SelRightOpA) & 3, 0b00)
        XCTAssertEqual((controlWordPass >> FI) & 1, 0)
        XCTAssertEqual((controlWordPass >> C0) & 1, 1)
        XCTAssertEqual((controlWordPass >> I0) & 7, 0b011)
        XCTAssertEqual((controlWordPass >> RS0) & 3, 0b11)
        XCTAssertEqual((controlWordPass >> J) & 1, 1)
        XCTAssertEqual((controlWordPass >> JABS) & 1, 1)
        XCTAssertEqual((controlWordPass >> MemLoad) & 1, 1)
        XCTAssertEqual((controlWordPass >> MemStore) & 1, 1)
        XCTAssertEqual((controlWordPass >> AssertStoreOp) & 1, 1)
        XCTAssertEqual((controlWordPass >> WriteBackSrcFlag) & 1, 0)
        XCTAssertEqual((controlWordPass >> WRL) & 1, 0)
        XCTAssertEqual((controlWordPass >> WRH) & 1, 0)
        XCTAssertEqual((controlWordPass >> WBEN) & 1, 0)
    }
    
    func testOpcodeSbc() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        
        let indexForFailCondition = generator.makeIndex(rst: 1, carry: 0, z: 0, ovf: 1, opcode: DecoderGenerator.opcodeSbc)
        XCTAssertEqual(decoder[indexForFailCondition], 0)
        
        let indexForPassCondition = generator.makeIndex(rst: 1, carry: 1, z: 0, ovf: 0, opcode: DecoderGenerator.opcodeSbc)
        let controlWord = ~decoder[indexForPassCondition] & ((1<<21)-1)
        
        XCTAssertEqual((controlWord >> HLT) & 1, 1)
        XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
        XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b00)
        XCTAssertEqual((controlWord >> FI) & 1, 0)
        XCTAssertEqual((controlWord >> C0) & 1, 1)
        XCTAssertEqual((controlWord >> I0) & 7, 0b010)
        XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
        XCTAssertEqual((controlWord >> J) & 1, 1)
        XCTAssertEqual((controlWord >> JABS) & 1, 1)
        XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
        XCTAssertEqual((controlWord >> MemStore) & 1, 1)
        XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
        XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
        XCTAssertEqual((controlWord >> WRL) & 1, 0)
        XCTAssertEqual((controlWord >> WRH) & 1, 0)
        XCTAssertEqual((controlWord >> WBEN) & 1, 0)
    }
}
