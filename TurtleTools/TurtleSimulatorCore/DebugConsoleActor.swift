//
//  DebugConsoleActor.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 1/22/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public final class DebugConsoleActor: NSObject {
    private let debugConsole: DebugConsole
    private let lock = NSCondition()
    
    public var logger: Logger {
        set(value) {
            withLock { debugConsole in
                debugConsole.logger = value
            }
        }
        get {
            withLock { debugConsole in
                debugConsole.logger
            }
        }
    }
    
    public init(debugConsole: DebugConsole) {
        self.debugConsole = debugConsole
    }
    
    public func withLock<R>(_ body: (DebugConsole) throws -> R) rethrows -> R {
        try lock.withLock {
            try body(debugConsole)
        }
    }
    
    public func eval(_ text: String, completionHandler: (DebugConsole) -> Void = {_ in}) {
        withLock { debugConsole in
            debugConsole.eval(text)
            completionHandler(debugConsole)
        }
    }
    
    public func run(instruction: DebugConsoleInstruction) {
        withLock { debugConsole in
            debugConsole.interpreter.runOne(instruction: instruction)
        }
    }
}
