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
    @IBOutlet var topLevelSplitView: NSSplitView!
    @IBOutlet var upperDeckSplitView: NSSplitView!
    @IBOutlet var registersContainerView: NSView!
    @IBOutlet var pipelineContainerView: NSView!
    @IBOutlet var disassemblyContainerView: NSView!
    @IBOutlet var memoryContainerView: NSView!
    @IBOutlet var debugConsoleContainerView: NSView!
    
    public var registersViewController: RegistersViewController!
    public var pipelineViewController: PipelineViewController!
    public var disassemblyViewController: DisassemblyViewController!
    public var memoryViewController: MemoryViewController!
    public var debugConsoleViewController: DebugConsoleViewController!
    
    var document: Document {
        self.view.window!.windowController?.document as! Document
    }
    
    override func viewDidLoad() {
        topLevelSplitView.autosaveName = "topLevelSplitView"
        upperDeckSplitView.autosaveName = "upperDeckSplitView"
    }
    
    override func viewWillAppear() {
        registersViewController = RegistersViewController(computer: document.debugger.computer)
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
        
        pipelineViewController = PipelineViewController(computer: document.debugger.computer)
        pipelineContainerView.addSubview(pipelineViewController.view)
        view.addConstraints([
            NSLayoutConstraint(item: pipelineViewController.view,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: pipelineContainerView,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
                NSLayoutConstraint(item: pipelineViewController.view,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: pipelineContainerView,
                                   attribute: .right,
                                   multiplier: 1,
                                   constant: 0),
            NSLayoutConstraint(item: pipelineViewController.view,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: pipelineContainerView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: pipelineViewController.view,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: pipelineContainerView,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0)
        ])
        
        disassemblyViewController = DisassemblyViewController(document.debugger.computer)
        disassemblyContainerView.addSubview(disassemblyViewController.view)
        view.addConstraints([
            NSLayoutConstraint(item: disassemblyViewController.view,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: disassemblyContainerView,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
                NSLayoutConstraint(item: disassemblyViewController.view,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: disassemblyContainerView,
                                   attribute: .right,
                                   multiplier: 1,
                                   constant: 0),
            NSLayoutConstraint(item: disassemblyViewController.view,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: disassemblyContainerView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: disassemblyViewController.view,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: disassemblyContainerView,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0)
        ])
        
        memoryViewController = MemoryViewController(debugger: document.debugger)
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
        
        debugConsoleViewController = DebugConsoleViewController(debugger: document.debugger)
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
    
        debugConsoleViewController.debugger.undoManager = document.undoManager
    }
    
    @IBAction func activateDebugConsole(_ sender: Any) {
        debugConsoleContainerView.isHidden = false
        debugConsoleViewController.debuggerInput.becomeFirstResponder()
    }
    
    @IBAction func toggleDebugConsole(_ sender: Any) {
        debugConsoleContainerView.isHidden = !debugConsoleContainerView.isHidden
    }
    
    @IBAction func toggleRegisters(_ sender: Any) {
        registersContainerView.isHidden = !registersContainerView.isHidden
    }
    
    @IBAction func togglePipeline(_ sender: Any) {
        pipelineContainerView.isHidden = !pipelineContainerView.isHidden
    }
    
    @IBAction func toggleDisassembly(_ sender: Any) {
        disassemblyContainerView.isHidden = !disassemblyContainerView.isHidden
    }
    
    @IBAction func toggleMemory(_ sender: Any) {
        memoryContainerView.isHidden = !memoryContainerView.isHidden
    }
    
    @objc func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(toggleDebugConsole):
            menuItem.state = debugConsoleContainerView.isHidden ? .off : .on
            return true
            
        case #selector(toggleRegisters):
            menuItem.state = registersContainerView.isHidden ? .off : .on
            return !(pipelineContainerView.isHidden && disassemblyContainerView.isHidden && memoryContainerView.isHidden)
            
        case #selector(togglePipeline):
            menuItem.state = pipelineContainerView.isHidden ? .off : .on
            return !(registersContainerView.isHidden && disassemblyContainerView.isHidden && memoryContainerView.isHidden)
        
        case #selector(toggleDisassembly):
            menuItem.state = disassemblyContainerView.isHidden ? .off : .on
            return !(pipelineContainerView.isHidden && registersContainerView.isHidden && memoryContainerView.isHidden)
        
        case #selector(toggleMemory):
            menuItem.state = memoryContainerView.isHidden ? .off : .on
            return !(pipelineContainerView.isHidden && registersContainerView.isHidden && disassemblyContainerView.isHidden)
        
        default:
            return true
        }
    }
}
