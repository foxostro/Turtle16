//
//  PopDeadStoreEliminationOptimizationPassTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class PopDeadStoreEliminationOptimizationPassTests: XCTestCase {
    func testOptimizeEmptyProgram() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = []
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [])
    }
    
    func testOptimizeSingleNOP() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [.nop]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [.nop])
    }
    
    func testADDdependsOnTheValueOfAandBatLeast() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.markAllRegisters(.notNeeded)
        _ = optimizer.rewrite(.add(.A))
        XCTAssertEqual(optimizer.registers[.A], .needed)
        XCTAssertEqual(optimizer.registers[.B], .needed)
        XCTAssertEqual(optimizer.registers[.D], .notNeeded)
        XCTAssertEqual(optimizer.registers[.X], .notNeeded)
        XCTAssertEqual(optimizer.registers[.Y], .notNeeded)
        XCTAssertEqual(optimizer.registers[.U], .notNeeded)
        XCTAssertEqual(optimizer.registers[.V], .notNeeded)
    }
    
    func testAccessToMemoryIntroducesDependencyOnUV() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.markAllRegisters(.notNeeded)
        _ = optimizer.rewrite(.add(.M))
        XCTAssertEqual(optimizer.registers[.A], .needed)
        XCTAssertEqual(optimizer.registers[.B], .needed)
        XCTAssertEqual(optimizer.registers[.D], .notNeeded)
        XCTAssertEqual(optimizer.registers[.X], .notNeeded)
        XCTAssertEqual(optimizer.registers[.Y], .notNeeded)
        XCTAssertEqual(optimizer.registers[.U], .needed)
        XCTAssertEqual(optimizer.registers[.V], .needed)
    }
    
    func testAccessToPeripheralsIntroducesDependencyOnXY() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.markAllRegisters(.notNeeded)
        _ = optimizer.rewrite(.add(.P))
        XCTAssertEqual(optimizer.registers[.A], .needed)
        XCTAssertEqual(optimizer.registers[.B], .needed)
        XCTAssertEqual(optimizer.registers[.D], .notNeeded)
        XCTAssertEqual(optimizer.registers[.X], .needed)
        XCTAssertEqual(optimizer.registers[.Y], .needed)
        XCTAssertEqual(optimizer.registers[.U], .notNeeded)
        XCTAssertEqual(optimizer.registers[.V], .notNeeded)
    }
    
    func testMovMayDependOnUVandXYtoo_1() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.markAllRegisters(.notNeeded)
        _ = optimizer.rewrite(.mov(.M, .P))
        XCTAssertEqual(optimizer.registers[.A], .notNeeded)
        XCTAssertEqual(optimizer.registers[.B], .notNeeded)
        XCTAssertEqual(optimizer.registers[.D], .notNeeded)
        XCTAssertEqual(optimizer.registers[.X], .needed)
        XCTAssertEqual(optimizer.registers[.Y], .needed)
        XCTAssertEqual(optimizer.registers[.U], .needed)
        XCTAssertEqual(optimizer.registers[.V], .needed)
    }
    
    func testMovMayDependOnUVandXYtoo_2() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.markAllRegisters(.notNeeded)
        _ = optimizer.rewrite(.mov(.P, .M))
        XCTAssertEqual(optimizer.registers[.A], .notNeeded)
        XCTAssertEqual(optimizer.registers[.B], .notNeeded)
        XCTAssertEqual(optimizer.registers[.D], .notNeeded)
        XCTAssertEqual(optimizer.registers[.X], .needed)
        XCTAssertEqual(optimizer.registers[.Y], .needed)
        XCTAssertEqual(optimizer.registers[.U], .needed)
        XCTAssertEqual(optimizer.registers[.V], .needed)
    }
    
    func testOptimizeSingleLI() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [.li(.A, 0)]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [.li(.A, 0)])
    }
    
    func testOneLIMaySquashValueSetEarlier() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0),
            .li(.A, 1)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .li(.A, 1)
        ])
    }
    
    func testOneMovMaySquashValueSetEarlier() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0),
            .mov(.A, .B)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .mov(.A, .B)
        ])
    }
    
    func testOneMovMaySquashValueSetEarlier_AndReadingFromMemoryIsNotASideEffect() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .mov(.A, .M),
            .mov(.A, .B)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .mov(.A, .B)
        ])
    }
    
    func testStoringToMemoryIsASideEffectThatMustBePreserved() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .mov(.M, .A)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .mov(.M, .A)
        ])
    }
    
    func testStoringToPeripheralIsASideEffectThatMustBePreserved() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .mov(.P, .A)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .mov(.P, .A)
        ])
    }
    
    func testSpecialHandlingForSpecialConstructUV() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 1),
            .li(.V, 2),
            .li(.UV, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .fake,
            .li(.UV, 0)
        ])
    }
    
    func testArithmeticInstructionWithExplicitlyNoOutputMeansWeCareAboutSideEffects() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .sub(.NONE)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .sub(.NONE)
        ])
    }
}
