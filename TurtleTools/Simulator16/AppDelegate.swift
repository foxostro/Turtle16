//
//  AppDelegate.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        ProcessInfo.processInfo.enableSuddenTermination()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

