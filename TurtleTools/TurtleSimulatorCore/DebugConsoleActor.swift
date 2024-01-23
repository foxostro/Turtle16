//
//  DebugConsoleActor.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 1/22/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Combine
import Foundation
import TurtleCore

public extension Notification.Name {
    static let debuggerStateDidChange = Notification.Name("debuggerStateDidChange")
}

public final class DebugConsoleActor: NSObject {
    private let debugConsole: DebugConsole
    private let lock = NSCondition()
    private var worker: Thread!
    private enum Command {
        case textCommand(String, completionHandler: (DebugConsole) -> Void)
        case compiledCommand(DebugConsoleInstruction)
    }
    private var commandQueue = Array<Command>()
    private var subscriptions = Set<AnyCancellable>()
    
    private let snapshotLock = NSLock()
    private var internalLatestSnapshot: TurtleComputer?
    public var latestSnapshot: TurtleComputer? {
        snapshotLock.withLock {
            internalLatestSnapshot
        }
    }
    
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
        internalLatestSnapshot = try? TurtleComputer.decode(from: debugConsole.computer.snapshot())
            
        super.init()
        NotificationCenter.default
            .publisher(for: .computerStateDidChange)
            .sink { [weak self] _ in
                guard let self else { return }
                let snapshot = try? TurtleComputer.decode(from: debugConsole.computer.snapshot())
                snapshotLock.withLock {
                    self.internalLatestSnapshot = snapshot
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .debuggerStateDidChange,
                        object: self)
                }
            }
            .store(in: &subscriptions)
        
        worker = Thread { [weak self] in
            self?.processCommandQueue()
        }
        worker.start()
    }
    
    public func withLock<R>(_ body: (DebugConsole) throws -> R) rethrows -> R {
        try lock.withLock {
            try body(debugConsole)
        }
    }
    
    public func eval(_ text: String, completionHandler: @escaping (DebugConsole) -> Void = {_ in}) {
        let command = Command.textCommand(text, completionHandler: completionHandler)
        lock.withLock {
            commandQueue.insert(command, at: 0)
            lock.signal()
        }
    }
    
    public func run(instruction: DebugConsoleInstruction) {
        let command = Command.compiledCommand(instruction)
        lock.withLock {
            commandQueue.insert(command, at: 0)
            lock.signal()
        }
    }
    
    private func processCommandQueue() {
        while true {
            lock.withLock {
                if commandQueue.isEmpty {
                    lock.wait()
                }
                processCommand(commandQueue.popLast())
            }
        }
    }
    
    private func processCommand(_ command: Command?) {
        switch command {
        case .textCommand(let text, let completionHandler):
            debugConsole.eval(text)
            DispatchQueue.main.async { [debugConsole] in
                completionHandler(debugConsole)
            }
            
        case .compiledCommand(let instruction):
            debugConsole.interpreter.runOne(instruction: instruction)
        
        case .none:
            break
        }
    }
}
