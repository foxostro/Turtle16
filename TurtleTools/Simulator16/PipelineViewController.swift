//
//  PipelineViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 6/8/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleSimulatorCore

class PipelineViewController: NSViewController {
    @IBOutlet var pipelineTableView: NSTableView!
    
    public var pipelineTableViewDataSource: PipelineTableViewDataSource!
    public let computer: Turtle16Computer
    
    public required init(computer: Turtle16Computer) {
        self.computer = computer
        super.init(nibName: NSNib.Name("PipelineViewController"), bundle: Bundle(for: type(of: self)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.virtualMachineStateDidChange(notification:)), name:  .virtualMachineStateDidChange, object: computer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pipelineTableViewDataSource = PipelineTableViewDataSource(computer: computer)
        pipelineTableView.dataSource = pipelineTableViewDataSource
    }
    
    @objc func virtualMachineStateDidChange(notification: Notification) {
        reload()
    }
    
    fileprivate func reload() {
        pipelineTableView.reloadData()
    }
}
