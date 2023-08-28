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
    
    func testEquality_Equal() throws {
        let path = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!.path
        
        let debugConsole1 = DebugConsole(computer: Turtle16Computer(SchematicLevelCPUModel()))
        debugConsole1.undoManager = UndoManager()
        debugConsole1.eval("load program \"\(path)\"")
        
        let debugConsole2 = DebugConsole(computer: Turtle16Computer(SchematicLevelCPUModel()))
        debugConsole2.undoManager = UndoManager()
        debugConsole2.eval("load program \"\(path)\"")
        
        XCTAssertEqual(debugConsole1, debugConsole2)
        XCTAssertEqual(debugConsole1.hash, debugConsole2.hash)
    }
    
    func testEquality_NotEqual() throws {
        let path = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!.path
        
        let debugConsole1 = DebugConsole(computer: Turtle16Computer(SchematicLevelCPUModel()))
        debugConsole1.undoManager = UndoManager()
        debugConsole1.eval("load program \"\(path)\"")
        debugConsole1.eval("c")
        
        let debugConsole2 = DebugConsole(computer: Turtle16Computer(SchematicLevelCPUModel()))
        debugConsole2.undoManager = UndoManager()
        debugConsole2.eval("load program \"\(path)\"")
        
        XCTAssertNotEqual(debugConsole1, debugConsole2)
        XCTAssertNotEqual(debugConsole1.hash, debugConsole2.hash)
    }
    
    func testEncodeDecodeRoundTrip() throws {
        let path = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!.path
        
        let debugConsole1 = DebugConsole(computer: Turtle16Computer(SchematicLevelCPUModel()))
        debugConsole1.undoManager = UndoManager()
        debugConsole1.eval("load program \"\(path)\"")
        debugConsole1.eval("r")
        
        var data: Data! = nil
        XCTAssertNoThrow(data = try NSKeyedArchiver.archivedData(withRootObject: debugConsole1, requiringSecureCoding: true))
        if data == nil {
            XCTFail()
            return
        }
        var debugConsole2: DebugConsole! = nil
        XCTAssertNoThrow(debugConsole2 = try DebugConsole.decode(from: data))
        XCTAssertEqual(debugConsole1, debugConsole2)
    }
}
