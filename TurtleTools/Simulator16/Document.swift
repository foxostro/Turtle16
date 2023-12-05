//
//  Document.swift
//  Simulator16
//
//  Created by Andrew Fox on 6/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleCore
import TurtleSimulatorCore

let kSimulator16ErrorDomain = "kSimulator16ErrorDomain"
let kFailedToReadDocument = -1

class Document: NSDocument {
    public var debugger: DebugConsole

    override init() {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        debugger = DebugConsole(computer: computer)
        debugger.sandboxAccessManager = ConcreteSandboxAccessManager()
        
        super.init()
        
        loadExampleProgram()
    }
    
    fileprivate func loadExampleProgram() {
        let url = Bundle(for: type(of: self)).url(forResource: "example", withExtension: "bin")!
        debugger.interpreter.run(instructions: [
            .reset(type: .soft),
            .load("program", url)
        ])
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        return try NSKeyedArchiver.archivedData(withRootObject: debugger, requiringSecureCoding: true)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        var decodedDebugger: DebugConsole? = nil
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        decodedDebugger = unarchiver.decodeObject(of: DebugConsole.self, forKey: NSKeyedArchiveRootObjectKey)
        if let error = unarchiver.error {
            throw NSError(domain: kSimulator16ErrorDomain, code: kFailedToReadDocument, userInfo: [NSUnderlyingErrorKey: error])
        }
        guard let decodedDebugger else {
            throw NSError(domain: kSimulator16ErrorDomain, code: kFailedToReadDocument, userInfo: nil)
        }
        debugger = decodedDebugger
        debugger.sandboxAccessManager = ConcreteSandboxAccessManager()
    }
}

