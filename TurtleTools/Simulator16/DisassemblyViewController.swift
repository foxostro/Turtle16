//
//  DisassemblyViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 6/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleCore
import Turtle16SimulatorCore

class DisassemblyViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!
    
    public let tableViewDataSource: DisassemblyTableViewDataSource
    public let computer: Turtle16Computer

    public required init(_ computer: Turtle16Computer) {
        self.tableViewDataSource = DisassemblyTableViewDataSource(computer: computer)
        self.computer = computer
        super.init(nibName: NSNib.Name("DisassemblyViewController"), bundle: Bundle(for: type(of: self)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.virtualMachineStateDidChange(notification:)), name:  .virtualMachineStateDidChange, object: computer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = tableViewDataSource
        tableView.selectRowIndexes(IndexSet(integer: Int(computer.pc)), byExtendingSelection: false)
    }
    
    @objc func virtualMachineStateDidChange(notification: Notification) {
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet(integer: Int(computer.pc)), byExtendingSelection: false)
    }
}
