//
//  Logger.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Provides an interface for logging simulation progress.
open class Logger: NSObject {
    open func append(_ format: String, _ args: CVarArg...) {
    }
}
