//
//  AppDelegate.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    public var executor: ComputerExecutor! = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        executor.stop()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ app:NSApplication) -> Bool {
        return true
    }
}

