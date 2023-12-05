//
//  RegistersViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/18/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleSimulatorCore

class RegistersViewController: NSViewController {
    @IBOutlet var registerTableView: NSTableView!
    
    public var registerTableViewDataSource: RegisterTableViewDataSource!
    public let computer: Turtle16Computer
    
    public required init(computer: Turtle16Computer) {
        self.computer = computer
        super.init(nibName: NSNib.Name("RegistersViewController"), bundle: Bundle(for: type(of: self)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.virtualMachineStateDidChange(notification:)), name:  .virtualMachineStateDidChange, object: computer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewDataSource = RegisterTableViewDataSource(computer: computer)
        registerTableView.dataSource = registerTableViewDataSource
    }
    
    @objc func virtualMachineStateDidChange(notification: Notification) {
        reload()
    }
    
    fileprivate func reload() {
        registerTableView.reloadData()
    }
}
