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
    
    func testCantImproveOnTwoNOPs() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [.nop, .nop]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [.nop, .nop])
    }
    
    func testCantImproveOnOneLI() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 1)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.A, 1)
        ])
    }
    
    func testRemoveRedundantLI() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 1),
            .li(.A, 1)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .li(.A, 1)
        ])
    }
    
    func testCannotRemoveStoreToMemory() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.M, 1),
            .li(.M, 1)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.M, 1),
            .li(.M, 1)
        ])
    }
    
    func testRemoveRedundantMOV() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .mov(.A, .B),
            .li(.A, 1)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .li(.A, 1)
        ])
    }
    
    func testCannotRemoveReadFromPeripheralDevice() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .mov(.A, .P),
            .li(.A, 1)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .mov(.A, .P),
            .li(.A, 1)
        ])
    }
    
    func testStoreToMemoryDependsOnUV() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 0),
            .li(.V, 0),
            .mov(.M, .A),
            .li(.U, 0),
            .li(.V, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.U, 0),
            .li(.V, 0),
            .mov(.M, .A),
            .li(.U, 0),
            .li(.V, 0)
        ])
    }
    
    func testCannotRemoveAnyArithmeticOrLogicalInstructionBecauseTheyCanAffectFlags() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .add(.A),
            .add(.A)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .add(.A),
            .add(.A)
        ])
    }
    
    func testRemoveRedundantINUV() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .inuv,
            .li(.U, 0),
            .li(.V, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .li(.U, 0),
            .li(.V, 0)
        ])
    }
    
    func testRemoveRedundantINUV_withUVconstruct() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .inuv,
            .li(.UV, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .li(.UV, 0)
        ])
    }
    
    func testRemoveRedundantINXY() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .inxy,
            .li(.X, 0),
            .li(.Y, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .li(.X, 0),
            .li(.Y, 0)
        ])
    }
    
    func testRemoveRedundantLIXY() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .lixy(""),
            .li(.X, 0),
            .li(.Y, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .li(.X, 0),
            .li(.Y, 0)
        ])
    }
    
    func testRemoveRedundantLIXbeforeLIXY() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0),
            .li(.Y, 0),
            .lixy("")
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .fake,
            .lixy("")
        ])
    }
    
    func testRemoveRedundantReadFromG() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .mov(.X, .G),
            .mov(.X, .G)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .fake,
            .mov(.X, .G)
        ])
    }
    
    func testStoreToNone() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .add(.NONE)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .add(.NONE)
        ])
    }
    
    func testBLTIbothDependsOnUVandModifiesIt() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 0),
            .li(.V, 0),
            .blti(.M, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.U, 0),
            .li(.V, 0),
            .blti(.M, 0)
        ])
    }
    
    func testBLTIdependsOnXYDandModifiesXY() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0),
            .blti(.P, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0),
            .blti(.P, 0)
        ])
    }
    
    func testStoreToPeripheralDeviceDependsOnRegisterD() throws {
        // The D register selects the active peripheral device.
        // Instructions which access peripheral devices will depend on D.
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.D, 1), // `LI P, 0' depends on the value of D here
            .li(.P, 0),
            .li(.D, 1),
            .li(.D, 2)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.D, 1), // `LI P, 0' depends on the value of D here
            .li(.P, 0),
            .fake,
            .li(.D, 2)
        ])
    }
    
    func testBLTbothDependsOnUVandModifiesIt() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.U, 0),
            .li(.V, 0),
            .blt(.M, .P)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.U, 0),
            .li(.V, 0),
            .blt(.M, .P)
        ])
    }
    
    func testBLTdependsOnXYDandModifiesXY() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0),
            .blt(.P, .M)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0),
            .blt(.P, .M)
        ])
    }
    
    func testCMPdependsOnRegistersAandB() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0),
            .li(.B, 0),
            .cmp,
            .li(.A, 0),
            .li(.B, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.A, 0),
            .li(.B, 0),
            .cmp,
            .li(.A, 0),
            .li(.B, 0)
        ])
    }
    
    func testArithmeticInstructionsMightDependOnUVDwhenStoringToRAM() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0),
            .li(.B, 0),
            .li(.U, 0),
            .li(.V, 0),
            .add(.M),
            .li(.A, 0),
            .li(.B, 0),
            .li(.U, 0),
            .li(.V, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.A, 0),
            .li(.B, 0),
            .li(.U, 0),
            .li(.V, 0),
            .add(.M),
            .li(.A, 0),
            .li(.B, 0),
            .li(.U, 0),
            .li(.V, 0)
        ])
    }
    
    func testArithmeticInstructionsMightDependOnXYDwhenStoringToPeripheralDevice() throws {
        let optimizer = PopDeadStoreEliminationOptimizationPass()
        optimizer.unoptimizedProgram = [
            .li(.A, 0),
            .li(.B, 0),
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0),
            .add(.P),
            .li(.A, 0),
            .li(.B, 0),
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0)
        ]
        optimizer.optimize()
        let actual = optimizer.optimizedProgram
        XCTAssertEqual(actual, [
            .li(.A, 0),
            .li(.B, 0),
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0),
            .add(.P),
            .li(.A, 0),
            .li(.B, 0),
            .li(.X, 0),
            .li(.Y, 0),
            .li(.D, 0)
        ])
    }
}
