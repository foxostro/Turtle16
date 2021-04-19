//
//  Simulator16ViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleCore
import Turtle16SimulatorCore

class Simulator16ViewController: NSViewController {
    @IBOutlet var registersContainerView: NSView!
    @IBOutlet var memoryContainerView: NSView!
    @IBOutlet var debugConsoleContainerView: NSView!
    
    public var registersViewController: RegistersViewController!
    public var memoryViewController: MemoryViewController!
    public var debugConsoleViewController: DebugConsoleViewController!
    
    public let debugger: DebugConsole
    
    required init?(coder: NSCoder) {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        debugger = DebugConsole(computer: computer)
        debugger.sandboxAccessManager = ConcreteSandboxAccessManager()
        
        super.init(coder: coder)
        
        loadExampleProgram()
    }

    fileprivate func loadExampleProgram() {
        let url = Bundle(for: type(of: self)).url(forResource: "example", withExtension: "bin")!
        debugger.interpreter.run(instructions: [
            .reset,
            .load("program", url)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registersViewController = RegistersViewController(computer: debugger.computer)
        registersContainerView.addSubview(registersViewController.view)
        view.addConstraints([
            NSLayoutConstraint(item: registersViewController.view,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: registersContainerView,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
                NSLayoutConstraint(item: registersViewController.view,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: registersContainerView,
                                   attribute: .right,
                                   multiplier: 1,
                                   constant: 0),
            NSLayoutConstraint(item: registersViewController.view,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: registersContainerView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: registersViewController.view,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: registersContainerView,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0)
        ])
        
        memoryViewController = MemoryViewController(debugger: debugger)
        memoryContainerView.addSubview(memoryViewController.view)
        view.addConstraints([
            NSLayoutConstraint(item: memoryViewController.view,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: memoryContainerView,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
                NSLayoutConstraint(item: memoryViewController.view,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: memoryContainerView,
                                   attribute: .right,
                                   multiplier: 1,
                                   constant: 0),
            NSLayoutConstraint(item: memoryViewController.view,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: memoryContainerView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: memoryViewController.view,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: memoryContainerView,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0)
        ])
        
        debugConsoleViewController = DebugConsoleViewController(debugger: debugger)
        debugConsoleContainerView.addSubview(debugConsoleViewController.view)
        view.addConstraints([
            NSLayoutConstraint(item: debugConsoleViewController.view,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: debugConsoleContainerView,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
                NSLayoutConstraint(item: debugConsoleViewController.view,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: debugConsoleContainerView,
                                   attribute: .right,
                                   multiplier: 1,
                                   constant: 0),
            NSLayoutConstraint(item: debugConsoleViewController.view,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: debugConsoleContainerView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: debugConsoleViewController.view,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: debugConsoleContainerView,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0)
        ])
    }
}
