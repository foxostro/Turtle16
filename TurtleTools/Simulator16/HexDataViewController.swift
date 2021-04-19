//
//  HexDataViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/18/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class HexDataViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!
    
    public let tableViewDataSource: NSTableViewDataSource
    public let computer: Turtle16Computer
    
    public required init(_ tableViewDataSource: NSTableViewDataSource, _ computer: Turtle16Computer) {
        self.tableViewDataSource = tableViewDataSource
        self.computer = computer
        super.init(nibName: NSNib.Name("HexDataViewController"), bundle: Bundle(for: type(of: self)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.virtualMachineStateDidChange(notification:)), name:  .virtualMachineStateDidChange, object: computer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = tableViewDataSource
    }
    
    @objc func virtualMachineStateDidChange(notification: Notification) {
        tableView.reloadData()
    }
}
