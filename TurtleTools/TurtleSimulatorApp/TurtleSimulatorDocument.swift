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
    
    struct Snapshot: Codable {
        let encodedDebugger: Data
        let isShowingRegisters: Bool
        let isShowingPipeline: Bool
        let isShowingDisassembly: Bool
        let isShowingMemory: Bool
    }
    
    let debugger: DebugConsole
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        debugger = DebugConsole(computer: TurtleComputer(SchematicLevelCPUModel()))
        debugger.sandboxAccessManager = ConcreteSandboxAccessManager()
        
        let url = Bundle(for: type(of: self)).url(forResource: "example", withExtension: "bin")!
        debugger.interpreter.run(instructions: [
            .reset(type: .soft),
            .load("program", url)
        ])
        
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
        decodedDebugger = unarchiver.decodeObject(of: DebugConsole.self, forKey: NSKeyedArchiveRootObjectKey)
        guard let decodedDebugger else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        debugger = decodedDebugger
        debugger.sandboxAccessManager = ConcreteSandboxAccessManager()
        
        subscribe()
    }
    
    private func subscribe() {
        NotificationCenter.default
            .publisher(for: .virtualMachineStateDidChange,
                       object: debugger.computer)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }
    
    func snapshot(contentType: UTType) throws -> Snapshot {
        let encodedDebugger = try NSKeyedArchiver.archivedData(withRootObject: debugger, requiringSecureCoding: true)
        let snapshot = Snapshot(encodedDebugger: encodedDebugger,
                                isShowingRegisters: isShowingRegisters,
                                isShowingPipeline: isShowingPipeline,
                                isShowingDisassembly: isShowingDisassembly,
                                isShowingMemory: isShowingMemory)
        return snapshot
    }
    
    func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}
