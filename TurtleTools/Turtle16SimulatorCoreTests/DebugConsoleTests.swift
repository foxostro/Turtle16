//
//  DebugConsoleTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 6/10/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class DebugConsoleTests: XCTestCase {
    func testRunProgram() throws {
        let path = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!.path
        let debugConsole = DebugConsole(computer: Turtle16Computer(SchematicLevelCPUModel()))
        debugConsole.eval("load program \"\(path)\"")
        debugConsole.eval("c")
        XCTAssertTrue(debugConsole.computer.isHalted)
    }
    
    func testUndo() throws {
        let path = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!.path
        let debugConsole = DebugConsole(computer: Turtle16Computer(SchematicLevelCPUModel()))
        let undoManager = UndoManager()
        debugConsole.undoManager = undoManager
        debugConsole.eval("load program \"\(path)\"")
        let computer1 = debugConsole.computer
        debugConsole.eval("s")
        undoManager.undo()
        let computer2 = debugConsole.computer
        XCTAssertEqual(computer1, computer2)
    }
}
