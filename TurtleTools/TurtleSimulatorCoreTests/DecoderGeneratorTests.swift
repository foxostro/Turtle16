//
//  DecoderGeneratorTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 1/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

final class DecoderGeneratorTests: XCTestCase {
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
    let LeftOperandIsUnused = 21
    let RightOperandIsUnused = 22

    fileprivate func makeCPU() -> SchematicLevelCPUModel {
        let cpu = SchematicLevelCPUModel()
        let rom = OpcodeDecoderROM()
        rom.opcodeDecodeROM = DecoderGenerator().generate()
        cpu.stageID.decoder = rom
        return cpu
    }

    func testGeneratesExactly512Entries() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        XCTAssertEqual(decoder.count, 512)
    }

    func testEntriesAreTwentyThreeBitsWide() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for entry in decoder {
            XCTAssertLessThanOrEqual(entry, (1 << 23) - 1)
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
            XCTAssertEqual(controlWord, ID.nopControlWord_ID)
        }
    }

    func testOpcodeHlt() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeHlt) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 0)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 1)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeLoad() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeLoad) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 0)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeStore() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeStore) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b10)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 0)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeLoadImmediate() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeLi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b10)
            //            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            //            XCTAssertEqual((controlWord >> C0) & 1, 1)
            //            XCTAssertEqual((controlWord >> I0) & 7, 0b111)
            //            XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 1)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeLoadUpperImmediate() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeLui) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            //            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            //            XCTAssertEqual((controlWord >> C0) & 1, 1)
            //            XCTAssertEqual((controlWord >> I0) & 7, 0b11)
            //            XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 1)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeCmp() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeCmp) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
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
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeAdd() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAdd) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b011)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeSub() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeSub) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeAnd() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAnd) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b110)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeOr() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeOr) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b101)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeXor() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeXor) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b00)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b100)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 0)
        }
    }

    func testOpcodeNot() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeNot) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            //            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b001)
            XCTAssertEqual((controlWord >> RS0) & 3, 0b01)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeCmpi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeCmpi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 1)
            XCTAssertEqual((controlWord >> I0) & 7, 0b010)
            XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 1)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeAddi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAddi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b011)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeSubi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeSubi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeAndi() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeAndi) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b110)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeOri() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeOri) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b101)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeXori() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeXori) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 0)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b100)
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
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeJmp() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeJmp) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b101)
            XCTAssertEqual((controlWord >> RS0) & 3, 0b10)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 1)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 1)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeJr() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeJr) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            //            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b11)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 1)
            XCTAssertEqual((controlWord >> WriteBackSrcFlag) & 1, 1)
            XCTAssertEqual((controlWord >> WRL) & 1, 1)
            XCTAssertEqual((controlWord >> WRH) & 1, 1)
            XCTAssertEqual((controlWord >> WBEN) & 1, 1)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    func testOpcodeJalr() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()
        for index in generator.indicesForAllConditions(DecoderGenerator.opcodeJalr) {
            let controlWord = decoder[index]
            XCTAssertEqual((controlWord >> HLT) & 1, 1)
            XCTAssertEqual((controlWord >> SelStoreOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> SelRightOpA) & 3, 0b01)
            XCTAssertEqual((controlWord >> FI) & 1, 1)
            XCTAssertEqual((controlWord >> C0) & 1, 0)
            XCTAssertEqual((controlWord >> I0) & 7, 0b011)
            XCTAssertEqual((controlWord >> RS0) & 3, 0b11)
            XCTAssertEqual((controlWord >> J) & 1, 0)
            XCTAssertEqual((controlWord >> JABS) & 1, 0)
            XCTAssertEqual((controlWord >> MemLoad) & 1, 1)
            XCTAssertEqual((controlWord >> MemStore) & 1, 1)
            XCTAssertEqual((controlWord >> AssertStoreOp) & 1, 0)
            XCTAssertEqual(~(controlWord >> WriteBackSrcFlag) & 1, 0)
            XCTAssertEqual((controlWord >> WRL) & 1, 0)
            XCTAssertEqual((controlWord >> WRH) & 1, 0)
            XCTAssertEqual((controlWord >> WBEN) & 1, 0)
            XCTAssertEqual((controlWord >> LeftOperandIsUnused) & 1, 0)
            XCTAssertEqual((controlWord >> RightOperandIsUnused) & 1, 1)
        }
    }

    fileprivate func isRelativeJump(_ controlBits: UInt) -> Bool {
        guard (controlBits >> HLT) & 1 == 1 else {
            return false
        }
        guard (controlBits >> SelStoreOpA) & 3 == 0b11 else {
            return false
        }
        guard (controlBits >> SelRightOpA) & 3 == 0b11 else {
            return false
        }
        guard (controlBits >> FI) & 1 == 1 else {
            return false
        }
        guard (controlBits >> C0) & 1 == 0 else {
            return false
        }
        guard (controlBits >> I0) & 7 == 0b011 else {
            return false
        }
        guard (controlBits >> RS0) & 3 == 0b10 else {
            return false
        }
        guard (controlBits >> J) & 1 == 0 else {
            return false
        }
        guard (controlBits >> JABS) & 1 == 1 else {
            return false
        }
        guard (controlBits >> MemLoad) & 1 == 1 else {
            return false
        }
        guard (controlBits >> MemStore) & 1 == 1 else {
            return false
        }
        guard (controlBits >> AssertStoreOp) & 1 == 1 else {
            return false
        }
        guard (controlBits >> WriteBackSrcFlag) & 1 == 1 else {
            return false
        }
        guard (controlBits >> WRL) & 1 == 1 else {
            return false
        }
        guard (controlBits >> WRH) & 1 == 1 else {
            return false
        }
        guard (controlBits >> WBEN) & 1 == 1 else {
            return false
        }
        return true
    }

    func testOpcodeBeq() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for v in bits {
                    let indexForFailCondition = generator.makeIndex(
                        n: n,
                        c: c,
                        z: 0,
                        v: v,
                        opcode: DecoderGenerator.opcodeBeq
                    )
                    XCTAssertEqual(decoder[indexForFailCondition], ID.nopControlWord_ID)

                    let indexForPassCondition = generator.makeIndex(
                        n: n,
                        c: c,
                        z: 1,
                        v: v,
                        opcode: DecoderGenerator.opcodeBeq
                    )
                    let ctlHighZ = decoder[indexForPassCondition]
                    XCTAssertTrue(isRelativeJump(ctlHighZ))
                } // v
            } // c
        } // n
    }

    func testOpcodeBne() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for v in bits {
                    let indexForFailCondition = generator.makeIndex(
                        n: n,
                        c: c,
                        z: 1,
                        v: v,
                        opcode: DecoderGenerator.opcodeBne
                    )
                    XCTAssertEqual(decoder[indexForFailCondition], ID.nopControlWord_ID)

                    let indexForPassCondition = generator.makeIndex(
                        n: n,
                        c: c,
                        z: 0,
                        v: v,
                        opcode: DecoderGenerator.opcodeBne
                    )
                    let ctlHighZ = decoder[indexForPassCondition]
                    XCTAssertTrue(isRelativeJump(ctlHighZ))
                } // v
            } // c
        } // n
    }

    func testBlt() {
        let cpu = makeCPU()
        cpu.instructions = [
            0b00000000_00000000, // NOP
            0b11010011_11111111 // BLT 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BLT jumps on N!=V
                        if (n == 0 && v == 1) || (n == 1 && v == 0) {
                            XCTAssertEqual(1026, cpu.pc)
                        }
                        else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    } // v
                } // z
            } // c
        } // n
    }

    func testBgt() {
        let cpu = makeCPU()
        cpu.instructions = [
            0b00000000_00000000, // NOP
            0b11011011_11111111 // BGT 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BGT jumps on (Z==0) && (N==V)
                        if z == 0, (n == 0 && v == 0) || (n == 1 && v == 1) {
                            XCTAssertEqual(1026, cpu.pc)
                        }
                        else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    } // v
                } // z
            } // c
        } // n
    }

    func testBltu() {
        let cpu = makeCPU()
        cpu.instructions = [
            0b00000000_00000000, // NOP
            0b11100011_11111111 // BLTU 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BLTU jumps on C==0
                        if c == 0 {
                            XCTAssertEqual(1026, cpu.pc)
                        }
                        else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    } // v
                } // z
            } // c
        } // n
    }

    func testBgtu() {
        let cpu = makeCPU()
        cpu.instructions = [
            0b00000000_00000000, // NOP
            0b11101011_11111111 // BGTU 1023
        ]

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for c in bits {
                for z in bits {
                    for v in bits {
                        cpu.reset()
                        cpu.n = n
                        cpu.c = c
                        cpu.v = v
                        cpu.z = z

                        XCTAssertEqual(0, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(1, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(2, cpu.pc)
                        cpu.step()
                        XCTAssertEqual(3, cpu.pc)
                        cpu.step()

                        // BGTU jumps on C==1 && Z==0
                        if c == 1, z == 0 {
                            XCTAssertEqual(1026, cpu.pc)
                        }
                        else {
                            XCTAssertEqual(4, cpu.pc)
                        }
                    } // v
                } // z
            } // c
        } // n
    }

    func testOpcodeAdc() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for z in bits {
                for v in bits {
                    let indexForFailCondition = generator.makeIndex(
                        n: n,
                        c: 0,
                        z: z,
                        v: v,
                        opcode: DecoderGenerator.opcodeAdc
                    )
                    let controlWordFail = decoder[indexForFailCondition]
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
                    XCTAssertEqual((controlWordFail >> LeftOperandIsUnused) & 1, 0)
                    XCTAssertEqual((controlWordFail >> RightOperandIsUnused) & 1, 0)

                    let indexForPassCondition = generator.makeIndex(
                        n: n,
                        c: 1,
                        z: z,
                        v: v,
                        opcode: DecoderGenerator.opcodeAdc
                    )
                    let controlWordPass = decoder[indexForPassCondition]
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
                    XCTAssertEqual((controlWordPass >> LeftOperandIsUnused) & 1, 0)
                    XCTAssertEqual((controlWordPass >> RightOperandIsUnused) & 1, 0)
                } // v
            } // z
        } // n
    }

    func testOpcodeSbc() throws {
        let generator = DecoderGenerator()
        let decoder = generator.generate()

        let bits = [UInt(0), UInt(1)]
        for n in bits {
            for z in bits {
                for v in bits {
                    let indexForFailCondition = generator.makeIndex(
                        n: n,
                        c: 0,
                        z: z,
                        v: v,
                        opcode: DecoderGenerator.opcodeSbc
                    )
                    let controlWordFail = decoder[indexForFailCondition]
                    XCTAssertEqual((controlWordFail >> HLT) & 1, 1)
                    XCTAssertEqual((controlWordFail >> SelStoreOpA) & 3, 0b11)
                    XCTAssertEqual((controlWordFail >> SelRightOpA) & 3, 0b00)
                    XCTAssertEqual((controlWordFail >> FI) & 1, 0)
                    XCTAssertEqual((controlWordFail >> C0) & 1, 1)
                    XCTAssertEqual((controlWordFail >> I0) & 7, 0b010)
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
                    XCTAssertEqual((controlWordFail >> LeftOperandIsUnused) & 1, 0)
                    XCTAssertEqual((controlWordFail >> RightOperandIsUnused) & 1, 0)

                    let indexForPassCondition = generator.makeIndex(
                        n: n,
                        c: 1,
                        z: z,
                        v: v,
                        opcode: DecoderGenerator.opcodeSbc
                    )
                    let controlWordPass = decoder[indexForPassCondition]
                    XCTAssertEqual((controlWordPass >> HLT) & 1, 1)
                    XCTAssertEqual((controlWordPass >> SelStoreOpA) & 3, 0b11)
                    XCTAssertEqual((controlWordPass >> SelRightOpA) & 3, 0b00)
                    XCTAssertEqual((controlWordPass >> FI) & 1, 0)
                    XCTAssertEqual((controlWordPass >> C0) & 1, 0)
                    XCTAssertEqual((controlWordPass >> I0) & 7, 0b010)
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
                    XCTAssertEqual((controlWordPass >> LeftOperandIsUnused) & 1, 0)
                    XCTAssertEqual((controlWordPass >> RightOperandIsUnused) & 1, 0)
                } // v
            } // z
        } // n
    }
}
