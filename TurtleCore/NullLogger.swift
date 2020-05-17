//
//  NullLogger.swift
//  TurtleCore
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class NullLogger: NSObject, Logger {
    public func append(_ format: String, _ args: CVarArg...) {}
}
