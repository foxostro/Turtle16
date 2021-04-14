//
//  StringLogger.swift
//  TurtleCore
//
//  Created by Andrew Fox on 4/13/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public class StringLogger: NSObject, Logger {
    public var stringValue = ""
    
    public func append(_ format: String, _ args: CVarArg...) {
        let message = String(format:format, arguments:args)
        stringValue += message
    }
}
