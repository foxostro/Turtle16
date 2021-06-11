//
//  DebugConsole.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/13/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class DebugConsole: NSObject {
    public var sandboxAccessManager: SandboxAccessManager? {
        set(value) {
            interpreter.sandboxAccessManager = value
        }
        get {
            interpreter.sandboxAccessManager
        }
    }
    
    public var shouldQuit: Bool {
        set(value) {
            interpreter.shouldQuit = value
        }
        get {
            interpreter.shouldQuit
        }
    }
    
    public var logger: Logger {
        set(value) {
            interpreter.logger = value
        }
        get {
            interpreter.logger
        }
    }
    
    public let computer: Turtle16Computer
    public let interpreter: DebugConsoleCommandLineInterpreter
    public let compiler: DebugConsoleCommandLineCompiler
    public var undoManager: UndoManager? = nil
    
    public init(computer: Turtle16Computer) {
        self.computer = computer
        interpreter = DebugConsoleCommandLineInterpreter(computer)
        compiler = DebugConsoleCommandLineCompiler()
    }
    
    public func eval(_ text: String) {
        assert(!shouldQuit)
        logger.append("> \(text)\n")
        compiler.compile(text)
        
        if compiler.hasError {
            if compiler.errors.count == 1 {
                logger.append(compiler.errors.first!.message)
            } else {
                let error = CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors)
                logger.append(error.message + "\n")
            }
        }
        else {
            if let keyInstruction = compiler.instructions.first, keyInstruction.undoable {
                registerUndo(keyInstruction.actionName)
            }
            interpreter.run(instructions: compiler.instructions)
        }
    }
    
    fileprivate func registerUndo(_ actionName: String?) {
        guard let undoManager = undoManager else {
            return
        }
        if let actionName = actionName {
            undoManager.setActionName(actionName)
        }
        let snapshotForUndo = computer.snapshot()
        undoManager.registerUndo(withTarget: self, handler: { [weak self] in
            self?.registerUndo(actionName)
            $0.computer.restore(from: snapshotForUndo)
        })
    }
}
