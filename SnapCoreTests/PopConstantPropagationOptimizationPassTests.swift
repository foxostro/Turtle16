//
//  PopConstantPropagationOptimizationPassTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class PopConstantPropagationOptimizationPassTests: XCTestCase {
    func testOptimizeEmptyProgram() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = []
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [])
    }
    
    func testLoadingAnImmediateUpdatesKnowledgeOfRegisterContents() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0xaa)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.A], .known(0xaa))
    }
    
    func testMovingARegisterMayUpdateKnowledgeOfRegisterContents() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0xaa),
            .mov(.B, .A),
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.A], .known(0xaa))
        XCTAssertEqual(optimizer.registers[.B], .known(0xaa))
    }
    
    func testMovingARegisterMayRemoveKnowledgeOfRegisterContents() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0xaa),
            .mov(.A, .B),
        ]
        optimizer.optimize()
        let actual = optimizer.registers[.A]
        XCTAssertEqual(actual, .unknown)
    }
    
    func testStoringToMemoryUpdatesKnowledgeOfMemoryContents() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 0xab),
            .li(.V, 0xcd),
            .li(.M, 0xcc),
            .mov(.A, .M)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.memory[0xabcd], .known(0xcc))
        XCTAssertEqual(optimizer.registers[.A], .known(0xcc))
    }
    
    func testLoadingTheSpecialConstructUV() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.UV, 0xaa)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.U], .known(0xaa))
        XCTAssertEqual(optimizer.registers[.V], .known(0xaa))
    }
    
    func testWeCannotSayAnythingAboutStoresToPeripheralDevices() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.P, 0xaa),
            .mov(.A, .P)
        ]
        optimizer.optimize()
        print(optimizer.registers.values)
        XCTAssertTrue(optimizer.registers.values.allSatisfy({ $0 == .unknown }))
        XCTAssertTrue(optimizer.memory.allSatisfy({ $0 == .unknown }))
    }
    
    func testOmitLoadImmediateWhenWeCanDetermineItDoesNothing() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0xaa),
            .li(.A, 0xaa)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.optimizedProgram, [
            .li(.A, 0xaa),
            .fake
        ])
    }
    
    func testOmitMovWhenWeCanDetermineItDoesNothing() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0xaa),
            .li(.B, 0xaa),
            .mov(.A, .B)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.optimizedProgram, [
            .li(.A, 0xaa),
            .li(.B, 0xaa),
            .fake
        ])
    }
    
    func testReplaceMovesWithLoadImmediateWhenWeCanStaticallyDetermineTheRegisterContents() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0xaa),
            .mov(.B, .A)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.optimizedProgram, [
            .li(.A, 0xaa),
            .li(.B, 0xaa)
        ])
    }
    
    func testIncrementUVWithINUV() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 0x00),
            .li(.V, 0xff),
            .inuv
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.U], .known(0x01))
        XCTAssertEqual(optimizer.registers[.V], .known(0x00))
    }
    
    func testSometimesWeCanReasonAboutINUVWithoutKnowingTheHighByte() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.V, 0xff),
            .inuv
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.U], .unknown)
        XCTAssertEqual(optimizer.registers[.V], .known(0x00))
    }
    
    func testIncrementXYWithINXY() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0x00),
            .li(.Y, 0xff),
            .inxy
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .known(0x01))
        XCTAssertEqual(optimizer.registers[.Y], .known(0x00))
    }
    
    func testSometimesWeCanReasonAboutINXYWithoutKnowingTheHighByte() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.Y, 0xff),
            .inxy
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .unknown)
        XCTAssertEqual(optimizer.registers[.Y], .known(0x00))
    }
    
    func testIncrementUVWithBLTI() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 0x00),
            .li(.V, 0xff),
            .blti(.M, 0xaa)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.U], .known(0x01))
        XCTAssertEqual(optimizer.registers[.V], .known(0x00))
        XCTAssertEqual(optimizer.memory[0x0100], .known(0xaa))
    }
    
    func testBLTIInvalidatesRegisters_XY() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0x00),
            .blti(.P, 0)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .unknown)
        XCTAssertEqual(optimizer.registers[.Y], .unknown)
    }
    
    func testBLTIInvalidatesRegistersAndMemory_UV() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 0x00),
            .blti(.M, 0)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.U], .unknown)
        XCTAssertEqual(optimizer.registers[.V], .unknown)
        XCTAssertTrue(optimizer.memory.allSatisfy({ $0 == .unknown }))
    }
    
    func testIncrementXYWithBLTI() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0x00),
            .li(.Y, 0xff),
            .blti(.P, 0)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .known(0x01))
        XCTAssertEqual(optimizer.registers[.Y], .known(0x00))
    }
    
    func testIncrementUVXYWithBLT_storeToMemory() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0x00),
            .li(.Y, 0xff),
            .li(.U, 0x00),
            .li(.V, 0xff),
            .li(.M, 0xaa),
            .blt(.M, .P)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .known(0x01))
        XCTAssertEqual(optimizer.registers[.Y], .known(0x00))
        XCTAssertEqual(optimizer.registers[.U], .known(0x01))
        XCTAssertEqual(optimizer.registers[.V], .known(0x00))
        XCTAssertTrue(optimizer.memory.allSatisfy({ $0 == .unknown }))
    }
    
    func testIncrementUVXYWithBLT_loadFromMemory() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0x00),
            .li(.Y, 0xff),
            .li(.U, 0x00),
            .li(.V, 0xff),
            .li(.M, 0xaa),
            .blt(.P, .M)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .known(0x01))
        XCTAssertEqual(optimizer.registers[.Y], .known(0x00))
        XCTAssertEqual(optimizer.registers[.U], .known(0x01))
        XCTAssertEqual(optimizer.registers[.V], .known(0x00))
        XCTAssertEqual(optimizer.memory[0x00ff], .known(0xaa))
    }
    
    func testArithmeticInstructionsInvalidateRegisters() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 1),
            .add(.A)
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.A], .unknown)
    }
    
    func testArithmeticInstructionsMayInvalidateAllOfMemory() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.memory[0xbcd] = .known(0x2a)
        optimizer.unoptimizedProgram = [
            .add(.M)
        ]
        optimizer.optimize()
        XCTAssertTrue(optimizer.memory.allSatisfy({ $0 == .unknown }))
    }
    
    func testBranchToLabelWillInvalidateXY() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0),
            .li(.Y, 0),
            .jmp("")
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .unknown)
        XCTAssertEqual(optimizer.registers[.Y], .unknown)
    }
    
    func testLIXYWillInvalidateXY() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0),
            .li(.Y, 0),
            .lixy("")
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.registers[.X], .unknown)
        XCTAssertEqual(optimizer.registers[.Y], .unknown)
    }
    
    func testCopyLabelWillInvalidateTheDestinationLocationInMemory() throws {
        let optimizer = PopConstantPropagationOptimizationPass()
        optimizer.memory[0xabcd] = .known(0xaa)
        optimizer.memory[0xabce] = .known(0xbb)
        optimizer.unoptimizedProgram = [
            .copyLabel(0xabcd, "")
        ]
        optimizer.optimize()
        XCTAssertEqual(optimizer.memory[0xabcd], .unknown)
        XCTAssertEqual(optimizer.memory[0xabce], .unknown)
    }
}
