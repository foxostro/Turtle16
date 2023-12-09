//
//  DebugConsole.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/13/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

open class DebugConsole: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
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
    
    public let computer: TurtleComputer
    public let interpreter: DebugConsoleCommandLineInterpreter
    public let compiler: DebugConsoleCommandLineCompiler
    public var undoManager: UndoManager? = nil
    
    public required init(computer: TurtleComputer) {
        self.computer = computer
        interpreter = DebugConsoleCommandLineInterpreter(computer)
        compiler = DebugConsoleCommandLineCompiler()
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let computer = coder.decodeObject(of: TurtleComputer.self, forKey: "computer") else {
            return nil
        }
        self.init(computer: computer)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(computer, forKey: "computer")
    }
    
    public static func decode(from data: Data) throws -> DebugConsole {
        var decodedObject: DebugConsole? = nil
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        decodedObject = unarchiver.decodeObject(of: self, forKey: NSKeyedArchiveRootObjectKey)
        if let error = unarchiver.error {
            fatalError("Error occured while attempting to decode \(self) from data: \(error.localizedDescription)")
        }
        guard let decodedObject else {
            fatalError("Failed to decode \(self) from data.")
        }
        return decodedObject
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
        let snapshotForUndo = snapshot()
        undoManager.registerUndo(withTarget: self, handler: { [weak self] in
            self?.registerUndo(actionName)
            $0.restore(from: snapshotForUndo)
        })
    }
    
    fileprivate func snapshot() -> Data {
        return computer.snapshot()
    }
    
    fileprivate func restore(from data: Data) {
        computer.restore(from: data)
    }
    
    public static func ==(lhs: DebugConsole, rhs: DebugConsole) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? DebugConsole,
              computer == rhs.computer else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(computer.hash)
        return hasher.finalize()
    }
}
