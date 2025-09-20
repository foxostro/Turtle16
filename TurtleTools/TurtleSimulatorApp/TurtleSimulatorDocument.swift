//
//  TurtleSimulatorDocument.swift
//  TurtleSimulator
//
//  Created by Andrew Fox on 12/5/23.
//  Copyright © 2023 Andrew Fox. All rights reserved.
//

import Combine
import SwiftUI
import TurtleCore
import TurtleSimulatorCore
import UniformTypeIdentifiers

extension UTType {
    static var turtleSimulatorSession: UTType {
        UTType(exportedAs: "com.foxostro.TurtleSimulator.session")
    }
}

class TurtleSimulatorDocument: ReferenceFileDocument {
    static var readableContentTypes: [UTType] { [.turtleSimulatorSession] }

    @Published var isShowingRegisters = true
    @Published var isShowingPipeline = true
    @Published var isShowingDisassembly = true
    @Published var isShowingMemory = true
    @Published var isFreeRunning = false

    struct Snapshot: Codable {
        let encodedDebugger: Data
        let isShowingRegisters: Bool
        let isShowingPipeline: Bool
        let isShowingDisassembly: Bool
        let isShowingMemory: Bool
    }

    let debugger: DebugConsoleActor
    private var subscriptions = Set<AnyCancellable>()

    init() {
        let debugConsole = DebugConsole(computer: TurtleComputer(SchematicLevelCPUModel()))
        debugConsole.sandboxAccessManager = ConcreteSandboxAccessManager()

        let url = Bundle(for: type(of: self)).url(forResource: "example", withExtension: "bin")!
        debugConsole.interpreter.run(instructions: [
            .reset(type: .soft),
            .load("program", url)
        ])

        debugger = DebugConsoleActor(debugConsole: debugConsole)

        subscribe()
    }

    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let snapshot = try JSONDecoder().decode(Snapshot.self, from: data)

        isShowingRegisters = snapshot.isShowingRegisters
        isShowingPipeline = snapshot.isShowingPipeline
        isShowingDisassembly = snapshot.isShowingDisassembly
        isShowingMemory = snapshot.isShowingMemory

        var decodedDebugger: DebugConsole? = nil
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: snapshot.encodedDebugger)
        unarchiver.requiresSecureCoding = false
        decodedDebugger = unarchiver.decodeObject(
            of: DebugConsole.self,
            forKey: NSKeyedArchiveRootObjectKey
        )
        guard let decodedDebugger else {
            throw CocoaError(.fileReadCorruptFile)
        }

        decodedDebugger.sandboxAccessManager = ConcreteSandboxAccessManager()
        debugger = DebugConsoleActor(debugConsole: decodedDebugger)

        isFreeRunning = debugger.isFreeRunning

        subscribe()
    }

    private func subscribe() {
        NotificationCenter.default
            .publisher(for: .debuggerStateDidChange, object: debugger)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                objectWillChange.send()
            }
            .store(in: &subscriptions)

        NotificationCenter.default
            .publisher(for: .debuggerIsFreeRunningDidChange, object: debugger)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                isFreeRunning = debugger.isFreeRunning
            }
            .store(in: &subscriptions)
    }

    func snapshot(contentType _: UTType) throws -> Snapshot {
        try debugger.withLock { debugConsole in
            let encodedDebugger = try NSKeyedArchiver.archivedData(
                withRootObject: debugConsole,
                requiringSecureCoding: true
            )
            let snapshot = Snapshot(
                encodedDebugger: encodedDebugger,
                isShowingRegisters: isShowingRegisters,
                isShowingPipeline: isShowingPipeline,
                isShowingDisassembly: isShowingDisassembly,
                isShowingMemory: isShowingMemory
            )
            return snapshot
        }
    }

    func fileWrapper(
        snapshot: Snapshot,
        configuration _: WriteConfiguration
    ) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }

    func pause() {
        debugger.pause()
    }

    func run() {
        debugger.run(instruction: .run)
    }
}
