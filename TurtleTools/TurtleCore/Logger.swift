//
//  Logger.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Foundation

// Provides an interface for logging simulation progress.
public protocol Logger {
    func append(_ format: String, _ args: CVarArg...)
}
